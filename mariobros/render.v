module main

import math
import sdl

pub fn render_mario_bros_game(renderer &sdl.Renderer, mut g MarioBrosGame) {
	// 1. Arcade Deep Sewer Background with Brick Mortar & Steam
	render_sewer_background(renderer)

	ox := int(g.shake_offset_x)
	oy := int(g.shake_offset_y)

	// 2. Draw Sewer Pipes (Top and Bottom Left/Right) with metallic collars & steam
	render_pipes(renderer, ox, oy)

	// 3. Draw Water Drips
	render_water_drips(renderer, mut g, ox, oy)

	// 4. Draw Multi-Tier Platforms with dynamic Bump Ripples & Brick Texture
	render_platforms(renderer, mut g, ox, oy)

	// 5. Draw Expanding POW Shockwaves
	render_shockwaves(renderer, mut g, ox, oy)

	// 6. Draw POW Block with 3D Bevel, Neon Glow & Fracture Cracks
	render_pow_block(renderer, mut g, ox, oy)

	// 7. Draw Coins with 3D Shimmering & Sparkles
	render_coins(renderer, mut g, ox, oy)

	// 8. Draw Enemies with Articulated Limbs & Animations
	render_enemies(renderer, mut g, ox, oy)

	// 9. Draw Players (Mario & Luigi) with detailed hats, overalls & dust
	render_players(renderer, mut g, ox, oy)

	// 10. Draw Particles
	render_particles(renderer, mut g, ox, oy)

	// 11. Draw Floating Score Popups
	render_score_popups(renderer, mut g, ox, oy)

	// 12. Draw In-Game Alerts (Phase Ready Banner & Combo Banners)
	render_gameplay_banners(renderer, mut g)

	// 13. Draw Arcade Top HUD & Lives Counters
	render_hud(renderer, mut g)

	// 14. Draw CRT Scanlines & Bezel Vignette
	if g.crt_filter {
		render_crt_overlay(renderer)
	}

	// 15. Draw Game State Overlays (Title, Paused, Phase Clear, Game Over)
	if g.state == .title {
		render_title_screen(renderer, mut g)
	} else if g.state == .paused {
		render_paused_screen(renderer)
	} else if g.state == .phase_clear {
		render_phase_clear_screen(renderer, mut g)
	} else if g.state == .game_over {
		render_game_over_screen(renderer, mut g)
	}
}

fn render_sewer_background(renderer &sdl.Renderer) {
	// Deep arcade sewer navy-black base
	sdl.set_render_draw_color(renderer, 8, 10, 18, 255)
	sdl.render_clear(renderer)

	// Subtle masonry brick grid in background
	sdl.set_render_draw_color(renderer, 14, 18, 30, 255)
	for row := 0; row < 15; row++ {
		y := row * 40
		sdl.render_draw_line(renderer, 0, y, 800, y)
		x_off := if row % 2 == 0 { 0 } else { 40 }
		for col := 0; col < 11; col++ {
			x := col * 80 + x_off
			sdl.render_draw_line(renderer, x, y, x, y + 40)
		}
	}
}

fn render_pipes(renderer &sdl.Renderer, ox int, oy int) {
	// Vibrant sewer pipe palette
	dark_green := Color{ r: 16, g: 90, b: 24, a: 255 }
	mid_green := Color{ r: 35, g: 160, b: 45, a: 255 }
	light_green := Color{ r: 90, g: 235, b: 90, a: 255 }
	mouth_black := Color{ r: 4, g: 12, b: 6, a: 255 }
	flange_c := Color{ r: 50, g: 195, b: 65, a: 255 }
	rivet_c := Color{ r: 180, g: 255, b: 180, a: 255 }

	// Top Left Pipe (X: 0..86, Y: 76..134)
	draw_pipe_horizontal(renderer, ox + 0, oy + 76, 86, 56, false, dark_green, mid_green, light_green, mouth_black, flange_c, rivet_c)

	// Top Right Pipe (X: 714..800, Y: 76..134)
	draw_pipe_horizontal(renderer, ox + 714, oy + 76, 86, 56, true, dark_green, mid_green, light_green, mouth_black, flange_c, rivet_c)

	// Bottom Left Pipe (X: 0..86, Y: 484..540)
	draw_pipe_horizontal(renderer, ox + 0, oy + 484, 86, 56, false, dark_green, mid_green, light_green, mouth_black, flange_c, rivet_c)

	// Bottom Right Pipe (X: 714..800, Y: 484..540)
	draw_pipe_horizontal(renderer, ox + 714, oy + 484, 86, 56, true, dark_green, mid_green, light_green, mouth_black, flange_c, rivet_c)
}

fn draw_pipe_horizontal(renderer &sdl.Renderer, x int, y int, w int, h int, is_right bool,
	dark Color, mid Color, light Color, mouth Color, flange Color, rivet Color) {
	// Pipe stem
	stem_x := if is_right { x + 26 } else { x }
	stem_w := w - 26
	stem_rect := sdl.Rect{ x: stem_x, y: y + 6, w: stem_w, h: h - 12 }
	sdl.set_render_draw_color(renderer, mid.r, mid.g, mid.b, 255)
	sdl.render_fill_rect(renderer, &stem_rect)

	// Highlight stripe along top edge
	hl_rect := sdl.Rect{ x: stem_x, y: y + 10, w: stem_w, h: 7 }
	sdl.set_render_draw_color(renderer, light.r, light.g, light.b, 255)
	sdl.render_fill_rect(renderer, &hl_rect)

	// Shadow stripe along bottom edge
	sd_rect := sdl.Rect{ x: stem_x, y: y + h - 16, w: stem_w, h: 9 }
	sdl.set_render_draw_color(renderer, dark.r, dark.g, dark.b, 255)
	sdl.render_fill_rect(renderer, &sd_rect)

	// Outer pipe collar / flange
	flange_x := if is_right { x } else { x + w - 26 }
	flange_rect := sdl.Rect{ x: flange_x, y: y, w: 26, h: h }
	sdl.set_render_draw_color(renderer, flange.r, flange.g, flange.b, 255)
	sdl.render_fill_rect(renderer, &flange_rect)

	flange_hl := sdl.Rect{ x: flange_x + 3, y: y + 4, w: 20, h: 7 }
	sdl.set_render_draw_color(renderer, light.r, light.g, light.b, 255)
	sdl.render_fill_rect(renderer, &flange_hl)

	flange_sd := sdl.Rect{ x: flange_x + 3, y: y + h - 12, w: 20, h: 8 }
	sdl.set_render_draw_color(renderer, dark.r, dark.g, dark.b, 255)
	sdl.render_fill_rect(renderer, &flange_sd)

	// Metallic Rivets on flange
	sdl.set_render_draw_color(renderer, rivet.r, rivet.g, rivet.b, 255)
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: flange_x + 11, y: y + 6, w: 4, h: 4 })
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: flange_x + 11, y: y + h / 2 - 2, w: 4, h: 4 })
	sdl.render_fill_rect(renderer, &sdl.Rect{ x: flange_x + 11, y: y + h - 10, w: 4, h: 4 })

	// Inner dark pipe mouth
	mouth_x := if is_right { x } else { x + w - 8 }
	mouth_rect := sdl.Rect{ x: mouth_x, y: y + 4, w: 8, h: h - 8 }
	sdl.set_render_draw_color(renderer, mouth.r, mouth.g, mouth.b, 255)
	sdl.render_fill_rect(renderer, &mouth_rect)
}

fn render_water_drips(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	sdl.set_render_draw_color(renderer, 90, 200, 255, 220)
	for d in g.water_drips {
		if !d.active {
			continue
		}
		dx := int(d.x) + ox
		dy := int(d.y) + oy
		rect := sdl.Rect{ x: dx, y: dy, w: 3, h: 7 }
		sdl.render_fill_rect(renderer, &rect)
	}
}

fn render_platforms(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	for plat in g.platforms {
		px := int(plat.x) + ox
		py := int(plat.y) + oy
		pw := int(plat.w)
		ph := int(plat.h)

		// Ground Floor (Sewer drain curb with iron grating & bottom water flow)
		if ph > 30 {
			// Sewer base curb
			sdl.set_render_draw_color(renderer, 20, 65, 110, 255)
			base_rect := sdl.Rect{ x: px, y: py, w: pw, h: ph }
			sdl.render_fill_rect(renderer, &base_rect)

			// Top curb bright cyan highlight strip
			sdl.set_render_draw_color(renderer, 60, 160, 245, 255)
			top_line := sdl.Rect{ x: px, y: py, w: pw, h: 6 }
			sdl.render_fill_rect(renderer, &top_line)

			// Iron drainage grating lines
			sdl.set_render_draw_color(renderer, 12, 40, 75, 255)
			for gx := px; gx < px + pw; gx += 20 {
				sdl.render_draw_line(renderer, gx, py + 6, gx, py + ph)
			}

			// Subtle flowing bottom sewer water stream
			water_glow := int((math.sin(f64(sdl.get_ticks()) / 250.0) + 1.0) * 20.0)
			sdl.set_render_draw_color(renderer, 15, u8(70 + water_glow), u8(130 + water_glow), 255)
			water_rect := sdl.Rect{ x: px, y: py + ph - 8, w: pw, h: 8 }
			sdl.render_fill_rect(renderer, &water_rect)
			continue
		}

		// Floating Multi-Tier Platforms with dynamic Sinusoidal Bumping & Brick Lattice
		for step_x := px; step_x < px + pw; step_x += 16 {
			bw := int(math.min(16, (px + pw) - step_x))

			// Calculate bump wave upward offset for this segment
			mut bump_disp := f32(0.0)
			for wave in g.bump_waves {
				if wave.active {
					dist := math.abs(f32(step_x + bw / 2) - wave.x)
					if dist < wave.radius {
						progress := wave.timer / wave.duration
						bump_amount := f32(math.sin(f64((1.0 - progress) * f32(math.pi))) * 16.0)
						falloff := 1.0 - (dist / wave.radius)
						bump_val := bump_amount * falloff
						if bump_val > bump_disp {
							bump_disp = bump_val
						}
					}
				}
			}

			disp_y := py - int(bump_disp)

			// Platform body (Vibrant arcade Cyan-Blue)
			plat_rect := sdl.Rect{ x: step_x, y: disp_y, w: bw, h: ph }
			sdl.set_render_draw_color(renderer, 28, 92, 160, 255)
			sdl.render_fill_rect(renderer, &plat_rect)

			// Top neon highlight ridge
			top_rect := sdl.Rect{ x: step_x, y: disp_y, w: bw, h: 4 }
			sdl.set_render_draw_color(renderer, 100, 200, 255, 255)
			sdl.render_fill_rect(renderer, &top_rect)

			// Brick bevel & mortar division lines
			sdl.set_render_draw_color(renderer, 14, 48, 90, 255)
			sdl.render_draw_line(renderer, step_x, disp_y, step_x, disp_y + ph)
			sdl.render_draw_line(renderer, step_x, disp_y + ph / 2, step_x + bw, disp_y + ph / 2)

			// Under-rail dark support shadow
			sdl.set_render_draw_color(renderer, 8, 22, 45, 255)
			sdl.render_draw_line(renderer, step_x, disp_y + ph, step_x + bw, disp_y + ph)
		}
	}
}

fn render_shockwaves(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	for sw in g.shockwaves {
		if !sw.active {
			continue
		}
		cx := int(sw.x) + ox
		cy := int(sw.y) + oy
		r := int(sw.radius)

		alpha := u8(math.max(0.0, f64(sw.timer / sw.duration) * 255.0))
		sdl.set_render_draw_blend_mode(renderer, .blend)
		sdl.set_render_draw_color(renderer, sw.color.r, sw.color.g, sw.color.b, alpha)

		// Draw concentric shockwave rings
		for ring_off in -2 .. 3 {
			draw_circle_wire(renderer, cx, cy, r + ring_off)
		}
	}
}

fn draw_circle_wire(renderer &sdl.Renderer, cx int, cy int, radius int) {
	if radius <= 0 {
		return
	}
	mut x := radius
	mut y := 0
	mut err := 0

	for x >= y {
		sdl.render_draw_point(renderer, cx + x, cy + y)
		sdl.render_draw_point(renderer, cx + y, cy + x)
		sdl.render_draw_point(renderer, cx - y, cy + x)
		sdl.render_draw_point(renderer, cx - x, cy + y)
		sdl.render_draw_point(renderer, cx - x, cy - y)
		sdl.render_draw_point(renderer, cx - y, cy - x)
		sdl.render_draw_point(renderer, cx + y, cy - x)
		sdl.render_draw_point(renderer, cx + x, cy - y)

		if err <= 0 {
			y += 1
			err += 2 * y + 1
		}
		if err > 0 {
			x -= 1
			err -= 2 * x + 1
		}
	}
}

fn render_pow_block(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	if !g.pow_block.active || g.pow_block.hits_left <= 0 {
		return
	}

	bx := int(g.pow_block.x) + ox
	by := int(g.pow_block.y) + oy
	bw := int(g.pow_block.w)
	bh := int(g.pow_block.h)

	// Shaking offset if recently struck
	shake_y := if g.pow_block.shake_timer > 0.0 {
		int(math.sin(f64(g.pow_block.shake_timer * 35.0)) * 5.0)
	} else {
		0
	}

	// Dynamic block color based on remaining hits (Electric Blue -> Bright Orange -> Fiery Red)
	base_color := match g.pow_block.hits_left {
		3 { Color{ r: 35, g: 125, b: 245, a: 255 } }
		2 { Color{ r: 240, g: 140, b: 25, a: 255 } }
		else { Color{ r: 245, g: 45, b: 35, a: 255 } }
	}

	top_color := match g.pow_block.hits_left {
		3 { Color{ r: 130, g: 200, b: 255, a: 255 } }
		2 { Color{ r: 255, g: 210, b: 110, a: 255 } }
		else { Color{ r: 255, g: 140, b: 130, a: 255 } }
	}

	// Outer ambient neon glow halo
	sdl.set_render_draw_blend_mode(renderer, .blend)
	sdl.set_render_draw_color(renderer, top_color.r, top_color.g, top_color.b, 60)
	glow_rect := sdl.Rect{ x: bx - 4, y: by + shake_y - 4, w: bw + 8, h: bh + 8 }
	sdl.render_fill_rect(renderer, &glow_rect)

	// 3D Block Base
	sdl.set_render_draw_blend_mode(renderer, .none)
	block_rect := sdl.Rect{ x: bx, y: by + shake_y, w: bw, h: bh }
	sdl.set_render_draw_color(renderer, base_color.r, base_color.g, base_color.b, 255)
	sdl.render_fill_rect(renderer, &block_rect)

	// Top beveled highlight strip
	top_rect := sdl.Rect{ x: bx, y: by + shake_y, w: bw, h: 6 }
	sdl.set_render_draw_color(renderer, top_color.r, top_color.g, top_color.b, 255)
	sdl.render_fill_rect(renderer, &top_rect)

	// Outer crisp white border
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	border := sdl.Rect{ x: bx, y: by + shake_y, w: bw, h: bh }
	sdl.render_draw_rect(renderer, &border)

	// Fracture Cracks for damaged hits
	if g.pow_block.hits_left <= 2 {
		sdl.set_render_draw_color(renderer, 15, 15, 20, 255)
		sdl.render_draw_line(renderer, bx + 12, by + shake_y + 2, bx + 18, by + shake_y + 16)
		sdl.render_draw_line(renderer, bx + 18, by + shake_y + 16, bx + 14, by + shake_y + bh - 4)
	}
	if g.pow_block.hits_left == 1 {
		sdl.set_render_draw_color(renderer, 15, 15, 20, 255)
		sdl.render_draw_line(renderer, bx + bw - 14, by + shake_y + 2, bx + bw - 20, by + shake_y + 18)
		sdl.render_draw_line(renderer, bx + bw - 20, by + shake_y + 18, bx + bw - 12, by + shake_y + bh - 4)
	}

	// "POW" text in bold center
	draw_text_centered_shadow(renderer, bx + bw / 2, by + shake_y + 8, 'POW', 2,
		Color{ r: 255, g: 255, b: 255, a: 255 }, Color{ r: 10, g: 10, b: 25, a: 255 })
}

fn render_coins(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	for c in g.coins {
		if !c.active {
			continue
		}
		cx := int(c.x) + ox
		cy := int(c.y) + oy

		// Animated coin spin width
		spin := math.abs(math.cos(f64(c.anim_timer)))
		cw := int(math.max(4.0, f64(c.width) * spin))
		ch := int(c.height)
		coin_x := cx + (int(c.width) - cw) / 2

		// Gold outer rim
		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		coin_rect := sdl.Rect{ x: coin_x, y: cy, w: cw, h: ch }
		sdl.render_fill_rect(renderer, &coin_rect)

		// Inner sparkle
		if cw > 8 {
			sdl.set_render_draw_color(renderer, 255, 250, 180, 255)
			inner := sdl.Rect{ x: coin_x + 3, y: cy + 3, w: cw - 6, h: ch - 6 }
			sdl.render_fill_rect(renderer, &inner)

			// Coin vertical slot
			sdl.set_render_draw_color(renderer, 190, 140, 10, 255)
			slot := sdl.Rect{ x: coin_x + cw / 2 - 1, y: cy + 5, w: 2, h: ch - 10 }
			sdl.render_fill_rect(renderer, &slot)
		}
	}
}

fn render_enemies(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	for e in g.enemies {
		if !e.active || e.state == .in_pipe {
			continue
		}
		ex := int(e.x) + ox
		ey := int(e.y) + oy
		ew := int(e.width)
		eh := int(e.height)

		match e.enemy_type {
			.shellcreeper {
				render_shellcreeper(renderer, ex, ey, ew, eh, e.state, e.facing_right, e.stun_timer)
			}
			.sidestepper {
				render_sidestepper(renderer, ex, ey, ew, eh, e.state, e.stun_timer, e.angry_level)
			}
			.fighterfly {
				render_fighterfly(renderer, ex, ey, ew, eh, e.state, e.stun_timer, e.hop_timer)
			}
			.slipice {
				render_slipice(renderer, ex, ey, ew, eh)
			}
			.fireball {
				render_fireball(renderer, ex, ey, ew, eh)
			}
		}
	}
}

fn render_shellcreeper(renderer &sdl.Renderer, x int, y int, w int, h int, state EnemyState, facing_right bool, stun_timer f32) {
	is_flipped := state == .stunned || state == .recovering || state == .kicked
	is_recovering := state == .recovering
	flash := is_recovering && (int(stun_timer * 15.0) % 2 == 0)

	if is_flipped {
		// Flipped shell with legs wiggling on top
		shell_color := if flash { Color{ r: 255, g: 50, b: 50, a: 255 } } else { Color{ r: 220, g: 190, b: 60, a: 255 } }
		sdl.set_render_draw_color(renderer, shell_color.r, shell_color.g, shell_color.b, 255)
		shell := sdl.Rect{ x: x + 2, y: y + 10, w: w - 4, h: h - 10 }
		sdl.render_fill_rect(renderer, &shell)

		// Shell underbelly rim
		sdl.set_render_draw_color(renderer, 160, 120, 20, 255)
		rim := sdl.Rect{ x: x, y: y + 10, w: w, h: 4 }
		sdl.render_fill_rect(renderer, &rim)

		// 4 Animated wiggling legs pointing UP
		leg_c := if flash { Color{ r: 255, g: 255, b: 255, a: 255 } } else { Color{ r: 70, g: 190, b: 40, a: 255 } }
		sdl.set_render_draw_color(renderer, leg_c.r, leg_c.g, leg_c.b, 255)
		wiggle := int(math.sin(f64(stun_timer * 20.0)) * 3.0)

		l1 := sdl.Rect{ x: x + 4, y: y + 2 + wiggle, w: 4, h: 8 }
		l2 := sdl.Rect{ x: x + 10, y: y + 2 - wiggle, w: 4, h: 8 }
		l3 := sdl.Rect{ x: x + 16, y: y + 2 + wiggle, w: 4, h: 8 }
		l4 := sdl.Rect{ x: x + 22, y: y + 2 - wiggle, w: 4, h: 8 }
		sdl.render_fill_rect(renderer, &l1)
		sdl.render_fill_rect(renderer, &l2)
		sdl.render_fill_rect(renderer, &l3)
		sdl.render_fill_rect(renderer, &l4)
		return
	}

	// Upright walking turtle
	// Green Shell dome
	sdl.set_render_draw_color(renderer, 50, 180, 50, 255)
	shell := sdl.Rect{ x: x + 4, y: y + 4, w: w - 8, h: h - 10 }
	sdl.render_fill_rect(renderer, &shell)

	// Shell highlights
	sdl.set_render_draw_color(renderer, 120, 230, 90, 255)
	sh_top := sdl.Rect{ x: x + 8, y: y + 6, w: w - 16, h: 4 }
	sdl.render_fill_rect(renderer, &sh_top)

	// Head
	hx := if facing_right { x + w - 8 } else { x }
	sdl.set_render_draw_color(renderer, 220, 170, 70, 255)
	head := sdl.Rect{ x: hx, y: y + 8, w: 8, h: 10 }
	sdl.render_fill_rect(renderer, &head)

	// Turtle Eye
	eye_x := if facing_right { hx + 5 } else { hx + 1 }
	sdl.set_render_draw_color(renderer, 10, 10, 10, 255)
	eye := sdl.Rect{ x: eye_x, y: y + 10, w: 2, h: 3 }
	sdl.render_fill_rect(renderer, &eye)

	// Walking Feet
	sdl.set_render_draw_color(renderer, 220, 170, 70, 255)
	foot1 := sdl.Rect{ x: x + 4, y: y + h - 6, w: 7, h: 6 }
	foot2 := sdl.Rect{ x: x + w - 11, y: y + h - 6, w: 7, h: 6 }
	sdl.render_fill_rect(renderer, &foot1)
	sdl.render_fill_rect(renderer, &foot2)
}

fn render_sidestepper(renderer &sdl.Renderer, x int, y int, w int, h int, state EnemyState, stun_timer f32, angry int) {
	is_flipped := state == .stunned || state == .recovering || state == .kicked
	is_angry := state == .angry || angry > 0
	is_recovering := state == .recovering
	flash := is_recovering && (int(stun_timer * 15.0) % 2 == 0)

	crab_color := if is_angry {
		Color{ r: 240, g: 30, b: 30, a: 255 }
	} else if flash {
		Color{ r: 255, g: 255, b: 255, a: 255 }
	} else {
		Color{ r: 240, g: 120, b: 20, a: 255 }
	}

	if is_flipped {
		// Flipped crab shell
		sdl.set_render_draw_color(renderer, 230, 200, 120, 255)
		belly := sdl.Rect{ x: x + 2, y: y + 10, w: w - 4, h: h - 10 }
		sdl.render_fill_rect(renderer, &belly)

		// Twitching claws pointing UP
		sdl.set_render_draw_color(renderer, crab_color.r, crab_color.g, crab_color.b, 255)
		c1 := sdl.Rect{ x: x + 2, y: y + 2, w: 6, h: 8 }
		c2 := sdl.Rect{ x: x + w - 8, y: y + 2, w: 6, h: 8 }
		sdl.render_fill_rect(renderer, &c1)
		sdl.render_fill_rect(renderer, &c2)
		return
	}

	// Crab Main Body
	sdl.set_render_draw_color(renderer, crab_color.r, crab_color.g, crab_color.b, 255)
	body := sdl.Rect{ x: x + 4, y: y + 8, w: w - 8, h: h - 14 }
	sdl.render_fill_rect(renderer, &body)

	// Crab Large Snapping Claws (Left & Right)
	claw_l := sdl.Rect{ x: x, y: y + 2, w: 7, h: 10 }
	claw_r := sdl.Rect{ x: x + w - 7, y: y + 2, w: 7, h: 10 }
	sdl.render_fill_rect(renderer, &claw_l)
	sdl.render_fill_rect(renderer, &claw_r)

	// Eyestalks
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	eye1 := sdl.Rect{ x: x + 8, y: y + 4, w: 4, h: 5 }
	eye2 := sdl.Rect{ x: x + w - 12, y: y + 4, w: 4, h: 5 }
	sdl.render_fill_rect(renderer, &eye1)
	sdl.render_fill_rect(renderer, &eye2)

	// Pupils
	sdl.set_render_draw_color(renderer, 10, 10, 10, 255)
	pup1 := sdl.Rect{ x: x + 9, y: y + 5, w: 2, h: 3 }
	pup2 := sdl.Rect{ x: x + w - 11, y: y + 5, w: 2, h: 3 }
	sdl.render_fill_rect(renderer, &pup1)
	sdl.render_fill_rect(renderer, &pup2)

	// Skittering Legs
	sdl.set_render_draw_color(renderer, crab_color.r, crab_color.g, crab_color.b, 255)
	for lx := 0; lx < 4; lx++ {
		leg := sdl.Rect{ x: x + 3 + lx * 6, y: y + h - 6, w: 3, h: 6 }
		sdl.render_fill_rect(renderer, &leg)
	}
}

fn render_fighterfly(renderer &sdl.Renderer, x int, y int, w int, h int, state EnemyState, stun_timer f32, hop_timer f32) {
	is_flipped := state == .stunned || state == .recovering || state == .kicked
	is_recovering := state == .recovering
	flash := is_recovering && (int(stun_timer * 15.0) % 2 == 0)

	if is_flipped {
		sdl.set_render_draw_color(renderer, 150, 100, 220, 255)
		body := sdl.Rect{ x: x + 4, y: y + 10, w: w - 8, h: h - 10 }
		sdl.render_fill_rect(renderer, &body)

		// Twitching legs UP
		leg_c := if flash { Color{ r: 255, g: 255, b: 255, a: 255 } } else { Color{ r: 230, g: 180, b: 40, a: 255 } }
		sdl.set_render_draw_color(renderer, leg_c.r, leg_c.g, leg_c.b, 255)
		l1 := sdl.Rect{ x: x + 6, y: y + 2, w: 4, h: 8 }
		l2 := sdl.Rect{ x: x + w - 10, y: y + 2, w: 4, h: 8 }
		sdl.render_fill_rect(renderer, &l1)
		sdl.render_fill_rect(renderer, &l2)
		return
	}

	// Fighter Fly Body (Purple / Blue)
	sdl.set_render_draw_color(renderer, 80, 70, 200, 255)
	body := sdl.Rect{ x: x + 6, y: y + 8, w: w - 12, h: h - 14 }
	sdl.render_fill_rect(renderer, &body)

	// Flapping Translucent Wings
	sdl.set_render_draw_color(renderer, 200, 220, 255, 220)
	wing_y := if int(hop_timer * 20.0) % 2 == 0 { y + 2 } else { y + 6 }
	w_left := sdl.Rect{ x: x, y: wing_y, w: 7, h: 6 }
	w_right := sdl.Rect{ x: x + w - 7, y: wing_y, w: 7, h: 6 }
	sdl.render_fill_rect(renderer, &w_left)
	sdl.render_fill_rect(renderer, &w_right)

	// Large Red Bug Eyes
	sdl.set_render_draw_color(renderer, 240, 40, 40, 255)
	e1 := sdl.Rect{ x: x + 7, y: y + 7, w: 4, h: 5 }
	e2 := sdl.Rect{ x: x + w - 11, y: y + 7, w: 4, h: 5 }
	sdl.render_fill_rect(renderer, &e1)
	sdl.render_fill_rect(renderer, &e2)

	// Hopping Yellow Feet
	sdl.set_render_draw_color(renderer, 240, 210, 40, 255)
	f1 := sdl.Rect{ x: x + 6, y: y + h - 6, w: 5, h: 6 }
	f2 := sdl.Rect{ x: x + w - 11, y: y + h - 6, w: 5, h: 6 }
	sdl.render_fill_rect(renderer, &f1)
	sdl.render_fill_rect(renderer, &f2)
}

fn render_slipice(renderer &sdl.Renderer, x int, y int, w int, h int) {
	// Crystal diamond shape
	sdl.set_render_draw_color(renderer, 140, 230, 255, 255)
	core := sdl.Rect{ x: x + 4, y: y + 4, w: w - 8, h: h - 8 }
	sdl.render_fill_rect(renderer, &core)

	// Bright frosted center
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	frost := sdl.Rect{ x: x + 8, y: y + 8, w: w - 16, h: h - 16 }
	sdl.render_fill_rect(renderer, &frost)
}

fn render_fireball(renderer &sdl.Renderer, x int, y int, w int, h int) {
	// Outer fiery orange corona
	sdl.set_render_draw_color(renderer, 255, 100, 20, 255)
	corona := sdl.Rect{ x: x + 2, y: y + 2, w: w - 4, h: h - 4 }
	sdl.render_fill_rect(renderer, &corona)

	// Inner yellow hot core
	sdl.set_render_draw_color(renderer, 255, 240, 40, 255)
	core := sdl.Rect{ x: x + 6, y: y + 6, w: w - 12, h: h - 12 }
	sdl.render_fill_rect(renderer, &core)

	// Center white flame
	sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
	center := sdl.Rect{ x: x + 10, y: y + 10, w: w - 20, h: h - 20 }
	sdl.render_fill_rect(renderer, &center)
}

fn render_players(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	for p in g.players {
		px := int(p.x) + ox
		py := int(p.y) + oy
		pw := int(p.width)
		ph := int(p.height)

		// Invulnerability flashing
		if p.invuln_timer > 0.0 && (int(p.invuln_timer * 18.0) % 2 == 0) {
			continue
		}

		is_mario := p.id == 1
		shirt_c := if is_mario { Color{ r: 240, g: 30, b: 30, a: 255 } } else { Color{ r: 40, g: 200, b: 40, a: 255 } }
		cap_c := if is_mario { Color{ r: 240, g: 30, b: 30, a: 255 } } else { Color{ r: 40, g: 200, b: 40, a: 255 } }
		overalls_c := if is_mario { Color{ r: 30, g: 90, b: 230, a: 255 } } else { Color{ r: 240, g: 240, b: 240, a: 255 } }
		skin_c := Color{ r: 255, g: 195, b: 140, a: 255 }
		brown_c := Color{ r: 120, g: 60, b: 20, a: 255 }

		// Dead spinning pose
		if p.is_dead {
			// Cap
			sdl.set_render_draw_color(renderer, cap_c.r, cap_c.g, cap_c.b, 255)
			c_rect := sdl.Rect{ x: px + 4, y: py + 22, w: pw - 8, h: 8 }
			sdl.render_fill_rect(renderer, &c_rect)
			// Face
			sdl.set_render_draw_color(renderer, skin_c.r, skin_c.g, skin_c.b, 255)
			f_rect := sdl.Rect{ x: px + 6, y: py + 14, w: pw - 12, h: 8 }
			sdl.render_fill_rect(renderer, &f_rect)
			// Overalls
			sdl.set_render_draw_color(renderer, overalls_c.r, overalls_c.g, overalls_c.b, 255)
			o_rect := sdl.Rect{ x: px + 4, y: py + 4, w: pw - 8, h: 10 }
			sdl.render_fill_rect(renderer, &o_rect)
			continue
		}

		// 1. Cap & Visor
		sdl.set_render_draw_color(renderer, cap_c.r, cap_c.g, cap_c.b, 255)
		cap_main := sdl.Rect{ x: px + 4, y: py, w: pw - 8, h: 7 }
		sdl.render_fill_rect(renderer, &cap_main)

		visor_x := if p.facing_right { px + pw - 8 } else { px }
		visor := sdl.Rect{ x: visor_x, y: py + 4, w: 8, h: 4 }
		sdl.render_fill_rect(renderer, &visor)

		// 2. Head / Face
		sdl.set_render_draw_color(renderer, skin_c.r, skin_c.g, skin_c.b, 255)
		face := sdl.Rect{ x: px + 6, y: py + 7, w: pw - 12, h: 9 }
		sdl.render_fill_rect(renderer, &face)

		// Nose
		nose_x := if p.facing_right { px + pw - 6 } else { px + 2 }
		nose := sdl.Rect{ x: nose_x, y: py + 9, w: 5, h: 4 }
		sdl.render_fill_rect(renderer, &nose)

		// Mustache & Eye
		sdl.set_render_draw_color(renderer, brown_c.r, brown_c.g, brown_c.b, 255)
		mustache_x := if p.facing_right { px + pw - 9 } else { px + 3 }
		mustache := sdl.Rect{ x: mustache_x, y: py + 12, w: 7, h: 4 }
		sdl.render_fill_rect(renderer, &mustache)

		eye_x := if p.facing_right { px + pw - 9 } else { px + 7 }
		eye := sdl.Rect{ x: eye_x, y: py + 8, w: 2, h: 3 }
		sdl.render_fill_rect(renderer, &eye)

		// 3. Shirt & Torso
		sdl.set_render_draw_color(renderer, shirt_c.r, shirt_c.g, shirt_c.b, 255)
		shirt := sdl.Rect{ x: px + 4, y: py + 16, w: pw - 8, h: 8 }
		sdl.render_fill_rect(renderer, &shirt)

		// Raised arm in jumping pose
		if p.is_jumping {
			arm_x := if p.facing_right { px + pw - 5 } else { px }
			arm := sdl.Rect{ x: arm_x, y: py + 8, w: 5, h: 10 }
			sdl.render_fill_rect(renderer, &arm)
			// White Glove
			sdl.set_render_draw_color(renderer, 255, 255, 255, 255)
			glove := sdl.Rect{ x: arm_x, y: py + 4, w: 5, h: 5 }
			sdl.render_fill_rect(renderer, &glove)
		}

		// 4. Overalls
		sdl.set_render_draw_color(renderer, overalls_c.r, overalls_c.g, overalls_c.b, 255)
		overalls := sdl.Rect{ x: px + 5, y: py + 20, w: pw - 10, h: 10 }
		sdl.render_fill_rect(renderer, &overalls)

		// Yellow overall buttons
		sdl.set_render_draw_color(renderer, 255, 230, 40, 255)
		btn1 := sdl.Rect{ x: px + 7, y: py + 21, w: 2, h: 2 }
		btn2 := sdl.Rect{ x: px + pw - 9, y: py + 21, w: 2, h: 2 }
		sdl.render_fill_rect(renderer, &btn1)
		sdl.render_fill_rect(renderer, &btn2)

		// 5. Shoes (Animated running / jumping / skidding)
		sdl.set_render_draw_color(renderer, brown_c.r, brown_c.g, brown_c.b, 255)
		if p.is_jumping {
			shoe1 := sdl.Rect{ x: px + 3, y: py + ph - 8, w: 8, h: 6 }
			shoe2 := sdl.Rect{ x: px + pw - 11, y: py + ph - 6, w: 8, h: 6 }
			sdl.render_fill_rect(renderer, &shoe1)
			sdl.render_fill_rect(renderer, &shoe2)
		} else if p.walk_frame % 2 == 1 {
			shoe1 := sdl.Rect{ x: px + 2, y: py + ph - 6, w: 9, h: 6 }
			shoe2 := sdl.Rect{ x: px + pw - 9, y: py + ph - 8, w: 8, h: 6 }
			sdl.render_fill_rect(renderer, &shoe1)
			sdl.render_fill_rect(renderer, &shoe2)
		} else {
			shoe1 := sdl.Rect{ x: px + 4, y: py + ph - 6, w: 8, h: 6 }
			shoe2 := sdl.Rect{ x: px + pw - 12, y: py + ph - 6, w: 8, h: 6 }
			sdl.render_fill_rect(renderer, &shoe1)
			sdl.render_fill_rect(renderer, &shoe2)
		}
	}
}

fn render_particles(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	for pt in g.particles {
		if !pt.active {
			continue
		}
		sdl.set_render_draw_color(renderer, pt.color.r, pt.color.g, pt.color.b, pt.color.a)
		rect := sdl.Rect{
			x: int(pt.x) + ox
			y: int(pt.y) + oy
			w: int(pt.size)
			h: int(pt.size)
		}
		sdl.render_fill_rect(renderer, &rect)
	}
}

fn render_score_popups(renderer &sdl.Renderer, mut g MarioBrosGame, ox int, oy int) {
	for sp in g.score_popups {
		if !sp.active {
			continue
		}
		draw_text_centered_shadow(renderer, int(sp.x) + ox, int(sp.y) + oy, sp.text, 2,
			sp.color, Color{ r: 0, g: 0, b: 0, a: 255 })
	}
}

fn render_gameplay_banners(renderer &sdl.Renderer, mut g MarioBrosGame) {
	// Phase Ready Banner
	if g.phase_banner_timer > 0.0 && g.state == .playing {
		banner_text := 'PHASE ${g.phase} - READY!'
		draw_text_centered_shadow(renderer, 400, 240, banner_text, 3,
			Color{ r: 255, g: 235, b: 60, a: 255 }, Color{ r: 20, g: 20, b: 20, a: 255 })
	}

	// Dynamic Combo Banner
	if g.combo_banner_timer > 0.0 && g.combo_banner != '' {
		draw_text_centered_shadow(renderer, 400, 200, g.combo_banner, 2,
			Color{ r: 255, g: 140, b: 40, a: 255 }, Color{ r: 10, g: 10, b: 10, a: 255 })
	}
}

fn render_hud(renderer &sdl.Renderer, mut g MarioBrosGame) {
	// Top Arcade Score Bar
	// P1 Score (Mario)
	p1_score := if g.players.len > 0 { g.players[0].score } else { 0 }
	draw_text_shadow(renderer, 40, 20, 'MARIO', 2, Color{ r: 240, g: 60, b: 60, a: 255 }, Color{ r: 20, g: 20, b: 20, a: 255 })
	draw_text_shadow(renderer, 40, 42, '${p1_score:06d}', 2, Color{ r: 255, g: 255, b: 255, a: 255 }, Color{ r: 20, g: 20, b: 20, a: 255 })

	// Top High Score
	draw_text_centered_shadow(renderer, 400, 20, 'TOP', 2, Color{ r: 240, g: 220, b: 40, a: 255 }, Color{ r: 20, g: 20, b: 20, a: 255 })
	draw_text_centered_shadow(renderer, 400, 42, '${g.high_score:06d}', 2, Color{ r: 255, g: 255, b: 255, a: 255 }, Color{ r: 20, g: 20, b: 20, a: 255 })

	// P2 Score (Luigi)
	p2_score := if g.players.len > 1 { g.players[1].score } else { 0 }
	draw_text_shadow(renderer, 660, 20, 'LUIGI', 2, Color{ r: 60, g: 220, b: 60, a: 255 }, Color{ r: 20, g: 20, b: 20, a: 255 })
	draw_text_shadow(renderer, 660, 42, '${p2_score:06d}', 2, Color{ r: 255, g: 255, b: 255, a: 255 }, Color{ r: 20, g: 20, b: 20, a: 255 })

	// Phase number indicator
	if g.state == .bonus_phase {
		timer_color := if g.bonus_timer < 5.0 { Color{ r: 255, g: 40, b: 40, a: 255 } } else { Color{ r: 255, g: 140, b: 40, a: 255 } }
		draw_text_centered_shadow(renderer, 400, 68, 'BONUS PHASE  TIME: ${int(g.bonus_timer)}', 2,
			timer_color, Color{ r: 0, g: 0, b: 0, a: 255 })
	} else {
		draw_text_centered_shadow(renderer, 400, 68, 'PHASE ${g.phase:02d}', 2,
			Color{ r: 120, g: 200, b: 255, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	}

	// Lives Counter Icons at Bottom
	if g.players.len > 0 {
		p1_lives := g.players[0].lives
		draw_text(renderer, 30, 568, 'M:', 2, Color{ r: 240, g: 60, b: 60, a: 255 })
		for i in 0 .. p1_lives {
			draw_mini_mario_cap(renderer, 70 + i * 22, 566, Color{ r: 240, g: 40, b: 40, a: 255 })
		}
	}

	if g.players.len > 1 {
		p2_lives := g.players[1].lives
		draw_text(renderer, 670, 568, 'L:', 2, Color{ r: 40, g: 220, b: 40, a: 255 })
		for i in 0 .. p2_lives {
			draw_mini_mario_cap(renderer, 710 + i * 22, 566, Color{ r: 40, g: 220, b: 40, a: 255 })
		}
	}
}

fn draw_mini_mario_cap(renderer &sdl.Renderer, x int, y int, color Color) {
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, 255)
	c_rect := sdl.Rect{ x: x, y: y, w: 14, h: 6 }
	sdl.render_fill_rect(renderer, &c_rect)
	v_rect := sdl.Rect{ x: x + 4, y: y + 6, w: 12, h: 4 }
	sdl.render_fill_rect(renderer, &v_rect)
}

fn render_crt_overlay(renderer &sdl.Renderer) {
	sdl.set_render_draw_blend_mode(renderer, .blend)
	// Subtle CRT horizontal scanlines
	sdl.set_render_draw_color(renderer, 0, 0, 0, 28)
	for y := 0; y < 600; y += 3 {
		line := sdl.Rect{ x: 0, y: y, w: 800, h: 1 }
		sdl.render_fill_rect(renderer, &line)
	}

	// CRT Vignette corner borders
	sdl.set_render_draw_color(renderer, 0, 0, 0, 80)
	top_bar := sdl.Rect{ x: 0, y: 0, w: 800, h: 2 }
	bot_bar := sdl.Rect{ x: 0, y: 598, w: 800, h: 2 }
	left_bar := sdl.Rect{ x: 0, y: 0, w: 2, h: 600 }
	right_bar := sdl.Rect{ x: 798, y: 0, w: 2, h: 600 }
	sdl.render_fill_rect(renderer, &top_bar)
	sdl.render_fill_rect(renderer, &bot_bar)
	sdl.render_fill_rect(renderer, &left_bar)
	sdl.render_fill_rect(renderer, &right_bar)
}

fn render_title_screen(renderer &sdl.Renderer, mut g MarioBrosGame) {
	// Dark semi-transparent backdrop
	sdl.set_render_draw_blend_mode(renderer, .blend)
	sdl.set_render_draw_color(renderer, 5, 8, 16, 220)
	scrim := sdl.Rect{ x: 0, y: 0, w: 800, h: 600 }
	sdl.render_fill_rect(renderer, &scrim)

	// Giant Arcade Marquee Title with Golden Trim
	draw_text_centered_shadow(renderer, 400, 75, 'MARIO BROS.', 5,
		Color{ r: 255, g: 45, b: 45, a: 255 }, Color{ r: 245, g: 220, b: 30, a: 255 })

	draw_text_centered_shadow(renderer, 400, 135, 'ARCADE 1983 RECREATION', 2,
		Color{ r: 60, g: 210, b: 255, a: 255 }, Color{ r: 10, g: 20, b: 40, a: 255 })

	// Mode Selector
	p1_c := if g.mode == .single_player { Color{ r: 255, g: 240, b: 40, a: 255 } } else { Color{ r: 160, g: 160, b: 160, a: 255 } }
	p2_c := if g.mode == .two_players { Color{ r: 255, g: 240, b: 40, a: 255 } } else { Color{ r: 160, g: 160, b: 160, a: 255 } }

	cursor_y := if g.mode == .single_player { 210 } else { 250 }
	draw_text_shadow(renderer, 240, cursor_y, '>', 2, Color{ r: 255, g: 50, b: 50, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })

	draw_text_shadow(renderer, 280, 210, '1 PLAYER GAME   (1)', 2, p1_c, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_shadow(renderer, 280, 250, '2 PLAYERS GAME  (2)', 2, p2_c, Color{ r: 0, g: 0, b: 0, a: 255 })

	draw_text_centered_shadow(renderer, 400, 305, 'PRESS SPACE OR ENTER TO START', 2,
		Color{ r: 255, g: 255, b: 255, a: 255 }, Color{ r: 20, g: 20, b: 20, a: 255 })

	// Controls Summary Box
	draw_text_centered_shadow(renderer, 400, 365, 'CONTROLS & SHORTCUTS', 2,
		Color{ r: 255, g: 185, b: 45, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 395, 'PLAYER 1 (MARIO): A / D MOVE | SPACE / W JUMP', 1,
		Color{ r: 230, g: 230, b: 230, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 420, 'PLAYER 2 (LUIGI): J / L MOVE | I / UP JUMP', 1,
		Color{ r: 230, g: 230, b: 230, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 445, 'HIT PLATFORMS UNDERNEATH PESTS TO FLIP THEM!', 1,
		Color{ r: 110, g: 255, b: 130, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 470, 'HIT THE POW BLOCK IN EMERGENCIES (3 USES)', 1,
		Color{ r: 100, g: 210, b: 255, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 495, '[P] PAUSE  [M] MUTE  [C] CRT SCANLINES  [R] RESET', 1,
		Color{ r: 255, g: 215, b: 110, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })

	draw_text_centered_shadow(renderer, 400, 560, '(C) 1983 NINTENDO ARCADE CLASSIC', 1,
		Color{ r: 150, g: 150, b: 160, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
}

fn render_paused_screen(renderer &sdl.Renderer) {
	sdl.set_render_draw_blend_mode(renderer, .blend)
	sdl.set_render_draw_color(renderer, 0, 0, 0, 190)
	scrim := sdl.Rect{ x: 0, y: 0, w: 800, h: 600 }
	sdl.render_fill_rect(renderer, &scrim)

	draw_text_centered_shadow(renderer, 400, 270, 'PAUSED', 4,
		Color{ r: 255, g: 230, b: 40, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 320, 'PRESS P TO RESUME', 2,
		Color{ r: 255, g: 255, b: 255, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
}

fn render_phase_clear_screen(renderer &sdl.Renderer, mut g MarioBrosGame) {
	sdl.set_render_draw_blend_mode(renderer, .blend)
	sdl.set_render_draw_color(renderer, 0, 0, 0, 180)
	scrim := sdl.Rect{ x: 0, y: 0, w: 800, h: 600 }
	sdl.render_fill_rect(renderer, &scrim)

	draw_text_centered_shadow(renderer, 400, 240, 'PHASE ${g.phase} CLEAR!', 4,
		Color{ r: 80, g: 255, b: 100, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 300, 'BONUS +1000 PTS', 2,
		Color{ r: 255, g: 230, b: 60, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 350, 'PRESS SPACE TO CONTINUE', 2,
		Color{ r: 255, g: 255, b: 255, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
}

fn render_game_over_screen(renderer &sdl.Renderer, mut g MarioBrosGame) {
	sdl.set_render_draw_blend_mode(renderer, .blend)
	sdl.set_render_draw_color(renderer, 0, 0, 0, 210)
	scrim := sdl.Rect{ x: 0, y: 0, w: 800, h: 600 }
	sdl.render_fill_rect(renderer, &scrim)

	p1_s := if g.players.len > 0 { g.players[0].score } else { 0 }
	draw_text_centered_shadow(renderer, 400, 230, 'GAME OVER', 5,
		Color{ r: 255, g: 40, b: 40, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 300, 'FINAL SCORE: ${p1_s}', 2,
		Color{ r: 255, g: 255, b: 255, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
	draw_text_centered_shadow(renderer, 400, 360, 'PRESS SPACE TO RETRY', 2,
		Color{ r: 255, g: 230, b: 40, a: 255 }, Color{ r: 0, g: 0, b: 0, a: 255 })
}
