module main

import sdl

struct App {
mut:
	window      &sdl.Window   = unsafe { nil }
	renderer    &sdl.Renderer = unsafe { nil }
	game        GameEngine
	sound_mgr   SoundManager
	p1_left     bool
	p1_right    bool
	mario_left  bool
	mario_right bool
	plunge_hold bool
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
	mutable_app.window = sdl.create_window('NES Pinball - 1984 Nintendo Arcade Recreation'.str,
		sdl.windowpos_centered, sdl.windowpos_centered, 800, 900, window_flags)

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
					if sym == int(sdl.KeyCode.escape) {
						running = false
					} else if sym == int(sdl.KeyCode._1) {
						if mutable_app.game.state == .title {
							mutable_app.game.start_game(.mode_1p)
						}
					} else if sym == int(sdl.KeyCode._2) {
						if mutable_app.game.state == .title {
							mutable_app.game.start_game(.mode_2p)
						}
					} else if sym == int(sdl.KeyCode.z) || sym == int(sdl.KeyCode.left)
						|| sym == int(sdl.KeyCode.a) {
						mutable_app.p1_left = true
						mutable_app.mario_left = true
					} else if sym == int(sdl.KeyCode.x) || sym == int(sdl.KeyCode.right)
						|| sym == int(sdl.KeyCode.d) {
						mutable_app.p1_right = true
						mutable_app.mario_right = true
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.down) {
						mutable_app.plunge_hold = true
					} else if sym == int(sdl.KeyCode.t) {
						mutable_app.game.nudge_table()
					} else if sym == int(sdl.KeyCode.r) {
						if mutable_app.game.state == .playing
							|| mutable_app.game.state == .game_over {
							mutable_app.game.start_game(mutable_app.game.mode)
						}
					} else if sym == int(sdl.KeyCode.p) {
						if mutable_app.game.state == .playing {
							mutable_app.game.state = .paused
						} else if mutable_app.game.state == .paused {
							mutable_app.game.state = .playing
						}
					} else if sym == int(sdl.KeyCode.s) {
						mutable_app.sound_mgr.toggle_sound()
					}
				}
				.keyup {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.z) || sym == int(sdl.KeyCode.left)
						|| sym == int(sdl.KeyCode.a) {
						mutable_app.p1_left = false
						mutable_app.mario_left = false
					} else if sym == int(sdl.KeyCode.x) || sym == int(sdl.KeyCode.right)
						|| sym == int(sdl.KeyCode.d) {
						mutable_app.p1_right = false
						mutable_app.mario_right = false
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.down) {
						mutable_app.plunge_hold = false
					}
				}
				else {}
			}
		}

		// Update game logic
		mutable_app.game.update(target_dt, mutable_app.p1_left, mutable_app.p1_right,
			mutable_app.mario_left, mutable_app.mario_right, mutable_app.plunge_hold)

		// Play queued audio events
		for sound_name in mutable_app.game.sound_queue {
			match sound_name {
				'flick' { mutable_app.sound_mgr.play_flick() }
				'bumper' { mutable_app.sound_mgr.play_bumper() }
				'slingshot' { mutable_app.sound_mgr.play_slingshot() }
				'target' { mutable_app.sound_mgr.play_target() }
				'spinner' { mutable_app.sound_mgr.play_spinner() }
				'mario_bounce' { mutable_app.sound_mgr.play_mario_bounce() }
				'damsel_rescue' { mutable_app.sound_mgr.play_damsel_rescue() }
				'drain' { mutable_app.sound_mgr.play_drain() }
				'plunger_release' { mutable_app.sound_mgr.play_plunger_release() }
				'tilt' { mutable_app.sound_mgr.play_tilt() }
				else {}
			}
		}
		mutable_app.game.sound_queue.clear()

		// Render frame
		render_game(mutable_app.renderer, &mutable_app.game)
		sdl.render_present(mutable_app.renderer)
		sdl.delay(16)
	}
}

fn (app &App) cleanup() {
	if app.renderer != unsafe { nil } {
		sdl.destroy_renderer(app.renderer)
	}
	if app.window != unsafe { nil } {
		sdl.destroy_window(app.window)
	}
	if app.sound_mgr.dev != 0 {
		sdl.close_audio_device(app.sound_mgr.dev)
	}
	sdl.quit()
}

fn main() {
	app := new_app()
	if !app.init() {
		return
	}
	app.run()
	app.cleanup()
}
