module main

import math
import sdl

fn draw_slots_game(renderer &sdl.Renderer, g &SlotsGame) {
	// Deep Casino Floor Carpet
	sdl.set_render_draw_color(renderer, 16, 12, 24, 255)
	sdl.render_clear(renderer)

	draw_casino_cabinet(renderer, g)
	draw_marquee_jackpot(renderer, g)
	draw_reels(renderer, g)
	draw_winning_paylines(renderer, g)
	draw_pull_lever(renderer, g)
	draw_control_console(renderer, g)
	draw_coin_particles(renderer, g)
	draw_celebration_banner(renderer, g)

	if g.show_paytable {
		draw_paytable_modal(renderer, g)
	}
}

fn draw_casino_cabinet(renderer &sdl.Renderer, _ &SlotsGame) {
	// Machine Outer Chassis (Deep Burgundy / Gold Trim)
	cab_x := 100
	cab_y := 20
	cab_w := 600
	cab_h := 560

	// Chassis Body
	sdl.set_render_draw_color(renderer, 45, 15, 25, 255)
	cab_rect := sdl.Rect{ x: cab_x, y: cab_y, w: cab_w, h: cab_h }
	sdl.render_fill_rect(renderer, &cab_rect)

	// Gold Rim Bezel
	sdl.set_render_draw_color(renderer, 220, 175, 45, 255)
	sdl.render_draw_rect(renderer, &cab_rect)
	inner_bezel := sdl.Rect{ x: cab_x + 4, y: cab_y + 4, w: cab_w - 8, h: cab_h - 8 }
	sdl.render_draw_rect(renderer, &inner_bezel)

	// Side Chrome Pillars
	sdl.set_render_draw_color(renderer, 180, 190, 210, 255)
	pillar_l := sdl.Rect{ x: cab_x + 8, y: cab_y + 80, w: 16, h: 420 }
	pillar_r := sdl.Rect{ x: cab_x + cab_w - 24, y: cab_y + 80, w: 16, h: 420 }
	sdl.render_fill_rect(renderer, &pillar_l)
	sdl.render_fill_rect(renderer, &pillar_r)
}

fn draw_marquee_jackpot(renderer &sdl.Renderer, g &SlotsGame) {
	// Top Glowing Marquee Sign
	mx := 140
	my := 32
	mw := 520
	mh := 80

	sdl.set_render_draw_color(renderer, 15, 10, 30, 255)
	m_rect := sdl.Rect{ x: mx, y: my, w: mw, h: mh }
	sdl.render_fill_rect(renderer, &m_rect)

	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	sdl.render_draw_rect(renderer, &m_rect)

	// Title text
	title_str := if g.theme == .vegas_classic { '★ VEGAS CLASSIC 777 ★' } else { '⚡ NEON CYBER SLOTS ⚡' }
	draw_text_centered(renderer, mx + mw / 2, my + 10, title_str, 2, Color{ r: 255, g: 220, b: 50 })

	// Progressive Jackpot Digital LED Meter
	jackpot_str := 'PROGRESSIVE JACKPOT: $${g.progressive_jackpot}'
	draw_text_centered(renderer, mx + mw / 2, my + 42, jackpot_str, 1, Color{ r: 255, g: 50, b: 50 })

	// Marquee Chaser Bulbs along perimeter
	bulb_time := sdl.get_ticks() / 150
	for i := 0; i < 20; i++ {
		bx := mx + 10 + i * 26
		is_lit := (i + int(bulb_time)) % 3 == 0
		col := if is_lit { Color{ r: 255, g: 255, b: 100 } } else { Color{ r: 120, g: 100, b: 30 } }
		b_rect := sdl.Rect{ x: bx, y: my + 64, w: 6, h: 6 }
		sdl.set_render_draw_color(renderer, col.r, col.g, col.b, 255)
		sdl.render_fill_rect(renderer, &b_rect)
	}
}

fn draw_reels(renderer &sdl.Renderer, g &SlotsGame) {
	// Glass Reel Display Window
	rx := int(g.grid_x)
	ry := int(g.grid_y)
	rw := int(f64(g.num_reels) * g.reel_w)
	rh := int(f64(g.visible_rows) * g.row_h)

	// Glass background
	sdl.set_render_draw_color(renderer, 245, 245, 250, 255)
	glass_rect := sdl.Rect{ x: rx - 6, y: ry - 6, w: rw + 12, h: rh + 12 }
	sdl.render_fill_rect(renderer, &glass_rect)

	sdl.set_render_draw_color(renderer, 30, 30, 40, 255)
	sdl.render_draw_rect(renderer, &glass_rect)

	// Clip reel symbols to window
	clip_rect := sdl.Rect{ x: rx, y: ry, w: rw, h: rh }
	sdl.render_set_clip_rect(renderer, &clip_rect)

	for r := 0; r < g.num_reels; r++ {
		reel := g.reels[r]
		reel_x := rx + int(f64(r) * g.reel_w)

		// Reel separator lines
		sdl.set_render_draw_color(renderer, 200, 205, 215, 255)
		sdl.render_draw_line(renderer, reel_x, ry, reel_x, ry + rh)

		// Draw symbols currently rolling in this reel strip
		strip_count := reel.symbols.len
		base_idx := int(reel.offset_y / g.row_h)
		sub_offset := math.fmod(reel.offset_y, g.row_h)

		for i := -1; i <= g.visible_rows + 1; i++ {
			sym_idx := (base_idx + i + strip_count * 10) % strip_count
			sym := reel.symbols[sym_idx]
			sym_y := ry + int(f64(i) * g.row_h - sub_offset)

			draw_slot_symbol(renderer, reel_x + int(g.reel_w * 0.5), sym_y + int(g.row_h * 0.5), sym)
		}

		// Hold Indicator
		if reel.hold {
			sdl.set_render_draw_color(renderer, 255, 50, 50, 160)
			hold_overlay := sdl.Rect{ x: reel_x, y: ry, w: int(g.reel_w), h: rh }
			sdl.render_fill_rect(renderer, &hold_overlay)
			draw_text_centered(renderer, reel_x + int(g.reel_w * 0.5), ry + rh / 2 - 8, 'HELD', 1, Color{ r: 255, g: 255, b: 255 })
		}
	}

	sdl.render_set_clip_rect(renderer, unsafe { nil })

	// Reel Grid Frame Border
	sdl.set_render_draw_color(renderer, 220, 175, 45, 255)
	grid_border := sdl.Rect{ x: rx - 2, y: ry - 2, w: rw + 4, h: rh + 4 }
	sdl.render_draw_rect(renderer, &grid_border)

	// Horizontal Payline Marks along row centers
	for row := 0; row < 3; row++ {
		py := ry + int((f64(row) + 0.5) * g.row_h)
		sdl.set_render_draw_color(renderer, 255, 50, 50, 120)
		sdl.render_draw_point(renderer, rx - 4, py)
		sdl.render_draw_point(renderer, rx + rw + 3, py)
	}
}

fn draw_slot_symbol(renderer &sdl.Renderer, cx int, cy int, sym SymbolType) {
	match sym {
		.cherry {
			// Twin Red Cherries with Green Stem
			draw_filled_circle(renderer, cx - 8, cy + 6, 8, Color{ r: 210, g: 25, b: 35 })
			draw_filled_circle(renderer, cx + 8, cy + 8, 8, Color{ r: 210, g: 25, b: 35 })
			// Specular shine
			sdl.set_render_draw_color(renderer, 255, 160, 170, 255)
			sdl.render_draw_point(renderer, cx - 10, cy + 4)
			sdl.render_draw_point(renderer, cx + 6, cy + 6)
			// Green Stem
			sdl.set_render_draw_color(renderer, 45, 160, 45, 255)
			sdl.render_draw_line(renderer, cx - 8, cy - 2, cx, cy - 14)
			sdl.render_draw_line(renderer, cx + 8, cy, cx, cy - 14)
		}
		.lemon {
			// Yellow Lemon oval
			draw_filled_circle(renderer, cx, cy, 14, Color{ r: 245, g: 215, b: 20 })
			draw_text_centered(renderer, cx, cy - 4, 'LEMON', 1, Color{ r: 160, g: 130, b: 0 })
		}
		.orange {
			// Vibrant Orange
			draw_filled_circle(renderer, cx, cy, 15, Color{ r: 245, g: 125, b: 20 })
			draw_filled_circle(renderer, cx, cy - 13, 3, Color{ r: 40, g: 140, b: 40 })
		}
		.plum {
			// Deep Purple Plum
			draw_filled_circle(renderer, cx, cy, 14, Color{ r: 135, g: 45, b: 165 })
			sdl.set_render_draw_color(renderer, 200, 140, 230, 255)
			sdl.render_draw_point(renderer, cx - 4, cy - 4)
		}
		.bell {
			// Liberty Bell (Golden Brass)
			draw_filled_circle(renderer, cx, cy + 2, 13, Color{ r: 240, g: 190, b: 30 })
			base_rect := sdl.Rect{ x: cx - 14, y: cy + 8, w: 28, h: 5 }
			sdl.set_render_draw_color(renderer, 210, 160, 20, 255)
			sdl.render_fill_rect(renderer, &base_rect)
			// Bell Clapper
			draw_filled_circle(renderer, cx, cy + 14, 3, Color{ r: 120, g: 80, b: 10 })
		}
		.bar_single {
			// Blue 1-BAR Plaque
			b_rect := sdl.Rect{ x: cx - 22, y: cy - 10, w: 44, h: 20 }
			sdl.set_render_draw_color(renderer, 35, 75, 180, 255)
			sdl.render_fill_rect(renderer, &b_rect)
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_draw_rect(renderer, &b_rect)
			draw_text_centered(renderer, cx, cy - 4, 'BAR', 1, Color{ r: 255, g: 255, b: 255 })
		}
		.bar_double {
			// Red 2-BAR Plaque
			b_rect := sdl.Rect{ x: cx - 24, y: cy - 11, w: 48, h: 22 }
			sdl.set_render_draw_color(renderer, 210, 35, 45, 255)
			sdl.render_fill_rect(renderer, &b_rect)
			sdl.set_render_draw_color(renderer, 255, 220, 50, 255)
			sdl.render_draw_rect(renderer, &b_rect)
			draw_text_centered(renderer, cx, cy - 4, '2-BAR', 1, Color{ r: 255, g: 255, b: 255 })
		}
		.bar_triple {
			// Gold 3-BAR Plaque
			b_rect := sdl.Rect{ x: cx - 26, y: cy - 12, w: 52, h: 24 }
			sdl.set_render_draw_color(renderer, 220, 165, 20, 255)
			sdl.render_fill_rect(renderer, &b_rect)
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_draw_rect(renderer, &b_rect)
			draw_text_centered(renderer, cx, cy - 4, '3-BAR', 1, Color{ r: 20, g: 20, b: 30 })
		}
		.seven {
			// Lucky Red 777
			draw_text_centered(renderer, cx, cy - 12, '7', 3, Color{ r: 230, g: 25, b: 35 })
		}
		.diamond {
			// Sparkling Cyan Diamond
			sdl.set_render_draw_color(renderer, 30, 220, 255, 255)
			d_size := 14
			sdl.render_draw_line(renderer, cx, cy - d_size, cx + d_size, cy)
			sdl.render_draw_line(renderer, cx + d_size, cy, cx, cy + d_size)
			sdl.render_draw_line(renderer, cx, cy + d_size, cx - d_size, cy)
			sdl.render_draw_line(renderer, cx - d_size, cy, cx, cy - d_size)
			draw_text_centered(renderer, cx, cy - 3, '$$', 1, Color{ r: 255, g: 255, b: 255 })
		}
		.wild {
			// Rainbow Wild Badge
			w_rect := sdl.Rect{ x: cx - 24, y: cy - 12, w: 48, h: 24 }
			sdl.set_render_draw_color(renderer, 180, 40, 220, 255)
			sdl.render_fill_rect(renderer, &w_rect)
			sdl.set_render_draw_color(renderer, 255, 255, 100, 255)
			sdl.render_draw_rect(renderer, &w_rect)
			draw_text_centered(renderer, cx, cy - 4, 'WILD', 1, Color{ r: 255, g: 255, b: 255 })
		}
		.scatter {
			// Golden Star Scatter Badge
			draw_filled_circle(renderer, cx, cy, 15, Color{ r: 255, g: 200, b: 20 })
			draw_text_centered(renderer, cx, cy - 4, 'SCAT', 1, Color{ r: 10, g: 10, b: 20 })
		}
	}
}

fn draw_winning_paylines(renderer &sdl.Renderer, g &SlotsGame) {
	if g.is_spinning || g.winning_lines.len == 0 {
		return
	}

	rx := g.grid_x
	ry := g.grid_y

	for w in g.winning_lines {
		sdl.set_render_draw_color(renderer, 255, 225, 0, 240)

		// Connect cell centers with glowing line
		for i := 0; i < w.positions.len - 1; i++ {
			p1 := w.positions[i]
			p2 := w.positions[i + 1]

			x1 := int(rx + (f64(p1.reel) + 0.5) * g.reel_w)
			y1 := int(ry + (f64(p1.row) + 0.5) * g.row_h)
			x2 := int(rx + (f64(p2.reel) + 0.5) * g.reel_w)
			y2 := int(ry + (f64(p2.row) + 0.5) * g.row_h)

			sdl.render_draw_line(renderer, x1, y1, x2, y2)
			sdl.render_draw_line(renderer, x1, y1 + 1, x2, y2 + 1)
			sdl.render_draw_line(renderer, x1, y1 - 1, x2, y2 - 1)
		}

		// Box highlight on winning cells
		for p in w.positions {
			cx := int(rx + f64(p.reel) * g.reel_w)
			cy := int(ry + f64(p.row) * g.row_h)
			box := sdl.Rect{ x: cx + 4, y: cy + 4, w: int(g.reel_w) - 8, h: int(g.row_h) - 8 }
			sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
			sdl.render_draw_rect(renderer, &box)
		}
	}
}

fn draw_pull_lever(renderer &sdl.Renderer, g &SlotsGame) {
	// Mechanical Side Lever on right of machine
	base_x := 700
	pivot_y := 300

	// Housing Base
	sdl.set_render_draw_color(renderer, 80, 85, 95, 255)
	b_rect := sdl.Rect{ x: base_x, y: pivot_y - 20, w: 22, h: 40 }
	sdl.render_fill_rect(renderer, &b_rect)

	// Arm movement based on lever_pos (0.0 straight up, 1.0 down)
	arm_angle := -0.6 + g.lever_pos * 1.4
	arm_len := 90.0
	tip_x := f64(base_x + 10) + math.cos(arm_angle) * arm_len
	tip_y := f64(pivot_y) + math.sin(arm_angle) * arm_len

	// Chrome Shaft
	sdl.set_render_draw_color(renderer, 200, 210, 230, 255)
	sdl.render_draw_line(renderer, base_x + 10, pivot_y, int(tip_x), int(tip_y))
	sdl.render_draw_line(renderer, base_x + 11, pivot_y, int(tip_x) + 1, int(tip_y))

	// Red Grip Knob
	draw_filled_circle(renderer, int(tip_x), int(tip_y), 13, Color{ r: 230, g: 30, b: 40 })
	draw_filled_circle(renderer, int(tip_x) - 3, int(tip_y) - 3, 3, Color{ r: 255, g: 150, b: 160 })
}

fn draw_control_console(renderer &sdl.Renderer, g &SlotsGame) {
	panel_x := 120
	panel_y := 430
	panel_w := 560
	panel_h := 130

	// Lower Console Housing
	sdl.set_render_draw_color(renderer, 25, 10, 20, 255)
	con_rect := sdl.Rect{ x: panel_x, y: panel_y, w: panel_w, h: panel_h }
	sdl.render_fill_rect(renderer, &con_rect)

	sdl.set_render_draw_color(renderer, 220, 175, 45, 255)
	sdl.render_draw_rect(renderer, &con_rect)

	// Meters: Balance, Total Bet, Win
	total_bet := g.bet_per_line * g.active_lines

	// Balance LED Box
	draw_meter_box(renderer, panel_x + 15, panel_y + 12, 120, 36, 'CREDITS', '$${g.balance}', Color{ r: 0, g: 255, b: 180 })
	// Bet LED Box
	draw_meter_box(renderer, panel_x + 145, panel_y + 12, 120, 36, 'TOTAL BET', '$${total_bet}', Color{ r: 255, g: 215, b: 0 })
	// Win LED Box
	draw_meter_box(renderer, panel_x + 275, panel_y + 12, 120, 36, 'WIN PAID', '$${g.last_win}', Color{ r: 255, g: 50, b: 80 })
	// Free Spins Box
	if g.free_spins > 0 {
		draw_meter_box(renderer, panel_x + 405, panel_y + 12, 135, 36, 'FREE SPINS', '${g.free_spins} (3X)', Color{ r: 255, g: 120, b: 240 })
	} else {
		draw_meter_box(renderer, panel_x + 405, panel_y + 12, 135, 36, 'LINES', '${g.active_lines}', Color{ r: 100, g: 200, b: 255 })
	}

	// Buttons Row (Hold / Bet / Lines / Spin)
	btn_y := panel_y + 60
	draw_button(renderer, panel_x + 15, btn_y, 75, 30, '[UP/DN] BET', Color{ r: 40, g: 60, b: 110 })
	draw_button(renderer, panel_x + 100, btn_y, 85, 30, '[L/R] LINES', Color{ r: 40, g: 60, b: 110 })
	draw_button(renderer, panel_x + 195, btn_y, 75, 30, '[M] MAX', Color{ r: 160, g: 90, b: 20 })
	draw_button(renderer, panel_x + 280, btn_y, 65, 30, '[TAB] PAY', Color{ r: 70, g: 45, b: 95 })
	draw_button(renderer, panel_x + 355, btn_y, 65, 30, '[T] THEME', Color{ r: 35, g: 95, b: 65 })
	draw_button(renderer, panel_x + 430, btn_y, 110, 30, '[SPACE] SPIN', Color{ r: 200, g: 35, b: 45 })

	// Bottom Hotkeys Guide
	draw_text_centered(renderer, 400, panel_y + 105, '[SPACE/CLICK LEVER] SPIN | [1-3] HOLD | [C] INSERT $$ | [M] SOUND', 1, Color{ r: 180, g: 190, b: 210 })
}

fn draw_meter_box(renderer &sdl.Renderer, x int, y int, w int, h int, label string, val string, val_col Color) {
	bg := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, 10, 10, 15, 255)
	sdl.render_fill_rect(renderer, &bg)
	sdl.set_render_draw_color(renderer, 80, 85, 100, 255)
	sdl.render_draw_rect(renderer, &bg)

	draw_text_centered(renderer, x + w / 2, y + 3, label, 1, Color{ r: 160, g: 175, b: 195 })
	draw_text_centered(renderer, x + w / 2, y + 16, val, 1, val_col)
}

fn draw_button(renderer &sdl.Renderer, x int, y int, w int, h int, label string, c Color) {
	btn_rect := sdl.Rect{ x: x, y: y, w: w, h: h }
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 255)
	sdl.render_fill_rect(renderer, &btn_rect)

	sdl.set_render_draw_color(renderer, 240, 245, 255, 200)
	sdl.render_draw_rect(renderer, &btn_rect)

	draw_text_centered(renderer, x + w / 2, y + 8, label, 1, Color{ r: 255, g: 255, b: 255 })
}

fn draw_coin_particles(renderer &sdl.Renderer, g &SlotsGame) {
	for p in g.particles {
		px := int(p.x)
		py := int(p.y)
		r := p.size

		// Rotating Gold Coin Oval
		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		draw_filled_circle(renderer, px, py, r, Color{ r: 255, g: 215, b: 0 })

		sdl.set_render_draw_color(renderer, 220, 160, 20, 255)
		draw_circle_wire(renderer, px, py, r, Color{ r: 220, g: 160, b: 20 })
	}
}

fn draw_celebration_banner(renderer &sdl.Renderer, g &SlotsGame) {
	if g.celebration != '' {
		box_w := 500
		box_h := 60
		bx := (800 - box_w) / 2
		by := 250

		sdl.set_render_draw_color(renderer, 15, 18, 30, 245)
		b_rect := sdl.Rect{ x: bx, y: by, w: box_w, h: box_h }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		draw_text_centered(renderer, 400, by + 20, g.celebration, 2, Color{ r: 255, g: 220, b: 50 })
	}
}

fn draw_paytable_modal(renderer &sdl.Renderer, _ &SlotsGame) {
	// Full Screen Paytable Overlay
	pw := 560
	ph := 440
	px := (800 - pw) / 2
	py := (600 - ph) / 2

	sdl.set_render_draw_color(renderer, 10, 14, 25, 250)
	bg_rect := sdl.Rect{ x: px, y: py, w: pw, h: ph }
	sdl.render_fill_rect(renderer, &bg_rect)

	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	sdl.render_draw_rect(renderer, &bg_rect)

	draw_text_centered(renderer, 400, py + 16, '★ OFFICIAL PAYTABLE & MULTIPLIERS ★', 2, Color{ r: 255, g: 215, b: 0 })

	lines := [
		'DIAMOND ($$):  5x = 1000x  |  4x = 250x  |  3x = 60x  (3-REEL: 500x)',
		'LUCKY 7 (7):   5x = 500x   |  4x = 150x  |  3x = 40x  (3-REEL: 200x)',
		'TRIPLE BAR:    5x = 250x   |  4x = 80x   |  3x = 25x  (3-REEL: 100x)',
		'DOUBLE BAR:    5x = 150x   |  4x = 50x   |  3x = 15x  (3-REEL: 50x)',
		'SINGLE BAR:    5x = 100x   |  4x = 30x   |  3x = 10x  (3-REEL: 30x)',
		'ANY 3 BARS:    15x MULTIPLIER ON 3-REEL CLASSIC',
		'LIBERTY BELL:  5x = 80x    |  4x = 25x   |  3x = 8x   (3-REEL: 25x)',
		'PLUM / ORANGE: 5x = 60x/40x|  4x = 20x/15|  3x = 6x/5x',
		'CHERRY:        3x = 25x    |  2x = 5x    |  1x = 2x',
		'WILD:          SUBSTITUTES FOR ALL SYMBOLS EXCEPT SCATTER (5x = 1500x)',
		'SCATTER:       3+ ANYWHERE TRIGGERS 10-25 FREE SPINS (3X MULTIPLIER)',
	]

	for i, l in lines {
		draw_text(renderer, px + 20, py + 55 + i * 26, l, 1, Color{ r: 230, g: 240, b: 255 })
	}

	draw_text_centered(renderer, 400, py + ph - 25, 'PRESS [TAB] OR [P] TO CLOSE PAYTABLE', 1, Color{ r: 255, g: 220, b: 50 })
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

fn draw_circle_wire(renderer &sdl.Renderer, cx int, cy int, r int, c Color) {
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, c.a)
	steps := 32
	for i := 0; i < steps; i++ {
		a1 := f64(i) * 2.0 * math.pi / f64(steps)
		a2 := f64(i + 1) * 2.0 * math.pi / f64(steps)
		x1 := int(f64(cx) + math.cos(a1) * f64(r))
		y1 := int(f64(cy) + math.sin(a1) * f64(r))
		x2 := int(f64(cx) + math.cos(a2) * f64(r))
		y2 := int(f64(cy) + math.sin(a2) * f64(r))
		sdl.render_draw_line(renderer, x1, y1, x2, y2)
	}
}
