module main

import math
import os
import rand
import sdl

const win_width = 1000
const win_height = 840

const cell_size = 64
const grid_w = 8 * cell_size
const grid_h = 8 * cell_size
const board_x = 60
const board_y = 150

enum GameMode {
	classic
	time_attack
	zen
}

struct GemParticle {
mut:
	x     f64
	y     f64
	vx    f64
	vy    f64
	life  f64
	color Color
	size  int
}

struct FloatText {
mut:
	x     f64
	y     f64
	text  string
	life  f64
	color Color
}

struct LaserBeam {
mut:
	r1    int
	c1    int
	r2    int
	c2    int
	life  f64
	color Color
}

struct HyperZap {
mut:
	fx    f64
	fy    f64
	tx    f64
	ty    f64
	life  f64
	color Color
}

struct SwapAnim {
mut:
	r1       int
	c1       int
	r2       int
	c2       int
	progress f64
	revert   bool
	active   bool
}

struct App {
mut:
	window         &sdl.Window   = unsafe { nil }
	renderer       &sdl.Renderer = unsafe { nil }
	sound_mgr      SoundManager
	grid           Grid
	mode           GameMode = .classic
	score          int
	high_score     int
	level          int = 1
	level_progress int
	time_left      f64 = 60.0
	combo          int
	selected_r     int = -1
	selected_c     int = -1
	cursor_r       int = 3
	cursor_c       int = 3
	hover_r        int = -1
	hover_c        int = -1
	swap_anim      SwapAnim
	falling        bool
	particles      []GemParticle
	float_texts    []FloatText
	laser_beams    []LaserBeam
	hyper_zaps     []HyperZap
	undo_grid      Grid
	has_undo       bool
	hint_p1        Point = Point{r: -1, c: -1}
	hint_p2        Point = Point{r: -1, c: -1}
	show_hint      bool
	hint_timer     f64
	shake_timer    f64
	game_over      bool
	btn_reset      Button
	btn_hint       Button
	btn_mode       Button
	btn_sound      Button
}

fn new_app() App {
	btn_y := 765

	return App{
		sound_mgr: new_sound_manager()
		grid:      new_grid()
		btn_reset: Button{
			x: 64, y: btn_y, w: 200, h: 42, text: 'RESET [R]',
			bg_color: Color{r: 35, g: 40, b: 60},
			hover_color: Color{r: 55, g: 65, b: 95},
			text_color: Color{r: 255, g: 255, b: 255},
			border_color: Color{r: 80, g: 95, b: 140},
		}
		btn_hint:  Button{
			x: 288, y: btn_y, w: 200, h: 42, text: 'HINT [H]',
			bg_color: Color{r: 35, g: 60, b: 50},
			hover_color: Color{r: 55, g: 90, b: 75},
			text_color: Color{r: 255, g: 255, b: 255},
			border_color: Color{r: 80, g: 135, b: 110},
		}
		btn_mode:  Button{
			x: 512, y: btn_y, w: 200, h: 42, text: 'CLASSIC [M]',
			bg_color: Color{r: 50, g: 40, b: 75},
			hover_color: Color{r: 75, g: 60, b: 115},
			text_color: Color{r: 255, g: 255, b: 255},
			border_color: Color{r: 110, g: 90, b: 165},
		}
		btn_sound: Button{
			x: 736, y: btn_y, w: 200, h: 42, text: 'SOUND: ON [S]',
			bg_color: Color{r: 35, g: 50, b: 70},
			hover_color: Color{r: 55, g: 80, b: 110},
			text_color: Color{r: 255, g: 255, b: 255},
			border_color: Color{r: 80, g: 115, b: 160},
		}
	}
}

fn get_gem_color(kind int) Color {
	return match kind {
		1 { Color{r: 245, g: 50, b: 60} }   // Ruby (Red)
		2 { Color{r: 50, g: 120, b: 255} }  // Sapphire (Blue)
		3 { Color{r: 50, g: 225, b: 100} }  // Emerald (Green)
		4 { Color{r: 255, g: 215, b: 40} }  // Topaz (Yellow)
		5 { Color{r: 180, g: 70, b: 245} }  // Amethyst (Purple)
		6 { Color{r: 240, g: 245, b: 255} } // Diamond (White)
		7 { Color{r: 255, g: 140, b: 35} }  // Amber (Orange)
		else { Color{r: 100, g: 100, b: 100} }
	}
}

fn (mut app App) trigger_swap(r1 int, c1 int, r2 int, c2 int) {
	if app.swap_anim.active || app.falling || app.game_over {
		return
	}
	app.show_hint = false
	app.hint_timer = 0.0
	app.undo_grid = app.grid
	app.has_undo = true

	app.swap_anim = SwapAnim{
		r1:       r1
		c1:       c1
		r2:       r2
		c2:       c2
		progress: 0.0
		revert:   false
		active:   true
	}
	app.sound_mgr.play_swap_sound()
}

fn (mut app App) handle_gem_click(r int, c int) {
	if app.swap_anim.active || app.falling || app.game_over {
		return
	}
	app.cursor_r = r
	app.cursor_c = c

	if app.selected_r == -1 {
		app.selected_r = r
		app.selected_c = c
		app.sound_mgr.play_select_sound()
	} else if app.selected_r == r && app.selected_c == c {
		app.selected_r = -1
		app.selected_c = -1
	} else if is_adjacent(app.selected_r, app.selected_c, r, c) {
		app.trigger_swap(app.selected_r, app.selected_c, r, c)
		app.selected_r = -1
		app.selected_c = -1
	} else {
		app.selected_r = r
		app.selected_c = c
		app.sound_mgr.play_select_sound()
	}
}

fn (mut app App) move_cursor(dr int, dc int) {
	nr := app.cursor_r + dr
	nc := app.cursor_c + dc
	if nr >= 0 && nr < grid_size {
		app.cursor_r = nr
	}
	if nc >= 0 && nc < grid_size {
		app.cursor_c = nc
	}
}

fn (mut app App) handle_cursor_action() {
	app.handle_gem_click(app.cursor_r, app.cursor_c)
}

fn (mut app App) spawn_match_particles(r int, c int, color Color) {
	cx := f64(board_x + c * cell_size + cell_size / 2)
	cy := f64(board_y + r * cell_size + cell_size / 2)

	for _ in 0 .. 16 {
		angle := rand.f64() * 2.0 * math.pi
		spd := 60.0 + rand.f64() * 180.0
		app.particles << GemParticle{
			x:     cx
			y:     cy
			vx:    math.cos(angle) * spd
			vy:    math.sin(angle) * spd
			life:  0.8
			color: color
			size:  2 + rand.int_in_range(1, 4) or { 2 }
		}
	}
}

fn (mut app App) spawn_flame_blast(r int, c int) {
	app.sound_mgr.play_flame_explosion_sound()
	app.shake_timer = 0.25

	for dr := -1; dr <= 1; dr++ {
		for dc := -1; dc <= 1; dc++ {
			nr := r + dr
			nc := c + dc
			if nr >= 0 && nr < grid_size && nc >= 0 && nc < grid_size {
				col := if app.grid.cells[nr][nc].kind > 0 { get_gem_color(app.grid.cells[nr][nc].kind) } else { Color{r: 255, g: 150, b: 30} }
				app.spawn_match_particles(nr, nc, col)
				app.grid.cells[nr][nc].kind = 0
				app.grid.cells[nr][nc].special = .none
			}
		}
	}
	pts := 500 * app.level
	app.score += pts
	if app.mode == .time_attack {
		app.time_left = math.min(99.0, app.time_left + 2.0)
	}
	app.float_texts << FloatText{
		x: f64(board_x + c * cell_size)
		y: f64(board_y + r * cell_size)
		text: 'FLAME BLAST! +${pts}'
		life: 1.2
		color: Color{r: 255, g: 180, b: 40}
	}
}

fn (mut app App) spawn_star_laser(r int, c int) {
	app.sound_mgr.play_star_laser_sound()
	app.shake_timer = 0.35

	// Horizontal laser beam
	app.laser_beams << LaserBeam{
		r1: r, c1: 0, r2: r, c2: grid_size - 1, life: 0.45, color: Color{r: 80, g: 240, b: 255}
	}
	// Vertical laser beam
	app.laser_beams << LaserBeam{
		r1: 0, c1: c, r2: grid_size - 1, c2: c, life: 0.45, color: Color{r: 80, g: 240, b: 255}
	}

	for col_i in 0 .. grid_size {
		col := if app.grid.cells[r][col_i].kind > 0 { get_gem_color(app.grid.cells[r][col_i].kind) } else { Color{r: 80, g: 240, b: 255} }
		app.spawn_match_particles(r, col_i, col)
		app.grid.cells[r][col_i].kind = 0
		app.grid.cells[r][col_i].special = .none
	}
	for row_i in 0 .. grid_size {
		col := if app.grid.cells[row_i][c].kind > 0 { get_gem_color(app.grid.cells[row_i][c].kind) } else { Color{r: 80, g: 240, b: 255} }
		app.spawn_match_particles(row_i, c, col)
		app.grid.cells[row_i][c].kind = 0
		app.grid.cells[row_i][c].special = .none
	}

	pts := 1200 * app.level
	app.score += pts
	if app.mode == .time_attack {
		app.time_left = math.min(99.0, app.time_left + 4.0)
	}
	app.float_texts << FloatText{
		x: f64(board_x + c * cell_size)
		y: f64(board_y + r * cell_size)
		text: 'STAR LASER! +${pts}'
		life: 1.4
		color: Color{r: 100, g: 240, b: 255}
	}
}

fn (mut app App) spawn_supernova_blast(r int, c int) {
	app.sound_mgr.play_supernova_sound()
	app.shake_timer = 0.50

	// 3x3 blast
	for dr := -1; dr <= 1; dr++ {
		for dc := -1; dc <= 1; dc++ {
			nr := r + dr
			nc := c + dc
			if nr >= 0 && nr < grid_size && nc >= 0 && nc < grid_size {
				col := if app.grid.cells[nr][nc].kind > 0 { get_gem_color(app.grid.cells[nr][nc].kind) } else { Color{r: 255, g: 220, b: 60} }
				app.spawn_match_particles(nr, nc, col)
				app.grid.cells[nr][nc].kind = 0
				app.grid.cells[nr][nc].special = .none
			}
		}
	}

	// Full cross laser
	app.laser_beams << LaserBeam{
		r1: r, c1: 0, r2: r, c2: grid_size - 1, life: 0.60, color: Color{r: 255, g: 220, b: 80}
	}
	app.laser_beams << LaserBeam{
		r1: 0, c1: c, r2: grid_size - 1, c2: c, life: 0.60, color: Color{r: 255, g: 220, b: 80}
	}

	for col_i in 0 .. grid_size {
		col := if app.grid.cells[r][col_i].kind > 0 { get_gem_color(app.grid.cells[r][col_i].kind) } else { Color{r: 255, g: 220, b: 80} }
		app.spawn_match_particles(r, col_i, col)
		app.grid.cells[r][col_i].kind = 0
		app.grid.cells[r][col_i].special = .none
	}
	for row_i in 0 .. grid_size {
		col := if app.grid.cells[row_i][c].kind > 0 { get_gem_color(app.grid.cells[row_i][c].kind) } else { Color{r: 255, g: 220, b: 80} }
		app.spawn_match_particles(row_i, c, col)
		app.grid.cells[row_i][c].kind = 0
		app.grid.cells[row_i][c].special = .none
	}

	pts := 3000 * app.level
	app.score += pts
	if app.mode == .time_attack {
		app.time_left = math.min(99.0, app.time_left + 8.0)
	}
	app.float_texts << FloatText{
		x: f64(board_x + c * cell_size)
		y: f64(board_y + r * cell_size)
		text: 'SUPERNOVA! +${pts}'
		life: 1.6
		color: Color{r: 255, g: 235, b: 60}
	}
}

fn (mut app App) trigger_hypercube_zap(r1 int, c1 int, r2 int, c2 int) {
	app.sound_mgr.play_hypercube_zap_sound()
	app.shake_timer = 0.40

	g1 := app.grid.cells[r1][c1]
	g2 := app.grid.cells[r2][c2]

	// Double Hypercube Swap: Board-Clearing Cosmic Singularity!
	if g1.special == .hypercube && g2.special == .hypercube {
		for r in 0 .. grid_size {
			for c in 0 .. grid_size {
				col := if app.grid.cells[r][c].kind > 0 { get_gem_color(app.grid.cells[r][c].kind) } else { Color{r: 255, g: 255, b: 255} }
				app.spawn_match_particles(r, c, col)
				app.grid.cells[r][c].kind = 0
				app.grid.cells[r][c].special = .none
			}
		}
		pts := 10000 * app.level
		app.score += pts
		app.float_texts << FloatText{
			x: f64(board_x + 2 * cell_size)
			y: f64(board_y + 3 * cell_size)
			text: 'COSMIC SINGULARITY! +${pts}'
			life: 2.0
			color: Color{r: 255, g: 235, b: 80}
		}
		app.falling = true
		return
	}

	// Single Hypercube: Zap all gems of the target color
	target_kind := if g1.special == .hypercube { g2.kind } else { g1.kind }
	hc_r := if g1.special == .hypercube { r1 } else { r2 }
	hc_c := if g1.special == .hypercube { c1 } else { c2 }

	h_fx := f64(board_x + hc_c * cell_size + cell_size / 2)
	h_fy := f64(board_y + hc_r * cell_size + cell_size / 2)

	app.grid.cells[hc_r][hc_c].kind = 0
	app.grid.cells[hc_r][hc_c].special = .none

	mut zapped := 0
	for r in 0 .. grid_size {
		for c in 0 .. grid_size {
			if app.grid.cells[r][c].kind == target_kind {
				t_x := f64(board_x + c * cell_size + cell_size / 2)
				t_y := f64(board_y + r * cell_size + cell_size / 2)
				app.hyper_zaps << HyperZap{
					fx: h_fx, fy: h_fy, tx: t_x, ty: t_y, life: 0.50, color: get_gem_color(target_kind)
				}
				app.spawn_match_particles(r, c, get_gem_color(target_kind))
				app.grid.cells[r][c].kind = 0
				app.grid.cells[r][c].special = .none
				zapped++
			}
		}
	}

	pts := zapped * 200 * app.level
	app.score += pts
	if app.mode == .time_attack {
		app.time_left = math.min(99.0, app.time_left + f64(zapped))
	}
	app.float_texts << FloatText{
		x: h_fx - 40.0
		y: h_fy - 20.0
		text: 'HYPER ZAP! +${pts}'
		life: 1.5
		color: Color{r: 255, g: 240, b: 120}
	}
	app.falling = true
}

fn (mut app App) process_matches() bool {
	groups := app.grid.find_matches()
	if groups.len == 0 {
		return false
	}

	app.combo++
	app.sound_mgr.play_match_sound(app.combo)

	mut pts_to_clear := []Point{}
	mut special_triggers := []Point{}

	for group in groups {
		base_pts := group.points.len * 50 * app.combo * app.level
		app.score += base_pts
		app.level_progress += base_pts
		if app.score > app.high_score {
			app.high_score = app.score
		}

		if group.points.len > 0 {
			mid_pt := group.points[group.points.len / 2]
			fx := f64(board_x + mid_pt.c * cell_size + 10)
			fy := f64(board_y + mid_pt.r * cell_size)
			txt := if app.combo > 1 { '+${base_pts} x${app.combo}!' } else { '+${base_pts}' }
			app.float_texts << FloatText{
				x:     fx
				y:     fy
				text:  txt
				life:  1.0
				color: get_gem_color(group.kind)
			}
		}

		for pt in group.points {
			pts_to_clear << pt
			app.spawn_match_particles(pt.r, pt.c, get_gem_color(group.kind))

			// Check if already a special gem
			sp := app.grid.cells[pt.r][pt.c].special
			if sp != .none {
				special_triggers << pt
			}
		}

		// Generate new Special Gems
		spawn_pt := group.points[group.points.len / 2]
		if group.points.len == 4 {
			app.grid.cells[spawn_pt.r][spawn_pt.c].special = .flame
		} else if group.points.len == 5 {
			app.grid.cells[spawn_pt.r][spawn_pt.c].special = .hypercube
		} else if group.points.len >= 6 {
			app.grid.cells[spawn_pt.r][spawn_pt.c].special = .supernova
		}
	}

	// Clear matched standard gems
	for pt in pts_to_clear {
		if app.grid.cells[pt.r][pt.c].special == .none {
			app.grid.cells[pt.r][pt.c].kind = 0
		}
	}

	// Trigger special gem explosions
	for pt in special_triggers {
		sp := app.grid.cells[pt.r][pt.c].special
		if sp == .flame {
			app.spawn_flame_blast(pt.r, pt.c)
		} else if sp == .star {
			app.spawn_star_laser(pt.r, pt.c)
		} else if sp == .supernova {
			app.spawn_supernova_blast(pt.r, pt.c)
		}
	}

	// Level up check (Classic mode)
	if app.mode == .classic && app.level_progress >= app.level * 2500 {
		app.level++
		app.level_progress = 0
		app.sound_mgr.play_level_up_sound()
	}

	return true
}

fn (mut app App) update(dt f64) {
	if app.shake_timer > 0 {
		app.shake_timer -= dt
		if app.shake_timer < 0 {
			app.shake_timer = 0
		}
	}

	// Update particles
	for i := app.particles.len - 1; i >= 0; i-- {
		mut p := unsafe { &app.particles[i] }
		p.x += p.vx * dt
		p.y += p.vy * dt
		p.life -= dt * 1.5
		if p.life <= 0 {
			app.particles.delete(i)
		}
	}

	// Update floating score texts
	for i := app.float_texts.len - 1; i >= 0; i-- {
		mut ft := unsafe { &app.float_texts[i] }
		ft.y -= dt * 35.0
		ft.life -= dt * 1.2
		if ft.life <= 0 {
			app.float_texts.delete(i)
		}
	}

	// Update laser beams
	for i := app.laser_beams.len - 1; i >= 0; i-- {
		mut lb := unsafe { &app.laser_beams[i] }
		lb.life -= dt * 2.0
		if lb.life <= 0 {
			app.laser_beams.delete(i)
		}
	}

	// Update hyper zaps
	for i := app.hyper_zaps.len - 1; i >= 0; i-- {
		mut hz := unsafe { &app.hyper_zaps[i] }
		hz.life -= dt * 2.2
		if hz.life <= 0 {
			app.hyper_zaps.delete(i)
		}
	}

	// Time Attack countdown
	if app.mode == .time_attack && !app.game_over {
		app.time_left -= dt
		if app.time_left <= 0.0 {
			app.time_left = 0.0
			app.game_over = true
			app.sound_mgr.play_invalid_sound()
		}
	}

	// Idle Hint timer
	if !app.swap_anim.active && !app.falling && !app.game_over {
		app.hint_timer += dt
		if app.hint_timer >= 6.0 && !app.show_hint {
			p1, p2, ok := app.grid.find_hint_move()
			if ok {
				app.hint_p1 = p1
				app.hint_p2 = p2
				app.show_hint = true
			}
		}
	}

	// Handle Swap Animation
	if app.swap_anim.active {
		app.swap_anim.progress += dt * 6.0
		if app.swap_anim.progress >= 1.0 {
			app.swap_anim.progress = 1.0

			// Check if Hypercube is involved
			c1_sp := app.grid.cells[app.swap_anim.r1][app.swap_anim.c1].special
			c2_sp := app.grid.cells[app.swap_anim.r2][app.swap_anim.c2].special
			if c1_sp == .hypercube || c2_sp == .hypercube {
				app.trigger_hypercube_zap(app.swap_anim.r1, app.swap_anim.c1, app.swap_anim.r2, app.swap_anim.c2)
				app.swap_anim.active = false
				return
			}

			// Swap in actual grid
			app.grid.swap(app.swap_anim.r1, app.swap_anim.c1, app.swap_anim.r2, app.swap_anim.c2)

			// Check if swap gave matches or hypercube
			has_match := app.process_matches()
			if !has_match {
				if !app.swap_anim.revert {
					// Swap back
					app.sound_mgr.play_invalid_sound()
					app.swap_anim.revert = true
					app.swap_anim.progress = 0.0
				} else {
					app.swap_anim.active = false
				}
			} else {
				app.swap_anim.active = false
				app.falling = true
			}
		}
		return
	}

	// Handle Falling Gems Animation
	mut any_falling := false
	fall_speed := dt * 12.0

	for r in 0 .. grid_size {
		for c in 0 .. grid_size {
			mut gem := unsafe { &app.grid.cells[r][c] }
			target_y := f64(r)
			target_x := f64(c)

			if gem.curr_y < target_y {
				gem.curr_y += fall_speed
				if gem.curr_y >= target_y {
					gem.curr_y = target_y
				} else {
					any_falling = true
				}
			}
			gem.curr_x = target_x
		}
	}

	if any_falling {
		app.falling = true
	} else if app.falling {
		// All gems finished falling, apply gravity/refill or check next matches
		if app.grid.apply_gravity_and_refill() {
			app.falling = true
		} else {
			// Check cascade matches
			if app.process_matches() {
				app.falling = true
			} else {
				app.falling = false
				app.combo = 0

				// Check if any moves remain
				if !app.grid.has_valid_moves() {
					app.grid.reshuffle()
					app.sound_mgr.play_swap_sound()
				}
			}
		}
	}
}

fn draw_gem_shape(renderer &sdl.Renderer, cx int, cy int, size int, kind int, special SpecialType) {
	color := get_gem_color(kind)
	r := size / 2
	ticks := sdl.get_ticks()

	// High & Shadow colors for 3D facets
	hi_r := u8(math.min(255, int(color.r) + 85))
	hi_g := u8(math.min(255, int(color.g) + 85))
	hi_b := u8(math.min(255, int(color.b) + 85))

	sh_r := u8(math.max(0, int(color.r) - 75))
	sh_g := u8(math.max(0, int(color.g) - 75))
	sh_b := u8(math.max(0, int(color.b) - 75))

	match kind {
		1 { // Ruby: Octagon with 3D Beveled facets
			pad := r / 3
			// Outer dark drop shadow
			sdl.set_render_draw_color(renderer, sh_r, sh_g, sh_b, 255)
			rect_shadow := sdl.Rect{x: cx - r + 1, y: cy - r + 1, w: r * 2, h: r * 2}
			sdl.render_fill_rect(renderer, &rect_shadow)

			// Base fill
			rect := sdl.Rect{x: cx - r, y: cy - r, w: r * 2, h: r * 2}
			sdl.set_render_draw_color(renderer, color.r, color.g, color.b, 255)
			sdl.render_fill_rect(renderer, &rect)

			// 3D Highlight top/left
			sdl.set_render_draw_color(renderer, hi_r, hi_g, hi_b, 255)
			sdl.render_draw_line(renderer, cx - r, cy, cx, cy - r)
			sdl.render_draw_line(renderer, cx, cy - r, cx + r, cy)
			sdl.render_draw_line(renderer, cx - r + 1, cy, cx, cy - r + 1)

			// 3D Shadow bottom/right
			sdl.set_render_draw_color(renderer, sh_r, sh_g, sh_b, 255)
			sdl.render_draw_line(renderer, cx + r, cy, cx, cy + r)
			sdl.render_draw_line(renderer, cx, cy + r, cx - r, cy)

			// Raised Center Table Facet
			inner := sdl.Rect{x: cx - r + pad, y: cy - r + pad, w: (r - pad) * 2, h: (r - pad) * 2}
			sdl.set_render_draw_color(renderer, hi_r, hi_g, hi_b, 200)
			sdl.render_fill_rect(renderer, &inner)
			sdl.set_render_draw_color(renderer, color.r, color.g, color.b, 255)
			inner_core := sdl.Rect{x: inner.x + 2, y: inner.y + 2, w: inner.w - 4, h: inner.h - 4}
			sdl.render_fill_rect(renderer, &inner_core)
		}
		2 { // Sapphire: Hexagon Brilliant Cut
			// Base fill with horizontal scanlines
			for i := -r; i <= r; i++ {
				w := int(f64(r) * (1.0 - math.abs(f64(i)) / (f64(r) * 2.2)))
				shade := if i < 0 { 40 } else { -40 }
				cr := u8(math.clamp(int(color.r) + shade, 0, 255))
				cg := u8(math.clamp(int(color.g) + shade, 0, 255))
				cb := u8(math.clamp(int(color.b) + shade, 0, 255))
				sdl.set_render_draw_color(renderer, cr, cg, cb, 255)
				rect := sdl.Rect{x: cx - w, y: cy + i, w: w * 2, h: 1}
				sdl.render_fill_rect(renderer, &rect)
			}
			// Hexagonal inner facet lines
			sdl.set_render_draw_color(renderer, hi_r, hi_g, hi_b, 230)
			sdl.render_draw_line(renderer, cx - r / 2, cy - r / 2, cx + r / 2, cy - r / 2)
			sdl.render_draw_line(renderer, cx - r / 2, cy - r / 2, cx - r / 2, cy + r / 2)
			sdl.set_render_draw_color(renderer, sh_r, sh_g, sh_b, 230)
			sdl.render_draw_line(renderer, cx + r / 2, cy - r / 2, cx + r / 2, cy + r / 2)
			sdl.render_draw_line(renderer, cx - r / 2, cy + r / 2, cx + r / 2, cy + r / 2)
		}
		3 { // Emerald: Classic Step Cut Beveled Square
			rect := sdl.Rect{x: cx - r, y: cy - r, w: r * 2, h: r * 2}
			sdl.set_render_draw_color(renderer, color.r, color.g, color.b, 255)
			sdl.render_fill_rect(renderer, &rect)

			// Step 1: Outer Chamfer
			sdl.set_render_draw_color(renderer, hi_r, hi_g, hi_b, 255)
			for t in 0 .. 3 {
				sdl.render_draw_line(renderer, cx - r + t, cy - r + t, cx + r - t, cy - r + t)
				sdl.render_draw_line(renderer, cx - r + t, cy - r + t, cx - r + t, cy + r - t)
			}
			sdl.set_render_draw_color(renderer, sh_r, sh_g, sh_b, 255)
			for t in 0 .. 3 {
				sdl.render_draw_line(renderer, cx - r + t, cy + r - t, cx + r - t, cy + r - t)
				sdl.render_draw_line(renderer, cx + r - t, cy - r + t, cx + r - t, cy + r - t)
			}

			// Step 2: Inner Emerald Table
			inner := sdl.Rect{x: cx - r / 2, y: cy - r / 2, w: r, h: r}
			sdl.set_render_draw_color(renderer, hi_r, hi_g, hi_b, 180)
			sdl.render_draw_rect(renderer, &inner)
			sdl.set_render_draw_color(renderer, 160, 255, 200, 240)
			core := sdl.Rect{x: inner.x + 2, y: inner.y + 2, w: inner.w - 4, h: inner.h - 4}
			sdl.render_fill_rect(renderer, &core)
		}
		4 { // Topaz: Triangular Brilliant Pyramid
			for y := -r; y <= r; y++ {
				prog := f64(y + r) / f64(r * 2)
				w := int(f64(r) * prog)
				shade := if y < 0 { 50 } else { -30 }
				cr := u8(math.clamp(int(color.r) + shade, 0, 255))
				cg := u8(math.clamp(int(color.g) + shade, 0, 255))
				cb := u8(math.clamp(int(color.b) + shade, 0, 255))
				sdl.set_render_draw_color(renderer, cr, cg, cb, 255)
				rect := sdl.Rect{x: cx - w, y: cy + y, w: w * 2, h: 1}
				sdl.render_fill_rect(renderer, &rect)
			}
			// Pyramid facet ridge lines meeting at center
			sdl.set_render_draw_color(renderer, 255, 255, 200, 240)
			sdl.render_draw_line(renderer, cx, cy - r, cx, cy + r / 3)
			sdl.render_draw_line(renderer, cx - r, cy + r, cx, cy + r / 3)
			sdl.set_render_draw_color(renderer, sh_r, sh_g, sh_b, 240)
			sdl.render_draw_line(renderer, cx + r, cy + r, cx, cy + r / 3)
		}
		5 { // Amethyst: Radiant Circular Jewel
			for y := -r; y <= r; y++ {
				norm_y := f64(y) / f64(r)
				w := int(f64(r) * math.sqrt(math.max(0.0, 1.0 - norm_y * norm_y)))
				shade := if y < 0 { 40 } else { -40 }
				cr := u8(math.clamp(int(color.r) + shade, 0, 255))
				cg := u8(math.clamp(int(color.g) + shade, 0, 255))
				cb := u8(math.clamp(int(color.b) + shade, 0, 255))
				sdl.set_render_draw_color(renderer, cr, cg, cb, 255)
				rect := sdl.Rect{x: cx - w, y: cy + y, w: w * 2, h: 1}
				sdl.render_fill_rect(renderer, &rect)
			}
			// Star-cut facet ring
			sdl.set_render_draw_color(renderer, hi_r, hi_g, hi_b, 200)
			for rad_i in 0 .. 8 {
				ang := f64(rad_i) * math.pi / 4.0
				x1 := cx + int(f64(r / 3) * math.cos(ang))
				y1 := cy + int(f64(r / 3) * math.sin(ang))
				x2 := cx + int(f64(r - 2) * math.cos(ang))
				y2 := cy + int(f64(r - 2) * math.sin(ang))
				sdl.render_draw_line(renderer, x1, y1, x2, y2)
			}
		}
		6 { // Diamond: Kite Rhombus Brilliant
			for y := -r; y <= r; y++ {
				prog := 1.0 - math.abs(f64(y)) / f64(r)
				w := int(f64(r) * prog)
				shade := if y < 0 { 60 } else { -40 }
				cr := u8(math.clamp(int(color.r) + shade, 0, 255))
				cg := u8(math.clamp(int(color.g) + shade, 0, 255))
				cb := u8(math.clamp(int(color.b) + shade, 0, 255))
				sdl.set_render_draw_color(renderer, cr, cg, cb, 255)
				rect := sdl.Rect{x: cx - w, y: cy + y, w: w * 2, h: 1}
				sdl.render_fill_rect(renderer, &rect)
			}
			// Diamond cross-facet star
			sdl.set_render_draw_color(renderer, 255, 255, 255, 240)
			sdl.render_draw_line(renderer, cx, cy - r, cx, cy + r)
			sdl.render_draw_line(renderer, cx - r, cy, cx + r, cy)
			sdl.set_render_draw_color(renderer, 180, 230, 255, 200)
			inner_d := sdl.Rect{x: cx - r / 3, y: cy - r / 3, w: (r / 3) * 2, h: (r / 3) * 2}
			sdl.render_draw_rect(renderer, &inner_d)
		}
		7 { // Amber: Star Pentagon Cut
			rect := sdl.Rect{x: cx - r + 3, y: cy - r / 2, w: (r - 3) * 2, h: r + r / 2}
			sdl.set_render_draw_color(renderer, color.r, color.g, color.b, 255)
			sdl.render_fill_rect(renderer, &rect)
			sdl.set_render_draw_color(renderer, hi_r, hi_g, hi_b, 255)
			sdl.render_draw_line(renderer, cx, cy - r, cx - r, cy)
			sdl.render_draw_line(renderer, cx, cy - r, cx + r, cy)
			sdl.set_render_draw_color(renderer, sh_r, sh_g, sh_b, 255)
			sdl.render_draw_line(renderer, cx - r, cy, cx - r / 2, cy + r)
			sdl.render_draw_line(renderer, cx + r, cy, cx + r / 2, cy + r)
			sdl.render_draw_line(renderer, cx - r / 2, cy + r, cx + r / 2, cy + r)
		}
		else {}
	}

	// Dynamic Specular Star Glint (sparkles periodically)
	sparkle := math.sin(f64(ticks) * 0.006 + f64(cx + cy) * 0.05) * 0.5 + 0.5
	if sparkle > 0.4 {
		alpha := u8(sparkle * 240.0)
		sdl.set_render_draw_color(renderer, 255, 255, 255, alpha)
		gx := cx - r / 3
		gy := cy - r / 2
		// 4-point cross starburst glint
		sdl.render_draw_point(renderer, gx, gy)
		sdl.render_draw_point(renderer, gx - 1, gy)
		sdl.render_draw_point(renderer, gx + 1, gy)
		sdl.render_draw_point(renderer, gx, gy - 1)
		sdl.render_draw_point(renderer, gx, gy + 1)
		if sparkle > 0.8 {
			sdl.render_draw_point(renderer, gx - 2, gy)
			sdl.render_draw_point(renderer, gx + 2, gy)
			sdl.render_draw_point(renderer, gx, gy - 2)
			sdl.render_draw_point(renderer, gx, gy + 2)
		}
	}

	// Special Gem Visual Overlays
	if special == .flame {
		// Multi-layered pulsating flame aura with orbiting embers
		pulse := math.sin(f64(ticks) * 0.012) * 0.5 + 0.5
		glow_size := r + 2 + int(pulse * 3.0)

		sdl.set_render_draw_color(renderer, 255, u8(100 + pulse * 100.0), 30, 200)
		g1 := sdl.Rect{x: cx - glow_size, y: cy - glow_size, w: glow_size * 2, h: glow_size * 2}
		sdl.render_draw_rect(renderer, &g1)

		sdl.set_render_draw_color(renderer, 255, 220, 60, 240)
		g2 := sdl.Rect{x: cx - glow_size + 1, y: cy - glow_size + 1, w: (glow_size - 1) * 2, h: (glow_size - 1) * 2}
		sdl.render_draw_rect(renderer, &g2)

		// Orbiting flame sparks
		for spark_i in 0 .. 4 {
			ang := f64(ticks) * 0.008 + f64(spark_i) * math.pi / 2.0
			sx := cx + int(f64(r + 4) * math.cos(ang))
			sy := cy + int(f64(r + 4) * math.sin(ang))
			sdl.set_render_draw_color(renderer, 255, 230, 70, 255)
			sdl.render_draw_point(renderer, sx, sy)
			sdl.render_draw_point(renderer, sx + 1, sy)
		}
	} else if special == .star {
		// Electric Pulsating Star Gem with energy spikes
		pulse := math.sin(f64(ticks) * 0.015) * 0.5 + 0.5
		sdl.set_render_draw_color(renderer, 80, 240, 255, 255)
		sp_len := r + 4 + int(pulse * 4.0)

		sdl.render_draw_line(renderer, cx - sp_len, cy, cx + sp_len, cy)
		sdl.render_draw_line(renderer, cx, cy - sp_len, cx, cy + sp_len)

		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		sdl.render_draw_line(renderer, cx - sp_len / 2, cy, cx + sp_len / 2, cy)
		sdl.render_draw_line(renderer, cx, cy - sp_len / 2, cx, cy + sp_len / 2)
	} else if special == .supernova {
		// Solar Corona Flare
		for ring in 0 .. 4 {
			t_ang := f64(ticks) * 0.01 + f64(ring) * 1.57
			flare_r := r + 4 + int(math.sin(t_ang) * 4.0)
			sdl.set_render_draw_color(renderer, 255, 220, 60, 220)
			r_box := sdl.Rect{x: cx - flare_r, y: cy - flare_r, w: flare_r * 2, h: flare_r * 2}
			sdl.render_draw_rect(renderer, &r_box)
		}
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		sdl.render_fill_rect(renderer, &sdl.Rect{x: cx - 3, y: cy - 3, w: 6, h: 6})
	} else if special == .hypercube {
		// Prismatic Rotating Rainbow Vortex
		for ring in 0 .. 3 {
			t_shift := f64(ticks) * 0.006 + f64(ring) * 1.8
			rr := u8((math.sin(t_shift) * 0.5 + 0.5) * 255.0)
			rg := u8((math.sin(t_shift + 2.09) * 0.5 + 0.5) * 255.0)
			rb := u8((math.sin(t_shift + 4.18) * 0.5 + 0.5) * 255.0)
			sdl.set_render_draw_color(renderer, rr, rg, rb, 255)

			offset := ring * 2
			cube := sdl.Rect{x: cx - r - 2 + offset, y: cy - r - 2 + offset, w: (r + 2 - offset) * 2, h: (r + 2 - offset) * 2}
			sdl.render_draw_rect(renderer, &cube)
		}
		// Bright center crystal star
		sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
		sdl.render_draw_line(renderer, cx - 4, cy, cx + 4, cy)
		sdl.render_draw_line(renderer, cx, cy - 4, cx, cy + 4)
	}
}

fn (mut app App) render() {
	renderer := app.renderer

	// Starry deep midnight blue background
	sdl.set_render_draw_color(renderer, 14, 18, 30, 255)
	sdl.render_clear(renderer)

	// Top Title
	draw_text_centered(renderer, win_width / 2, 25, 'BEJEWELED // GEM MATCH-3', 3, Color{r: 90, g: 190, b: 255})
	draw_text_centered(renderer, win_width / 2, 65, 'CASCADING GEMS & SPECIAL COMBOS', 2, Color{r: 170, g: 190, b: 230})

	// Screen Shake on Flame / Hypercube explosions
	mut bx := board_x
	mut by := board_y
	if app.shake_timer > 0 {
		shake_mag := app.shake_timer * 20.0
		bx += int((rand.f64() * 2.0 - 1.0) * shake_mag)
		by += int((rand.f64() * 2.0 - 1.0) * shake_mag)
	}

	// Outer Board Bevel
	pad := 14
	board_rect := sdl.Rect{
		x: bx - pad
		y: by - pad
		w: grid_w + pad * 2
		h: grid_h + pad * 2
	}
	sdl.set_render_draw_color(renderer, 30, 36, 56, 255)
	sdl.render_fill_rect(renderer, &board_rect)
	sdl.set_render_draw_color(renderer, 60, 75, 115, 255)
	sdl.render_draw_rect(renderer, &board_rect)

	// Inner Grid Cells
	for r in 0 .. grid_size {
		for c in 0 .. grid_size {
			cell_rect := sdl.Rect{
				x: bx + c * cell_size
				y: by + r * cell_size
				w: cell_size
				h: cell_size
			}
			is_dark := (r + c) % 2 == 0
			sdl.set_render_draw_color(renderer, if is_dark { u8(18) } else { u8(24) }, if is_dark { u8(22) } else { u8(30) }, if is_dark { u8(38) } else { u8(48) }, 255)
			sdl.render_fill_rect(renderer, &cell_rect)
			sdl.set_render_draw_color(renderer, 40, 50, 75, 255)
			sdl.render_draw_rect(renderer, &cell_rect)
		}
	}

	// Hint Highlight Pulses
	if app.show_hint && app.hint_p1.r >= 0 && app.hint_p2.r >= 0 {
		pulse := u8((math.sin(f64(sdl.get_ticks()) * 0.008) * 0.5 + 0.5) * 150.0 + 105.0)
		sdl.set_render_draw_color(renderer, pulse, pulse, 60, 255)

		h1 := sdl.Rect{x: bx + app.hint_p1.c * cell_size + 2, y: by + app.hint_p1.r * cell_size + 2, w: cell_size - 4, h: cell_size - 4}
		h2 := sdl.Rect{x: bx + app.hint_p2.c * cell_size + 2, y: by + app.hint_p2.r * cell_size + 2, w: cell_size - 4, h: cell_size - 4}
		sdl.render_draw_rect(renderer, &h1)
		sdl.render_draw_rect(renderer, &h2)
	}

	// Selected Cell Highlight
	if app.selected_r >= 0 && app.selected_c >= 0 {
		sel_rect := sdl.Rect{
			x: bx + app.selected_c * cell_size + 2
			y: by + app.selected_r * cell_size + 2
			w: cell_size - 4
			h: cell_size - 4
		}
		sdl.set_render_draw_color(renderer, 255, 230, 80, 255)
		sdl.render_draw_rect(renderer, &sel_rect)
		inner := sdl.Rect{x: sel_rect.x + 1, y: sel_rect.y + 1, w: sel_rect.w - 2, h: sel_rect.h - 2}
		sdl.render_draw_rect(renderer, &inner)
	}

	// Render Gems
	for r in 0 .. grid_size {
		for c in 0 .. grid_size {
			gem := app.grid.cells[r][c]
			if gem.kind == 0 {
				continue
			}

			mut cx := bx + int(gem.curr_x * f64(cell_size)) + cell_size / 2
			mut cy := by + int(gem.curr_y * f64(cell_size)) + cell_size / 2

			// Handle Swap Interpolation
			if app.swap_anim.active {
				if r == app.swap_anim.r1 && c == app.swap_anim.c1 {
					prog := if app.swap_anim.revert { 1.0 - app.swap_anim.progress } else { app.swap_anim.progress }
					dx := f64(app.swap_anim.c2 - app.swap_anim.c1) * f64(cell_size) * prog
					dy := f64(app.swap_anim.r2 - app.swap_anim.r1) * f64(cell_size) * prog
					cx = bx + c * cell_size + cell_size / 2 + int(dx)
					cy = by + r * cell_size + cell_size / 2 + int(dy)
				} else if r == app.swap_anim.r2 && c == app.swap_anim.c2 {
					prog := if app.swap_anim.revert { 1.0 - app.swap_anim.progress } else { app.swap_anim.progress }
					dx := f64(app.swap_anim.c1 - app.swap_anim.c2) * f64(cell_size) * prog
					dy := f64(app.swap_anim.r1 - app.swap_anim.r2) * f64(cell_size) * prog
					cx = bx + c * cell_size + cell_size / 2 + int(dx)
					cy = by + r * cell_size + cell_size / 2 + int(dy)
				}
			}

			// Don't render above board during refill spawn
			if cy < by {
				continue
			}

			draw_gem_shape(renderer, cx, cy, cell_size - 14, gem.kind, gem.special)
		}
	}

	// Render Laser Beams
	for lb in app.laser_beams {
		x1 := bx + lb.c1 * cell_size + cell_size / 2
		y1 := by + lb.r1 * cell_size + cell_size / 2
		x2 := bx + lb.c2 * cell_size + cell_size / 2
		y2 := by + lb.r2 * cell_size + cell_size / 2
		alpha := u8(math.min(255.0, lb.life * 550.0))
		sdl.set_render_draw_blend_mode(renderer, .blend)
		sdl.set_render_draw_color(renderer, lb.color.r, lb.color.g, lb.color.b, alpha)
		for w_i in -3 .. 4 {
			if lb.r1 == lb.r2 {
				sdl.render_draw_line(renderer, x1, y1 + w_i, x2, y2 + w_i)
			} else {
				sdl.render_draw_line(renderer, x1 + w_i, y1, x2 + w_i, y2)
			}
		}
	}

	// Render Hyper Zaps
	for hz in app.hyper_zaps {
		alpha := u8(math.min(255.0, hz.life * 500.0))
		sdl.set_render_draw_blend_mode(renderer, .blend)
		sdl.set_render_draw_color(renderer, hz.color.r, hz.color.g, hz.color.b, alpha)
		mid_x := (hz.fx + hz.tx) / 2.0 + (rand.f64() * 2.0 - 1.0) * 12.0
		mid_y := (hz.fy + hz.ty) / 2.0 + (rand.f64() * 2.0 - 1.0) * 12.0
		sdl.render_draw_line(renderer, int(hz.fx), int(hz.fy), int(mid_x), int(mid_y))
		sdl.render_draw_line(renderer, int(mid_x), int(mid_y), int(hz.tx), int(hz.ty))
	}

	// Keyboard Cursor Bracket
	if app.cursor_r >= 0 && app.cursor_c >= 0 {
		cur_x := bx + app.cursor_c * cell_size
		cur_y := by + app.cursor_r * cell_size
		sdl.set_render_draw_color(renderer, 80, 230, 255, 255)
		sdl.render_draw_line(renderer, cur_x + 4, cur_y + 4, cur_x + 14, cur_y + 4)
		sdl.render_draw_line(renderer, cur_x + 4, cur_y + 4, cur_x + 4, cur_y + 14)
		sdl.render_draw_line(renderer, cur_x + cell_size - 4, cur_y + 4, cur_x + cell_size - 14, cur_y + 4)
		sdl.render_draw_line(renderer, cur_x + cell_size - 4, cur_y + 4, cur_x + cell_size - 4, cur_y + 14)
		sdl.render_draw_line(renderer, cur_x + 4, cur_y + cell_size - 4, cur_x + 14, cur_y + cell_size - 4)
		sdl.render_draw_line(renderer, cur_x + 4, cur_y + cell_size - 4, cur_x + 4, cur_y + cell_size - 14)
		sdl.render_draw_line(renderer, cur_x + cell_size - 4, cur_y + cell_size - 4, cur_x + cell_size - 14, cur_y + cell_size - 4)
		sdl.render_draw_line(renderer, cur_x + cell_size - 4, cur_y + cell_size - 4, cur_x + cell_size - 4, cur_y + cell_size - 14)
	}

	// Render Floating Texts
	for ft in app.float_texts {
		draw_text(renderer, int(ft.x), int(ft.y), ft.text, 2, ft.color)
	}

	// Render Particles
	for part in app.particles {
		rect := sdl.Rect{
			x: int(part.x)
			y: int(part.y)
			w: part.size
			h: part.size
		}
		sdl.set_render_draw_color(renderer, part.color.r, part.color.g, part.color.b, u8(part.life * 255.0))
		sdl.render_fill_rect(renderer, &rect)
	}

	// Right HUD Panel (Scores & Stats)
	hud_x := 620
	hud_y := 150

	// Score Box
	score_box := sdl.Rect{x: hud_x, y: hud_y, w: 320, h: 105}
	sdl.set_render_draw_color(renderer, 24, 30, 48, 255)
	sdl.render_fill_rect(renderer, &score_box)
	sdl.set_render_draw_color(renderer, 60, 75, 120, 255)
	sdl.render_draw_rect(renderer, &score_box)

	draw_text(renderer, hud_x + 20, hud_y + 18, 'SCORE', 2, Color{r: 160, g: 190, b: 230})
	draw_text(renderer, hud_x + 20, hud_y + 46, '${app.score}', 3, Color{r: 255, g: 255, b: 255})
	draw_text(renderer, hud_x + 20, hud_y + 80, 'BEST: ${app.high_score}', 1, Color{r: 140, g: 160, b: 190})

	// Level / Timer / Zen Box
	prog_box := sdl.Rect{x: hud_x, y: hud_y + 120, w: 320, h: 110}
	sdl.set_render_draw_color(renderer, 24, 30, 48, 255)
	sdl.render_fill_rect(renderer, &prog_box)
	sdl.set_render_draw_color(renderer, 60, 75, 120, 255)
	sdl.render_draw_rect(renderer, &prog_box)

	if app.mode == .classic {
		draw_text(renderer, hud_x + 20, hud_y + 138, 'CLASSIC // LEVEL ${app.level}', 2, Color{r: 100, g: 220, b: 255})
		target := app.level * 2500
		pct := math.min(1.0, f64(app.level_progress) / f64(target))
		bar_bg := sdl.Rect{x: hud_x + 20, y: hud_y + 175, w: 280, h: 22}
		sdl.set_render_draw_color(renderer, 15, 20, 32, 255)
		sdl.render_fill_rect(renderer, &bar_bg)
		bar_fill := sdl.Rect{x: hud_x + 20, y: hud_y + 175, w: int(280.0 * pct), h: 22}
		sdl.set_render_draw_color(renderer, 70, 180, 255, 255)
		sdl.render_fill_rect(renderer, &bar_fill)
		draw_text_centered(renderer, hud_x + 160, hud_y + 204, '${app.level_progress} / ${target}', 1, Color{r: 200, g: 220, b: 255})
	} else if app.mode == .time_attack {
		draw_text(renderer, hud_x + 20, hud_y + 138, 'LIGHTNING // BLITZ', 2, Color{r: 255, g: 100, b: 100})
		time_pct := math.min(1.0, app.time_left / 60.0)
		bar_bg := sdl.Rect{x: hud_x + 20, y: hud_y + 175, w: 280, h: 22}
		sdl.set_render_draw_color(renderer, 15, 20, 32, 255)
		sdl.render_fill_rect(renderer, &bar_bg)
		bar_fill := sdl.Rect{x: hud_x + 20, y: hud_y + 175, w: int(280.0 * time_pct), h: 22}
		bar_col := if app.time_left < 15.0 { Color{r: 255, g: 45, b: 45} } else { Color{r: 255, g: 140, b: 50} }
		sdl.set_render_draw_color(renderer, bar_col.r, bar_col.g, bar_col.b, 255)
		sdl.render_fill_rect(renderer, &bar_fill)
		draw_text_centered(renderer, hud_x + 160, hud_y + 204, '${int(app.time_left)}s REMAINING (+5s SPECIAL)', 1, Color{r: 255, g: 220, b: 200})
	} else {
		draw_text(renderer, hud_x + 20, hud_y + 138, 'ZEN // RELAXATION', 2, Color{r: 120, g: 255, b: 150})
		draw_text(renderer, hud_x + 20, hud_y + 175, 'ENDLESS TRANQUIL PLAY', 1, Color{r: 180, g: 235, b: 200})
		draw_text(renderer, hud_x + 20, hud_y + 195, 'NO TIMERS // NO GAME OVER', 1, Color{r: 140, g: 200, b: 170})
	}

	// Instructions / Powers Box
	inst_card := sdl.Rect{x: hud_x, y: hud_y + 245, w: 320, h: 285}
	sdl.set_render_draw_color(renderer, 20, 24, 38, 255)
	sdl.render_fill_rect(renderer, &inst_card)
	sdl.set_render_draw_color(renderer, 50, 65, 100, 255)
	sdl.render_draw_rect(renderer, &inst_card)

	draw_text_centered(renderer, hud_x + 160, hud_y + 258, 'SPECIAL GEM POWERS', 2, Color{r: 255, g: 215, b: 70})
	draw_text(renderer, hud_x + 16, hud_y + 288, '- Match 4 : Flame Gem (3x3 Blast)', 1, Color{r: 255, g: 140, b: 60})
	draw_text(renderer, hud_x + 16, hud_y + 310, '- Match 5 L/T : Star Gem (Cross Laser)', 1, Color{r: 80, g: 240, b: 255})
	draw_text(renderer, hud_x + 16, hud_y + 332, '- Match 5 Line : Hypercube (Color Zap)', 1, Color{r: 255, g: 180, b: 245})
	draw_text(renderer, hud_x + 16, hud_y + 354, '- Match 6+ : Supernova (Mega Blast)', 1, Color{r: 255, g: 225, b: 70})

	bgm_name := match app.sound_mgr.bgm_type {
		.cosmic_trance { 'COSMIC TRANCE' }
		.electro_rush { 'ELECTRO RUSH' }
		.zen_ambient { 'ZEN AMBIENT' }
		.off { 'OFF' }
	}
	draw_text(renderer, hud_x + 16, hud_y + 386, 'MUSIC : ${bgm_name} [T/B]', 1, Color{r: 100, g: 230, b: 255})
	draw_text(renderer, hud_x + 16, hud_y + 408, 'CONTROLS : WASD / ARROWS / MOUSE', 1, Color{r: 200, g: 220, b: 240})
	draw_text(renderer, hud_x + 16, hud_y + 430, '[SPACE/ENTER] SWAP  [U] UNDO', 1, Color{r: 220, g: 220, b: 230})
	draw_text(renderer, hud_x + 16, hud_y + 452, '[H] HINT  [M] MODE  [S] SOUND  [R] RESET  [F11] Fullscreen', 1, Color{r: 180, g: 200, b: 230})

	// Game Over Banner
	if app.game_over {
		banner := sdl.Rect{x: 0, y: 690, w: win_width, h: 55}
		sdl.set_render_draw_color(renderer, 70, 20, 25, 230)
		sdl.render_fill_rect(renderer, &banner)
		draw_text_centered(renderer, win_width / 2, 706, 'TIME OVER! FINAL SCORE: ${app.score} - PRESS [R] TO PLAY AGAIN', 2, Color{r: 255, g: 220, b: 80})
	}

	// Render Buttons
	mut mx, mut my := 0, 0
	sdl.get_mouse_state(&mx, &my)

	app.btn_reset.render(renderer, mx, my)
	app.btn_hint.render(renderer, mx, my)

	app.btn_mode.text = match app.mode {
		.classic { 'CLASSIC [M]' }
		.time_attack { 'LIGHTNING [M]' }
		.zen { 'ZEN [M]' }
	}
	app.btn_mode.render(renderer, mx, my)

	app.btn_sound.text = if app.sound_mgr.sound_enabled { 'SOUND: ON [S]' } else { 'SOUND: OFF [S]' }
	app.btn_sound.render(renderer, mx, my)

	sdl.render_present(renderer)
}

fn (mut app App) get_cell_under_mouse(mx int, my int) (int, int) {
	if mx >= board_x && mx < board_x + grid_w && my >= board_y && my < board_y + grid_h {
		c := (mx - board_x) / cell_size
		r := (my - board_y) / cell_size
		return r, c
	}
	return -1, -1
}

fn main() {
	if sdl.init(sdl.init_video | sdl.init_audio) != 0 {
		println('Failed to init SDL')
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
		app.score = 4250
		app.level = 2
		app.level_progress = 1800
		app.selected_r = 3
		app.selected_c = 4
		app.render()
		sdl.save_bmp(surface, 'screenshots/bejeweled.bmp'.str)
		sdl.destroy_renderer(s_renderer)
		sdl.free_surface(surface)
		return
	}

	window := sdl.create_window(
		'Bejeweled // Gem Match-3'.str,
		sdl.windowpos_centered,
		sdl.windowpos_centered,
		win_width,
		win_height,
		u32(sdl.WindowFlags.shown) | u32(sdl.WindowFlags.fullscreen_desktop) | u32(sdl.WindowFlags.resizable)
	)
	if window == unsafe { nil } {
		return
	}
	defer {
		sdl.destroy_window(window)
	}

	renderer := sdl.create_renderer(window, -1, u32(u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync)))
	if renderer == unsafe { nil } {
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
		ticks := sdl.get_ticks()
		dt := f64(ticks - last_ticks) / 1000.0
		last_ticks = ticks

		// Update Background Music
		app.sound_mgr.update_bgm(dt, !app.game_over)

		mut event := sdl.Event{}
		for sdl.poll_event(&event) != 0 {
			match event.@type {
				.quit {
					return
				}
				.mousemotion {
					app.hover_r, app.hover_c = app.get_cell_under_mouse(event.motion.x, event.motion.y)
				}
				.mousebuttondown {
					mx := event.button.x
					my := event.button.y
					if app.btn_reset.is_hovered(mx, my) {
						app.grid = new_grid()
						app.score = 0
						app.level = 1
						app.level_progress = 0
						app.time_left = 60.0
						app.game_over = false
						app.selected_r = -1
						app.selected_c = -1
						app.show_hint = false
						app.sound_mgr.play_swap_sound()
					} else if app.btn_hint.is_hovered(mx, my) {
						p1, p2, ok := app.grid.find_hint_move()
						if ok {
							app.hint_p1 = p1
							app.hint_p2 = p2
							app.show_hint = true
							app.sound_mgr.play_select_sound()
						}
					} else if app.btn_mode.is_hovered(mx, my) {
						app.mode = match app.mode {
							.classic { GameMode.time_attack }
							.time_attack { GameMode.zen }
							.zen { GameMode.classic }
						}
						app.time_left = 60.0
						app.game_over = false
						app.sound_mgr.play_swap_sound()
					} else if app.btn_sound.is_hovered(mx, my) {
						app.sound_mgr.toggle_sound()
					} else {
						r, c := app.get_cell_under_mouse(mx, my)
						if r >= 0 && c >= 0 {
							app.handle_gem_click(r, c)
						}
					}
				}
				.keydown {
					sym := int(event.key.keysym.sym)
					if sym == int(sdl.KeyCode.f11) {
						toggle_fullscreen(window)
					} else if sym == int(sdl.KeyCode.escape) {
						return
					}
					// WASD / Arrow Movement
					else if sym == int(sdl.KeyCode.w) || sym == int(sdl.KeyCode.up) {
						app.move_cursor(-1, 0)
					} else if sym == int(sdl.KeyCode.s) || sym == int(sdl.KeyCode.down) {
						app.move_cursor(1, 0)
					} else if sym == int(sdl.KeyCode.a) || sym == int(sdl.KeyCode.left) {
						app.move_cursor(0, -1)
					} else if sym == int(sdl.KeyCode.d) || sym == int(sdl.KeyCode.right) {
						app.move_cursor(0, 1)
					}
					// Space / Enter / J / Z Action
					else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.@return) || sym == int(sdl.KeyCode.j) || sym == int(sdl.KeyCode.z) {
						app.handle_cursor_action()
					}
					// Undo (U)
					else if sym == int(sdl.KeyCode.u) {
						if app.has_undo && !app.swap_anim.active && !app.falling {
							app.grid = app.undo_grid
							app.has_undo = false
							app.sound_mgr.play_swap_sound()
						}
					}
					// Cycle Soundtrack (T / B)
					else if sym == int(sdl.KeyCode.t) || sym == int(sdl.KeyCode.b) {
						app.sound_mgr.cycle_bgm()
					}
					// Restart (R)
					else if sym == int(sdl.KeyCode.r) {
						app.grid = new_grid()
						app.score = 0
						app.level = 1
						app.level_progress = 0
						app.time_left = 60.0
						app.game_over = false
						app.selected_r = -1
						app.selected_c = -1
						app.show_hint = false
						app.sound_mgr.play_swap_sound()
					}
					// Hint (H / G)
					else if sym == int(sdl.KeyCode.h) || sym == int(sdl.KeyCode.g) {
						p1, p2, ok := app.grid.find_hint_move()
						if ok {
							app.hint_p1 = p1
							app.hint_p2 = p2
							app.show_hint = true
							app.sound_mgr.play_select_sound()
						}
					}
					// Switch Mode (M)
					else if sym == int(sdl.KeyCode.m) {
						app.mode = match app.mode {
							.classic { GameMode.time_attack }
							.time_attack { GameMode.zen }
							.zen { GameMode.classic }
						}
						app.time_left = 60.0
						app.game_over = false
						app.sound_mgr.play_swap_sound()
					}
					// Toggle Sound (S)
					else if sym == int(sdl.KeyCode.s) {
						app.sound_mgr.toggle_sound()
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
