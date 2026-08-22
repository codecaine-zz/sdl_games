module main

import math
import sdl

pub fn render_rodent_game(renderer &sdl.Renderer, mut g RodentGame, win_w int, win_h int, sound_enabled bool) {
	// 1. Classic Windows Cyan Backdrop
	sdl.set_render_draw_color(renderer, 0, 128, 128, 255)
	clear_rect := sdl.Rect{0, 0, win_w, win_h}
	sdl.render_fill_rect(renderer, &clear_rect)

	tile_s := 28
	board_x := (win_w - grid_w * tile_s) / 2
	board_y := 60
	board_w := grid_w * tile_s
	board_h := grid_h * tile_s

	// 2. Warehouse Grid Background
	sdl.set_render_draw_color(renderer, 240, 240, 240, 255)
	board_bg := sdl.Rect{board_x, board_y, board_w, board_h}
	sdl.render_fill_rect(renderer, &board_bg)

	// 3. Render 20x20 Tiles
	for x in 0 .. grid_w {
		for y in 0 .. grid_h {
			px := board_x + x * tile_s
			py := board_y + y * tile_s
			render_rodent_tile(renderer, g.grid[x][y], px, py, tile_s)
		}
	}

	// 4. Render Cats
	for c in g.cats {
		cx := board_x + c.x * tile_s
		cy := board_y + c.y * tile_s
		render_cat(renderer, cx, cy, tile_s)
	}

	// 5. Render Mouse (Player)
	mx := board_x + g.player_x * tile_s
	my := board_y + g.player_y * tile_s
	render_mouse(renderer, mx, my, tile_s, g.facing_dx, g.facing_dy)

	// 6. Top Status Header Bar
	render_header(renderer, g, win_w, sound_enabled)

	// 7. Announcement Banner
	if g.banner_timer > 0.0 && g.banner_text != '' {
		bw := g.banner_text.len * 8 * 2 + 40
		bx := win_w / 2 - bw / 2
		by := 300

		sdl.set_render_draw_color(renderer, 20, 25, 35, 240)
		bg := sdl.Rect{bx, by, bw, 44}
		sdl.render_fill_rect(renderer, &bg)
		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &bg)

		draw_text_centered(renderer, win_w / 2, by + 14, g.banner_text, 2, Color{255, 230, 80, 255})
	}
}

fn render_rodent_tile(renderer &sdl.Renderer, t TileType, x int, y int, s int) {
	match t {
		.wall {
			// Brick wall border
			sdl.set_render_draw_color(renderer, 100, 100, 110, 255)
			r := sdl.Rect{x, y, s, s}
			sdl.render_fill_rect(renderer, &r)
			sdl.set_render_draw_color(renderer, 60, 60, 70, 255)
			sdl.render_draw_rect(renderer, &r)
		}
		.block {
			// Pushable beige wooden crate
			sdl.set_render_draw_color(renderer, 210, 180, 130, 255)
			r := sdl.Rect{x + 1, y + 1, s - 2, s - 2}
			sdl.render_fill_rect(renderer, &r)
			sdl.set_render_draw_color(renderer, 160, 120, 80, 255)
			sdl.render_draw_rect(renderer, &r)
			// Cross lines
			sdl.render_draw_line(renderer, x + 3, y + 3, x + s - 4, y + s - 4)
			sdl.render_draw_line(renderer, x + 3, y + s - 4, x + s - 4, y + 3)
		}
		.cheese {
			// Golden cheese wedge!
			sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
			c_rect := sdl.Rect{x + 3, y + 3, s - 6, s - 6}
			sdl.render_fill_rect(renderer, &c_rect)
			// Cheese holes
			draw_filled_circle(renderer, x + 8, y + 8, 2, Color{210, 160, 0, 255})
			draw_filled_circle(renderer, x + 16, y + 14, 3, Color{210, 160, 0, 255})
			draw_filled_circle(renderer, x + 10, y + 20, 2, Color{210, 160, 0, 255})
		}
		.mousetrap {
			// Mousetrap
			sdl.set_render_draw_color(renderer, 150, 90, 40, 255)
			r := sdl.Rect{x + 2, y + 6, s - 4, s - 12}
			sdl.render_fill_rect(renderer, &r)
			sdl.set_render_draw_color(renderer, 220, 40, 40, 255)
			sdl.render_draw_line(renderer, x + 4, y + s / 2, x + s - 5, y + s / 2)
		}
		.empty {
			// Floor grid line
			sdl.set_render_draw_color(renderer, 225, 225, 230, 255)
			r := sdl.Rect{x, y, s, s}
			sdl.render_draw_rect(renderer, &r)
		}
	}
}

fn render_cat(renderer &sdl.Renderer, x int, y int, s int) {
	// Orange Cat Body
	sdl.set_render_draw_color(renderer, 235, 120, 30, 255)
	body := sdl.Rect{x + 5, y + 6, s - 10, s - 12}
	sdl.render_fill_rect(renderer, &body)

	// Triangular ears
	draw_filled_circle(renderer, x + 7, y + 6, 3, Color{235, 120, 30, 255})
	draw_filled_circle(renderer, x + s - 8, y + 6, 3, Color{235, 120, 30, 255})

	// Green eyes
	draw_filled_circle(renderer, x + 9, y + 12, 2, Color{50, 220, 80, 255})
	draw_filled_circle(renderer, x + s - 10, y + 12, 2, Color{50, 220, 80, 255})
}

fn render_mouse(renderer &sdl.Renderer, x int, y int, s int, dx int, dy int) {
	// Grey Mouse Body
	sdl.set_render_draw_color(renderer, 130, 130, 140, 255)
	body := sdl.Rect{x + 6, y + 6, s - 12, s - 12}
	sdl.render_fill_rect(renderer, &body)

	// Pink ears
	draw_filled_circle(renderer, x + 7, y + 7, 3, Color{255, 160, 180, 255})
	draw_filled_circle(renderer, x + s - 8, y + 7, 3, Color{255, 160, 180, 255})

	// Nose
	draw_filled_circle(renderer, x + s / 2, y + s / 2 + 2, 2, Color{255, 100, 130, 255})
}

fn render_header(renderer &sdl.Renderer, g RodentGame, win_w int, sound_enabled bool) {
	sdl.set_render_draw_color(renderer, 192, 192, 192, 255)
	bar := sdl.Rect{0, 0, win_w, 48}
	sdl.render_fill_rect(renderer, &bar)

	sdl.set_render_draw_color(renderer, 128, 128, 128, 255)
	sdl.render_draw_line(renderer, 0, 47, win_w, 47)

	// Title
	draw_text(renderer, 20, 16, "RODENT'S REVENGE", 2, Color{30, 30, 50, 255})

	// Level & Score
	draw_text(renderer, 310, 18, 'LEVEL: ${g.level}', 1, Color{20, 40, 120, 255})
	draw_text(renderer, 420, 18, 'SCORE: ${g.score}', 1, Color{0, 100, 30, 255})
	draw_text(renderer, 560, 18, 'LIVES: ${g.lives}', 1, Color{180, 30, 30, 255})
	draw_text(renderer, 670, 18, 'TIME: ${int(math.max(0.0, g.time_left))}S', 1, Color{80, 60, 0, 255})

	// Sound toggle badge
	sound_x := win_w - 135
	if sound_enabled {
		sdl.set_render_draw_color(renderer, 40, 120, 60, 255)
		btn := sdl.Rect{sound_x, 10, 115, 26}
		sdl.render_fill_rect(renderer, &btn)
		draw_text_centered(renderer, sound_x + 57, 16, 'SOUND: ON [M]', 1, Color{255, 255, 255, 255})
	} else {
		sdl.set_render_draw_color(renderer, 120, 35, 40, 255)
		btn := sdl.Rect{sound_x, 10, 115, 26}
		sdl.render_fill_rect(renderer, &btn)
		draw_text_centered(renderer, sound_x + 57, 16, 'MUTED [M]', 1, Color{255, 180, 180, 255})
	}
}
