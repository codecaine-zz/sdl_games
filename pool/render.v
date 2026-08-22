module main

import math
import sdl

fn draw_pool_game(renderer &sdl.Renderer, g &PoolGame) {
	// Deep pub lounge background
	sdl.set_render_draw_color(renderer, 15, 18, 26, 255)
	sdl.render_clear(renderer)

	draw_table_wood_rim(renderer, g)
	draw_table_felt(renderer, g)
	draw_pockets(renderer, g)
	draw_balls(renderer, g)
	draw_cue_stick(renderer, g)
	draw_aiming_guideline(renderer, g)
	draw_pool_hud(renderer, g)
	draw_celebration(renderer, g)
}

fn draw_table_wood_rim(renderer &sdl.Renderer, g &PoolGame) {
	// Polished Mahogany Table Border
	tx := int(g.table_x)
	ty := int(g.table_y)
	tw := int(g.table_w)
	th := int(g.table_h)

	sdl.set_render_draw_color(renderer, 70, 38, 20, 255)
	rim_rect := sdl.Rect{ x: tx, y: ty, w: tw, h: th }
	sdl.render_fill_rect(renderer, &rim_rect)

	// Wood grain bevel
	sdl.set_render_draw_color(renderer, 105, 58, 30, 255)
	inner_rim := sdl.Rect{ x: tx + 6, y: ty + 6, w: tw - 12, h: th - 12 }
	sdl.render_draw_rect(renderer, &inner_rim)

	// Sights / Diamonds along rails (3 along short rails, 6 along long rails)
	sdl.set_render_draw_color(renderer, 230, 220, 190, 255)
	// Top & Bottom rail diamonds
	for i := 1; i <= 6; i++ {
		dx := tx + int(f64(tw) * (f64(i) / 7.0))
		d1 := sdl.Rect{ x: dx - 2, y: ty + 10, w: 4, h: 4 }
		d2 := sdl.Rect{ x: dx - 2, y: ty + th - 14, w: 4, h: 4 }
		sdl.render_fill_rect(renderer, &d1)
		sdl.render_fill_rect(renderer, &d2)
	}
	// Left & Right rail diamonds
	for i := 1; i <= 3; i++ {
		dy := ty + int(f64(th) * (f64(i) / 4.0))
		d1 := sdl.Rect{ x: tx + 10, y: dy - 2, w: 4, h: 4 }
		d2 := sdl.Rect{ x: tx + tw - 14, y: dy - 2, w: 4, h: 4 }
		sdl.render_fill_rect(renderer, &d1)
		sdl.render_fill_rect(renderer, &d2)
	}
}

fn draw_table_felt(renderer &sdl.Renderer, g &PoolGame) {
	// Green Tournament Felt Playfield
	fx := int(g.table_x + g.cushion_thick)
	fy := int(g.table_y + g.cushion_thick)
	fw := int(g.table_w - g.cushion_thick * 2.0)
	fh := int(g.table_h - g.cushion_thick * 2.0)

	sdl.set_render_draw_color(renderer, 18, 120, 68, 255)
	felt_rect := sdl.Rect{ x: fx, y: fy, w: fw, h: fh }
	sdl.render_fill_rect(renderer, &felt_rect)

	// Head string line & spot
	sdl.set_render_draw_color(renderer, 30, 145, 85, 200)
	hx := int(g.table_x + g.table_w * 0.28)
	sdl.render_draw_line(renderer, hx, fy, hx, fy + fh)

	// Head spot
	spot := sdl.Rect{ x: hx - 2, y: fy + fh / 2 - 2, w: 4, h: 4 }
	sdl.render_fill_rect(renderer, &spot)
}

fn draw_pockets(renderer &sdl.Renderer, g &PoolGame) {
	for p in g.pockets {
		px := int(p.x)
		py := int(p.y)
		r := int(p.radius)

		// Dark interior leather drop hole
		sdl.set_render_draw_color(renderer, 8, 10, 15, 255)
		draw_filled_circle(renderer, px, py, r, Color{ r: 8, g: 10, b: 15 })

		// Brass pocket rim corner
		draw_circle_wire(renderer, px, py, r, Color{ r: 180, g: 150, b: 60 })
	}
}

fn draw_balls(renderer &sdl.Renderer, g &PoolGame) {
	for b in g.balls {
		if b.potted { continue }

		bx := int(b.x)
		by := int(b.y)
		r := int(b.radius)

		// Ball drop shadow
		sdl.set_render_draw_color(renderer, 0, 0, 0, 80)
		shadow := sdl.Rect{ x: bx - r + 2, y: by - r + 3, w: r * 2, h: r * 2 }
		sdl.render_fill_rect(renderer, &shadow)

		// Ball base color
		c := get_ball_color(b.id)
		draw_filled_circle(renderer, bx, by, r, c)

		// If stripe ball (9-15), draw white stripe band across middle
		if !b.is_solid && !b.is_cue && !b.is_eight {
			sdl.set_render_draw_color(renderer, 245, 245, 255, 255)
			stripe_rect := sdl.Rect{ x: bx - r, y: by - 4, w: r * 2, h: 8 }
			sdl.render_fill_rect(renderer, &stripe_rect)
		}

		// Number circle badge (except cue ball)
		if !b.is_cue {
			badge_r := 5
			draw_filled_circle(renderer, bx, by, badge_r, Color{ r: 250, g: 250, b: 255 })
			num_str := '${b.id}'
			draw_text_centered(renderer, bx, by - 3, num_str, 1, Color{ r: 10, g: 10, b: 15 })
		}

		// 3D Specular Highlight
		pr := u8(math.min(255.0, f64(c.r) + 80.0))
		pg := u8(math.min(255.0, f64(c.g) + 80.0))
		pb := u8(math.min(255.0, f64(c.b) + 80.0))
		sdl.set_render_draw_color(renderer, pr, pg, pb, 200)
		sdl.render_draw_point(renderer, bx - 3, by - 3)
		sdl.render_draw_point(renderer, bx - 2, by - 3)
		sdl.render_draw_point(renderer, bx - 3, by - 2)
	}
}

fn get_ball_color(id int) Color {
	return match id {
		0  { Color{ r: 245, g: 245, b: 255 } } // Cue Ball (White)
		1, 9  { Color{ r: 245, g: 210, b: 30 } }  // Yellow
		2, 10 { Color{ r: 35, g: 75, b: 210 } }   // Blue
		3, 11 { Color{ r: 220, g: 45, b: 45 } }   // Red
		4, 12 { Color{ r: 120, g: 40, b: 160 } }  // Purple
		5, 13 { Color{ r: 240, g: 120, b: 25 } }  // Orange
		6, 14 { Color{ r: 30, g: 140, b: 50 } }   // Green
		7, 15 { Color{ r: 140, g: 30, b: 35 } }   // Maroon
		8  { Color{ r: 20, g: 20, b: 25 } }   // Black 8-Ball
		else { Color{ r: 200, g: 200, b: 200 } }
	}
}

fn draw_aiming_guideline(renderer &sdl.Renderer, g &PoolGame) {
	if g.state != .aiming && g.state != .power_pull {
		return
	}
	if g.balls.len == 0 || g.balls[0].potted {
		return
	}

	cx := g.balls[0].x
	cy := g.balls[0].y

	// Raycast forward to find first object ball hit or cushion
	mut ray_len := 400.0
	mut hit_ball_idx := -1

	for idx, b in g.balls {
		if idx == 0 || b.potted { continue }

		dx := b.x - cx
		dy := b.y - cy

		// Projection along aim line
		aim_dir_x := math.cos(g.aim_angle)
		aim_dir_y := math.sin(g.aim_angle)
		dot := dx * aim_dir_x + dy * aim_dir_y

		if dot > 0.0 && dot < ray_len {
			// Perpendicular distance to line
			perp_dist := math.abs(dx * aim_dir_y - dy * aim_dir_x)
			if perp_dist < 22.0 {
				ray_len = dot - math.sqrt(484.0 - perp_dist * perp_dist)
				hit_ball_idx = idx
			}
		}
	}

	end_x := cx + math.cos(g.aim_angle) * ray_len
	end_y := cy + math.sin(g.aim_angle) * ray_len

	// Primary Cue Line (Translucent White)
	sdl.set_render_draw_color(renderer, 255, 255, 255, 180)
	sdl.render_draw_line(renderer, int(cx), int(cy), int(end_x), int(end_y))

	// Ghost Ball Projection at impact point
	if hit_ball_idx != -1 {
		draw_circle_wire(renderer, int(end_x), int(end_y), 11, Color{ r: 255, g: 255, b: 255 })

		// Deflection trajectory vector for object ball
		tb := g.balls[hit_ball_idx]
		obj_dir_x := tb.x - end_x
		obj_dir_y := tb.y - end_y
		obj_dist := math.sqrt(obj_dir_x * obj_dir_x + obj_dir_y * obj_dir_y)
		if obj_dist > 0.001 {
			nx := obj_dir_x / obj_dist
			ny := obj_dir_y / obj_dist
			deflect_x := tb.x + nx * 60.0
			deflect_y := tb.y + ny * 60.0

			sdl.set_render_draw_color(renderer, 255, 215, 0, 220)
			sdl.render_draw_line(renderer, int(tb.x), int(tb.y), int(deflect_x), int(deflect_y))
		}
	}
}

fn draw_cue_stick(renderer &sdl.Renderer, g &PoolGame) {
	if g.state != .aiming && g.state != .power_pull {
		return
	}
	if g.balls.len == 0 || g.balls[0].potted {
		return
	}

	cx := g.balls[0].x
	cy := g.balls[0].y

	// Pull-back offset based on power
	pull_offset := 18.0 + g.cue_power * 40.0
	cue_len := 180.0

	tip_x := cx - math.cos(g.aim_angle) * pull_offset
	tip_y := cy - math.sin(g.aim_angle) * pull_offset
	butt_x := tip_x - math.cos(g.aim_angle) * cue_len
	butt_y := tip_y - math.sin(g.aim_angle) * cue_len

	// Cue Shaft (Maple Wood)
	sdl.set_render_draw_color(renderer, 220, 185, 140, 255)
	sdl.render_draw_line(renderer, int(tip_x), int(tip_y), int(butt_x), int(butt_y))
	sdl.render_draw_line(renderer, int(tip_x + 1), int(tip_y), int(butt_x + 1), int(butt_y))

	// Cue Leather Tip (Blue chalk)
	sdl.set_render_draw_color(renderer, 40, 140, 220, 255)
	sdl.render_draw_line(renderer, int(tip_x), int(tip_y), int(tip_x - math.cos(g.aim_angle) * 4.0), int(tip_y - math.sin(g.aim_angle) * 4.0))

	// Cue Butt Grip (Black/Mahogany)
	sdl.set_render_draw_color(renderer, 30, 25, 20, 255)
	grip_start_x := butt_x + math.cos(g.aim_angle) * 60.0
	grip_start_y := butt_y + math.sin(g.aim_angle) * 60.0
	sdl.render_draw_line(renderer, int(grip_start_x), int(grip_start_y), int(butt_x), int(butt_y))
}

fn draw_pool_hud(renderer &sdl.Renderer, g &PoolGame) {
	// Top Header Banner
	panel_w := 760
	panel_h := 60
	px := (800 - panel_w) / 2
	py := 10

	sdl.set_render_draw_color(renderer, 10, 14, 25, 240)
	panel_rect := sdl.Rect{ x: px, y: py, w: panel_w, h: panel_h }
	sdl.render_fill_rect(renderer, &panel_rect)

	sdl.set_render_draw_color(renderer, 0, 200, 255, 255)
	sdl.render_draw_rect(renderer, &panel_rect)

	mode_str := match g.typ {
		.eight_ball { '8-BALL POOL' }
		.nine_ball { '9-BALL POOL' }
		.practice { 'PRACTICE / TRICK SHOT' }
	}
	draw_text(renderer, px + 12, py + 8, mode_str, 1, Color{ r: 255, g: 215, b: 0 })

	// Player turn indicator
	p := g.players[g.current_p_idx]
	group_str := match p.group {
		.solids { 'SOLIDS (1-7)' }
		.stripes { 'STRIPES (9-15)' }
		else { 'OPEN TABLE' }
	}
	draw_text(renderer, px + 12, py + 26, '${p.name.to_upper()} TURN: ${group_str}', 1, Color{ r: 0, g: 255, b: 180 })

	// Power Gauge (Right side of HUD)
	bar_w := 140
	bar_h := 16
	bar_x := px + panel_w - bar_w - 20
	bar_y := py + 24

	draw_text(renderer, bar_x, py + 8, 'POWER (HOLD SPACE / DRAG)', 1, Color{ r: 200, g: 220, b: 255 })
	bg_rect := sdl.Rect{ x: bar_x, y: bar_y, w: bar_w, h: bar_h }
	sdl.set_render_draw_color(renderer, 30, 35, 50, 255)
	sdl.render_fill_rect(renderer, &bg_rect)

	fill_w := int(f64(bar_w) * g.cue_power)
	fill_rect := sdl.Rect{ x: bar_x, y: bar_y, w: fill_w, h: bar_h }
	sdl.set_render_draw_color(renderer, 255, 180, 0, 255)
	sdl.render_fill_rect(renderer, &fill_rect)

	sdl.set_render_draw_color(renderer, 200, 210, 240, 255)
	sdl.render_draw_rect(renderer, &bg_rect)

	// Bottom Controls Guide
	help_text := '[MOUSE / ARROWS] AIM  |  [HOLD SPACE / CLICK DRAG] STRIKE  |  [1-3] MODES  |  [M] SOUND  |  [R] RE-RACK'
	draw_text_centered(renderer, 400, 560, help_text, 1, Color{ r: 150, g: 170, b: 200 })

	if g.state == .ball_in_hand {
		draw_text_centered(renderer, 400, 490, 'BALL IN HAND: CLICK TABLE TO PLACE CUE BALL', 1, Color{ r: 255, g: 220, b: 50 })
	}
}

fn draw_celebration(renderer &sdl.Renderer, g &PoolGame) {
	if g.celebration != '' {
		box_w := 460
		box_h := 60
		bx := (800 - box_w) / 2
		by := 250

		sdl.set_render_draw_color(renderer, 15, 20, 35, 245)
		b_rect := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		draw_text_centered(renderer, 400, by + 20, g.celebration, 2, Color{ r: 255, g: 220, b: 50 })
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
	steps := 40
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
