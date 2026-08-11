module main

import sdl

fn main() {
	sdl.init(sdl.init_video | sdl.init_audio)
	defer { sdl.quit() }

	window := sdl.create_window(
		'Cyber Bomberman Tactical Maze'.str,
		sdl.windowpos_centered,
		sdl.windowpos_centered,
		800,
		600,
		u32(sdl.WindowFlags.shown)
	)
	if unsafe { window == nil } {
		return
	}
	defer { sdl.destroy_window(window) }

	renderer := sdl.create_renderer(window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if unsafe { renderer == nil } {
		return
	}
	defer { sdl.destroy_renderer(renderer) }

	mut game := new_bomberman_game()

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
					if sym == int(sdl.KeyCode.a) { game.key_p1_left = true }
					else if sym == int(sdl.KeyCode.d) { game.key_p1_right = true }
					else if sym == int(sdl.KeyCode.w) { game.key_p1_up = true }
					else if sym == int(sdl.KeyCode.s) { game.key_p1_down = true }
					else if sym == int(sdl.KeyCode.space) {
						if game.state == .menu || game.state == .game_over || game.state == .victory {
							game.reset_game()
						} else {
							game.key_p1_bomb = true
						}
					} else if sym == int(sdl.KeyCode.left) { game.key_p2_left = true }
					else if sym == int(sdl.KeyCode.right) { game.key_p2_right = true }
					else if sym == int(sdl.KeyCode.up) { game.key_p2_up = true }
					else if sym == int(sdl.KeyCode.down) { game.key_p2_down = true }
					else if sym == int(sdl.KeyCode.@return) || sym == int(sdl.KeyCode.kp_enter) { game.key_p2_bomb = true }
					else if sym == int(sdl.KeyCode.p) {
						if game.state == .playing { game.state = .paused }
						else if game.state == .paused { game.state = .playing }
					} else if sym == int(sdl.KeyCode.r) { game.reset_game() }
					else if sym == int(sdl.KeyCode.m) { game.sound_mgr.toggle_sound() }
					else if sym == int(sdl.KeyCode.escape) { running = false }
				}
				.keyup {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.a) { game.key_p1_left = false }
					else if sym == int(sdl.KeyCode.d) { game.key_p1_right = false }
					else if sym == int(sdl.KeyCode.w) { game.key_p1_up = false }
					else if sym == int(sdl.KeyCode.s) { game.key_p1_down = false }
					else if sym == int(sdl.KeyCode.left) { game.key_p2_left = false }
					else if sym == int(sdl.KeyCode.right) { game.key_p2_right = false }
					else if sym == int(sdl.KeyCode.up) { game.key_p2_up = false }
					else if sym == int(sdl.KeyCode.down) { game.key_p2_down = false }
					else if sym == int(sdl.KeyCode.space) { game.key_p1_bomb = false }
					else if sym == int(sdl.KeyCode.@return) || sym == int(sdl.KeyCode.kp_enter) { game.key_p2_bomb = false }
				}
				else {}
			}
		}

		current_ticks := sdl.get_ticks()
		dt := f32(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks

		capped_dt := if dt > 0.05 { f32(0.05) } else { dt }
		game.update(capped_dt)
		render_bomberman_game(renderer, mut game)

		sdl.delay(16)
	}
}
