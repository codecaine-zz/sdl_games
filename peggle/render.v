module main

import math
import sdl

pub fn render_peggle_game(renderer &sdl.Renderer, mut g PeggleGame, win_w int, win_h int, sound_enabled bool) {
	// 1. Magical Deep Purple/Blue Gradient
	for y in 0 .. win_h {
		factor := f64(y) / f64(win_h)
		r := u8(20.0 + factor * 25.0)
		gr := u8(15.0 + factor * 20.0)
		b := u8(45.0 + factor * 55.0)
		sdl.set_render_draw_color(renderer, r, gr, b, 255)
		sdl.render_draw_line(renderer, 0, y, win_w, y)
	}

	// 2. Side Golden Columns
	sdl.set_render_draw_color(renderer, 180, 130, 40, 255)
	col_l := sdl.Rect{45, 0, 15, win_h}
	col_r := sdl.Rect{win_w - 60, 0, 15, win_h}
	sdl.render_fill_rect(renderer, &col_l)
	sdl.render_fill_rect(renderer, &col_r)

	// 3. Aiming Guide Trajectory (when ready to shoot)
	if g.active_balls.len == 0 && g.balls_left > 0 && !g.is_game_over {
		cannon_x := f64(win_w) / 2.0
		cannon_y := 45.0
		sdl.set_render_draw_color(renderer, 255, 230, 100, 140)
		for step in 1 .. 14 {
			dist := f64(step * 24)
			gx := int(cannon_x + math.cos(g.cannon_angle) * dist)
			gy := int(cannon_y + math.sin(g.cannon_angle) * dist)
			draw_filled_circle(renderer, gx, gy, 2, Color{255, 230, 100, 140})
		}
	}

	// 4. Render Pegs
	for p in g.pegs {
		render_peg(renderer, p)
	}

	// 5. Render Moving Bottom Catcher Bucket
	render_bucket(renderer, g.bucket_x, f64(win_h - 25), g.bucket_w)

	// 6. Render Active Balls
	for b in g.active_balls {
		if b.active {
			bx := int(b.x)
			by := int(b.y)
			draw_filled_circle(renderer, bx, by, int(b.radius), Color{240, 240, 250, 255})
			draw_filled_circle(renderer, bx - 2, by - 2, 3, Color{255, 255, 255, 255})
		}
	}

	// 7. Render Overhead Rotating Cannon
	render_cannon(renderer, f64(win_w) / 2.0, 45.0, g.cannon_angle)

	// 8. Top Header & Status Meters
	render_peggle_hud(renderer, g, win_w, sound_enabled)

	// 9. Announcement Banner
	if g.banner_timer > 0.0 && g.banner_text != '' {
		bw := g.banner_text.len * 8 * 2 + 40
		bx := win_w / 2 - bw / 2
		by := 240

		sdl.set_render_draw_color(renderer, 15, 20, 35, 240)
		bg := sdl.Rect{bx, by, bw, 44}
		sdl.render_fill_rect(renderer, &bg)
		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &bg)

		draw_text_centered(renderer, win_w / 2, by + 14, g.banner_text, 2, Color{255, 230, 80, 255})
	}
}

fn render_peg(renderer &sdl.Renderer, p Peg) {
	px := int(p.x)
	py := int(p.y)
	r := int(p.radius)

	// Glow aura if hit
	if p.is_hit {
		draw_filled_circle(renderer, px, py, r + 4, Color{255, 255, 255, 180})
	}

	col := match p.ptype {
		.blue { Color{40, 140, 255, 255} }
		.orange { Color{255, 140, 20, 255} }
		.purple { Color{210, 40, 240, 255} }
		.green { Color{40, 230, 100, 255} }
	}

	draw_filled_circle(renderer, px, py, r, col)
	draw_filled_circle(renderer, px - 2, py - 2, r / 3, Color{255, 255, 255, 200})
}

fn render_bucket(renderer &sdl.Renderer, cx f64, cy f64, w f64) {
	bx := int(cx - w / 2.0)
	by := int(cy)

	// Golden Bucket Catcher
	sdl.set_render_draw_color(renderer, 220, 175, 40, 255)
	b_rect := sdl.Rect{bx, by, int(w), 20}
	sdl.render_fill_rect(renderer, &b_rect)

	sdl.set_render_draw_color(renderer, 80, 40, 10, 255)
	sdl.render_draw_rect(renderer, &b_rect)

	draw_text_centered(renderer, int(cx), by + 6, 'FREE BALL', 1, Color{30, 20, 5, 255})
}

fn render_cannon(renderer &sdl.Renderer, cx f64, cy f64, angle f64) {
	// Cannon Base Dome
	draw_filled_circle(renderer, int(cx), int(cy), 22, Color{180, 140, 40, 255})

	// Rotating Barrel
	barrel_len := 30.0
	bx := int(cx + math.cos(angle) * barrel_len)
	by := int(cy + math.sin(angle) * barrel_len)

	sdl.set_render_draw_color(renderer, 220, 220, 230, 255)
	for i in -2 .. 3 {
		sdl.render_draw_line(renderer, int(cx) + i, int(cy), bx + i, by)
	}
}

fn render_peggle_hud(renderer &sdl.Renderer, g PeggleGame, win_w int, sound_enabled bool) {
	sdl.set_render_draw_color(renderer, 15, 20, 32, 220)
	bar := sdl.Rect{0, 0, win_w, 42}
	sdl.render_fill_rect(renderer, &bar)

	sdl.set_render_draw_color(renderer, 180, 140, 40, 255)
	sdl.render_draw_line(renderer, 0, 41, win_w, 41)

	// Title
	draw_text(renderer, 20, 14, '★ PEGGLE EXTREME ★', 1, Color{255, 215, 0, 255})

	// Stats
	draw_text(renderer, 210, 14, 'BALLS: ${g.balls_left}', 1, Color{100, 240, 255, 255})
	draw_text(renderer, 330, 14, 'ORANGE LEFT: ${g.orange_left}', 1, Color{255, 160, 40, 255})
	draw_text(renderer, 520, 14, 'SCORE: ${g.score}', 1, Color{100, 255, 140, 255})

	// Sound toggle badge
	sound_x := win_w - 140
	if sound_enabled {
		sdl.set_render_draw_color(renderer, 40, 120, 60, 255)
		btn := sdl.Rect{sound_x, 8, 120, 24}
		sdl.render_fill_rect(renderer, &btn)
		draw_text_centered(renderer, sound_x + 60, 13, 'SOUND: ON [M]', 1, Color{255, 255, 255, 255})
	} else {
		sdl.set_render_draw_color(renderer, 120, 35, 40, 255)
		btn := sdl.Rect{sound_x, 8, 120, 24}
		sdl.render_fill_rect(renderer, &btn)
		draw_text_centered(renderer, sound_x + 60, 13, 'MUTED [M]', 1, Color{255, 180, 180, 255})
	}
}
