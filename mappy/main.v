module main

import math
import sdl

struct App {
mut:
	window      &sdl.Window   = unsafe { nil }
	renderer    &sdl.Renderer = unsafe { nil }
	game        GameEngine
	sound_mgr   SoundManager
	key_left    bool
	key_right   bool
	key_action  bool
}

fn new_app() App {
	return App{
		game:      new_game_engine()
		sound_mgr: new_sound_manager()
	}
}

fn (app &App) init() bool {
	if sdl.init(sdl.init_video | sdl.init_audio) < 0 {
		eprintln('Failed to init SDL')
		return false
	}

	mut mutable_app := unsafe { &App(app) }

	window_flags := u32(sdl.WindowFlags.shown)
	mutable_app.window = sdl.create_window('Mappy - Namco Arcade Police Mouse Classic'.str,
		sdl.windowpos_centered, sdl.windowpos_centered, 800, 600, window_flags)

	if mutable_app.window == unsafe { nil } {
		eprintln('Failed to create window')
		return false
	}

	render_flags := u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync)
	mutable_app.renderer = sdl.create_renderer(mutable_app.window, -1, render_flags)

	if mutable_app.renderer == unsafe { nil } {
		eprintln('Failed to create renderer')
		return false
	}

	sdl.set_render_draw_blend_mode(mutable_app.renderer, .blend)
	return true
}

fn (app &App) run() {
	mut mutable_app := unsafe { &App(app) }
	mut event := sdl.Event{}
	mut last_ticks := sdl.get_ticks()
	mut running := true

	for running {
		current_ticks := sdl.get_ticks()
		raw_dt := f64(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks
		dt := math.min(0.033, if raw_dt > 0.001 { raw_dt } else { 1.0 / 60.0 })

		mutable_app.key_action = false // Action trigger is one-shot per keydown

		for sdl.poll_event(&event) != 0 {
			match unsafe { event.type } {
				.quit {
					running = false
				}
				.keydown {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						mutable_app.key_left = true
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						if mutable_app.game.state == .title && sym == int(sdl.KeyCode.d) {
							mutable_app.game.cycle_difficulty()
						} else {
							mutable_app.key_right = true
						}
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) || sym == int(sdl.KeyCode.@return) {
						mutable_app.key_action = true
						if mutable_app.game.state == .title {
							mutable_app.game.start_game(1)
						} else if mutable_app.game.state == .game_over {
							mutable_app.game.start_game(1)
						}
					} else if sym == int(sdl.KeyCode._1) {
						if mutable_app.game.state == .title {
							mutable_app.game.set_difficulty(.easy)
						}
					} else if sym == int(sdl.KeyCode._2) {
						if mutable_app.game.state == .title {
							mutable_app.game.set_difficulty(.normal)
						}
					} else if sym == int(sdl.KeyCode._3) {
						if mutable_app.game.state == .title {
							mutable_app.game.set_difficulty(.hard)
						}
					} else if sym == int(sdl.KeyCode._4) {
						if mutable_app.game.state == .title {
							mutable_app.game.set_difficulty(.expert)
						}
					} else if sym == int(sdl.KeyCode._5) || sym == int(sdl.KeyCode.b) {
						if mutable_app.game.state == .title {
							mutable_app.game.start_game(3) // Start directly on Bonus Round!
						}
					} else if sym == int(sdl.KeyCode.tab) {
						if mutable_app.game.state == .title {
							mutable_app.game.cycle_difficulty()
						}
					} else if sym == int(sdl.KeyCode.p) {
						if mutable_app.game.state == .playing {
							mutable_app.game.state = .paused
						} else if mutable_app.game.state == .paused {
							mutable_app.game.state = .playing
						}
					} else if sym == int(sdl.KeyCode.r) {
						mutable_app.game.start_game(1)
					} else if sym == int(sdl.KeyCode.m) || sym == int(sdl.KeyCode.s) {
						mutable_app.sound_mgr.toggle_sound()
					}
				}
				.keyup {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						mutable_app.key_left = false
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						mutable_app.key_right = false
					}
				}
				else {}
			}
		}

		// Update game logic
		mutable_app.game.update(dt, mutable_app.key_left, mutable_app.key_right,
			mutable_app.key_action, mut mutable_app.sound_mgr)

		// Render frame
		draw_game(mutable_app.renderer, &mutable_app.game)
		sdl.render_present(mutable_app.renderer)
		sdl.delay(1)
	}

	sdl.destroy_renderer(mutable_app.renderer)
	sdl.destroy_window(mutable_app.window)
	sdl.quit()
}

fn main() {
	mut app := new_app()
	if app.init() {
		app.run()
	}
}
