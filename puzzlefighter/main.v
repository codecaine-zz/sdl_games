module main

import math
import os
import rand
import sdl

const win_width = 960
const win_height = 840

const cell_size = 40
const p1_board_x = 70
const p2_board_x = 580
const board_y = 110

const grid_w = pf_cols * cell_size
const grid_h = pf_rows * cell_size

struct PfParticle {
mut:
	x     f64
	y     f64
	vx    f64
	vy    f64
	life  f64
	max_l f64
	color Color
	size  int
}

struct FloatText {
mut:
	x     f64
	y     f64
	text  string
	life  f64
	max_l f64
	scale int
	color Color
}

struct App {
mut:
	window      &sdl.Window   = unsafe { nil }
	renderer    &sdl.Renderer = unsafe { nil }
	sound_mgr   SoundManager
	p1          PlayerBoard
	p2          PlayerBoard
	particles   []PfParticle
	float_texts []FloatText
	shake_timer f64
	paused      bool
	btn_reset   Button
	btn_sound   Button
	btn_pause   Button
}

fn new_app() App {
	btn_y := 770
	return App{
		sound_mgr: new_sound_manager()
		p1:        new_player_board(false)
		p2:        new_player_board(true)
		btn_reset: Button{
			x: 70, y: btn_y, w: 160, h: 42, text: 'RESET [R]',
			bg_color: Color{r: 48, g: 25, b: 35},
			hover_color: Color{r: 85, g: 40, b: 55},
			text_color: Color{r: 255, g: 255, b: 255},
			border_color: Color{r: 180, g: 75, b: 90},
		}
		btn_sound: Button{
			x: 250, y: btn_y, w: 160, h: 42, text: 'SOUND [M]',
			bg_color: Color{r: 25, g: 38, b: 55},
			hover_color: Color{r: 45, g: 68, b: 98},
			text_color: Color{r: 255, g: 255, b: 255},
			border_color: Color{r: 75, g: 125, b: 180},
		}
		btn_pause: Button{
			x: 430, y: btn_y, w: 160, h: 42, text: 'PAUSE [P]',
			bg_color: Color{r: 45, g: 42, b: 25},
			hover_color: Color{r: 78, g: 72, b: 40},
			text_color: Color{r: 255, g: 255, b: 255},
			border_color: Color{r: 165, g: 155, b: 70},
		}
	}
}

fn get_pf_color(color_id int) (Color, Color, Color) {
	match color_id {
		1 { // Red (Ruby)
			return Color{r: 235, g: 35, b: 50}, Color{r: 255, g: 135, b: 145}, Color{r: 130, g: 10, b: 20}
		}
		2 { // Blue (Sapphire)
			return Color{r: 30, g: 135, b: 245}, Color{r: 120, g: 200, b: 255}, Color{r: 15, g: 65, b: 160}
		}
		3 { // Green (Emerald)
			return Color{r: 35, g: 215, b: 75}, Color{r: 130, g: 255, b: 155}, Color{r: 15, g: 120, b: 35}
		}
		4 { // Yellow (Topaz)
			return Color{r: 250, g: 215, b: 30}, Color{r: 255, g: 245, b: 135}, Color{r: 155, g: 130, b: 15}
		}
		else {
			return Color{r: 110, g: 110, b: 120}, Color{r: 165, g: 165, b: 175}, Color{r: 60, g: 60, b: 70}
		}
	}
}

// Draw a Puzzle Fighter Gem with Normals, Crash Orb Pulsing Rings, or Counter Timers
fn draw_pf_gem(renderer &sdl.Renderer, cx int, cy int, size int, cell GemCell, ticks u32) {
	if cell.color == 0 {
		return
	}
	r := size / 2 - 2
	main_c, high_c, shadow_c := get_pf_color(cell.color)

	match cell.nature {
		.crash_orb {
			// Swirling Glowing Spherical Energy Orb with pulsating corona
			t := f64(ticks) * 0.01
			pulse := u8((math.sin(t * 3.0) * 0.5 + 0.5) * 60.0)

			// Corona Rings
			for ring in 0 .. 3 {
				c_rect := sdl.Rect{x: cx - r - ring, y: cy - r - ring, w: (r + ring) * 2, h: (r + ring) * 2}
				sdl.set_render_draw_color(renderer, main_c.r, main_c.g, main_c.b, u8(180 - ring * 45))
				sdl.render_draw_rect(renderer, &c_rect)
			}

			// Orb Core
			orb := sdl.Rect{x: cx - r + 2, y: cy - r + 2, w: (r - 2) * 2, h: (r - 2) * 2}
			sdl.set_render_draw_color(renderer, main_c.r, main_c.g, main_c.b, 255)
			sdl.render_fill_rect(renderer, &orb)

			// Inner White Hot Star
			sdl.set_render_draw_color(renderer, 255, 255, 255, 200 + pulse)
			sdl.render_draw_line(renderer, cx - 4, cy, cx + 4, cy)
			sdl.render_draw_line(renderer, cx, cy - 4, cx, cy + 4)
			sdl.render_draw_point(renderer, cx, cy)
		}
		.counter {
			// Solid Darkened Shell with Countdown Number
			rect := sdl.Rect{x: cx - r + 1, y: cy - r + 1, w: (r - 1) * 2, h: (r - 1) * 2}
			sdl.set_render_draw_color(renderer, main_c.r / 2, main_c.g / 2, main_c.b / 2, 255)
			sdl.render_fill_rect(renderer, &rect)

			sdl.set_render_draw_color(renderer, 60, 60, 70, 255)
			sdl.render_draw_rect(renderer, &rect)

			// Embedded Timer Digit (White)
			digit_str := '${cell.timer}'
			draw_text_centered(renderer, cx, cy - 7, digit_str, 2, Color{r: 255, g: 255, b: 255})
		}
		.normal, .diamond {
			rect := sdl.Rect{x: cx - r + 1, y: cy - r + 1, w: (r - 1) * 2, h: (r - 1) * 2}
			sdl.set_render_draw_color(renderer, main_c.r, main_c.g, main_c.b, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Top & Left Highlight
			sdl.set_render_draw_color(renderer, high_c.r, high_c.g, high_c.b, 255)
			for i in 0 .. 3 {
				sdl.render_draw_line(renderer, cx - r + 1 + i, cy - r + 1 + i, cx + r - 1 - i, cy - r + 1 + i)
				sdl.render_draw_line(renderer, cx - r + 1 + i, cy - r + 1 + i, cx - r + 1 + i, cy + r - 1 - i)
			}

			// Bottom & Right Shadow
			sdl.set_render_draw_color(renderer, shadow_c.r, shadow_c.g, shadow_c.b, 255)
			for i in 0 .. 3 {
				sdl.render_draw_line(renderer, cx - r + 1 + i, cy + r - 1 - i, cx + r - 1 - i, cy + r - 1 - i)
				sdl.render_draw_line(renderer, cx + r - 1 - i, cy - r + 1 + i, cx + r - 1 - i, cy + r - 1 - i)
			}

			// Table Facet Center
			center_sq := sdl.Rect{x: cx - r / 2, y: cy - r / 2, w: r, h: r}
			sdl.set_render_draw_color(renderer, main_c.r, main_c.g, main_c.b, 255)
			sdl.render_fill_rect(renderer, &center_sq)

			// Power Gem cross shimmer
			if cell.power_id > 0 {
				sdl.set_render_draw_color(renderer, 255, 255, 255, 180)
				sdl.render_draw_point(renderer, cx - r / 3, cy - r / 3)
			}

			// Border
			sdl.set_render_draw_color(renderer, 15, 15, 22, 255)
			sdl.render_draw_rect(renderer, &rect)
		}
	}
}

fn (mut app App) spawn_burst(cx int, cy int, color_id int) {
	main_c, _, _ := get_pf_color(color_id)
	for _ in 0 .. 16 {
		ang := rand.f64_in_range(0.0, 2.0 * math.pi) or { 0.0 }
		spd := rand.f64_in_range(90.0, 310.0) or { 160.0 }
		life := rand.f64_in_range(0.35, 0.7) or { 0.5 }
		app.particles << PfParticle{
			x:     f64(cx)
			y:     f64(cy)
			vx:    math.cos(ang) * spd
			vy:    math.sin(ang) * spd
			life:  life
			max_l: life
			color: main_c
			size:  rand.int_in_range(3, 6) or { 4 }
		}
	}
}

fn (mut app App) update(dt f64) {
	if app.paused {
		return
	}

	if app.shake_timer > 0 {
		app.shake_timer -= dt
	}

	prev_p1_chain := app.p1.chain_count
	prev_p2_chain := app.p2.chain_count

	p1_garbage := app.p1.update(dt)
	p2_garbage := app.p2.update(dt)

	if p1_garbage > 0 {
		app.p2.receive_garbage(p1_garbage)
	}
	if p2_garbage > 0 {
		app.p1.receive_garbage(p2_garbage)
	}

	// Sound & FX trigger on Combos
	if app.p1.chain_count > prev_p1_chain && app.p1.chain_count > 0 {
		app.sound_mgr.play_crash_sound(app.p1.chain_count)
		app.shake_timer = 0.22
		app.float_texts << FloatText{
			x:     f64(p1_board_x + grid_w / 2)
			y:     f64(board_y + grid_h / 2 - 20)
			text:  'CHAIN x${app.p1.chain_count}!'
			life:  1.1
			max_l: 1.1
			scale: 3
			color: Color{r: 255, g: 230, b: 60}
		}
	}
	if app.p2.chain_count > prev_p2_chain && app.p2.chain_count > 0 {
		app.sound_mgr.play_crash_sound(app.p2.chain_count)
		app.float_texts << FloatText{
			x:     f64(p2_board_x + grid_w / 2)
			y:     f64(board_y + grid_h / 2 - 20)
			text:  'CHAIN x${app.p2.chain_count}!'
			life:  1.1
			max_l: 1.1
			scale: 3
			color: Color{r: 255, g: 90, b: 110}
		}
	}

	// Update Particles
	mut active_particles := []PfParticle{}
	for mut p in app.particles {
		p.x += p.vx * dt
		p.y += p.vy * dt
		p.vy += 380.0 * dt
		p.vx *= 0.985
		p.life -= dt
		if p.life > 0 {
			active_particles << p
		}
	}
	app.particles = active_particles

	// Update Floating Texts
	mut active_texts := []FloatText{}
	for mut ft in app.float_texts {
		ft.y -= 35.0 * dt
		ft.life -= dt
		if ft.life > 0 {
			active_texts << ft
		}
	}
	app.float_texts = active_texts
}

// Render a Single Player Board
fn render_player_board(renderer &sdl.Renderer, bx int, by int, board &PlayerBoard, ticks u32, is_p1 bool) {
	// Frame
	frame := sdl.Rect{x: bx - 8, y: by - 8, w: grid_w + 16, h: grid_h + 16}
	sdl.set_render_draw_color(renderer, 32, 28, 48, 255)
	sdl.render_fill_rect(renderer, &frame)
	frame_c := if is_p1 { Color{r: 80, g: 150, b: 240} } else { Color{r: 240, g: 80, b: 100} }
	sdl.set_render_draw_color(renderer, frame_c.r, frame_c.g, frame_c.b, 255)
	sdl.render_draw_rect(renderer, &frame)

	// Inner Board Background
	bg := sdl.Rect{x: bx, y: by, w: grid_w, h: grid_h}
	sdl.set_render_draw_color(renderer, 10, 8, 18, 255)
	sdl.render_fill_rect(renderer, &bg)

	// Grid Lines
	sdl.set_render_draw_color(renderer, 24, 20, 36, 255)
	for r in 0 .. pf_rows + 1 {
		sdl.render_draw_line(renderer, bx, by + r * cell_size, bx + grid_w, by + r * cell_size)
	}
	for c in 0 .. pf_cols + 1 {
		sdl.render_draw_line(renderer, bx + c * cell_size, by, bx + c * cell_size, by + grid_h)
	}

	// Render Settled Gems
	for r in 0 .. pf_rows {
		for c in 0 .. pf_cols {
			cell := board.grid[r][c]
			if cell.color != 0 {
				cx := bx + c * cell_size + cell_size / 2
				cy := by + r * cell_size + cell_size / 2
				draw_pf_gem(renderer, cx, cy, cell_size, cell, ticks)
			}
		}
	}

	// Render Active Falling Pair
	if board.state == .falling {
		// Main Gem
		if board.pair.r1 >= 0 && board.pair.r1 < f64(pf_rows) {
			cx := bx + board.pair.c1 * cell_size + cell_size / 2
			cy := by + int(board.pair.r1 * f64(cell_size)) + cell_size / 2
			draw_pf_gem(renderer, cx, cy, cell_size, GemCell{color: board.pair.color1, nature: board.pair.nat1}, ticks)
		}
		// Sub Gem
		if board.pair.r2 >= 0 && board.pair.r2 < f64(pf_rows) && board.pair.c2 >= 0 && board.pair.c2 < pf_cols {
			cx := bx + board.pair.c2 * cell_size + cell_size / 2
			cy := by + int(board.pair.r2 * f64(cell_size)) + cell_size / 2
			draw_pf_gem(renderer, cx, cy, cell_size, GemCell{color: board.pair.color2, nature: board.pair.nat2}, ticks)
		}
	}

	// Header Label
	p_title := if is_p1 { '1P RYU (YOU)' } else { '2P CPU (MORRIGAN)' }
	draw_text_centered(renderer, bx + grid_w / 2, by - 36, p_title, 2, frame_c)

	// Bottom Score
	draw_text_centered(renderer, bx + grid_w / 2, by + grid_h + 12, 'SCORE: ${board.score}', 2, Color{r: 255, g: 235, b: 120})
}

fn (mut app App) render() {
	renderer := app.renderer
	ticks := sdl.get_ticks()

	// Capcom Arcade Midnight Arena
	sdl.set_render_draw_color(renderer, 14, 10, 22, 255)
	sdl.render_clear(renderer)

	// Screen Shake Offset
	mut sx := 0
	mut sy := 0
	if app.shake_timer > 0 {
		mag := app.shake_timer * 16.0
		sx = int((rand.f64() * 2.0 - 1.0) * mag)
		sy = int((rand.f64() * 2.0 - 1.0) * mag)
	}

	// Title Banner
	draw_text_centered_fitted(renderer, win_width / 2 + sx, 20 + sy, 'SUPER PUZZLE FIGHTER II TURBO', 3, win_width - 60, Color{r: 255, g: 195, b: 40})
	draw_text_centered_fitted(renderer, win_width / 2 + sx, 56 + sy, 'DETONATE CRASH ORBS & BUILD GIANT POWER GEMS!', 2, win_width - 60, Color{r: 170, g: 215, b: 255})

	// Render P1 and P2 Boards
	render_player_board(renderer, p1_board_x + sx, board_y + sy, &app.p1, ticks, true)
	render_player_board(renderer, p2_board_x + sx, board_y + sy, &app.p2, ticks, false)

	// Center Arena HUD: Next Queue, Super Meter & VS Emblem
	center_x := win_width / 2 + sx
	draw_text_centered(renderer, center_x, board_y + 10, 'VS', 4, Color{r: 255, g: 60, b: 75})

	// Next Pair Preview Box (P1)
	draw_text_centered(renderer, center_x, board_y + 70, 'NEXT', 2, Color{r: 190, g: 200, b: 230})
	nbox := sdl.Rect{x: center_x - cell_size / 2 - 4, y: board_y + 95, w: cell_size + 8, h: cell_size * 2 + 8}
	sdl.set_render_draw_color(renderer, 24, 20, 36, 255)
	sdl.render_fill_rect(renderer, &nbox)
	sdl.set_render_draw_color(renderer, 85, 75, 120, 255)
	sdl.render_draw_rect(renderer, &nbox)

	draw_pf_gem(renderer, center_x, board_y + 100 + cell_size / 2, cell_size, GemCell{color: app.p1.next_pair.color1, nature: app.p1.next_pair.nat1}, ticks)
	draw_pf_gem(renderer, center_x, board_y + 100 + cell_size + cell_size / 2, cell_size, GemCell{color: app.p1.next_pair.color2, nature: app.p1.next_pair.nat2}, ticks)

	// Super Combo Meter
	meter_w := 140
	meter_h := 18
	m_rect := sdl.Rect{x: center_x - meter_w / 2, y: board_y + 220, w: meter_w, h: meter_h}
	sdl.set_render_draw_color(renderer, 20, 20, 30, 255)
	sdl.render_fill_rect(renderer, &m_rect)

	t_anim := (ticks / 300) % 2
	if t_anim == 0 {
		sdl.set_render_draw_color(renderer, 255, 180, 40, 255)
	} else {
		sdl.set_render_draw_color(renderer, 255, 230, 80, 255)
	}
	meter_fill := sdl.Rect{x: m_rect.x + 2, y: m_rect.y + 2, w: meter_w - 4, h: meter_h - 4}
	sdl.render_fill_rect(renderer, &meter_fill)
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	sdl.render_draw_rect(renderer, &m_rect)
	draw_text_centered(renderer, center_x, board_y + 244, 'SUPER COMBO', 1, Color{r: 255, g: 255, b: 255})

	// Controls Panel in Center Bottom
	draw_text_centered(renderer, center_x, board_y + 320, '1P CONTROLS', 2, Color{r: 255, g: 215, b: 90})
	draw_text_centered(renderer, center_x, board_y + 346, 'A/D: MOVE', 1, Color{r: 190, g: 200, b: 230})
	draw_text_centered(renderer, center_x, board_y + 366, 'W/UP: ROTATE', 1, Color{r: 190, g: 200, b: 230})
	draw_text_centered(renderer, center_x, board_y + 386, 'S/DOWN: DROP', 1, Color{r: 190, g: 200, b: 230})
	draw_text_centered(renderer, center_x, board_y + 406, 'SPACE: HARD DROP', 1, Color{r: 190, g: 200, b: 230})

	// Render Particles
	for p in app.particles {
		prect := sdl.Rect{x: int(p.x), y: int(p.y), w: p.size, h: p.size}
		alpha := u8((p.life / p.max_l) * 255.0)
		sdl.set_render_draw_color(renderer, p.color.r, p.color.g, p.color.b, alpha)
		sdl.render_fill_rect(renderer, &prect)
	}

	// Render Floating Texts
	for ft in app.float_texts {
		draw_text_centered(renderer, int(ft.x), int(ft.y), ft.text, ft.scale, ft.color)
	}

	// Buttons
	mut mx := 0
	mut my := 0
	sdl.get_mouse_state(&mx, &my)
	app.btn_reset.render(renderer, mx, my)
	app.btn_sound.render(renderer, mx, my)
	app.btn_pause.render(renderer, mx, my)

	// Overlays
	if app.p1.state == .game_over || app.p2.state == .game_over {
		box := sdl.Rect{x: win_width / 2 - 200, y: win_height / 2 - 60, w: 400, h: 120}
		sdl.set_render_draw_color(renderer, 25, 15, 25, 245)
		sdl.render_fill_rect(renderer, &box)
		sdl.set_render_draw_color(renderer, 255, 190, 40, 255)
		sdl.render_draw_rect(renderer, &box)
		winner_text := if app.p2.state == .game_over { 'YOU WIN! K.O.!' } else { 'CPU WINS! K.O.!' }
		win_c := if app.p2.state == .game_over { Color{r: 80, g: 255, b: 120} } else { Color{r: 255, g: 80, b: 90} }
		draw_text_centered(renderer, win_width / 2, win_height / 2 - 35, winner_text, 3, win_c)
		draw_text_centered(renderer, win_width / 2, win_height / 2 + 15, 'PRESS [R] TO REMATCH', 2, Color{r: 255, g: 255, b: 255})
	} else if app.paused {
		box := sdl.Rect{x: win_width / 2 - 160, y: win_height / 2 - 50, w: 320, h: 100}
		sdl.set_render_draw_color(renderer, 20, 25, 40, 245)
		sdl.render_fill_rect(renderer, &box)
		draw_text_centered(renderer, win_width / 2, win_height / 2 - 25, 'PAUSED', 3, Color{r: 255, g: 220, b: 80})
		draw_text_centered(renderer, win_width / 2, win_height / 2 + 15, 'PRESS [P] TO RESUME', 2, Color{r: 200, g: 220, b: 255})
	}

	sdl.render_present(renderer)
}

fn main() {
	if sdl.init(sdl.init_video | sdl.init_audio) != 0 {
		eprintln('Failed to init SDL')
		return
	}
	defer {
		sdl.quit()
	}

	mut app := new_app()

	if os.args.contains('--snapshot') {
		surface := sdl.create_rgb_surface(0, win_width, win_height, 32, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)
		s_renderer := sdl.create_software_renderer(surface)
		app.renderer = s_renderer
		app.p1.score = 8400
		app.p2.score = 5600
		app.p1.grid[11][0] = GemCell{color: 1, nature: .normal}
		app.p1.grid[11][1] = GemCell{color: 1, nature: .normal}
		app.p1.grid[10][0] = GemCell{color: 1, nature: .normal}
		app.p1.grid[10][1] = GemCell{color: 1, nature: .crash_orb}
		app.p2.grid[11][4] = GemCell{color: 2, nature: .counter, timer: 3}
		app.render()
		sdl.save_bmp(surface, 'screenshots/puzzlefighter.bmp'.str)
		sdl.destroy_renderer(s_renderer)
		sdl.free_surface(surface)
		return
	}

	window := sdl.create_window(
		'SUPER PUZZLE FIGHTER II TURBO // Arcade Gem Battler'.str,
		sdl.windowpos_centered,
		sdl.windowpos_centered,
		win_width,
		win_height,
		u32(sdl.WindowFlags.shown) | u32(sdl.WindowFlags.fullscreen_desktop) | u32(sdl.WindowFlags.resizable),
	)
	if window == unsafe { nil } {
		eprintln('Failed to create window')
		return
	}
	defer {
		sdl.destroy_window(window)
	}

	renderer := sdl.create_renderer(window, -1, u32(u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync)))
	if renderer == unsafe { nil } {
		eprintln('Failed to create renderer')
		return
	}
	defer {
		sdl.destroy_renderer(renderer)
	}
	sdl.render_set_logical_size(renderer, win_width, win_height)

	app.window = window
	app.renderer = renderer

	mut last_ticks := sdl.get_ticks()

	for {
		current_ticks := sdl.get_ticks()
		dt := f64(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks

		mut event := sdl.Event{}
		for sdl.poll_event(&event) != 0 {
			match event.@type {
				.quit {
					return
				}
				.mousebuttondown {
					mx := event.button.x
					my := event.button.y
					if app.btn_reset.is_hovered(mx, my) {
						app.p1 = new_player_board(false)
						app.p2 = new_player_board(true)
					} else if app.btn_sound.is_hovered(mx, my) {
						app.sound_mgr.toggle_sound()
					} else if app.btn_pause.is_hovered(mx, my) {
						app.paused = !app.paused
					}
				}
				.keydown {
					sym := int(event.key.keysym.sym)
					if sym == int(sdl.KeyCode.f11) {
						toggle_fullscreen(window)
					} else if sym == int(sdl.KeyCode.escape) {
						return
					} else if sym == int(sdl.KeyCode.r) {
						app.p1 = new_player_board(false)
						app.p2 = new_player_board(true)
					} else if sym == int(sdl.KeyCode.p) {
						app.paused = !app.paused
					} else if sym == int(sdl.KeyCode.m) {
						app.sound_mgr.toggle_sound()
					} else if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						if app.p1.move_pair(-1) {
							app.sound_mgr.play_move_sound()
						}
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						if app.p1.move_pair(1) {
							app.sound_mgr.play_move_sound()
						}
					} else if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) {
						app.p1.rotate(1)
						app.sound_mgr.play_rotate_sound()
					} else if sym == int(sdl.KeyCode.down) || sym == int(sdl.KeyCode.s) {
						if app.p1.state == .falling {
							app.p1.pair.r1 += 0.8
						}
					} else if sym == int(sdl.KeyCode.space) {
						app.p1.hard_drop()
					}
				}
				else {}
			}
		}

		app.update(dt)
		app.render()
		sdl.delay(16)
	}
}

fn toggle_fullscreen(window &sdl.Window) {
	flags := sdl.get_window_flags(window)
	if (flags & u32(sdl.WindowFlags.fullscreen_desktop)) != 0 || (flags & u32(sdl.WindowFlags.fullscreen)) != 0 {
		sdl.set_window_fullscreen(window, 0)
	} else {
		sdl.set_window_fullscreen(window, u32(sdl.WindowFlags.fullscreen_desktop))
	}
}
