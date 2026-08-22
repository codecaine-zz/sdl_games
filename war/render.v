module main

import math
import sdl

fn draw_war_game(renderer &sdl.Renderer, g &WarGame) {
	// Deep Navy / Mahogany Split Felt Table
	sdl.set_render_draw_color(renderer, 16, 20, 32, 255)
	sdl.render_clear(renderer)

	draw_battlefield_background(renderer)
	draw_player_zones(renderer, g)
	draw_battlefield_duel(renderer, g)
	draw_hud_and_prompts(renderer, g)
}

fn draw_battlefield_background(renderer &sdl.Renderer) {
	// Top General Territory (Crimson Tint with Gradient)
	top_rect := sdl.Rect{ x: 20, y: 20, w: 760, h: 260 }
	sdl.set_render_draw_color(renderer, 48, 16, 22, 255)
	sdl.render_fill_rect(renderer, &top_rect)
	sdl.set_render_draw_color(renderer, 150, 45, 55, 255)
	sdl.render_draw_rect(renderer, &top_rect)

	// Bottom Player Territory (Royal Blue Tint with Gradient)
	bot_rect := sdl.Rect{ x: 20, y: 300, w: 760, h: 260 }
	sdl.set_render_draw_color(renderer, 16, 32, 60, 255)
	sdl.render_fill_rect(renderer, &bot_rect)
	sdl.set_render_draw_color(renderer, 45, 85, 165, 255)
	sdl.render_draw_rect(renderer, &bot_rect)

	// Center Demarcation Line with Gold Swords Trim
	sdl.set_render_draw_color(renderer, 225, 185, 50, 255)
	sdl.render_draw_line(renderer, 20, 290, 780, 290)
	sdl.render_draw_line(renderer, 20, 291, 780, 291)
}

fn draw_player_zones(renderer &sdl.Renderer, g &WarGame) {
	// Top Zone: General Bob
	p_ai_tot := g.get_ai_total_cards()
	draw_text(renderer, 40, 35, 'GENERAL BOB (OPPONENT)', 1, Color{ r: 255, g: 150, b: 150 })
	draw_text(renderer, 40, 50, 'TOTAL FORCES: ${p_ai_tot} / 52 CARDS', 1, Color{ r: 220, g: 220, b: 220 })

	// AI Draw Pile Deck
	if g.ai_draw_pile.len > 0 {
		draw_stacked_deck_back(renderer, 100, 80, 70, 100, g.ai_draw_pile.len, Color{ r: 175, g: 28, b: 38 })
		draw_text_centered(renderer, 135, 192, 'DRAW (${g.ai_draw_pile.len})', 1, Color{ r: 255, g: 200, b: 200 })
	}
	// AI Capture Pile
	if g.ai_win_pile.len > 0 {
		draw_stacked_deck_back(renderer, 200, 80, 70, 100, g.ai_win_pile.len, Color{ r: 120, g: 20, b: 30 })
		draw_text_centered(renderer, 235, 192, 'CAPTURED (${g.ai_win_pile.len})', 1, Color{ r: 255, g: 180, b: 180 })
	}

	// Bottom Zone: Player
	p_tot := g.get_player_total_cards()
	draw_text(renderer, 40, 520, 'YOU (PLAYER 1)', 1, Color{ r: 150, g: 200, b: 255 })
	draw_text(renderer, 40, 535, 'TOTAL FORCES: ${p_tot} / 52 CARDS', 1, Color{ r: 220, g: 220, b: 220 })

	// Player Draw Pile Deck
	if g.player_draw_pile.len > 0 {
		draw_stacked_deck_back(renderer, 100, 390, 70, 100, g.player_draw_pile.len, Color{ r: 25, g: 75, b: 185 })
		draw_text_centered(renderer, 135, 502, 'DRAW (${g.player_draw_pile.len})', 1, Color{ r: 200, g: 220, b: 255 })
	}
	// Player Capture Pile
	if g.player_win_pile.len > 0 {
		draw_stacked_deck_back(renderer, 200, 390, 70, 100, g.player_win_pile.len, Color{ r: 18, g: 45, b: 125 })
		draw_text_centered(renderer, 235, 502, 'CAPTURED (${g.player_win_pile.len})', 1, Color{ r: 180, g: 200, b: 255 })
	}

	// Visual Tug-of-War Strength Bar (Right side)
	bar_x := 730
	bar_y := 80
	bar_w := 24
	bar_h := 410
	sdl.set_render_draw_color(renderer, 15, 18, 26, 255)
	bar_bg := sdl.Rect{ x: bar_x, y: bar_y, w: bar_w, h: bar_h }
	sdl.render_fill_rect(renderer, &bar_bg)
	sdl.set_render_draw_color(renderer, 180, 190, 210, 255)
	sdl.render_draw_rect(renderer, &bar_bg)

	// Blue share vs Red share
	p_pct := f64(p_tot) / 52.0
	p_h := int(p_pct * f64(bar_h))
	p_bar := sdl.Rect{ x: bar_x + 2, y: bar_y + bar_h - p_h + 2, w: bar_w - 4, h: p_h - 4 }
	sdl.set_render_draw_color(renderer, 35, 120, 240, 255)
	sdl.render_fill_rect(renderer, &p_bar)

	ai_h := bar_h - p_h
	ai_bar := sdl.Rect{ x: bar_x + 2, y: bar_y + 2, w: bar_w - 4, h: ai_h - 4 }
	sdl.set_render_draw_color(renderer, 220, 35, 45, 255)
	sdl.render_fill_rect(renderer, &ai_bar)
}

fn draw_battlefield_duel(renderer &sdl.Renderer, g &WarGame) {
	cx := 450
	card_w := 80
	card_h := 115

	// Center Battlefield Ring
	draw_text_centered(renderer, cx, 285, '★ BATTLEFIELD DUEL ★', 1, Color{ r: 255, g: 220, b: 80 })

	// War Loot Pot Stack
	if g.war_pot.len > 0 {
		pot_x := 600
		pot_y := 235
		draw_stacked_deck_back(renderer, pot_x, pot_y, 65, 95, g.war_pot.len, Color{ r: 180, g: 150, b: 30 })
		draw_text_centered(renderer, pot_x + 32, pot_y + 105, 'WAR POT: ${g.war_pot.len}', 1, Color{ r: 255, g: 215, b: 0 })
	}

	if g.has_battle_card {
		// AI Active Card (Top center)
		ai_card_y := 155
		draw_playing_card(renderer, cx - card_w / 2, ai_card_y, card_w, card_h, g.battle_ai)
		draw_text_centered(renderer, cx, ai_card_y - 18, 'GENERAL BOB: ${get_rank_str(g.battle_ai.rank)}', 1, Color{ r: 255, g: 180, b: 180 })

		// Player Active Card (Bottom center)
		p_card_y := 315
		draw_playing_card(renderer, cx - card_w / 2, p_card_y, card_w, card_h, g.battle_player)
		draw_text_centered(renderer, cx, p_card_y + card_h + 8, 'YOUR CARD: ${get_rank_str(g.battle_player.rank)}', 1, Color{ r: 180, g: 210, b: 255 })

		// Clash VS Badge
		if g.phase == .comparing {
			match g.round_winner {
				1 {
					draw_text_centered(renderer, cx, 282, '>> YOU WIN ROUND! <<', 1, Color{ r: 80, g: 255, b: 120 })
				}
				2 {
					draw_text_centered(renderer, cx, 282, '>> GENERAL BOB WINS ROUND! <<', 1, Color{ r: 255, g: 80, b: 80 })
				}
				3 {
					draw_text_centered(renderer, cx, 282, '⚔️ TIE! WAR DECLARED! ⚔️', 1, Color{ r: 255, g: 220, b: 50 })
				}
				else {}
			}
		}
	} else if g.phase == .ready {
		draw_text_centered(renderer, cx, 250, 'PRESS [SPACE] OR CLICK TO FLIP', 1, Color{ r: 220, g: 235, b: 255 })
	}
}

// -------------------------------------------------------------
// 16-Bit Card Graphics Rendering
// -------------------------------------------------------------

fn draw_playing_card(renderer &sdl.Renderer, x int, y int, w int, h int, c Card) {
	// Drop Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 110)
	shadow := sdl.Rect{ x: x + 3, y: y + 4, w: w, h: h }
	sdl.render_fill_rect(renderer, &shadow)

	// Ivory Card Body
	card_rect := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 252, 250, 245, 255)
	sdl.render_fill_rect(renderer, &card_rect)

	// Dark Border
	sdl.set_render_draw_color(renderer, 35, 38, 45, 255)
	sdl.render_draw_rect(renderer, &card_rect)

	// Inner Margin
	inner_b := sdl.Rect{ x: x + 2, y: y + 2, w: w - 4, h: h - 4 }
	sdl.set_render_draw_color(renderer, 215, 210, 200, 255)
	sdl.render_draw_rect(renderer, &inner_b)

	is_red := c.suit == .hearts || c.suit == .diamonds
	col := if is_red { Color{ r: 215, g: 30, b: 40 } } else { Color{ r: 24, g: 26, b: 32 } }

	rank_s := get_rank_str(c.rank)

	// Corner indicators (Top Left & Bottom Right)
	draw_text(renderer, x + 5, y + 5, rank_s, 1, col)
	draw_suit_pip(renderer, c.suit, x + 10, y + 20, 5)

	draw_text(renderer, x + w - 14, y + h - 16, rank_s, 1, col)
	draw_suit_pip(renderer, c.suit, x + w - 10, y + h - 25, 5)

	// Center Artwork
	cx := x + w / 2
	cy := y + h / 2

	if c.rank == 14 || c.rank == 1 {
		// Ace: Large Centerpiece Emblem
		draw_suit_pip(renderer, c.suit, cx, cy, 16)
		draw_circle_ring(renderer, cx, cy, 22, 1, Color{ r: col.r, g: col.g, b: col.b, a: 80 })
	} else if c.rank >= 11 && c.rank <= 13 {
		// Royalty Portrait
		draw_court_portrait(renderer, x + 16, y + 22, w - 32, h - 44, c.rank, col)
	} else {
		// Center Pip
		draw_suit_pip(renderer, c.suit, cx, cy, 10)
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
		helm := sdl.Rect{ x: cx - 10, y: cy - 14, w: 20, h: 14 }
		sdl.render_fill_rect(renderer, &helm)
		draw_text_centered(renderer, cx, cy + 12, 'J', 1, col)
	} else if rank == 12 {
		// Queen: Crown
		sdl.set_render_draw_color(renderer, 245, 205, 40, 255)
		crown := sdl.Rect{ x: cx - 12, y: cy - 16, w: 24, h: 8 }
		sdl.render_fill_rect(renderer, &crown)
		draw_text_centered(renderer, cx, cy + 12, 'Q', 1, col)
	} else if rank == 13 {
		// King: Imperial Crown
		sdl.set_render_draw_color(renderer, 245, 205, 40, 255)
		k_crown := sdl.Rect{ x: cx - 14, y: cy - 18, w: 28, h: 9 }
		sdl.render_fill_rect(renderer, &k_crown)
		draw_text_centered(renderer, cx, cy + 12, 'K', 1, col)
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

fn draw_stacked_deck_back(renderer &sdl.Renderer, x int, y int, w int, h int, count int, c Color) {
	// Draw shadow card layers to depict 3D stack thickness
	layers := count / 5 + 1
	for i := 0; i < layers; i++ {
		sx := x + i * 2
		sy := y - i * 2
		bg := sdl.Rect{ x: sx, y: sy, w: w, h: h }
		sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 255)
		sdl.render_fill_rect(renderer, &bg)
		sdl.set_render_draw_color(renderer, 245, 248, 255, 200)
		sdl.render_draw_rect(renderer, &bg)

		// Diamond crosshatch on top card
		if i == layers - 1 {
			sdl.set_render_draw_color(renderer, 255, 255, 255, 80)
			for ly := sy + 8; ly < sy + h - 8; ly += 10 {
				for lx := sx + 8; lx < sx + w - 8; lx += 10 {
					sdl.render_draw_point(renderer, lx, ly)
				}
			}
		}
	}
}

fn draw_hud_and_prompts(renderer &sdl.Renderer, g &WarGame) {
	// Top Header Stats
	draw_text(renderer, 320, 26, 'WARS: ${g.wars_fought} | ROUND: ${g.round_count} | AUTO: ${if g.auto_play { 'ON [A]' } else { 'OFF [A]' }}', 1, Color{ r: 240, g: 230, b: 180 })

	// Bottom Controls Bar
	bar_rect := sdl.Rect{ x: 20, y: 568, w: 760, h: 26 }
	sdl.set_render_draw_color(renderer, 12, 18, 30, 240)
	sdl.render_fill_rect(renderer, &bar_rect)
	draw_text_centered(renderer, 400, 574, '[SPACE/CLICK] FLIP BATTLE | [A] TOGGLE AUTO-PLAY | [R] RESTART MATCH | [M] SOUND', 1, Color{ r: 220, g: 235, b: 255 })

	// Announcement Banner
	if g.celebration != '' {
		box_w := 540
		box_h := 50
		bx := (800 - box_w) / 2
		by := 215

		sdl.set_render_draw_color(renderer, 15, 20, 35, 245)
		b_rect := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 255, 215, 50, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		draw_text_centered(renderer, 400, by + 18, g.celebration, 1, Color{ r: 255, g: 230, b: 70 })
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
