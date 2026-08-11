module main

import sdl

struct App {
mut:
	window    &sdl.Window   = unsafe { nil }
	renderer  &sdl.Renderer = unsafe { nil }
	game      GameEngine
	sound_mgr SoundManager
	p1_left   bool
	p1_right  bool
	p1_flap   bool
	p2_left   bool
	p2_right  bool
	p2_flap   bool
}

fn new_app() App {
	return App{
		game:      new_game_engine()
		sound_mgr: new_sound_manager()
	}
}

fn (app &App) init() bool {
	if sdl.init(sdl.init_video) < 0 {
		eprintln('Failed to init SDL Video')
		return false
	}

	mut mutable_app := unsafe { &App(app) }

	window_flags := u32(sdl.WindowFlags.shown)
	mutable_app.window = sdl.create_window('NES Balloon Fight - 1984 Arcade Recreation'.str,
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
	mut running := true
	target_dt := 1.0 / 60.0

	for running {
		for sdl.poll_event(&event) != 0 {
			match unsafe { event.type } {
				.quit {
					running = false
				}
				.keydown {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						mutable_app.p1_left = true
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						mutable_app.p1_right = true
					} else if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) || sym == int(sdl.KeyCode.space) {
						mutable_app.p1_flap = true
						if mutable_app.game.state == .phase_clear {
							mutable_app.game.state = .playing
							mutable_app.game.setup_stage()
						} else if mutable_app.game.state == .title {
							mutable_app.game.start_game(.mode_a_1p)
						} else if mutable_app.game.state == .game_over {
							mutable_app.game.start_game(.mode_a_1p)
						}
					} else if sym == int(sdl.KeyCode.j) {
						mutable_app.p2_left = true
					} else if sym == int(sdl.KeyCode.l) {
						mutable_app.p2_right = true
					} else if sym == int(sdl.KeyCode.i) || sym == int(sdl.KeyCode.o) {
						mutable_app.p2_flap = true
					} else if sym == int(sdl.KeyCode._1) {
						mutable_app.game.start_game(.mode_a_1p)
					} else if sym == int(sdl.KeyCode._2) {
						mutable_app.game.start_game(.mode_b_2p)
					} else if sym == int(sdl.KeyCode._3) {
						mutable_app.game.start_game(.balloon_trip)
					} else if sym == int(sdl.KeyCode.p) {
						if mutable_app.game.state == .playing {
							mutable_app.game.state = .paused
						} else if mutable_app.game.state == .paused {
							mutable_app.game.state = .playing
						}
					} else if sym == int(sdl.KeyCode.r) {
						mutable_app.game.start_game(mutable_app.game.mode)
					} else if sym == int(sdl.KeyCode.m) {
						mutable_app.sound_mgr.toggle_sound()
					}
				}
				.keyup {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						mutable_app.p1_left = false
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						mutable_app.p1_right = false
					} else if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) || sym == int(sdl.KeyCode.space) {
						mutable_app.p1_flap = false
					} else if sym == int(sdl.KeyCode.j) {
						mutable_app.p2_left = false
					} else if sym == int(sdl.KeyCode.l) {
						mutable_app.p2_right = false
					} else if sym == int(sdl.KeyCode.i) || sym == int(sdl.KeyCode.o) {
						mutable_app.p2_flap = false
					}
				}
				else {}
			}
		}

		// Update game logic
		mutable_app.game.update(target_dt, mutable_app.p1_left, mutable_app.p1_right,
			mutable_app.p1_flap, mutable_app.p2_left, mutable_app.p2_right, mutable_app.p2_flap,
			&mutable_app.sound_mgr)

		// Render frame
		draw_game(mutable_app.renderer, &mutable_app.game)
		sdl.render_present(mutable_app.renderer)
		sdl.delay(16)
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
