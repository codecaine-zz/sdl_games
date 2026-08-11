module main

import sdl

struct Button {
pub mut:
	x            int
	y            int
	w            int
	h            int
	text         string
	bg_color     Color
	hover_color  Color
	text_color   Color
	border_color Color
}

pub fn (b Button) contains(mx int, my int) bool {
	return mx >= b.x && mx <= b.x + b.w && my >= b.y && my <= b.y + b.h
}

pub fn (b Button) draw(renderer &sdl.Renderer, mx int, my int) {
	is_hover := b.contains(mx, my)
	bg := if is_hover { b.hover_color } else { b.bg_color }

	rect := sdl.Rect{
		x: b.x
		y: b.y
		w: b.w
		h: b.h
	}
	sdl.set_render_draw_color(renderer, bg.r, bg.g, bg.b, bg.a)
	sdl.render_fill_rect(renderer, &rect)

	// Top/Left bevel highlight
	sdl.set_render_draw_color(renderer, u8(math_min(int(bg.r) + 40, 255)), u8(math_min(int(bg.g) + 40, 255)),
		u8(math_min(int(bg.b) + 40, 255)), bg.a)
	sdl.render_draw_line(renderer, b.x, b.y, b.x + b.w, b.y)
	sdl.render_draw_line(renderer, b.x, b.y, b.x, b.y + b.h)

	// Border outline
	sdl.set_render_draw_color(renderer, b.border_color.r, b.border_color.g, b.border_color.b,
		b.border_color.a)
	sdl.render_draw_rect(renderer, &rect)

	draw_text_centered(renderer, b.x + b.w / 2, b.y + (b.h - 16) / 2, b.text, 2, b.text_color)
}

fn math_min(a int, b int) int {
	return if a < b { a } else { b }
}

pub fn draw_game(renderer &sdl.Renderer, game Game, mx int, my int, btn_editor Button, btn_restart Button, btn_sound Button, btn_prev Button, btn_next Button, btn_test Button, btn_clear Button) {
	// Deep Castle Background Gradient
	sdl.set_render_draw_color(renderer, 15, 18, 28, 255)
	sdl.render_clear(renderer)

	// Decorative background wall pattern
	for r in 0 .. 15 {
		for c in 0 .. 20 {
			bx := c * 48
			by := r * 48
			sdl.set_render_draw_color(renderer, 22, 26, 38, 255)
			sdl.render_draw_rect(renderer, &sdl.Rect{ x: bx, y: by, w: 48, h: 48 })
		}
	}

	// Draw Header Bar
	draw_header(renderer, game)

	// Draw Main Playfield / Grid
	draw_playfield(renderer, game)

	// Draw Sidebar / UI Controls
	if game.mode == .editor {
		draw_editor_palette(renderer, game, mx, my, btn_test, btn_clear)
	} else {
		draw_hud_panel(renderer, game, mx, my, btn_prev, btn_next, btn_restart)
	}

	// Draw Common UI Action Buttons
	btn_editor.draw(renderer, mx, my)
	btn_sound.draw(renderer, mx, my)

	// Status Overlay if Lost or Won
	if game.status == .lost || game.status == .won || game.status == .level_clear {
		draw_status_overlay(renderer, game)
	}
}

fn draw_header(renderer &sdl.Renderer, game Game) {
	// Top Glassmorphism Header Box
	hdr_rect := sdl.Rect{
		x: 0
		y: 0
		w: win_w
		h: 64
	}
	sdl.set_render_draw_color(renderer, 28, 34, 48, 255)
	sdl.render_fill_rect(renderer, &hdr_rect)

	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	sdl.render_draw_line(renderer, 0, 63, win_w, 63)
	sdl.render_draw_line(renderer, 0, 64, win_w, 64)

	// Title & Subtitle
	draw_text(renderer, 20, 12, 'ADVENTURES OF LOLO', 2, Color{ r: 255, g: 215, b: 0 })

	lvl_name := if game.mode == .editor {
		'INTERACTIVE LEVEL DESIGNER'
	} else {
		game.current_level.name
	}
	draw_text(renderer, 20, 36, lvl_name, 2, Color{ r: 180, g: 220, b: 255 })

	// Score & Lives
	score_str := 'SCORE: ${game.score:06d}'
	draw_text(renderer, 580, 14, score_str, 2, Color{ r: 255, g: 255, b: 255 })

	lives_str := 'LIVES: ${game.lives}'
	draw_text(renderer, 580, 36, lives_str, 2, Color{ r: 255, g: 120, b: 120 })
}

fn draw_playfield(renderer &sdl.Renderer, game Game) {
	// Heavy 3D Castle Wall Outer Frame
	frame_rect := sdl.Rect{
		x: grid_offset_x - 10
		y: grid_offset_y - 10
		w: (grid_cols * cell_size) + 20
		h: (grid_rows * cell_size) + 20
	}
	sdl.set_render_draw_color(renderer, 90, 75, 60, 255)
	sdl.render_fill_rect(renderer, &frame_rect)

	// Inner Gold Trim
	gold_trim := sdl.Rect{
		x: grid_offset_x - 4
		y: grid_offset_y - 4
		w: (grid_cols * cell_size) + 8
		h: (grid_rows * cell_size) + 8
	}
	sdl.set_render_draw_color(renderer, 215, 170, 0, 255)
	sdl.render_draw_rect(renderer, &gold_trim)

	inner_rect := sdl.Rect{
		x: grid_offset_x
		y: grid_offset_y
		w: grid_cols * cell_size
		h: grid_rows * cell_size
	}
	sdl.set_render_draw_color(renderer, 30, 24, 18, 255)
	sdl.render_fill_rect(renderer, &inner_rect)

	// Draw Grid Cells (Checkerboard Grass & Terrain)
	active_grid := if game.mode == .editor { game.editor_level.grid } else { game.grid }
	active_entities := if game.mode == .editor { game.editor_level.entities } else { game.entities }

	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			cx := grid_offset_x + c * cell_size
			cy := grid_offset_y + r * cell_size
			tile := active_grid[r][c]

			draw_tile(renderer, cx, cy, c, r, tile)
		}
	}

	// Draw Entities
	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			cx := grid_offset_x + c * cell_size
			cy := grid_offset_y + r * cell_size
			ent := active_entities[r][c]

			draw_entity(renderer, cx, cy, ent, game.chest_open, game.door_open)
		}
	}

	// In Play mode, draw dynamic Enemies, Lolo, Shot, & Medusa Laser
	if game.mode == .play {
		// Enemies
		for enemy in game.enemies {
			if enemy.x >= 0 {
				cx := grid_offset_x + enemy.x * cell_size
				cy := grid_offset_y + enemy.y * cell_size
				draw_enemy(renderer, cx, cy, enemy)
			}
		}

		// Lolo
		if !game.lolo.is_dead {
			lx := grid_offset_x + game.lolo.x * cell_size
			ly := grid_offset_y + game.lolo.y * cell_size
			draw_lolo(renderer, lx, ly, game.lolo.dir)
		}

		// Magic Shot
		if game.magic_shot.active {
			sx := grid_offset_x + int(game.magic_shot.x * f64(cell_size)) + cell_size / 2
			sy := grid_offset_y + int(game.magic_shot.y * f64(cell_size)) + cell_size / 2
			draw_magic_shot(renderer, sx, sy)
		}

		// Medusa Laser Strike Animation
		if game.medusa_laser_active {
			lx1 := grid_offset_x + game.laser_x1 * cell_size + cell_size / 2
			ly1 := grid_offset_y + game.laser_y1 * cell_size + cell_size / 2
			lx2 := grid_offset_x + game.laser_x2 * cell_size + cell_size / 2
			ly2 := grid_offset_y + game.laser_y2 * cell_size + cell_size / 2

			// Outer glowing magenta laser
			sdl.set_render_draw_color(renderer, 255, 0, 100, 255)
			sdl.render_draw_line(renderer, lx1 - 2, ly1 - 2, lx2 - 2, ly2 - 2)
			sdl.render_draw_line(renderer, lx1 + 2, ly1 + 2, lx2 + 2, ly2 + 2)
			sdl.render_draw_line(renderer, lx1 - 1, ly1 - 1, lx2 - 1, ly2 - 1)
			sdl.render_draw_line(renderer, lx1 + 1, ly1 + 1, lx2 + 1, ly2 + 1)

			// Core bright yellow-white beam
			sdl.set_render_draw_color(renderer, 255, 255, 180, 255)
			sdl.render_draw_line(renderer, lx1, ly1, lx2, ly2)

			// Impact spark crosshairs at target
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_draw_line(renderer, lx2 - 8, ly2, lx2 + 8, ly2)
			sdl.render_draw_line(renderer, lx2, ly2 - 8, lx2, ly2 + 8)
		}
	}
}

fn draw_tile(renderer &sdl.Renderer, x int, y int, col int, row int, tile TileType) {
	rect := sdl.Rect{
		x: x
		y: y
		w: cell_size
		h: cell_size
	}

	match tile {
		.grass {
			// Two-tone checkerboard vibrant grass
			is_alt := (col + row) % 2 == 0
			bg := if is_alt { Color{ r: 72, g: 155, b: 48 } } else { Color{ r: 62, g: 140, b: 40 } }
			sdl.set_render_draw_color(renderer, bg.r, bg.g, bg.b, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Subtle grass blade details
			sdl.set_render_draw_color(renderer, 95, 180, 65, 255)
			sdl.render_draw_line(renderer, x + 10, y + 14, x + 12, y + 8)
			sdl.render_draw_line(renderer, x + 12, y + 8, x + 14, y + 14)

			sdl.render_draw_line(renderer, x + 30, y + 34, x + 32, y + 28)
			sdl.render_draw_line(renderer, x + 32, y + 28, x + 34, y + 34)

			// Soft grid border line
			sdl.set_render_draw_color(renderer, 50, 115, 30, 255)
			sdl.render_draw_rect(renderer, &rect)
		}
		.wall {
			// 3D Bevelled Masonry Wall
			sdl.set_render_draw_color(renderer, 120, 120, 125, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Top-Left bevel highlight
			sdl.set_render_draw_color(renderer, 170, 170, 175, 255)
			sdl.render_draw_line(renderer, x, y, x + cell_size, y)
			sdl.render_draw_line(renderer, x, y, x, y + cell_size)

			// Bottom-Right shadow
			sdl.set_render_draw_color(renderer, 70, 70, 75, 255)
			sdl.render_draw_line(renderer, x + cell_size - 1, y, x + cell_size - 1, y + cell_size)
			sdl.render_draw_line(renderer, x, y + cell_size - 1, x + cell_size, y + cell_size - 1)

			// Brick Mortar Grid Lines
			sdl.set_render_draw_color(renderer, 50, 50, 55, 255)
			sdl.render_draw_line(renderer, x, y + 24, x + cell_size, y + 24)
			sdl.render_draw_line(renderer, x + 24, y, x + 24, y + 24)
			sdl.render_draw_line(renderer, x + 12, y + 24, x + 12, y + cell_size)
		}
		.rock {
			// Grass base
			sdl.set_render_draw_color(renderer, 68, 145, 42, 255)
			sdl.render_fill_rect(renderer, &rect)

			// 3D Granite Boulder
			r_rect := sdl.Rect{
				x: x + 4
				y: y + 4
				w: cell_size - 8
				h: cell_size - 8
			}
			sdl.set_render_draw_color(renderer, 150, 140, 130, 255)
			sdl.render_fill_rect(renderer, &r_rect)

			// Top Highlight Arc
			sdl.set_render_draw_color(renderer, 200, 190, 180, 255)
			sdl.render_draw_line(renderer, x + 6, y + 6, x + cell_size - 8, y + 6)
			sdl.render_draw_line(renderer, x + 6, y + 6, x + 6, y + cell_size - 8)

			// Bottom Shadow
			sdl.set_render_draw_color(renderer, 90, 80, 70, 255)
			sdl.render_draw_line(renderer, x + 4, y + cell_size - 5, x + cell_size - 4, y + cell_size - 5)
			sdl.render_draw_line(renderer, x + cell_size - 5, y + 4, x + cell_size - 5, y + cell_size - 4)

			// Mossy base speckles
			sdl.set_render_draw_color(renderer, 80, 130, 50, 255)
			sdl.render_draw_line(renderer, x + 8, y + cell_size - 7, x + 16, y + cell_size - 7)
		}
		.tree {
			// Grass base
			sdl.set_render_draw_color(renderer, 68, 145, 42, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Wood Trunk
			trunk := sdl.Rect{
				x: x + 18
				y: y + 24
				w: 12
				h: 20
			}
			sdl.set_render_draw_color(renderer, 110, 60, 25, 255)
			sdl.render_fill_rect(renderer, &trunk)

			// Tree Foliage Canopy (Overlapping Circles/Rects)
			canopy1 := sdl.Rect{
				x: x + 6
				y: y + 4
				w: 36
				h: 24
			}
			sdl.set_render_draw_color(renderer, 25, 120, 35, 255)
			sdl.render_fill_rect(renderer, &canopy1)

			canopy2 := sdl.Rect{
				x: x + 10
				y: y + 2
				w: 28
				h: 20
			}
			sdl.set_render_draw_color(renderer, 40, 160, 50, 255)
			sdl.render_fill_rect(renderer, &canopy2)

			// Canopy Highlight
			sdl.set_render_draw_color(renderer, 80, 210, 80, 255)
			sdl.render_draw_line(renderer, x + 12, y + 4, x + 26, y + 4)
		}
		.water {
			// Deep Blue Animated Water
			sdl.set_render_draw_color(renderer, 30, 95, 195, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Wave Shimmer Lines
			sdl.set_render_draw_color(renderer, 85, 170, 255, 255)
			sdl.render_draw_line(renderer, x + 4, y + 12, x + 18, y + 12)
			sdl.render_draw_line(renderer, x + 24, y + 24, x + 42, y + 24)
			sdl.render_draw_line(renderer, x + 10, y + 36, x + 28, y + 36)

			// Wave Top Highlight
			sdl.set_render_draw_color(renderer, 160, 220, 255, 255)
			sdl.render_draw_line(renderer, x + 6, y + 11, x + 14, y + 11)
			sdl.render_draw_line(renderer, x + 28, y + 23, x + 38, y + 23)
		}
		.bridge {
			// Water background under bridge
			sdl.set_render_draw_color(renderer, 30, 95, 195, 255)
			sdl.render_fill_rect(renderer, &rect)

			// 3D Wooden Plank
			plank := sdl.Rect{
				x: x + 2
				y: y + 4
				w: cell_size - 4
				h: cell_size - 8
			}
			sdl.set_render_draw_color(renderer, 165, 115, 60, 255)
			sdl.render_fill_rect(renderer, &plank)

			// Plank Top Highlight
			sdl.set_render_draw_color(renderer, 210, 160, 100, 255)
			sdl.render_draw_line(renderer, x + 2, y + 4, x + cell_size - 2, y + 4)

			// Plank Seams & Nails
			sdl.set_render_draw_color(renderer, 90, 50, 20, 255)
			sdl.render_draw_rect(renderer, &plank)
			sdl.render_draw_line(renderer, x + 2, y + 18, x + cell_size - 2, y + 18)
			sdl.render_draw_line(renderer, x + 2, y + 32, x + cell_size - 2, y + 32)

			// Iron Nails
			sdl.set_render_draw_color(renderer, 40, 40, 40, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 8, w: 3, h: 3 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + cell_size - 9, y: y + 8, w: 3, h: 3 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 22, w: 3, h: 3 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + cell_size - 9, y: y + 22, w: 3, h: 3 })
		}
		.arrow_up, .arrow_down, .arrow_left, .arrow_right {
			sdl.set_render_draw_color(renderer, 68, 145, 42, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Neon Yellow Chevron
			sdl.set_render_draw_color(renderer, 255, 220, 0, 255)
			cx := x + cell_size / 2
			cy := y + cell_size / 2

			match tile {
				.arrow_up {
					sdl.render_draw_line(renderer, cx, y + 8, cx - 14, y + 24)
					sdl.render_draw_line(renderer, cx, y + 8, cx + 14, y + 24)
					sdl.render_draw_line(renderer, cx - 1, y + 8, cx, y + 38)
					sdl.render_draw_line(renderer, cx + 1, y + 8, cx, y + 38)
				}
				.arrow_down {
					sdl.render_draw_line(renderer, cx, y + 40, cx - 14, y + 24)
					sdl.render_draw_line(renderer, cx, y + 40, cx + 14, y + 24)
					sdl.render_draw_line(renderer, cx - 1, y + 10, cx, y + 40)
					sdl.render_draw_line(renderer, cx + 1, y + 10, cx, y + 40)
				}
				.arrow_left {
					sdl.render_draw_line(renderer, x + 8, cy, x + 24, cy - 14)
					sdl.render_draw_line(renderer, x + 8, cy, x + 24, cy + 14)
					sdl.render_draw_line(renderer, x + 8, cy, x + 40, cy)
				}
				.arrow_right {
					sdl.render_draw_line(renderer, x + 40, cy, x + 24, cy - 14)
					sdl.render_draw_line(renderer, x + 40, cy, x + 24, cy + 14)
					sdl.render_draw_line(renderer, x + 8, cy, x + 40, cy)
				}
				else {}
			}
		}
	}
}

fn draw_entity(renderer &sdl.Renderer, x int, y int, ent EntityType, chest_open bool, door_open bool) {
	cx := x + cell_size / 2
	cy := y + cell_size / 2

	match ent {
		.emerald_frame {
			// Metallic Green Pushable Frame
			frame_rect := sdl.Rect{
				x: x + 3
				y: y + 3
				w: cell_size - 6
				h: cell_size - 6
			}
			sdl.set_render_draw_color(renderer, 215, 175, 0, 255) // Gold Frame Border
			sdl.render_fill_rect(renderer, &frame_rect)

			inner_block := sdl.Rect{
				x: x + 6
				y: y + 6
				w: cell_size - 12
				h: cell_size - 12
			}
			sdl.set_render_draw_color(renderer, 20, 170, 75, 255)
			sdl.render_fill_rect(renderer, &inner_block)

			// Highlight
			sdl.set_render_draw_color(renderer, 70, 230, 130, 255)
			sdl.render_draw_line(renderer, x + 6, y + 6, x + cell_size - 6, y + 6)
			sdl.render_draw_line(renderer, x + 6, y + 6, x + 6, y + cell_size - 6)

			// Multi-faceted Emerald Gem Center
			gem := sdl.Rect{
				x: cx - 7
				y: cy - 7
				w: 14
				h: 14
			}
			sdl.set_render_draw_color(renderer, 140, 255, 180, 255)
			sdl.render_fill_rect(renderer, &gem)

			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 4, y: cy - 4, w: 4, h: 4 })
		}
		.heart_frame {
			// Golden Frame Container
			frame_rect := sdl.Rect{
				x: x + 4
				y: y + 4
				w: cell_size - 8
				h: cell_size - 8
			}
			sdl.set_render_draw_color(renderer, 220, 180, 20, 255)
			sdl.render_fill_rect(renderer, &frame_rect)

			inner := sdl.Rect{
				x: x + 7
				y: y + 7
				w: cell_size - 14
				h: cell_size - 14
			}
			sdl.set_render_draw_color(renderer, 40, 20, 30, 255)
			sdl.render_fill_rect(renderer, &inner)

			// Crimson 3D Heart
			h1 := sdl.Rect{ x: cx - 9, y: cy - 8, w: 8, h: 10 }
			h2 := sdl.Rect{ x: cx + 1, y: cy - 8, w: 8, h: 10 }
			h3 := sdl.Rect{ x: cx - 8, y: cy - 2, w: 16, h: 10 }
			sdl.set_render_draw_color(renderer, 230, 30, 60, 255)
			sdl.render_fill_rect(renderer, &h1)
			sdl.render_fill_rect(renderer, &h2)
			sdl.render_fill_rect(renderer, &h3)

			// Specular White Gloss Arc
			sdl.set_render_draw_color(renderer, 255, 200, 210, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 7, y: cy - 6, w: 3, h: 3 })
		}
		.chest {
			// Wooden Pirate Chest
			rect := sdl.Rect{
				x: x + 4
				y: y + 8
				w: cell_size - 8
				h: cell_size - 12
			}
			if chest_open {
				// Open Chest with Glowing Magic Jewel Inside
				sdl.set_render_draw_color(renderer, 160, 100, 25, 255)
				sdl.render_fill_rect(renderer, &rect)

				jewel_glow := sdl.Rect{
					x: cx - 10
					y: cy - 8
					w: 20
					h: 16
				}
				sdl.set_render_draw_color(renderer, 0, 220, 255, 255)
				sdl.render_fill_rect(renderer, &jewel_glow)

				sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 4, y: cy - 5, w: 8, h: 8 })
			} else {
				// Closed Chest
				sdl.set_render_draw_color(renderer, 130, 75, 15, 255)
				sdl.render_fill_rect(renderer, &rect)

				// Gold Iron Bands
				sdl.set_render_draw_color(renderer, 230, 185, 0, 255)
				sdl.render_draw_rect(renderer, &rect)
				sdl.render_draw_line(renderer, x + 4, y + 22, x + cell_size - 4, y + 22)

				// Keyhole Lock Plate
				lock_plate := sdl.Rect{
					x: cx - 4
					y: cy - 2
					w: 8
					h: 8
				}
				sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
				sdl.render_fill_rect(renderer, &lock_plate)
				sdl.set_render_draw_color(renderer, 0, 0, 0, 255)
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 1, y: cy, w: 2, h: 4 })
			}
		}
		.door {
			// Gothic Castle Arch Exit Door
			rect := sdl.Rect{
				x: x + 4
				y: y + 2
				w: cell_size - 8
				h: cell_size - 2
			}
			if door_open {
				// Illuminated Open Exit Portal (Glowing Gold Stairs!)
				sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
				sdl.render_fill_rect(renderer, &rect)

				// Dark Portal Interior Arch
				portal := sdl.Rect{
					x: x + 8
					y: y + 6
					w: cell_size - 16
					h: cell_size - 6
				}
				sdl.set_render_draw_color(renderer, 10, 10, 15, 255)
				sdl.render_fill_rect(renderer, &portal)

				// Stairs leading upward
				sdl.set_render_draw_color(renderer, 200, 160, 30, 255)
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 10, y: y + 36, w: cell_size - 20, h: 4 })
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 12, y: y + 28, w: cell_size - 24, h: 4 })
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 14, y: y + 20, w: cell_size - 28, h: 4 })
			} else {
				// Locked Heavy Iron Wood Door
				sdl.set_render_draw_color(renderer, 100, 55, 20, 255)
				sdl.render_fill_rect(renderer, &rect)

				// Stone Arch Surround
				sdl.set_render_draw_color(renderer, 140, 140, 140, 255)
				sdl.render_draw_rect(renderer, &rect)

				// Iron Hinges & Keyhole
				sdl.set_render_draw_color(renderer, 40, 40, 45, 255)
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 10, w: 8, h: 3 })
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 32, w: 8, h: 3 })

				keyhole := sdl.Rect{
					x: cx - 3
					y: cy - 4
					w: 6
					h: 10
				}
				sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
				sdl.render_fill_rect(renderer, &keyhole)
			}
		}
		.lolo_spawn {
			draw_char(renderer, x + 16, y + 16, `L`, 2, Color{ r: 80, g: 180, b: 255 })
		}
		.hammer {
			// Steel Hammer Mallet
			draw_char(renderer, x + 16, y + 16, `T`, 2, Color{ r: 230, g: 230, b: 230 })
		}
		.snakey { draw_enemy_icon(renderer, x, y, .snakey) }
		.alma { draw_enemy_icon(renderer, x, y, .alma) }
		.leeper { draw_enemy_icon(renderer, x, y, .leeper) }
		.skull { draw_enemy_icon(renderer, x, y, .skull) }
		.medusa { draw_enemy_icon(renderer, x, y, .medusa) }
		.don_medusa_h { draw_enemy_icon(renderer, x, y, .don_medusa_h) }
		.don_medusa_v { draw_enemy_icon(renderer, x, y, .don_medusa_v) }
		else {}
	}
}

fn draw_enemy_icon(renderer &sdl.Renderer, x int, y int, kind EntityType) {
	dummy := Enemy{
		kind: kind
		x:    0
		y:    0
	}
	draw_enemy(renderer, x, y, dummy)
}

fn draw_enemy(renderer &sdl.Renderer, x int, y int, enemy Enemy) {
	cx := x + cell_size / 2
	cy := y + cell_size / 2

	rect := sdl.Rect{
		x: x + 4
		y: y + 4
		w: cell_size - 8
		h: cell_size - 8
	}

	if enemy.is_egg {
		// Dinosaur Egg Form (Speckled White-Cream Egg with Purple Spots)
		sdl.set_render_draw_color(renderer, 245, 240, 230, 255)
		sdl.render_fill_rect(renderer, &rect)

		// Egg Top Specular Highlight
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		sdl.render_draw_line(renderer, x + 8, y + 6, x + cell_size - 8, y + 6)

		// Purple Spots
		sdl.set_render_draw_color(renderer, 150, 50, 180, 255)
		sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 6, y: cy - 6, w: 6, h: 6 })
		sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 2, y: cy + 2, w: 5, h: 5 })
		return
	}

	match enemy.kind {
		.snakey {
			// Vibrant Coiled Green Cobra Snake
			sdl.set_render_draw_color(renderer, 30, 185, 60, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Yellow Belly Scales
			sdl.set_render_draw_color(renderer, 240, 220, 40, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 10, y: y + 20, w: cell_size - 20, h: 16 })

			// Black Eyes with Yellow Pupil
			sdl.set_render_draw_color(renderer, 0, 0, 0, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 8, y: cy - 10, w: 5, h: 6 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy - 10, w: 5, h: 6 })

			// Flicking Red Tongue
			sdl.set_render_draw_color(renderer, 240, 30, 40, 255)
			sdl.render_draw_line(renderer, cx, cy - 2, cx, cy + 4)
		}
		.alma {
			// Red Armadillo Monster
			sdl.set_render_draw_color(renderer, 220, 45, 40, 255)
			sdl.render_fill_rect(renderer, &rect)

			// White Shell Plates & Spikes
			sdl.set_render_draw_color(renderer, 250, 240, 230, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 6, w: cell_size - 12, h: 6 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 16, w: cell_size - 12, h: 6 })

			// Angry Eyes
			sdl.set_render_draw_color(renderer, 255, 255, 0, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 8, y: cy + 4, w: 5, h: 5 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy + 4, w: 5, h: 5 })
		}
		.leeper {
			// Lime Green Bunny
			sdl.set_render_draw_color(renderer, 125, 225, 85, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Long Bunny Ears
			ear1 := sdl.Rect{ x: x + 8, y: y + 1, w: 6, h: 10 }
			ear2 := sdl.Rect{ x: x + cell_size - 14, y: y + 1, w: 6, h: 10 }
			sdl.set_render_draw_color(renderer, 255, 180, 200, 255) // Pink inner ear
			sdl.render_fill_rect(renderer, &ear1)
			sdl.render_fill_rect(renderer, &ear2)

			if enemy.is_asleep {
				draw_text(renderer, x + 6, y + 16, 'Zzz', 1, Color{ r: 255, g: 255, b: 255 })
			} else {
				// Black Eyes
				sdl.set_render_draw_color(renderer, 0, 0, 0, 255)
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 7, y: cy - 2, w: 4, h: 6 })
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy - 2, w: 4, h: 6 })
			}
		}
		.skull {
			// Bone White Skull
			sdl.set_render_draw_color(renderer, 230, 225, 210, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Eye Sockets
			sdl.set_render_draw_color(renderer, 20, 20, 20, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 9, y: cy - 8, w: 6, h: 8 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy - 8, w: 6, h: 8 })

			// Glowing Red Eyes when awakened
			sdl.set_render_draw_color(renderer, 255, 0, 0, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 7, y: cy - 6, w: 3, h: 3 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 4, y: cy - 6, w: 3, h: 3 })

			// Teeth Grin
			sdl.set_render_draw_color(renderer, 0, 0, 0, 255)
			sdl.render_draw_line(renderer, cx - 8, cy + 8, cx + 8, cy + 8)
			sdl.render_draw_line(renderer, cx - 4, cy + 5, cx - 4, cy + 11)
			sdl.render_draw_line(renderer, cx, cy + 5, cx, cy + 11)
			sdl.render_draw_line(renderer, cx + 4, cy + 5, cx + 4, cy + 11)
		}
		.medusa {
			// Purple Medusa Head with Snake Hair
			sdl.set_render_draw_color(renderer, 150, 40, 170, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Serpentine hair tendrils
			sdl.set_render_draw_color(renderer, 100, 20, 120, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 2, y: y + 2, w: 8, h: 8 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + cell_size - 10, y: y + 2, w: 8, h: 8 })

			// Glowing Gold Eyes
			sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 8, y: cy - 6, w: 6, h: 6 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 2, y: cy - 6, w: 6, h: 6 })
		}
		.don_medusa_h, .don_medusa_v {
			// Crowned Don Medusa Head
			sdl.set_render_draw_color(renderer, 110, 20, 130, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Golden Crown
			crown := sdl.Rect{ x: x + 8, y: y + 2, w: cell_size - 16, h: 8 }
			sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
			sdl.render_fill_rect(renderer, &crown)

			// Ruby Crown Gem
			sdl.set_render_draw_color(renderer, 230, 20, 20, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 2, y: y + 4, w: 4, h: 4 })

			// Fierce Red Eyes
			sdl.set_render_draw_color(renderer, 255, 40, 40, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 8, y: cy - 4, w: 6, h: 6 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 2, y: cy - 4, w: 6, h: 6 })
		}
		else {}
	}
}

fn draw_lolo(renderer &sdl.Renderer, x int, y int, dir Direction) {
	// Lolo: Spherical 3D Shaded Blue Character
	rect := sdl.Rect{
		x: x + 3
		y: y + 3
		w: cell_size - 6
		h: cell_size - 6
	}

	// Body Base Shading (Royal Blue)
	sdl.set_render_draw_color(renderer, 35, 120, 245, 255)
	sdl.render_fill_rect(renderer, &rect)

	// Top Highlight Arc (Bright Cyan)
	sdl.set_render_draw_color(renderer, 100, 200, 255, 255)
	sdl.render_draw_line(renderer, x + 6, y + 4, x + cell_size - 6, y + 4)

	// White Face Oval Plate
	face := sdl.Rect{
		x: x + 10
		y: y + 8
		w: cell_size - 20
		h: cell_size - 20
	}
	sdl.set_render_draw_color(renderer, 250, 250, 255, 255)
	sdl.render_fill_rect(renderer, &face)

	// Rosy Pink Cheeks
	sdl.set_render_draw_color(renderer, 255, 150, 180, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 10, y: y + 24, w: 5, h: 4 })
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + cell_size - 15, y: y + 24, w: 5, h: 4 })

	// Large Expressive Eyes & Direction Pupils
	cx := x + cell_size / 2
	cy := y + cell_size / 2

	mut eye_off_x := 0
	mut eye_off_y := 0
	match dir {
		.up { eye_off_y = -3 }
		.down { eye_off_y = 3 }
		.left { eye_off_x = -3 }
		.right { eye_off_x = 3 }
	}

	e1 := sdl.Rect{
		x: cx - 9 + eye_off_x
		y: cy - 7 + eye_off_y
		w: 6
		h: 9
	}
	e2 := sdl.Rect{
		x: cx + 3 + eye_off_x
		y: cy - 7 + eye_off_y
		w: 6
		h: 9
	}
	sdl.set_render_draw_color(renderer, 10, 20, 40, 255)
	sdl.render_fill_rect(renderer, &e1)
	sdl.render_fill_rect(renderer, &e2)

	// Blue Iris & Specular White Eye Dots
	sdl.set_render_draw_color(renderer, 30, 120, 240, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 8 + eye_off_x, y: cy - 4 + eye_off_y, w: 3, h: 4 })
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 4 + eye_off_x, y: cy - 4 + eye_off_y, w: 3, h: 4 })

	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 8 + eye_off_x, y: cy - 6 + eye_off_y, w: 2, h: 2 })
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 4 + eye_off_x, y: cy - 6 + eye_off_y, w: 2, h: 2 })

	// Cute Round Yellow Feet
	f1 := sdl.Rect{
		x: x + 6
		y: y + cell_size - 5
		w: 12
		h: 5
	}
	f2 := sdl.Rect{
		x: x + cell_size - 18
		y: y + cell_size - 5
		w: 12
		h: 5
	}
	sdl.set_render_draw_color(renderer, 255, 200, 0, 255)
	sdl.render_fill_rect(renderer, &f1)
	sdl.render_fill_rect(renderer, &f2)
}

fn draw_magic_shot(renderer &sdl.Renderer, sx int, sy int) {
	// Plasma Energy Orb
	orb := sdl.Rect{
		x: sx - 9
		y: sy - 9
		w: 18
		h: 18
	}
	sdl.set_render_draw_color(renderer, 0, 230, 255, 255)
	sdl.render_fill_rect(renderer, &orb)

	// White Core Spark
	core := sdl.Rect{
		x: sx - 4
		y: sy - 4
		w: 8
		h: 8
	}
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	sdl.render_fill_rect(renderer, &core)
}

fn draw_hud_panel(renderer &sdl.Renderer, game Game, mx int, my int, btn_prev Button, btn_next Button, btn_restart Button) {
	panel_x := 600
	panel_y := 90

	// HUD Title Box
	draw_text(renderer, panel_x, panel_y, 'LEVEL OBJECTIVES', 2, Color{ r: 255, g: 215, b: 0 })

	// Heart Counter
	draw_char(renderer, panel_x, panel_y + 35, `@`, 2, Color{ r: 255, g: 50, b: 80 })
	hearts_str := 'HEARTS LEFT: ${game.hearts_remaining} / ${game.total_hearts}'
	draw_text(renderer, panel_x + 24, panel_y + 35, hearts_str, 2, Color{ r: 255, g: 255, b: 255 })

	// Magic Shot Counter
	shots_str := 'MAGIC SHOTS: ${game.lolo.shots}'
	draw_text(renderer, panel_x + 24, panel_y + 65, shots_str, 2, Color{ r: 0, g: 220, b: 255 })

	// Hammer Counter
	hammers_str := 'HAMMERS: ${game.lolo.hammers}'
	draw_text(renderer, panel_x + 24, panel_y + 95, hammers_str, 2, Color{ r: 220, g: 220, b: 220 })

	// Instructions List Container
	draw_text(renderer, panel_x, panel_y + 145, 'CONTROLS:', 2, Color{ r: 255, g: 215, b: 0 })
	draw_text(renderer, panel_x, panel_y + 175, 'WASD / ARROWS: MOVE LOLO', 1, Color{ r: 180, g: 200, b: 230 })
	draw_text(renderer, panel_x, panel_y + 195, 'SPACE: FIRE MAGIC SHOT', 1, Color{ r: 180, g: 200, b: 230 })
	draw_text(renderer, panel_x, panel_y + 215, 'PUSH GREEN BLOCKS INTO WATER', 1, Color{ r: 180, g: 200, b: 230 })
	draw_text(renderer, panel_x, panel_y + 235, 'SHOT TURNS ENEMY TO EGG', 1, Color{ r: 180, g: 200, b: 230 })
	draw_text(renderer, panel_x, panel_y + 255, 'R: RETRY LEVEL | P: PAUSE', 1, Color{ r: 180, g: 200, b: 230 })

	// Level Select & Restart Buttons
	btn_prev.draw(renderer, mx, my)
	btn_next.draw(renderer, mx, my)
	btn_restart.draw(renderer, mx, my)
}

fn draw_editor_palette(renderer &sdl.Renderer, game Game, mx int, my int, btn_test Button, btn_clear Button) {
	panel_x := 600
	panel_y := 90

	draw_text(renderer, panel_x, panel_y, 'TILE & ENTITY PALETTE', 2, Color{ r: 255, g: 215, b: 0 })
	draw_text(renderer, panel_x, panel_y + 25, 'CLICK ITEM, THEN PAINT ON GRID', 1, Color{ r: 180, g: 200, b: 230 })

	// Draw Tile/Entity Selection Options
	items := [
		'GRASS', 'WALL', 'ROCK', 'TREE', 'WATER', 'BRIDGE',
		'EMERALD', 'HEART', 'CHEST', 'DOOR', 'SPAWN',
		'SNAKEY', 'ALMA', 'LEEPER', 'SKULL', 'MEDUSA', 'DON MED H', 'DON MED V'
	]

	for idx, item in items {
		ix := panel_x + (idx % 3) * 105
		iy := panel_y + 55 + (idx / 3) * 35

		is_selected := if idx < 6 {
			!game.is_entity_selected && int(game.selected_tile) == idx
		} else {
			game.is_entity_selected && get_entity_from_palette_index(idx) == game.selected_entity
		}

		btn_rect := sdl.Rect{
			x: ix
			y: iy
			w: 100
			h: 30
		}
		bg_c := if is_selected { Color{ r: 80, g: 140, b: 220 } } else { Color{ r: 40, g: 50, b: 70 } }
		sdl.set_render_draw_color(renderer, bg_c.r, bg_c.g, bg_c.b, bg_c.a)
		sdl.render_fill_rect(renderer, &btn_rect)

		border_c := if is_selected { Color{ r: 255, g: 215, b: 0 } } else { Color{ r: 70, g: 90, b: 120 } }
		sdl.set_render_draw_color(renderer, border_c.r, border_c.g, border_c.b, border_c.a)
		sdl.render_draw_rect(renderer, &btn_rect)

		draw_text_centered(renderer, ix + 50, iy + 8, item, 1, Color{ r: 255, g: 255, b: 255 })
	}

	// Validation Message
	if game.validation_msg != '' {
		draw_text(renderer, panel_x, panel_y + 285, game.validation_msg, 1, Color{ r: 255, g: 80, b: 80 })
	}

	// Test Play & Clear Buttons
	btn_test.draw(renderer, mx, my)
	btn_clear.draw(renderer, mx, my)
}

pub fn get_entity_from_palette_index(idx int) EntityType {
	match idx {
		6 { return .emerald_frame }
		7 { return .heart_frame }
		8 { return .chest }
		9 { return .door }
		10 { return .lolo_spawn }
		11 { return .snakey }
		12 { return .alma }
		13 { return .leeper }
		14 { return .skull }
		15 { return .medusa }
		16 { return .don_medusa_h }
		17 { return .don_medusa_v }
		else { return .none }
	}
}

fn draw_status_overlay(renderer &sdl.Renderer, game Game) {
	overlay := sdl.Rect{
		x: grid_offset_x + 40
		y: grid_offset_y + 180
		w: (grid_cols * cell_size) - 80
		h: 120
	}

	sdl.set_render_draw_color(renderer, 20, 24, 38, 235)
	sdl.render_fill_rect(renderer, &overlay)

	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	sdl.render_draw_rect(renderer, &overlay)

	msg := if game.status_msg != '' {
		game.status_msg
	} else if game.status == .won {
		'YOU BEAT ALL LEVELS!'
	} else {
		'LEVEL COMPLETED!'
	}
	draw_text_centered(renderer, overlay.x + overlay.w / 2, overlay.y + 45, msg, 2, Color{ r: 255, g: 255, b: 255 })
}
