module main

import math
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
	sdl.set_render_draw_color(renderer, u8(math_min(int(bg.r) + 45, 255)), u8(math_min(int(bg.g) + 45, 255)),
		u8(math_min(int(bg.b) + 45, 255)), bg.a)
	sdl.render_draw_line(renderer, b.x, b.y, b.x + b.w, b.y)
	sdl.render_draw_line(renderer, b.x, b.y, b.x, b.y + b.h)

	// Bottom/Right shadow
	sdl.set_render_draw_color(renderer, u8(math_max(int(bg.r) - 35, 0)), u8(math_max(int(bg.g) - 35, 0)),
		u8(math_max(int(bg.b) - 35, 0)), bg.a)
	sdl.render_draw_line(renderer, b.x, b.y + b.h - 1, b.x + b.w, b.y + b.h - 1)
	sdl.render_draw_line(renderer, b.x + b.w - 1, b.y, b.x + b.w - 1, b.y + b.h)

	// Border outline
	sdl.set_render_draw_color(renderer, b.border_color.r, b.border_color.g, b.border_color.b, b.border_color.a)
	sdl.render_draw_rect(renderer, &rect)

	draw_text_centered(renderer, b.x + b.w / 2, b.y + (b.h - 16) / 2, b.text, 2, b.text_color)
}

fn math_min(a int, b int) int { return if a < b { a } else { b } }
fn math_max(a int, b int) int { return if a > b { a } else { b } }

pub fn draw_game(renderer &sdl.Renderer, game Game, mx int, my int, btn_editor Button, btn_restart Button, btn_sound Button, btn_prev Button, btn_next Button, btn_test Button, btn_clear Button, btn_undo Button, btn_level_select Button) {
	// Deep Royal Castle Background
	sdl.set_render_draw_color(renderer, 12, 14, 22, 255)
	sdl.render_clear(renderer)

	// Castle Masonry Background Pattern
	ticks := sdl.get_ticks()
	for r in 0 .. 15 {
		y := r * 48
		for c in 0 .. 20 {
			x := c * 48
			sdl.set_render_draw_color(renderer, 18, 22, 34, 255)
			sdl.render_draw_rect(renderer, &sdl.Rect{ x: x, y: y, w: 48, h: 48 })
		}
	}

	// Draw Header Bar
	draw_header(renderer, game)

	// Draw Main Playfield / Grid
	draw_playfield(renderer, game, ticks)

	// Draw Sidebar / UI Controls
	if game.mode == .editor {
		draw_editor_palette(renderer, game, mx, my, btn_test, btn_clear)
	} else {
		draw_hud_panel(renderer, game, mx, my, btn_prev, btn_next, btn_restart, btn_undo, btn_level_select)
	}

	// Draw Common UI Action Buttons
	btn_editor.draw(renderer, mx, my)
	btn_sound.draw(renderer, mx, my)

	// Grand Victory Ending Cutscene
	if game.status == .won {
		draw_victory_ending(renderer, game, ticks)
	} else if game.status == .lost || game.status == .level_clear {
		draw_status_overlay(renderer, game)
	}

	// Level Select Modal Dialog
	if game.is_level_select_open {
		draw_level_select_modal(renderer, game, mx, my)
	}
}

fn draw_header(renderer &sdl.Renderer, game Game) {
	hdr_rect := sdl.Rect{ x: 0, y: 0, w: win_w, h: 64 }
	sdl.set_render_draw_color(renderer, 24, 30, 44, 255)
	sdl.render_fill_rect(renderer, &hdr_rect)

	// Gold header dividing rail
	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	sdl.render_draw_line(renderer, 0, 62, win_w, 62)
	sdl.render_draw_line(renderer, 0, 63, win_w, 63)
	sdl.set_render_draw_color(renderer, 160, 120, 0, 255)
	sdl.render_draw_line(renderer, 0, 64, win_w, 64)

	// Title & Floor Room
	draw_text(renderer, 20, 12, 'ADVENTURES OF LOLO', 2, Color{ r: 255, g: 215, b: 0 })

	lvl_name := if game.mode == .editor {
		'INTERACTIVE LEVEL DESIGNER & TESTER'
	} else {
		'FLOOR ${game.current_level.floor} - ${game.current_level.name} [PASS: ${game.current_level.password}]'
	}
	draw_text(renderer, 20, 36, lvl_name, 2, Color{ r: 180, g: 225, b: 255 })

	// Score & Moves & Lives
	score_str := 'SCORE: ${game.score:06d}'
	draw_text(renderer, 570, 14, score_str, 2, Color{ r: 255, g: 255, b: 255 })

	moves_str := 'MOVES: ${game.moves_count}'
	draw_text(renderer, 570, 36, moves_str, 2, Color{ r: 140, g: 220, b: 255 })

	lives_str := 'LIVES: ${game.lives}'
	draw_text(renderer, 680, 36, lives_str, 2, Color{ r: 255, g: 120, b: 120 })
}

fn draw_playfield(renderer &sdl.Renderer, game Game, ticks u32) {
	// Heavy 3D Castle Wall Outer Frame
	frame_rect := sdl.Rect{
		x: grid_offset_x - 12
		y: grid_offset_y - 12
		w: (grid_cols * cell_size) + 24
		h: (grid_rows * cell_size) + 24
	}
	sdl.set_render_draw_color(renderer, 75, 60, 50, 255)
	sdl.render_fill_rect(renderer, &frame_rect)

	// Castle wall brick blocks on frame border
	sdl.set_render_draw_color(renderer, 50, 40, 32, 255)
	for i in 0 .. (grid_cols + 1) {
		bx := grid_offset_x - 12 + i * cell_size
		sdl.render_draw_line(renderer, bx, grid_offset_y - 12, bx, grid_offset_y)
		sdl.render_draw_line(renderer, bx, grid_offset_y + grid_rows * cell_size, bx, grid_offset_y + grid_rows * cell_size + 12)
	}

	// Inner Gold Trim
	gold_trim := sdl.Rect{
		x: grid_offset_x - 4
		y: grid_offset_y - 4
		w: (grid_cols * cell_size) + 8
		h: (grid_rows * cell_size) + 8
	}
	sdl.set_render_draw_color(renderer, 220, 180, 20, 255)
	sdl.render_draw_rect(renderer, &gold_trim)

	inner_rect := sdl.Rect{
		x: grid_offset_x
		y: grid_offset_y
		w: grid_cols * cell_size
		h: grid_rows * cell_size
	}
	sdl.set_render_draw_color(renderer, 32, 95, 45, 255)
	sdl.render_fill_rect(renderer, &inner_rect)

	// 1. Draw Floor Tiles
	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			tile := if game.mode == .editor { game.editor_level.grid[r][c] } else { game.grid[r][c] }
			tx := grid_offset_x + c * cell_size
			ty := grid_offset_y + r * cell_size
			draw_tile(renderer, tx, ty, tile, r, c, ticks)
		}
	}

	// 2. Draw Entities
	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			ent := if game.mode == .editor { game.editor_level.entities[r][c] } else { game.entities[r][c] }
			if ent != .none {
				tx := grid_offset_x + c * cell_size
				ty := grid_offset_y + r * cell_size
				draw_entity(renderer, tx, ty, ent, game.chest_open, game.door_open, ticks)
			}
		}
	}

	// 3. Draw Dynamic Enemies (In Play Mode)
	if game.mode == .play {
		for enemy in game.enemies {
			if enemy.x >= 0 && enemy.x < grid_cols && enemy.y >= 0 && enemy.y < grid_rows {
				ex := grid_offset_x + enemy.x * cell_size
				ey := grid_offset_y + enemy.y * cell_size
				draw_enemy(renderer, ex, ey, enemy, ticks)
			}
		}
	}

	// 4. Draw Lolo
	if game.mode == .play && !game.lolo.is_dead {
		lx := grid_offset_x + game.lolo.x * cell_size
		ly := grid_offset_y + game.lolo.y * cell_size
		draw_lolo(renderer, lx, ly, game.lolo.dir, ticks)
	}

	// 5. Draw Magic Shot
	if game.mode == .play && game.magic_shot.active {
		sx := grid_offset_x + int(game.magic_shot.x * f64(cell_size)) + cell_size / 2
		sy := grid_offset_y + int(game.magic_shot.y * f64(cell_size)) + cell_size / 2
		draw_magic_shot(renderer, sx, sy, ticks)
	}

	// 6. Draw Medusa Laser Beam with crackling electric arc
	if game.medusa_laser_active {
		x1 := grid_offset_x + game.laser_x1 * cell_size + cell_size / 2
		y1 := grid_offset_y + game.laser_y1 * cell_size + cell_size / 2
		x2 := grid_offset_x + game.laser_x2 * cell_size + cell_size / 2
		y2 := grid_offset_y + game.laser_y2 * cell_size + cell_size / 2

		// Outer red electric corona
		sdl.set_render_draw_color(renderer, 255, 50, 50, 255)
		sdl.render_draw_line(renderer, x1 - 2, y1 - 2, x2 - 2, y2 - 2)
		sdl.render_draw_line(renderer, x1 + 2, y1 + 2, x2 + 2, y2 + 2)
		sdl.render_draw_line(renderer, x1 - 1, y1 - 1, x2 - 1, y2 - 1)
		sdl.render_draw_line(renderer, x1 + 1, y1 + 1, x2 + 1, y2 + 1)

		// Intense white lightning core
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		sdl.render_draw_line(renderer, x1, y1, x2, y2)
	}
}

fn draw_tile(renderer &sdl.Renderer, x int, y int, tile TileType, r int, c int, ticks u32) {
	rect := sdl.Rect{ x: x, y: y, w: cell_size, h: cell_size }

	match tile {
		.grass {
			// Subtle checkerboard flagstone pattern
			bg_col := if (r + c) % 2 == 0 {
				Color{ r: 42, g: 125, b: 55, a: 255 }
			} else {
				Color{ r: 48, g: 140, b: 62, a: 255 }
			}
			sdl.set_render_draw_color(renderer, bg_col.r, bg_col.g, bg_col.b, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Subtle cobblestone mortar dots
			sdl.set_render_draw_color(renderer, 32, 95, 42, 255)
			sdl.render_draw_point(renderer, x + 12, y + 12)
			sdl.render_draw_point(renderer, x + 36, y + 36)
		}
		.wall {
			// 3D Stone Castle Block
			sdl.set_render_draw_color(renderer, 105, 90, 80, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Top and Left light bevel
			sdl.set_render_draw_color(renderer, 150, 135, 125, 255)
			sdl.render_draw_line(renderer, x + 1, y + 1, x + cell_size - 2, y + 1)
			sdl.render_draw_line(renderer, x + 1, y + 1, x + 1, y + cell_size - 2)

			// Brick division lines & mortar
			sdl.set_render_draw_color(renderer, 55, 45, 40, 255)
			sdl.render_draw_rect(renderer, &rect)
			sdl.render_draw_line(renderer, x, y + cell_size / 2, x + cell_size, y + cell_size / 2)
			sdl.render_draw_line(renderer, x + cell_size / 2, y, x + cell_size / 2, y + cell_size / 2)
		}
		.rock {
			// Faceted Boulder
			sdl.set_render_draw_color(renderer, 125, 130, 140, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Rock facets & specular bevel
			sdl.set_render_draw_color(renderer, 175, 180, 195, 255)
			f_top := sdl.Rect{ x: x + 6, y: y + 6, w: cell_size - 16, h: 10 }
			sdl.render_fill_rect(renderer, &f_top)

			sdl.set_render_draw_color(renderer, 70, 75, 85, 255)
			f_bot := sdl.Rect{ x: x + 14, y: y + cell_size - 14, w: cell_size - 20, h: 8 }
			sdl.render_fill_rect(renderer, &f_bot)
			sdl.render_draw_rect(renderer, &rect)
		}
		.tree {
			// Woody trunk base
			sdl.set_render_draw_color(renderer, 95, 55, 20, 255)
			trunk := sdl.Rect{ x: x + 18, y: y + 28, w: 12, h: 16 }
			sdl.render_fill_rect(renderer, &trunk)

			// Multi-tiered Lush Green Tree Foliage Canopy
			sdl.set_render_draw_color(renderer, 18, 90, 32, 255)
			canopy_b := sdl.Rect{ x: x + 4, y: y + 12, w: cell_size - 8, h: 22 }
			sdl.render_fill_rect(renderer, &canopy_b)

			sdl.set_render_draw_color(renderer, 32, 145, 50, 255)
			canopy_m := sdl.Rect{ x: x + 8, y: y + 6, w: cell_size - 16, h: 20 }
			sdl.render_fill_rect(renderer, &canopy_m)

			sdl.set_render_draw_color(renderer, 70, 200, 85, 255)
			canopy_t := sdl.Rect{ x: x + 14, y: y + 4, w: cell_size - 28, h: 8 }
			sdl.render_fill_rect(renderer, &canopy_t)
		}
		.water {
			// Procedural Shimmering Water with animated sine-wave ripples
			sdl.set_render_draw_color(renderer, 24, 75, 175, 255)
			sdl.render_fill_rect(renderer, &rect)

			wave_off1 := int(math.sin(f64(ticks) / 200.0 + f64(c * 2)) * 4.0)
			wave_off2 := int(math.cos(f64(ticks) / 250.0 + f64(r * 2)) * 4.0)

			// Azure wave highlights
			sdl.set_render_draw_color(renderer, 50, 140, 245, 255)
			sdl.render_draw_line(renderer, x + 4, y + 14 + wave_off1, x + cell_size - 4, y + 14 + wave_off1)
			sdl.render_draw_line(renderer, x + 8, y + 32 + wave_off2, x + cell_size - 8, y + 32 + wave_off2)

			// Bright specular glint
			sdl.set_render_draw_color(renderer, 160, 220, 255, 255)
			sdl.render_draw_point(renderer, x + 16 + wave_off1, y + 13 + wave_off1)
			sdl.render_draw_point(renderer, x + 32 + wave_off2, y + 31 + wave_off2)
		}
		.bridge {
			// Wooden Plank Bridge over water
			sdl.set_render_draw_color(renderer, 140, 85, 30, 255)
			sdl.render_fill_rect(renderer, &rect)

			sdl.set_render_draw_color(renderer, 85, 45, 15, 255)
			sdl.render_draw_rect(renderer, &rect)
			sdl.render_draw_line(renderer, x, y + 12, x + cell_size, y + 12)
			sdl.render_draw_line(renderer, x, y + 24, x + cell_size, y + 24)
			sdl.render_draw_line(renderer, x, y + 36, x + cell_size, y + 36)

			// Metal nails
			sdl.set_render_draw_color(renderer, 220, 220, 220, 255)
			sdl.render_draw_point(renderer, x + 4, y + 6)
			sdl.render_draw_point(renderer, x + cell_size - 5, y + 6)
			sdl.render_draw_point(renderer, x + 4, y + 18)
			sdl.render_draw_point(renderer, x + cell_size - 5, y + 18)
		}
		.arrow_up {
			draw_arrow_tile(renderer, x, y, `^`)
		}
		.arrow_down {
			draw_arrow_tile(renderer, x, y, `v`)
		}
		.arrow_left {
			draw_arrow_tile(renderer, x, y, `<`)
		}
		.arrow_right {
			draw_arrow_tile(renderer, x, y, `>`)
		}
	}
}

fn draw_arrow_tile(renderer &sdl.Renderer, x int, y int, ch u8) {
	rect := sdl.Rect{ x: x, y: y, w: cell_size, h: cell_size }
	sdl.set_render_draw_color(renderer, 50, 130, 70, 255)
	sdl.render_fill_rect(renderer, &rect)

	sdl.set_render_draw_color(renderer, 25, 75, 40, 255)
	sdl.render_draw_rect(renderer, &rect)

	draw_char(renderer, x + 16, y + 16, ch, 2, Color{ r: 255, g: 255, b: 255 })
}

fn draw_entity(renderer &sdl.Renderer, x int, y int, ent EntityType, chest_open bool, door_open bool, ticks u32) {
	cx := x + cell_size / 2
	cy := y + cell_size / 2

	match ent {
		.emerald_frame {
			// Faceted cut emerald jewel with 3D octagonal bevels & gold brackets
			sdl.set_render_draw_color(renderer, 0, 150, 65, 255)
			body := sdl.Rect{ x: x + 4, y: y + 4, w: cell_size - 8, h: cell_size - 8 }
			sdl.render_fill_rect(renderer, &body)

			// Bright crystal highlights
			sdl.set_render_draw_color(renderer, 60, 230, 130, 255)
			top_facet := sdl.Rect{ x: x + 8, y: y + 8, w: cell_size - 16, h: cell_size - 16 }
			sdl.render_fill_rect(renderer, &top_facet)

			sdl.set_render_draw_color(renderer, 180, 255, 210, 255)
			glint := sdl.Rect{ x: cx - 6, y: cy - 6, w: 12, h: 12 }
			sdl.render_fill_rect(renderer, &glint)

			// Gold Corner Brackets
			sdl.set_render_draw_color(renderer, 240, 195, 20, 255)
			sdl.render_draw_rect(renderer, &body)
		}
		.heart_frame {
			// Ornate Gold Frame with pulsating Ruby Heart
			pulse := int((math.sin(f64(ticks) / 180.0) + 1.0) * 15.0)

			sdl.set_render_draw_color(renderer, 235, 190, 20, 255)
			f_rect := sdl.Rect{ x: x + 4, y: y + 4, w: cell_size - 8, h: cell_size - 8 }
			sdl.render_fill_rect(renderer, &f_rect)

			sdl.set_render_draw_color(renderer, 50, 20, 20, 255)
			inner := sdl.Rect{ x: x + 7, y: y + 7, w: cell_size - 14, h: cell_size - 14 }
			sdl.render_fill_rect(renderer, &inner)

			// Radiant Ruby Heart Shape
			sdl.set_render_draw_color(renderer, u8(220 + pulse), 20, 50, 255)
			h1 := sdl.Rect{ x: cx - 11, y: cy - 9, w: 10, h: 10 }
			h2 := sdl.Rect{ x: cx + 1, y: cy - 9, w: 10, h: 10 }
			h3 := sdl.Rect{ x: cx - 9, y: cy + 1, w: 18, h: 9 }
			h4 := sdl.Rect{ x: cx - 4, y: cy + 10, w: 8, h: 4 }
			sdl.render_fill_rect(renderer, &h1)
			sdl.render_fill_rect(renderer, &h2)
			sdl.render_fill_rect(renderer, &h3)
			sdl.render_fill_rect(renderer, &h4)

			// White sparkle glint
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_draw_point(renderer, cx - 7, cy - 6)
			sdl.render_draw_point(renderer, cx - 6, cy - 6)
		}
		.chest {
			rect := sdl.Rect{ x: x + 4, y: y + 8, w: cell_size - 8, h: cell_size - 12 }
			if chest_open {
				// Royal Open Chest with floating Eden Jewel
				sdl.set_render_draw_color(renderer, 150, 90, 20, 255)
				sdl.render_fill_rect(renderer, &rect)

				// Golden interior glow
				sdl.set_render_draw_color(renderer, 255, 220, 50, 255)
				inner := sdl.Rect{ x: cx - 12, y: cy - 8, w: 24, h: 14 }
				sdl.render_fill_rect(renderer, &inner)

				// Floating Eden Jewel
				float_y := int(math.sin(f64(ticks) / 160.0) * 4.0)
				sdl.set_render_draw_color(renderer, 0, 220, 255, 255)
				gem := sdl.Rect{ x: cx - 6, y: cy - 14 + float_y, w: 12, h: 12 }
				sdl.render_fill_rect(renderer, &gem)

				sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
				gem_c := sdl.Rect{ x: cx - 2, y: cy - 10 + float_y, w: 4, h: 4 }
				sdl.render_fill_rect(renderer, &gem_c)
			} else {
				// Heavy Sealed Royal Treasure Chest with Golden Bands
				sdl.set_render_draw_color(renderer, 135, 75, 18, 255)
				sdl.render_fill_rect(renderer, &rect)

				// Gold Bands & Filigree
				sdl.set_render_draw_color(renderer, 245, 195, 25, 255)
				b1 := sdl.Rect{ x: x + 10, y: y + 8, w: 5, h: cell_size - 12 }
				b2 := sdl.Rect{ x: x + cell_size - 15, y: y + 8, w: 5, h: cell_size - 12 }
				sdl.render_fill_rect(renderer, &b1)
				sdl.render_fill_rect(renderer, &b2)

				// Ruby Lock Latch
				sdl.set_render_draw_color(renderer, 220, 30, 30, 255)
				latch_rect := sdl.Rect{ x: cx - 4, y: cy + 2, w: 8, h: 8 }
				sdl.render_fill_rect(renderer, &latch_rect)
			}
		}
		.door {
			rect := sdl.Rect{ x: x + 4, y: y + 2, w: cell_size - 8, h: cell_size - 2 }
			if door_open {
				// Magical Swirling Portal Exit
				sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
				sdl.render_fill_rect(renderer, &rect)

				// Glowing mystical portal center
				sdl.set_render_draw_color(renderer, 10, 180, 240, 255)
				portal := sdl.Rect{ x: x + 8, y: y + 6, w: cell_size - 16, h: cell_size - 6 }
				sdl.render_fill_rect(renderer, &portal)

				// Swirling white core
				sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
				core := sdl.Rect{ x: cx - 6, y: cy - 2, w: 12, h: 16 }
				sdl.render_fill_rect(renderer, &core)
			} else {
				// Sealed Dungeon Portcullis Gate
				sdl.set_render_draw_color(renderer, 85, 75, 70, 255)
				sdl.render_fill_rect(renderer, &rect)

				// Iron bars
				sdl.set_render_draw_color(renderer, 35, 30, 30, 255)
				for bar := 0; bar < 4; bar++ {
					bx := x + 10 + bar * 8
					sdl.render_draw_line(renderer, bx, y + 4, bx, y + cell_size - 4)
				}
			}
		}
		.lolo_spawn {
			draw_char(renderer, x + 16, y + 16, `L`, 2, Color{ r: 90, g: 190, b: 255 })
		}
		.hammer {
			// Steel Warhammer
			sdl.set_render_draw_color(renderer, 130, 80, 25, 255)
			handle := sdl.Rect{ x: cx - 2, y: cy - 6, w: 4, h: 18 }
			sdl.render_fill_rect(renderer, &handle)

			sdl.set_render_draw_color(renderer, 200, 210, 225, 255)
			head := sdl.Rect{ x: cx - 10, y: cy - 12, w: 20, h: 8 }
			sdl.render_fill_rect(renderer, &head)
		}
		.snakey { draw_enemy_icon(renderer, x, y, .snakey, ticks) }
		.alma { draw_enemy_icon(renderer, x, y, .alma, ticks) }
		.leeper { draw_enemy_icon(renderer, x, y, .leeper, ticks) }
		.skull { draw_enemy_icon(renderer, x, y, .skull, ticks) }
		.medusa { draw_enemy_icon(renderer, x, y, .medusa, ticks) }
		.don_medusa_h { draw_enemy_icon(renderer, x, y, .don_medusa_h, ticks) }
		.don_medusa_v { draw_enemy_icon(renderer, x, y, .don_medusa_v, ticks) }
		.gol { draw_enemy_icon(renderer, x, y, .gol, ticks) }
		.king_egger { draw_enemy_icon(renderer, x, y, .king_egger, ticks) }
		else {}
	}
}

fn draw_enemy_icon(renderer &sdl.Renderer, x int, y int, kind EntityType, ticks u32) {
	dummy := Enemy{ kind: kind, x: 0, y: 0 }
	draw_enemy(renderer, x, y, dummy, ticks)
}

fn draw_enemy(renderer &sdl.Renderer, x int, y int, enemy Enemy, ticks u32) {
	cx := x + cell_size / 2
	cy := y + cell_size / 2
	rect := sdl.Rect{ x: x + 4, y: y + 4, w: cell_size - 8, h: cell_size - 8 }

	if enemy.is_egg {
		// Speckled Dinosaur Egg with cute wobble
		wobble := int(math.sin(f64(ticks) / 120.0) * 2.0)
		sdl.set_render_draw_color(renderer, 250, 245, 235, 255)
		egg_rect := sdl.Rect{ x: x + 6 + wobble, y: y + 4, w: cell_size - 12, h: cell_size - 8 }
		sdl.render_fill_rect(renderer, &egg_rect)

		// Purple spots
		sdl.set_render_draw_color(renderer, 160, 60, 185, 255)
		sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 6 + wobble, y: cy - 8, w: 6, h: 6 })
		sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 2 + wobble, y: cy + 2, w: 5, h: 5 })
		return
	}

	match enemy.kind {
		.snakey {
			// Coiled Green Scales & Flickering Tongue
			sdl.set_render_draw_color(renderer, 25, 175, 55, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Yellow belly scales
			sdl.set_render_draw_color(renderer, 245, 225, 45, 255)
			belly := sdl.Rect{ x: x + 10, y: y + 22, w: cell_size - 20, h: 14 }
			sdl.render_fill_rect(renderer, &belly)

			// Eyes
			sdl.set_render_draw_color(renderer, 20, 20, 20, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 8, y: cy - 8, w: 5, h: 6 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy - 8, w: 5, h: 6 })

			// Animated red forked tongue
			if (ticks / 250) % 2 == 0 {
				sdl.set_render_draw_color(renderer, 255, 40, 40, 255)
				sdl.render_draw_line(renderer, cx, y + cell_size - 6, cx, y + cell_size - 1)
				sdl.render_draw_line(renderer, cx, y + cell_size - 1, cx - 2, y + cell_size + 1)
				sdl.render_draw_line(renderer, cx, y + cell_size - 1, cx + 2, y + cell_size + 1)
			}
		}
		.alma {
			// Spiked Armadillo Beast
			sdl.set_render_draw_color(renderer, 225, 45, 40, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Armored shell bands
			sdl.set_render_draw_color(renderer, 255, 240, 220, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 6, w: cell_size - 12, h: 6 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 16, w: cell_size - 12, h: 6 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 26, w: cell_size - 12, h: 6 })
		}
		.leeper {
			// Bouncy bunny-eared imp
			sdl.set_render_draw_color(renderer, 120, 225, 80, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Pink Inner Ears
			ear1 := sdl.Rect{ x: x + 8, y: y + 1, w: 6, h: 10 }
			ear2 := sdl.Rect{ x: x + cell_size - 14, y: y + 1, w: 6, h: 10 }
			sdl.set_render_draw_color(renderer, 255, 175, 200, 255)
			sdl.render_fill_rect(renderer, &ear1)
			sdl.render_fill_rect(renderer, &ear2)

			if enemy.is_asleep {
				// Closed sleepy eyes & floating Zzz
				sdl.set_render_draw_color(renderer, 20, 20, 20, 255)
				sdl.render_draw_line(renderer, cx - 8, cy - 2, cx - 3, cy - 2)
				sdl.render_draw_line(renderer, cx + 3, cy - 2, cx + 8, cy - 2)

				// Floating Zzz animation
				z_off := int(math.sin(f64(ticks) / 200.0) * 3.0)
				draw_text(renderer, x + 6, y + 14 + z_off, 'Zzz', 1, Color{ r: 255, g: 255, b: 255 })
			} else {
				// Wide curious eyes
				sdl.set_render_draw_color(renderer, 20, 20, 20, 255)
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 7, y: cy - 4, w: 4, h: 5 })
				sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy - 4, w: 4, h: 5 })
			}
		}
		.skull {
			// Polished Bone Skull with glowing sockets
			sdl.set_render_draw_color(renderer, 235, 230, 215, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Dark menacing eye sockets
			sdl.set_render_draw_color(renderer, 20, 20, 25, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 8, y: cy - 6, w: 5, h: 7 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy - 6, w: 5, h: 7 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 6, y: cy + 8, w: 12, h: 5 })

			// Glowing red soul flame
			sdl.set_render_draw_color(renderer, 255, 30, 30, 255)
			sdl.render_draw_point(renderer, cx - 6, cy - 3)
			sdl.render_draw_point(renderer, cx + 5, cy - 3)
		}
		.medusa {
			// Writhing stone snake hair & glowing red gaze
			sdl.set_render_draw_color(renderer, 135, 130, 150, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Snake crown
			sdl.set_render_draw_color(renderer, 40, 185, 75, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 4, w: cell_size - 12, h: 8 })

			// Sinister glowing ruby eyes
			sdl.set_render_draw_color(renderer, 255, 30, 30, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 7, y: cy + 2, w: 4, h: 4 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy + 2, w: 4, h: 4 })
		}
		.don_medusa_h, .don_medusa_v {
			// Armored demon visage with gold horned helm
			sdl.set_render_draw_color(renderer, 225, 55, 35, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Golden Horned Crown
			sdl.set_render_draw_color(renderer, 255, 215, 40, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 2, w: cell_size - 12, h: 8 })

			// Intimidating white/red eyes
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 7, y: cy + 3, w: 4, h: 4 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy + 3, w: 4, h: 4 })
		}
		.gol {
			// Blue Fire Dragon
			sdl.set_render_draw_color(renderer, 45, 115, 230, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Horns
			sdl.set_render_draw_color(renderer, 255, 210, 45, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y + 2, w: 5, h: 8 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + cell_size - 11, y: y + 2, w: 5, h: 8 })

			// Glowing dragon eyes
			sdl.set_render_draw_color(renderer, 255, 60, 30, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 7, y: cy, w: 4, h: 5 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy, w: 4, h: 5 })
		}
		.king_egger {
			// Grand Devil King Egger Boss
			sdl.set_render_draw_color(renderer, 125, 35, 160, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Massive Golden Crown with Ruby Gems
			sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 6, y: y, w: cell_size - 12, h: 10 })

			sdl.set_render_draw_color(renderer, 255, 40, 40, 255)
			sdl.render_draw_point(renderer, cx - 6, y + 4)
			sdl.render_draw_point(renderer, cx, y + 4)
			sdl.render_draw_point(renderer, cx + 6, y + 4)

			// Boss Cape & Glowing Eyes
			sdl.set_render_draw_color(renderer, 255, 240, 240, 255)
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx - 7, y: cy + 2, w: 4, h: 5 })
			sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx + 3, y: cy + 2, w: 4, h: 5 })
		}
		else {}
	}
}

fn draw_lolo(renderer &sdl.Renderer, x int, y int, dir Direction, ticks u32) {
	cx := x + cell_size / 2
	cy := y + cell_size / 2

	// Glossy Cobalt Blue Round Body
	sdl.set_render_draw_color(renderer, 30, 110, 235, 255)
	body := sdl.Rect{ x: x + 6, y: y + 6, w: cell_size - 12, h: cell_size - 12 }
	sdl.render_fill_rect(renderer, &body)

	// Top spherical light sheen
	sdl.set_render_draw_color(renderer, 90, 180, 255, 255)
	sheen := sdl.Rect{ x: x + 10, y: y + 8, w: cell_size - 20, h: 7 }
	sdl.render_fill_rect(renderer, &sheen)

	// Blinking & Expressive Directional Eyes
	is_blinking := (ticks / 2200) % 15 == 0

	if !is_blinking {
		eye_off_x := match dir {
			.left { -3 }
			.right { 3 }
			else { 0 }
		}
		eye_off_y := match dir {
			.up { -3 }
			.down { 2 }
			else { 0 }
		}

		// White sclera
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		e1 := sdl.Rect{ x: cx - 8 + eye_off_x, y: cy - 7 + eye_off_y, w: 6, h: 8 }
		e2 := sdl.Rect{ x: cx + 2 + eye_off_x, y: cy - 7 + eye_off_y, w: 6, h: 8 }
		sdl.render_fill_rect(renderer, &e1)
		sdl.render_fill_rect(renderer, &e2)

		// Dark blue pupils looking in movement direction
		sdl.set_render_draw_color(renderer, 10, 40, 120, 255)
		p1 := sdl.Rect{ x: cx - 6 + eye_off_x, y: cy - 5 + eye_off_y, w: 3, h: 5 }
		p2 := sdl.Rect{ x: cx + 4 + eye_off_x, y: cy - 5 + eye_off_y, w: 3, h: 5 }
		sdl.render_fill_rect(renderer, &p1)
		sdl.render_fill_rect(renderer, &p2)
	}

	// Cute Rosy Blushing Cheeks
	sdl.set_render_draw_color(renderer, 255, 140, 170, 255)
	c1 := sdl.Rect{ x: cx - 12, y: cy + 4, w: 4, h: 3 }
	c2 := sdl.Rect{ x: cx + 8, y: cy + 4, w: 4, h: 3 }
	sdl.render_fill_rect(renderer, &c1)
	sdl.render_fill_rect(renderer, &c2)

	// Step Bobbing Feet
	sdl.set_render_draw_color(renderer, 20, 80, 190, 255)
	f1 := sdl.Rect{ x: x + 8, y: y + cell_size - 8, w: 10, h: 5 }
	f2 := sdl.Rect{ x: x + cell_size - 18, y: y + cell_size - 8, w: 10, h: 5 }
	sdl.render_fill_rect(renderer, &f1)
	sdl.render_fill_rect(renderer, &f2)
}

fn draw_magic_shot(renderer &sdl.Renderer, sx int, sy int, ticks u32) {
	// Glowing Azure Magic Shot Orb
	pulse := int(math.sin(f64(ticks) / 80.0) * 3.0)

	sdl.set_render_draw_color(renderer, 50, 180, 255, 255)
	outer := sdl.Rect{ x: sx - 8 - pulse / 2, y: sy - 8 - pulse / 2, w: 16 + pulse, h: 16 + pulse }
	sdl.render_fill_rect(renderer, &outer)

	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	core := sdl.Rect{ x: sx - 4, y: sy - 4, w: 8, h: 8 }
	sdl.render_fill_rect(renderer, &core)
}

fn draw_hud_panel(renderer &sdl.Renderer, game Game, mx int, my int, btn_prev Button, btn_next Button, btn_restart Button, btn_undo Button, btn_level_select Button) {
	panel_x := 580
	panel_y := 80
	panel_w := 360
	panel_h := 580

	// Sidebar Card Container
	sdl.set_render_draw_color(renderer, 24, 30, 44, 255)
	card := sdl.Rect{ x: panel_x, y: panel_y, w: panel_w, h: panel_h }
	sdl.render_fill_rect(renderer, &card)

	sdl.set_render_draw_color(renderer, 60, 75, 105, 255)
	sdl.render_draw_rect(renderer, &card)

	// Section 1: Objective & Level Info
	draw_text(renderer, panel_x + 20, panel_y + 16, 'STAGE GOALS', 2, Color{ r: 255, g: 215, b: 0 })

	h_left_str := 'HEARTS REMAINING: ${game.hearts_remaining}'
	draw_text(renderer, panel_x + 20, panel_y + 44, h_left_str, 2, Color{ r: 255, g: 120, b: 120 })

	shots_str := 'MAGIC SHOTS: ${game.lolo.shots}'
	draw_text(renderer, panel_x + 20, panel_y + 70, shots_str, 2, Color{ r: 120, g: 220, b: 255 })

	chest_state := if game.chest_open { 'OPEN! COLLECT JEWEL' } else { 'LOCKED (GET HEARTS)' }
	chest_col := if game.chest_open { Color{ r: 100, g: 255, b: 120 } } else { Color{ r: 240, g: 180, b: 60 } }
	draw_text(renderer, panel_x + 20, panel_y + 96, 'CHEST: ${chest_state}', 2, chest_col)

	// Section 2: Instructions & Key Guide
	draw_text(renderer, panel_x + 20, panel_y + 140, 'HOW TO PLAY', 2, Color{ r: 255, g: 215, b: 0 })
	draw_text(renderer, panel_x + 20, panel_y + 166, 'ARROWS / WASD : MOVE LOLO', 1, Color{ r: 220, g: 230, b: 245 })
	draw_text(renderer, panel_x + 20, panel_y + 186, 'SPACE / ENTER : MAGIC SHOT', 1, Color{ r: 220, g: 230, b: 245 })
	draw_text(renderer, panel_x + 20, panel_y + 206, 'U / Z : UNDO MOVE', 1, Color{ r: 220, g: 230, b: 245 })
	draw_text(renderer, panel_x + 20, panel_y + 226, 'P : LEVEL SELECTOR', 1, Color{ r: 220, g: 230, b: 245 })
	draw_text(renderer, panel_x + 20, panel_y + 246, 'F11 : FULLSCREEN TOGGLE', 1, Color{ r: 220, g: 230, b: 245 })

	// Draw Action Buttons
	btn_undo.draw(renderer, mx, my)
	btn_level_select.draw(renderer, mx, my)
	btn_prev.draw(renderer, mx, my)
	btn_next.draw(renderer, mx, my)
	btn_restart.draw(renderer, mx, my)
}

fn draw_editor_palette(renderer &sdl.Renderer, game Game, mx int, my int, btn_test Button, btn_clear Button) {
	panel_x := 580
	panel_y := 80
	panel_w := 360
	panel_h := 580

	sdl.set_render_draw_color(renderer, 24, 30, 44, 255)
	card := sdl.Rect{ x: panel_x, y: panel_y, w: panel_w, h: panel_h }
	sdl.render_fill_rect(renderer, &card)

	sdl.set_render_draw_color(renderer, 60, 75, 105, 255)
	sdl.render_draw_rect(renderer, &card)

	draw_text(renderer, panel_x + 20, panel_y + 16, 'PALETTE SELECTION', 2, Color{ r: 255, g: 215, b: 0 })

	for idx in 0 .. 18 {
		ix := panel_x + 20 + (idx % 3) * 110
		iy := panel_y + 50 + (idx / 3) * 38

		is_sel := if idx < 6 {
			!game.is_entity_selected && int(game.selected_tile) == idx
		} else {
			game.is_entity_selected && game.selected_entity == get_entity_from_palette_index(idx)
		}

		bg := if is_sel { Color{ r: 60, g: 120, b: 190 } } else { Color{ r: 40, g: 50, b: 70 } }
		sdl.set_render_draw_color(renderer, bg.r, bg.g, bg.b, 255)
		b_rect := sdl.Rect{ x: ix, y: iy, w: 100, h: 32 }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 90, 115, 155, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		p_name := get_palette_name(idx)
		draw_text_centered(renderer, ix + 50, iy + 8, p_name, 1, Color{ r: 255, g: 255, b: 255 })
	}

	btn_test.draw(renderer, mx, my)
	btn_clear.draw(renderer, mx, my)
}

fn get_palette_name(idx int) string {
	match idx {
		0 { return 'GRASS' }
		1 { return 'WALL' }
		2 { return 'ROCK' }
		3 { return 'TREE' }
		4 { return 'WATER' }
		5 { return 'BRIDGE' }
		6 { return 'EMERALD' }
		7 { return 'HEART' }
		8 { return 'CHEST' }
		9 { return 'DOOR' }
		10 { return 'HAMMER' }
		11 { return 'LOLO' }
		12 { return 'SNAKEY' }
		13 { return 'ALMA' }
		14 { return 'LEEPER' }
		15 { return 'SKULL' }
		16 { return 'MEDUSA' }
		17 { return 'DON MEDUSA' }
		else { return '' }
	}
}

fn draw_status_overlay(renderer &sdl.Renderer, game Game) {
	sdl.set_render_draw_blend_mode(renderer, .blend)
	sdl.set_render_draw_color(renderer, 0, 0, 0, 180)
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: 0, y: 0, w: win_w, h: win_h })

	col := if game.status == .level_clear { Color{ r: 100, g: 255, b: 120 } } else { Color{ r: 255, g: 80, b: 80 } }
	draw_text_centered(renderer, win_w / 2, win_h / 2 - 30, game.status_msg, 3, col)
	draw_text_centered(renderer, win_w / 2, win_h / 2 + 20, 'PRESS SPACE / ENTER TO CONTINUE', 2, Color{ r: 255, g: 255, b: 255 })
}

fn draw_victory_ending(renderer &sdl.Renderer, game Game, ticks u32) {
	sdl.set_render_draw_blend_mode(renderer, .blend)
	sdl.set_render_draw_color(renderer, 10, 12, 25, 235)
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: 0, y: 0, w: win_w, h: win_h })

	// Animated Victory Confetti Sparkles
	for i in 0 .. 40 {
		cx := (i * 37 + int(ticks / 10)) % win_w
		cy := (i * 29 + int(ticks / 15)) % win_h
		sdl.set_render_draw_color(renderer, u8((i * 45) % 255), u8((i * 75) % 255), u8((i * 125) % 255), 255)
		sdl.render_fill_rect(renderer, &sdl.Rect{ x: cx, y: cy, w: 4, h: 4 })
	}

	draw_text_centered(renderer, win_w / 2, 90, 'VICTORY! PRINCESS LALA IS RESCUED!', 3, Color{ r: 255, g: 215, b: 0 })
	draw_text_centered(renderer, win_w / 2, 130, 'KING EGGER HAS BEEN BANISHED FROM THE REALM!', 2, Color{ r: 180, g: 220, b: 255 })

	// Draw Lolo and Princess Lala Side by Side with Heart
	draw_lolo(renderer, win_w / 2 - 60, 200, .right, ticks)
	draw_princess_lala(renderer, win_w / 2 + 20, 200, ticks)

	// Floating Giant Heart between them
	heart_y := 170 + int(math.sin(f64(ticks) / 160.0) * 8.0)
	draw_char(renderer, win_w / 2 - 8, heart_y, `*`, 3, Color{ r: 255, g: 80, b: 120 })

	// Stats Summary Card
	card_x := win_w / 2 - 200
	card_y := 280
	sdl.set_render_draw_color(renderer, 24, 30, 50, 255)
	card := sdl.Rect{ x: card_x, y: card_y, w: 400, h: 180 }
	sdl.render_fill_rect(renderer, &card)
	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	sdl.render_draw_rect(renderer, &card)

	draw_text_centered(renderer, win_w / 2, card_y + 20, 'HERO STATISTICS', 2, Color{ r: 255, g: 215, b: 0 })
	draw_text(renderer, card_x + 40, card_y + 60, 'FINAL SCORE: ${game.score}', 2, Color{ r: 255, g: 255, b: 255 })
	draw_text(renderer, card_x + 40, card_y + 90, 'TOTAL MOVES: ${game.moves_count}', 2, Color{ r: 140, g: 220, b: 255 })
	draw_text(renderer, card_x + 40, card_y + 120, 'ROOMS CLEARED: 20 / 20', 2, Color{ r: 100, g: 255, b: 120 })

	draw_text_centered(renderer, win_w / 2, 500, 'PRESS SPACE / ENTER TO PLAY AGAIN', 2, Color{ r: 255, g: 255, b: 255 })
}

fn draw_princess_lala(renderer &sdl.Renderer, x int, y int, ticks u32) {
	cx := x + cell_size / 2
	cy := y + cell_size / 2

	// Glossy Pink Lala Body
	sdl.set_render_draw_color(renderer, 245, 110, 180, 255)
	body := sdl.Rect{ x: x + 6, y: y + 6, w: cell_size - 12, h: cell_size - 12 }
	sdl.render_fill_rect(renderer, &body)

	// Crown / Bow with gentle bounce
	bow_y := y + 2 + int(math.sin(f64(ticks) / 180.0) * 2.0)
	sdl.set_render_draw_color(renderer, 255, 60, 120, 255)
	bow1 := sdl.Rect{ x: cx - 12, y: bow_y, w: 10, h: 8 }
	bow2 := sdl.Rect{ x: cx + 2, y: bow_y, w: 10, h: 8 }
	sdl.render_fill_rect(renderer, &bow1)
	sdl.render_fill_rect(renderer, &bow2)

	// Eyes with Eyelashes and Blinking
	is_blinking := (ticks / 2400) % 12 == 0
	if !is_blinking {
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		e1 := sdl.Rect{ x: cx - 8, y: cy - 6, w: 6, h: 8 }
		e2 := sdl.Rect{ x: cx + 2, y: cy - 6, w: 6, h: 8 }
		sdl.render_fill_rect(renderer, &e1)
		sdl.render_fill_rect(renderer, &e2)

		sdl.set_render_draw_color(renderer, 140, 20, 90, 255)
		p1 := sdl.Rect{ x: cx - 7, y: cy - 4, w: 3, h: 5 }
		p2 := sdl.Rect{ x: cx + 3, y: cy - 4, w: 3, h: 5 }
		sdl.render_fill_rect(renderer, &p1)
		sdl.render_fill_rect(renderer, &p2)
	}
}

fn draw_level_select_modal(renderer &sdl.Renderer, game Game, mx int, my int) {
	sdl.set_render_draw_blend_mode(renderer, .blend)
	sdl.set_render_draw_color(renderer, 0, 0, 0, 190)
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: 0, y: 0, w: win_w, h: win_h })

	modal_x := 100
	modal_y := 60
	modal_w := 760
	modal_h := 560

	sdl.set_render_draw_color(renderer, 22, 28, 42, 255)
	modal := sdl.Rect{ x: modal_x, y: modal_y, w: modal_w, h: modal_h }
	sdl.render_fill_rect(renderer, &modal)

	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	sdl.render_draw_rect(renderer, &modal)

	draw_text_centered(renderer, win_w / 2, modal_y + 20, 'CHAPTER SELECT - ALL 20 PUZZLE ROOMS', 2, Color{ r: 255, g: 215, b: 0 })
	draw_text_centered(renderer, win_w / 2, modal_y + 48, 'CLICK ANY ROOM TO WARP INSTANTLY [PRESS ESC / P TO CLOSE]', 1, Color{ r: 180, g: 220, b: 255 })

	for i in 0 .. game.campaign_levels.len {
		col := i / 5
		row := i % 5
		bx := modal_x + 30 + col * 175
		by := modal_y + 80 + row * 82

		is_hover := mx >= bx && mx <= bx + 165 && my >= by && my <= by + 72
		bg_c := if is_hover { Color{ r: 60, g: 90, b: 150 } } else { Color{ r: 35, g: 45, b: 70 } }

		sdl.set_render_draw_color(renderer, bg_c.r, bg_c.g, bg_c.b, 255)
		b_rect := sdl.Rect{ x: bx, y: by, w: 165, h: 72 }
		sdl.render_fill_rect(renderer, &b_rect)

		sdl.set_render_draw_color(renderer, 90, 120, 175, 255)
		sdl.render_draw_rect(renderer, &b_rect)

		lvl := game.campaign_levels[i]
		draw_text(renderer, bx + 8, by + 8, 'ROOM ${i + 1}', 2, Color{ r: 255, g: 215, b: 0 })
		draw_text(renderer, bx + 8, by + 30, 'F${lvl.floor}: ${lvl.name}', 1, Color{ r: 255, g: 255, b: 255 })
		draw_text(renderer, bx + 8, by + 48, 'PASS: ${lvl.password}', 1, Color{ r: 120, g: 230, b: 255 })
	}
}
