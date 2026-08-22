module main

import sdl

fn draw_war_game(renderer &sdl.Renderer, g &WarGame) {
	// Deep Navy / Mahogany Split Felt Table
	sdl.set_render_draw_color(renderer, 20, 24, 38, 255)
	sdl.render_clear(renderer)

	draw_battlefield_background(renderer)
	draw_player_zones(renderer, g)
	draw_battlefield_duel(renderer, g)
	draw_hud_and_prompts(renderer, g)
}

fn draw_battlefield_background(renderer &sdl.Renderer) {
	// Top General Territory (Crimson Tint)
	top_rect := sdl.Rect{ x: 20, y: 20, w: 760, h: 260 }
	sdl.set_render_draw_color(renderer, 55, 18, 24, 255)
	sdl.render_fill_rect(renderer, &top_rect)
	sdl.set_render_draw_color(renderer, 140, 50, 60, 255)
	sdl.render_draw_rect(renderer, &top_rect)

	// Bottom Player Territory (Royal Blue Tint)
	bot_rect := sdl.Rect{ x: 20, y: 300, w: 760, h: 260 }
	sdl.set_render_draw_color(renderer, 18, 35, 65, 255)
	sdl.render_fill_rect(renderer, &bot_rect)
	sdl.set_render_draw_color(renderer, 50, 90, 160, 255)
	sdl.render_draw_rect(renderer, &bot_rect)

	// Center Demarcation Line
	sdl.set_render_draw_color(renderer, 220, 180, 50, 255)
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
		draw_stacked_deck_back(renderer, 100, 80, 70, 100, g.ai_draw_pile.len, Color{ r: 180, g: 30, b: 40 })
		draw_text_centered(renderer, 135, 190, 'DRAW (${g.ai_draw_pile.len})', 1, Color{ r: 255, g: 200, b: 200 })
	}
	// AI Capture Pile
	if g.ai_win_pile.len > 0 {
		draw_stacked_deck_back(renderer, 200, 80, 70, 100, g.ai_win_pile.len, Color{ r: 120, g: 20, b: 30 })
		draw_text_centered(renderer, 235, 190, 'CAPTURED (${g.ai_win_pile.len})', 1, Color{ r: 255, g: 180, b: 180 })
	}

	// Bottom Zone: Player
	p_tot := g.get_player_total_cards()
	draw_text(renderer, 40, 520, 'YOU (PLAYER 1)', 1, Color{ r: 150, g: 200, b: 255 })
	draw_text(renderer, 40, 535, 'TOTAL FORCES: ${p_tot} / 52 CARDS', 1, Color{ r: 220, g: 220, b: 220 })

	// Player Draw Pile Deck
	if g.player_draw_pile.len > 0 {
		draw_stacked_deck_back(renderer, 100, 390, 70, 100, g.player_draw_pile.len, Color{ r: 30, g: 80, b: 190 })
		draw_text_centered(renderer, 135, 500, 'DRAW (${g.player_draw_pile.len})', 1, Color{ r: 200, g: 220, b: 255 })
	}
	// Player Capture Pile
	if g.player_win_pile.len > 0 {
		draw_stacked_deck_back(renderer, 200, 390, 70, 100, g.player_win_pile.len, Color{ r: 20, g: 50, b: 130 })
		draw_text_centered(renderer, 235, 500, 'CAPTURED (${g.player_win_pile.len})', 1, Color{ r: 180, g: 200, b: 255 })
	}

	// Visual Tug-of-War Strength Bar (Right side)
	bar_x := 730
	bar_y := 80
	bar_w := 24
	bar_h := 410
	sdl.set_render_draw_color(renderer, 20, 20, 30, 255)
	bar_bg := sdl.Rect{ x: bar_x, y: bar_y, w: bar_w, h: bar_h }
	sdl.render_fill_rect(renderer, &bar_bg)
	sdl.set_render_draw_color(renderer, 150, 160, 180, 255)
	sdl.render_draw_rect(renderer, &bar_bg)

	// Blue share vs Red share
	p_pct := f64(p_tot) / 52.0
	p_h := int(p_pct * f64(bar_h))
	p_bar := sdl.Rect{ x: bar_x + 2, y: bar_y + bar_h - p_h + 2, w: bar_w - 4, h: p_h - 4 }
	sdl.set_render_draw_color(renderer, 40, 120, 240, 255)
	sdl.render_fill_rect(renderer, &p_bar)

	ai_h := bar_h - p_h
	ai_bar := sdl.Rect{ x: bar_x + 2, y: bar_y + 2, w: bar_w - 4, h: ai_h - 4 }
	sdl.set_render_draw_color(renderer, 220, 40, 50, 255)
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
		ai_card_y := 160
		draw_playing_card(renderer, cx - card_w / 2, ai_card_y, card_w, card_h, g.battle_ai)
		draw_text_centered(renderer, cx, ai_card_y - 18, 'GENERAL BOB: ${get_rank_str(g.battle_ai.rank)}', 1, Color{ r: 255, g: 180, b: 180 })

		// Player Active Card (Bottom center)
		p_card_y := 310
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

fn draw_playing_card(renderer &sdl.Renderer, x int, y int, w int, h int, c Card) {
	// White Card Body
	card_rect := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 250, 250, 252, 255)
	sdl.render_fill_rect(renderer, &card_rect)

	// Gold Border
	sdl.set_render_draw_color(renderer, 30, 30, 40, 255)
	sdl.render_draw_rect(renderer, &card_rect)
	inner_b := sdl.Rect{ x: x + 2, y: y + 2, w: w - 4, h: h - 4 }
	sdl.render_draw_rect(renderer, &inner_b)

	is_red := c.suit == .hearts || c.suit == .diamonds
	col := if is_red { Color{ r: 210, g: 25, b: 35 } } else { Color{ r: 20, g: 20, b: 30 } }

	rank_s := get_rank_str(c.rank)
	suit_s := match c.suit {
		.hearts { 'H' }
		.diamonds { 'D' }
		.clubs { 'C' }
		.spades { 'S' }
	}

	// Corner indicators
	draw_text(renderer, x + 6, y + 6, rank_s, 1, col)
	draw_text(renderer, x + 6, y + 18, suit_s, 1, col)

	draw_text(renderer, x + w - 16, y + h - 28, rank_s, 1, col)
	draw_text(renderer, x + w - 16, y + h - 16, suit_s, 1, col)

	// Center Large Rank & Suit Vector
	draw_text_centered(renderer, x + w / 2, y + h / 2 - 14, rank_s, 2, col)
	draw_text_centered(renderer, x + w / 2, y + h / 2 + 8, suit_s, 1, col)
}

fn draw_stacked_deck_back(renderer &sdl.Renderer, x int, y int, w int, h int, count int, c Color) {
	// Draw shadow card layers to depict stack thickness
	layers := count / 6 + 1
	for i := 0; i < layers; i++ {
		sx := x + i * 2
		sy := y - i * 2
		bg := sdl.Rect{ x: sx, y: sy, w: w, h: h }
		sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 255)
		sdl.render_fill_rect(renderer, &bg)
		sdl.set_render_draw_color(renderer, 240, 245, 255, 200)
		sdl.render_draw_rect(renderer, &bg)
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
