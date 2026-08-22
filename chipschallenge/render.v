module main

import math
import sdl

pub fn render_chips_game(renderer &sdl.Renderer, mut g ChipsGame, win_w int, win_h int, sound_enabled bool) {
	// 1. Dark Grey Windows Canvas Background
	sdl.set_render_draw_color(renderer, 192, 192, 192, 255)
	clear_rect := sdl.Rect{0, 0, win_w, win_h}
	sdl.render_fill_rect(renderer, &clear_rect)

	tile_size := 36
	board_x := 30
	board_y := 30
	board_w := grid_size * tile_size
	board_h := grid_size * tile_size

	// 2. Sunken Grid Bevel
	sdl.set_render_draw_color(renderer, 128, 128, 128, 255)
	frame := sdl.Rect{board_x - 3, board_y - 3, board_w + 6, board_h + 6}
	sdl.render_draw_rect(renderer, &frame)

	// 3. Render 16x16 Grid Tiles
	for x in 0 .. grid_size {
		for y in 0 .. grid_size {
			px := board_x + x * tile_size
			py := board_y + y * tile_size
			render_tile(renderer, g.grid[x][y], px, py, tile_size)
		}
	}

	// 4. Render Chip (Player)
	chip_px := board_x + g.player_x * tile_size
	chip_py := board_y + g.player_y * tile_size
	render_chip_player(renderer, chip_px, chip_py, tile_size, g.facing_dx, g.facing_dy)

	// 5. Right Side Windows Status HUD
	hud_x := board_x + board_w + 25
	hud_y := board_y
	hud_w := win_w - hud_x - 30
	hud_h := board_h
	render_hud_panel(renderer, g, hud_x, hud_y, hud_w, hud_h, sound_enabled)

	// 6. Announcement Banner
	if g.banner_timer > 0.0 && g.banner_text != '' {
		bw := g.banner_text.len * 8 * 2 + 40
		bx := win_w / 2 - bw / 2
		by := 260

		sdl.set_render_draw_color(renderer, 20, 30, 45, 240)
		bg := sdl.Rect{bx, by, bw, 44}
		sdl.render_fill_rect(renderer, &bg)
		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &bg)

		draw_text_centered(renderer, win_w / 2, by + 14, g.banner_text, 2, Color{255, 230, 80, 255})
	}
}

fn render_tile(renderer &sdl.Renderer, t Tile, x int, y int, s int) {
	// Base floor
	sdl.set_render_draw_color(renderer, 220, 220, 220, 255)
	base := sdl.Rect{x, y, s, s}
	sdl.render_fill_rect(renderer, &base)

	match t {
		.wall {
			// Blue mosaic wall
			sdl.set_render_draw_color(renderer, 40, 70, 150, 255)
			sdl.render_fill_rect(renderer, &base)
			sdl.set_render_draw_color(renderer, 70, 110, 200, 255)
			sdl.render_draw_rect(renderer, &base)
		}
		.chip {
			// Microchip IC
			sdl.set_render_draw_color(renderer, 30, 30, 30, 255)
			ic := sdl.Rect{x + 8, y + 8, s - 16, s - 16}
			sdl.render_fill_rect(renderer, &ic)
			sdl.set_render_draw_color(renderer, 220, 180, 40, 255)
			// Pins
			sdl.render_draw_line(renderer, x + 4, y + 12, x + 8, y + 12)
			sdl.render_draw_line(renderer, x + 4, y + 24, x + 8, y + 24)
			sdl.render_draw_line(renderer, x + s - 8, y + 12, x + s - 4, y + 12)
			sdl.render_draw_line(renderer, x + s - 8, y + 24, x + s - 4, y + 24)
		}
		.chip_socket {
			// Red striped barrier
			sdl.set_render_draw_color(renderer, 200, 40, 40, 255)
			sdl.render_fill_rect(renderer, &base)
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_draw_line(renderer, x, y, x + s, y + s)
			sdl.render_draw_line(renderer, x, y + s, x + s, y)
		}
		.exit_portal {
			// Swirling exit portal
			sdl.set_render_draw_color(renderer, 40, 220, 240, 255)
			sdl.render_fill_rect(renderer, &base)
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			draw_filled_circle(renderer, x + s / 2, y + s / 2, 8, Color{255, 255, 255, 255})
		}
		.red_key {
			draw_key_icon(renderer, x, y, s, Color{220, 40, 40, 255})
		}
		.blue_key {
			draw_key_icon(renderer, x, y, s, Color{40, 80, 220, 255})
		}
		.yellow_key {
			draw_key_icon(renderer, x, y, s, Color{230, 200, 30, 255})
		}
		.green_key {
			draw_key_icon(renderer, x, y, s, Color{40, 200, 60, 255})
		}
		.red_door {
			draw_door_tile(renderer, x, y, s, Color{200, 40, 40, 255})
		}
		.blue_door {
			draw_door_tile(renderer, x, y, s, Color{40, 80, 200, 255})
		}
		.yellow_door {
			draw_door_tile(renderer, x, y, s, Color{220, 190, 30, 255})
		}
		.green_door {
			draw_door_tile(renderer, x, y, s, Color{40, 180, 60, 255})
		}
		.water {
			sdl.set_render_draw_color(renderer, 30, 110, 220, 255)
			sdl.render_fill_rect(renderer, &base)
		}
		.fire {
			sdl.set_render_draw_color(renderer, 240, 60, 20, 255)
			sdl.render_fill_rect(renderer, &base)
		}
		.dirt_block {
			sdl.set_render_draw_color(renderer, 140, 80, 40, 255)
			b := sdl.Rect{x + 2, y + 2, s - 4, s - 4}
			sdl.render_fill_rect(renderer, &b)
		}
		.dirt_floor {
			sdl.set_render_draw_color(renderer, 160, 110, 60, 255)
			sdl.render_fill_rect(renderer, &base)
		}
		.flippers {
			sdl.set_render_draw_color(renderer, 40, 200, 220, 255)
			draw_text_centered(renderer, x + s / 2, y + s / 2 - 4, 'FLIP', 1, Color{20, 40, 80, 255})
		}
		.fire_boots {
			sdl.set_render_draw_color(renderer, 240, 80, 40, 255)
			draw_text_centered(renderer, x + s / 2, y + s / 2 - 4, 'BOOT', 1, Color{80, 20, 10, 255})
		}
		.hint_tile {
			sdl.set_render_draw_color(renderer, 240, 240, 100, 255)
			draw_text_centered(renderer, x + s / 2, y + s / 2 - 4, '?', 2, Color{40, 40, 40, 255})
		}
		else {}
	}

	// Tile grid outline
	sdl.set_render_draw_color(renderer, 180, 180, 180, 255)
	sdl.render_draw_rect(renderer, &base)
}

fn draw_key_icon(renderer &sdl.Renderer, x int, y int, s int, col Color) {
	sdl.set_render_draw_color(renderer, col.r, col.g, col.b, 255)
	draw_filled_circle(renderer, x + s / 2 - 4, y + s / 2, 5, col)
	shaft := sdl.Rect{x + s / 2 - 4, y + s / 2 - 2, 12, 4}
	sdl.render_fill_rect(renderer, &shaft)
	tooth := sdl.Rect{x + s / 2 + 5, y + s / 2 + 2, 3, 4}
	sdl.render_fill_rect(renderer, &tooth)
}

fn draw_door_tile(renderer &sdl.Renderer, x int, y int, s int, col Color) {
	sdl.set_render_draw_color(renderer, col.r, col.g, col.b, 255)
	d_rect := sdl.Rect{x + 2, y + 2, s - 4, s - 4}
	sdl.render_fill_rect(renderer, &d_rect)
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	keyhole := sdl.Rect{x + s / 2 - 2, y + s / 2 - 3, 4, 6}
	sdl.render_fill_rect(renderer, &keyhole)
}

fn render_chip_player(renderer &sdl.Renderer, x int, y int, s int, dx int, dy int) {
	// Chip Body (Yellow shirt)
	sdl.set_render_draw_color(renderer, 240, 210, 30, 255)
	body := sdl.Rect{x + 8, y + 10, s - 16, s - 16}
	sdl.render_fill_rect(renderer, &body)

	// Red Cap / Hair
	sdl.set_render_draw_color(renderer, 220, 40, 40, 255)
	cap := sdl.Rect{x + 8, y + 6, s - 16, 6}
	sdl.render_fill_rect(renderer, &cap)

	// Blue Pants
	sdl.set_render_draw_color(renderer, 30, 60, 180, 255)
	legs := sdl.Rect{x + 10, y + s - 8, s - 20, 6}
	sdl.render_fill_rect(renderer, &legs)

	// Eyes looking in facing direction
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	eye1 := sdl.Rect{x + 12 + dx * 2, y + 14 + dy * 2, 3, 3}
	eye2 := sdl.Rect{x + 18 + dx * 2, y + 14 + dy * 2, 3, 3}
	sdl.render_fill_rect(renderer, &eye1)
	sdl.render_fill_rect(renderer, &eye2)
}

fn render_hud_panel(renderer &sdl.Renderer, g ChipsGame, x int, y int, w int, h int, sound_enabled bool) {
	// Windows 95 Style Panel
	sdl.set_render_draw_color(renderer, 210, 210, 210, 255)
	panel := sdl.Rect{x, y, w, h}
	sdl.render_fill_rect(renderer, &panel)

	sdl.set_render_draw_color(renderer, 100, 100, 100, 255)
	sdl.render_draw_rect(renderer, &panel)

	lvl := g.levels[g.level_idx]

	// Title
	draw_text_centered(renderer, x + w / 2, y + 14, "CHIP'S CHALLENGE", 1, Color{20, 20, 40, 255})
	draw_text_centered(renderer, x + w / 2, y + 32, lvl.name.to_upper(), 1, Color{80, 40, 20, 255})

	// Chips Left 7-Segment Box
	sdl.set_render_draw_color(renderer, 20, 20, 20, 255)
	chip_box := sdl.Rect{x + 20, y + 60, w - 40, 45}
	sdl.render_fill_rect(renderer, &chip_box)
	draw_text_centered(renderer, x + w / 2, y + 68, 'CHIPS LEFT', 1, Color{180, 180, 180, 255})
	draw_text_centered(renderer, x + w / 2, y + 84, '${g.chips_left}', 2, Color{255, 50, 50, 255})

	// Time Left 7-Segment Box
	time_box := sdl.Rect{x + 20, y + 120, w - 40, 45}
	sdl.render_fill_rect(renderer, &time_box)
	draw_text_centered(renderer, x + w / 2, y + 128, 'TIME REMAINING', 1, Color{180, 180, 180, 255})
	draw_text_centered(renderer, x + w / 2, y + 144, '${int(math.max(0.0, g.time_left))}', 2, Color{50, 255, 50, 255})

	// Keys Inventory
	draw_text(renderer, x + 20, y + 185, 'KEYS INVENTORY:', 1, Color{40, 40, 40, 255})
	draw_text(renderer, x + 24, y + 205, 'RED: ${g.red_keys}', 1, Color{200, 30, 30, 255})
	draw_text(renderer, x + 140, y + 205, 'BLUE: ${g.blue_keys}', 1, Color{30, 60, 200, 255})
	draw_text(renderer, x + 24, y + 225, 'YEL: ${g.yellow_keys}', 1, Color{180, 150, 0, 255})
	draw_text(renderer, x + 140, y + 225, 'GRN: ${g.green_keys}', 1, Color{30, 160, 40, 255})

	// Boots Inventory
	draw_text(renderer, x + 20, y + 260, 'EQUIPMENT:', 1, Color{40, 40, 40, 255})
	flip_str := if g.has_flippers { '[X] FLIPPERS' } else { '[ ] FLIPPERS' }
	fire_str := if g.has_fire_boots { '[X] FIRE BOOTS' } else { '[ ] FIRE BOOTS' }
	draw_text(renderer, x + 24, y + 280, flip_str, 1, Color{30, 80, 180, 255})
	draw_text(renderer, x + 24, y + 300, fire_str, 1, Color{180, 50, 20, 255})

	// Hint window
	if g.showing_hint {
		draw_text(renderer, x + 20, y + 340, 'HINT: ${lvl.hint_text}', 1, Color{80, 60, 0, 255})
	}

	// Sound toggle badge
	sound_x := x + 20
	sound_y := y + h - 50
	if sound_enabled {
		sdl.set_render_draw_color(renderer, 40, 120, 60, 255)
		btn := sdl.Rect{sound_x, sound_y, w - 40, 28}
		sdl.render_fill_rect(renderer, &btn)
		draw_text_centered(renderer, sound_x + (w - 40) / 2, sound_y + 8, 'SOUND: ON [M]', 1, Color{255, 255, 255, 255})
	} else {
		sdl.set_render_draw_color(renderer, 120, 35, 40, 255)
		btn := sdl.Rect{sound_x, sound_y, w - 40, 28}
		sdl.render_fill_rect(renderer, &btn)
		draw_text_centered(renderer, sound_x + (w - 40) / 2, sound_y + 8, 'MUTED [M]', 1, Color{255, 180, 180, 255})
	}
}
