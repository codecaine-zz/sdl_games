module main

import sdl

fn render_bomberman_game(renderer &sdl.Renderer, mut g BombermanGame) {
	// Background field dark grey
	sdl.set_render_draw_color(renderer, 30, 35, 45, 255)
	sdl.render_clear(renderer)

	// 1. Draw Grid Tiles
	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			tx := grid_offset_x + c * tile_size
			ty := grid_offset_y + r * tile_size

			match g.grid[r][c] {
				.empty {
					// Checkerboard floor
					col_val := if (r + c) % 2 == 0 { u8(45) } else { u8(55) }
					sdl.set_render_draw_color(renderer, col_val, col_val + 10, col_val, 255)
					rect := sdl.Rect{ x: tx, y: ty, w: tile_size, h: tile_size }
					sdl.render_fill_rect(renderer, &rect)
				}
				.hard_wall {
					// 3D Bevel Hard Wall
					sdl.set_render_draw_color(renderer, 80, 90, 105, 255)
					rect := sdl.Rect{ x: tx, y: ty, w: tile_size, h: tile_size }
					sdl.render_fill_rect(renderer, &rect)

					sdl.set_render_draw_color(renderer, 130, 140, 160, 255)
					top := sdl.Rect{ x: tx, y: ty, w: tile_size, h: 4 }
					left := sdl.Rect{ x: tx, y: ty, w: 4, h: tile_size }
					sdl.render_fill_rect(renderer, &top)
					sdl.render_fill_rect(renderer, &left)
				}
				.soft_block {
					// Soft Destructible Brick
					sdl.set_render_draw_color(renderer, 180, 100, 50, 255)
					rect := sdl.Rect{ x: tx + 1, y: ty + 1, w: tile_size - 2, h: tile_size - 2 }
					sdl.render_fill_rect(renderer, &rect)

					sdl.set_render_draw_color(renderer, 130, 60, 30, 255)
					line1 := sdl.Rect{ x: tx + 2, y: ty + tile_size / 2, w: tile_size - 4, h: 3 }
					sdl.render_fill_rect(renderer, &line1)
				}
			}
		}
	}

	// 2. Draw Power-Ups
	for p in g.powerups {
		if !p.active { continue }
		px := grid_offset_x + p.grid_x * tile_size + 8
		py := grid_offset_y + p.grid_y * tile_size + 8

		color := match p.power_type {
			.flame { Color{ r: 255, g: 80, b: 0, a: 255 } }
			.bomb_cap { Color{ r: 0, g: 180, b: 255, a: 255 } }
			.speed { Color{ r: 255, g: 220, b: 0, a: 255 } }
			else { Color{ r: 200, g: 200, b: 200, a: 255 } }
		}
		sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
		rect := sdl.Rect{ x: px, y: py, w: 24, h: 24 }
		sdl.render_fill_rect(renderer, &rect)

		// Icon label
		icon_text := match p.power_type {
			.flame { "F" }
			.bomb_cap { "B" }
			.speed { "S" }
			else { "+" }
		}
		draw_text(renderer, px + 8, py + 4, icon_text, 2, Color{ r: 255, g: 255, b: 255, a: 255 })
	}

	// 3. Draw Bombs
	for b in g.bombs {
		if !b.active { continue }
		bx := grid_offset_x + b.grid_x * tile_size + 6
		by := grid_offset_y + b.grid_y * tile_size + 6

		// Pulsing fuse glow
		pulse := int(b.fuse_timer * 10.0) % 2 == 0
		color := if pulse { Color{ r: 20, g: 20, b: 20, a: 255 } } else { Color{ r: 80, g: 20, b: 20, a: 255 } }

		sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
		body := sdl.Rect{ x: bx, y: by, w: 28, h: 28 }
		sdl.render_fill_rect(renderer, &body)

		// Spark fuse
		sdl.set_render_draw_color(renderer, 255, 200, 0, 255)
		fuse := sdl.Rect{ x: bx + 12, y: by - 4, w: 4, h: 6 }
		sdl.render_fill_rect(renderer, &fuse)
	}

	// 4. Draw Flame Explosions
	for f in g.flames {
		fx := grid_offset_x + f.grid_x * tile_size
		fy := grid_offset_y + f.grid_y * tile_size

		alpha := u8(f.timer / 0.5 * 255.0)
		sdl.set_render_draw_color(renderer, 255, 120, 0, alpha)
		center := sdl.Rect{ x: fx + 2, y: fy + 2, w: tile_size - 4, h: tile_size - 4 }
		sdl.render_fill_rect(renderer, &center)

		sdl.set_render_draw_color(renderer, 255, 255, 100, alpha)
		inner := sdl.Rect{ x: fx + 8, y: fy + 8, w: tile_size - 16, h: tile_size - 16 }
		sdl.render_fill_rect(renderer, &inner)
	}

	// 5. Draw Players
	for pl in g.players {
		if !pl.active { continue }
		px := int(pl.x)
		py := int(pl.y)

		body_color := if pl.id == 1 { Color{ r: 0, g: 150, b: 255, a: 255 } } else { Color{ r: 255, g: 50, b: 50, a: 255 } }

		// Player Body Circle/Square (26x26 box centered to fit perfectly within tile grid square)
		sdl.set_render_draw_color(renderer, body_color.r, body_color.g, body_color.b, body_color.a)
		body := sdl.Rect{ x: px - 13, y: py - 13, w: 26, h: 26 }
		sdl.render_fill_rect(renderer, &body)

		// White Helmet Visor
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		visor := sdl.Rect{ x: px - 8, y: py - 9, w: 16, h: 8 }
		sdl.render_fill_rect(renderer, &visor)
	}

	// 6. Draw HUD
	draw_text(renderer, 20, 10, "CYBER BOMBERMAN", 2, Color{ r: 255, g: 220, b: 0, a: 255 })
	draw_text(renderer, 250, 10, "P1 LIVES: ${g.players[0].lives} | BOMBS: ${g.players[0].max_bombs} | FLAME: ${g.players[0].flame_radius}", 2, Color{ r: 0, g: 200, b: 255, a: 255 })
	draw_text_centered(renderer, 400, 575, "[SPACE] DROP BOMB TO DESTROY WALLS & ENEMIES | [WASD] MOVE | [P] PAUSE | [M] MUTE", 1, Color{ r: 220, g: 220, b: 220, a: 255 })

	// 7. Overlay Menus
	if g.state == .menu {
		draw_text_centered(renderer, 400, 180, "CYBER BOMBERMAN", 4, Color{ r: 255, g: 200, b: 0, a: 255 })
		draw_text_centered(renderer, 400, 240, "GRID TACTICAL MAZE BATTLE", 2, Color{ r: 0, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 310, "GOAL: DROP BOMBS TO DESTROY WALLS & ENEMIES!", 2, Color{ r: 255, g: 100, b: 100, a: 255 })
		draw_text_centered(renderer, 400, 380, "PRESS SPACE TO START", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
		draw_text_centered(renderer, 400, 440, "P1: WASD MOVE, SPACE DROP BOMB | P2: ARROWS MOVE, ENTER DROP BOMB", 1, Color{ r: 180, g: 180, b: 180, a: 255 })
	} else if g.state == .game_over {
		draw_text_centered(renderer, 400, 260, "GAME OVER - DEFEATED!", 3, Color{ r: 255, g: 50, b: 50, a: 255 })
		draw_text_centered(renderer, 400, 340, "PRESS SPACE OR R TO RESTART", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
	} else if g.state == .victory {
		draw_text_centered(renderer, 400, 260, "VICTORY! ENEMY DESTROYED!", 3, Color{ r: 0, g: 255, b: 100, a: 255 })
		draw_text_centered(renderer, 400, 340, "PRESS SPACE OR R TO RESTART", 2, Color{ r: 255, g: 255, b: 255, a: 255 })
	} else if g.state == .paused {
		draw_text_centered(renderer, 400, 280, "- PAUSED -", 3, Color{ r: 255, g: 255, b: 0, a: 255 })
	}

	sdl.render_present(renderer)
}
