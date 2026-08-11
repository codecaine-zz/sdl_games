module main

import math
import rand
import sdl

struct App {
mut:
	window        &sdl.Window   = unsafe { nil }
	renderer      &sdl.Renderer = unsafe { nil }
	game          AsteroidsGame
	sound_mgr     SoundManager
	particles     []Particle
	mouse_x       int
	mouse_y       int
	key_left      bool
	key_right     bool
	key_up        bool
	key_fire      bool
	key_hyper     bool
	key_shield    bool
	paused        bool
	btn_restart   Button
	btn_hyper     Button
	btn_shield    Button
	btn_sound     Button
}

fn new_app() App {
	mut app := App{
		game:        new_asteroids_game()
		sound_mgr:   new_sound_manager()
		btn_restart: Button{
			x:            50
			y:            540
			w:            150
			h:            40
			text:         'RESTART [R]'
			bg_color:     Color{r: 25, g: 35, b: 55}
			hover_color:  Color{r: 45, g: 60, b: 90}
			text_color:   Color{r: 255, g: 255, b: 255}
			border_color: Color{r: 70, g: 90, b: 140}
		}
		btn_hyper:   Button{
			x:            220
			y:            540
			w:            170
			h:            40
			text:         'HYPERSPACE [H]'
			bg_color:     Color{r: 25, g: 35, b: 55}
			hover_color:  Color{r: 45, g: 60, b: 90}
			text_color:   Color{r: 255, g: 255, b: 255}
			border_color: Color{r: 70, g: 90, b: 140}
		}
		btn_shield:  Button{
			x:            410
			y:            540
			w:            150
			h:            40
			text:         'SHIELD [S]'
			bg_color:     Color{r: 25, g: 35, b: 55}
			hover_color:  Color{r: 45, g: 60, b: 90}
			text_color:   Color{r: 255, g: 255, b: 255}
			border_color: Color{r: 70, g: 90, b: 140}
		}
		btn_sound:   Button{
			x:            580
			y:            540
			w:            170
			h:            40
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
		speed := 30.0 + rand.f64() * 120.0
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

	mut rot_input := 0.0
	if app.key_left {
		rot_input -= 1.0
	}
	if app.key_right {
		rot_input += 1.0
	}

	app.game.step(dt, rot_input, app.key_up, app.key_fire, app.key_hyper, app.key_shield)

	// Consume one-shot triggers
	app.key_hyper = false
	app.key_shield = false

	// Particle thruster trail
	if app.game.ship.thrusting && !app.game.game_over {
		tx := app.game.ship.x - math.cos(app.game.ship.angle) * 14.0
		ty := app.game.ship.y - math.sin(app.game.ship.angle) * 14.0
		app.spawn_particles(tx, ty, 2, Color{r: 255, g: 150, b: 0})
	}

	// Process Sound Triggers & Sound FX Particles
	if app.game.last_sound_event != '' {
		event := app.game.last_sound_event
		app.game.last_sound_event = ''
		match event {
			'laser' {
				app.sound_mgr.play_laser_sound()
			}
			'plasma' {
				app.sound_mgr.play_plasma_sound()
			}
			'explosion' {
				app.sound_mgr.play_explosion_sound(app.game.last_sound_param)
			}
			'powerup' {
				app.sound_mgr.play_powerup_sound()
				app.spawn_particles(app.game.ship.x, app.game.ship.y, 25, Color{
					r: 255
					g: 255
					b: 0
				})
			}
			'emp' {
				app.sound_mgr.play_emp_sound()
				app.spawn_particles(world_w / 2, world_h / 2, 60, Color{
					r: 200
					g: 100
					b: 255
				})
			}
			'warp' {
				app.sound_mgr.play_warp_sound()
				app.spawn_particles(app.game.ship.x, app.game.ship.y, 30, Color{
					r: 0
					g: 255
					b: 255
				})
			}
			'shield' {
				app.sound_mgr.play_shield_sound()
			}
			else {}
		}
	}

	// Update Particle physics
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

	app.window = sdl.create_window('Asteroids Pro: Top-Down Space Shooter'.str, sdl.windowpos_centered,
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
						} else if app.btn_hyper.contains(mx, my) {
							app.key_hyper = true
						} else if app.btn_shield.contains(mx, my) {
							app.key_shield = true
						} else if app.btn_sound.contains(mx, my) {
							muted := !app.sound_mgr.toggle_sound()
							app.btn_sound.text = if muted { 'SOUND: OFF [O]' } else { 'SOUND: ON [O]' }
						}
					}
				}
				.keydown {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = true
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = true
					} else if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) {
						app.key_up = true
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.j) {
						app.key_fire = true
					} else if sym == int(sdl.KeyCode.h) || sym == int(sdl.KeyCode.k) {
						app.key_hyper = true
					} else if sym == int(sdl.KeyCode.s) || sym == int(sdl.KeyCode.down) {
						app.key_shield = true
					} else if sym == int(sdl.KeyCode.r) {
						app.reset_game()
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
					} else if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) {
						app.key_up = false
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.j) {
						app.key_fire = false
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

		render_asteroids_game(app.renderer, &app.game, app.particles)

		// Render UI buttons
		app.btn_restart.render(app.renderer, app.mouse_x, app.mouse_y)
		app.btn_hyper.render(app.renderer, app.mouse_x, app.mouse_y)
		app.btn_shield.render(app.renderer, app.mouse_x, app.mouse_y)
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
