module main

import rand
import sdl
import math

struct App {
mut:
	window        &sdl.Window   = unsafe { nil }
	renderer      &sdl.Renderer = unsafe { nil }
	game          GameEngine
	sound_mgr     SoundManager
	particles     []Particle
	mouse_x       int
	mouse_y       int
	key_left      bool
	key_right     bool
	btn_start     Button
	btn_easy      Button
	btn_norm      Button
	btn_hard      Button
	btn_next_sec  Button
	btn_buy_eng   Button
	btn_buy_load  Button
	btn_buy_hull  Button
	btn_buy_blast Button
	btn_restart   Button
	btn_sound     Button
}

fn new_app() App {
	mut app := App{
		game:          new_game_engine()
		sound_mgr:     new_sound_manager()
		btn_start:     Button{
			x:            350
			y:            480
			w:            300
			h:            52
			text:         'ENGAGE SEA PATROL'
			bg_color:     Color{
				r: 6
				g: 182
				b: 212
			}
			hover_color:  Color{
				r: 34
				g: 211
				b: 238
			}
			text_color:   Color{
				r: 15
				g: 23
				b: 42
			}
			border_color: Color{
				r: 250
				g: 204
				b: 21
			}
		}
		btn_easy:      Button{
			x:            320
			y:            400
			w:            110
			h:            40
			text:         'EASY'
			bg_color:     Color{
				r: 30
				g: 41
				b: 59
			}
			hover_color:  Color{
				r: 51
				g: 65
				b: 85
			}
			text_color:   Color{
				r: 255
				g: 255
				b: 255
			}
			border_color: Color{
				r: 71
				g: 85
				b: 105
			}
		}
		btn_norm:      Button{
			x:            445
			y:            400
			w:            110
			h:            40
			text:         'NORMAL'
			bg_color:     Color{
				r: 6
				g: 182
				b: 212
			}
			hover_color:  Color{
				r: 34
				g: 211
				b: 238
			}
			text_color:   Color{
				r: 15
				g: 23
				b: 42
			}
			border_color: Color{
				r: 250
				g: 204
				b: 21
			}
		}
		btn_hard:      Button{
			x:            570
			y:            400
			w:            110
			h:            40
			text:         'HARD'
			bg_color:     Color{
				r: 30
				g: 41
				b: 59
			}
			hover_color:  Color{
				r: 51
				g: 65
				b: 85
			}
			text_color:   Color{
				r: 255
				g: 255
				b: 255
			}
			border_color: Color{
				r: 71
				g: 85
				b: 105
			}
		}
		btn_next_sec:  Button{
			x:            320
			y:            520
			w:            360
			h:            48
			text:         'NEXT SECTOR DEPART ➡️'
			bg_color:     Color{
				r: 16
				g: 185
				b: 129
			}
			hover_color:  Color{
				r: 52
				g: 211
				b: 153
			}
			text_color:   Color{
				r: 15
				g: 23
				b: 42
			}
			border_color: Color{
				r: 250
				g: 204
				b: 21
			}
		}
		btn_buy_eng:   Button{
			x:            560
			y:            280
			w:            100
			h:            36
			text:         '$200'
			bg_color:     Color{
				r: 234
				g: 179
				b: 8
			}
			hover_color:  Color{
				r: 250
				g: 204
				b: 21
			}
			text_color:   Color{
				r: 15
				g: 23
				b: 42
			}
			border_color: Color{
				r: 255
				g: 255
				b: 255
			}
		}
		btn_buy_load:  Button{
			x:            560
			y:            335
			w:            100
			h:            36
			text:         '$250'
			bg_color:     Color{
				r: 234
				g: 179
				b: 8
			}
			hover_color:  Color{
				r: 250
				g: 204
				b: 21
			}
			text_color:   Color{
				r: 15
				g: 23
				b: 42
			}
			border_color: Color{
				r: 255
				g: 255
				b: 255
			}
		}
		btn_buy_hull:  Button{
			x:            560
			y:            390
			w:            100
			h:            36
			text:         '$300'
			bg_color:     Color{
				r: 234
				g: 179
				b: 8
			}
			hover_color:  Color{
				r: 250
				g: 204
				b: 21
			}
			text_color:   Color{
				r: 15
				g: 23
				b: 42
			}
			border_color: Color{
				r: 255
				g: 255
				b: 255
			}
		}
		btn_buy_blast: Button{
			x:            560
			y:            445
			w:            100
			h:            36
			text:         '$200'
			bg_color:     Color{
				r: 234
				g: 179
				b: 8
			}
			hover_color:  Color{
				r: 250
				g: 204
				b: 21
			}
			text_color:   Color{
				r: 15
				g: 23
				b: 42
			}
			border_color: Color{
				r: 255
				g: 255
				b: 255
			}
		}
		btn_restart:   Button{
			x:            350
			y:            500
			w:            300
			h:            48
			text:         'REDEPLOY SHIP'
			bg_color:     Color{
				r: 225
				g: 29
				b: 72
			}
			hover_color:  Color{
				r: 244
				g: 63
				b: 94
			}
			text_color:   Color{
				r: 255
				g: 255
				b: 255
			}
			border_color: Color{
				r: 250
				g: 204
				b: 21
			}
		}
		btn_sound:     Button{
			x:            820
			y:            12
			w:            160
			h:            36
			text:         'SOUND: ON [O]'
			bg_color:     Color{
				r: 30
				g: 41
				b: 59
			}
			hover_color:  Color{
				r: 51
				g: 65
				b: 85
			}
			text_color:   Color{
				r: 80
				g: 240
				b: 140
			}
			border_color: Color{
				r: 71
				g: 85
				b: 105
			}
		}
	}
	return app
}

fn (mut app App) init_sdl() bool {
	if sdl.init(sdl.init_video) < 0 {
		eprintln('Failed to initialize SDL')
		return false
	}

	app.window = sdl.create_window(c'SinkSub Pro: Tactical Overdrive - V & SDL2', sdl.windowpos_centered,
		sdl.windowpos_centered, ocean_width, ocean_height, u32(sdl.WindowFlags.shown))

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

fn (mut app App) spawn_explosion_particles(cx f64, cy f64) {
	for _ in 0 .. 20 {
		angle := rand.f64() * 6.28
		speed := 1.5 + rand.f64() * 5.0
		app.particles << Particle{
			x:     cx
			y:     cy
			vx:    math.cos(angle) * speed
			vy:    math.sin(angle) * speed
			life:  1.0
			color: Color{
				r: 245
				g: 158
				b: 11
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

fn (mut app App) handle_mouse_click(x int, y int) {
	if app.btn_sound.is_hovered(x, y) {
		is_on := app.sound_mgr.toggle_sound()
		app.btn_sound.text = if is_on { 'SOUND: ON [O]' } else { 'SOUND: OFF [O]' }
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
		return
	}

	if app.game.mode == .menu {
		if app.btn_easy.is_hovered(x, y) {
			app.game.difficulty = 'easy'
			app.btn_easy.bg_color = Color{
				r: 6
				g: 182
				b: 212
			}
			app.btn_norm.bg_color = Color{
				r: 30
				g: 41
				b: 59
			}
			app.btn_hard.bg_color = Color{
				r: 30
				g: 41
				b: 59
			}
		} else if app.btn_norm.is_hovered(x, y) {
			app.game.difficulty = 'normal'
			app.btn_easy.bg_color = Color{
				r: 30
				g: 41
				b: 59
			}
			app.btn_norm.bg_color = Color{
				r: 6
				g: 182
				b: 212
			}
			app.btn_hard.bg_color = Color{
				r: 30
				g: 41
				b: 59
			}
		} else if app.btn_hard.is_hovered(x, y) {
			app.game.difficulty = 'hard'
			app.btn_easy.bg_color = Color{
				r: 30
				g: 41
				b: 59
			}
			app.btn_norm.bg_color = Color{
				r: 30
				g: 41
				b: 59
			}
			app.btn_hard.bg_color = Color{
				r: 6
				g: 182
				b: 212
			}
		} else if app.btn_start.is_hovered(x, y) {
			app.sound_mgr.play_click_sound()
			app.game.start_new_game()
		}
	} else if app.game.mode == .shop {
		if app.btn_buy_eng.is_hovered(x, y) {
			if app.game.buy_upgrade('engine') {
				app.sound_mgr.play_powerup()
			}
		} else if app.btn_buy_load.is_hovered(x, y) {
			if app.game.buy_upgrade('loader') {
				app.sound_mgr.play_powerup()
			}
		} else if app.btn_buy_hull.is_hovered(x, y) {
			if app.game.buy_upgrade('hull') {
				app.sound_mgr.play_powerup()
			}
		} else if app.btn_buy_blast.is_hovered(x, y) {
			if app.game.buy_upgrade('blast') {
				app.sound_mgr.play_powerup()
			}
		} else if app.btn_next_sec.is_hovered(x, y) {
			app.sound_mgr.play_click_sound()
			app.game.start_sector(app.game.sector + 1)
			app.game.mode = .playing
		}
	} else if app.game.mode == .game_over {
		if app.btn_restart.is_hovered(x, y) {
			app.sound_mgr.play_click_sound()
			app.game.start_new_game()
		}
	}
}

fn (mut app App) render() {
	ticks := sdl.get_ticks()
	sdl.set_render_draw_color(app.renderer, 2, 6, 23, 255)
	sdl.render_clear(app.renderer)

	render_ocean_background(app.renderer, ticks)

	// Top Header Bar HUD
	draw_glass_card(app.renderer, 0, 0, ocean_width, 60, Color{ r: 6, g: 182, b: 212 })
	draw_text(app.renderer, 20, 18, 'SINKSUB PRO', 3, Color{ r: 34, g: 211, b: 238 })

	// HUD Stats Info
	draw_text(app.renderer, 320, 14, 'SCORE: ${app.game.score}', 2, Color{ r: 255, g: 255, b: 255 })
	draw_text(app.renderer, 320, 36, 'CREDITS: $${app.game.credits}', 2, Color{
		r: 250
		g: 204
		b: 21
	})

	draw_text(app.renderer, 550, 14, 'TARGET: ${app.game.target_killed}/${app.game.req_to_clear}',
		2, Color{ r: 52, g: 211, b: 153 })
	draw_text(app.renderer, 550, 36, 'SECTOR: ${app.game.sector}', 2, Color{ r: 96, g: 165, b: 250 })

	// Sound Button Header
	app.btn_sound.draw(app.renderer, app.mouse_x, app.mouse_y)

	// Render Entities when playing / shop
	if app.game.mode == .playing || app.game.mode == .shop {
		// Ship
		render_ship(app.renderer, app.game.ship, app.game.perks.shield > 0, ticks)

		// Depth Charges (Bevelled canister with blinking LED fuse)
		for dc in app.game.charges {
			cx := int(dc.x)
			cy := int(dc.y)
			draw_filled_circle(app.renderer, cx, cy, 6, Color{ r: 245, g: 158, b: 11 })
			draw_circle_outline(app.renderer, cx, cy, 6, 1, Color{ r: 180, g: 83, b: 9 })
			// Blinking LED fuse
			if (ticks / 100) % 2 == 0 {
				draw_filled_circle(app.renderer, cx, cy - 3, 2, Color{ r: 239, g: 68, b: 68 })
			}
		}

		// Submarines
		for sub in app.game.subs {
			render_submarine(app.renderer, sub, ticks)
		}

		// Homing Torpedoes
		for torp in app.game.torpedoes {
			tx := int(torp.x)
			ty := int(torp.y)
			draw_filled_circle(app.renderer, tx, ty, 5, Color{ r: 239, g: 68, b: 68 })
			draw_circle_outline(app.renderer, tx, ty, 5, 1, Color{ r: 255, g: 255, b: 255 })
			// Propeller bubble trail
			draw_filled_circle(app.renderer, tx, ty + 6, 2, Color{ r: 255, g: 255, b: 255, a: 180 })
		}

		// Spiked Naval Floatmines
		for mine in app.game.mines {
			mx := int(mine.x)
			my := int(mine.y)
			draw_filled_circle(app.renderer, mx, my, 6, Color{ r: 220, g: 38, b: 38 })
			draw_circle_outline(app.renderer, mx, my, 6, 1, Color{ r: 153, g: 27, b: 27 })
			// Spikes
			sdl.set_render_draw_color(app.renderer, 220, 38, 38, 255)
			sdl.render_draw_line(app.renderer, mx - 8, my, mx + 8, my)
			sdl.render_draw_line(app.renderer, mx, my - 8, mx, my + 8)
		}

		// Supply Crates
		for cr in app.game.crates {
			render_supply_crate(app.renderer, cr, ticks)
		}

		// Controls overlay hint at bottom
		draw_text_centered(app.renderer, ocean_width / 2, ocean_height - 30, 'CONTROLS: ARROWS = MOVE | Z/J = STERN CHARGE | X/K = BOW ROCKET | SPACE = NUKE',
			1, Color{ r: 148, g: 163, b: 184 })
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

	// Overlay Modals
	if app.game.mode == .menu {
		draw_glass_card(app.renderer, 250, 160, 500, 420, Color{ r: 6, g: 182, b: 212 })
		draw_text_centered(app.renderer, ocean_width / 2, 190, 'SINKSUB PRO', 3, Color{
			r: 34
			g: 211
			b: 238
		})
		draw_text_centered(app.renderer, ocean_width / 2, 230, 'TACTICAL OVERDRIVE', 2,
			Color{ r: 250, g: 204, b: 21 })

		draw_text_centered(app.renderer, ocean_width / 2, 290, 'HIGH RECORD: ${app.game.high_score}',
			2, Color{ r: 148, g: 163, b: 184 })
		draw_text_centered(app.renderer, ocean_width / 2, 350, 'SELECT DIFFICULTY:', 2,
			Color{ r: 255, g: 255, b: 255 })

		app.btn_easy.draw(app.renderer, app.mouse_x, app.mouse_y)
		app.btn_norm.draw(app.renderer, app.mouse_x, app.mouse_y)
		app.btn_hard.draw(app.renderer, app.mouse_x, app.mouse_y)
		app.btn_start.draw(app.renderer, app.mouse_x, app.mouse_y)
	} else if app.game.mode == .shop {
		draw_glass_card(app.renderer, 250, 140, 500, 460, Color{ r: 16, g: 185, b: 129 })
		draw_text_centered(app.renderer, ocean_width / 2, 165, 'SECTOR SECURED!', 3, Color{
			r: 52
			g: 211
			b: 153
		})
		draw_text_centered(app.renderer, ocean_width / 2, 210, 'UPGRADE SHOP TERMINAL',
			2, Color{ r: 250, g: 204, b: 21 })
		draw_text_centered(app.renderer, ocean_width / 2, 240, 'BUDGET: $${app.game.credits}',
			2, Color{ r: 255, g: 255, b: 255 })

		draw_text(app.renderer, 280, 290, 'ENGINE HYDRO-THRUST (Lvl ${app.game.upgrades.engine})',
			1, Color{ r: 255, g: 255, b: 255 })
		app.btn_buy_eng.draw(app.renderer, app.mouse_x, app.mouse_y)

		draw_text(app.renderer, 280, 345, 'RAPID AUTOLOADER (Lvl ${app.game.upgrades.loader})',
			1, Color{ r: 255, g: 255, b: 255 })
		app.btn_buy_load.draw(app.renderer, app.mouse_x, app.mouse_y)

		draw_text(app.renderer, 280, 400, 'ARCLITE PLATED ARMOR (${app.game.upgrades.hull} Slots)',
			1, Color{ r: 255, g: 255, b: 255 })
		app.btn_buy_hull.draw(app.renderer, app.mouse_x, app.mouse_y)

		draw_text(app.renderer, 280, 455, 'HIGH-YIELD EXPLOSIVES (Lvl ${app.game.upgrades.blast})',
			1, Color{ r: 255, g: 255, b: 255 })
		app.btn_buy_blast.draw(app.renderer, app.mouse_x, app.mouse_y)

		app.btn_next_sec.draw(app.renderer, app.mouse_x, app.mouse_y)
	} else if app.game.mode == .game_over {
		draw_glass_card(app.renderer, 250, 180, 500, 400, Color{ r: 225, g: 29, b: 72 })
		draw_text_centered(app.renderer, ocean_width / 2, 210, 'HULL BREACHED', 3, Color{
			r: 244
			g: 63
			b: 94
		})
		draw_text_centered(app.renderer, ocean_width / 2, 260, 'CORVETTE DESTROYED', 2,
			Color{ r: 255, g: 255, b: 255 })

		draw_text_centered(app.renderer, ocean_width / 2, 320, 'FINAL RANK: ${app.game.current_rank.title}',
			2, Color{ r: 250, g: 204, b: 21 })
		draw_text_centered(app.renderer, ocean_width / 2, 360, 'FINAL SCORE: ${app.game.score}',
			2, Color{ r: 34, g: 211, b: 238 })
		draw_text_centered(app.renderer, ocean_width / 2, 400, 'SURVIVED: SECTOR ${app.game.sector}',
			2, Color{ r: 148, g: 163, b: 184 })

		app.btn_restart.draw(app.renderer, app.mouse_x, app.mouse_y)
	}

	sdl.render_present(app.renderer)
}

fn (mut app App) run() {
	mut should_close := false

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
					now := sdl.get_ticks()
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = true
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = true
					} else if sym == int(sdl.KeyCode.z) || sym == int(sdl.KeyCode.j) {
						if app.game.mode == .playing && app.game.drop_stern_charge(now) {
							app.sound_mgr.play_launch()
						}
					} else if sym == int(sdl.KeyCode.x) || sym == int(sdl.KeyCode.k) {
						if app.game.mode == .playing && app.game.throw_bow_charge(now) {
							app.sound_mgr.play_launch()
						}
					} else if sym == int(sdl.KeyCode.space) {
						if app.game.mode == .playing && app.game.trigger_nuke() {
							app.sound_mgr.play_nuke()
						}
					} else if sym == int(sdl.KeyCode.o) {
						is_on := app.sound_mgr.toggle_sound()
						app.btn_sound.text = if is_on { 'SOUND: ON [O]' } else { 'SOUND: OFF [O]' }
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
					} else if sym == int(sdl.KeyCode.escape) {
						should_close = true
					}
				}
				.keyup {
					sym := evt.key.keysym.sym
					if sym == int(sdl.KeyCode.left) || sym == int(sdl.KeyCode.a) {
						app.key_left = false
					} else if sym == int(sdl.KeyCode.right) || sym == int(sdl.KeyCode.d) {
						app.key_right = false
					}
				}
				else {}
			}
		}

		_, exploded, powerup := app.game.update_step(app.key_left, app.key_right)
		if exploded {
			app.sound_mgr.play_explosion(true)
		}
		if powerup {
			app.sound_mgr.play_powerup()
		}

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
