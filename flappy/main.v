module main

import math
import os
import sdl

struct App {
mut:
	window    &sdl.Window   = unsafe { nil }
	renderer  &sdl.Renderer = unsafe { nil }
	game      FlappyGame
	sound_mgr SoundManager
}

fn new_app() App {
	return App{
		game:      new_flappy_game()
		sound_mgr: new_sound_manager()
	}
}

fn main() {
	if sdl.init(sdl.init_video | sdl.init_events | sdl.init_timer) < 0 {
		eprintln('Failed to initialize SDL2')
		return
	}
	defer { sdl.quit() }

	if os.args.contains('--snap') {
		surface := sdl.create_rgb_surface(0, world_w, world_h, 32, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)
		if unsafe { surface == nil } { return }
		defer { sdl.free_surface(surface) }

		renderer := sdl.create_software_renderer(surface)
		if unsafe { renderer == nil } { return }
		defer { sdl.destroy_renderer(renderer) }

		mut snap_game := new_flappy_game()
		snap_game.state = .playing
		snap_game.score = 18
		snap_game.bird.x = 130.0
		snap_game.bird.y = 260.0
		snap_game.bird.angle = -0.2
		snap_game.bird.wing_frame = 1

		// Position pipes aesthetically
		snap_game.pipes.clear()
		snap_game.pipes << Pipe{ x: 30.0, top_h: 180.0, passed: true }
		snap_game.pipes << Pipe{ x: 260.0, top_h: 210.0, passed: false }
		snap_game.pipes << Pipe{ x: 490.0, top_h: 140.0, passed: false }

		render_flappy_game(renderer, &snap_game, world_w, world_h)
		bmp_path := 'screenshots/flappy.bmp'
		sdl.save_bmp(surface, bmp_path.str)
		return
	}

	mut app := new_app()

	window := sdl.create_window(
		'Flappy Bird Pro - Precision Jumper'.str,
		sdl.windowpos_centered,
		sdl.windowpos_centered,
		world_w,
		world_h,
		u32(sdl.WindowFlags.shown)
	)
	if unsafe { window == nil } {
		eprintln('Failed to create SDL window')
		return
	}
	defer { sdl.destroy_window(window) }

	renderer := sdl.create_renderer(window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if unsafe { renderer == nil } {
		eprintln('Failed to create SDL renderer')
		return
	}
	defer { sdl.destroy_renderer(renderer) }

	app.window = window
	app.renderer = renderer

	mut event := sdl.Event{}
	mut running := true
	mut last_ticks := sdl.get_ticks()

	for running {
		now := sdl.get_ticks()
		dt := math.min(f64(now - last_ticks) / 1000.0, 0.05)
		last_ticks = now

		for sdl.poll_event(&event) != 0 {
			match event.@type {
				.quit {
					running = false
				}
				.mousebuttondown {
					if event.button.button == sdl.button_left {
						if app.game.state == .game_over {
							app.game.reset_game()
						} else {
							if app.game.flap() {
								app.sound_mgr.play_flap_sound()
							}
						}
					}
				}
				.keydown {
					sym := int(event.key.keysym.sym)
					if sym == int(sdl.KeyCode.escape) {
						running = false
					} else if sym == int(sdl.KeyCode.r) {
						app.game.reset_game()
					} else if sym == int(sdl.KeyCode.s) {
						app.sound_mgr.toggle_sound()
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) {
						if app.game.state == .game_over {
							app.game.reset_game()
						} else {
							if app.game.flap() {
								app.sound_mgr.play_flap_sound()
							}
						}
					}
				}
				else {}
			}
		}

		ev := app.game.update(dt)
		if ev.scored {
			app.sound_mgr.play_point_sound()
		}
		if ev.hit_pipe {
			app.sound_mgr.play_hit_sound()
		}
		if ev.hit_ground {
			app.sound_mgr.play_die_sound()
		}

		render_flappy_game(app.renderer, &app.game, world_w, world_h)
		sdl.delay(16)
	}
}
