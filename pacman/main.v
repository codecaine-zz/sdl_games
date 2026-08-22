module main

import sdl

struct App {
mut:
	window    &sdl.Window   = unsafe { nil }
	renderer  &sdl.Renderer = unsafe { nil }
	game      Game
	sound_mgr SoundManager
	btn_reset Button
	btn_sound Button
	btn_pause Button
	mouse_x   int
	mouse_y   int
}

fn new_app() App {
	mut app := App{
		game:      new_game()
		sound_mgr: new_sound_manager()
		btn_reset: Button{
			x:            735
			y:            160
			w:            200
			h:            44
			text:         'RESET [R]'
			bg_color:     Color{
				r: 35
				g: 45
				b: 70
			}
			hover_color:  Color{
				r: 55
				g: 70
				b: 105
			}
			text_color:   Color{
				r: 255
				g: 255
				b: 255
			}
			border_color: Color{
				r: 85
				g: 105
				b: 150
			}
		}
		btn_sound: Button{
			x:            735
			y:            225
			w:            200
			h:            44
			text:         'SOUND: ON [S]'
			bg_color:     Color{
				r: 35
				g: 45
				b: 70
			}
			hover_color:  Color{
				r: 55
				g: 70
				b: 105
			}
			text_color:   Color{
				r: 255
				g: 255
				b: 255
			}
			border_color: Color{
				r: 85
				g: 105
				b: 150
			}
		}
		btn_pause: Button{
			x:            735
			y:            290
			w:            200
			h:            44
			text:         'PAUSE [P]'
			bg_color:     Color{
				r: 35
				g: 45
				b: 70
			}
			hover_color:  Color{
				r: 55
				g: 70
				b: 105
			}
			text_color:   Color{
				r: 255
				g: 255
				b: 255
			}
			border_color: Color{
				r: 85
				g: 105
				b: 150
			}
		}
	}
	return app
}

fn (mut app App) init_sdl() bool {
	if sdl.init(sdl.init_video | sdl.init_audio) < 0 {
		eprintln('Failed to init SDL')
		return false
	}

	app.window = sdl.create_window(c'Pac-Man Arcade - V & SDL2', sdl.windowpos_centered,
		sdl.windowpos_centered, win_w, win_h, u32(sdl.WindowFlags.shown))
	if app.window == unsafe { nil } {
		eprintln('Failed to create window')
		return false
	}

	app.renderer = sdl.create_renderer(app.window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if app.renderer == unsafe { nil } {
		eprintln('Failed to create renderer')
		return false
	}

	return true
}

fn (mut app App) run() {
	mut last_ticks := sdl.get_ticks()
	mut should_close := false

	for !should_close {
		current_ticks := sdl.get_ticks()
		dt := f64(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks

		mut ev := sdl.Event{}
		for 0 < sdl.poll_event(&ev) {
			match ev.@type {
				.quit {
					should_close = true
				}
				.mousemotion {
					app.mouse_x = ev.motion.x
					app.mouse_y = ev.motion.y
				}
				.mousebuttondown {
					mx := ev.button.x
					my := ev.button.y

					if app.btn_reset.contains(mx, my) {
						app.game.init_level()
						app.game.score = 0
						app.game.lives = 3
					} else if app.btn_sound.contains(mx, my) {
						is_on := app.sound_mgr.toggle_sound()
						app.btn_sound.text = if is_on {
							'SOUND: ON [S]'
						} else {
							'SOUND: OFF [S]'
						}
					} else if app.btn_pause.contains(mx, my) {
						if app.game.status == .playing {
							app.game.status = .paused
						} else if app.game.status == .paused {
							app.game.status = .playing
						}
					}
				}
				.keydown {
					sym := ev.key.keysym.sym
					if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) {
						app.game.pacman.next_dir = .up
					} else if sym == int(sdl.KeyCode.down) || sym == int(sdl.KeyCode.s) {
						app.game.pacman.next_dir = .down
					} else if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.game.pacman.next_dir = .left
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.game.pacman.next_dir = .right
					} else if sym == int(sdl.KeyCode.r) {
						app.game.init_level()
						app.game.score = 0
						app.game.lives = 3
					} else if sym == int(sdl.KeyCode.p) {
						if app.game.status == .playing {
							app.game.status = .paused
						} else if app.game.status == .paused {
							app.game.status = .playing
						}
					} else if sym == int(sdl.KeyCode.s) || sym == int(sdl.KeyCode.o) {
						is_on := app.sound_mgr.toggle_sound()
						app.btn_sound.text = if is_on {
							'SOUND: ON [S]'
						} else {
							'SOUND: OFF [S]'
						}
					} else if sym == int(sdl.KeyCode.escape) {
						should_close = true
					}
				}
				else {}
			}
		}

		// Update game logic
		ate_dot, ate_power, ate_ghost, pac_died, level_win := app.game.update(dt)
		if ate_dot {
			app.sound_mgr.play_waka_sound()
		}
		if ate_power {
			app.sound_mgr.play_power_pellet_sound()
		}
		if ate_ghost {
			app.sound_mgr.play_eat_ghost_sound()
		}
		if pac_died {
			app.sound_mgr.play_death_sound()
		}
		if level_win {
			app.sound_mgr.play_extra_life_sound()
		}

		// Render frame
		draw_game(app.renderer, app.game, app.mouse_x, app.mouse_y, app.btn_reset, app.btn_sound,
			app.btn_pause)
		sdl.render_present(app.renderer)

		sdl.delay(16) // ~60 FPS
	}
}

fn (mut app App) cleanup() {
	app.sound_mgr.cleanup()
	if app.renderer != unsafe { nil } {
		sdl.destroy_renderer(app.renderer)
	}
	if app.window != unsafe { nil } {
		sdl.destroy_window(app.window)
	}
	sdl.quit()
}

fn main() {
	mut app := new_app()
	if !app.init_sdl() {
		return
	}
	defer {
		app.cleanup()
	}
	app.run()
}
