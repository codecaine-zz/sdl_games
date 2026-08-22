module main

import math
import sdl

pub fn render_simon_console(renderer &sdl.Renderer, game &SimonGame, screen_w int, screen_h int, mouse_x int, mouse_y int) {
	// Background: Sleek dark retro-futuristic arcade console
	sdl.set_render_draw_color(renderer, 16, 18, 26, 255)
	sdl.render_clear(renderer)

	// Subtle radial grid background lines
	sdl.set_render_draw_color(renderer, 24, 28, 42, 255)
	for r := 80; r < 500; r += 60 {
		draw_circle(renderer, screen_w / 2, screen_h / 2 + 10, r)
	}

	cx := screen_w / 2
	cy := screen_h / 2 + 10
	outer_rad := 200
	inner_rad := 85

	// 1. Outer Console Chasis (Heavy dark metallic disc)
	sdl.set_render_draw_color(renderer, 28, 30, 38, 255)
	fill_circle(renderer, cx, cy, outer_rad + 24)

	sdl.set_render_draw_color(renderer, 45, 48, 60, 255)
	fill_circle(renderer, cx, cy, outer_rad + 14)

	sdl.set_render_draw_color(renderer, 12, 14, 20, 255)
	fill_circle(renderer, cx, cy, outer_rad + 4)

	// 2. Draw the 4 Quadrant Pads
	// Pad 0: Green (Top-Left, angle 180 to 270)
	// Pad 1: Red (Top-Right, angle 270 to 360)
	// Pad 2: Yellow (Bottom-Left, angle 90 to 180)
	// Pad 3: Blue (Bottom-Right, angle 0 to 90)

	pad_colors_off := [
		Color{r: 20, g: 110, b: 40},   // Green Off
		Color{r: 150, g: 25, b: 35},   // Red Off
		Color{r: 160, g: 135, b: 20},  // Yellow Off
		Color{r: 20, g: 55, b: 150},   // Blue Off
	]

	pad_colors_lit := [
		Color{r: 60, g: 255, b: 90},   // Green Lit
		Color{r: 255, g: 60, b: 70},   // Red Lit
		Color{r: 255, g: 240, b: 60},  // Yellow Lit
		Color{r: 60, g: 160, b: 255},  // Blue Lit
	]

	for pad_idx in 0 .. 4 {
		is_lit := game.lit_pad == pad_idx
		base_col := if is_lit { pad_colors_lit[pad_idx] } else { pad_colors_off[pad_idx] }

		draw_quadrant_pad(renderer, cx, cy, inner_rad, outer_rad, pad_idx, base_col, is_lit)
	}

	// 3. Black Separator Cross Spoke Lines
	sdl.set_render_draw_color(renderer, 15, 16, 22, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{x: cx - 6, y: cy - outer_rad - 6, w: 12, h: (outer_rad + 6) * 2})
	sdl.render_fill_rect(renderer, &sdl.Rect{x: cx - outer_rad - 6, y: cy - 6, w: (outer_rad + 6) * 2, h: 12})

	// 4. Center Console Hub (Dark metallic circle)
	sdl.set_render_draw_color(renderer, 32, 35, 45, 255)
	fill_circle(renderer, cx, cy, inner_rad + 4)

	sdl.set_render_draw_color(renderer, 18, 20, 28, 255)
	fill_circle(renderer, cx, cy, inner_rad)

	sdl.set_render_draw_color(renderer, 50, 55, 75, 255)
	draw_circle(renderer, cx, cy, inner_rad)

	// Center Logo & LED Score Display
	draw_text_centered(renderer, cx, cy - 58, 'CYBER SIMON', 1, Color{r: 255, g: 215, b: 0})

	// 7-Segment Style LED Box
	led_rect := sdl.Rect{x: cx - 42, y: cy - 36, w: 84, h: 36}
	sdl.set_render_draw_color(renderer, 8, 10, 16, 255)
	sdl.render_fill_rect(renderer, &led_rect)
	sdl.set_render_draw_color(renderer, 45, 50, 68, 255)
	sdl.render_draw_rect(renderer, &led_rect)

	score_str := if game.sequence.len > 0 { '${game.sequence.len}' } else { '--' }
	draw_text_centered(renderer, cx, cy - 28, score_str, 2, Color{r: 255, g: 50, b: 50})

	// Status Prompt text inside hub
	status_text := match game.state {
		.attract { 'PRESS SPACE' }
		.playback { 'LISTEN...' }
		.player_turn { 'REPEAT!' }
		.round_success { 'PERFECT!' }
		.game_over { 'GAME OVER' }
	}
	status_col := match game.state {
		.playback { Color{r: 255, g: 200, b: 60} }
		.player_turn { Color{r: 60, g: 240, b: 120} }
		.round_success { Color{r: 80, g: 220, b: 255} }
		.game_over { Color{r: 255, g: 60, b: 60} }
		else { Color{r: 180, g: 190, b: 220} }
	}
	draw_text_centered(renderer, cx, cy + 12, status_text, 1, status_col)

	// Mode Pill inside hub
	mode_label := match game.mode {
		.classic { 'CLASSIC' }
		.reverse { 'REVERSE' }
		.speed { 'SPEED' }
	}
	draw_text_centered(renderer, cx, cy + 34, '[M] ${mode_label}', 1, Color{r: 140, g: 180, b: 240})

	// 5. Pad Keyboard Labels on outer ring
	draw_text_centered(renderer, cx - 130, cy - 130, '[Q / 1]', 1, Color{r: 140, g: 255, b: 160})
	draw_text_centered(renderer, cx + 130, cy - 130, '[W / 2]', 1, Color{r: 255, g: 140, b: 150})
	draw_text_centered(renderer, cx - 130, cy + 120, '[A / 3]', 1, Color{r: 255, g: 240, b: 140})
	draw_text_centered(renderer, cx + 130, cy + 120, '[S / 4]', 1, Color{r: 140, g: 200, b: 255})

	// 6. Top Header & High Scores Bar
	hud_h := 48
	sdl.set_render_draw_color(renderer, 12, 14, 22, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{x: 0, y: 0, w: screen_w, h: hud_h})
	sdl.set_render_draw_color(renderer, 45, 50, 75, 255)
	sdl.render_draw_line(renderer, 0, hud_h, screen_w, hud_h)

	draw_text(renderer, 24, 16, 'CYBER SIMON', 2, Color{r: 255, g: 215, b: 0})

	cur_hs := match game.mode {
		.classic { game.high_score_classic }
		.reverse { game.high_score_reverse }
		.speed { game.high_score_speed }
	}
	draw_text(renderer, screen_w - 340, 16, 'BEST: ${cur_hs}  STREAK: ${game.streak}', 2, Color{r: 200, g: 220, b: 255})

	// 7. Bottom Instructions Footer
	footer_y := screen_h - 28
	draw_text_centered(renderer, screen_w / 2, footer_y, '[CLICK/KEYS 1-4/Q-S] PLAY PAD  [SPACE] START  [M] MODE  [R] RESET  [S] SOUND', 1, Color{r: 160, g: 175, b: 210})

	sdl.render_present(renderer)
}

fn draw_quadrant_pad(renderer &sdl.Renderer, cx int, cy int, inner_r int, outer_r int, quad int, col Color, is_lit bool) {
	// Sample angle range for quadrant
	// quad 0: top-left (180 to 270)
	// quad 1: top-right (270 to 360)
	// quad 2: bottom-left (90 to 180)
	// quad 3: bottom-right (0 to 90)

	start_deg := match quad {
		0 { 182.0 }
		1 { 272.0 }
		2 { 92.0 }
		else { 2.0 }
	}
	end_deg := start_deg + 86.0

	for r := inner_r + 4; r <= outer_r; r++ {
		for deg := start_deg; deg <= end_deg; deg += 0.4 {
			rad := (deg * math.pi) / 180.0
			px := cx + int(f64(r) * math.cos(rad))
			py := cy + int(f64(r) * math.sin(rad))

			// Lighting intensity gradient
			brightness := if is_lit {
				dist_from_mid := math.abs(f64(r) - f64(inner_r + outer_r) / 2.0) / f64(outer_r - inner_r)
				1.15 - dist_from_mid * 0.25
			} else {
				0.85
			}

			r_val := u8(math.clamp(f64(col.r) * brightness, 0.0, 255.0))
			g_val := u8(math.clamp(f64(col.g) * brightness, 0.0, 255.0))
			b_val := u8(math.clamp(f64(col.b) * brightness, 0.0, 255.0))

			sdl.set_render_draw_color(renderer, r_val, g_val, b_val, 255)
			sdl.render_draw_point(renderer, px, py)
		}
	}
}

fn fill_circle(renderer &sdl.Renderer, cx int, cy int, radius int) {
	for y := -radius; y <= radius; y++ {
		for x := -radius; x <= radius; x++ {
			if x * x + y * y <= radius * radius {
				sdl.render_draw_point(renderer, cx + x, cy + y)
			}
		}
	}
}

fn draw_circle(renderer &sdl.Renderer, cx int, cy int, radius int) {
	for deg := 0.0; deg < 360.0; deg += 1.0 {
		rad := (deg * math.pi) / 180.0
		x := cx + int(f64(radius) * math.cos(rad))
		y := cy + int(f64(radius) * math.sin(rad))
		sdl.render_draw_point(renderer, x, y)
	}
}

pub fn get_pad_under_mouse(cx int, cy int, inner_r int, outer_r int, mx int, my int) int {
	dx := mx - cx
	dy := my - cy
	dist_sq := dx * dx + dy * dy
	if dist_sq < (inner_r + 4) * (inner_r + 4) || dist_sq > outer_r * outer_r {
		return -1
	}

	// Calculate angle in degrees [0..360)
	mut angle := (math.atan2(f64(dy), f64(dx)) * 180.0) / math.pi
	if angle < 0.0 {
		angle += 360.0
	}

	if angle >= 180.0 && angle < 270.0 {
		return 0 // Green (Top-Left)
	} else if angle >= 270.0 && angle < 360.0 {
		return 1 // Red (Top-Right)
	} else if angle >= 90.0 && angle < 180.0 {
		return 2 // Yellow (Bottom-Left)
	} else if angle >= 0.0 && angle < 90.0 {
		return 3 // Blue (Bottom-Right)
	}
	return -1
}
