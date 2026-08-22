module main

import os

import sdl

struct App {
mut:
	window      &sdl.Window   = unsafe { nil }
	renderer    &sdl.Renderer = unsafe { nil }
	game        Game
	sound_mgr   SoundManager
	btn_editor  Button
	btn_sound   Button
	btn_prev    Button
	btn_next    Button
	btn_restart Button
	btn_test    Button
	btn_clear   Button
	mouse_x     int
	mouse_y     int
	is_down     bool
}

fn new_app() App {
	mut app := App{
		game:        new_game()
		sound_mgr:   new_sound_manager()
		btn_editor:  Button{
			x:            770
			y:            14
			w:            170
			h:            36
			text:         'DESIGNER [TAB]'
			bg_color:     Color{ r: 40, g: 60, b: 100 }
			hover_color:  Color{ r: 60, g: 90, b: 150 }
			text_color:   Color{ r: 255, g: 255, b: 255 }
			border_color: Color{ r: 100, g: 140, b: 220 }
		}
		btn_sound:   Button{
			x:            620
			y:            600
			w:            310
			h:            44
			text:         'SOUND: ON [S]'
			bg_color:     Color{ r: 35, g: 45, b: 70 }
			hover_color:  Color{ r: 55, g: 70, b: 105 }
			text_color:   Color{ r: 255, g: 255, b: 255 }
			border_color: Color{ r: 85, g: 105, b: 150 }
		}
		btn_prev:    Button{
			x:            600
			y:            380
			w:            150
			h:            40
			text:         'PREV LEVEL [<]'
			bg_color:     Color{ r: 40, g: 50, b: 70 }
			hover_color:  Color{ r: 60, g: 80, b: 110 }
			text_color:   Color{ r: 255, g: 255, b: 255 }
			border_color: Color{ r: 90, g: 110, b: 150 }
		}
		btn_next:    Button{
			x:            770
			y:            380
			w:            150
			h:            40
			text:         'NEXT LEVEL [>]'
			bg_color:     Color{ r: 40, g: 50, b: 70 }
			hover_color:  Color{ r: 60, g: 80, b: 110 }
			text_color:   Color{ r: 255, g: 255, b: 255 }
			border_color: Color{ r: 90, g: 110, b: 150 }
		}
		btn_restart: Button{
			x:            600
			y:            435
			w:            320
			h:            44
			text:         'RETRY LEVEL [R]'
			bg_color:     Color{ r: 100, g: 40, b: 40 }
			hover_color:  Color{ r: 150, g: 60, b: 60 }
			text_color:   Color{ r: 255, g: 255, b: 255 }
			border_color: Color{ r: 200, g: 90, b: 90 }
		}
		btn_test:    Button{
			x:            600
			y:            420
			w:            155
			h:            44
			text:         'TEST PLAY'
			bg_color:     Color{ r: 30, g: 120, b: 60 }
			hover_color:  Color{ r: 50, g: 160, b: 90 }
			text_color:   Color{ r: 255, g: 255, b: 255 }
			border_color: Color{ r: 90, g: 220, b: 130 }
		}
		btn_clear:   Button{
			x:            770
			y:            420
			w:            155
			h:            44
			text:         'CLEAR GRID'
			bg_color:     Color{ r: 120, g: 40, b: 40 }
			hover_color:  Color{ r: 170, g: 60, b: 60 }
			text_color:   Color{ r: 255, g: 255, b: 255 }
			border_color: Color{ r: 220, g: 90, b: 90 }
		}
	}
	return app
}

fn (mut app App) init_sdl() bool {
	if sdl.init(sdl.init_video | sdl.init_audio) < 0 {
		eprintln('Failed to init SDL')
		return false
	}

	app.window = sdl.create_window(c'Adventures of Lolo & Level Designer - V & SDL2', sdl.windowpos_centered,
		sdl.windowpos_centered, win_w, win_h, u32(sdl.WindowFlags.shown))
	if app.window == unsafe { nil } {
		eprintln('Failed to create window')
		return false
	}

	app.renderer = sdl.create_renderer(app.window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if app.renderer == unsafe { nil } {
		eprintln('Failed to create renderer')
		return false
	}

	return true
}

fn (mut app App) run() {
	mut last_ticks := sdl.get_ticks()
	mut should_close := false

	for !should_close {
		current_ticks := sdl.get_ticks()
		dt := f64(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks

		mut ev := sdl.Event{}
		for 0 < sdl.poll_event(&ev) {
			match ev.@type {
				.quit {
					should_close = true
				}
				.mousemotion {
					app.mouse_x = ev.motion.x
					app.mouse_y = ev.motion.y

					if app.is_down && app.game.mode == .editor {
						app.handle_grid_editor_click(ev.motion.x, ev.motion.y, false)
					}
				}
				.mousebuttondown {
					mx := ev.button.x
					my := ev.button.y
					app.is_down = true

					is_right := ev.button.button == u8(sdl.button_right)

					if app.btn_editor.contains(mx, my) {
						app.game.toggle_editor_mode()
						app.btn_editor.text = if app.game.mode == .editor { 'PLAY MODE [TAB]' } else { 'DESIGNER [TAB]' }
					} else if app.btn_sound.contains(mx, my) {
						is_on := app.sound_mgr.toggle_sound()
						app.btn_sound.text = if is_on { 'SOUND: ON [S]' } else { 'SOUND: OFF [S]' }
					} else if app.game.mode == .play {
						if app.btn_prev.contains(mx, my) {
							if app.game.current_level_idx > 0 {
								app.game.load_level(app.game.current_level_idx - 1)
							}
						} else if app.btn_next.contains(mx, my) {
							app.game.next_level()
						} else if app.btn_restart.contains(mx, my) {
							app.game.restart_level()
						}
					} else if app.game.mode == .editor {
						if app.btn_test.contains(mx, my) {
							if app.game.test_play_custom_level() {
								app.btn_editor.text = 'DESIGNER [TAB]'
							}
						} else if app.btn_clear.contains(mx, my) {
							app.game.editor_level = create_empty_level('Custom Level')
						} else {
							// Check palette click
							app.handle_palette_click(mx, my)
							// Check grid click
							app.handle_grid_editor_click(mx, my, is_right)
						}
					}
				}
				.mousebuttonup {
					app.is_down = false
				}
				.keydown {
					sym := ev.key.keysym.sym
					if sym == int(sdl.KeyCode.escape) {
						should_close = true
					} else if sym == int(sdl.KeyCode.tab) || sym == int(sdl.KeyCode.e) {
						app.game.toggle_editor_mode()
						app.btn_editor.text = if app.game.mode == .editor { 'PLAY MODE [TAB]' } else { 'DESIGNER [TAB]' }
					} else if sym == int(sdl.KeyCode.s) || sym == int(sdl.KeyCode.o) {
						is_on := app.sound_mgr.toggle_sound()
						app.btn_sound.text = if is_on { 'SOUND: ON [S]' } else { 'SOUND: OFF [S]' }
					} else if app.game.mode == .play {
						if app.game.status == .level_clear || app.game.status == .won {
							if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w)
								|| sym == int(sdl.KeyCode.down) || sym == int(sdl.KeyCode.s)
								|| sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a)
								|| sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d)
								|| sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.@return) {
								app.game.next_level()
								continue
							}
						}

						mut step := false
						mut heart := false
						mut push := false
						mut chest := false
						mut victory := false

						if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) {
							step, heart, push, chest, victory, _ = app.game.move_lolo(.up)
						} else if sym == int(sdl.KeyCode.down) || sym == int(sdl.KeyCode.s) {
							step, heart, push, chest, victory, _ = app.game.move_lolo(.down)
						} else if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
							step, heart, push, chest, victory, _ = app.game.move_lolo(.left)
						} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
							step, heart, push, chest, victory, _ = app.game.move_lolo(.right)
						} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.@return) {
							if app.game.fire_magic_shot() {
								app.sound_mgr.play_shot()
							}
						} else if sym == int(sdl.KeyCode.r) {
							app.game.restart_level()
						}

						if step { app.sound_mgr.play_step() }
						if heart { app.sound_mgr.play_heart() }
						if push { app.sound_mgr.play_push() }
						if chest { app.sound_mgr.play_chest() }
						if victory { app.sound_mgr.play_victory() }
					}
				}
				else {}
			}
		}

		// Game logic update
		p_step, p_heart, p_shot, p_egg, p_push, p_laser, p_chest, p_vic := app.game.update(dt)
		if p_step { app.sound_mgr.play_step() }
		if p_heart { app.sound_mgr.play_heart() }
		if p_shot { app.sound_mgr.play_shot() }
		if p_egg { app.sound_mgr.play_egg() }
		if p_push { app.sound_mgr.play_push() }
		if p_laser { app.sound_mgr.play_laser() }
		if p_chest { app.sound_mgr.play_chest() }
		if p_vic { app.sound_mgr.play_victory() }

		// Draw frame
		draw_game(app.renderer, app.game, app.mouse_x, app.mouse_y, app.btn_editor, app.btn_restart, app.btn_sound, app.btn_prev, app.btn_next, app.btn_test, app.btn_clear)
		sdl.render_present(app.renderer)

		sdl.delay(16) // ~60 FPS
	}
}

fn (mut app App) handle_palette_click(mx int, my int) {
	panel_x := 600
	panel_y := 90

	for idx in 0 .. 18 {
		ix := panel_x + (idx % 3) * 105
		iy := panel_y + 55 + (idx / 3) * 35

		if mx >= ix && mx <= ix + 100 && my >= iy && my <= iy + 30 {
			if idx < 6 {
				app.game.is_entity_selected = false
				app.game.selected_tile = unsafe { TileType(idx) }
			} else {
				app.game.is_entity_selected = true
				app.game.selected_entity = get_entity_from_palette_index(idx)
			}
			return
		}
	}
}

fn (mut app App) handle_grid_editor_click(mx int, my int, is_right bool) {
	col := (mx - grid_offset_x) / cell_size
	row := (my - grid_offset_y) / cell_size

	if col >= 0 && col < grid_cols && row >= 0 && row < grid_rows {
		app.game.handle_editor_click(col, row, is_right)
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
	if os.args.contains("--snapshot") || os.args.contains("--snap") || os.getenv("SNAPSHOT") == "1" {
		if sdl.init(sdl.init_video) != 0 { return }
		defer { sdl.quit() }
		surface := sdl.create_rgb_surface(0, 960, 700, 32, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)
		s_renderer := sdl.create_software_renderer(surface)
		mut app := new_app()
		draw_game(s_renderer, app.game, 0, 0, app.btn_editor, app.btn_restart, app.btn_sound, app.btn_prev, app.btn_next, app.btn_test, app.btn_clear)
		sdl.save_bmp(surface, 'screenshots/lolo.bmp'.str)
		sdl.destroy_renderer(s_renderer)
		sdl.free_surface(surface)
		return
	}
	mut app := new_app()
	if !app.init_sdl() {
		return
	}
	defer {
		app.cleanup()
	}
	app.run()
}
