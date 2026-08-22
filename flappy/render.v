module main

import math
import sdl

pub fn draw_flappy_bird(renderer &sdl.Renderer, cx f64, cy f64, angle f64, wing_frame int) {
	// Bird Body: Yellow oval with orange belly
	int_cx := int(cx)
	int_cy := int(cy)

	// Rotated offsets helper
	rot_pt := fn (rx f64, ry f64, ang f64) (int, int) {
		cos_a := math.cos(ang)
		sin_a := math.sin(ang)
		nx := rx * cos_a - ry * sin_a
		ny := rx * sin_a + ry * cos_a
		return int(nx), int(ny)
	}

	// Body Base (Yellow)
	sdl.set_render_draw_color(renderer, 245, 195, 35, 255)
	for dy := -11; dy <= 11; dy++ {
		dx_max := int(math.sqrt(f64(144 - dy * dy)) * 1.3)
		for dx := -dx_max; dx <= dx_max; dx++ {
			rx, ry := rot_pt(f64(dx), f64(dy), angle)
			sdl.render_draw_point(renderer, int_cx + rx, int_cy + ry)
		}
	}

	// Orange Belly Underbelly
	sdl.set_render_draw_color(renderer, 235, 130, 30, 255)
	for dy := 2; dy <= 10; dy++ {
		dx_max := int(math.sqrt(f64(100 - dy * dy)) * 1.1)
		for dx := -dx_max; dx <= dx_max; dx++ {
			rx, ry := rot_pt(f64(dx - 2), f64(dy), angle)
			sdl.render_draw_point(renderer, int_cx + rx, int_cy + ry)
		}
	}

	// Beak (Bright Orange)
	sdl.set_render_draw_color(renderer, 245, 80, 20, 255)
	for dy := -4; dy <= 4; dy++ {
		len_x := 10 - int(math.abs(f64(dy)) * 2.0)
		for dx := 0; dx <= len_x; dx++ {
			rx, ry := rot_pt(f64(11 + dx), f64(dy + 2), angle)
			sdl.render_draw_point(renderer, int_cx + rx, int_cy + ry)
		}
	}

	// Large White Eye with Black Pupil
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	eye_ox := 7.0
	eye_oy := -5.0
	for dy := -5; dy <= 5; dy++ {
		dx_max := int(math.sqrt(f64(25 - dy * dy)))
		for dx := -dx_max; dx <= dx_max; dx++ {
			rx, ry := rot_pt(eye_ox + f64(dx), eye_oy + f64(dy), angle)
			sdl.render_draw_point(renderer, int_cx + rx, int_cy + ry)
		}
	}

	// Black Pupil
	sdl.set_render_draw_color(renderer, 10, 10, 10, 255)
	for dy := -2; dy <= 2; dy++ {
		for dx := 0; dx <= 2; dx++ {
			rx, ry := rot_pt(eye_ox + 2.0 + f64(dx), eye_oy + f64(dy), angle)
			sdl.render_draw_point(renderer, int_cx + rx, int_cy + ry)
		}
	}

	// Animated White Wing
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	wing_dy := match wing_frame {
		0 { 0.0 }
		1 { -4.0 }
		else { 4.0 }
	}
	for dy := -5; dy <= 5; dy++ {
		dx_max := int(math.sqrt(f64(25 - dy * dy)) * 1.2)
		for dx := -dx_max; dx <= dx_max; dx++ {
			rx, ry := rot_pt(-6.0 + f64(dx), wing_dy + f64(dy), angle)
			sdl.render_draw_point(renderer, int_cx + rx, int_cy + ry)
		}
	}
}

pub fn draw_retro_pipe(renderer &sdl.Renderer, px f64, top_h f64, gap f64, win_h int) {
	ix := int(px)
	iw := int(pipe_width)
	rim_h := 24
	rim_out := 4

	body_col := Color{r: 115, g: 190, b: 45}
	light_col := Color{r: 180, g: 235, b: 85}
	shadow_col := Color{r: 70, g: 125, b: 25}
	dark_border := Color{r: 35, g: 65, b: 15}

	// Helper to draw a beveled pipe segment
	draw_pipe_seg := fn (renderer &sdl.Renderer, sx int, sy int, sw int, sh int, b_col Color, l_col Color, s_col Color, d_col Color) {
		// Base fill
		sdl.set_render_draw_color(renderer, b_col.r, b_col.g, b_col.b, 255)
		sdl.render_fill_rect(renderer, &sdl.Rect{x: sx, y: sy, w: sw, h: sh})

		// Left highlight band
		sdl.set_render_draw_color(renderer, l_col.r, l_col.g, l_col.b, 255)
		sdl.render_fill_rect(renderer, &sdl.Rect{x: sx + 4, y: sy, w: 8, h: sh})

		// Right shadow band
		sdl.set_render_draw_color(renderer, s_col.r, s_col.g, s_col.b, 255)
		sdl.render_fill_rect(renderer, &sdl.Rect{x: sx + sw - 12, y: sy, w: 10, h: sh})

		// Dark Outer Border
		sdl.set_render_draw_color(renderer, d_col.r, d_col.g, d_col.b, 255)
		sdl.render_draw_rect(renderer, &sdl.Rect{x: sx, y: sy, w: sw, h: sh})
	}

	// 1. Top Pipe Body (y: 0 to top_h - rim_h)
	top_body_h := int(top_h) - rim_h
	if top_body_h > 0 {
		draw_pipe_seg(renderer, ix, 0, iw, top_body_h, body_col, light_col, shadow_col, dark_border)
	}

	// 2. Top Pipe Rim Cap (y: top_h - rim_h to top_h)
	draw_pipe_seg(renderer, ix - rim_out, int(top_h) - rim_h, iw + rim_out * 2, rim_h, body_col, light_col, shadow_col, dark_border)

	// 3. Bottom Pipe Rim Cap (y: top_h + gap to top_h + gap + rim_h)
	bot_rim_y := int(top_h + gap)
	draw_pipe_seg(renderer, ix - rim_out, bot_rim_y, iw + rim_out * 2, rim_h, body_col, light_col, shadow_col, dark_border)

	// 4. Bottom Pipe Body (y: bot_rim_y + rim_h to ground)
	bot_body_y := bot_rim_y + rim_h
	bot_body_h := win_h - int(ground_height) - bot_body_y
	if bot_body_h > 0 {
		draw_pipe_seg(renderer, ix, bot_body_y, iw, bot_body_h, body_col, light_col, shadow_col, dark_border)
	}
}

pub fn render_flappy_game(renderer &sdl.Renderer, game &FlappyGame, win_w int, win_h int) {
	// 1. Sky Gradient (Bright Blue to Cyan)
	sdl.set_render_draw_color(renderer, 75, 190, 235, 255)
	sdl.render_clear(renderer)

	// Distant City Skyline Parallax
	sdl.set_render_draw_color(renderer, 140, 215, 205, 255)
	skyline_y := int(f64(win_h) - ground_height - 60.0)
	for i := 0; i < win_w / 35 + 2; i++ {
		bx := (i * 35 - int(game.scroll_x * 0.2)) % (win_w + 70) - 35
		bh := 30 + (i * 17) % 35
		sdl.render_fill_rect(renderer, &sdl.Rect{x: bx, y: skyline_y - bh, w: 32, h: bh + 60})
	}

	// Clouds Parallax
	sdl.set_render_draw_color(renderer, 240, 250, 255, 200)
	for i := 0; i < 4; i++ {
		cx := (i * 160 - int(game.scroll_x * 0.4)) % (win_w + 120) - 60
		cy := 70 + (i * 37) % 80
		sdl.render_fill_rect(renderer, &sdl.Rect{x: cx, y: cy, w: 70, h: 22})
		sdl.render_fill_rect(renderer, &sdl.Rect{x: cx + 15, y: cy - 10, w: 40, h: 18})
	}

	// 2. Pipes
	for pipe in game.pipes {
		draw_retro_pipe(renderer, pipe.x, pipe.top_h, pipe_gap, win_h)
	}

	// 3. Ground Layer (Grass top + Dirt with scrolling hazard stripes)
	gy := int(f64(win_h) - ground_height)
	// Green Grass Rim
	sdl.set_render_draw_color(renderer, 115, 200, 45, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{x: 0, y: gy, w: win_w, h: 14})
	sdl.set_render_draw_color(renderer, 160, 235, 75, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{x: 0, y: gy + 2, w: win_w, h: 3})

	// Brown Dirt Bed
	sdl.set_render_draw_color(renderer, 220, 180, 110, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{x: 0, y: gy + 14, w: win_w, h: int(ground_height) - 14})

	// Dirt stripes parallax
	sdl.set_render_draw_color(renderer, 190, 150, 85, 255)
	for i := 0; i < win_w / 20 + 2; i++ {
		sx := (i * 20 - int(game.scroll_x)) % (win_w + 40) - 20
		sdl.render_draw_line(renderer, sx, gy + 14, sx + 14, gy + int(ground_height))
	}

	// 4. Flappy Bird
	draw_flappy_bird(renderer, game.bird.x, game.bird.y, game.bird.angle, game.bird.wing_frame)

	// 5. HUD Score in Playing state
	if game.state == .playing || game.state == .ready {
		draw_text_centered(renderer, win_w / 2, 45, '${game.score}', 5, Color{r: 255, g: 255, b: 255})
	}

	// Ready Tutorial Overlay
	if game.state == .ready {
		draw_text_centered(renderer, win_w / 2, 180, 'FLAPPY BIRD', 4, Color{r: 255, g: 215, b: 0})
		draw_text_centered(renderer, win_w / 2, 230, 'PRO EDITION', 2, Color{r: 255, g: 255, b: 255})
		draw_text_centered(renderer, win_w / 2, 380, 'PRESS [SPACE] OR [CLICK]', 2, Color{r: 20, g: 50, b: 80})
		draw_text_centered(renderer, win_w / 2, 410, 'TO FLAP WINGS', 2, Color{r: 20, g: 50, b: 80})
	}

	// Game Over Scoreboard
	if game.state == .game_over {
		// Dim overlay
		sdl.set_render_draw_color(renderer, 0, 0, 0, 120)
		sdl.render_fill_rect(renderer, &sdl.Rect{x: 0, y: 0, w: win_w, h: win_h})

		// Score Card Box
		bx := (win_w - 320) / 2
		by := 170
		bw := 320
		bh := 240

		sdl.set_render_draw_color(renderer, 235, 215, 160, 255)
		sdl.render_fill_rect(renderer, &sdl.Rect{x: bx, y: by, w: bw, h: bh})
		sdl.set_render_draw_color(renderer, 120, 80, 40, 255)
		sdl.render_draw_rect(renderer, &sdl.Rect{x: bx, y: by, w: bw, h: bh})

		draw_text_centered(renderer, win_w / 2, by + 20, 'GAME OVER', 3, Color{r: 220, g: 60, b: 40})

		// Score
		draw_text(renderer, bx + 170, by + 75, 'SCORE', 2, Color{r: 180, g: 110, b: 40})
		draw_text(renderer, bx + 170, by + 100, '${game.score}', 3, Color{r: 20, g: 20, b: 20})

		// Best Score
		draw_text(renderer, bx + 170, by + 140, 'BEST', 2, Color{r: 180, g: 110, b: 40})
		draw_text(renderer, bx + 170, by + 165, '${game.best_score}', 3, Color{r: 20, g: 20, b: 20})

		// Medal Box (Left side of card)
		draw_text(renderer, bx + 30, by + 75, 'MEDAL', 2, Color{r: 180, g: 110, b: 40})
		medal_cx := bx + 65
		medal_cy := by + 135
		medal_tier := game.get_medal()

		// Medal Circle
		medal_color := match medal_tier {
			.platinum { Color{r: 220, g: 240, b: 255} }
			.gold { Color{r: 255, g: 215, b: 0} }
			.silver { Color{r: 200, g: 200, b: 210} }
			.bronze { Color{r: 205, g: 127, b: 50} }
			.none { Color{r: 180, g: 160, b: 130} }
		}
		sdl.set_render_draw_color(renderer, medal_color.r, medal_color.g, medal_color.b, 255)
		for dy := -24; dy <= 24; dy++ {
			dx_max := int(math.sqrt(f64(576 - dy * dy)))
			sdl.render_draw_line(renderer, medal_cx - dx_max, medal_cy + dy, medal_cx + dx_max, medal_cy + dy)
		}
		sdl.set_render_draw_color(renderer, 100, 70, 30, 255)
		sdl.render_draw_rect(renderer, &sdl.Rect{x: medal_cx - 24, y: medal_cy - 24, w: 48, h: 48})

		// Restart Button Text
		draw_text_centered(renderer, win_w / 2, by + bh + 30, 'PRESS [SPACE] TO RETRY', 2, Color{r: 255, g: 255, b: 255})
	}

	sdl.render_present(renderer)
}
