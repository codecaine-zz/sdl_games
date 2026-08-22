module main

import math
import sdl

fn draw_texas_game(renderer &sdl.Renderer, g &TexasGame) {
	// Deep Casino Floor Carpet
	draw_casino_room_background(renderer)

	draw_poker_table(renderer, g)
	draw_community_cards(renderer, g)
	draw_player_seats(renderer, g)
	draw_control_panel(renderer, g)

	if g.celebration != '' {
		draw_celebration_banner(renderer, g)
	}
}

fn draw_casino_room_background(renderer &sdl.Renderer) {
	// Deep navy casino floor with carpet diamond motifs
	for y := 0; y < 600; y += 4 {
		shade := u8(10 + (y * 8) / 600)
		sdl.set_render_draw_color(renderer, shade + 2, shade, shade + 10, 255)
		rect := sdl.Rect{ x: 0, y: y, w: 800, h: 4 }
		sdl.render_fill_rect(renderer, &rect)
	}
}

fn draw_poker_table(renderer &sdl.Renderer, g &TexasGame) {
	rx := 50
	ry := 50
	rw := 700
	rh := 460

	// 1. Outer Padded Armrest (Dark Stitched Mahogany Leather)
	sdl.set_render_draw_color(renderer, 48, 22, 14, 255)
	rail := sdl.Rect{ x: rx, y: ry, w: rw, h: rh }
	sdl.render_fill_rect(renderer, &rail)

	// Gold Inlay Rail Trim
	sdl.set_render_draw_color(renderer, 215, 175, 45, 255)
	sdl.render_draw_rect(renderer, &rail)

	sdl.set_render_draw_color(renderer, 75, 38, 22, 255)
	inner_rail := sdl.Rect{ x: rx + 4, y: ry + 4, w: rw - 8, h: rh - 8 }
	sdl.render_draw_rect(renderer, &inner_rail)

	// 2. Tournament Wool Baize Felt (Emerald Green with Center Spotlight Vignette)
	fx := rx + 16
	fy := ry + 16
	fw := rw - 32
	fh := rh - 32

	for y := 0; y < fh; y += 4 {
		norm_y := f64(y) / f64(fh) - 0.5
		vignette := math.max(0.0, 1.0 - (norm_y * norm_y * 2.0))

		r := u8(12.0 + vignette * 8.0)
		gr := u8(65.0 + vignette * 30.0)
		b := u8(35.0 + vignette * 18.0)

		sdl.set_render_draw_color(renderer, r, gr, b, 255)
		strip := sdl.Rect{ x: fx, y: fy + y, w: fw, h: 4 }
		sdl.render_fill_rect(renderer, &strip)
	}

	// Inner Felt Betting Line Ring
	sdl.set_render_draw_color(renderer, 230, 190, 50, 110)
	bet_line := sdl.Rect{ x: fx + 50, y: fy + 35, w: fw - 100, h: fh - 70 }
	sdl.render_draw_rect(renderer, &bet_line)

	// Felt Logo & Pot Display
	draw_text_centered(renderer, 400, 185, '★ TEXAS HOLD\'EM NO-LIMIT ★', 1, Color{ r: 240, g: 215, b: 60 })

	// Main Pot Golden Chip Box
	draw_pot_display(renderer, 400, 215, g.pot)
}

fn draw_pot_display(renderer &sdl.Renderer, cx int, cy int, pot int) {
	pot_w := 180
	pot_h := 24
	px := cx - pot_w / 2
	py := cy - pot_h / 2

	sdl.set_render_draw_color(renderer, 10, 28, 16, 220)
	box := sdl.Rect{ x: px, y: py, w: pot_w, h: pot_h }
	sdl.render_fill_rect(renderer, &box)

	sdl.set_render_draw_color(renderer, 235, 195, 50, 255)
	sdl.render_draw_rect(renderer, &box)

	// Gold chip icon
	draw_filled_circle(renderer, px + 14, cy, 7, Color{ r: 250, g: 210, b: 40 })
	draw_circle_ring(renderer, px + 14, cy, 5, 1, Color{ r: 255, g: 255, b: 255 })

	draw_text_centered(renderer, cx + 6, cy - 4, 'POT: $$${pot}', 1, Color{ r: 255, g: 255, b: 255 })
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
			// Empty Card Placeholder with Felt Shadow Slot
			sdl.set_render_draw_color(renderer, 8, 38, 20, 255)
			bg := sdl.Rect{ x: cx, y: cy, w: card_w, h: card_h }
			sdl.render_fill_rect(renderer, &bg)

			sdl.set_render_draw_color(renderer, 30, 95, 50, 255)
			sdl.render_draw_rect(renderer, &bg)

			draw_text_centered(renderer, cx + card_w / 2, cy + card_h / 2 - 4, '?', 1, Color{ r: 35, g: 110, b: 60 })
		}
	}
}

fn draw_player_seats(renderer &sdl.Renderer, g &TexasGame) {
	// 0: Bottom (Human), 1: Left, 2: Top, 3: Right
	seat_pos := [
		[400, 420],
		[130, 260],
		[400, 100],
		[670, 260],
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
	w := 148
	h := 80
	x := cx - w / 2
	y := cy - h / 2

	// Pod Background with 3D Bevel
	bg_col := if is_turn { Color{ r: 28, g: 45, b: 72 } } else { Color{ r: 16, g: 20, b: 30 } }
	sdl.set_render_draw_color(renderer, bg_col.r, bg_col.g, bg_col.b, 245)
	pod := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.render_fill_rect(renderer, &pod)

	border_col := if is_turn { Color{ r: 255, g: 215, b: 0 } } else { Color{ r: 85, g: 95, b: 120 } }
	sdl.set_render_draw_color(renderer, border_col.r, border_col.g, border_col.b, 255)
	sdl.render_draw_rect(renderer, &pod)

	// Name & Chip Count
	name_col := if p.is_folded { Color{ r: 110, g: 110, b: 110 } } else { Color{ r: 255, g: 255, b: 255 } }
	draw_text_centered(renderer, cx, y + 6, p.name, 1, name_col)
	draw_text_centered(renderer, cx, y + 18, '$$${p.chips}', 1, Color{ r: 255, g: 215, b: 50 })

	// Action status badge
	if p.last_action != '' {
		draw_text_centered(renderer, cx, y + 30, p.last_action, 1, Color{ r: 80, g: 220, b: 255 })
	}

	// Hole Cards
	card_w := 34
	card_h := 48
	if p.hole_cards.len == 2 {
		c1_x := cx - card_w - 2
		c2_x := cx + 2
		cards_y := y + 44

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
		db_y := y + 12
		draw_filled_circle(renderer, db_x, db_y, 10, Color{ r: 250, g: 250, b: 255 })
		draw_circle_ring(renderer, db_x, db_y, 10, 1, Color{ r: 20, g: 20, b: 30 })
		draw_text_centered(renderer, db_x, db_y - 4, 'D', 1, Color{ r: 200, g: 20, b: 30 })
	}
}

// -------------------------------------------------------------
// 16-Bit Poker Playing Card Renderer
// -------------------------------------------------------------

fn draw_poker_card(renderer &sdl.Renderer, x int, y int, w int, h int, c Card) {
	// Drop Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 100)
	shadow := sdl.Rect{ x: x + 2, y: y + 3, w: w, h: h }
	sdl.render_fill_rect(renderer, &shadow)

	// Ivory Card Body
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 252, 250, 245, 255)
	sdl.render_fill_rect(renderer, &bg)

	sdl.set_render_draw_color(renderer, 40, 42, 50, 255)
	sdl.render_draw_rect(renderer, &bg)

	is_red := c.suit == .hearts || c.suit == .diamonds
	suit_col := if is_red { Color{ r: 215, g: 30, b: 40 } } else { Color{ r: 24, g: 26, b: 32 } }

	rank_s := match c.rank {
		14 { 'A' }
		13 { 'K' }
		12 { 'Q' }
		11 { 'J' }
		10 { '10' }
		else { '${c.rank}' }
	}

	// Corner Index
	draw_text(renderer, x + 3, y + 3, rank_s, 1, suit_col)

	// Small vs Large card layout
	if w >= 50 {
		// Community card size
		draw_suit_pip(renderer, c.suit, x + 8, y + 16, 4)
		draw_text(renderer, x + w - 11, y + h - 12, rank_s, 1, suit_col)
		draw_suit_pip(renderer, c.suit, x + w - 8, y + h - 20, 4)

		cx := x + w / 2
		cy := y + h / 2

		if c.rank == 14 {
			// Ace: Large Centerpiece
			draw_suit_pip(renderer, c.suit, cx, cy, 12)
			draw_circle_ring(renderer, cx, cy, 16, 1, Color{ r: suit_col.r, g: suit_col.g, b: suit_col.b, a: 70 })
		} else if c.rank >= 11 && c.rank <= 13 {
			// Court Portrait
			draw_court_portrait(renderer, x + 12, y + 18, w - 24, h - 36, c.rank, suit_col)
		} else {
			// Center Pip Layout
			draw_suit_pip(renderer, c.suit, cx, cy, 8)
		}
	} else {
		// Mini Hole Card (34x48)
		draw_suit_pip(renderer, c.suit, x + w / 2, y + h / 2 + 2, 5)
	}
}

fn draw_court_portrait(renderer &sdl.Renderer, px int, py int, pw int, ph int, rank int, col Color) {
	p_rect := sdl.Rect{ x: px, y: py, w: pw, h: ph }
	sdl.set_render_draw_color(renderer, 245, 240, 225, 255)
	sdl.render_fill_rect(renderer, &p_rect)

	sdl.set_render_draw_color(renderer, 200, 165, 60, 255)
	sdl.render_draw_rect(renderer, &p_rect)

	cx := px + pw / 2
	cy := py + ph / 2

	if rank == 11 {
		// Jack: Helmet
		sdl.set_render_draw_color(renderer, 140, 150, 170, 255)
		helm := sdl.Rect{ x: cx - 6, y: cy - 10, w: 12, h: 10 }
		sdl.render_fill_rect(renderer, &helm)
		draw_text_centered(renderer, cx, cy + 8, 'J', 1, col)
	} else if rank == 12 {
		// Queen: Crown
		sdl.set_render_draw_color(renderer, 245, 205, 40, 255)
		crown := sdl.Rect{ x: cx - 8, y: cy - 12, w: 16, h: 6 }
		sdl.render_fill_rect(renderer, &crown)
		draw_text_centered(renderer, cx, cy + 8, 'Q', 1, col)
	} else if rank == 13 {
		// King: Imperial Crown
		sdl.set_render_draw_color(renderer, 245, 205, 40, 255)
		k_crown := sdl.Rect{ x: cx - 10, y: cy - 13, w: 20, h: 7 }
		sdl.render_fill_rect(renderer, &k_crown)
		draw_text_centered(renderer, cx, cy + 8, 'K', 1, col)
	}
}

fn draw_suit_pip(renderer &sdl.Renderer, suit CardSuit, cx int, cy int, size int) {
	match suit {
		.hearts {
			sdl.set_render_draw_color(renderer, 215, 30, 40, 255)
			for dy := -size; dy <= size; dy++ {
				for dx := -size; dx <= size; dx++ {
					if dy < 0 {
						lx := dx + size / 2
						rx := dx - size / 2
						if (lx * lx + (dy + size / 2) * (dy + size / 2) <= (size / 2) * (size / 2) + 1) ||
						   (rx * rx + (dy + size / 2) * (dy + size / 2) <= (size / 2) * (size / 2) + 1) {
							sdl.render_draw_point(renderer, cx + dx, cy + dy)
						}
					} else {
						span := (size - dy)
						if dx >= -span && dx <= span {
							sdl.render_draw_point(renderer, cx + dx, cy + dy)
						}
					}
				}
			}
		}
		.diamonds {
			sdl.set_render_draw_color(renderer, 215, 30, 40, 255)
			for dy := -size; dy <= size; dy++ {
				span := int(f64(size - int(math.abs(f64(dy)))) * 0.8)
				for dx := -span; dx <= span; dx++ {
					sdl.render_draw_point(renderer, cx + dx, cy + dy)
				}
			}
		}
		.clubs {
			sdl.set_render_draw_color(renderer, 24, 26, 32, 255)
			r_lobe := size / 2
			draw_filled_circle(renderer, cx, cy - r_lobe, r_lobe, Color{ r: 24, g: 26, b: 32 })
			draw_filled_circle(renderer, cx - r_lobe, cy + r_lobe / 2, r_lobe, Color{ r: 24, g: 26, b: 32 })
			draw_filled_circle(renderer, cx + r_lobe, cy + r_lobe / 2, r_lobe, Color{ r: 24, g: 26, b: 32 })
			stem := sdl.Rect{ x: cx - 1, y: cy + r_lobe / 2, w: 3, h: size - r_lobe / 2 + 1 }
			sdl.render_fill_rect(renderer, &stem)
		}
		.spades {
			sdl.set_render_draw_color(renderer, 24, 26, 32, 255)
			for dy := -size; dy <= size / 2; dy++ {
				mut span := int(f64(dy + size) * 0.7)
				if span > size { span = size }
				for dx := -span; dx <= span; dx++ {
					sdl.render_draw_point(renderer, cx + dx, cy + dy)
				}
			}
			r_lobe := size / 2
			draw_filled_circle(renderer, cx - r_lobe / 2, cy + r_lobe / 2, r_lobe, Color{ r: 24, g: 26, b: 32 })
			draw_filled_circle(renderer, cx + r_lobe / 2, cy + r_lobe / 2, r_lobe, Color{ r: 24, g: 26, b: 32 })
			stem := sdl.Rect{ x: cx - 1, y: cy + r_lobe / 2, w: 3, h: size - r_lobe / 2 + 2 }
			sdl.render_fill_rect(renderer, &stem)
		}
	}
}

fn draw_poker_card_back(renderer &sdl.Renderer, x int, y int, w int, h int) {
	// Drop Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 90)
	shadow := sdl.Rect{ x: x + 2, y: y + 3, w: w, h: h }
	sdl.render_fill_rect(renderer, &shadow)

	// White Base
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 248, 246, 240, 255)
	sdl.render_fill_rect(renderer, &bg)
	sdl.set_render_draw_color(renderer, 30, 32, 40, 255)
	sdl.render_draw_rect(renderer, &bg)

	// Inner Crimson Pattern
	inner := sdl.Rect{ x: x + 3, y: y + 3, w: w - 6, h: h - 6 }
	sdl.set_render_draw_color(renderer, 155, 25, 35, 255)
	sdl.render_fill_rect(renderer, &inner)

	// Diamond lattice
	sdl.set_render_draw_color(renderer, 255, 255, 255, 100)
	for ly := y + 5; ly < y + h - 5; ly += 6 {
		for lx := x + 5; lx < x + w - 5; lx += 6 {
			sdl.render_draw_point(renderer, lx, ly)
		}
	}
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
