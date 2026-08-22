module main

import math
import sdl

fn draw_bowling_game(renderer &sdl.Renderer, g &BowlingGame) {
	// Background
	sdl.set_render_draw_color(renderer, 15, 20, 32, 255)
	sdl.render_clear(renderer)

	draw_lane(renderer, g)
	draw_gutters(renderer, g)
	draw_pins(renderer, g)
	draw_ball(renderer, g)
	draw_particles(renderer, g)
	draw_aim_hud(renderer, g)
	draw_pinsetter_sweep(renderer, g)
	draw_overhead_scoreboard(renderer, g)
	draw_celebration_banner(renderer, g)
}

fn draw_lane(renderer &sdl.Renderer, g &BowlingGame) {
	lane_w := int(g.lane_right - g.lane_left)
	lane_h := int(g.lane_bottom - g.lane_top)

	// Wood Plank Boards
	plank_count := 39
	plank_w := f64(lane_w) / f64(plank_count)

	for i := 0; i < plank_count; i++ {
		shade := if i % 2 == 0 { u8(220) } else { u8(205) }
		mut r := shade
		mut gr := u8(f64(shade) * 0.78)
		mut b := u8(f64(shade) * 0.45)

		px := int(g.lane_left + f64(i) * plank_w)
		rect := sdl.Rect{
			x: px
			y: int(g.lane_top)
			w: int(plank_w) + 1
			h: lane_h
		}
		sdl.set_render_draw_color(renderer, r, gr, b, 255)
		sdl.render_fill_rect(renderer, &rect)
	}

	// Oil Pattern Sheen (From Foul Line to oil_end_y)
	oil_y := int(g.oil_end_y)
	oil_h := int(g.lane_bottom - g.oil_end_y)
	sdl.set_render_draw_color(renderer, 255, 255, 255, 25)
	oil_rect := sdl.Rect{
		x: int(g.lane_left)
		y: oil_y
		w: lane_w
		h: oil_h
	}
	sdl.render_fill_rect(renderer, &oil_rect)

	// Oil Pattern Transition Line
	sdl.set_render_draw_color(renderer, 190, 140, 80, 120)
	sdl.render_draw_line(renderer, int(g.lane_left), oil_y, int(g.lane_right), oil_y)

	// Aiming Guide Arrows (Row of 7 Arrows)
	arrow_y := int(g.lane_bottom - 220.0)
	for i := 1; i <= 7; i++ {
		ax := int(g.lane_left + f64(i) * (f64(lane_w) / 8.0))
		sdl.set_render_draw_color(renderer, 80, 45, 20, 255)
		// Small triangle arrow
		for dy := 0; dy < 12; dy++ {
			span := dy / 2
			line := sdl.Rect{
				x: ax - span
				y: arrow_y + dy
				w: span * 2 + 1
				h: 1
			}
			sdl.render_fill_rect(renderer, &line)
		}
	}

	// 1-3 & 1-2 Strike Pocket Target Indicators on Backend
	pocket_y := int(240.0)
	// 1-3 Pocket (Righty strike target: 407px)
	sdl.set_render_draw_color(renderer, 255, 180, 0, 160)
	sdl.render_draw_line(renderer, 407, pocket_y - 8, 407, pocket_y + 8)
	sdl.render_draw_line(renderer, 403, pocket_y, 411, pocket_y)

	// Foul Line
	sdl.set_render_draw_color(renderer, 200, 30, 30, 255)
	foul_rect := sdl.Rect{
		x: int(g.lane_left)
		y: int(g.lane_bottom - 10.0)
		w: lane_w
		h: 4
	}
	sdl.render_fill_rect(renderer, &foul_rect)
}

fn draw_gutters(renderer &sdl.Renderer, g &BowlingGame) {
	lane_h := int(g.lane_bottom - g.lane_top)

	// Left Gutter
	sdl.set_render_draw_color(renderer, 25, 28, 35, 255)
	gutter_l := sdl.Rect{
		x: int(g.lane_left - 35.0)
		y: int(g.lane_top)
		w: 35
		h: lane_h
	}
	sdl.render_fill_rect(renderer, &gutter_l)

	// Right Gutter
	gutter_r := sdl.Rect{
		x: int(g.lane_right)
		y: int(g.lane_top)
		w: 35
		h: lane_h
	}
	sdl.render_fill_rect(renderer, &gutter_r)
}

fn draw_pins(renderer &sdl.Renderer, g &BowlingGame) {
	for pin in g.pins {
		if pin.x < 0.0 { continue }

		px := int(pin.x)
		py := int(pin.y)
		pin_w := 18
		pin_h := 32

		if pin.standing {
			// Wobble / Tilt displacement
			tilt_offset_x := int(math.sin(pin.tilt) * 12.0)

			// Standing Pin Body
			sdl.set_render_draw_color(renderer, 250, 250, 255, 255)
			body_rect := sdl.Rect{
				x: px - pin_w / 2 + tilt_offset_x
				y: py - pin_h / 2
				w: pin_w
				h: pin_h
			}
			sdl.render_fill_rect(renderer, &body_rect)

			// Red Stripes
			sdl.set_render_draw_color(renderer, 220, 35, 45, 255)
			stripe1 := sdl.Rect{
				x: px - pin_w / 2 + tilt_offset_x
				y: py - 6
				w: pin_w
				h: 3
			}
			stripe2 := sdl.Rect{
				x: px - pin_w / 2 + tilt_offset_x
				y: py - 1
				w: pin_w
				h: 3
			}
			sdl.render_fill_rect(renderer, &stripe1)
			sdl.render_fill_rect(renderer, &stripe2)

			// 3D Pin Shading Contour
			sdl.set_render_draw_color(renderer, 180, 185, 200, 255)
			sdl.render_draw_rect(renderer, &body_rect)
		} else {
			// Knocked/Fallen Tilted Pin on Floor
			sdl.set_render_draw_color(renderer, 210, 215, 225, 255)
			fallen_rect := sdl.Rect{
				x: px - pin_h / 2
				y: py - pin_w / 2
				w: pin_h
				h: pin_w
			}
			sdl.render_fill_rect(renderer, &fallen_rect)

			sdl.set_render_draw_color(renderer, 200, 40, 50, 255)
			stripe := sdl.Rect{
				x: px - 4
				y: py - pin_w / 2
				w: 4
				h: pin_w
			}
			sdl.render_fill_rect(renderer, &stripe)
		}
	}
}

fn draw_ball(renderer &sdl.Renderer, g &BowlingGame) {
	bx := int(g.ball.x)
	by := int(g.ball.y)
	r := int(g.ball.radius)

	// Ball Drop Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 90)
	shadow_rect := sdl.Rect{
		x: bx - r + 3
		y: by - r + 5
		w: r * 2
		h: r * 2
	}
	sdl.render_fill_rect(renderer, &shadow_rect)

	// Ball Sphere
	color_r := if g.current_player == 0 { u8(30) } else { u8(180) }
	color_g := if g.current_player == 0 { u8(80) } else { u8(40) }
	color_b := if g.current_player == 0 { u8(220) } else { u8(40) }

	for dy := -r; dy <= r; dy++ {
		for dx := -r; dx <= r; dx++ {
			if dx * dx + dy * dy <= r * r {
				// 3D Specular Highlight
				highlight := f64(dx - r / 3) * f64(dx - r / 3) + f64(dy + r / 3) * f64(dy + r / 3)
				shade := math.max(0.0, 1.0 - highlight / (f64(r * r) * 1.5))

				pr := u8(math.min(255.0, f64(color_r) + shade * 90.0))
				pg := u8(math.min(255.0, f64(color_g) + shade * 90.0))
				pb := u8(math.min(255.0, f64(color_b) + shade * 90.0))

				sdl.set_render_draw_color(renderer, pr, pg, pb, 255)
				sdl.render_draw_point(renderer, bx + dx, by + dy)
			}
		}
	}

	// 3 Finger Grip Holes
	sdl.set_render_draw_color(renderer, 10, 12, 18, 255)
	h1 := sdl.Rect{ x: bx - 4, y: by - 8, w: 3, h: 3 }
	h2 := sdl.Rect{ x: bx + 2, y: by - 8, w: 3, h: 3 }
	h3 := sdl.Rect{ x: bx - 1, y: by - 1, w: 4, h: 4 }
	sdl.render_fill_rect(renderer, &h1)
	sdl.render_fill_rect(renderer, &h2)
	sdl.render_fill_rect(renderer, &h3)
}

fn draw_particles(renderer &sdl.Renderer, g &BowlingGame) {
	for p in g.particles {
		alpha := u8(255.0 * (p.life / p.max_life))
		sdl.set_render_draw_color(renderer, p.color.r, p.color.g, p.color.b, alpha)
		rect := sdl.Rect{
			x: int(p.x) - p.size / 2
			y: int(p.y) - p.size / 2
			w: p.size
			h: p.size
		}
		sdl.render_fill_rect(renderer, &rect)
	}
}

fn draw_aim_hud(renderer &sdl.Renderer, g &BowlingGame) {
	if g.phase == .position || g.phase == .angle || g.phase == .power {
		bx := int(g.aim_x)
		by := int(g.lane_bottom - 40.0)

		// Trajectory Guide Arrow Line
		arrow_len := 120.0
		end_x := f64(bx) + math.sin(g.aim_angle) * arrow_len
		end_y := f64(by) - math.cos(g.aim_angle) * arrow_len

		sdl.set_render_draw_color(renderer, 255, 215, 0, 200)
		sdl.render_draw_line(renderer, bx, by, int(end_x), int(end_y))
		sdl.render_draw_line(renderer, bx - 1, by, int(end_x) - 1, int(end_y))
		sdl.render_draw_line(renderer, bx + 1, by, int(end_x) + 1, int(end_y))

		// Power & Hook Gauge Bar (Bottom HUD)
		bar_x := 600
		bar_y := 450
		bar_w := 160
		bar_h := 22

		// Power Meter
		draw_text(renderer, bar_x, bar_y - 20, 'POWER (SPACE)', 1, Color{ r: 255, g: 255, b: 255 })
		bg_rect := sdl.Rect{ x: bar_x, y: bar_y, w: bar_w, h: bar_h }
		sdl.set_render_draw_color(renderer, 40, 45, 60, 255)
		sdl.render_fill_rect(renderer, &bg_rect)

		fill_w := int(f64(bar_w) * g.power)
		fill_color := if g.power > 0.8 {
			Color{ r: 255, g: 50, b: 50 }
		} else if g.power > 0.5 {
			Color{ r: 255, g: 200, b: 0 }
		} else {
			Color{ r: 50, g: 200, b: 50 }
		}
		fill_rect := sdl.Rect{ x: bar_x, y: bar_y, w: fill_w, h: bar_h }
		sdl.set_render_draw_color(renderer, fill_color.r, fill_color.g, fill_color.b, 255)
		sdl.render_fill_rect(renderer, &fill_rect)

		sdl.set_render_draw_color(renderer, 200, 210, 230, 255)
		sdl.render_draw_rect(renderer, &bg_rect)

		// Hook / Spin Meter
		hook_y := bar_y + 45
		draw_text(renderer, bar_x, hook_y - 20, 'HOOK SPIN (Z / X)', 1, Color{ r: 255, g: 255, b: 255 })
		hook_bg := sdl.Rect{ x: bar_x, y: hook_y, w: bar_w, h: bar_h }
		sdl.set_render_draw_color(renderer, 40, 45, 60, 255)
		sdl.render_fill_rect(renderer, &hook_bg)

		hook_mid := bar_x + bar_w / 2
		hook_fill_w := int(g.hook * f64(bar_w / 2))
		hook_rect := if hook_fill_w >= 0 {
			sdl.Rect{ x: hook_mid, y: hook_y, w: hook_fill_w, h: bar_h }
		} else {
			sdl.Rect{ x: hook_mid + hook_fill_w, y: hook_y, w: -hook_fill_w, h: bar_h }
		}
		sdl.set_render_draw_color(renderer, 0, 180, 255, 255)
		sdl.render_fill_rect(renderer, &hook_rect)
		sdl.set_render_draw_color(renderer, 200, 210, 230, 255)
		sdl.render_draw_rect(renderer, &hook_bg)

		// Instructions
		status_text := match g.phase {
			.position { 'STEP 1: [A / D] STANCE POSITION -> [SPACE] LOCK' }
			.angle { 'STEP 2: [SPACE] LOCK LAUNCH ANGLE' }
			.power { 'STEP 3: [SPACE] BOWL BALL / [Z / X] HOOK SPIN' }
			else { '' }
		}
		draw_text_centered(renderer, 400, int(g.lane_bottom + 15.0), status_text, 1, Color{ r: 255, g: 220, b: 100 })
	}
}

fn draw_pinsetter_sweep(renderer &sdl.Renderer, g &BowlingGame) {
	if g.phase == .sweep {
		sy := int(g.sweep_y)
		lane_w := int(g.lane_right - g.lane_left)

		// Metal Sweeper Bar
		sdl.set_render_draw_color(renderer, 70, 75, 90, 255)
		sweep_rect := sdl.Rect{
			x: int(g.lane_left)
			y: sy
			w: lane_w
			h: 16
		}
		sdl.render_fill_rect(renderer, &sweep_rect)

		sdl.set_render_draw_color(renderer, 200, 210, 230, 255)
		sdl.render_draw_rect(renderer, &sweep_rect)

		draw_text_centered(renderer, 400, sy + 3, 'PINSETTER SWEEP', 1, Color{ r: 255, g: 220, b: 0 })
	}
}

fn draw_overhead_scoreboard(renderer &sdl.Renderer, g &BowlingGame) {
	// Top Scoreboard Banner (10 Frames)
	panel_w := 780
	panel_h := 80
	px := (800 - panel_w) / 2
	py := 8

	sdl.set_render_draw_color(renderer, 10, 14, 25, 240)
	panel_rect := sdl.Rect{ x: px, y: py, w: panel_w, h: panel_h }
	sdl.render_fill_rect(renderer, &panel_rect)

	sdl.set_render_draw_color(renderer, 0, 180, 255, 255)
	sdl.render_draw_rect(renderer, &panel_rect)

	p := g.players[g.current_player]

	// Player Name & Game Mode
	mode_name := match g.mode {
		.solo { 'SOLO BOWLING' }
		.vs_ai { 'VS CPU BOWLER' }
		.vs_2p { '2P LOCAL VERSUS' }
	}
	draw_text(renderer, px + 10, py + 8, '${p.name.to_upper()} - ${mode_name}', 1, Color{ r: 255, g: 215, b: 0 })
	draw_text(renderer, px + panel_w - 180, py + 8, 'TOTAL: ${p.total_score}', 1, Color{ r: 0, g: 255, b: 180 })

	// Frame Boxes 1-10
	frame_w := 54
	frame_h := 45
	start_x := px + 120

	for i := 0; i < 10; i++ {
		fx := start_x + i * frame_w
		fy := py + 26
		is_cur := (i == p.current_frame)

		// Frame box border
		cr := if is_cur { u8(255) } else { u8(80) }
		cg := if is_cur { u8(220) } else { u8(90) }
		cb := if is_cur { u8(50) } else { u8(120) }
		sdl.set_render_draw_color(renderer, cr, cg, cb, 255)
		f_rect := sdl.Rect{ x: fx, y: fy, w: frame_w - 2, h: frame_h }
		sdl.render_draw_rect(renderer, &f_rect)

		// Frame Number Header
		draw_text_centered(renderer, fx + (frame_w - 2) / 2, fy + 2, '${i + 1}', 1, Color{ r: 180, g: 190, b: 210 })

		// Roll Marks
		f_score := p.frames[i]
		if i < 9 {
			// Sub-box for roll 2
			sub_rect := sdl.Rect{ x: fx + frame_w - 20, y: fy + 12, w: 18, h: 16 }
			sdl.set_render_draw_color(renderer, 60, 70, 95, 255)
			sdl.render_fill_rect(renderer, &sub_rect)
			sdl.render_draw_rect(renderer, &sub_rect)

			if f_score.is_strike {
				draw_text_centered(renderer, fx + frame_w - 11, fy + 15, 'X', 1, Color{ r: 255, g: 50, b: 50 })
			} else {
				if f_score.roll1 != -1 {
					r1_str := if f_score.roll1 == 0 { '-' } else { '${f_score.roll1}' }
					draw_text(renderer, fx + 8, fy + 15, r1_str, 1, Color{ r: 250, g: 250, b: 255 })
				}
				if f_score.is_spare {
					draw_text_centered(renderer, fx + frame_w - 11, fy + 15, '/', 1, Color{ r: 0, g: 255, b: 180 })
				} else if f_score.roll2 != -1 {
					r2_str := if f_score.roll2 == 0 { '-' } else { '${f_score.roll2}' }
					draw_text_centered(renderer, fx + frame_w - 11, fy + 15, r2_str, 1, Color{ r: 250, g: 250, b: 255 })
				}
			}
		} else {
			// 10th frame (3 sub-boxes)
			if f_score.roll1 != -1 {
				r1_str := if f_score.is_strike { 'X' } else if f_score.roll1 == 0 { '-' } else { '${f_score.roll1}' }
				draw_text(renderer, fx + 4, fy + 15, r1_str, 1, Color{ r: 250, g: 250, b: 255 })
			}
			if f_score.roll2 != -1 {
				r2_str := if f_score.roll2 == 10 { 'X' } else if f_score.is_spare { '/' } else if f_score.roll2 == 0 { '-' } else { '${f_score.roll2}' }
				draw_text(renderer, fx + 20, fy + 15, r2_str, 1, Color{ r: 250, g: 250, b: 255 })
			}
			if f_score.roll3 != -1 {
				r3_str := if f_score.roll3 == 10 { 'X' } else if f_score.roll3 == 0 { '-' } else { '${f_score.roll3}' }
				draw_text(renderer, fx + 36, fy + 15, r3_str, 1, Color{ r: 250, g: 250, b: 255 })
			}
		}

		// Cumulative Score
		if f_score.cumulative != -1 {
			cum_str := '${f_score.cumulative}'
			draw_text_centered(renderer, fx + (frame_w - 2) / 2, fy + 30, cum_str, 1, Color{ r: 0, g: 255, b: 200 })
		}
	}
}

fn draw_celebration_banner(renderer &sdl.Renderer, g &BowlingGame) {
	if g.celebration != '' {
		box_w := 440
		box_h := 60
		bx := (800 - box_w) / 2
		by := 280

		sdl.set_render_draw_color(renderer, 12, 16, 28, 245)
		b_rect := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		draw_text_centered(renderer, 400, by + 20, g.celebration, 2, Color{ r: 255, g: 220, b: 50 })
	}
}
