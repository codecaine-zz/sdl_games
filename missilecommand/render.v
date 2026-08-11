module main

import sdl

fn render_missilecommand_game(renderer &sdl.Renderer, mut g MissileCommandGame) {
	// Black space environment
	sdl.set_render_draw_color(renderer, 5, 5, 12, 255)
	sdl.render_clear(renderer)

	// 1. Ground Baseline & Silos
	sdl.set_render_draw_color(renderer, 200, 160, 40, 255)
	ground := sdl.Rect{ x: 0, y: 550, w: 800, h: 50 }
	sdl.render_fill_rect(renderer, &ground)

	// Silo Batteries
	for s in g.silos {
		if s.ammo > 0 {
			sdl.set_render_draw_color(renderer, 50, 180, 255, 255)
			silo_box := sdl.Rect{ x: int(s.x) - 20, y: 525, w: 40, h: 25 }
			sdl.render_fill_rect(renderer, &silo_box)

			// Ammo counter
			draw_text(renderer, int(s.x) - 10, 505, "${s.ammo}", 1, Color{ r: 255, g: 255, b: 255, a: 255 })
		}
	}

	// 2. Cities
	for c in g.cities {
		if c.active {
			sdl.set_render_draw_color(renderer, 0, 220, 255, 255)
			b1 := sdl.Rect{ x: int(c.x) - 18, y: 520, w: 12, h: 30 }
			b2 := sdl.Rect{ x: int(c.x) - 4, y: 510, w: 14, h: 40 }
			b3 := sdl.Rect{ x: int(c.x) + 12, y: 525, w: 10, h: 25 }
			sdl.render_fill_rect(renderer, &b1)
			sdl.render_fill_rect(renderer, &b2)
			sdl.render_fill_rect(renderer, &b3)
		} else {
			// Ruined city debris
			sdl.set_render_draw_color(renderer, 100, 100, 100, 255)
			debris := sdl.Rect{ x: int(c.x) - 16, y: 542, w: 34, h: 8 }
			sdl.render_fill_rect(renderer, &debris)
		}
	}

	// 3. ICBM Trajectories (Red Lines)
	for m in g.icbms {
		if !m.active { continue }
		sdl.set_render_draw_color(renderer, 255, 60, 60, 255)
		sdl.render_draw_line(renderer, int(m.start_x), int(m.start_y), int(m.x), int(m.y))
	}

	// 4. Interceptor Trails (Blue Lines + Target X)
	for m in g.interceptors {
		if !m.active { continue }
		sdl.set_render_draw_color(renderer, 60, 180, 255, 255)
		sdl.render_draw_line(renderer, int(m.start_x), int(m.start_y), int(m.x), int(m.y))

		// Target X indicator
		tx := int(m.target_x)
		ty := int(m.target_y)
		sdl.set_render_draw_color(renderer, 255, 255, 0, 255)
		sdl.render_draw_line(renderer, tx - 4, ty - 4, tx + 4, ty + 4)
		sdl.render_draw_line(renderer, tx - 4, ty + 4, tx + 4, ty - 4)
	}

	// 5. Expanding Blast Clouds
	for b in g.blasts {
		if !b.active { continue }
		cx := int(b.x)
		cy := int(b.y)
		r := int(b.radius)

		// Outer expanding circle rect
		sdl.set_render_draw_color(renderer, 255, 200, 50, 255)
		outer := sdl.Rect{ x: cx - r, y: cy - r, w: r * 2, h: r * 2 }
		sdl.render_fill_rect(renderer, &outer)

		// Inner bright core
		if r > 6 {
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			inner := sdl.Rect{ x: cx - r / 2, y: cy - r / 2, w: r, h: r }
			sdl.render_fill_rect(renderer, &inner)
		}
	}

	// 6. Crosshair Cursor
	if g.state == .playing || g.state == .paused {
		cx := int(g.crosshair_x)
		cy := int(g.crosshair_y)
		sdl.set_render_draw_color(renderer, 0, 255, 100, 255)
		sdl.render_draw_line(renderer, cx - 10, cy, cx + 10, cy)
		sdl.render_draw_line(renderer, cx, cy - 10, cx, cy + 10)
	}

	// 7. HUD
	draw_text(renderer, 20, 15, "DEFENSE SCORE: ${g.score}", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
	draw_text(renderer, 350, 15, "HIGH: ${g.high_score}", 2, Color{ r: 255, g: 215, b: 0, a: 255 })
	draw_text(renderer, 650, 15, "WAVE ${g.wave}", 2, Color{ r: 0, g: 255, b: 255, a: 255 })

	// 8. Overlay Menus
	if g.state == .menu {
		draw_text_centered(renderer, 400, 180, "MISSILE COMMAND", 4, Color{ r: 255, g: 50, b: 50, a: 255 })
		draw_text_centered(renderer, 400, 240, "AIR DEFENSE VECTOR SHOOTER", 2, Color{ r: 0, g: 200, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 340, "PRESS SPACE OR CLICK TO START", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 400, "AIM WITH MOUSE / ARROWS | FIRE INTERCEPTOR WITH CLICK / SPACE", 1, Color{ r: 180, g: 180, b: 180, a: 255 })
		draw_text_centered(renderer, 400, 420, "PROTECT YOUR 6 CITIES FROM INCOMING ICBM STRIKES!", 1, Color{ r: 180, g: 180, b: 180, a: 255 })
	} else if g.state == .game_over {
		draw_text_centered(renderer, 400, 220, "THE END - ALL CITIES DESTROYED", 4, Color{ r: 255, g: 50, b: 50, a: 255 })
		draw_text_centered(renderer, 400, 310, "FINAL DEFENSE SCORE: ${g.score}", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 370, "PRESS SPACE OR R TO RESTART", 2, Color{ r: 0, g: 255, b: 100, a: 255 })
	} else if g.state == .paused {
		draw_text_centered(renderer, 400, 280, "- PAUSED -", 3, Color{ r: 255, g: 255, b: 0, a: 255 })
	}

	sdl.render_present(renderer)
}
