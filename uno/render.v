module main

import math
import sdl

fn draw_uno_game(renderer &sdl.Renderer, g &UnoGame) {
	// Table Background (Green Casino Felt)
	sdl.set_render_draw_color(renderer, 18, 65, 38, 255)
	sdl.render_clear(renderer)

	// Wood Trim Border
	sdl.set_render_draw_color(renderer, 60, 30, 15, 255)
	wood_rect := sdl.Rect{ x: 10, y: 10, w: 780, h: 580 }
	sdl.render_draw_rect(renderer, &wood_rect)
	inner_trim := sdl.Rect{ x: 12, y: 12, w: 776, h: 576 }
	sdl.render_draw_rect(renderer, &inner_trim)

	draw_table_center(renderer, g)
	draw_player_hands(renderer, g)
	draw_action_prompts(renderer, g)

	if g.state == .color_pick {
		draw_color_picker_modal(renderer)
	}
}

fn draw_table_center(renderer &sdl.Renderer, g &UnoGame) {
	cx := 400
	cy := 270

	// Center Felt Circle
	draw_filled_circle(renderer, cx, cy, 110, Color{ r: 12, g: 50, b: 28 })

	// Active Color Indicator Halo Ring
	col_rgb := get_color_rgb(g.active_color)
	draw_circle_ring(renderer, cx, cy, 108, 6, col_rgb)

	// Direction Rotation Indicator
	dir_str := if g.direction == 1 { 'ROTATION: CLOCKWISE >>' } else { '<< ROTATION: COUNTER-CW' }
	draw_text_centered(renderer, cx, cy - 85, dir_str, 1, Color{ r: 240, g: 230, b: 150 })

	// Draw Pile (Face Down Card)
	draw_pile_x := cx - 75
	draw_pile_y := cy - 50
	draw_card_back(renderer, draw_pile_x, draw_pile_y, 60, 90)
	draw_text_centered(renderer, draw_pile_x + 30, draw_pile_y + 38, 'DRAW', 1, Color{ r: 255, g: 255, b: 255 })
	draw_text_centered(renderer, draw_pile_x + 30, draw_pile_y + 52, '(${g.deck.len})', 1, Color{ r: 220, g: 220, b: 220 })

	// Discard Pile (Top Face Up Card)
	top_card := g.top_discard()
	dis_pile_x := cx + 15
	dis_pile_y := cy - 50
	draw_uno_card(renderer, dis_pile_x, dis_pile_y, 60, 90, top_card, true)

	// Active Color Badge
	col_name := match g.active_color {
		.red { 'RED' }
		.blue { 'BLUE' }
		.green { 'GREEN' }
		.yellow { 'YELLOW' }
		else { 'MULTI' }
	}
	draw_text_centered(renderer, cx, cy + 55, 'ACTIVE COLOR: ${col_name}', 1, col_rgb)
}

fn draw_player_hands(renderer &sdl.Renderer, g &UnoGame) {
	// Top Player (Bot Bob)
	draw_bot_horizontal_hand(renderer, 400, 40, &g.players[2], g.current_p_idx == 2)

	// Left Player (Bot Alice)
	draw_bot_vertical_hand(renderer, 50, 270, &g.players[1], g.current_p_idx == 1)

	// Right Player (Bot Charlie)
	draw_bot_vertical_hand(renderer, 730, 270, &g.players[3], g.current_p_idx == 3)

	// Bottom Player (Human Player 1)
	draw_human_hand(renderer, g)
}

fn draw_human_hand(renderer &sdl.Renderer, g &UnoGame) {
	p := &g.players[0]
	hand_len := p.hand.len
	if hand_len == 0 {
		return
	}

	card_w := 58
	card_h := 88
	spacing := math.min(52.0, 520.0 / f64(math.max(1, hand_len)))
	total_w := int(f64(hand_len - 1) * spacing) + card_w
	start_x := 400 - total_w / 2
	base_y := 470

	// Player Turn Indicator
	is_my_turn := g.current_p_idx == 0
	turn_col := if is_my_turn { Color{ r: 255, g: 220, b: 50 } } else { Color{ r: 200, g: 200, b: 200 } }
	draw_text_centered(renderer, 400, base_y - 25, '${p.name} - ${hand_len} CARDS ${if is_my_turn { '(YOUR TURN!)' } else { '' }}', 1, turn_col)

	for i := 0; i < hand_len; i++ {
		card := p.hand[i]
		cx := start_x + int(f64(i) * spacing)
		is_selected := i == g.selected_card
		is_playable := is_my_turn && g.is_card_playable(card)

		cy := if is_selected { base_y - 18 } else { base_y }

		draw_uno_card(renderer, cx, cy, card_w, card_h, card, is_playable)

		if is_selected {
			// Gold Selection Border
			sel_rect := sdl.Rect{ x: cx - 2, y: cy - 2, w: card_w + 4, h: card_h + 4 }
			sdl.set_render_draw_color(renderer, 255, 255, 100, 255)
			sdl.render_draw_rect(renderer, &sel_rect)
		}
	}

	// "CALL UNO!" Button on Bottom Right
	if p.hand.len <= 2 {
		uno_btn_rect := sdl.Rect{ x: 670, y: 490, w: 105, h: 42 }
		btn_col := if p.called_uno { Color{ r: 40, g: 160, b: 60 } } else { Color{ r: 220, g: 30, b: 40 } }
		sdl.set_render_draw_color(renderer, btn_col.r, btn_col.g, btn_col.b, 255)
		sdl.render_fill_rect(renderer, &uno_btn_rect)
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		sdl.render_draw_rect(renderer, &uno_btn_rect)

		btn_text := if p.called_uno { 'UNO CALLED!' } else { '[U] CALL UNO' }
		draw_text_centered(renderer, 722, 504, btn_text, 1, Color{ r: 255, g: 255, b: 255 })
	}
}

fn draw_bot_horizontal_hand(renderer &sdl.Renderer, cx int, cy int, p &UnoPlayer, is_turn bool) {
	hand_len := p.hand.len
	spacing := 16
	total_w := hand_len * spacing + 40
	start_x := cx - total_w / 2

	turn_col := if is_turn { Color{ r: 255, g: 220, b: 50 } } else { Color{ r: 200, g: 200, b: 200 } }
	draw_text_centered(renderer, cx, cy - 18, '${p.name}: ${hand_len} cards ${if p.called_uno { '[UNO!]' } else { '' }}', 1, turn_col)

	for i := 0; i < hand_len; i++ {
		draw_card_back(renderer, start_x + i * spacing, cy, 38, 54)
	}
}

fn draw_bot_vertical_hand(renderer &sdl.Renderer, cx int, cy int, p &UnoPlayer, is_turn bool) {
	hand_len := p.hand.len
	spacing := 14
	total_h := hand_len * spacing + 40
	start_y := cy - total_h / 2

	turn_col := if is_turn { Color{ r: 255, g: 220, b: 50 } } else { Color{ r: 200, g: 200, b: 200 } }
	draw_text_centered(renderer, cx, start_y - 18, '${p.name}', 1, turn_col)
	draw_text_centered(renderer, cx, start_y - 6, '(${hand_len} cards)', 1, turn_col)

	for i := 0; i < hand_len; i++ {
		draw_card_back(renderer, cx - 24, start_y + i * spacing, 48, 32)
	}
}

fn draw_uno_card(renderer &sdl.Renderer, x int, y int, w int, h int, card UnoCard, is_playable bool) {
	// Card Body Fill
	rgb := get_color_rgb(card.color)
	card_rect := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, rgb.r, rgb.g, rgb.b, 255)
	sdl.render_fill_rect(renderer, &card_rect)

	// Inner White Oval
	draw_filled_circle(renderer, x + w / 2, y + h / 2, int(f64(w) * 0.38), Color{ r: 255, g: 255, b: 255 })

	// Card Label Symbol
	sym_str := get_card_symbol_str(card.typ)
	sym_col := if card.color == .wild_color { Color{ r: 30, g: 30, b: 40 } } else { rgb }
	draw_text_centered(renderer, x + w / 2, y + h / 2 - 4, sym_str, 1, sym_col)

	// Top Left & Bottom Right Corner Symbols
	draw_text(renderer, x + 4, y + 4, sym_str, 1, Color{ r: 255, g: 255, b: 255 })
	draw_text(renderer, x + w - 12, y + h - 12, sym_str, 1, Color{ r: 255, g: 255, b: 255 })

	// Card Border
	border_col := if is_playable { Color{ r: 255, g: 255, b: 255 } } else { Color{ r: 120, g: 120, b: 120 } }
	sdl.set_render_draw_color(renderer, border_col.r, border_col.g, border_col.b, 255)
	sdl.render_draw_rect(renderer, &card_rect)
}

fn draw_card_back(renderer &sdl.Renderer, x int, y int, w int, h int) {
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 20, 20, 25, 255)
	sdl.render_fill_rect(renderer, &bg)

	// Red Center Oval
	draw_filled_circle(renderer, x + w / 2, y + h / 2, int(f64(w) * 0.36), Color{ r: 220, g: 35, b: 45 })
	draw_text_centered(renderer, x + w / 2, y + h / 2 - 4, 'UNO', 1, Color{ r: 255, g: 220, b: 50 })

	sdl.set_render_draw_color(renderer, 220, 225, 235, 255)
	sdl.render_draw_rect(renderer, &bg)
}

fn get_color_rgb(col UnoColor) Color {
	return match col {
		.red { Color{ r: 225, g: 35, b: 45 } }
		.blue { Color{ r: 35, g: 110, b: 225 } }
		.green { Color{ r: 45, g: 175, b: 55 } }
		.yellow { Color{ r: 235, g: 195, b: 25 } }
		.wild_color { Color{ r: 30, g: 30, b: 35 } }
	}
}

fn get_card_symbol_str(typ UnoCardType) string {
	return match typ {
		.num_0 { '0' }
		.num_1 { '1' }
		.num_2 { '2' }
		.num_3 { '3' }
		.num_4 { '4' }
		.num_5 { '5' }
		.num_6 { '6' }
		.num_7 { '7' }
		.num_8 { '8' }
		.num_9 { '9' }
		.skip { 'SKP' }
		.reverse { 'REV' }
		.draw_two { '+2' }
		.wild { 'WLD' }
		.wild_draw_four { '+4' }
	}
}

fn draw_action_prompts(renderer &sdl.Renderer, g &UnoGame) {
	// Bottom Controls Bar
	bar_rect := sdl.Rect{ x: 20, y: 568, w: 760, h: 26 }
	sdl.set_render_draw_color(renderer, 10, 35, 20, 240)
	sdl.render_fill_rect(renderer, &bar_rect)
	draw_text_centered(renderer, 400, 574, '[A/D or ARROWS] SELECT CARD | [SPACE/ENTER] PLAY | [D] DRAW CARD | [U] CALL UNO | [M] SOUND', 1, Color{ r: 220, g: 235, b: 255 })

	// Celebration / Announcement Banner
	if g.celebration != '' {
		box_w := 540
		box_h := 45
		bx := (800 - box_w) / 2
		by := 220

		sdl.set_render_draw_color(renderer, 15, 20, 35, 240)
		b_rect := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 255, 220, 50, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		draw_text_centered(renderer, 400, by + 16, g.celebration, 1, Color{ r: 255, g: 235, b: 80 })
	}
}

fn draw_color_picker_modal(renderer &sdl.Renderer) {
	mx := 260
	my := 170
	mw := 280
	mh := 180

	sdl.set_render_draw_color(renderer, 15, 20, 30, 245)
	bg := sdl.Rect{ x: mx, y: my, w: mw, h: mh }
	sdl.render_fill_rect(renderer, &bg)
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	sdl.render_draw_rect(renderer, &bg)

	draw_text_centered(renderer, 400, my + 15, 'CHOOSE ACTIVE COLOR', 1, Color{ r: 255, g: 255, b: 255 })

	// 4 Color quadrant buttons
	btn_w := 115
	btn_h := 50
	// 1: Red
	r_rect := sdl.Rect{ x: mx + 15, y: my + 45, w: btn_w, h: btn_h }
	sdl.set_render_draw_color(renderer, 225, 35, 45, 255)
	sdl.render_fill_rect(renderer, &r_rect)
	draw_text_centered(renderer, mx + 15 + btn_w / 2, my + 63, '[1] RED', 1, Color{ r: 255, g: 255, b: 255 })

	// 2: Blue
	b_rect := sdl.Rect{ x: mx + 150, y: my + 45, w: btn_w, h: btn_h }
	sdl.set_render_draw_color(renderer, 35, 110, 225, 255)
	sdl.render_fill_rect(renderer, &b_rect)
	draw_text_centered(renderer, mx + 150 + btn_w / 2, my + 63, '[2] BLUE', 1, Color{ r: 255, g: 255, b: 255 })

	// 3: Green
	g_rect := sdl.Rect{ x: mx + 15, y: my + 110, w: btn_w, h: btn_h }
	sdl.set_render_draw_color(renderer, 45, 175, 55, 255)
	sdl.render_fill_rect(renderer, &g_rect)
	draw_text_centered(renderer, mx + 15 + btn_w / 2, my + 128, '[3] GREEN', 1, Color{ r: 255, g: 255, b: 255 })

	// 4: Yellow
	y_rect := sdl.Rect{ x: mx + 150, y: my + 110, w: btn_w, h: btn_h }
	sdl.set_render_draw_color(renderer, 235, 195, 25, 255)
	sdl.render_fill_rect(renderer, &y_rect)
	draw_text_centered(renderer, mx + 150 + btn_w / 2, my + 128, '[4] YELLOW', 1, Color{ r: 255, g: 255, b: 255 })
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
