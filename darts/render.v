module main

import math
import sdl

fn draw_darts_game(renderer &sdl.Renderer, g &DartsGame) {
	// Deep pub background
	sdl.set_render_draw_color(renderer, 18, 14, 24, 255)
	sdl.render_clear(renderer)

	draw_dartboard(renderer, g)
	draw_board_darts(renderer, g)
	draw_aim_reticle(renderer, g)
	draw_darts_hud(renderer, g)
	draw_celebration(renderer, g)
}

fn draw_dartboard(renderer &sdl.Renderer, g &DartsGame) {
	cx := int(g.board_center_x)
	cy := int(g.board_center_y)

	// Outer Catch Ring (Black)
	draw_filled_circle(renderer, cx, cy, int(r_board_outer), Color{ r: 20, g: 22, b: 28 })

	// 20 Pie Wedge Segments
	for i := 0; i < 20; i++ {
		// Angles in radians (0 is top 20)
		a_start := (f64(i) * math.pi / 10.0) - (math.pi / 20.0) - (math.pi / 2.0)
		a_end := a_start + (math.pi / 10.0)

		is_black := (i % 2 == 0)
		// Single Bed Color: Black or Cream
		c_single := if is_black { Color{ r: 25, g: 25, b: 30 } } else { Color{ r: 235, g: 225, b: 195 } }
		// Double / Triple Ring Color: Red or Green
		c_ring := if is_black { Color{ r: 210, g: 30, b: 40 } } else { Color{ r: 35, g: 145, b: 65 } }

		// Draw Single Outer Wedge
		draw_pie_sector(renderer, cx, cy, r_triple_out, r_double_in, a_start, a_end, c_single)
		// Draw Double Ring
		draw_pie_sector(renderer, cx, cy, r_double_in, r_double_out, a_start, a_end, c_ring)
		// Draw Single Inner Wedge
		draw_pie_sector(renderer, cx, cy, r_outer_bull, r_triple_in, a_start, a_end, c_single)
		// Draw Triple Ring
		draw_pie_sector(renderer, cx, cy, r_triple_in, r_triple_out, a_start, a_end, c_ring)

		// Number Label
		num := dart_segments[i]
		mid_angle := (a_start + a_end) * 0.5
		lbl_r := r_double_out + 20.0
		lx := int(f64(cx) + math.cos(mid_angle) * lbl_r)
		ly := int(f64(cy) + math.sin(mid_angle) * lbl_r)
		num_str := '${num}'
		draw_text_centered(renderer, lx, ly - 4, num_str, 1, Color{ r: 250, g: 250, b: 255 })
	}

	// Outer Bullseye (Green, 25 pts)
	draw_filled_circle(renderer, cx, cy, int(r_outer_bull), Color{ r: 35, g: 145, b: 65 })
	// Inner Double Bullseye (Red, 50 pts)
	draw_filled_circle(renderer, cx, cy, int(r_double_bull), Color{ r: 210, g: 30, b: 40 })

	// Steel Spider Wire Rim
	draw_circle_wire(renderer, cx, cy, int(r_double_out), Color{ r: 180, g: 190, b: 210 })
	draw_circle_wire(renderer, cx, cy, int(r_double_in), Color{ r: 180, g: 190, b: 210 })
	draw_circle_wire(renderer, cx, cy, int(r_triple_out), Color{ r: 180, g: 190, b: 210 })
	draw_circle_wire(renderer, cx, cy, int(r_triple_in), Color{ r: 180, g: 190, b: 210 })
	draw_circle_wire(renderer, cx, cy, int(r_outer_bull), Color{ r: 180, g: 190, b: 210 })
	draw_circle_wire(renderer, cx, cy, int(r_double_bull), Color{ r: 180, g: 190, b: 210 })
}

fn draw_pie_sector(renderer &sdl.Renderer, cx int, cy int, r_in f64, r_out f64, a_start f64, a_end f64, c Color) {
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 255)
	steps_r := 8
	steps_a := 12

	for ri := 0; ri < steps_r; ri++ {
		r1 := r_in + (f64(ri) / f64(steps_r)) * (r_out - r_in)
		r2 := r_in + (f64(ri + 1) / f64(steps_r)) * (r_out - r_in)

		for ai := 0; ai < steps_a; ai++ {
			a1 := a_start + (f64(ai) / f64(steps_a)) * (a_end - a_start)
			a2 := a_start + (f64(ai + 1) / f64(steps_a)) * (a_end - a_start)

			x1 := int(f64(cx) + math.cos(a1) * r1)
			y1 := int(f64(cy) + math.sin(a1) * r1)
			x2 := int(f64(cx) + math.cos(a2) * r2)
			y2 := int(f64(cy) + math.sin(a2) * r2)

			sdl.render_draw_line(renderer, x1, y1, x2, y2)
		}
	}
}

fn draw_filled_circle(renderer &sdl.Renderer, cx int, cy int, r int, c Color) {
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 255)
	for dy := -r; dy <= r; dy++ {
		for dx := -r; dx <= r; dx++ {
			if dx * dx + dy * dy <= r * r {
				sdl.render_draw_point(renderer, cx + dx, cy + dy)
			}
		}
	}
}

fn draw_circle_wire(renderer &sdl.Renderer, cx int, cy int, r int, c Color) {
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 255)
	steps := 80
	for i := 0; i < steps; i++ {
		a1 := f64(i) * 2.0 * math.pi / f64(steps)
		a2 := f64(i + 1) * 2.0 * math.pi / f64(steps)
		x1 := int(f64(cx) + math.cos(a1) * f64(r))
		y1 := int(f64(cy) + math.sin(a1) * f64(r))
		x2 := int(f64(cx) + math.cos(a2) * f64(r))
		y2 := int(f64(cy) + math.sin(a2) * f64(r))
		sdl.render_draw_line(renderer, x1, y1, x2, y2)
	}
}

fn draw_board_darts(renderer &sdl.Renderer, g &DartsGame) {
	p := g.players[g.current_p_idx]
	cx := g.board_center_x
	cy := g.board_center_y

	for hit in p.current_turn {
		hx := int(cx + hit.x)
		hy := int(cy + hit.y)

		// Dart Flight Barrel
		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_line(renderer, hx, hy, hx + 12, hy - 18)
		sdl.render_draw_line(renderer, hx + 1, hy, hx + 13, hy - 18)

		// Dart Flight Wings
		sdl.set_render_draw_color(renderer, 0, 180, 255, 255)
		wing := sdl.Rect{ x: hx + 10, y: hy - 24, w: 8, h: 8 }
		sdl.render_fill_rect(renderer, &wing)
	}
}

fn draw_aim_reticle(renderer &sdl.Renderer, g &DartsGame) {
	if g.phase == .aiming || g.phase == .power_meter {
		rx := int(g.aim_x + g.wobble_x)
		ry := int(g.aim_y + g.wobble_y)

		// Crosshair Reticle
		sdl.set_render_draw_color(renderer, 255, 220, 0, 240)
		sdl.render_draw_line(renderer, rx - 14, ry, rx + 14, ry)
		sdl.render_draw_line(renderer, rx, ry - 14, rx, ry + 14)

		// Outer Ring
		draw_circle_wire(renderer, rx, ry, 8, Color{ r: 255, g: 220, b: 0 })

		// Power Timing Gauge Bar (Right side of board)
		if g.phase == .power_meter {
			bar_x := 680
			bar_y := 240
			bar_w := 24
			bar_h := 200

			bg_rect := sdl.Rect{ x: bar_x, y: bar_y, w: bar_w, h: bar_h }
			sdl.set_render_draw_color(renderer, 35, 40, 55, 255)
			sdl.render_fill_rect(renderer, &bg_rect)

			fill_h := int(f64(bar_h) * g.power)
			fill_rect := sdl.Rect{ x: bar_x, y: bar_y + (bar_h - fill_h), w: bar_w, h: fill_h }

			// Sweet spot green zone in middle (0.45 .. 0.55)
			sweet_rect := sdl.Rect{ x: bar_x, y: bar_y + int(f64(bar_h) * 0.45), w: bar_w, h: int(f64(bar_h) * 0.1) }
			sdl.set_render_draw_color(renderer, 0, 255, 100, 180)
			sdl.render_fill_rect(renderer, &sweet_rect)

			sdl.set_render_draw_color(renderer, 255, 180, 0, 255)
			sdl.render_fill_rect(renderer, &fill_rect)

			sdl.set_render_draw_color(renderer, 200, 210, 240, 255)
			sdl.render_draw_rect(renderer, &bg_rect)

			draw_text_centered(renderer, bar_x + bar_w / 2, bar_y - 20, 'TIMING', 1, Color{ r: 255, g: 255, b: 255 })
			draw_text_centered(renderer, bar_x + bar_w / 2, bar_y + bar_h + 10, '[SPACE]', 1, Color{ r: 255, g: 215, b: 0 })
		}
	}
}

fn draw_darts_hud(renderer &sdl.Renderer, g &DartsGame) {
	// Top Match Information Banner
	panel_w := 760
	panel_h := 65
	px := (800 - panel_w) / 2
	py := 10

	sdl.set_render_draw_color(renderer, 10, 14, 25, 240)
	panel_rect := sdl.Rect{ x: px, y: py, w: panel_w, h: panel_h }
	sdl.render_fill_rect(renderer, &panel_rect)

	sdl.set_render_draw_color(renderer, 0, 200, 255, 255)
	sdl.render_draw_rect(renderer, &panel_rect)

	mode_name := match g.typ {
		.x501 { '501 DARTS (DOUBLE OUT)' }
		.x301 { '301 DARTS (DOUBLE OUT)' }
		.cricket { 'CRICKET DARTS' }
		.around_clock { 'AROUND THE CLOCK' }
	}
	draw_text(renderer, px + 12, py + 8, mode_name, 1, Color{ r: 255, g: 215, b: 0 })

	// Players scores
	for i, p in g.players {
		x_offset := px + 12 + i * 260
		is_active := (i == g.current_p_idx)
		txt_col := if is_active { Color{ r: 0, g: 255, b: 180 } } else { Color{ r: 160, g: 175, b: 200 } }

		score_str := match g.typ {
			.x501, .x301 { 'REMAINING: ${p.score_left}' }
			.cricket { 'SCORE: ${p.cricket_score}' }
			.around_clock { 'TARGET: ${p.atc_target}' }
		}
		draw_text(renderer, x_offset, py + 26, '${p.name.to_upper()}: ${score_str}', 1, txt_col)
		draw_text(renderer, x_offset, py + 44, 'LEGS WON: ${p.legs_won} | DARTS: ${p.darts_thrown}', 1, Color{ r: 180, g: 190, b: 210 })
	}

	// Checkout Hint Display
	if g.checkout_hint != '' {
		draw_text(renderer, px + panel_w - 220, py + 8, 'CHECKOUT ROUTE:', 1, Color{ r: 255, g: 220, b: 100 })
		draw_text(renderer, px + panel_w - 220, py + 26, g.checkout_hint, 1, Color{ r: 255, g: 80, b: 80 })
	}

	// Bottom Controls Help Bar
	help_text := '[MOUSE / WASD] AIM  |  [SPACE] LOCK & THROW  |  [1-4] GAME MODE  |  [M] SOUND  |  [R] RESTART'
	draw_text_centered(renderer, 400, 570, help_text, 1, Color{ r: 150, g: 170, b: 200 })
}

fn draw_celebration(renderer &sdl.Renderer, g &DartsGame) {
	if g.celebration != '' {
		box_w := 420
		box_h := 60
		bx := (800 - box_w) / 2
		by := 270

		sdl.set_render_draw_color(renderer, 15, 20, 35, 245)
		b_rect := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		draw_text_centered(renderer, 400, by + 20, g.celebration, 2, Color{ r: 255, g: 220, b: 50 })
	}
}
