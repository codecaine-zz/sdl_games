module main

import math
import os
import sdl

fn main() {
	if sdl.init(sdl.init_video | sdl.init_audio) != 0 {
		eprintln('Failed to initialize SDL')
		return
	}
	defer { sdl.quit() }

	// Snapshot capture mode
	if os.args.contains('--snapshot') || os.args.contains('--snap') {
		surface := sdl.create_rgb_surface(0, 800, 600, 32, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)
		if unsafe { surface == nil } {
			return
		}
		defer { sdl.free_surface(surface) }

		s_renderer := sdl.create_software_renderer(surface)
		if unsafe { s_renderer == nil } {
			return
		}
		defer { sdl.destroy_renderer(s_renderer) }

		mut game := new_yie_ar_kung_fu_game()
		game.start_game()
		game.score = 6400
		game.high_score = 18000
		game.round_timer = 76.0

		// Oolong executing flying kick against Master Wang
		game.player.x = 320.0
		game.player.y = 340.0
		game.player.move = .flying_kick
		game.player.facing_right = true

		game.opponent.x = 420.0
		game.opponent.y = 384.0
		game.opponent.hp = 68
		game.opponent.move = .hit_stun
		game.opponent.facing_right = false

		// Hit spark particles and score popup
		game.add_particles(410.0, 360.0, 14, Color{ r: 255, g: 230, b: 60, a: 255 })
		game.add_score_popup(410.0, 310.0, '+1440', Color{ r: 255, g: 220, b: 40, a: 255 })

		render_yie_ar_kung_fu_game(s_renderer, mut game)
		sdl.save_bmp(surface, 'screenshots/yiearkungfu.bmp'.str)
		return
	}

	// Normal Window
	window := sdl.create_window(
		'Yie Ar Kung-Fu (1985 Konami Fighting Classic)'.str,
		sdl.windowpos_centered,
		sdl.windowpos_centered,
		800,
		600,
		u32(sdl.WindowFlags.shown)
	)
	if unsafe { window == nil } {
		eprintln('Failed to create window')
		return
	}
	defer { sdl.destroy_window(window) }

	renderer := sdl.create_renderer(window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if unsafe { renderer == nil } {
		eprintln('Failed to create renderer')
		return
	}
	defer { sdl.destroy_renderer(renderer) }

	mut game := new_yie_ar_kung_fu_game()

	mut running := true
	mut event := sdl.Event{}
	mut last_ticks := sdl.get_ticks()

	for running {
		for sdl.poll_event(&event) != 0 {
			match unsafe { event.@type } {
				.quit {
					running = false
				}
				.keydown {
					sym := event.key.keysym.sym
					// Left
					if sym == int(sdl.KeyCode.a) || sym == int(sdl.KeyCode.left) {
						game.key_left = true
					}
					// Right
					else if sym == int(sdl.KeyCode.d) || sym == int(sdl.KeyCode.right) {
						game.key_right = true
					}
					// Down / Crouch
					else if sym == int(sdl.KeyCode.s) || sym == int(sdl.KeyCode.down) {
						game.key_down = true
					}
					// Up / Jump
					else if sym == int(sdl.KeyCode.w) || sym == int(sdl.KeyCode.up) {
						game.key_up = true
					}
					// Space / Return
					else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.@return) {
						if game.state == .title {
							game.start_game()
						} else if game.state == .round_clear {
							game.next_stage()
						} else if game.state in [.game_over, .victory] {
							game.reset_to_title()
						}
					}
					// Punch (J / Z)
					else if sym == int(sdl.KeyCode.j) || sym == int(sdl.KeyCode.z) {
						game.perform_player_attack(false)
					}
					// Kick (K / X)
					else if sym == int(sdl.KeyCode.k) || sym == int(sdl.KeyCode.x) {
						game.perform_player_attack(true)
					}
					// Pause
					else if sym == int(sdl.KeyCode.p) {
						if game.state == .fighting {
							game.state = .paused
						} else if game.state == .paused {
							game.state = .fighting
						}
					}
					// Sound toggle
					else if sym == int(sdl.KeyCode.m) {
						game.sound_mgr.toggle_sound()
					}
					// CRT Scanlines toggle
					else if sym == int(sdl.KeyCode.c) {
						game.crt_filter = !game.crt_filter
					}
					// Restart
					else if sym == int(sdl.KeyCode.r) {
						game.reset_to_title()
					}
					// Escape
					else if sym == int(sdl.KeyCode.escape) {
						if game.state == .title {
							running = false
						} else {
							game.reset_to_title()
						}
					}
				}
				.keyup {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.a) || sym == int(sdl.KeyCode.left) {
						game.key_left = false
					} else if sym == int(sdl.KeyCode.d) || sym == int(sdl.KeyCode.right) {
						game.key_right = false
					} else if sym == int(sdl.KeyCode.s) || sym == int(sdl.KeyCode.down) {
						game.key_down = false
					} else if sym == int(sdl.KeyCode.w) || sym == int(sdl.KeyCode.up) {
						game.key_up = false
					}
				}
				else {}
			}
		}

		current_ticks := sdl.get_ticks()
		dt := f32(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks
		clamped_dt := f32(math.min(f64(dt), 0.05))

		game.update(clamped_dt)
		render_yie_ar_kung_fu_game(renderer, mut game)
		sdl.render_present(renderer)
		sdl.delay(16)
	}
}
