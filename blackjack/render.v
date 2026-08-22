module main

import math
import sdl

fn draw_blackjack_game(renderer &sdl.Renderer, g &BlackjackGame) {
	// Deep Casino Green Felt with subtle vignette
	draw_casino_table_felt(renderer)

	draw_table_felt_markings(renderer)
	draw_dealer_area(renderer, g)
	draw_player_hands_area(renderer, g)
	draw_betting_chips_area(renderer, g)
	draw_hud_and_controls(renderer, g)
}

fn draw_casino_table_felt(renderer &sdl.Renderer) {
	// Deep emerald casino baize with vignette
	for y := 0; y < 600; y += 4 {
		shade := u8(14 + (y * 8) / 600)
		sdl.set_render_draw_color(renderer, shade - 4, shade + 45, shade + 18, 255)
		rect := sdl.Rect{ x: 0, y: y, w: 800, h: 4 }
		sdl.render_fill_rect(renderer, &rect)
	}

	// Mahogany Wood Border Rail
	sdl.set_render_draw_color(renderer, 58, 28, 16, 255)
	rim := sdl.Rect{ x: 8, y: 8, w: 784, h: 584 }
	sdl.render_draw_rect(renderer, &rim)

	sdl.set_render_draw_color(renderer, 85, 42, 24, 255)
	inner_rim := sdl.Rect{ x: 10, y: 10, w: 780, h: 580 }
	sdl.render_draw_rect(renderer, &inner_rim)
}

fn draw_table_felt_markings(renderer &sdl.Renderer) {
	// Gold Felt Arch
	sdl.set_render_draw_color(renderer, 220, 185, 50, 100)
	sdl.render_draw_line(renderer, 100, 260, 700, 260)
	sdl.render_draw_line(renderer, 100, 261, 700, 261)

	// Printed Rules in Arch
	draw_text_centered(renderer, 400, 205, '★ BLACKJACK PAYS 3 TO 2 ★', 2, Color{ r: 255, g: 215, b: 50 })
	draw_text_centered(renderer, 400, 235, 'Dealer Must Draw to 16 and Stand on all 17s', 1, Color{ r: 230, g: 240, b: 210 })
	draw_text_centered(renderer, 400, 268, '★ INSURANCE PAYS 2 TO 1 ★', 1, Color{ r: 255, g: 215, b: 50 })
}

fn draw_dealer_area(renderer &sdl.Renderer, g &BlackjackGame) {
	dx := 400
	dy := 60
	card_w := 64
	card_h := 94

	draw_text_centered(renderer, dx, dy - 20, 'DEALER', 1, Color{ r: 240, g: 220, b: 150 })

	if g.dealer_hand.len > 0 {
		start_x := dx - (g.dealer_hand.len * 38 + card_w - 38) / 2

		for i, c in g.dealer_hand {
			cx := start_x + i * 38
			if i == 1 && g.dealer_hidden {
				draw_playing_card_back(renderer, cx, dy, card_w, card_h, Color{ r: 160, g: 25, b: 35 })
			} else {
				draw_playing_card(renderer, cx, dy, card_w, card_h, c.rank, c.suit)
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
	py := 315

	for h_idx, h in g.player_hands {
		hx := if g.player_hands.len == 1 { 400 } else { 280 + h_idx * 240 }
		start_x := hx - (h.cards.len * 35 + card_w - 35) / 2

		is_active := h_idx == g.active_hand_idx && g.state == .player_turn

		// Active Hand Spotlight Box
		if is_active {
			box := sdl.Rect{ x: hx - 85, y: py - 25, w: 170, h: card_h + 62 }
			sdl.set_render_draw_color(renderer, 255, 215, 0, 90)
			sdl.render_draw_rect(renderer, &box)
		}

		for i, c in h.cards {
			cx := start_x + i * 35
			draw_playing_card(renderer, cx, py, card_w, card_h, c.rank, c.suit)
		}

		// Hand Status / Value
		val, is_soft := calculate_hand_value(h.cards)
		val_str := if h.is_bj { 'BLACKJACK! (21)' } else if h.is_busted { 'BUST! (${val})' } else if is_soft && val < 21 { 'SOFT ${val}' } else { '${val}' }

		col := if is_active { Color{ r: 255, g: 220, b: 50 } } else { Color{ r: 220, g: 235, b: 255 } }
		draw_text_centered(renderer, hx, py + card_h + 8, 'Hand: ${val_str} ($$${h.bet})', 1, col)
	}
}

fn draw_betting_chips_area(renderer &sdl.Renderer, g &BlackjackGame) {
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
	// Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 90)
	shadow := sdl.Rect{ x: cx - r + 2, y: cy - r + 3, w: r * 2, h: r * 2 }
	sdl.render_fill_rect(renderer, &shadow)

	// Base body
	draw_filled_circle(renderer, cx, cy, r, c)
	// Outer edge rim
	draw_circle_ring(renderer, cx, cy, r, 2, Color{ r: 240, g: 220, b: 150 })
	// Inner white dash ring
	draw_circle_ring(renderer, cx, cy, r - 4, 2, Color{ r: 255, g: 255, b: 255 })

	val_s := if val >= 500 { '500' } else if val >= 100 { '100' } else { '${val}' }
	draw_text_centered(renderer, cx, cy - 3, val_s, 1, Color{ r: 255, g: 255, b: 255 })
}

// -------------------------------------------------------------
// 16-Bit Card Graphics Rendering
// -------------------------------------------------------------

fn draw_playing_card(renderer &sdl.Renderer, x int, y int, w int, h int, rank int, suit CardSuit) {
	// Drop Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 110)
	shadow := sdl.Rect{ x: x + 3, y: y + 4, w: w, h: h }
	sdl.render_fill_rect(renderer, &shadow)

	// Ivory Card Body
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 252, 250, 245, 255)
	sdl.render_fill_rect(renderer, &bg)

	// Card Outer Border
	sdl.set_render_draw_color(renderer, 45, 48, 55, 255)
	sdl.render_draw_rect(renderer, &bg)

	// Card Inner Subtle Margin
	sdl.set_render_draw_color(renderer, 220, 215, 205, 255)
	inner := sdl.Rect{ x: x + 2, y: y + 2, w: w - 4, h: h - 4 }
	sdl.render_draw_rect(renderer, &inner)

	is_red := suit == .hearts || suit == .diamonds
	suit_col := if is_red { Color{ r: 215, g: 30, b: 40 } } else { Color{ r: 24, g: 26, b: 32 } }

	rank_s := match rank {
		1  { 'A' }
		11 { 'J' }
		12 { 'Q' }
		13 { 'K' }
		10 { '10' }
		else { '${rank}' }
	}

	// Top-Left Index (Rank & Mini Suit Pip)
	draw_text(renderer, x + 4, y + 4, rank_s, 1, suit_col)
	draw_suit_pip(renderer, suit, x + 8, y + 18, 4)

	// Bottom-Right Index (Rank & Mini Suit Pip)
	draw_text(renderer, x + w - 12, y + h - 14, rank_s, 1, suit_col)
	draw_suit_pip(renderer, suit, x + w - 9, y + h - 22, 4)

	// Center Card Artwork / Pip Layout
	cx := x + w / 2
	cy := y + h / 2

	if rank == 1 {
		// Ace: Large Ornate Centerpiece Suit Emblem
		draw_suit_pip(renderer, suit, cx, cy, 14)
		// Decorative filigree ring
		draw_circle_ring(renderer, cx, cy, 20, 1, Color{ r: suit_col.r, g: suit_col.g, b: suit_col.b, a: 80 })
	} else if rank >= 11 && rank <= 13 {
		// Court Cards: Jack, Queen, King 16-bit Royal Portrait
		draw_court_portrait(renderer, x + 14, y + 20, w - 28, h - 40, rank, suit, suit_col)
	} else {
		// Number Cards (2-10): Authentic Pip Layouts
		draw_pip_layout(renderer, x, y, w, h, rank, suit)
	}
}

fn draw_court_portrait(renderer &sdl.Renderer, px int, py int, pw int, ph int, rank int, _suit CardSuit, col Color) {
	// Decorative Gold Frame
	p_rect := sdl.Rect{ x: px, y: py, w: pw, h: ph }
	sdl.set_render_draw_color(renderer, 245, 240, 225, 255)
	sdl.render_fill_rect(renderer, &p_rect)

	sdl.set_render_draw_color(renderer, 200, 165, 60, 255)
	sdl.render_draw_rect(renderer, &p_rect)

	cx := px + pw / 2
	cy := py + ph / 2

	if rank == 11 {
		// Jack: Medieval Royal Knight
		// Helmet / Visor
		sdl.set_render_draw_color(renderer, 140, 150, 170, 255)
		helm := sdl.Rect{ x: cx - 8, y: cy - 14, w: 16, h: 12 }
		sdl.render_fill_rect(renderer, &helm)

		// Plume Feather
		sdl.set_render_draw_color(renderer, col.r, col.g, col.b, 255)
		plume := sdl.Rect{ x: cx - 4, y: cy - 18, w: 8, h: 4 }
		sdl.render_fill_rect(renderer, &plume)

		// Armored Shoulder Pauldron
		sdl.set_render_draw_color(renderer, 100, 110, 130, 255)
		paul := sdl.Rect{ x: cx - 12, y: cy, w: 24, h: 12 }
		sdl.render_fill_rect(renderer, &paul)

		// Sword blade
		sdl.set_render_draw_color(renderer, 220, 225, 240, 255)
		sdl.render_draw_line(renderer, cx + 8, cy - 8, cx + 8, cy + 14)

		draw_text_centered(renderer, cx, cy + 14, 'J', 1, col)
	} else if rank == 12 {
		// Queen: Royal Crown & Jewel
		// Golden Crown
		sdl.set_render_draw_color(renderer, 245, 205, 40, 255)
		crown := sdl.Rect{ x: cx - 10, y: cy - 16, w: 20, h: 6 }
		sdl.render_fill_rect(renderer, &crown)
		sdl.render_draw_point(renderer, cx - 8, cy - 18)
		sdl.render_draw_point(renderer, cx, cy - 18)
		sdl.render_draw_point(renderer, cx + 8, cy - 18)

		// Queen Bodice
		sdl.set_render_draw_color(renderer, col.r, col.g, col.b, 255)
		bodice := sdl.Rect{ x: cx - 10, y: cy - 8, w: 20, h: 20 }
		sdl.render_fill_rect(renderer, &bodice)

		// Center Ruby Jewel
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		sdl.render_draw_point(renderer, cx, cy)

		draw_text_centered(renderer, cx, cy + 14, 'Q', 1, col)
	} else if rank == 13 {
		// King: Imperial Crown & Ermine Fur Collar
		// Imperial Gold Crown
		sdl.set_render_draw_color(renderer, 245, 205, 40, 255)
		k_crown := sdl.Rect{ x: cx - 12, y: cy - 16, w: 24, h: 7 }
		sdl.render_fill_rect(renderer, &k_crown)
		sdl.render_draw_line(renderer, cx - 10, cy - 19, cx - 10, cy - 16)
		sdl.render_draw_line(renderer, cx, cy - 20, cx, cy - 16)
		sdl.render_draw_line(renderer, cx + 10, cy - 19, cx + 10, cy - 16)

		// Royal Ermine Robe
		sdl.set_render_draw_color(renderer, col.r, col.g, col.b, 255)
		robe := sdl.Rect{ x: cx - 12, y: cy - 7, w: 24, h: 19 }
		sdl.render_fill_rect(renderer, &robe)

		// White Fur Trim
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		sdl.render_draw_line(renderer, cx - 12, cy - 7, cx + 12, cy - 7)

		draw_text_centered(renderer, cx, cy + 14, 'K', 1, col)
	}
}

fn draw_pip_layout(renderer &sdl.Renderer, x int, y int, w int, h int, rank int, suit CardSuit) {
	cx := x + w / 2
	cy := y + h / 2
	lx := x + 20
	rx := x + w - 20
	ty := y + 26
	by := y + h - 26
	my := y + h / 2

	match rank {
		2 {
			draw_suit_pip(renderer, suit, cx, ty, 6)
			draw_suit_pip(renderer, suit, cx, by, 6)
		}
		3 {
			draw_suit_pip(renderer, suit, cx, ty, 6)
			draw_suit_pip(renderer, suit, cx, cy, 6)
			draw_suit_pip(renderer, suit, cx, by, 6)
		}
		4 {
			draw_suit_pip(renderer, suit, lx, ty, 5)
			draw_suit_pip(renderer, suit, rx, ty, 5)
			draw_suit_pip(renderer, suit, lx, by, 5)
			draw_suit_pip(renderer, suit, rx, by, 5)
		}
		5 {
			draw_suit_pip(renderer, suit, lx, ty, 5)
			draw_suit_pip(renderer, suit, rx, ty, 5)
			draw_suit_pip(renderer, suit, cx, cy, 6)
			draw_suit_pip(renderer, suit, lx, by, 5)
			draw_suit_pip(renderer, suit, rx, by, 5)
		}
		6 {
			draw_suit_pip(renderer, suit, lx, ty, 5)
			draw_suit_pip(renderer, suit, rx, ty, 5)
			draw_suit_pip(renderer, suit, lx, my, 5)
			draw_suit_pip(renderer, suit, rx, my, 5)
			draw_suit_pip(renderer, suit, lx, by, 5)
			draw_suit_pip(renderer, suit, rx, by, 5)
		}
		7 {
			draw_suit_pip(renderer, suit, lx, ty, 5)
			draw_suit_pip(renderer, suit, rx, ty, 5)
			draw_suit_pip(renderer, suit, cx, ty + 12, 5)
			draw_suit_pip(renderer, suit, lx, my + 4, 5)
			draw_suit_pip(renderer, suit, rx, my + 4, 5)
			draw_suit_pip(renderer, suit, lx, by, 5)
			draw_suit_pip(renderer, suit, rx, by, 5)
		}
		8 {
			draw_suit_pip(renderer, suit, lx, ty, 5)
			draw_suit_pip(renderer, suit, rx, ty, 5)
			draw_suit_pip(renderer, suit, cx, ty + 12, 5)
			draw_suit_pip(renderer, suit, lx, my + 4, 5)
			draw_suit_pip(renderer, suit, rx, my + 4, 5)
			draw_suit_pip(renderer, suit, cx, by - 12, 5)
			draw_suit_pip(renderer, suit, lx, by, 5)
			draw_suit_pip(renderer, suit, rx, by, 5)
		}
		9 {
			draw_suit_pip(renderer, suit, lx, ty, 5)
			draw_suit_pip(renderer, suit, rx, ty, 5)
			draw_suit_pip(renderer, suit, lx, ty + 14, 5)
			draw_suit_pip(renderer, suit, rx, ty + 14, 5)
			draw_suit_pip(renderer, suit, cx, cy, 5)
			draw_suit_pip(renderer, suit, lx, by - 14, 5)
			draw_suit_pip(renderer, suit, rx, by - 14, 5)
			draw_suit_pip(renderer, suit, lx, by, 5)
			draw_suit_pip(renderer, suit, rx, by, 5)
		}
		10 {
			draw_suit_pip(renderer, suit, lx, ty, 5)
			draw_suit_pip(renderer, suit, rx, ty, 5)
			draw_suit_pip(renderer, suit, cx, ty + 10, 5)
			draw_suit_pip(renderer, suit, lx, ty + 16, 5)
			draw_suit_pip(renderer, suit, rx, ty + 16, 5)
			draw_suit_pip(renderer, suit, lx, by - 16, 5)
			draw_suit_pip(renderer, suit, rx, by - 16, 5)
			draw_suit_pip(renderer, suit, cx, by - 10, 5)
			draw_suit_pip(renderer, suit, lx, by, 5)
			draw_suit_pip(renderer, suit, rx, by, 5)
		}
		else {}
	}
}

fn draw_suit_pip(renderer &sdl.Renderer, suit CardSuit, cx int, cy int, size int) {
	match suit {
		.hearts {
			// Hearts (♥) - Crimson
			sdl.set_render_draw_color(renderer, 215, 30, 40, 255)
			for dy := -size; dy <= size; dy++ {
				for dx := -size; dx <= size; dx++ {
					// Heart mathematical formula
					if dy < 0 {
						// Twin lobes
						lx := dx + size / 2
						rx := dx - size / 2
						if (lx * lx + (dy + size / 2) * (dy + size / 2) <= (size / 2) * (size / 2) + 1) ||
						   (rx * rx + (dy + size / 2) * (dy + size / 2) <= (size / 2) * (size / 2) + 1) {
							sdl.render_draw_point(renderer, cx + dx, cy + dy)
						}
					} else {
						// Tapering triangle base
						span := (size - dy)
						if dx >= -span && dx <= span {
							sdl.render_draw_point(renderer, cx + dx, cy + dy)
						}
					}
				}
			}
			// White specular glint
			if size >= 6 {
				sdl.set_render_draw_color(renderer, 255, 255, 255, 200)
				sdl.render_draw_point(renderer, cx - size / 2, cy - size / 2)
			}
		}
		.diamonds {
			// Diamonds (♦) - Crimson
			sdl.set_render_draw_color(renderer, 215, 30, 40, 255)
			for dy := -size; dy <= size; dy++ {
				span := int(f64(size - int(math.abs(f64(dy)))) * 0.8)
				for dx := -span; dx <= span; dx++ {
					sdl.render_draw_point(renderer, cx + dx, cy + dy)
				}
			}
			// Specular facet
			if size >= 6 {
				sdl.set_render_draw_color(renderer, 255, 255, 255, 220)
				sdl.render_draw_point(renderer, cx - 1, cy - size / 3)
			}
		}
		.clubs {
			// Clubs (♣) - Onyx Black
			sdl.set_render_draw_color(renderer, 24, 26, 32, 255)
			r_lobe := size / 2
			// Top lobe
			draw_filled_circle(renderer, cx, cy - r_lobe, r_lobe, Color{ r: 24, g: 26, b: 32 })
			// Left lobe
			draw_filled_circle(renderer, cx - r_lobe, cy + r_lobe / 2, r_lobe, Color{ r: 24, g: 26, b: 32 })
			// Right lobe
			draw_filled_circle(renderer, cx + r_lobe, cy + r_lobe / 2, r_lobe, Color{ r: 24, g: 26, b: 32 })
			// Stem
			stem := sdl.Rect{ x: cx - 1, y: cy + r_lobe / 2, w: 3, h: size - r_lobe / 2 + 1 }
			sdl.render_fill_rect(renderer, &stem)
		}
		.spades {
			// Spades (♠) - Onyx Black
			sdl.set_render_draw_color(renderer, 24, 26, 32, 255)
			for dy := -size; dy <= size / 2; dy++ {
				mut span := int(f64(dy + size) * 0.7)
				if span > size { span = size }
				for dx := -span; dx <= span; dx++ {
					sdl.render_draw_point(renderer, cx + dx, cy + dy)
				}
			}
			// Bottom lobes
			r_lobe := size / 2
			draw_filled_circle(renderer, cx - r_lobe / 2, cy + r_lobe / 2, r_lobe, Color{ r: 24, g: 26, b: 32 })
			draw_filled_circle(renderer, cx + r_lobe / 2, cy + r_lobe / 2, r_lobe, Color{ r: 24, g: 26, b: 32 })
			// Stem
			stem := sdl.Rect{ x: cx - 1, y: cy + r_lobe / 2, w: 3, h: size - r_lobe / 2 + 2 }
			sdl.render_fill_rect(renderer, &stem)
		}
	}
}

fn draw_playing_card_back(renderer &sdl.Renderer, x int, y int, w int, h int, pattern_col Color) {
	// Drop Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 110)
	shadow := sdl.Rect{ x: x + 3, y: y + 4, w: w, h: h }
	sdl.render_fill_rect(renderer, &shadow)

	// White Base
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 250, 248, 242, 255)
	sdl.render_fill_rect(renderer, &bg)
	sdl.set_render_draw_color(renderer, 30, 32, 40, 255)
	sdl.render_draw_rect(renderer, &bg)

	// Inner Pattern Area
	inner := sdl.Rect{ x: x + 4, y: y + 4, w: w - 8, h: h - 8 }
	sdl.set_render_draw_color(renderer, pattern_col.r, pattern_col.g, pattern_col.b, 255)
	sdl.render_fill_rect(renderer, &inner)

	// Diamond Filigree Lattice
	sdl.set_render_draw_color(renderer, 255, 255, 255, 120)
	for ly := y + 6; ly < y + h - 6; ly += 8 {
		for lx := x + 6; lx < x + w - 6; lx += 8 {
			sdl.render_draw_line(renderer, lx, ly - 3, lx + 3, ly)
			sdl.render_draw_line(renderer, lx + 3, ly, lx, ly + 3)
			sdl.render_draw_line(renderer, lx, ly + 3, lx - 3, ly)
			sdl.render_draw_line(renderer, lx - 3, ly, lx, ly - 3)
		}
	}

	// Center Gold Medallion
	draw_filled_circle(renderer, x + w / 2, y + h / 2, 10, Color{ r: 245, g: 215, b: 60 })
	draw_circle_ring(renderer, x + w / 2, y + h / 2, 10, 1, Color{ r: 255, g: 255, b: 255 })
}

fn draw_card_outline(renderer &sdl.Renderer, x int, y int, w int, h int) {
	rect := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 30, 85, 48, 180)
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
		.betting     { '[SPACE/ENTER] DEAL | [1-5] CHIPS (+$$5..$$500) | [C] CLEAR | [M] SOUND' }
		.player_turn { '[H] HIT | [S] STAND | [D] DOUBLE | [P] SPLIT | [I] INSURANCE' }
		else         { '[SPACE/ENTER] NEXT HAND | [M] SOUND' }
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
