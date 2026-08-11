module main

import sdl

struct Particle {
pub mut:
	x        f64
	y        f64
	dx       f64
	dy       f64
	life     f64
	max_life f64
	color    Color
}

struct Button {
	x            int
	y            int
	w            int
	h            int
	bg_color     Color
	hover_color  Color
	text_color   Color
	border_color Color
mut:
	text string
}

fn (b Button) contains(x int, y int) bool {
	return x >= b.x && x <= b.x + b.w && y >= b.y && y <= b.y + b.h
}

fn (b Button) render(renderer &sdl.Renderer, mouse_x int, mouse_y int) {
	is_hover := b.contains(mouse_x, mouse_y)
	color := if is_hover { b.hover_color } else { b.bg_color }

	rect := sdl.Rect{
		x: b.x
		y: b.y
		w: b.w
		h: b.h
	}
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	sdl.render_fill_rect(renderer, &rect)

	sdl.set_render_draw_color(renderer, b.border_color.r, b.border_color.g, b.border_color.b, b.border_color.a)
	sdl.render_draw_rect(renderer, &rect)

	text_x := b.x + (b.w - b.text.len * 8 * 2) / 2
	text_y := b.y + (b.h - 16) / 2
	draw_text(renderer, text_x, text_y, b.text, 2, b.text_color)
}

fn draw_rect_filled(renderer &sdl.Renderer, x int, y int, w int, h int, color Color) {
	rect := sdl.Rect{
		x: x
		y: y
		w: w
		h: h
	}
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	sdl.render_fill_rect(renderer, &rect)
}

fn draw_rect_outline(renderer &sdl.Renderer, x int, y int, w int, h int, color Color) {
	rect := sdl.Rect{
		x: x
		y: y
		w: w
		h: h
	}
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	sdl.render_draw_rect(renderer, &rect)
}

fn draw_circle_filled(renderer &sdl.Renderer, cx f64, cy f64, r f64, color Color) {
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	ir := int(r)
	for dy in -ir .. ir + 1 {
		for dx in -ir .. ir + 1 {
			if dx * dx + dy * dy <= ir * ir {
				sdl.render_draw_point(renderer, int(cx) + dx, int(cy) + dy)
			}
		}
	}
}

fn render_breakout_game(renderer &sdl.Renderer, game &BreakoutGame, particles []Particle) {
	// Dark grid arcade background
	sdl.set_render_draw_color(renderer, 14, 16, 28, 255)
	sdl.render_clear(renderer)

	// Top banner border line
	sdl.set_render_draw_color(renderer, 40, 55, 90, 255)
	sdl.render_draw_line(renderer, 0, 40, world_w, 40)

	// Bottom Shield line
	if game.bottom_shield_active {
		sdl.set_render_draw_color(renderer, 0, 220, 255, 255)
		sdl.render_draw_line(renderer, 0, world_h - 6, world_w, world_h - 6)
		sdl.render_draw_line(renderer, 0, world_h - 5, world_w, world_h - 5)
	}

	// Render Bricks
	for b in game.bricks {
		if !b.alive {
			continue
		}

		// Base brick fill
		draw_rect_filled(renderer, b.x, b.y, b.w, b.h, b.color)

		// Bevel highlight top/left
		draw_rect_filled(renderer, b.x, b.y, b.w, 2, Color{r: 255, g: 255, b: 255, a: 120})
		draw_rect_filled(renderer, b.x, b.y, 2, b.h, Color{r: 255, g: 255, b: 255, a: 120})

		// Bevel shadow bottom/right
		draw_rect_filled(renderer, b.x, b.y + b.h - 2, b.w, 2, Color{r: 0, g: 0, b: 0, a: 100})
		draw_rect_filled(renderer, b.x + b.w - 2, b.y, 2, b.h, Color{r: 0, g: 0, b: 0, a: 100})

		// Kind overlay labels / cracks
		if b.kind == .tnt {
			draw_text_centered(renderer, b.x + b.w / 2, b.y + 4, 'TNT', 1, Color{
				r: 255
				g: 255
				b: 255
			})
		} else if b.kind == .steel {
			draw_rect_outline(renderer, b.x + 3, b.y + 3, b.w - 6, b.h - 6, Color{
				r: 220
				g: 220
				b: 240
			})
		} else if b.kind == .mystery {
			draw_text_centered(renderer, b.x + b.w / 2, b.y + 4, '?', 1, Color{
				r: 0
				g: 0
				b: 0
			})
		}

		// Cracks for multi-hp bricks
		if b.max_hp > 1 && b.hp < b.max_hp {
			sdl.set_render_draw_color(renderer, 30, 30, 30, 200)
			sdl.render_draw_line(renderer, b.x + 4, b.y + 4, b.x + b.w - 6, b.y + b.h - 4)
		}
	}

	// Render Power-up Capsules
	for cap in game.capsules {
		color := match cap.kind {
			.multiball { Color{r: 255, g: 200, b: 0} }
			.expand_paddle { Color{r: 0, g: 255, b: 120} }
			.laser_paddle { Color{r: 255, g: 50, b: 80} }
			.sticky_paddle { Color{r: 200, g: 100, b: 255} }
			.fireball { Color{r: 255, g: 120, b: 0} }
			.slow_ball { Color{r: 0, g: 200, b: 255} }
			.bottom_shield { Color{r: 0, g: 255, b: 255} }
			.extra_life { Color{r: 50, g: 255, b: 50} }
		}

		draw_rect_filled(renderer, int(cap.x), int(cap.y), cap.w, cap.h, color)
		draw_rect_outline(renderer, int(cap.x), int(cap.y), cap.w, cap.h, Color{
			r: 255
			g: 255
			b: 255
		})

		lbl := match cap.kind {
			.multiball { '3X' }
			.expand_paddle { 'EXP' }
			.laser_paddle { 'LAS' }
			.sticky_paddle { 'STK' }
			.fireball { 'FIR' }
			.slow_ball { 'SLO' }
			.bottom_shield { 'SH' }
			.extra_life { '+1' }
		}
		draw_text_centered(renderer, int(cap.x) + cap.w / 2, int(cap.y) + 3, lbl, 1, Color{
			r: 0
			g: 0
			b: 0
		})
	}

	// Render Lasers
	for laser in game.lasers {
		draw_rect_filled(renderer, int(laser.x) - 2, int(laser.y), 4, 12, Color{
			r: 255
			g: 40
			b: 80
		})
	}

	// Render Particles
	for part in particles {
		alpha := u8(255.0 * (part.life / part.max_life))
		color := Color{
			r: part.color.r
			g: part.color.g
			b: part.color.b
			a: alpha
		}
		sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
		sdl.render_draw_point(renderer, int(part.x), int(part.y))
	}

	// Render Paddle
	paddle_color := if game.paddle.fireball_timer > 0.0 {
		Color{r: 255, g: 140, b: 0}
	} else if game.paddle.has_lasers {
		Color{r: 255, g: 60, b: 100}
	} else if game.paddle.has_sticky {
		Color{r: 200, g: 100, b: 255}
	} else {
		Color{r: 0, g: 220, b: 255}
	}

	draw_rect_filled(renderer, int(game.paddle.x), int(game.paddle.y), int(game.paddle.w),
		int(game.paddle.h), paddle_color)
	draw_rect_outline(renderer, int(game.paddle.x), int(game.paddle.y), int(game.paddle.w),
		int(game.paddle.h), Color{r: 255, g: 255, b: 255})

	// Side Laser guns on paddle
	if game.paddle.has_lasers {
		draw_rect_filled(renderer, int(game.paddle.x) + 4, int(game.paddle.y) - 6, 6, 6,
			Color{r: 255, g: 40, b: 40})
		draw_rect_filled(renderer, int(game.paddle.x + game.paddle.w) - 10, int(game.paddle.y) - 6,
			6, 6, Color{r: 255, g: 40, b: 40})
	}

	// Render Balls
	is_fireball := game.paddle.fireball_timer > 0.0
	ball_color := if is_fireball { Color{r: 255, g: 100, b: 0} } else { Color{r: 255, g: 255, b: 255} }

	for ball in game.balls {
		draw_circle_filled(renderer, ball.x, ball.y, ball.radius, ball_color)
	}

	// HUD Top Banner
	draw_text(renderer, 20, 12, 'SCORE: ${game.score}', 2, Color{r: 255, g: 255, b: 255})
	draw_text(renderer, 320, 12, 'LEVEL: ${game.level}', 2, Color{r: 0, g: 255, b: 200})

	// Lives as small red hearts/rectangles
	for i in 0 .. game.lives {
		draw_rect_filled(renderer, 700 + i * 18, 14, 12, 12, Color{r: 255, g: 60, b: 80})
	}

	// Level Cleared Banner
	if game.level_cleared {
		draw_text_centered(renderer, world_w / 2, 240, 'LEVEL CLEARED!', 4, Color{
			r: 0
			g: 255
			b: 150
		})
		draw_text_centered(renderer, world_w / 2, 300, 'PRESS [SPACE] FOR NEXT LEVEL', 2,
			Color{r: 255, g: 255, b: 255})
	}

	// Game Over Banner
	if game.game_over {
		draw_text_centered(renderer, world_w / 2, 220, 'GAME OVER', 4, Color{
			r: 255
			g: 60
			b: 60
		})
		draw_text_centered(renderer, world_w / 2, 280, 'FINAL SCORE: ${game.score}', 2,
			Color{r: 255, g: 255, b: 255})
		draw_text_centered(renderer, world_w / 2, 320, 'PRESS [R] TO RESTART', 2, Color{
			r: 0
			g: 255
			b: 200
		})
	}
}
