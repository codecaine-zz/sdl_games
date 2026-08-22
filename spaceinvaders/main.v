module main

import math
import os
import sdl

struct App {
mut:
	window     &sdl.Window   = unsafe { nil }
	renderer   &sdl.Renderer = unsafe { nil }
	game       SpaceInvadersGame
	sound_mgr  SoundManager
	key_left   bool
	key_right  bool
	key_fire   bool
	wave_pause f64
}

fn new_app() App {
	return App{
		game:      new_space_invaders_game()
		sound_mgr: new_sound_manager()
	}
}

fn main() {
	if sdl.init(sdl.init_video | sdl.init_audio | sdl.init_events | sdl.init_timer) < 0 {
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

		mut snap_game := new_space_invaders_game()
		snap_game.score = 1460
		snap_game.ufo.active = true
		snap_game.ufo.x = 240.0

		// Shoot an active laser
		snap_game.bullets << Bullet{
			x: snap_game.player.x + 20.0
			y: snap_game.player.y - 120.0
			dy: -500.0
			is_player: true
			alive: true
		}
		snap_game.bullets << Bullet{
			x: 350.0
			y: 360.0
			dy: 240.0
			is_player: false
			alive: true
		}

		render_space_invaders(renderer, &snap_game)
		bmp_path := 'screenshots/spaceinvaders.bmp'
		sdl.save_bmp(surface, bmp_path.str)
		return
	}

	mut app := new_app()

	window := sdl.create_window(
		'Space Invaders 1978 Arcade Pro'.str,
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
				.keydown {
					sym := int(event.key.keysym.sym)
					if sym == int(sdl.KeyCode.escape) {
						running = false
					} else if sym == int(sdl.KeyCode.r) {
						app.game.init_game()
					} else if sym == int(sdl.KeyCode.s) {
						app.sound_mgr.toggle_sound()
					} else if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = true
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = true
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.j) {
						if app.game.state == .game_over {
							app.game.init_game()
						} else {
							fired := app.game.fire_player_bullet()
							if fired {
								app.sound_mgr.play_player_laser()
							}
						}
					}
				}
				.keyup {
					sym := int(event.key.keysym.sym)
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = false
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = false
					}
				}
				else {}
			}
		}

		if app.game.state == .wave_clear {
			app.wave_pause += dt
			if app.wave_pause >= 2.0 {
				app.wave_pause = 0.0
				app.game.init_wave(app.game.wave + 1)
			}
		} else {
			ev := app.game.update(dt, app.key_left, app.key_right)
			if ev.march_beat {
				app.sound_mgr.play_march_beat(ev.beat_idx)
			}
			if ev.alien_exploded {
				app.sound_mgr.play_alien_explosion()
			}
			if ev.player_exploded {
				app.sound_mgr.play_player_explosion()
			}
			if ev.ufo_siren {
				app.sound_mgr.play_ufo_siren()
			}
			if ev.ufo_bonus {
				app.sound_mgr.play_ufo_bonus()
			}
		}

		render_space_invaders(app.renderer, &app.game)
		sdl.delay(16)
	}
}
