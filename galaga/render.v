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

	// 3. Draw Captured Ship attached to Boss
	if g.captured_ship_x > 0 && g.captured_ship_y > 0 {
		draw_player_ship(renderer, g.captured_ship_x, g.captured_ship_y, false, Color{ r: 255, g: 100, b: 100, a: 255 })
	}

	// 4. Draw Rescuable Ships falling down
	for rs in g.rescuable_ships {
		if !rs.active { continue }
		draw_player_ship(renderer, rs.x, rs.y, false, Color{ r: 100, g: 255, b: 150, a: 255 })
	}

	// 5. Draw Enemies
	for e in g.enemies {
		if !e.active { continue }
		draw_enemy_ship(renderer, e)
	}

	// 6. Draw Player Ship
	if g.state == .playing || g.state == .paused {
		if g.player.invuln_timer <= 0 || (int(g.player.invuln_timer * 10.0) % 2 == 0) {
			p_color := if g.player.is_capturing { Color{ r: 255, g: 120, b: 120, a: 255 } } else { Color{ r: 255, g: 255, b: 255, a: 255 } }
			if g.player.is_dual {
				draw_player_ship(renderer, g.player.x - g.player.dual_offset / 2.0, g.player.y, false, p_color)
				draw_player_ship(renderer, g.player.x + g.player.dual_offset / 2.0, g.player.y, false, p_color)
			} else {
				draw_player_ship(renderer, g.player.x, g.player.y, false, p_color)
			}
		}
	}

	// 7. Draw Bullets with glowing laser corona
	for b in g.player_bullets {
		if !b.active { continue }
		// Yellow-orange photon aura
		sdl.set_render_draw_color(renderer, 255, 180, 40, 130)
		glow := sdl.Rect{ x: int(b.x) - 4, y: int(b.y) - 8, w: 8, h: 16 }
		sdl.render_fill_rect(renderer, &glow)

		sdl.set_render_draw_color(renderer, 255, 255, 200, 255)
		rect := sdl.Rect{ x: int(b.x) - 2, y: int(b.y) - 6, w: 4, h: 12 }
		sdl.render_fill_rect(renderer, &rect)
	}

	for eb in g.enemy_bullets {
		if !eb.active { continue }
		sdl.set_render_draw_color(renderer, 255, 30, 30, 120)
		glow := sdl.Rect{ x: int(eb.x) - 3, y: int(eb.y) - 5, w: 6, h: 10 }
		sdl.render_fill_rect(renderer, &glow)

		sdl.set_render_draw_color(renderer, 255, 180, 180, 255)
		rect := sdl.Rect{ x: int(eb.x) - 2, y: int(eb.y) - 4, w: 4, h: 8 }
		sdl.render_fill_rect(renderer, &rect)
	}

	// 8. Draw Particles
	for p in g.particles {
		alpha := u8(p.life / p.max_life * 255.0)
		sdl.set_render_draw_color(renderer, p.color.r, p.color.g, p.color.b, alpha)
		rect := sdl.Rect{ x: int(p.x) - 1, y: int(p.y) - 1, w: 3, h: 3 }
		sdl.render_fill_rect(renderer, &rect)
	}

	// 9. Draw Top HUD
	draw_text(renderer, 20, 15, "1UP ${g.score}", 2, Color{ r: 255, g: 50, b: 50, a: 255 })
	draw_text(renderer, 320, 15, "HIGH ${g.high_score}", 2, Color{ r: 255, g: 215, b: 0, a: 255 })
	draw_text(renderer, 650, 15, "STAGE ${g.stage}", 2, Color{ r: 0, g: 255, b: 255, a: 255 })

	// Lives Icons at Bottom-Left
	for l in 0 .. g.player.lives {
		draw_player_ship(renderer, 25.0 + f32(l) * 26.0, 580.0, true, Color{ r: 255, g: 255, b: 255, a: 255 })
	}

	// Stage Flags / Badges at Bottom-Right
	draw_stage_badges(renderer, g.stage)

	// Stage Intro Banners ("STAGE X", "READY!", "CHALLENGING STAGE")
	if g.state == .playing && g.stage_intro_timer > 0 {
		if g.is_challenge_stage {
			draw_text_centered(renderer, 400, 260, "CHALLENGING STAGE", 3, Color{ r: 0, g: 240, b: 255, a: 255 })
		} else {
			draw_text_centered(renderer, 400, 250, "STAGE ${g.stage}", 3, Color{ r: 0, g: 255, b: 255, a: 255 })
			draw_text_centered(renderer, 400, 290, "READY", 2, Color{ r: 255, g: 50, b: 50, a: 255 })
		}
	}

	// Stage Clear Banner
	if g.state == .playing && g.stage_clear_timer > 0 {
		draw_text_centered(renderer, 400, 260, "STAGE CLEAR!", 3, Color{ r: 255, g: 220, b: 40, a: 255 })
		bonus_str := if g.is_challenge_stage && g.challenge_hits == g.challenge_total {
			"PERFECT! BONUS 10000 PTS"
		} else {
			"STAGE BONUS +${1000 + g.stage * 200}"
		}
		draw_text_centered(renderer, 400, 300, bonus_str, 2, Color{ r: 100, g: 255, b: 150, a: 255 })
	}

	// 10. Overlay Menus
	if g.state == .menu {
		draw_text_centered(renderer, 400, 170, "GALAGA ARCADE", 4, Color{ r: 255, g: 50, b: 50, a: 255 })
		draw_text_centered(renderer, 400, 230, "CYBER SPACE SHOOTER", 2, Color{ r: 0, g: 200, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 320, "PRESS SPACE TO START", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 380, "CONTROLS: A/D OR ARROWS MOVE | SPACE FIRE | F11: Fullscreen", 1, Color{ r: 180, g: 180, b: 180, a: 255 })
		draw_text_centered(renderer, 400, 400, "DUAL FIGHTER RESCUE | M MUTE | R RESET", 1, Color{ r: 180, g: 180, b: 180, a: 255 })
	} else if g.state == .game_over {
		draw_text_centered(renderer, 400, 230, "GAME OVER", 4, Color{ r: 255, g: 50, b: 50, a: 255 })
		draw_text_centered(renderer, 400, 300, "FINAL SCORE: ${g.score}", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 330, "REACHED STAGE ${g.stage}", 2, Color{ r: 0, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 380, "PRESS SPACE OR R TO RESTART", 2, Color{ r: 0, g: 255, b: 100, a: 255 })
	} else if g.state == .paused {
		draw_text_centered(renderer, 400, 280, "- PAUSED -", 3, Color{ r: 255, g: 255, b: 0, a: 255 })
	}

	sdl.render_present(renderer)
}

fn draw_stage_badges(renderer &sdl.Renderer, stage int) {
	mut s := stage
	mut bx := 770
	by := 575

	// 50-flag
	for s >= 50 && bx > 500 {
		draw_flag(renderer, bx, by, Color{ r: 255, g: 215, b: 0, a: 255 }, '50')
		bx -= 24
		s -= 50
	}
	// 30-flag
	for s >= 30 && bx > 500 {
		draw_flag(renderer, bx, by, Color{ r: 255, g: 100, b: 100, a: 255 }, '30')
		bx -= 24
		s -= 30
	}
	// 20-flag
	for s >= 20 && bx > 500 {
		draw_flag(renderer, bx, by, Color{ r: 100, g: 150, b: 255, a: 255 }, '20')
		bx -= 24
		s -= 20
	}
	// 10-flag
	for s >= 10 && bx > 500 {
		draw_flag(renderer, bx, by, Color{ r: 255, g: 50, b: 50, a: 255 }, '10')
		bx -= 24
		s -= 10
	}
	// 5-badge
	for s >= 5 && bx > 500 {
		draw_flag(renderer, bx, by, Color{ r: 255, g: 200, b: 40, a: 255 }, '5')
		bx -= 20
		s -= 5
	}
	// 1-badge
	for s >= 1 && bx > 500 {
		draw_flag(renderer, bx, by, Color{ r: 100, g: 200, b: 255, a: 255 }, '1')
		bx -= 16
		s -= 1
	}
}

fn draw_flag(renderer &sdl.Renderer, x int, y int, col Color, _ string) {
	sdl.set_render_draw_color(renderer, col.r, col.g, col.b, col.a)
	rect := sdl.Rect{ x: x - 6, y: y - 8, w: 12, h: 16 }
	sdl.render_fill_rect(renderer, &rect)

	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	tri := sdl.Rect{ x: x - 4, y: y - 6, w: 8, h: 8 }
	sdl.render_fill_rect(renderer, &tri)
}

fn draw_player_ship(renderer &sdl.Renderer, x f32, y f32, mini bool, color Color) {
	scale := if mini { f32(0.6) } else { f32(1.0) }
	px := int(x)
	py := int(y)

	// 16-Bit Galaga Fighter Starship
	// Main Fuselage (White/Steel)
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	fuse := sdl.Rect{ x: px - int(4.0 * scale), y: py - int(12.0 * scale), w: int(8.0 * scale) + 1, h: int(20.0 * scale) }
	sdl.render_fill_rect(renderer, &fuse)

	// Nose Tip Needle
	sdl.set_render_draw_color(renderer, 255, 220, 40, 255)
	nose := sdl.Rect{ x: px - int(1.0 * scale), y: py - int(16.0 * scale), w: int(3.0 * scale), h: int(5.0 * scale) }
	sdl.render_fill_rect(renderer, &nose)

	// Crimson Swept Wings with Dual Laser Pods
	sdl.set_render_draw_color(renderer, 225, 30, 40, 255)
	wing_l := sdl.Rect{ x: px - int(15.0 * scale), y: py + int(2.0 * scale), w: int(11.0 * scale), h: int(7.0 * scale) }
	wing_r := sdl.Rect{ x: px + int(4.0 * scale), y: py + int(2.0 * scale), w: int(11.0 * scale), h: int(7.0 * scale) }
	sdl.render_fill_rect(renderer, &wing_l)
	sdl.render_fill_rect(renderer, &wing_r)

	// Wingtip Lasers (Golden)
	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	laser_l := sdl.Rect{ x: px - int(15.0 * scale), y: py - int(4.0 * scale), w: int(3.0 * scale), h: int(10.0 * scale) }
	laser_r := sdl.Rect{ x: px + int(12.0 * scale), y: py - int(4.0 * scale), w: int(3.0 * scale), h: int(10.0 * scale) }
	sdl.render_fill_rect(renderer, &laser_l)
	sdl.render_fill_rect(renderer, &laser_r)

	// Cockpit Canopy (Cobalt Blue Glass)
	sdl.set_render_draw_color(renderer, 0, 180, 255, 255)
	cockpit := sdl.Rect{ x: px - int(2.0 * scale), y: py - int(4.0 * scale), w: int(5.0 * scale), h: int(7.0 * scale) }
	sdl.render_fill_rect(renderer, &cockpit)

	// Dynamic Cyan & Orange Thruster Flame if full size
	if !mini {
		ticks := sdl.get_ticks()
		f_height := 6 + int(ticks % 5)
		sdl.set_render_draw_color(renderer, 255, 140, 30, 200)
		outer_flame := sdl.Rect{ x: px - 3, y: py + 8, w: 7, h: f_height + 2 }
		sdl.render_fill_rect(renderer, &outer_flame)

		sdl.set_render_draw_color(renderer, 0, 240, 255, 240)
		thrust := sdl.Rect{ x: px - 2, y: py + 8, w: 5, h: f_height }
		sdl.render_fill_rect(renderer, &thrust)
	}
}

fn draw_enemy_ship(renderer &sdl.Renderer, e Enemy) {
	px := int(e.x)
	py := int(e.y)

	match e.enemy_type {
		.zako {
			// 16-Bit Zako (Cobalt & Golden Wing Butterfly)
			sdl.set_render_draw_color(renderer, 35, 110, 235, 255)
			body := sdl.Rect{ x: px - 6, y: py - 7, w: 12, h: 14 }
			sdl.render_fill_rect(renderer, &body)

			// Golden Wings
			sdl.set_render_draw_color(renderer, 245, 205, 30, 255)
			wing_l := sdl.Rect{ x: px - 14, y: py - 5, w: 8, h: 10 }
			wing_r := sdl.Rect{ x: px + 6, y: py - 5, w: 8, h: 10 }
			sdl.render_fill_rect(renderer, &wing_l)
			sdl.render_fill_rect(renderer, &wing_r)

			// Red Eyes
			sdl.set_render_draw_color(renderer, 255, 40, 40, 255)
			sdl.render_draw_point(renderer, px - 3, py - 4)
			sdl.render_draw_point(renderer, px + 3, py - 4)
		}
		.goei {
			// 16-Bit Goei (Crimson & Amber Boss Moth)
			sdl.set_render_draw_color(renderer, 225, 35, 45, 255)
			body := sdl.Rect{ x: px - 8, y: py - 8, w: 16, h: 16 }
			sdl.render_fill_rect(renderer, &body)

			// Amber Antennae & Wings
			sdl.set_render_draw_color(renderer, 255, 185, 30, 255)
			w_span := sdl.Rect{ x: px - 16, y: py - 6, w: 32, h: 7 }
			sdl.render_fill_rect(renderer, &w_span)

			// Yellow Eyes
			sdl.set_render_draw_color(renderer, 255, 255, 100, 255)
			sdl.render_draw_point(renderer, px - 4, py - 4)
			sdl.render_draw_point(renderer, px + 4, py - 4)
		}
		.boss {
			// 16-Bit Boss Galaga (Emerald / Purple with Horn Mandibles)
			body_col := if e.hp == 2 { Color{ r: 35, g: 215, b: 65 } } else { Color{ r: 195, g: 45, b: 215 } }
			sdl.set_render_draw_color(renderer, body_col.r, body_col.g, body_col.b, 255)
			body := sdl.Rect{ x: px - 12, y: py - 9, w: 24, h: 18 }
			sdl.render_fill_rect(renderer, &body)

			// Horn Mandibles (White / Gold)
			sdl.set_render_draw_color(renderer, 250, 245, 220, 255)
			m1 := sdl.Rect{ x: px - 10, y: py - 14, w: 4, h: 6 }
			m2 := sdl.Rect{ x: px + 6, y: py - 14, w: 4, h: 6 }
			sdl.render_fill_rect(renderer, &m1)
			sdl.render_fill_rect(renderer, &m2)

			// Center Core Power Gem
			core_col := if e.hp == 2 { Color{ r: 255, g: 215, b: 0 } } else { Color{ r: 255, g: 40, b: 40 } }
			sdl.set_render_draw_color(renderer, core_col.r, core_col.g, core_col.b, 255)
			gem := sdl.Rect{ x: px - 3, y: py - 2, w: 6, h: 6 }
			sdl.render_fill_rect(renderer, &gem)
		}
	}
}
