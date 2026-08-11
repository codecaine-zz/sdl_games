module main

import math
import rand
import sdl

struct App {
mut:
	window      &sdl.Window   = unsafe { nil }
	renderer    &sdl.Renderer = unsafe { nil }
	game        BreakoutGame
	sound_mgr   SoundManager
	particles   []Particle
	mouse_x     int
	mouse_y     int
	key_left    bool
	key_right   bool
	key_launch  bool
	key_fire    bool
	paused      bool
	btn_restart Button
	btn_level   Button
	btn_sound   Button
}

fn new_app() App {
	mut app := App{
		game:        new_breakout_game()
		sound_mgr:   new_sound_manager()
		btn_restart: Button{
			x:            100
			y:            565
			w:            170
			h:            30
			text:         'RESTART [R]'
			bg_color:     Color{r: 25, g: 35, b: 55}
			hover_color:  Color{r: 45, g: 60, b: 90}
			text_color:   Color{r: 255, g: 255, b: 255}
			border_color: Color{r: 70, g: 90, b: 140}
		}
		btn_level:   Button{
			x:            310
			y:            565
			w:            180
			h:            30
			text:         'NEXT LEVEL [L]'
			bg_color:     Color{r: 25, g: 35, b: 55}
			hover_color:  Color{r: 45, g: 60, b: 90}
			text_color:   Color{r: 255, g: 255, b: 255}
			border_color: Color{r: 70, g: 90, b: 140}
		}
		btn_sound:   Button{
			x:            520
			y:            565
			w:            170
			h:            30
			text:         'SOUND: ON [O]'
			bg_color:     Color{r: 25, g: 35, b: 55}
			hover_color:  Color{r: 45, g: 60, b: 90}
			text_color:   Color{r: 255, g: 255, b: 255}
			border_color: Color{r: 70, g: 90, b: 140}
		}
	}
	return app
}

fn (mut app App) spawn_particles(x f64, y f64, count int, color Color) {
	for _ in 0 .. count {
		angle := rand.f64() * 2.0 * math.pi
		speed := 40.0 + rand.f64() * 140.0
		life := 0.2 + rand.f64() * 0.4
		app.particles << Particle{
			x:        x
			y:        y
			dx:       math.cos(angle) * speed
			dy:       math.sin(angle) * speed
			life:     life
			max_life: life
			color:    color
		}
	}
}

fn (mut app App) reset_game() {
	app.sound_mgr.clear_audio()
	app.game.reset()
	app.game.last_sound_event = ''
}

fn (mut app App) update(dt f64) {
	if app.paused {
		return
	}

	mut move_x := f64(app.mouse_x)
	if app.key_left {
		move_x = app.game.paddle.x + app.game.paddle.w / 2.0 - 400.0 * dt
	} else if app.key_right {
		move_x = app.game.paddle.x + app.game.paddle.w / 2.0 + 400.0 * dt
	}

	if app.game.level_cleared && app.key_launch {
		app.game.level++
		if app.game.level > max_level {
			app.game.level = 1
		}
		app.game.load_level(app.game.level)
		app.key_launch = false
	} else {
		app.game.step(dt, move_x, app.key_launch, app.key_fire)
		app.key_launch = false
		app.key_fire = false
	}

	// Fireball particle trail
	if app.game.paddle.fireball_timer > 0.0 {
		for ball in app.game.balls {
			if !ball.attached {
				app.spawn_particles(ball.x, ball.y, 2, Color{r: 255, g: 120, b: 0})
			}
		}
	}

	// Sound Events & Particle Triggering
	if app.game.last_sound_event != '' {
		event := app.game.last_sound_event
		app.game.last_sound_event = ''
		match event {
			'paddle' {
				app.sound_mgr.play_paddle_hit()
			}
			'brick' {
				app.sound_mgr.play_brick_hit(rand.f64())
				app.spawn_particles(f64(app.mouse_x), 150.0, 8, Color{r: 255, g: 255, b: 200})
			}
			'metal' {
				app.sound_mgr.play_metal_hit()
			}
			'explosion' {
				app.sound_mgr.play_explosion_sound()
				app.spawn_particles(f64(app.mouse_x), 150.0, 25, Color{r: 255, g: 80, b: 40})
			}
			'laser' {
				app.sound_mgr.play_laser_sound()
			}
			'powerup' {
				app.sound_mgr.play_powerup_sound()
				app.spawn_particles(app.game.paddle.x + app.game.paddle.w / 2, app.game.paddle.y,
					20, Color{r: 0, g: 255, b: 200})
			}
			'lose' {
				app.sound_mgr.play_lose_ball_sound()
			}
			'win' {
				app.sound_mgr.play_win_fanfare()
				app.spawn_particles(world_w / 2, 200, 50, Color{r: 0, g: 255, b: 150})
			}
			else {}
		}
	}

	// Update Particles
	for i := app.particles.len - 1; i >= 0; i-- {
		mut p := app.particles[i]
		p.x += p.dx * dt
		p.y += p.dy * dt
		p.life -= dt

		if p.life <= 0.0 {
			app.particles.delete(i)
		} else {
			app.particles[i] = p
		}
	}
}

fn main() {
	if sdl.init(sdl.init_video) < 0 {
		eprintln('Failed to initialize SDL Video')
		return
	}
	defer {
		sdl.quit()
	}

	mut app := new_app()

	app.window = sdl.create_window('Breakout Pro: Brick Breaker Overdrive'.str, sdl.windowpos_centered,
		sdl.windowpos_centered, world_w, world_h, u32(sdl.WindowFlags.shown))
	if unsafe { app.window == nil } {
		eprintln('Failed to create SDL Window')
		return
	}
	defer {
		sdl.destroy_window(app.window)
	}

	app.renderer = sdl.create_renderer(app.window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if unsafe { app.renderer == nil } {
		eprintln('Failed to create SDL Renderer')
		return
	}
	defer {
		sdl.destroy_renderer(app.renderer)
	}

	mut last_ticks := sdl.get_ticks()

	for {
		mut event := sdl.Event{}
		mut quit := false

		for 0 < sdl.poll_event(&event) {
			match event.@type {
				.quit {
					quit = true
				}
				.mousemotion {
					app.mouse_x = event.motion.x
					app.mouse_y = event.motion.y
				}
				.mousebuttondown {
					if event.button.button == u8(sdl.button_left) {
						mx := event.button.x
						my := event.button.y

						if app.btn_restart.contains(mx, my) {
							app.reset_game()
						} else if app.btn_level.contains(mx, my) {
							app.game.level++
							if app.game.level > max_level {
								app.game.level = 1
							}
							app.game.load_level(app.game.level)
						} else if app.btn_sound.contains(mx, my) {
							muted := !app.sound_mgr.toggle_sound()
							app.btn_sound.text = if muted { 'SOUND: OFF [O]' } else { 'SOUND: ON [O]' }
						} else {
							app.key_launch = true
							app.key_fire = true
						}
					}
				}
				.keydown {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = true
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = true
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.up) {
						app.key_launch = true
						app.key_fire = true
					} else if sym == int(sdl.KeyCode.r) {
						app.reset_game()
					} else if sym == int(sdl.KeyCode.l) {
						app.game.level++
						if app.game.level > max_level {
							app.game.level = 1
						}
						app.game.load_level(app.game.level)
					} else if sym == int(sdl.KeyCode.p) {
						app.paused = !app.paused
					} else if sym == int(sdl.KeyCode.o) {
						muted := !app.sound_mgr.toggle_sound()
						app.btn_sound.text = if muted { 'SOUND: OFF [O]' } else { 'SOUND: ON [O]' }
					} else if sym == int(sdl.KeyCode.escape) {
						quit = true
					}
				}
				.keyup {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = false
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = false
					}
				}
				else {}
			}
		}

		if quit {
			break
		}

		current_ticks := sdl.get_ticks()
		dt := f64(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks

		app.update(math.min(dt, 0.05))

		render_breakout_game(app.renderer, &app.game, app.particles)

		// Render UI buttons
		app.btn_restart.render(app.renderer, app.mouse_x, app.mouse_y)
		app.btn_level.render(app.renderer, app.mouse_x, app.mouse_y)
		app.btn_sound.render(app.renderer, app.mouse_x, app.mouse_y)

		if app.paused {
			draw_text_centered(app.renderer, world_w / 2, 280, 'PAUSED', 4, Color{
				r: 255
				g: 255
				b: 0
			})
		}

		sdl.render_present(app.renderer)
		sdl.delay(16)
	}
}
