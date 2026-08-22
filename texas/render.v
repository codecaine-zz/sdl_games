module main

import sdl

fn draw_texas_game(renderer &sdl.Renderer, g &TexasGame) {
	// Deep Casino Floor Carpet
	sdl.set_render_draw_color(renderer, 15, 20, 30, 255)
	sdl.render_clear(renderer)

	draw_poker_table(renderer, g)
	draw_community_cards(renderer, g)
	draw_player_seats(renderer, g)
	draw_control_panel(renderer, g)

	if g.celebration != '' {
		draw_celebration_banner(renderer, g)
	}
}

fn draw_poker_table(renderer &sdl.Renderer, g &TexasGame) {
	// Oval Table (Wood Rail + Green Felt)
	rx := 60
	ry := 60
	rw := 680
	rh := 440

	// Outer Padded Rail (Dark Mahogany)
	sdl.set_render_draw_color(renderer, 50, 22, 14, 255)
	rail := sdl.Rect{ x: rx, y: ry, w: rw, h: rh }
	sdl.render_fill_rect(renderer, &rail)
	sdl.set_render_draw_color(renderer, 220, 180, 50, 255)
	sdl.render_draw_rect(renderer, &rail)

	// Inner Felt (Emerald Green)
	sdl.set_render_draw_color(renderer, 18, 70, 38, 255)
	felt := sdl.Rect{ x: rx + 14, y: ry + 14, w: rw - 28, h: rh - 28 }
	sdl.render_fill_rect(renderer, &felt)

	// Felt Logo & Pot Display
	draw_text_centered(renderer, 400, 190, '★ TEXAS HOLD\'EM NO-LIMIT ★', 1, Color{ r: 240, g: 215, b: 60 })
	draw_text_centered(renderer, 400, 215, 'MAIN POT: $$${g.pot}', 2, Color{ r: 255, g: 255, b: 255 })
}

fn draw_community_cards(renderer &sdl.Renderer, g &TexasGame) {
	card_w := 54
	card_h := 78
	cy := 245
	start_x := 400 - (5 * 62 - 8) / 2

	for i := 0; i < 5; i++ {
		cx := start_x + i * 62
		if i < g.community_cards.len {
			draw_poker_card(renderer, cx, cy, card_w, card_h, g.community_cards[i])
		} else {
			// Empty Card Placeholder
			sdl.set_render_draw_color(renderer, 12, 50, 26, 255)
			bg := sdl.Rect{ x: cx, y: cy, w: card_w, h: card_h }
			sdl.render_fill_rect(renderer, &bg)
			sdl.set_render_draw_color(renderer, 40, 110, 60, 255)
			sdl.render_draw_rect(renderer, &bg)
		}
	}
}

fn draw_player_seats(renderer &sdl.Renderer, g &TexasGame) {
	// Seat Coordinates: 0: Bottom (Human), 1: Left, 2: Top, 3: Right
	seat_pos := [
		[400, 420], // 0: Bottom
		[130, 260], // 1: Left
		[400, 100], // 2: Top
		[670, 260], // 3: Right
	]

	for i, p in g.players {
		sx := seat_pos[i][0]
		sy := seat_pos[i][1]
		is_turn := i == g.current_turn_idx && g.stage != .showdown && g.stage != .round_over
		is_dealer := i == g.dealer_idx

		draw_player_pod(renderer, sx, sy, p, is_turn, is_dealer, g.stage == .showdown || g.stage == .round_over)
	}
}

fn draw_player_pod(renderer &sdl.Renderer, cx int, cy int, p PokerPlayer, is_turn bool, is_dealer bool, is_showdown bool) {
	w := 140
	h := 75
	x := cx - w / 2
	y := cy - h / 2

	// Pod Background
	bg_col := if is_turn { Color{ r: 40, g: 60, b: 90 } } else { Color{ r: 20, g: 25, b: 35 } }
	sdl.set_render_draw_color(renderer, bg_col.r, bg_col.g, bg_col.b, 240)
	pod := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.render_fill_rect(renderer, &pod)

	border_col := if is_turn { Color{ r: 255, g: 215, b: 0 } } else { Color{ r: 120, g: 130, b: 150 } }
	sdl.set_render_draw_color(renderer, border_col.r, border_col.g, border_col.b, 255)
	sdl.render_draw_rect(renderer, &pod)

	// Name & Chip Count
	name_col := if p.is_folded { Color{ r: 120, g: 120, b: 120 } } else { Color{ r: 255, g: 255, b: 255 } }
	draw_text_centered(renderer, cx, y + 6, p.name, 1, name_col)
	draw_text_centered(renderer, cx, y + 18, '$$${p.chips}', 1, Color{ r: 255, g: 215, b: 50 })

	// Action status
	if p.last_action != '' {
		draw_text_centered(renderer, cx, y + 30, p.last_action, 1, Color{ r: 100, g: 220, b: 255 })
	}

	// Hole Cards
	card_w := 34
	card_h := 48
	if p.hole_cards.len == 2 {
		c1_x := cx - card_w - 2
		c2_x := cx + 2
		cards_y := y + 42

		if !p.is_ai || is_showdown {
			draw_poker_card(renderer, c1_x, cards_y, card_w, card_h, p.hole_cards[0])
			draw_poker_card(renderer, c2_x, cards_y, card_w, card_h, p.hole_cards[1])
		} else {
			draw_poker_card_back(renderer, c1_x, cards_y, card_w, card_h)
			draw_poker_card_back(renderer, c2_x, cards_y, card_w, card_h)
		}
	}

	// Dealer Button Token
	if is_dealer {
		db_x := x - 12
		db_y := y + 10
		draw_filled_circle(renderer, db_x, db_y, 10, Color{ r: 255, g: 255, b: 255 })
		draw_text_centered(renderer, db_x, db_y - 4, 'D', 1, Color{ r: 200, g: 20, b: 30 })
	}
}

fn draw_poker_card(renderer &sdl.Renderer, x int, y int, w int, h int, c Card) {
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 252, 252, 255, 255)
	sdl.render_fill_rect(renderer, &bg)

	sdl.set_render_draw_color(renderer, 20, 20, 30, 255)
	sdl.render_draw_rect(renderer, &bg)

	is_red := c.suit == .hearts || c.suit == .diamonds
	col := if is_red { Color{ r: 215, g: 25, b: 35 } } else { Color{ r: 20, g: 20, b: 30 } }

	rank_s := match c.rank {
		14 { 'A' }
		13 { 'K' }
		12 { 'Q' }
		11 { 'J' }
		10 { '10' }
		else { '${c.rank}' }
	}
	suit_s := match c.suit {
		.hearts { 'H' }
		.diamonds { 'D' }
		.clubs { 'C' }
		.spades { 'S' }
	}

	draw_text(renderer, x + 3, y + 3, rank_s, 1, col)
	draw_text(renderer, x + 3, y + 11, suit_s, 1, col)

	if w >= 50 {
		draw_text_centered(renderer, x + w / 2, y + h / 2 - 8, rank_s, 2, col)
	}
}

fn draw_poker_card_back(renderer &sdl.Renderer, x int, y int, w int, h int) {
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 150, 25, 35, 255)
	sdl.render_fill_rect(renderer, &bg)
	sdl.set_render_draw_color(renderer, 240, 245, 255, 255)
	sdl.render_draw_rect(renderer, &bg)
}

fn draw_control_panel(renderer &sdl.Renderer, g &TexasGame) {
	bar_rect := sdl.Rect{ x: 20, y: 562, w: 760, h: 32 }
	sdl.set_render_draw_color(renderer, 10, 15, 25, 245)
	sdl.render_fill_rect(renderer, &bar_rect)
	sdl.set_render_draw_color(renderer, 220, 180, 50, 255)
	sdl.render_draw_rect(renderer, &bar_rect)

	p1 := g.players[0]
	is_my_turn := g.current_turn_idx == 0 && !p1.is_folded && !p1.is_all_in && g.stage != .showdown && g.stage != .round_over

	to_call := g.current_bet - p1.current_bet

	prompt_str := if is_my_turn {
		call_label := if to_call == 0 { 'CHECK' } else { 'CALL ($$${to_call})' }
		'[C] ${call_label} | [R] RAISE ($$${g.raise_amount}) | [UP/DN] ADJ BET | [F] FOLD | [A] ALL-IN'
	} else if g.stage == .round_over {
		'[SPACE/ENTER] DEAL NEXT HAND | [M] SOUND'
	} else {
		'OPPONENT IS THINKING... | [M] SOUND'
	}

	draw_text_centered(renderer, 400, 572, prompt_str, 1, Color{ r: 255, g: 235, b: 120 })
}

fn draw_celebration_banner(renderer &sdl.Renderer, g &TexasGame) {
	box_w := 580
	box_h := 50
	bx := (800 - box_w) / 2
	by := 160

	sdl.set_render_draw_color(renderer, 12, 18, 30, 250)
	b_rect := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
	sdl.render_fill_rect(renderer, &b_rect)

	sdl.set_render_draw_color(renderer, 255, 215, 50, 255)
	sdl.render_draw_rect(renderer, &b_rect)

	draw_text_centered(renderer, 400, by + 18, g.celebration, 1, Color{ r: 255, g: 230, b: 70 })
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
