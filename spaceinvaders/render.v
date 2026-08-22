module main

import math
import sdl

// Pixel sprite patterns (8x8 or custom bitmap grids)
// 1 = solid pixel, 0 = transparent

// Squid Alien (8x8)
const squid_f0 = [
	0x18, 0x3C, 0x7E, 0xDB, 0xFF, 0x24, 0x5A, 0xA5
]
const squid_f1 = [
	0x18, 0x3C, 0x7E, 0xDB, 0xFF, 0x24, 0x42, 0x24
]

// Crab Alien (11x8 mapped to 12-wide)
const crab_f0 = [
	0x92, 0x49, 0xFE, 0x6D, 0x7F, 0x24, 0x42, 0x81
]
const crab_f1 = [
	0x92, 0x49, 0xFE, 0x6D, 0x7F, 0x24, 0x24, 0x42
]

// Octopus Alien (12x8)
const octopus_f0 = [
	0x3C, 0x7E, 0xFF, 0xDB, 0xFF, 0x3C, 0x66, 0xC3
]
const octopus_f1 = [
	0x3C, 0x7E, 0xFF, 0xDB, 0xFF, 0x3C, 0x5A, 0x81
]

pub fn draw_alien_sprite(renderer &sdl.Renderer, x int, y int, kind AlienType, frame int, color Color) {
	scale := 3

	pattern := match kind {
		.squid {
			if frame == 0 { squid_f0 } else { squid_f1 }
		}
		.crab {
			if frame == 0 { crab_f0 } else { crab_f1 }
		}
		.octopus {
			if frame == 0 { octopus_f0 } else { octopus_f1 }
		}
	}

	for row_idx in 0 .. 8 {
		row_bits := pattern[row_idx]
		for col_idx in 0 .. 8 {
			if (row_bits & (1 << u32(7 - col_idx))) != 0 {
				px := x + col_idx * scale + 4
				py := y + row_idx * scale

				// 16-Bit Dual-Tone Sprite Fill: Top highlight, Bottom base
				c := if row_idx <= 2 {
					Color{ r: u8(math.min(255, int(color.r) + 60)), g: u8(math.min(255, int(color.g) + 60)), b: u8(math.min(255, int(color.b) + 60)), a: 255 }
				} else {
					color
				}

				sdl.set_render_draw_color(renderer, c.r, c.g, c.b, c.a)
				rect := sdl.Rect{
					x: px
					y: py
					w: scale
					h: scale
				}
				sdl.render_fill_rect(renderer, &rect)
			}
		}
	}
}

pub fn draw_alien_explosion(renderer &sdl.Renderer, cx int, cy int, color Color) {
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	scale := 3
	lines := [
		[0, -4, 0, -2],
		[0, 2, 0, 4],
		[-4, 0, -2, 0],
		[2, 0, 4, 0],
		[-3, -3, -1, -1],
		[1, 1, 3, 3],
		[-3, 3, -1, 1],
		[1, -1, 3, -3],
	]
	for l in lines {
		rect := sdl.Rect{
			x: cx + l[0] * scale
			y: cy + l[1] * scale
			w: (l[2] - l[0] + 1) * scale
			h: (l[3] - l[1] + 1) * scale
		}
		sdl.render_fill_rect(renderer, &rect)
	}
}

pub fn draw_player_cannon(renderer &sdl.Renderer, x int, y int, w int, h int) {
	// 16-Bit Metallic Emerald Laser Cannon Base
	// Base Body
	sdl.set_render_draw_color(renderer, 25, 175, 55, 255)
	base_rect := sdl.Rect{ x: x, y: y + 10, w: w, h: h - 10 }
	sdl.render_fill_rect(renderer, &base_rect)

	// Top Highlight Line
	sdl.set_render_draw_color(renderer, 100, 255, 140, 255)
	sdl.render_draw_line(renderer, x, y + 10, x + w - 1, y + 10)

	// Middle Turret
	mid_w := w * 2 / 3
	sdl.set_render_draw_color(renderer, 45, 225, 75, 255)
	mid_rect := sdl.Rect{ x: x + (w - mid_w) / 2, y: y + 4, w: mid_w, h: 6 }
	sdl.render_fill_rect(renderer, &mid_rect)

	// Top Cannon Barrel with muzzle glow
	sdl.set_render_draw_color(renderer, 220, 255, 220, 255)
	gun_rect := sdl.Rect{ x: x + w / 2 - 2, y: y, w: 4, h: 5 }
	sdl.render_fill_rect(renderer, &gun_rect)
}

pub fn draw_ufo_saucer(renderer &sdl.Renderer, x int, y int) {
	// 16-Bit Mystery Flying Saucer
	// Saucer Glass Cockpit Dome (Glowing Cyan)
	sdl.set_render_draw_color(renderer, 120, 240, 255, 255)
	dome := sdl.Rect{ x: x + 16, y: y, w: 16, h: 6 }
	sdl.render_fill_rect(renderer, &dome)

	// Saucer Main Hull (Shaded Crimson Red)
	sdl.set_render_draw_color(renderer, 235, 30, 50, 255)
	hull := sdl.Rect{ x: x + 4, y: y + 6, w: 40, h: 8 }
	sdl.render_fill_rect(renderer, &hull)

	// Upper Hull Highlight
	sdl.set_render_draw_color(renderer, 255, 140, 150, 255)
	sdl.render_draw_line(renderer, x + 4, y + 6, x + 43, y + 6)

	// Saucer Lower Lip & Gold Thrusters
	sdl.set_render_draw_color(renderer, 255, 195, 20, 255)
	lip := sdl.Rect{ x: x + 10, y: y + 14, w: 28, h: 4 }
	sdl.render_fill_rect(renderer, &lip)

	// Blinking Warning Lights
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 8, y: y + 8, w: 4, h: 4 })
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 22, y: y + 8, w: 4, h: 4 })
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: x + 36, y: y + 8, w: 4, h: 4 })
}

pub fn render_space_invaders(renderer &sdl.Renderer, game &SpaceInvadersGame) {
	// Deep space dark background with twinkling starfield
	sdl.set_render_draw_color(renderer, 8, 10, 18, 255)
	sdl.render_clear(renderer)

	ticks := sdl.get_ticks()

	// 2-Layer Parallax Animated Starfield
	for star_i in 0 .. 60 {
		seed := (star_i * 1234567 + 98765) % 1000000
		base_x := seed % world_w
		base_y := (seed / world_w + int(f64(ticks) * (0.015 + f64(star_i % 3) * 0.015))) % (world_h - 50)
		twinkle := math.sin(f64(ticks) * 0.005 + f64(star_i)) * 0.5 + 0.5
		star_alpha := u8(80.0 + twinkle * 160.0)

		if star_i % 4 == 0 {
			// Bright cyan/blue star
			sdl.set_render_draw_color(renderer, 140, 220, 255, star_alpha)
			sdl.render_draw_point(renderer, base_x, base_y)
			sdl.render_draw_point(renderer, base_x + 1, base_y)
		} else {
			sdl.set_render_draw_color(renderer, 200, 210, 235, star_alpha)
			sdl.render_draw_point(renderer, base_x, base_y)
		}
	}

	// Top HUD
	draw_text(renderer, 40, 15, 'SCORE <1>', 2, Color{r: 255, g: 255, b: 255})
	draw_text(renderer, 40, 38, '${game.score:05d}', 2, Color{r: 80, g: 255, b: 120})

	draw_text(renderer, 320, 15, 'HI-SCORE', 2, Color{r: 255, g: 255, b: 255})
	draw_text(renderer, 330, 38, '${game.high_score:05d}', 2, Color{r: 255, g: 220, b: 80})

	draw_text(renderer, 620, 15, 'WAVE', 2, Color{r: 255, g: 255, b: 255})
	draw_text(renderer, 640, 38, '${game.wave:02d}', 2, Color{r: 80, g: 220, b: 255})

	// Top header separator line
	sdl.set_render_draw_color(renderer, 40, 45, 65, 255)
	sdl.render_draw_line(renderer, 20, 65, world_w - 20, 65)

	// UFO Flying Saucer
	if game.ufo.active {
		draw_ufo_saucer(renderer, int(game.ufo.x), int(game.ufo.y))
	} else if game.ufo.show_score {
		draw_text(renderer, int(game.ufo.x), int(game.ufo.y), '+${game.ufo.score_val}', 2, Color{r: 255, g: 50, b: 80})
	}

	// Render 55 Aliens
	alien_colors := [
		Color{r: 255, g: 70, b: 120},  // Squids: Magenta/Pink
		Color{r: 80, g: 220, b: 255},  // Crabs: Cyan
		Color{r: 255, g: 220, b: 60},  // Octopuses: Yellow
	]

	for r in 0 .. 5 {
		col_idx := if r == 0 { 0 } else if r <= 2 { 1 } else { 2 }
		for c in 0 .. 11 {
			al := game.aliens[r][c]
			if al.alive {
				draw_alien_sprite(renderer, int(al.x), int(al.y), al.kind, al.frame, alien_colors[col_idx])
			} else if al.exploding {
				draw_alien_explosion(renderer, int(al.x) + 16, int(al.y) + 14, Color{r: 255, g: 255, b: 255})
			}
		}
	}

	// Render Bunker Shields
	for s in game.shields {
		for row in 0 .. bunker_rows {
			for col in 0 .. bunker_cols {
				if s.grid[row][col] {
					b_rect := sdl.Rect{
						x: int(s.x) + col * bunker_block_sz
						y: int(s.y) + row * bunker_block_sz
						w: bunker_block_sz
						h: bunker_block_sz
					}
					// Gradient emerald armor blocks
					sdl.set_render_draw_color(renderer, 50, u8(200 + col % 3 * 15), 90, 255)
					sdl.render_fill_rect(renderer, &b_rect)
				}
			}
		}
	}

	// Render Bullets with glowing laser corona
	for b in game.bullets {
		if !b.alive {
			continue
		}
		if b.is_player {
			// Orange/Red laser core with outer glow
			sdl.set_render_draw_color(renderer, 255, 100, 30, 140)
			glow_rect := sdl.Rect{x: int(b.x) - 1, y: int(b.y) - 1, w: 5, h: 14}
			sdl.render_fill_rect(renderer, &glow_rect)

			sdl.set_render_draw_color(renderer, 255, 240, 160, 255)
			b_rect := sdl.Rect{x: int(b.x), y: int(b.y), w: 3, h: 12}
			sdl.render_fill_rect(renderer, &b_rect)
		} else {
			// Cyan zigzag alien projectile with photon aura
			sdl.set_render_draw_color(renderer, 40, 180, 255, 140)
			glow_rect := sdl.Rect{x: int(b.x) - 1, y: int(b.y) - 1, w: 5, h: 12}
			sdl.render_fill_rect(renderer, &glow_rect)

			sdl.set_render_draw_color(renderer, 200, 250, 255, 255)
			b_rect := sdl.Rect{x: int(b.x), y: int(b.y), w: 3, h: 10}
			sdl.render_fill_rect(renderer, &b_rect)
		}
	}

	// Render Player Cannon
	if game.player.alive {
		draw_player_cannon(renderer, int(game.player.x), int(game.player.y), int(game.player.w), int(game.player.h))
	} else if game.lives > 0 {
		// Player explosion animation
		draw_alien_explosion(renderer, int(game.player.x) + int(game.player.w / 2), int(game.player.y) + 12, Color{r: 255, g: 80, b: 40})
	}

	// Bottom Green Ground Line
	sdl.set_render_draw_color(renderer, 50, 240, 70, 255)
	sdl.render_draw_line(renderer, 20, world_h - 45, world_w - 20, world_h - 45)

	// Bottom Lives Display & Controls Prompt
	draw_text(renderer, 30, world_h - 35, '${game.lives}', 2, Color{r: 255, g: 255, b: 255})
	for i in 0 .. (game.lives - 1) {
		lx := 60 + i * 36
		draw_player_cannon(renderer, lx, world_h - 35, 26, 16)
	}

	draw_text_centered(renderer, world_w / 2 + 60, world_h - 32, '[A/D or ARROWS] MOVE  [SPACE] FIRE  [R] RESTART', 1, Color{r: 160, g: 180, b: 210})

	// Game Over / Wave Clear Overlays
	if game.state == .game_over {
		draw_text_centered(renderer, world_w / 2, world_h / 2 - 20, 'GAME OVER', 4, Color{r: 255, g: 50, b: 50})
		draw_text_centered(renderer, world_w / 2, world_h / 2 + 25, 'PRESS [R] OR [SPACE] TO RETRY', 2, Color{r: 255, g: 255, b: 255})
	} else if game.state == .wave_clear {
		draw_text_centered(renderer, world_w / 2, world_h / 2 - 20, 'WAVE CLEAR!', 4, Color{r: 80, g: 255, b: 120})
		draw_text_centered(renderer, world_w / 2, world_h / 2 + 25, 'GET READY FOR WAVE ${game.wave + 1}...', 2, Color{r: 255, g: 255, b: 255})
	}

	sdl.render_present(renderer)
}
