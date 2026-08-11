module main

import sdl

fn render_frogger_game(renderer &sdl.Renderer, mut g FroggerGame) {
	// Clear Background to dark blue
	sdl.set_render_draw_color(renderer, 10, 15, 30, 255)
	sdl.render_clear(renderer)

	// 1. Draw Zones
	// River (Rows 1..5) -> Y 80 to 280
	sdl.set_render_draw_color(renderer, 15, 45, 110, 255)
	river_rect := sdl.Rect{ x: 0, y: 80, w: 800, h: 200 }
	sdl.render_fill_rect(renderer, &river_rect)

	// Middle Grass Island (Row 6) -> Y 280 to 320
	sdl.set_render_draw_color(renderer, 30, 140, 40, 255)
	mid_grass := sdl.Rect{ x: 0, y: 280, w: 800, h: 40 }
	sdl.render_fill_rect(renderer, &mid_grass)

	// Highway Road (Rows 7..11) -> Y 320 to 520
	sdl.set_render_draw_color(renderer, 35, 35, 40, 255)
	road_rect := sdl.Rect{ x: 0, y: 320, w: 800, h: 200 }
	sdl.render_fill_rect(renderer, &road_rect)

	// Road Lane Markings
	sdl.set_render_draw_color(renderer, 200, 200, 200, 255)
	for r in 1 .. 5 {
		lane_y := 320 + r * 40
		for c in 0 .. 15 {
			dash := sdl.Rect{ x: c * 60 + 10, y: lane_y - 1, w: 30, h: 2 }
			sdl.render_fill_rect(renderer, &dash)
		}
	}

	// Bottom Grass Zone (Row 12) -> Y 520 to 560
	sdl.set_render_draw_color(renderer, 30, 140, 40, 255)
	start_grass := sdl.Rect{ x: 0, y: 520, w: 800, h: 40 }
	sdl.render_fill_rect(renderer, &start_grass)

	// Top Dock Zone (Row 0) -> Y 40 to 80
	sdl.set_render_draw_color(renderer, 20, 90, 30, 255)
	dock_strip := sdl.Rect{ x: 0, y: 40, w: 800, h: 40 }
	sdl.render_fill_rect(renderer, &dock_strip)

	// 2. Draw Docks
	for d in g.docks {
		dx := int(d.x)
		dy := 60
		sdl.set_render_draw_color(renderer, 50, 180, 70, 255)
		dock_rect := sdl.Rect{ x: dx - 24, y: dy - 16, w: 48, h: 32 }
		sdl.render_fill_rect(renderer, &dock_rect)

		if d.filled {
			// Draw Docked Frog
			sdl.set_render_draw_color(renderer, 0, 255, 100, 255)
			frog_mini := sdl.Rect{ x: dx - 10, y: dy - 10, w: 20, h: 20 }
			sdl.render_fill_rect(renderer, &frog_mini)
		}
	}

	// 3. Draw Lane Objects
	for obj in g.objects {
		ox := int(obj.x)
		oy := 40 + obj.row * 40 + 6

		match obj.obj_type {
			.car {
				sdl.set_render_draw_color(renderer, 255, 60, 60, 255)
				rect := sdl.Rect{ x: ox, y: oy, w: int(obj.width), h: 28 }
				sdl.render_fill_rect(renderer, &rect)
				// Windows
				sdl.set_render_draw_color(renderer, 200, 240, 255, 255)
				win := sdl.Rect{ x: ox + 8, y: oy + 4, w: int(obj.width) - 16, h: 20 }
				sdl.render_fill_rect(renderer, &win)
			}
			.truck {
				sdl.set_render_draw_color(renderer, 220, 180, 30, 255)
				rect := sdl.Rect{ x: ox, y: oy, w: int(obj.width), h: 28 }
				sdl.render_fill_rect(renderer, &rect)
				// Cab line
				sdl.set_render_draw_color(renderer, 50, 50, 50, 255)
				cab := sdl.Rect{ x: ox + int(obj.width) - 20, y: oy + 2, w: 4, h: 24 }
				sdl.render_fill_rect(renderer, &cab)
			}
			.race_car {
				sdl.set_render_draw_color(renderer, 0, 220, 255, 255)
				rect := sdl.Rect{ x: ox, y: oy, w: int(obj.width), h: 28 }
				sdl.render_fill_rect(renderer, &rect)
			}
			.log_small, .log_medium, .log_large {
				sdl.set_render_draw_color(renderer, 140, 80, 30, 255)
				log_rect := sdl.Rect{ x: ox, y: oy + 2, w: int(obj.width), h: 24 }
				sdl.render_fill_rect(renderer, &log_rect)
			}
			.turtles {
				if obj.submerged { continue }
				// Draw 3 turtle shells
				count := int(obj.width / 25.0)
				for i in 0 .. count {
					sdl.set_render_draw_color(renderer, 200, 50, 50, 255)
					shell := sdl.Rect{ x: ox + i * 25, y: oy + 4, w: 20, h: 20 }
					sdl.render_fill_rect(renderer, &shell)
				}
			}
		}
	}

	// 4. Draw Frog
	if g.state == .playing || g.state == .paused {
		fx := int(g.frog_x)
		fy := int(g.frog_y)

		sdl.set_render_draw_color(renderer, 0, 255, 100, 255)
		frog_body := sdl.Rect{ x: fx - 12, y: fy - 12, w: 24, h: 24 }
		sdl.render_fill_rect(renderer, &frog_body)

		// Eyes
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		e1 := sdl.Rect{ x: fx - 10, y: fy - 14, w: 6, h: 6 }
		e2 := sdl.Rect{ x: fx + 4, y: fy - 14, w: 6, h: 6 }
		sdl.render_fill_rect(renderer, &e1)
		sdl.render_fill_rect(renderer, &e2)
	}

	// 5. Draw HUD
	draw_text(renderer, 20, 10, "SCORE: ${g.score}", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
	draw_text(renderer, 300, 10, "HIGH: ${g.high_score}", 2, Color{ r: 255, g: 215, b: 0, a: 255 })
	draw_text(renderer, 620, 10, "LEVEL ${g.level}", 2, Color{ r: 0, g: 255, b: 255, a: 255 })

	// Timer Bar
	timer_w := int((g.timer / g.max_timer) * 300.0)
	if timer_w > 0 {
		timer_color := if g.timer < 8.0 { Color{ r: 255, g: 50, b: 50, a: 255 } } else { Color{ r: 0, g: 255, b: 100, a: 255 } }
		sdl.set_render_draw_color(renderer, timer_color.r, timer_color.g, timer_color.b, 255)
		bar := sdl.Rect{ x: 250, y: 570, w: timer_w, h: 14 }
		sdl.render_fill_rect(renderer, &bar)
	}
	draw_text(renderer, 180, 568, "TIME", 2, Color{ r: 200, g: 200, b: 200, a: 255 })

	// Lives Icons
	for l in 0 .. g.lives {
		sdl.set_render_draw_color(renderer, 0, 255, 100, 255)
		life_icon := sdl.Rect{ x: 20 + l * 22, y: 568, w: 14, h: 14 }
		sdl.render_fill_rect(renderer, &life_icon)
	}

	// 6. Overlay Menus
	if g.state == .menu {
		draw_text_centered(renderer, 400, 180, "CYBER CROSSER", 4, Color{ r: 0, g: 255, b: 100, a: 255 })
		draw_text_centered(renderer, 400, 240, "HIGHWAY & RIVER CROSSING", 2, Color{ r: 0, g: 200, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 340, "PRESS SPACE TO START", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 400, "CONTROLS: WASD OR ARROW KEYS HOP", 1, Color{ r: 180, g: 180, b: 180, a: 255 })
	} else if g.state == .game_over {
		draw_text_centered(renderer, 400, 240, "GAME OVER", 4, Color{ r: 255, g: 50, b: 50, a: 255 })
		draw_text_centered(renderer, 400, 310, "FINAL SCORE: ${g.score}", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 370, "PRESS SPACE OR R TO RESTART", 2, Color{ r: 0, g: 255, b: 100, a: 255 })
	} else if g.state == .paused {
		draw_text_centered(renderer, 400, 280, "- PAUSED -", 3, Color{ r: 255, g: 255, b: 0, a: 255 })
	}

	sdl.render_present(renderer)
}
