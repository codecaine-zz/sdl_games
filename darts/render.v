module main

import math
import sdl

fn draw_darts_game(renderer &sdl.Renderer, g &DartsGame) {
	// Traditional British Pub Lounge with wood paneling & warm ambient lighting
	draw_pub_background(renderer)

	draw_dartboard_cabinet(renderer, g)
	draw_dartboard(renderer, g)
	draw_board_darts(renderer, g)
	draw_aim_reticle(renderer, g)
	draw_chalkboard_hud(renderer, g)
	draw_celebration(renderer, g)
}

fn draw_pub_background(renderer &sdl.Renderer) {
	// Deep warm tavern wood paneling background
	for y := 0; y < 620; y += 4 {
		shade := u8(16 + (y * 10) / 620)
		sdl.set_render_draw_color(renderer, shade + 4, shade, shade - 2, 255)
		rect := sdl.Rect{ x: 0, y: y, w: 800, h: 4 }
		sdl.render_fill_rect(renderer, &rect)
	}

	// Vertical dark wood wainscot dividers
	for x := 0; x < 800; x += 160 {
		sdl.set_render_draw_color(renderer, 10, 8, 6, 255)
		sdl.render_draw_line(renderer, x, 0, x, 620)
		sdl.set_render_draw_color(renderer, 35, 25, 18, 255)
		sdl.render_draw_line(renderer, x + 1, 0, x + 1, 620)
	}
}

fn draw_dartboard_cabinet(renderer &sdl.Renderer, g &DartsGame) {
	cx := int(g.board_center_x)
	cy := int(g.board_center_y)

	// Mahogany Wood Backboard / Surround
	cabinet_w := 480
	cabinet_h := 480
	cab_x := cx - cabinet_w / 2
	cab_y := cy - cabinet_h / 2

	// Dark mahogany surround ring
	sdl.set_render_draw_color(renderer, 48, 26, 16, 255)
	cab_rect := sdl.Rect{ x: cab_x, y: cab_y, w: cabinet_w, h: cabinet_h }
	sdl.render_fill_rect(renderer, &cab_rect)

	// Outer wooden bevel
	sdl.set_render_draw_color(renderer, 75, 42, 24, 255)
	sdl.render_draw_rect(renderer, &cab_rect)
	sdl.set_render_draw_color(renderer, 25, 14, 8, 255)
	inner_rim := sdl.Rect{ x: cab_x + 3, y: cab_y + 3, w: cabinet_w - 6, h: cabinet_h - 6 }
	sdl.render_draw_rect(renderer, &inner_rim)

	// Brass decorative corner brackets
	draw_brass_bracket(renderer, cab_x + 6, cab_y + 6)
	draw_brass_bracket(renderer, cab_x + cabinet_w - 22, cab_y + 6)
	draw_brass_bracket(renderer, cab_x + 6, cab_y + cabinet_h - 22)
	draw_brass_bracket(renderer, cab_x + cabinet_w - 22, cab_y + cabinet_h - 22)

	// Spotlight illumination halo over board
	for r := int(r_board_outer) + 20; r > int(r_board_outer); r -= 4 {
		alpha := u8((int(r_board_outer) + 24 - r) * 4)
		sdl.set_render_draw_color(renderer, 255, 240, 190, alpha)
		draw_circle_wire(renderer, cx, cy, r, Color{ r: 255, g: 240, b: 190, a: alpha })
	}
}

fn draw_brass_bracket(renderer &sdl.Renderer, x int, y int) {
	sdl.set_render_draw_color(renderer, 190, 155, 60, 255)
	bracket := sdl.Rect{ x: x, y: y, w: 16, h: 16 }
	sdl.render_fill_rect(renderer, &bracket)

	sdl.set_render_draw_color(renderer, 240, 215, 120, 255)
	sdl.render_draw_line(renderer, x, y, x + 15, y)
	sdl.render_draw_line(renderer, x, y, x, y + 15)

	sdl.set_render_draw_color(renderer, 80, 50, 15, 255)
	sdl.render_draw_line(renderer, x, y + 15, x + 15, y + 15)
	sdl.render_draw_line(renderer, x + 15, y, x + 15, y + 15)

	// Center rivet
	sdl.set_render_draw_color(renderer, 30, 20, 10, 255)
	sdl.render_draw_point(renderer, x + 8, y + 8)
}

fn draw_dartboard(renderer &sdl.Renderer, g &DartsGame) {
	cx := int(g.board_center_x)
	cy := int(g.board_center_y)

	// Outer Catch Ring (High density sisal black ring)
	draw_filled_circle(renderer, cx, cy, int(r_board_outer), Color{ r: 22, g: 24, b: 30 })

	// 20 Pie Wedge Segments
	for i := 0; i < 20; i++ {
		// Angles in radians (0 is top 20)
		a_start := (f64(i) * math.pi / 10.0) - (math.pi / 20.0) - (math.pi / 2.0)
		a_end := a_start + (math.pi / 10.0)

		is_black := (i % 2 == 0)

		// 16-Bit Sisal Palette
		// Single Bed: Charcoal Slate or Aged Linen Cream
		c_single := if is_black {
			Color{ r: 28, g: 30, b: 36 }
		} else {
			Color{ r: 232, g: 224, b: 198 }
		}

		// Double / Triple Ring: Crimson Cherry or Emerald Forest
		c_ring := if is_black {
			Color{ r: 215, g: 35, b: 45 }
		} else {
			Color{ r: 26, g: 150, b: 72 }
		}

		// Draw Single Outer Wedge
		draw_pie_sector(renderer, cx, cy, r_triple_out, r_double_in, a_start, a_end, c_single)
		// Draw Double Ring
		draw_pie_sector(renderer, cx, cy, r_double_in, r_double_out, a_start, a_end, c_ring)
		// Draw Single Inner Wedge
		draw_pie_sector(renderer, cx, cy, r_outer_bull, r_triple_in, a_start, a_end, c_single)
		// Draw Triple Ring
		draw_pie_sector(renderer, cx, cy, r_triple_in, r_triple_out, a_start, a_end, c_ring)

		// Outer Number Ring Labels
		num := dart_segments[i]
		mid_angle := (a_start + a_end) * 0.5
		lbl_r := r_double_out + 20.0
		lx := int(f64(cx) + math.cos(mid_angle) * lbl_r)
		ly := int(f64(cy) + math.sin(mid_angle) * lbl_r)
		num_str := '${num}'

		// Number wire shadow + bright wire number
		draw_text_centered(renderer, lx + 1, ly - 3, num_str, 1, Color{ r: 10, g: 12, b: 16 })
		draw_text_centered(renderer, lx, ly - 4, num_str, 1, Color{ r: 250, g: 250, b: 255 })
	}

	// Outer Bullseye (Emerald Green, 25 pts)
	draw_filled_circle(renderer, cx, cy, int(r_outer_bull), Color{ r: 26, g: 150, b: 72 })
	// Inner Double Bullseye (Crimson Red, 50 pts)
	draw_filled_circle(renderer, cx, cy, int(r_double_bull), Color{ r: 220, g: 35, b: 45 })

	// Steel Spider Wire Framework (Polished high-tensile wire with specular highlights)
	wire_highlight := Color{ r: 215, g: 225, b: 245 }
	wire_shadow := Color{ r: 15, g: 18, b: 24, a: 160 }

	// Shadowed wire rings (offset +1 for 3D depth)
	draw_circle_wire(renderer, cx + 1, cy + 1, int(r_double_out), wire_shadow)
	draw_circle_wire(renderer, cx + 1, cy + 1, int(r_double_in), wire_shadow)
	draw_circle_wire(renderer, cx + 1, cy + 1, int(r_triple_out), wire_shadow)
	draw_circle_wire(renderer, cx + 1, cy + 1, int(r_triple_in), wire_shadow)
	draw_circle_wire(renderer, cx + 1, cy + 1, int(r_outer_bull), wire_shadow)
	draw_circle_wire(renderer, cx + 1, cy + 1, int(r_double_bull), wire_shadow)

	// Metallic Highlight Wire Rings
	draw_circle_wire(renderer, cx, cy, int(r_double_out), wire_highlight)
	draw_circle_wire(renderer, cx, cy, int(r_double_in), wire_highlight)
	draw_circle_wire(renderer, cx, cy, int(r_triple_out), wire_highlight)
	draw_circle_wire(renderer, cx, cy, int(r_triple_in), wire_highlight)
	draw_circle_wire(renderer, cx, cy, int(r_outer_bull), wire_highlight)
	draw_circle_wire(renderer, cx, cy, int(r_double_bull), wire_highlight)

	// Radial Spider Wire Spokes
	for i := 0; i < 20; i++ {
		angle := (f64(i) * math.pi / 10.0) - (math.pi / 20.0) - (math.pi / 2.0)
		x1 := int(f64(cx) + math.cos(angle) * r_outer_bull)
		y1 := int(f64(cy) + math.sin(angle) * r_outer_bull)
		x2 := int(f64(cx) + math.cos(angle) * r_double_out)
		y2 := int(f64(cy) + math.sin(angle) * r_double_out)

		sdl.set_render_draw_color(renderer, wire_shadow.r, wire_shadow.g, wire_shadow.b, 180)
		sdl.render_draw_line(renderer, x1 + 1, y1 + 1, x2 + 1, y2 + 1)
		sdl.set_render_draw_color(renderer, wire_highlight.r, wire_highlight.g, wire_highlight.b, 255)
		sdl.render_draw_line(renderer, x1, y1, x2, y2)
	}
}

fn draw_pie_sector(renderer &sdl.Renderer, cx int, cy int, r_in f64, r_out f64, a_start f64, a_end f64, c Color) {
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 255)
	steps_r := 10
	steps_a := 16

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

fn draw_board_darts(renderer &sdl.Renderer, g &DartsGame) {
	p := g.players[g.current_p_idx]
	cx := g.board_center_x
	cy := g.board_center_y

	for hit in p.current_turn {
		hx := int(cx + hit.x)
		hy := int(cy + hit.y)

		// 16-Bit 3D Angled Sticking Dart

		// Drop Shadow cast onto sisal board
		sdl.set_render_draw_color(renderer, 0, 0, 0, 110)
		sdl.render_draw_line(renderer, hx, hy, hx + 18, hy + 10)
		sdl.render_draw_line(renderer, hx + 1, hy, hx + 19, hy + 10)
		s_wing := sdl.Rect{ x: hx + 14, y: hy + 6, w: 10, h: 8 }
		sdl.render_fill_rect(renderer, &s_wing)

		// Steel Point into Sisal
		sdl.set_render_draw_color(renderer, 190, 195, 210, 255)
		sdl.render_draw_line(renderer, hx, hy, hx + 4, hy - 6)

		// Tungsten Knurled Barrel
		sdl.set_render_draw_color(renderer, 240, 205, 50, 255)
		sdl.render_draw_line(renderer, hx + 4, hy - 6, hx + 14, hy - 19)
		sdl.render_draw_line(renderer, hx + 5, hy - 6, hx + 15, hy - 19)
		// Grip grooves
		sdl.set_render_draw_color(renderer, 140, 100, 20, 255)
		sdl.render_draw_point(renderer, hx + 7, hy - 10)
		sdl.render_draw_point(renderer, hx + 10, hy - 14)

		// Shaft (Aluminum stem)
		sdl.set_render_draw_color(renderer, 210, 220, 235, 255)
		sdl.render_draw_line(renderer, hx + 14, hy - 19, hx + 20, hy - 26)

		// 16-Bit Aerodynamic Flights (Player 1: Royal Blue / Gold, Player 2: Flame Crimson)
		flight_col1 := if g.current_p_idx == 0 { Color{ r: 30, g: 140, b: 240 } } else { Color{ r: 235, g: 45, b: 45 } }
		flight_col2 := if g.current_p_idx == 0 { Color{ r: 255, g: 215, b: 0 } } else { Color{ r: 255, g: 255, b: 255 } }

		// Top wing
		sdl.set_render_draw_color(renderer, flight_col1.r, flight_col1.g, flight_col1.b, 255)
		wing_top := sdl.Rect{ x: hx + 16, y: hy - 34, w: 10, h: 9 }
		sdl.render_fill_rect(renderer, &wing_top)

		// Flight accent stripe
		sdl.set_render_draw_color(renderer, flight_col2.r, flight_col2.g, flight_col2.b, 255)
		sdl.render_draw_line(renderer, hx + 18, hy - 32, hx + 24, hy - 28)

		// Flight outline & bevel
		sdl.set_render_draw_color(renderer, 255, 255, 255, 200)
		sdl.render_draw_rect(renderer, &wing_top)
	}
}

fn draw_aim_reticle(renderer &sdl.Renderer, g &DartsGame) {
	if g.phase == .aiming || g.phase == .power_meter {
		rx := int(g.aim_x + g.wobble_x)
		ry := int(g.aim_y + g.wobble_y)

		// 16-Bit Arcade Precision Targeting Crosshair
		// Outer rotating guide brackets
		sdl.set_render_draw_color(renderer, 255, 215, 0, 220)
		draw_circle_wire(renderer, rx, ry, 12, Color{ r: 255, g: 215, b: 0 })
		draw_circle_wire(renderer, rx, ry, 4, Color{ r: 0, g: 230, b: 255 })

		// Precision crosshair lines with tick marks
		sdl.set_render_draw_color(renderer, 255, 230, 60, 255)
		sdl.render_draw_line(renderer, rx - 18, ry, rx - 6, ry)
		sdl.render_draw_line(renderer, rx + 6, ry, rx + 18, ry)
		sdl.render_draw_line(renderer, rx, ry - 18, rx, ry - 6)
		sdl.render_draw_line(renderer, rx, ry + 6, rx, ry + 18)

		// Center target pip
		sdl.set_render_draw_color(renderer, 255, 50, 50, 255)
		sdl.render_draw_point(renderer, rx, ry)

		// Vintage Brass Power Timing Meter (Right side)
		if g.phase == .power_meter {
			bar_x := 680
			bar_y := 220
			bar_w := 28
			bar_h := 220

			// Brass frame chassis
			draw_brass_meter_frame(renderer, bar_x, bar_y, bar_w, bar_h)

			// Meter slot background
			slot_rect := sdl.Rect{ x: bar_x + 4, y: bar_y + 4, w: bar_w - 8, h: bar_h - 8 }
			sdl.set_render_draw_color(renderer, 20, 22, 32, 255)
			sdl.render_fill_rect(renderer, &slot_rect)

			// Green Target Sweet Spot in middle (0.45 .. 0.55)
			sweet_h := int(f64(bar_h - 8) * 0.12)
			sweet_y := bar_y + 4 + int(f64(bar_h - 8) * 0.44)
			sweet_rect := sdl.Rect{ x: bar_x + 4, y: sweet_y, w: bar_w - 8, h: sweet_h }
			sdl.set_render_draw_color(renderer, 0, 255, 120, 220)
			sdl.render_fill_rect(renderer, &sweet_rect)
			sdl.set_render_draw_color(renderer, 255, 255, 255, 200)
			sdl.render_draw_rect(renderer, &sweet_rect)

			// Power Indicator needle / column
			fill_h := int(f64(bar_h - 8) * g.power)
			fill_y := bar_y + 4 + (bar_h - 8 - fill_h)

			sdl.set_render_draw_color(renderer, 255, 200, 30, 255)
			fill_rect := sdl.Rect{ x: bar_x + 6, y: fill_y, w: bar_w - 12, h: fill_h }
			sdl.render_fill_rect(renderer, &fill_rect)

			// Glowing needle
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_draw_line(renderer, bar_x + 2, fill_y, bar_x + bar_w - 3, fill_y)

			draw_text_centered(renderer, bar_x + bar_w / 2, bar_y - 18, 'TIMING', 1, Color{ r: 255, g: 220, b: 100 })
			draw_text_centered(renderer, bar_x + bar_w / 2, bar_y + bar_h + 12, '[SPACE]', 1, Color{ r: 0, g: 230, b: 255 })
		}
	}
}

fn draw_brass_meter_frame(renderer &sdl.Renderer, x int, y int, w int, h int) {
	frame := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 170, 135, 50, 255)
	sdl.render_fill_rect(renderer, &frame)

	sdl.set_render_draw_color(renderer, 240, 210, 110, 255)
	sdl.render_draw_line(renderer, x, y, x + w, y)
	sdl.render_draw_line(renderer, x, y, x, y + h)

	sdl.set_render_draw_color(renderer, 80, 55, 20, 255)
	sdl.render_draw_line(renderer, x, y + h - 1, x + w, y + h - 1)
	sdl.render_draw_line(renderer, x + w - 1, y, x + w - 1, y + h)
}

fn draw_chalkboard_hud(renderer &sdl.Renderer, g &DartsGame) {
	// Traditional Pub Chalkboard Header Banner
	panel_w := 760
	panel_h := 70
	px := (800 - panel_w) / 2
	py := 8

	// Wooden Frame around Chalkboard
	frame_rect := sdl.Rect{ x: px - 4, y: py - 4, w: panel_w + 8, h: panel_h + 8 }
	sdl.set_render_draw_color(renderer, 65, 38, 20, 255)
	sdl.render_fill_rect(renderer, &frame_rect)

	sdl.set_render_draw_color(renderer, 95, 55, 28, 255)
	sdl.render_draw_rect(renderer, &frame_rect)

	// Slate green chalkboard interior
	chalk_rect := sdl.Rect{ x: px, y: py, w: panel_w, h: panel_h }
	sdl.set_render_draw_color(renderer, 24, 40, 32, 255)
	sdl.render_fill_rect(renderer, &chalk_rect)

	// Chalk dust border
	sdl.set_render_draw_color(renderer, 180, 210, 195, 120)
	sdl.render_draw_rect(renderer, &chalk_rect)

	// Game Mode Title
	mode_name := match g.typ {
		.x501         { '501 TOURNAMENT DARTS (DOUBLE OUT)' }
		.x301         { '301 PUB DARTS (DOUBLE OUT)' }
		.cricket      { 'ENGLISH CRICKET DARTS' }
		.around_clock { 'AROUND THE CLOCK (1-20 -> BULL)' }
	}
	draw_text(renderer, px + 14, py + 8, mode_name, 1, Color{ r: 255, g: 215, b: 0 })

	// Players Chalk Scores
	for i, p in g.players {
		x_offset := px + 14 + i * 270
		is_active := (i == g.current_p_idx)
		txt_col := if is_active { Color{ r: 0, g: 255, b: 200 } } else { Color{ r: 200, g: 215, b: 225 } }

		score_str := match g.typ {
			.x501, .x301  { 'REMAINING: ${p.score_left}' }
			.cricket      { 'SCORE: ${p.cricket_score}' }
			.around_clock { 'TARGET: ${p.atc_target}' }
		}
		// Active player indicator bullet
		if is_active {
			bullet := sdl.Rect{ x: x_offset - 8, y: py + 28, w: 4, h: 4 }
			sdl.set_render_draw_color(renderer, 0, 255, 200, 255)
			sdl.render_fill_rect(renderer, &bullet)
		}

		draw_text(renderer, x_offset, py + 26, '${p.name.to_upper()}: ${score_str}', 1, txt_col)
		draw_text(renderer, x_offset, py + 46, 'LEGS: ${p.legs_won} | DARTS THROWN: ${p.darts_thrown}', 1, Color{ r: 160, g: 190, b: 180 })
	}

	// Checkout Route Hint Box
	if g.checkout_hint != '' {
		draw_text(renderer, px + panel_w - 230, py + 8, 'OUT COMBINATION:', 1, Color{ r: 255, g: 220, b: 100 })
		draw_text(renderer, px + panel_w - 230, py + 26, g.checkout_hint, 1, Color{ r: 255, g: 85, b: 85 })
	}

	// Bottom Pub Controls Bar
	help_text := '[MOUSE / WASD] AIM  |  [SPACE] LOCK & THROW  |  [1-4] MODES  |  [M] SOUND  |  [R] RESTART'
	draw_text_centered(renderer, 400, 588, help_text, 1, Color{ r: 170, g: 190, b: 215 })
}

fn draw_celebration(renderer &sdl.Renderer, g &DartsGame) {
	if g.celebration != '' {
		box_w := 460
		box_h := 64
		bx := (800 - box_w) / 2
		by := 260

		// Pub Celebration Plaque
		plaque := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
		sdl.set_render_draw_color(renderer, 18, 22, 36, 250)
		sdl.render_fill_rect(renderer, &plaque)

		// Gold Border
		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &plaque)
		inner := sdl.Rect{ x: bx + 3, y: by + 3, w: box_w - 6, h: box_h - 6 }
		sdl.render_draw_rect(renderer, &inner)

		draw_text_centered(renderer, 402, by + 24, g.celebration, 2, Color{ r: 30, g: 15, b: 0 })
		draw_text_centered(renderer, 400, by + 22, g.celebration, 2, Color{ r: 255, g: 225, b: 50 })
	}
}

fn draw_filled_circle(renderer &sdl.Renderer, cx int, cy int, r int, c Color) {
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, c.a)
	for dy := -r; dy <= r; dy++ {
		for dx := -r; dx <= r; dx++ {
			if dx * dx + dy * dy <= r * r {
				sdl.render_draw_point(renderer, cx + dx, cy + dy)
			}
		}
	}
}

fn draw_circle_wire(renderer &sdl.Renderer, cx int, cy int, r int, c Color) {
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, c.a)
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
