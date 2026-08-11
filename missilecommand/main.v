module main

import sdl

fn main() {
	sdl.init(sdl.init_video | sdl.init_audio)
	defer { sdl.quit() }

	window := sdl.create_window(
		'Missile Command Air Defense'.str,
		sdl.windowpos_centered,
		sdl.windowpos_centered,
		800,
		600,
		u32(sdl.WindowFlags.shown)
	)
	if unsafe { window == nil } { return }
	defer { sdl.destroy_window(window) }

	renderer := sdl.create_renderer(window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if unsafe { renderer == nil } { return }
	defer { sdl.destroy_renderer(renderer) }

	mut game := new_missilecommand_game()

	mut running := true
	mut event := sdl.Event{}
	mut last_ticks := sdl.get_ticks()

	for running {
		for sdl.poll_event(&event) != 0 {
			match unsafe { event.@type } {
				.quit { running = false }
				.mousemotion {
					game.crosshair_x = f32(event.motion.x)
					game.crosshair_y = f32(event.motion.y)
				}
				.mousebuttondown {
					if event.button.button == u8(sdl.button_left) {
						if game.state == .menu || game.state == .game_over {
							game.reset_game()
						} else {
							game.fire_interceptor(f32(event.button.x), f32(event.button.y))
						}
					}
				}
				.keydown {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.space) {
						if game.state == .menu || game.state == .game_over {
							game.reset_game()
						} else {
							game.fire_interceptor(game.crosshair_x, game.crosshair_y)
						}
					} else if sym == int(sdl.KeyCode.p) {
						if game.state == .playing { game.state = .paused }
						else if game.state == .paused { game.state = .playing }
					} else if sym == int(sdl.KeyCode.r) { game.reset_game() }
					else if sym == int(sdl.KeyCode.m) { game.sound_mgr.toggle_sound() }
					else if sym == int(sdl.KeyCode.escape) { running = false }
				}
				else {}
			}
		}

		current_ticks := sdl.get_ticks()
		dt := f32(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks

		capped_dt := if dt > 0.05 { f32(0.05) } else { dt }
		game.update(capped_dt)
		render_missilecommand_game(renderer, mut game)

		sdl.delay(16)
	}
}
