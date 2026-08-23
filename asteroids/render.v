module main

import math
import rand
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

fn draw_line(renderer &sdl.Renderer, x1 f64, y1 f64, x2 f64, y2 f64, color Color) {
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	sdl.render_draw_line(renderer, int(x1), int(y1), int(x2), int(y2))
}

fn draw_circle(renderer &sdl.Renderer, cx f64, cy f64, r f64, color Color) {
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	segments := 16
	for i in 0 .. segments {
		a1 := (f64(i) / f64(segments)) * 2.0 * math.pi
		a2 := (f64(i + 1) / f64(segments)) * 2.0 * math.pi
		x1 := cx + math.cos(a1) * r
		y1 := cy + math.sin(a1) * r
		x2 := cx + math.cos(a2) * r
		y2 := cy + math.sin(a2) * r
		sdl.render_draw_line(renderer, int(x1), int(y1), int(x2), int(y2))
	}
}

fn render_asteroids_game(renderer &sdl.Renderer, game &AsteroidsGame, particles []Particle) {
	// Clear background (Dark Space)
	sdl.set_render_draw_color(renderer, 10, 12, 22, 255)
	sdl.render_clear(renderer)

	// Stars background grid
	for i in 0 .. 40 {
		sx := (i * 137 + 50) % world_w
		sy := (i * 263 + 30) % world_h
		sdl.set_render_draw_color(renderer, 80, 100, 140, 180)
		sdl.render_draw_point(renderer, sx, sy)
	}

	// Render Power-ups
	for p in game.powerups {
		color := match p.kind {
			.spread_shot { Color{r: 255, g: 180, b: 0} }
			.shield { Color{r: 0, g: 200, b: 255} }
			.rapid_fire { Color{r: 255, g: 50, b: 100} }
			.emp_nuke { Color{r: 220, g: 100, b: 255} }
			.plasma_beam { Color{r: 0, g: 255, b: 150} }
			.extra_life { Color{r: 50, g: 255, b: 50} }
		}

		// Pulse ring
		pulse := 14.0 + math.sin(p.timer * 8.0) * 3.0
		draw_circle(renderer, p.x, p.y, pulse, color)

		label := match p.kind {
			.spread_shot { '3X' }
			.shield { 'SH' }
			.rapid_fire { 'RF' }
			.emp_nuke { 'EMP' }
			.plasma_beam { 'PB' }
			.extra_life { '+1' }
		}
		draw_text_centered(renderer, int(p.x), int(p.y) - 4, label, 1, color)
	}

	// Render Asteroids
	for ast in game.asteroids {
		color := match ast.size {
			.large { Color{r: 180, g: 200, b: 220} }
			.medium { Color{r: 150, g: 180, b: 210} }
			.small { Color{r: 120, g: 150, b: 190} }
		}
		count := ast.shape.len
		for i in 0 .. count {
			a1 := ast.rot + (f64(i) / f64(count)) * 2.0 * math.pi
			a2 := ast.rot + (f64(i + 1) / f64(count)) * 2.0 * math.pi
			r1 := ast.radius * ast.shape[i]
			r2 := ast.radius * ast.shape[(i + 1) % count]

			x1 := ast.x + math.cos(a1) * r1
			y1 := ast.y + math.sin(a1) * r1
			x2 := ast.x + math.cos(a2) * r2
			y2 := ast.y + math.sin(a2) * r2

			draw_line(renderer, x1, y1, x2, y2, color)
		}
	}

	// Render UFOs
	for ufo in game.ufos {
		color := if ufo.is_hunter { Color{r: 255, g: 60, b: 60} } else { Color{r: 255, g: 200, b: 0} }
		// Oval dome & saucer ring
		draw_line(renderer, ufo.x - 14, ufo.y, ufo.x + 14, ufo.y, color)
		draw_line(renderer, ufo.x - 14, ufo.y, ufo.x - 7, ufo.y + 6, color)
		draw_line(renderer, ufo.x + 14, ufo.y, ufo.x + 7, ufo.y + 6, color)
		draw_line(renderer, ufo.x - 7, ufo.y + 6, ufo.x + 7, ufo.y + 6, color)

		draw_line(renderer, ufo.x - 8, ufo.y, ufo.x - 4, ufo.y - 6, color)
		draw_line(renderer, ufo.x + 8, ufo.y, ufo.x + 4, ufo.y - 6, color)
		draw_line(renderer, ufo.x - 4, ufo.y - 6, ufo.x + 4, ufo.y - 6, color)
	}

	// Render Bullets
	for b in game.bullets {
		if b.is_plasma {
			// Thick glowing green plasma line
			dx := math.cos(math.atan2(b.dy, b.dx)) * 12.0
			dy := math.sin(math.atan2(b.dy, b.dx)) * 12.0
			draw_line(renderer, b.x - dx, b.y - dy, b.x + dx, b.y + dy, Color{
				r: 0
				g: 255
				b: 160
			})
			draw_circle(renderer, b.x, b.y, 4.0, Color{r: 200, g: 255, b: 220})
		} else if b.is_ufo {
			draw_circle(renderer, b.x, b.y, 3.0, Color{r: 255, g: 80, b: 80})
		} else {
			// Cyan player laser pulse
			dx := math.cos(math.atan2(b.dy, b.dx)) * 6.0
			dy := math.sin(math.atan2(b.dy, b.dx)) * 6.0
			draw_line(renderer, b.x - dx, b.y - dy, b.x + dx, b.y + dy, Color{
				r: 0
				g: 240
				b: 255
			})
		}
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

	// Render Ship (if alive & invulnerability flickering)
	if !game.game_over && (game.ship.invuln_timer <= 0.0 || int(game.ship.invuln_timer * 10.0) % 2 == 0) {
		ship_color := if game.ship.has_powerup {
			match game.ship.active_powerup {
				.spread_shot { Color{r: 255, g: 200, b: 0} }
				.rapid_fire { Color{r: 255, g: 80, b: 120} }
				.plasma_beam { Color{r: 0, g: 255, b: 180} }
				else { Color{r: 0, g: 255, b: 255} }
			}
		} else {
			Color{r: 0, g: 255, b: 255}
		}

		// Vector ship points
		nose_x := game.ship.x + math.cos(game.ship.angle) * 16.0
		nose_y := game.ship.y + math.sin(game.ship.angle) * 16.0

		left_x := game.ship.x + math.cos(game.ship.angle + 2.5) * 14.0
		left_y := game.ship.y + math.sin(game.ship.angle + 2.5) * 14.0

		right_x := game.ship.x + math.cos(game.ship.angle - 2.5) * 14.0
		right_y := game.ship.y + math.sin(game.ship.angle - 2.5) * 14.0

		back_x := game.ship.x - math.cos(game.ship.angle) * 6.0
		back_y := game.ship.y - math.sin(game.ship.angle) * 6.0

		draw_line(renderer, nose_x, nose_y, left_x, left_y, ship_color)
		draw_line(renderer, left_x, left_y, back_x, back_y, ship_color)
		draw_line(renderer, back_x, back_y, right_x, right_y, ship_color)
		draw_line(renderer, right_x, right_y, nose_x, nose_y, ship_color)

		// Thruster flame when moving
		if game.ship.thrusting {
			flame_x := game.ship.x - math.cos(game.ship.angle) * (14.0 + (rand.f64() * 6.0))
			flame_y := game.ship.y - math.sin(game.ship.angle) * (14.0 + (rand.f64() * 6.0))
			draw_line(renderer, left_x, left_y, flame_x, flame_y, Color{
				r: 255
				g: 140
				b: 0
			})
			draw_line(renderer, flame_x, flame_y, right_x, right_y, Color{
				r: 255
				g: 140
				b: 0
			})
		}

		// Shield forcefield
		if game.ship.shield_active {
			shield_col := Color{r: 0, g: 180, b: 255, a: 220}
			draw_circle(renderer, game.ship.x, game.ship.y, 22.0, shield_col)
		}
	}

	// HUD overlay
	draw_text(renderer, 20, 20, 'SCORE: ${game.score}', 2, Color{r: 255, g: 255, b: 255})
	draw_text(renderer, 20, 45, 'WAVE:  ${game.wave}', 2, Color{r: 0, g: 220, b: 255})

	// Lives as small ship icons
	for i in 0 .. game.lives {
		lx := 700.0 + f64(i * 20)
		ly := 30.0
		draw_line(renderer, lx, ly - 8, lx - 6, ly + 6, Color{r: 0, g: 255, b: 255})
		draw_line(renderer, lx - 6, ly + 6, lx, ly + 2, Color{r: 0, g: 255, b: 255})
		draw_line(renderer, lx, ly + 2, lx + 6, ly + 6, Color{r: 0, g: 255, b: 255})
		draw_line(renderer, lx + 6, ly + 6, lx, ly - 8, Color{r: 0, g: 255, b: 255})
	}

	// Active Power-up indicator
	if game.ship.has_powerup {
		name := match game.ship.active_powerup {
			.spread_shot { 'TRIPLE SPREAD' }
			.rapid_fire { 'RAPID FIRE' }
			.plasma_beam { 'PLASMA BEAM' }
			else { '' }
		}
		rem := int(game.ship.powerup_timer) + 1
		draw_text_centered(renderer, world_w / 2, 20, '${name} [${rem}s]', 2, Color{
			r: 255
			g: 220
			b: 0
		})
	}

	// Game Over screen
	if game.game_over {
		draw_text_centered(renderer, world_w / 2, 220, 'GAME OVER', 4, Color{
			r: 255
			g: 50
			b: 50
		})
		draw_text_centered(renderer, world_w / 2, 280, 'FINAL SCORE: ${game.score}', 2,
			Color{r: 255, g: 255, b: 255})
		draw_text_centered(renderer, world_w / 2, 320, 'PRESS [R] TO RESTART  [F11] Fullscreen', 2, Color{
			r: 0,
			g: 255,
			b: 200
		})
	}
}
