module main

import math
import sdl

fn draw_uno_game(renderer &sdl.Renderer, g &UnoGame) {
	// Table Background (Green Casino Felt with Vignette)
	draw_uno_table_background(renderer)

	draw_table_center(renderer, g)
	draw_player_hands(renderer, g)
	draw_action_prompts(renderer, g)

	if g.state == .color_pick {
		draw_color_picker_modal(renderer)
	}
}

fn draw_uno_table_background(renderer &sdl.Renderer) {
	for y := 0; y < 600; y += 4 {
		shade := u8(14 + (y * 8) / 600)
		sdl.set_render_draw_color(renderer, shade - 2, shade + 48, shade + 22, 255)
		rect := sdl.Rect{ x: 0, y: y, w: 800, h: 4 }
		sdl.render_fill_rect(renderer, &rect)
	}

	// Wood Trim Border
	sdl.set_render_draw_color(renderer, 55, 26, 14, 255)
	wood_rect := sdl.Rect{ x: 8, y: 8, w: 784, h: 584 }
	sdl.render_draw_rect(renderer, &wood_rect)
	sdl.set_render_draw_color(renderer, 85, 42, 22, 255)
	inner_trim := sdl.Rect{ x: 10, y: 10, w: 780, h: 580 }
	sdl.render_draw_rect(renderer, &inner_trim)
}

fn draw_table_center(renderer &sdl.Renderer, g &UnoGame) {
	cx := 400
	cy := 270

	// Center Felt Circle with Depth Ring
	draw_filled_circle(renderer, cx, cy, 112, Color{ r: 10, g: 45, b: 24 })

	// Active Color Indicator Halo Ring
	col_rgb := get_color_rgb(g.active_color)
	draw_circle_ring(renderer, cx, cy, 110, 6, col_rgb)
	draw_circle_ring(renderer, cx, cy, 114, 1, Color{ r: 255, g: 255, b: 255, a: 160 })

	// Direction Rotation Indicator
	dir_str := if g.direction == 1 { 'ROTATION: CLOCKWISE >>' } else { '<< ROTATION: COUNTER-CW' }
	draw_text_centered(renderer, cx, cy - 85, dir_str, 1, Color{ r: 240, g: 230, b: 150 })

	// Draw Pile (Stacked Face Down Cards)
	draw_pile_x := cx - 78
	draw_pile_y := cy - 48
	card_w := 62
	card_h := 92

	// Deck thickness shadows
	draw_card_back(renderer, draw_pile_x + 2, draw_pile_y - 2, card_w, card_h)
	draw_card_back(renderer, draw_pile_x, draw_pile_y, card_w, card_h)

	draw_text_centered(renderer, draw_pile_x + card_w / 2, draw_pile_y + card_h + 8, 'DECK (${g.deck.len})', 1, Color{ r: 220, g: 235, b: 255 })

	// Discard Pile (Top Face Up Card)
	top_card := g.top_discard()
	dis_pile_x := cx + 16
	dis_pile_y := cy - 48
	draw_uno_card(renderer, dis_pile_x, dis_pile_y, card_w, card_h, top_card, true)

	// Active Color Badge Banner
	col_name := match g.active_color {
		.red        { 'RED' }
		.blue       { 'BLUE' }
		.green      { 'GREEN' }
		.yellow     { 'YELLOW' }
		.wild_color { 'ANY COLOR' }
	}
	draw_text_centered(renderer, cx, cy + 62, 'ACTIVE COLOR: ${col_name}', 1, col_rgb)
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

	card_w := 62
	card_h := 92
	spacing := math.min(54.0, 540.0 / f64(math.max(1, hand_len)))
	total_w := int(f64(hand_len - 1) * spacing) + card_w
	start_x := 400 - total_w / 2
	base_y := 465

	// Player Turn Indicator
	is_my_turn := g.current_p_idx == 0
	turn_col := if is_my_turn { Color{ r: 255, g: 220, b: 50 } } else { Color{ r: 200, g: 200, b: 200 } }
	draw_text_centered(renderer, 400, base_y - 25, '${p.name} - ${hand_len} CARDS ${if is_my_turn { '(YOUR TURN!)' } else { '' }}', 1, turn_col)

	for i := 0; i < hand_len; i++ {
		card := p.hand[i]
		cx := start_x + int(f64(i) * spacing)
		is_selected := i == g.selected_card
		is_playable := is_my_turn && g.is_card_playable(card)

		cy := if is_selected { base_y - 20 } else { base_y }

		draw_uno_card(renderer, cx, cy, card_w, card_h, card, is_playable)

		if is_selected {
			// Glowing Gold Selection Border
			sel_rect := sdl.Rect{ x: cx - 2, y: cy - 2, w: card_w + 4, h: card_h + 4 }
			sdl.set_render_draw_color(renderer, 255, 235, 60, 255)
			sdl.render_draw_rect(renderer, &sel_rect)
			sel_inner := sdl.Rect{ x: cx - 3, y: cy - 3, w: card_w + 6, h: card_h + 6 }
			sdl.render_draw_rect(renderer, &sel_inner)
		}
	}

	// "CALL UNO!" Button on Bottom Right
	if p.hand.len <= 2 {
		uno_btn_rect := sdl.Rect{ x: 670, y: 490, w: 105, h: 42 }
		btn_col := if p.called_uno { Color{ r: 35, g: 160, b: 65 } } else { Color{ r: 220, g: 30, b: 40 } }
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

// -------------------------------------------------------------
// 16-Bit UNO Card Graphics
// -------------------------------------------------------------

fn draw_uno_card(renderer &sdl.Renderer, x int, y int, w int, h int, card UnoCard, is_playable bool) {
	// Drop Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 100)
	shadow := sdl.Rect{ x: x + 2, y: y + 3, w: w, h: h }
	sdl.render_fill_rect(renderer, &shadow)

	// White Card Base Border
	base_rect := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 252, 252, 255, 255)
	sdl.render_fill_rect(renderer, &base_rect)

	// Primary Card Color Body (Inset 3px)
	rgb := get_color_rgb(card.color)
	body_rect := sdl.Rect{ x: x + 3, y: y + 3, w: w - 6, h: h - 6 }
	sdl.set_render_draw_color(renderer, rgb.r, rgb.g, rgb.b, 255)
	sdl.render_fill_rect(renderer, &body_rect)

	// Inner Elliptical Center Badge
	cx := x + w / 2
	cy := y + h / 2

	if card.color == .wild_color {
		// Wild Card: 4-Quadrant Color Disc Center
		draw_wild_quadrant_disc(renderer, cx, cy, int(f64(w) * 0.32))
	} else {
		// Standard White Center Oval
		draw_filled_circle(renderer, cx, cy, int(f64(w) * 0.30), Color{ r: 255, g: 255, b: 255 })
		draw_circle_ring(renderer, cx, cy, int(f64(w) * 0.30), 1, Color{ r: 220, g: 220, b: 225 })
	}

	// Center Card Symbol Artwork
	draw_uno_symbol_artwork(renderer, cx, cy, card.typ, card.color, w)

	// Top-Left & Bottom-Right Corner Symbols
	sym_str := get_card_symbol_str(card.typ)
	corner_col := if card.color == .wild_color { Color{ r: 255, g: 215, b: 0 } } else { Color{ r: 255, g: 255, b: 255 } }

	draw_text(renderer, x + 5, y + 4, sym_str, 1, corner_col)
	draw_text(renderer, x + w - 12, y + h - 12, sym_str, 1, corner_col)

	// Outer Playable Highlight / Dim Outline
	border_col := if is_playable { Color{ r: 255, g: 255, b: 255 } } else { Color{ r: 80, g: 85, b: 95 } }
	sdl.set_render_draw_color(renderer, border_col.r, border_col.g, border_col.b, 255)
	sdl.render_draw_rect(renderer, &base_rect)
}

fn draw_uno_symbol_artwork(renderer &sdl.Renderer, cx int, cy int, typ UnoCardType, col UnoColor, _w int) {
	match typ {
		.num_0, .num_1, .num_2, .num_3, .num_4, .num_5, .num_6, .num_7, .num_8, .num_9 {
			num_str := get_card_symbol_str(typ)
			txt_col := get_color_rgb(col)
			draw_text_centered(renderer, cx + 1, cy - 7, num_str, 2, Color{ r: 180, g: 180, b: 180 })
			draw_text_centered(renderer, cx, cy - 8, num_str, 2, txt_col)
		}
		.skip {
			// Prohibition Slash Circle (⊘)
			draw_circle_ring(renderer, cx, cy, 11, 2, Color{ r: 225, g: 35, b: 45 })
			sdl.set_render_draw_color(renderer, 225, 35, 45, 255)
			sdl.render_draw_line(renderer, cx - 7, cy + 7, cx + 7, cy - 7)
			sdl.render_draw_line(renderer, cx - 7, cy + 6, cx + 6, cy - 7)
		}
		.reverse {
			// Looping Twin Arrows (⇄)
			sdl.set_render_draw_color(renderer, 0, 115, 220, 255)
			// Top right arrow
			sdl.render_draw_line(renderer, cx - 8, cy - 4, cx + 6, cy - 4)
			sdl.render_draw_line(renderer, cx + 6, cy - 4, cx + 2, cy - 8)
			sdl.render_draw_line(renderer, cx + 6, cy - 4, cx + 2, cy)
			// Bottom left arrow
			sdl.render_draw_line(renderer, cx + 8, cy + 4, cx - 6, cy + 4)
			sdl.render_draw_line(renderer, cx - 6, cy + 4, cx - 2, cy)
			sdl.render_draw_line(renderer, cx - 6, cy + 4, cx - 2, cy + 8)
		}
		.draw_two {
			// Stacked Mini Cards +2
			sdl.set_render_draw_color(renderer, 40, 170, 60, 255)
			c1 := sdl.Rect{ x: cx - 9, y: cy - 9, w: 10, h: 14 }
			c2 := sdl.Rect{ x: cx - 4, y: cy - 5, w: 10, h: 14 }
			sdl.render_fill_rect(renderer, &c1)
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_draw_rect(renderer, &c1)
			sdl.set_render_draw_color(renderer, 40, 170, 60, 255)
			sdl.render_fill_rect(renderer, &c2)
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_draw_rect(renderer, &c2)
			draw_text_centered(renderer, cx + 8, cy - 4, '+2', 1, Color{ r: 255, g: 255, b: 255 })
		}
		.wild {
			// Center "WILD" Gold Banner
			draw_text_centered(renderer, cx + 1, cy - 3, 'WILD', 1, Color{ r: 10, g: 10, b: 15 })
			draw_text_centered(renderer, cx, cy - 4, 'WILD', 1, Color{ r: 255, g: 255, b: 255 })
		}
		.wild_draw_four {
			// +4 Badge in Center of 4-Color Disc
			draw_text_centered(renderer, cx + 1, cy - 5, '+4', 2, Color{ r: 10, g: 10, b: 15 })
			draw_text_centered(renderer, cx, cy - 6, '+4', 2, Color{ r: 255, g: 255, b: 255 })
		}
	}
}

fn draw_wild_quadrant_disc(renderer &sdl.Renderer, cx int, cy int, r int) {
	for dy := -r; dy <= r; dy++ {
		for dx := -r; dx <= r; dx++ {
			if dx * dx + dy * dy <= r * r {
				col := if dx < 0 && dy < 0 {
					Color{ r: 225, g: 35, b: 45 } // Top-left: Red
				} else if dx >= 0 && dy < 0 {
					Color{ r: 35, g: 110, b: 225 } // Top-right: Blue
				} else if dx < 0 && dy >= 0 {
					Color{ r: 235, g: 195, b: 25 } // Bottom-left: Yellow
				} else {
					Color{ r: 45, g: 175, b: 55 } // Bottom-right: Green
				}
				sdl.set_render_draw_color(renderer, col.r, col.g, col.b, 255)
				sdl.render_draw_point(renderer, cx + dx, cy + dy)
			}
		}
	}
	draw_circle_ring(renderer, cx, cy, r, 1, Color{ r: 255, g: 255, b: 255 })
}

fn draw_card_back(renderer &sdl.Renderer, x int, y int, w int, h int) {
	// Drop Shadow
	sdl.set_render_draw_color(renderer, 0, 0, 0, 90)
	shadow := sdl.Rect{ x: x + 2, y: y + 3, w: w, h: h }
	sdl.render_fill_rect(renderer, &shadow)

	// White Border Base
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 250, 250, 255, 255)
	sdl.render_fill_rect(renderer, &bg)

	// Obsidian Black Body
	inner := sdl.Rect{ x: x + 2, y: y + 2, w: w - 4, h: h - 4 }
	sdl.set_render_draw_color(renderer, 20, 22, 28, 255)
	sdl.render_fill_rect(renderer, &inner)

	// Crimson Center Oval
	cx := x + w / 2
	cy := y + h / 2
	draw_filled_circle(renderer, cx, cy, int(f64(w) * 0.32), Color{ r: 220, g: 30, b: 42 })

	// "UNO" 3D Shadowed Gold Logo
	draw_text_centered(renderer, cx + 1, cy - 3, 'UNO', 1, Color{ r: 30, g: 15, b: 0 })
	draw_text_centered(renderer, cx, cy - 4, 'UNO', 1, Color{ r: 255, g: 215, b: 45 })
}

fn get_color_rgb(col UnoColor) Color {
	return match col {
		.red        { Color{ r: 225, g: 35, b: 45 } }
		.blue       { Color{ r: 30, g: 115, b: 225 } }
		.green      { Color{ r: 40, g: 170, b: 60 } }
		.yellow     { Color{ r: 240, g: 195, b: 25 } }
		.wild_color { Color{ r: 28, g: 30, b: 36 } }
	}
}

fn get_card_symbol_str(typ UnoCardType) string {
	return match typ {
		.num_0          { '0' }
		.num_1          { '1' }
		.num_2          { '2' }
		.num_3          { '3' }
		.num_4          { '4' }
		.num_5          { '5' }
		.num_6          { '6' }
		.num_7          { '7' }
		.num_8          { '8' }
		.num_9          { '9' }
		.skip           { '⊘' }
		.reverse        { '⇄' }
		.draw_two       { '+2' }
		.wild           { 'W' }
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
	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
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
