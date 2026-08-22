module main

import math
import sdl

pub fn render_memory_match(renderer &sdl.Renderer, game &MemoryGame, screen_w int, screen_h int, hover_idx int) {
	// 1. Background: Deep royal navy with subtle ambient vignette
	sdl.set_render_draw_color(renderer, 15, 20, 34, 255)
	sdl.render_clear(renderer)

	// Background grid lines
	sdl.set_render_draw_color(renderer, 24, 30, 50, 255)
	for y := 60; y < screen_h; y += 40 {
		sdl.render_draw_line(renderer, 0, y, screen_w, y)
	}
	for x := 0; x < screen_w; x += 40 {
		sdl.render_draw_line(renderer, x, 60, x, screen_h)
	}

	// 2. Top Header HUD
	hud_h := 54
	sdl.set_render_draw_color(renderer, 12, 16, 28, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{x: 0, y: 0, w: screen_w, h: hud_h})
	sdl.set_render_draw_color(renderer, 45, 60, 100, 255)
	sdl.render_draw_line(renderer, 0, hud_h, screen_w, hud_h)

	draw_text(renderer, 20, 18, 'MEMORY MATCH', 2, Color{r: 255, g: 215, b: 0})

	mode_name := match game.grid_mode {
		.grid_4x4 { '4X4 (8 PAIRS)' }
		.grid_6x4 { '6X4 (12 PAIRS)' }
		.grid_6x6 { '6X6 (18 PAIRS)' }
	}
	draw_text(renderer, 225, 22, '[G] ${mode_name}', 1, Color{r: 140, g: 200, b: 255})

	draw_text(renderer, 380, 18, 'TURNS: ${game.turns}', 2, Color{r: 255, g: 255, b: 255})
	draw_text(renderer, 530, 18, 'PAIRS: ${game.matches}/${game.total_pairs}', 2, Color{r: 100, g: 255, b: 150})

	sec := int(game.timer)
	time_str := '${sec / 60:02d}:${sec % 60:02d}'
	draw_text(renderer, 710, 18, 'TIME: ${time_str}', 2, Color{r: 255, g: 220, b: 60})

	// 3. Calculate Dynamic Card Layout Grid
	board_y := 70
	avail_w := screen_w - 60
	avail_h := screen_h - board_y - 45

	card_w := math.min(int(avail_w / game.cols) - 12, 100)
	card_h := math.min(int(avail_h / game.rows) - 12, 110)

	total_grid_w := game.cols * (card_w + 12) - 12
	total_grid_h := game.rows * (card_h + 12) - 12
	start_x := (screen_w - total_grid_w) / 2
	start_y := board_y + (avail_h - total_grid_h) / 2

	for row in 0 .. game.rows {
		for col in 0 .. game.cols {
			idx := row * game.cols + col
			if idx >= game.cards.len { continue }

			card := game.cards[idx]
			mut cx := start_x + col * (card_w + 12)
			cy := start_y + row * (card_h + 12)

			// Shake offset on mismatch
			if card.shake_timer > 0.0 {
				cx += int(math.sin(card.shake_timer * 40.0) * 5.0)
			}

			is_hover := hover_idx == idx && !card.is_face_up && !card.is_matched

			draw_card_3d(renderer, &card, cx, cy, card_w, card_h, is_hover)
		}
	}

	// 4. Footer Controls Hint
	draw_text_centered(renderer, screen_w / 2, screen_h - 22, '[LEFT CLICK] FLIP CARD  [G] GRID MODE  [R] NEW GAME  [S] SOUND', 1, Color{r: 160, g: 180, b: 220})

	// 5. Victory Modal Overlay
	if game.state == .game_won {
		sdl.set_render_draw_color(renderer, 0, 0, 0, 190)
		sdl.render_fill_rect(renderer, &sdl.Rect{x: 0, y: 0, w: screen_w, h: screen_h})

		mw := 500
		mh := 280
		mx := (screen_w - mw) / 2
		my := (screen_h - mh) / 2
		m_rect := sdl.Rect{x: mx, y: my, w: mw, h: mh}

		sdl.set_render_draw_color(renderer, 20, 26, 48, 255)
		sdl.render_fill_rect(renderer, &m_rect)
		sdl.set_render_draw_color(renderer, 70, 120, 240, 255)
		sdl.render_draw_rect(renderer, &m_rect)

		draw_text_centered(renderer, screen_w / 2, my + 24, 'GRID CLEARED!', 3, Color{r: 255, g: 215, b: 0})

		// Render Star Rating
		for s in 0 .. 3 {
			star_x := screen_w / 2 - 40 + s * 40
			star_col := if s < game.stars { Color{r: 255, g: 215, b: 0} } else { Color{r: 60, g: 65, b: 80} }
			draw_star_icon(renderer, star_x, my + 80, 14, star_col)
		}

		draw_text_centered(renderer, screen_w / 2, my + 120, 'TOTAL TURNS: ${game.turns}', 2, Color{r: 255, g: 255, b: 255})
		draw_text_centered(renderer, screen_w / 2, my + 150, 'CLEAR TIME: ${time_str}', 2, Color{r: 100, g: 255, b: 180})
		draw_text_centered(renderer, screen_w / 2, my + 180, 'MAX COMBO: ${game.max_combo}X', 2, Color{r: 255, g: 200, b: 60})

		draw_text_centered(renderer, screen_w / 2, my + 230, 'PRESS [SPACE] OR [R] TO PLAY AGAIN', 1, Color{r: 140, g: 200, b: 255})
	}

	sdl.render_present(renderer)
}

fn draw_card_3d(renderer &sdl.Renderer, card &Card, cx int, cy int, w int, h int, is_hover bool) {
	// 3D horizontal perspective cosine scaling
	// flip_progress: 0.0 (back) to 1.0 (front)
	angle := card.flip_progress * math.pi
	scale_x := math.abs(math.cos(angle))
	is_front := math.cos(angle) < 0.0 || card.flip_progress >= 0.5

	cur_w := math.max(int(f64(w) * scale_x), 4)
	offset_x := (w - cur_w) / 2
	rx := cx + offset_x

	card_rect := sdl.Rect{x: rx, y: cy, w: cur_w, h: h}

	if card.is_matched {
		// Matched card: Soft golden halo translucent card
		sdl.set_render_draw_color(renderer, 24, 38, 55, 255)
		sdl.render_fill_rect(renderer, &card_rect)
		sdl.set_render_draw_color(renderer, 80, 200, 120, 255)
		sdl.render_draw_rect(renderer, &card_rect)
		if cur_w > 20 {
			draw_card_icon(renderer, card.icon, rx + cur_w / 2, cy + h / 2, cur_w)
		}
		return
	}

	if is_front {
		// Front of card (Ivory / Platinum tile with glowing icon)
		sdl.set_render_draw_color(renderer, 235, 240, 250, 255)
		sdl.render_fill_rect(renderer, &card_rect)

		// Border & Bevel
		sdl.set_render_draw_color(renderer, 160, 175, 205, 255)
		sdl.render_draw_rect(renderer, &card_rect)

		inner_rect := sdl.Rect{x: rx + 4, y: cy + 4, w: cur_w - 8, h: h - 8}
		sdl.set_render_draw_color(renderer, 215, 225, 240, 255)
		sdl.render_draw_rect(renderer, &inner_rect)

		if cur_w > 20 {
			draw_card_icon(renderer, card.icon, rx + cur_w / 2, cy + h / 2, cur_w)
		}
	} else {
		// Back of card (Deep sapphire metallic with gold circuit pattern)
		base_b := if is_hover { 75 } else { 55 }
		sdl.set_render_draw_color(renderer, 25, 38, u8(base_b), 255)
		sdl.render_fill_rect(renderer, &card_rect)

		border_col := if is_hover { Color{r: 255, g: 215, b: 0} } else { Color{r: 50, g: 80, b: 140} }
		sdl.set_render_draw_color(renderer, border_col.r, border_col.g, border_col.b, 255)
		sdl.render_draw_rect(renderer, &card_rect)

		// Inner diamond geometric pattern on card back
		if cur_w > 24 {
			mid_x := rx + cur_w / 2
			mid_y := cy + h / 2
			dw := cur_w / 3
			dh := h / 4

			sdl.set_render_draw_color(renderer, 220, 180, 50, 200)
			sdl.render_draw_line(renderer, mid_x, mid_y - dh, mid_x + dw, mid_y)
			sdl.render_draw_line(renderer, mid_x + dw, mid_y, mid_x, mid_y + dh)
			sdl.render_draw_line(renderer, mid_x, mid_y + dh, mid_x - dw, mid_y)
			sdl.render_draw_line(renderer, mid_x - dw, mid_y, mid_x, mid_y - dh)
		}
	}
}

fn draw_card_icon(renderer &sdl.Renderer, icon CardIcon, icx int, icy int, cw int) {
	scale := math.min(f64(cw) / 70.0, 1.0)
	rad := int(16.0 * scale)

	match icon {
		.gem {
			// Cyan Crystal Gem
			sdl.set_render_draw_color(renderer, 40, 210, 240, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad, y: icy - rad / 2, w: rad * 2, h: rad})
			sdl.set_render_draw_color(renderer, 180, 250, 255, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad / 2, y: icy - rad, w: rad, h: rad * 2})
		}
		.crown {
			// Gold Crown
			sdl.set_render_draw_color(renderer, 255, 200, 30, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad, y: icy + rad / 4, w: rad * 2, h: rad / 2})
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad, y: icy - rad / 2, w: rad / 3, h: rad})
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad / 6, y: icy - rad / 2 - 4, w: rad / 3, h: rad + 4})
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx + rad * 2 / 3, y: icy - rad / 2, w: rad / 3, h: rad})
		}
		.star {
			draw_star_icon(renderer, icx, icy, rad, Color{r: 255, g: 215, b: 0})
		}
		.key {
			// Gold Key
			sdl.set_render_draw_color(renderer, 240, 190, 40, 255)
			fill_circ(renderer, icx - rad / 2, icy, rad / 2)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad / 2, y: icy - 2, w: rad + 6, h: 4})
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx + rad / 2, y: icy - 2, w: 4, h: 8})
		}
		.potion {
			// Ruby Potion Flask
			sdl.set_render_draw_color(renderer, 230, 40, 60, 255)
			fill_circ(renderer, icx, icy + 4, rad * 3 / 4)
			sdl.set_render_draw_color(renderer, 200, 150, 70, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 3, y: icy - rad, w: 6, h: 8})
		}
		.fire {
			// Flame
			sdl.set_render_draw_color(renderer, 255, 120, 20, 255)
			fill_circ(renderer, icx, icy + 4, rad * 3 / 4)
			sdl.set_render_draw_color(renderer, 255, 220, 40, 255)
			fill_circ(renderer, icx, icy + 4, rad / 2)
		}
		.lightning {
			// Lightning Bolt
			sdl.set_render_draw_color(renderer, 255, 235, 40, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 3, y: icy - rad, w: 6, h: rad})
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 8, y: icy - 2, w: 16, h: 4})
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 3, y: icy, w: 6, h: rad})
		}
		.heart {
			// Crimson Heart
			sdl.set_render_draw_color(renderer, 235, 40, 60, 255)
			fill_circ(renderer, icx - rad / 3, icy - rad / 4, rad / 2)
			fill_circ(renderer, icx + rad / 3, icy - rad / 4, rad / 2)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad / 2, y: icy, w: rad, h: rad / 2})
		}
		.crescent {
			// Silver Glowing Moon
			sdl.set_render_draw_color(renderer, 220, 230, 255, 255)
			fill_circ(renderer, icx, icy, rad)
			sdl.set_render_draw_color(renderer, 235, 240, 250, 255)
			fill_circ(renderer, icx + rad / 3, icy - rad / 4, rad * 3 / 4)
		}
		.atom {
			// Cyan Atomic Rings
			sdl.set_render_draw_color(renderer, 40, 220, 240, 255)
			fill_circ(renderer, icx, icy, 4)
			draw_circ(renderer, icx, icy, rad)
		}
		.rocket {
			// Silver Rocket
			sdl.set_render_draw_color(renderer, 200, 210, 225, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 4, y: icy - rad, w: 8, h: rad * 2})
			sdl.set_render_draw_color(renderer, 240, 40, 40, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 8, y: icy + rad / 2, w: 16, h: 4})
		}
		.shield {
			// Knight Shield
			sdl.set_render_draw_color(renderer, 70, 130, 220, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad * 3 / 4, y: icy - rad, w: rad * 3 / 2, h: rad * 3 / 2})
			sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
			sdl.render_draw_line(renderer, icx, icy - rad, icx, icy + rad / 2)
		}
		.diamond {
			sdl.set_render_draw_color(renderer, 60, 180, 255, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad / 2, y: icy - rad / 2, w: rad, h: rad})
		}
		.coin {
			sdl.set_render_draw_color(renderer, 255, 210, 30, 255)
			fill_circ(renderer, icx, icy, rad * 3 / 4)
			sdl.set_render_draw_color(renderer, 180, 130, 20, 255)
			draw_circ(renderer, icx, icy, rad / 2)
		}
		.music {
			sdl.set_render_draw_color(renderer, 200, 60, 220, 255)
			fill_circ(renderer, icx - 6, icy + 6, 4)
			fill_circ(renderer, icx + 6, icy + 4, 4)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 4, y: icy - 8, w: 3, h: 14})
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx + 8, y: icy - 10, w: 3, h: 14})
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 4, y: icy - 10, w: 15, h: 4})
		}
		.clover {
			sdl.set_render_draw_color(renderer, 40, 200, 60, 255)
			fill_circ(renderer, icx - 4, icy - 4, 5)
			fill_circ(renderer, icx + 4, icy - 4, 5)
			fill_circ(renderer, icx - 4, icy + 4, 5)
			fill_circ(renderer, icx + 4, icy + 4, 5)
		}
		.bell {
			sdl.set_render_draw_color(renderer, 255, 200, 40, 255)
			fill_circ(renderer, icx, icy, rad * 2 / 3)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - rad * 3 / 4, y: icy + 2, w: rad * 3 / 2, h: 4})
		}
		.skull {
			sdl.set_render_draw_color(renderer, 220, 225, 235, 255)
			fill_circ(renderer, icx, icy - 2, rad * 2 / 3)
			sdl.render_fill_rect(renderer, &sdl.Rect{x: icx - 4, y: icy + 4, w: 8, h: 6})
			sdl.set_render_draw_color(renderer, 20, 20, 25, 255)
			fill_circ(renderer, icx - 3, icy - 2, 2)
			fill_circ(renderer, icx + 3, icy - 2, 2)
		}
	}
}

fn draw_star_icon(renderer &sdl.Renderer, cx int, cy int, radius int, col Color) {
	sdl.set_render_draw_color(renderer, col.r, col.g, col.b, 255)
	fill_circ(renderer, cx, cy, radius / 2)
	sdl.render_fill_rect(renderer, &sdl.Rect{x: cx - radius, y: cy - 2, w: radius * 2, h: 4})
	sdl.render_fill_rect(renderer, &sdl.Rect{x: cx - 2, y: cy - radius, w: 4, h: radius * 2})
}

fn fill_circ(renderer &sdl.Renderer, cx int, cy int, radius int) {
	for y := -radius; y <= radius; y++ {
		for x := -radius; x <= radius; x++ {
			if x * x + y * y <= radius * radius {
				sdl.render_draw_point(renderer, cx + x, cy + y)
			}
		}
	}
}

fn draw_circ(renderer &sdl.Renderer, cx int, cy int, radius int) {
	for deg := 0.0; deg < 360.0; deg += 3.0 {
		rad := (deg * math.pi) / 180.0
		x := cx + int(f64(radius) * math.cos(rad))
		y := cy + int(f64(radius) * math.sin(rad))
		sdl.render_draw_point(renderer, x, y)
	}
}

pub fn get_card_index_at(mx int, my int, game &MemoryGame, screen_w int, screen_h int) int {
	board_y := 70
	avail_w := screen_w - 60
	avail_h := screen_h - board_y - 45

	card_w := math.min(int(avail_w / game.cols) - 12, 100)
	card_h := math.min(int(avail_h / game.rows) - 12, 110)

	total_grid_w := game.cols * (card_w + 12) - 12
	total_grid_h := game.rows * (card_h + 12) - 12
	start_x := (screen_w - total_grid_w) / 2
	start_y := board_y + (avail_h - total_grid_h) / 2

	for row in 0 .. game.rows {
		for col in 0 .. game.cols {
			idx := row * game.cols + col
			if idx >= game.cards.len { continue }

			cx := start_x + col * (card_w + 12)
			cy := start_y + row * (card_h + 12)

			if mx >= cx && mx <= cx + card_w && my >= cy && my <= cy + card_h {
				return idx
			}
		}
	}
	return -1
}
