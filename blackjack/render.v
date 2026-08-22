module main

import sdl

fn draw_blackjack_game(renderer &sdl.Renderer, g &BlackjackGame) {
	// Deep Casino Green Felt
	sdl.set_render_draw_color(renderer, 15, 62, 35, 255)
	sdl.render_clear(renderer)

	draw_table_felt_markings(renderer)
	draw_dealer_area(renderer, g)
	draw_player_hands_area(renderer, g)
	draw_betting_chips_area(renderer, g)
	draw_hud_and_controls(renderer, g)
}

fn draw_table_felt_markings(renderer &sdl.Renderer) {
	// Outer Mahogany Rim
	sdl.set_render_draw_color(renderer, 55, 25, 12, 255)
	rim := sdl.Rect{ x: 10, y: 10, w: 780, h: 580 }
	sdl.render_draw_rect(renderer, &rim)
	inner_rim := sdl.Rect{ x: 12, y: 12, w: 776, h: 576 }
	sdl.render_draw_rect(renderer, &inner_rim)

	// Gold Felt Arch
	sdl.set_render_draw_color(renderer, 220, 185, 50, 120)
	sdl.render_draw_line(renderer, 100, 260, 700, 260)

	// Printed Rules in Arch
	draw_text_centered(renderer, 400, 210, '★ BLACKJACK PAYS 3 TO 2 ★', 2, Color{ r: 255, g: 215, b: 50 })
	draw_text_centered(renderer, 400, 240, 'Dealer Must Draw to 16 and Stand on all 17s', 1, Color{ r: 230, g: 240, b: 210 })
	draw_text_centered(renderer, 400, 270, '★ INSURANCE PAYS 2 TO 1 ★', 1, Color{ r: 255, g: 215, b: 50 })
}

fn draw_dealer_area(renderer &sdl.Renderer, g &BlackjackGame) {
	dx := 400
	dy := 60
	card_w := 64
	card_h := 94

	draw_text_centered(renderer, dx, dy - 20, 'DEALER', 1, Color{ r: 240, g: 220, b: 150 })

	if g.dealer_hand.len > 0 {
		start_x := dx - (g.dealer_hand.len * 35 + card_w - 35) / 2

		for i, c in g.dealer_hand {
			cx := start_x + i * 35
			if i == 1 && g.dealer_hidden {
				draw_bj_card_back(renderer, cx, dy, card_w, card_h)
			} else {
				draw_bj_card(renderer, cx, dy, card_w, card_h, c)
			}
		}

		// Dealer Value Badge
		if !g.dealer_hidden {
			val, is_soft := calculate_hand_value(g.dealer_hand)
			val_str := if is_soft && val < 21 { 'SOFT ${val}' } else if val > 21 { 'BUST (${val})' } else { '${val}' }
			draw_text_centered(renderer, dx, dy + card_h + 10, 'Total: ${val_str}', 1, Color{ r: 255, g: 240, b: 180 })
		} else if g.dealer_hand.len > 0 {
			up_val, _ := calculate_hand_value([g.dealer_hand[0]])
			draw_text_centered(renderer, dx, dy + card_h + 10, 'Showing: ${up_val}', 1, Color{ r: 200, g: 220, b: 200 })
		}
	} else {
		// Empty Card placeholders
		draw_card_outline(renderer, dx - 40, dy, card_w, card_h)
		draw_card_outline(renderer, dx + 40 - card_w, dy, card_w, card_h)
	}
}

fn draw_player_hands_area(renderer &sdl.Renderer, g &BlackjackGame) {
	if g.player_hands.len == 0 {
		return
	}

	card_w := 64
	card_h := 94
	py := 320

	for h_idx, h in g.player_hands {
		// Hand center X
		hx := if g.player_hands.len == 1 { 400 } else { 280 + h_idx * 240 }
		start_x := hx - (h.cards.len * 30 + card_w - 30) / 2

		is_active := h_idx == g.active_hand_idx && g.state == .player_turn

		// Active Hand Spotlight Box
		if is_active {
			box := sdl.Rect{ x: hx - 80, y: py - 25, w: 160, h: card_h + 60 }
			sdl.set_render_draw_color(renderer, 255, 215, 0, 80)
			sdl.render_draw_rect(renderer, &box)
		}

		for i, c in h.cards {
			cx := start_x + i * 30
			draw_bj_card(renderer, cx, py, card_w, card_h, c)
		}

		// Hand Status / Value
		val, is_soft := calculate_hand_value(h.cards)
		val_str := if h.is_bj { 'BLACKJACK! (21)' } else if h.is_busted { 'BUST! (${val})' } else if is_soft && val < 21 { 'SOFT ${val}' } else { '${val}' }

		col := if is_active { Color{ r: 255, g: 220, b: 50 } } else { Color{ r: 220, g: 235, b: 255 } }
		draw_text_centered(renderer, hx, py + card_h + 8, 'Hand: ${val_str} ($$${h.bet})', 1, col)
	}
}

fn draw_betting_chips_area(renderer &sdl.Renderer, g &BlackjackGame) {
	// Center Betting Spot Circle
	bx := 400
	by := 460

	draw_circle_ring(renderer, bx, by, 36, 3, Color{ r: 220, g: 185, b: 50 })
	draw_text_centered(renderer, bx, by - 6, 'BET', 1, Color{ r: 240, g: 220, b: 150 })
	draw_text_centered(renderer, bx, by + 6, '$$${g.current_bet}', 1, Color{ r: 255, g: 255, b: 255 })

	// Chips Tray at bottom left
	chips_x := 80
	chips_y := 460
	chip_vals := [5, 25, 50, 100, 500]
	chip_cols := [
		Color{ r: 210, g: 30, b: 40 },   // Red $5
		Color{ r: 40, g: 160, b: 60 },   // Green $25
		Color{ r: 35, g: 90, b: 210 },   // Blue $50
		Color{ r: 30, g: 30, b: 40 },    // Black $100
		Color{ r: 160, g: 45, b: 180 },  // Purple $500
	]

	for i := 0; i < 5; i++ {
		cx := chips_x + i * 48
		draw_casino_chip(renderer, cx, chips_y, 18, chip_vals[i], chip_cols[i])
	}
}

fn draw_casino_chip(renderer &sdl.Renderer, cx int, cy int, r int, val int, c Color) {
	draw_filled_circle(renderer, cx, cy, r, c)
	draw_circle_ring(renderer, cx, cy, r - 3, 2, Color{ r: 255, g: 255, b: 255 })
	val_s := if val >= 500 { '500' } else if val >= 100 { '100' } else { '${val}' }
	draw_text_centered(renderer, cx, cy - 3, val_s, 1, Color{ r: 255, g: 255, b: 255 })
}

fn draw_bj_card(renderer &sdl.Renderer, x int, y int, w int, h int, c Card) {
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 252, 252, 255, 255)
	sdl.render_fill_rect(renderer, &bg)

	sdl.set_render_draw_color(renderer, 20, 20, 30, 255)
	sdl.render_draw_rect(renderer, &bg)

	is_red := c.suit == .hearts || c.suit == .diamonds
	col := if is_red { Color{ r: 210, g: 30, b: 40 } } else { Color{ r: 20, g: 20, b: 30 } }

	rank_s := match c.rank {
		1 { 'A' }
		11 { 'J' }
		12 { 'Q' }
		13 { 'K' }
		10 { '10' }
		else { '${c.rank}' }
	}
	suit_s := match c.suit {
		.hearts { 'H' }
		.diamonds { 'D' }
		.clubs { 'C' }
		.spades { 'S' }
	}

	draw_text(renderer, x + 4, y + 4, rank_s, 1, col)
	draw_text(renderer, x + 4, y + 14, suit_s, 1, col)

	draw_text_centered(renderer, x + w / 2, y + h / 2 - 10, rank_s, 2, col)
	draw_text_centered(renderer, x + w / 2, y + h / 2 + 8, suit_s, 1, col)
}

fn draw_bj_card_back(renderer &sdl.Renderer, x int, y int, w int, h int) {
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 160, 25, 35, 255)
	sdl.render_fill_rect(renderer, &bg)

	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	sdl.render_draw_rect(renderer, &bg)
	draw_text_centered(renderer, x + w / 2, y + h / 2 - 4, '21', 1, Color{ r: 255, g: 220, b: 50 })
}

fn draw_card_outline(renderer &sdl.Renderer, x int, y int, w int, h int) {
	rect := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 40, 100, 60, 180)
	sdl.render_draw_rect(renderer, &rect)
}

fn draw_hud_and_controls(renderer &sdl.Renderer, g &BlackjackGame) {
	// Top Header Balance & Stats
	draw_text(renderer, 30, 25, 'CHIPS: $$${g.chips} | WON: ${g.hands_won} | LOST: ${g.hands_lost} | BJ: ${g.blackjacks_hit}', 1, Color{ r: 240, g: 230, b: 180 })

	// Bottom Action Bar
	bar_rect := sdl.Rect{ x: 20, y: 566, w: 760, h: 28 }
	sdl.set_render_draw_color(renderer, 10, 35, 20, 240)
	sdl.render_fill_rect(renderer, &bar_rect)

	controls_str := match g.state {
		.betting { '[SPACE/ENTER] DEAL | [1-5] CHIPS (+$$5..$$500) | [C] CLEAR | [M] SOUND' }
		.player_turn { '[H] HIT | [S] STAND | [D] DOUBLE | [P] SPLIT | [I] INSURANCE' }
		else { '[SPACE/ENTER] NEXT HAND | [M] SOUND' }
	}
	draw_text_centered(renderer, 400, 574, controls_str, 1, Color{ r: 255, g: 235, b: 120 })

	// Center Announcement Banner
	if g.celebration != '' {
		box_w := 540
		box_h := 48
		bx := (800 - box_w) / 2
		by := 205

		sdl.set_render_draw_color(renderer, 12, 18, 30, 245)
		b_rect := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 255, 215, 50, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		draw_text_centered(renderer, 400, by + 16, g.celebration, 2, Color{ r: 255, g: 225, b: 60 })
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

fn draw_circle_ring(renderer &sdl.Renderer, cx int, cy int, r int, thickness int, c Color) {
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, c.a)
	r_outer := r + thickness / 2
	r_inner := r - thickness / 2
	for dy := -r_outer; dy <= r_outer; dy++ {
		for dx := -r_outer; dx <= r_outer; dx++ {
			d2 := dx * dx + dy * dy
			if d2 <= r_outer * r_outer && d2 >= r_inner * r_inner {
				sdl.render_draw_point(renderer, cx + dx, cy + dy)
			}
		}
	}
}
