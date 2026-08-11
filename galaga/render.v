module main

import sdl

fn render_galaga_game(renderer &sdl.Renderer, mut g GalagaGame) {
	// Clear screen to space black
	sdl.set_render_draw_color(renderer, 5, 5, 15, 255)
	sdl.render_clear(renderer)

	// 1. Draw Starfield
	for s in g.stars {
		sdl.set_render_draw_color(renderer, s.brightness, s.brightness, s.brightness, 255)
		rect := sdl.Rect{ x: int(s.x), y: int(s.y), w: s.size, h: s.size }
		sdl.render_fill_rect(renderer, &rect)
	}

	// 2. Draw Tractor Beam if active
	if g.tractor_active {
		for mut e in g.enemies {
			if e.id == g.tractor_enemy_id && e.active {
				for row in 0 .. 15 {
					y_pos := int(e.y + 20.0 + f32(row) * 18.0)
					width := 20 + row * 6
					x_left := int(e.x) - width / 2
					rect := sdl.Rect{ x: x_left, y: y_pos, w: width, h: 10 }
					alpha := u8(80 + (row % 2) * 80)
					sdl.set_render_draw_color(renderer, 0, 200, 255, alpha)
					sdl.render_fill_rect(renderer, &rect)
				}
			}
		}
	}

	// 3. Draw Captured Ship if returning
	if g.captured_ship_x > 0 && g.captured_ship_y > 0 {
		draw_player_ship(renderer, g.captured_ship_x, g.captured_ship_y, false, Color{ r: 255, g: 100, b: 100, a: 255 })
	}

	// 4. Draw Enemies
	for e in g.enemies {
		if !e.active { continue }
		draw_enemy_ship(renderer, e)
	}

	// 5. Draw Player Ship
	if g.state == .playing || g.state == .paused {
		if g.player.invuln_timer <= 0 || (int(g.player.invuln_timer * 10.0) % 2 == 0) {
			if g.player.is_dual {
				draw_player_ship(renderer, g.player.x - g.player.dual_offset / 2.0, g.player.y, false, Color{ r: 255, g: 255, b: 255, a: 255 })
				draw_player_ship(renderer, g.player.x + g.player.dual_offset / 2.0, g.player.y, false, Color{ r: 255, g: 255, b: 255, a: 255 })
			} else {
				draw_player_ship(renderer, g.player.x, g.player.y, false, Color{ r: 255, g: 255, b: 255, a: 255 })
			}
		}
	}

	// 6. Draw Bullets
	for b in g.player_bullets {
		if !b.active { continue }
		sdl.set_render_draw_color(renderer, 255, 255, 100, 255)
		rect := sdl.Rect{ x: int(b.x) - 2, y: int(b.y) - 6, w: 4, h: 12 }
		sdl.render_fill_rect(renderer, &rect)
	}

	for eb in g.enemy_bullets {
		if !eb.active { continue }
		sdl.set_render_draw_color(renderer, 255, 50, 50, 255)
		rect := sdl.Rect{ x: int(eb.x) - 2, y: int(eb.y) - 4, w: 4, h: 8 }
		sdl.render_fill_rect(renderer, &rect)
	}

	// 7. Draw Particles
	for p in g.particles {
		alpha := u8(p.life / p.max_life * 255.0)
		sdl.set_render_draw_color(renderer, p.color.r, p.color.g, p.color.b, alpha)
		rect := sdl.Rect{ x: int(p.x) - 1, y: int(p.y) - 1, w: 3, h: 3 }
		sdl.render_fill_rect(renderer, &rect)
	}

	// 8. Draw HUD
	draw_text(renderer, 20, 15, "SCORE: ${g.score}", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
	draw_text(renderer, 320, 15, "HIGH: ${g.high_score}", 2, Color{ r: 255, g: 215, b: 0, a: 255 })
	draw_text(renderer, 650, 15, "STAGE ${g.stage}", 2, Color{ r: 0, g: 255, b: 255, a: 255 })

	for l in 0 .. g.player.lives {
		draw_player_ship(renderer, 30.0 + f32(l) * 26.0, 580.0, true, Color{ r: 255, g: 255, b: 255, a: 255 })
	}

	// 9. Overlay Menus
	if g.state == .menu {
		draw_text_centered(renderer, 400, 180, "GALAGA ARCADE", 4, Color{ r: 255, g: 50, b: 50, a: 255 })
		draw_text_centered(renderer, 400, 240, "CYBER SPACE SHOOTER", 2, Color{ r: 0, g: 200, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 340, "PRESS SPACE TO START", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 400, "CONTROLS: A/D OR ARROWS MOVE | SPACE FIRE", 1, Color{ r: 180, g: 180, b: 180, a: 255 })
		draw_text_centered(renderer, 400, 420, "DUAL CANNON RESCUE | M MUTE | R RESET", 1, Color{ r: 180, g: 180, b: 180, a: 255 })
	} else if g.state == .game_over {
		draw_text_centered(renderer, 400, 240, "GAME OVER", 4, Color{ r: 255, g: 50, b: 50, a: 255 })
		draw_text_centered(renderer, 400, 310, "FINAL SCORE: ${g.score}", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 370, "PRESS SPACE OR R TO RESTART", 2, Color{ r: 0, g: 255, b: 100, a: 255 })
	} else if g.state == .paused {
		draw_text_centered(renderer, 400, 280, "- PAUSED -", 3, Color{ r: 255, g: 255, b: 0, a: 255 })
	}

	sdl.render_present(renderer)
}

fn draw_player_ship(renderer &sdl.Renderer, x f32, y f32, mini bool, color Color) {
	scale := if mini { f32(0.6) } else { f32(1.0) }
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)

	p1_x := int(x)
	p1_y := int(y - 14.0 * scale)
	p2_x := int(x - 12.0 * scale)
	p2_y := int(y + 10.0 * scale)
	p3_x := int(x + 12.0 * scale)
	p3_y := int(y + 10.0 * scale)

	sdl.render_draw_line(renderer, p1_x, p1_y, p2_x, p2_y)
	sdl.render_draw_line(renderer, p2_x, p2_y, p3_x, p3_y)
	sdl.render_draw_line(renderer, p3_x, p3_y, p1_x, p1_y)

	sdl.set_render_draw_color(renderer, 255, 50, 50, 255)
	rect_l := sdl.Rect{ x: int(x - 15.0 * scale), y: int(y + 2.0 * scale), w: int(4.0 * scale), h: int(8.0 * scale) }
	rect_r := sdl.Rect{ x: int(x + 11.0 * scale), y: int(y + 2.0 * scale), w: int(4.0 * scale), h: int(8.0 * scale) }
	sdl.render_fill_rect(renderer, &rect_l)
	sdl.render_fill_rect(renderer, &rect_r)
}

fn draw_enemy_ship(renderer &sdl.Renderer, e Enemy) {
	px := int(e.x)
	py := int(e.y)

	match e.enemy_type {
		.zako {
			sdl.set_render_draw_color(renderer, 50, 150, 255, 255)
			body := sdl.Rect{ x: px - 8, y: py - 6, w: 16, h: 12 }
			sdl.render_fill_rect(renderer, &body)

			sdl.set_render_draw_color(renderer, 255, 220, 0, 255)
			wing_l := sdl.Rect{ x: px - 14, y: py - 4, w: 6, h: 8 }
			wing_r := sdl.Rect{ x: px + 8, y: py - 4, w: 6, h: 8 }
			sdl.render_fill_rect(renderer, &wing_l)
			sdl.render_fill_rect(renderer, &wing_r)
		}
		.goei {
			sdl.set_render_draw_color(renderer, 255, 50, 50, 255)
			body := sdl.Rect{ x: px - 9, y: py - 7, w: 18, h: 14 }
			sdl.render_fill_rect(renderer, &body)

			sdl.set_render_draw_color(renderer, 255, 200, 50, 255)
			top_wing := sdl.Rect{ x: px - 15, y: py - 9, w: 30, h: 4 }
			sdl.render_fill_rect(renderer, &top_wing)
		}
		.boss {
			color := if e.hp == 2 { Color{ r: 50, g: 220, b: 50, a: 255 } } else { Color{ r: 200, g: 50, b: 200, a: 255 } }
			sdl.set_render_draw_color(renderer, color.r, color.g, color.b, 255)
			body := sdl.Rect{ x: px - 12, y: py - 8, w: 24, h: 16 }
			sdl.render_fill_rect(renderer, &body)

			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			m1 := sdl.Rect{ x: px - 10, y: py - 12, w: 4, h: 6 }
			m2 := sdl.Rect{ x: px + 6, y: py - 12, w: 4, h: 6 }
			sdl.render_fill_rect(renderer, &m1)
			sdl.render_fill_rect(renderer, &m2)
		}
	}
}
