module main

import math
import rand
import sdl

const win_width = 880
const win_height = 820

const cell_px = 32
const matrix_start_x = (win_width - (grid_cols * cell_px)) / 2
const matrix_start_y = 120

struct App {
mut:
	window      &sdl.Window   = unsafe { nil }
	renderer    &sdl.Renderer = unsafe { nil }
	game        TetrisGame
	sound_mgr   SoundManager
	particles   []Particle
	last_drop_t u32
	mouse_x     int
	mouse_y     int
	btn_restart Button
	btn_pause   Button
	btn_sound   Button
}

fn new_app() App {
	mut app := App{
		game:        new_tetris_game()
		sound_mgr:   new_sound_manager()
		btn_restart: Button{
			x:            100
			y:            760
			w:            200
			h:            44
			text:         'RESET [R]'
			bg_color:     Color{
				r: 35
				g: 45
				b: 70
			}
			hover_color:  Color{
				r: 55
				g: 70
				b: 105
			}
			text_color:   Color{
				r: 255
				g: 255
				b: 255
			}
			border_color: Color{
				r: 85
				g: 105
				b: 150
			}
		}
		btn_pause:   Button{
			x:            340
			y:            760
			w:            200
			h:            44
			text:         'PAUSE [P]'
			bg_color:     Color{
				r: 35
				g: 45
				b: 70
			}
			hover_color:  Color{
				r: 55
				g: 70
				b: 105
			}
			text_color:   Color{
				r: 255
				g: 255
				b: 255
			}
			border_color: Color{
				r: 85
				g: 105
				b: 150
			}
		}
		btn_sound:   Button{
			x:            580
			y:            760
			w:            200
			h:            44
			text:         'SOUND: ON [S]'
			bg_color:     Color{
				r: 35
				g: 45
				b: 70
			}
			hover_color:  Color{
				r: 55
				g: 70
				b: 105
			}
			text_color:   Color{
				r: 80
				g: 240
				b: 140
			}
			border_color: Color{
				r: 85
				g: 105
				b: 150
			}
		}
	}
	return app
}

fn (mut app App) init_sdl() bool {
	if sdl.init(sdl.init_video | sdl.init_audio) < 0 {
		eprintln('Failed to initialize SDL')
		return false
	}

	app.window = sdl.create_window(c'Modern Tetris - V & SDL2', sdl.windowpos_centered,
		sdl.windowpos_centered, win_width, win_height, u32(sdl.WindowFlags.shown))

	if app.window == unsafe { nil } {
		eprintln('Failed to create SDL Window')
		return false
	}

	app.renderer = sdl.create_renderer(app.window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if app.renderer == unsafe { nil } {
		eprintln('Failed to create SDL Renderer')
		return false
	}

	return true
}

fn (mut app App) get_gravity_delay() u32 {
	level := u32(app.game.level)
	if level >= 15 {
		return 80
	}
	return 700 - (level - 1) * 45
}

fn (mut app App) spawn_line_particles(cleared_lines int) {
	for _ in 0 .. cleared_lines * 15 {
		angle := rand.f64() * math.pi * 2.0
		speed := 2.0 + rand.f64() * 6.0
		cx := f64(matrix_start_x + (grid_cols * cell_px) / 2)
		cy := f64(matrix_start_y + grid_rows * cell_px - 50)
		app.particles << Particle{
			x:     cx
			y:     cy
			vx:    math.cos(angle) * speed
			vy:    math.sin(angle) * speed
			life:  1.0
			color: Color{
				r: 255
				g: 220
				b: 40
			}
			size:  3 + rand.intn(3) or { 3 }
		}
	}
}

fn (mut app App) update_particles() {
	for i := app.particles.len - 1; i >= 0; i-- {
		app.particles[i].x += app.particles[i].vx
		app.particles[i].y += app.particles[i].vy
		app.particles[i].life -= 0.03
		if app.particles[i].life <= 0 {
			app.particles.delete(i)
		}
	}
}

fn (mut app App) update_game_step() {
	now := sdl.get_ticks()
	delay := app.get_gravity_delay()
	if now - app.last_drop_t >= delay {
		app.last_drop_t = now

		locked := app.game.step_down()
		if locked {
			app.sound_mgr.play_drop_sound()
			if app.game.game_over {
				app.sound_mgr.play_tetris_sound()
			}
		}
	}
}

fn (mut app App) toggle_sound() {
	is_on := app.sound_mgr.toggle_sound()
	app.btn_sound.text = if is_on { 'SOUND: ON [S]' } else { 'SOUND: OFF [S]' }
	app.btn_sound.text_color = if is_on {
		Color{
			r: 80
			g: 240
			b: 140
		}
	} else {
		Color{
			r: 240
			g: 90
			b: 90
		}
	}
	if is_on {
		app.sound_mgr.play_click_sound()
	}
}

fn (mut app App) toggle_pause() {
	app.sound_mgr.play_click_sound()
	app.game.is_paused = !app.game.is_paused
	app.btn_pause.text = if app.game.is_paused { 'RESUME [P]' } else { 'PAUSE [P]' }
}

fn (mut app App) reset_game() {
	app.sound_mgr.play_click_sound()
	app.game.reset()
	app.particles.clear()
}

fn (mut app App) handle_mouse_click(x int, y int) {
	if app.btn_restart.is_hovered(x, y) {
		app.reset_game()
		return
	}
	if app.btn_pause.is_hovered(x, y) {
		app.toggle_pause()
		return
	}
	if app.btn_sound.is_hovered(x, y) {
		app.toggle_sound()
		return
	}
}

fn (mut app App) render() {
	sdl.set_render_draw_color(app.renderer, 15, 18, 30, 255)
	sdl.render_clear(app.renderer)

	// Top Title Header
	draw_text_centered(app.renderer, win_width / 2, 14, 'MODERN TETRIS', 3, Color{
		r: 255
		g: 255
		b: 255
	})

	// Glassmorphic Score Cards Header Row
	draw_glass_card(app.renderer, 40, 50, 240, 44, Color{ r: 40, g: 220, b: 240 })
	draw_text_centered(app.renderer, 160, 64, 'SCORE: ${app.game.score}', 2, Color{
		r: 100
		g: 240
		b: 255
	})

	draw_glass_card(app.renderer, win_width - 280, 50, 240, 44, Color{ r: 245, g: 215, b: 40 })
	draw_text_centered(app.renderer, win_width - 160, 64, 'LEVEL: ${app.game.level}',
		2, Color{ r: 255, g: 235, b: 120 })

	// Status Badge
	mut status_text := 'PLAYING'
	mut status_color := Color{
		r: 80
		g: 240
		b: 140
	}
	mut badge_border := Color{
		r: 50
		g: 200
		b: 120
	}

	if app.game.game_over {
		status_text = 'GAME OVER! PRESS [R]'
		status_color = Color{
			r: 255
			g: 80
			b: 90
		}
		badge_border = Color{
			r: 235
			g: 45
			b: 60
		}
	} else if app.game.is_paused {
		status_text = 'PAUSED'
		status_color = Color{
			r: 255
			g: 220
			b: 60
		}
		badge_border = Color{
			r: 255
			g: 200
			b: 25
		}
	}

	draw_glass_card(app.renderer, win_width / 2 - 170, 50, 340, 44, badge_border)
	draw_text_centered(app.renderer, win_width / 2, 64, status_text, 2, status_color)

	// Left Box: HOLD PIECE Card
	draw_glass_card(app.renderer, 40, 120, 200, 180, Color{ r: 90, g: 110, b: 160 })
	draw_text_centered(app.renderer, 140, 134, 'HOLD [C]', 2, Color{ r: 200, g: 215, b: 240 })
	if app.game.has_hold && app.game.hold_piece.kind > 0 {
		h_size := app.game.hold_piece.matrix.len
		ox := 140 - (h_size * 22) / 2
		oy := 200 - (h_size * 22) / 2
		for r in 0 .. h_size {
			for c in 0 .. h_size {
				k := app.game.hold_piece.matrix[r][c]
				if k != 0 {
					draw_block(app.renderer, ox + c * 22, oy + r * 22, 20, k, false)
				}
			}
		}
	}

	// Right Box: NEXT PIECE Card
	draw_glass_card(app.renderer, win_width - 240, 120, 200, 180, Color{ r: 90, g: 110, b: 160 })
	draw_text_centered(app.renderer, win_width - 140, 134, 'NEXT', 2, Color{ r: 200, g: 215, b: 240 })
	if app.game.next_piece.kind > 0 {
		n_size := app.game.next_piece.matrix.len
		ox := win_width - 140 - (n_size * 22) / 2
		oy := 200 - (n_size * 22) / 2
		for r in 0 .. n_size {
			for c in 0 .. n_size {
				k := app.game.next_piece.matrix[r][c]
				if k != 0 {
					draw_block(app.renderer, ox + c * 22, oy + r * 22, 20, k, false)
				}
			}
		}
	}

	// Stats Panel Card below Hold Box
	draw_glass_card(app.renderer, 40, 320, 200, 160, Color{ r: 90, g: 110, b: 160 })
	draw_text_centered(app.renderer, 140, 336, 'STATS', 2, Color{ r: 200, g: 215, b: 240 })
	draw_text(app.renderer, 55, 380, 'LINES: ${app.game.lines}', 2, Color{ r: 255, g: 255, b: 255 })

	// Main 10x20 Matrix Grid Fill & Frame
	matrix_rect := sdl.Rect{
		x: matrix_start_x
		y: matrix_start_y
		w: grid_cols * cell_px
		h: grid_rows * cell_px
	}
	sdl.set_render_draw_color(app.renderer, 20, 26, 42, 255)
	sdl.render_fill_rect(app.renderer, &matrix_rect)

	// Outer Matrix Border
	sdl.set_render_draw_color(app.renderer, 45, 60, 95, 255)
	sdl.render_draw_rect(app.renderer, &matrix_rect)

	// Subtle Grid Background Lines
	sdl.set_render_draw_color(app.renderer, 25, 33, 54, 255)
	for c in 1 .. grid_cols {
		gx := matrix_start_x + c * cell_px
		sdl.render_draw_line(app.renderer, gx, matrix_start_y, gx, matrix_start_y +
			grid_rows * cell_px)
	}
	for r in 1 .. grid_rows {
		gy := matrix_start_y + r * cell_px
		sdl.render_draw_line(app.renderer, matrix_start_x, gy, matrix_start_x + grid_cols * cell_px,
			gy)
	}

	// Draw Locked Grid Blocks
	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			k := app.game.grid[r][c]
			if k != 0 {
				draw_block(app.renderer, matrix_start_x + c * cell_px, matrix_start_y + r * cell_px,
					cell_px, k, false)
			}
		}
	}

	// Draw Ghost Piece Projection
	if !app.game.game_over && !app.game.is_paused {
		ghost_y := app.game.get_ghost_y()
		p := app.game.curr_piece
		size := p.matrix.len
		for r in 0 .. size {
			for c in 0 .. size {
				k := p.matrix[r][c]
				if k != 0 {
					bx := matrix_start_x + (p.x + c) * cell_px
					by := matrix_start_y + (ghost_y + r) * cell_px
					draw_block(app.renderer, bx, by, cell_px, k, true)
				}
			}
		}

		// Draw Active Falling Piece
		for r in 0 .. size {
			for c in 0 .. size {
				k := p.matrix[r][c]
				if k != 0 {
					bx := matrix_start_x + (p.x + c) * cell_px
					by := matrix_start_y + (p.y + r) * cell_px
					draw_block(app.renderer, bx, by, cell_px, k, false)
				}
			}
		}
	}

	// Render Particles
	for p in app.particles {
		draw_filled_circle(app.renderer, int(p.x), int(p.y), p.size, Color{
			r: p.color.r
			g: p.color.g
			b: p.color.b
			a: u8(p.life * 255.0)
		})
	}

	// Draw Control Buttons
	app.btn_restart.draw(app.renderer, app.mouse_x, app.mouse_y)
	app.btn_pause.draw(app.renderer, app.mouse_x, app.mouse_y)
	app.btn_sound.draw(app.renderer, app.mouse_x, app.mouse_y)

	sdl.render_present(app.renderer)
}

fn (mut app App) run() {
	mut should_close := false
	app.last_drop_t = sdl.get_ticks()

	for !should_close {
		evt := sdl.Event{}
		for 0 < sdl.poll_event(&evt) {
			match evt.@type {
				.quit {
					should_close = true
				}
				.mousebuttondown {
					if evt.button.button == u8(sdl.button_left) {
						app.handle_mouse_click(evt.button.x, evt.button.y)
					}
				}
				.mousemotion {
					app.mouse_x = evt.motion.x
					app.mouse_y = evt.motion.y
				}
				.keydown {
					sym := evt.key.keysym.sym
					if sym == int(sdl.KeyCode.r) {
						app.reset_game()
					} else if sym == int(sdl.KeyCode.p) {
						app.toggle_pause()
					} else if sym == int(sdl.KeyCode.s) {
						app.toggle_sound()
					} else if sym == int(sdl.KeyCode.c) {
						if app.game.hold() {
							app.sound_mgr.play_move_sound()
						}
					} else if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						if app.game.move_left() {
							app.sound_mgr.play_move_sound()
						}
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						if app.game.move_right() {
							app.sound_mgr.play_move_sound()
						}
					} else if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w)
						|| sym == int(sdl.KeyCode.z) {
						if app.game.rotate() {
							app.sound_mgr.play_rotate_sound()
						}
					} else if sym == int(sdl.KeyCode.down) {
						if !app.game.check_collision(app.game.curr_piece, 0, 1) {
							app.game.curr_piece.y++
							app.sound_mgr.play_move_sound()
						}
					} else if sym == int(sdl.KeyCode.space) {
						drop_dist := app.game.hard_drop()
						if drop_dist > 0 {
							app.sound_mgr.play_drop_sound()
						}
					} else if sym == int(sdl.KeyCode.escape) {
						should_close = true
					}
				}
				else {}
			}
		}

		app.update_game_step()
		app.update_particles()
		app.render()
		sdl.delay(16) // ~60 FPS loop
	}
}

fn (mut app App) cleanup() {
	app.sound_mgr.cleanup()
	if app.renderer != unsafe { nil } {
		sdl.destroy_renderer(app.renderer)
	}
	if app.window != unsafe { nil } {
		sdl.destroy_window(app.window)
	}
	sdl.quit()
}

fn main() {
	mut app := new_app()
	if !app.init_sdl() {
		return
	}
	defer {
		app.cleanup()
	}
	app.run()
}
