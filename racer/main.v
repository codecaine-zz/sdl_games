module main

import sdl

struct Button {
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

fn (b &Button) contains(px int, py int) bool {
	return px >= b.x && px <= b.x + b.w && py >= b.y && py <= b.y + b.h
}

fn (b &Button) draw(renderer &sdl.Renderer, mouse_x int, mouse_y int) {
	is_hover := b.contains(mouse_x, mouse_y)
	c := if is_hover { b.hover_color } else { b.bg_color }
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 255)
	rect := sdl.Rect{
		x: b.x
		y: b.y
		w: b.w
		h: b.h
	}
	sdl.render_fill_rect(renderer, &rect)

	sdl.set_render_draw_color(renderer, b.border_color.r, b.border_color.g, b.border_color.b, 255)
	sdl.render_draw_rect(renderer, &rect)

	draw_text_centered(renderer, b.x + b.w / 2, b.y + (b.h - 16) / 2, b.text, 2, b.text_color)
}

struct App {
mut:
	window         &sdl.Window   = unsafe { nil }
	renderer       &sdl.Renderer = unsafe { nil }
	game           RacerGame
	sound_mgr      SoundManager
	mouse_x        int
	mouse_y        int
	key_accel      bool
	key_brake      bool
	key_left       bool
	key_right      bool
	key_handbrake  bool
	paused         bool
	btn_restart    Button
	btn_sound      Button
}

fn new_app() App {
	return App{
		game:        new_racer_game()
		sound_mgr:   new_sound_manager()
		btn_restart: Button{
			x:            30
			y:            580
			w:            160
			h:            36
			text:         'RESTART [R]'
			bg_color:     Color{r: 25, g: 35, b: 55}
			hover_color:  Color{r: 45, g: 60, b: 90}
			text_color:   Color{r: 255, g: 255, b: 255}
			border_color: Color{r: 70, g: 90, b: 140}
		}
		btn_sound:   Button{
			x:            200
			y:            580
			w:            120
			h:            36
			text:         'SOUND [S]'
			bg_color:     Color{r: 25, g: 35, b: 55}
			hover_color:  Color{r: 45, g: 60, b: 90}
			text_color:   Color{r: 255, g: 255, b: 255}
			border_color: Color{r: 70, g: 90, b: 140}
		}
	}
}

fn main() {
	if sdl.init(sdl.init_video | sdl.init_audio | sdl.init_events) < 0 {
		eprintln('Failed to init SDL')
		return
	}
	defer { sdl.quit() }

	window := sdl.create_window(
		'Cyber Drift Racer 2D Engine'.str,
		sdl.windowpos_centered,
		sdl.windowpos_centered,
		960,
		640,
		u32(sdl.WindowFlags.shown)
	)
	if unsafe { window == nil } {
		eprintln('Failed to create window')
		return
	}
	defer { sdl.destroy_window(window) }

	renderer := sdl.create_renderer(window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.presentvsync))
	if unsafe { renderer == nil } {
		eprintln('Failed to create renderer')
		return
	}
	defer { sdl.destroy_renderer(renderer) }

	mut app := new_app()
	app.window = window
	app.renderer = renderer

	mut running := true
	mut event := sdl.Event{}
	mut last_ticks := sdl.get_ticks()

	for running {
		current_ticks := sdl.get_ticks()
		dt := f64(current_ticks - last_ticks) / 1000.0
		last_ticks = current_ticks

		for sdl.poll_event(&event) != 0 {
			match event.@type {
				.quit {
					running = false
				}
				.mousemotion {
					app.mouse_x = event.motion.x
					app.mouse_y = event.motion.y
				}
				.mousebuttondown {
					if app.btn_restart.contains(app.mouse_x, app.mouse_y) {
						app.game = new_racer_game()
					} else if app.btn_sound.contains(app.mouse_x, app.mouse_y) {
						app.sound_mgr.toggle_sound()
					}
				}
				.keydown {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) {
						app.key_accel = true
					} else if sym == int(sdl.KeyCode.down) || sym == int(sdl.KeyCode.s) {
						app.key_brake = true
					} else if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = true
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = true
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.k) {
						app.key_handbrake = true
					} else if sym == int(sdl.KeyCode.r) {
						app.game = new_racer_game()
					} else if sym == int(sdl.KeyCode.p) {
						app.paused = !app.paused
					}
				}
				.keyup {
					sym := event.key.keysym.sym
					if sym == int(sdl.KeyCode.up) || sym == int(sdl.KeyCode.w) {
						app.key_accel = false
					} else if sym == int(sdl.KeyCode.down) || sym == int(sdl.KeyCode.s) {
						app.key_brake = false
					} else if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = false
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = false
					} else if sym == int(sdl.KeyCode.space) || sym == int(sdl.KeyCode.k) {
						app.key_handbrake = false
					}
				}
				else {}
			}
		}

		if !app.paused {
			app.game.update(dt, app.key_accel, app.key_brake, app.key_left, app.key_right, app.key_handbrake)

			// Play Audio Synths
			if app.game.sound_event_engine {
				speed_ratio := app.game.player.speed / app.game.player.max_speed
				app.sound_mgr.play_engine_sound(speed_ratio)
			}
			if app.game.sound_event_skid { app.sound_mgr.play_skid_sound() }
			if app.game.sound_event_crash { app.sound_mgr.play_crash_sound() }
			if app.game.sound_event_boost { app.sound_mgr.play_boost_sound() }
			if app.game.sound_event_gate { app.sound_mgr.play_gate_sound() }
		}

		app.game.render(app.renderer)
		app.btn_restart.draw(app.renderer, app.mouse_x, app.mouse_y)
		app.btn_sound.draw(app.renderer, app.mouse_x, app.mouse_y)

		sdl.render_present(app.renderer)
		sdl.delay(10)
	}
}
