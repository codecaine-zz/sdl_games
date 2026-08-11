module main

import math
import sdl

struct Particle {
mut:
	x     f64
	y     f64
	vx    f64
	vy    f64
	life  f64
	color Color
	size  int
}

fn draw_filled_circle(renderer &sdl.Renderer, cx int, cy int, r int, color Color) {
	if r <= 0 {
		return
	}
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	r_sq := r * r
	for dy := -r; dy <= r; dy++ {
		dx := int(math.sqrt(f64(r_sq - dy * dy)))
		if dx < 0 {
			continue
		}
		rect := sdl.Rect{
			x: cx - dx
			y: cy + dy
			w: dx * 2 + 1
			h: 1
		}
		sdl.render_fill_rect(renderer, &rect)
	}
}

fn draw_circle_outline(renderer &sdl.Renderer, cx int, cy int, r int, thickness int, color Color) {
	if r <= 0 {
		return
	}
	sdl.set_render_draw_color(renderer, color.r, color.g, color.b, color.a)
	for t := 0; t < thickness; t++ {
		radius := r - t
		if radius <= 0 {
			break
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
				y++
				err += 2 * y + 1
			}
			if err > 0 {
				x--
				err -= 2 * x + 1
			}
		}
	}
}

fn draw_glass_card(renderer &sdl.Renderer, x int, y int, w int, h int, border_color Color) {
	bg_rect := sdl.Rect{
		x: x
		y: y
		w: w
		h: h
	}
	sdl.set_render_draw_color(renderer, 15, 23, 42, 230)
	sdl.render_fill_rect(renderer, &bg_rect)

	sdl.set_render_draw_color(renderer, border_color.r, border_color.g, border_color.b,
		border_color.a)
	sdl.render_draw_rect(renderer, &bg_rect)

	inner_rect := sdl.Rect{
		x: x + 1
		y: y + 1
		w: w - 2
		h: h - 2
	}
	sdl.set_render_draw_color(renderer, border_color.r, border_color.g, border_color.b,
		60)
	sdl.render_draw_rect(renderer, &inner_rect)
}

struct Button {
	x int
	y int
	w int
	h int
mut:
	text         string
	bg_color     Color
	hover_color  Color
	text_color   Color
	border_color Color
}

fn (btn &Button) is_hovered(mx int, my int) bool {
	return mx >= btn.x && mx <= btn.x + btn.w && my >= btn.y && my <= btn.y + btn.h
}

fn (btn &Button) draw(renderer &sdl.Renderer, mx int, my int) {
	hovered := btn.is_hovered(mx, my)
	current_bg := if hovered { btn.hover_color } else { btn.bg_color }

	if hovered {
		glow_rect := sdl.Rect{
			x: btn.x - 2
			y: btn.y - 2
			w: btn.w + 4
			h: btn.h + 4
		}
		sdl.set_render_draw_color(renderer, btn.border_color.r, btn.border_color.g, btn.border_color.b,
			90)
		sdl.render_draw_rect(renderer, &glow_rect)
	}

	bg_rect := sdl.Rect{
		x: btn.x
		y: btn.y
		w: btn.w
		h: btn.h
	}
	sdl.set_render_draw_color(renderer, current_bg.r, current_bg.g, current_bg.b, current_bg.a)
	sdl.render_fill_rect(renderer, &bg_rect)

	top_line_rect := sdl.Rect{
		x: btn.x + 1
		y: btn.y + 1
		w: btn.w - 2
		h: 2
	}
	sdl.set_render_draw_color(renderer, 255, 255, 255, 60)
	sdl.render_fill_rect(renderer, &top_line_rect)

	sdl.set_render_draw_color(renderer, btn.border_color.r, btn.border_color.g, btn.border_color.b,
		btn.border_color.a)
	sdl.render_draw_rect(renderer, &bg_rect)

	cx := btn.x + btn.w / 2
	ty := btn.y + (btn.h - 16) / 2
	draw_text_centered(renderer, cx, ty, btn.text, 2, btn.text_color)
}

fn render_ocean_background(renderer &sdl.Renderer, ticks u32) {
	// Sky (0 to water_level_y)
	sky_rect := sdl.Rect{
		x: 0
		y: 0
		w: ocean_width
		h: water_level_y
	}
	sdl.set_render_draw_color(renderer, 10, 15, 32, 255)
	sdl.render_fill_rect(renderer, &sky_rect)

	// Stars in Sky
	sdl.set_render_draw_color(renderer, 220, 235, 255, 180)
	for i in 0 .. 25 {
		sx := (i * 47) % ocean_width
		sy := 20 + ((i * 31) % (water_level_y - 40))
		sdl.render_draw_point(renderer, sx, sy)
	}

	// Water Deep Ocean Gradient
	water_rect := sdl.Rect{
		x: 0
		y: water_level_y
		w: ocean_width
		h: ocean_height - water_level_y
	}
	sdl.set_render_draw_color(renderer, 2, 12, 35, 255)
	sdl.render_fill_rect(renderer, &water_rect)

	// Animated Sunbeams Filtering Down
	sdl.set_render_draw_color(renderer, 34, 211, 238, 25)
	for beam in 0 .. 5 {
		bx := (beam * 220 + int(ticks / 40)) % ocean_width
		beam_rect := sdl.Rect{
			x: bx
			y: water_level_y
			w: 60
			h: ocean_height - water_level_y
		}
		sdl.render_fill_rect(renderer, &beam_rect)
	}

	// Animated Water Surface Wave Crests
	sdl.set_render_draw_color(renderer, 34, 211, 238, 220)
	surf_y := water_level_y
	for x := 0; x < ocean_width; x += 16 {
		wave_off := int(math.sin(f64(ticks) * 0.005 + f64(x) * 0.05) * 3.0)
		wave_rect := sdl.Rect{
			x: x
			y: surf_y + wave_off
			w: 16
			h: 3
		}
		sdl.render_fill_rect(renderer, &wave_rect)
	}

	// Swaying Kelp Forests on Seabed
	sdl.set_render_draw_color(renderer, 16, 185, 129, 140)
	for k in 0 .. 8 {
		kx := k * 130 + 40
		sway := int(math.sin(f64(ticks) * 0.003 + f64(k)) * 12.0)
		for h := 0; h < 70; h += 4 {
			cur_x := kx + (sway * h) / 70
			cur_y := ocean_height - h
			kelp_rect := sdl.Rect{
				x: cur_x
				y: cur_y
				w: 5
				h: 4
			}
			sdl.render_fill_rect(renderer, &kelp_rect)
		}
	}
}

fn render_ship(renderer &sdl.Renderer, ship Ship, has_shield bool, ticks u32) {
	sx := int(ship.x - ship.w / 2.0)
	sy := int(ship.y)
	sw := int(ship.w)
	sh := int(ship.h)

	// Arc Shield Concentric Forcefield Bubble
	if has_shield {
		pulse := int(math.sin(f64(ticks) * 0.02) * 3.0)
		draw_circle_outline(renderer, int(ship.x), sy + sh / 2, sw / 2 + 10 + pulse, 3,
			Color{ r: 34, g: 211, b: 238 })
		draw_circle_outline(renderer, int(ship.x), sy + sh / 2, sw / 2 + 6 + pulse, 2,
			Color{ r: 100, g: 240, b: 255 })
	}

	// Water Wake Spray at Stern
	if math.abs(ship.speed) > 0.5 {
		wake_x := if ship.dir == 1 { sx - 12 } else { sx + sw + 4 }
		draw_filled_circle(renderer, wake_x, sy + sh - 4, 6, Color{ r: 255, g: 255, b: 255, a: 160 })
	}

	// Hull Main Metallic Body
	hull_rect := sdl.Rect{
		x: sx
		y: sy + 10
		w: sw
		h: sh - 10
	}
	sdl.set_render_draw_color(renderer, 51, 65, 85, 255)
	sdl.render_fill_rect(renderer, &hull_rect)

	// Bevel Top Highlight
	top_highlight := sdl.Rect{
		x: sx + 2
		y: sy + 11
		w: sw - 4
		h: 3
	}
	sdl.set_render_draw_color(renderer, 148, 163, 184, 255)
	sdl.render_fill_rect(renderer, &top_highlight)

	// Swedish Navy Yellow Stripe
	stripe_rect := sdl.Rect{
		x: sx + sw / 2 - 4
		y: sy + 10
		w: 8
		h: sh - 10
	}
	sdl.set_render_draw_color(renderer, 250, 204, 21, 255)
	sdl.render_fill_rect(renderer, &stripe_rect)

	// Stealth Cabin Superstructure & Radar Dome
	cabin_rect := sdl.Rect{
		x: sx + sw / 4
		y: sy
		w: sw / 2
		h: 12
	}
	sdl.set_render_draw_color(renderer, 30, 41, 59, 255)
	sdl.render_fill_rect(renderer, &cabin_rect)

	// Spinning Radar Scanner Bar
	radar_cx := sx + sw / 2
	radar_sway := int(math.sin(f64(ticks) * 0.08) * 8.0)
	sdl.set_render_draw_color(renderer, 34, 211, 238, 255)
	sdl.render_draw_line(renderer, radar_cx, sy - 4, radar_cx + radar_sway, sy - 4)

	// Deck Cannon (Bow)
	cannon_x := if ship.dir == 1 { sx + sw - 6 } else { sx + 2 }
	cannon_rect := sdl.Rect{
		x: cannon_x
		y: sy + 6
		w: 8
		h: 4
	}
	sdl.set_render_draw_color(renderer, 15, 23, 42, 255)
	sdl.render_fill_rect(renderer, &cannon_rect)

	// Outer Border
	sdl.set_render_draw_color(renderer, 148, 163, 184, 255)
	sdl.render_draw_rect(renderer, &hull_rect)
}

fn render_submarine(renderer &sdl.Renderer, sub Submarine, ticks u32) {
	sx := int(sub.x)
	sy := int(sub.y)
	sw := int(sub.w)
	sh := int(sub.h)

	// Headlight Cone Beam Underwater
	beam_dir := if sub.speed > 0 { 1 } else { -1 }
	beam_start_x := if sub.speed > 0 { sx + sw } else { sx }
	sdl.set_render_draw_color(renderer, 255, 255, 200, 30)
	for b := 0; b < 60; b += 4 {
		bx := beam_start_x + beam_dir * b
		by := sy + sh / 2 - b / 3
		bh := b * 2 / 3 + 4
		beam_rect := sdl.Rect{
			x: if sub.speed > 0 { bx } else { bx - 4 }
			y: by
			w: 4
			h: bh
		}
		sdl.render_fill_rect(renderer, &beam_rect)
	}

	// Main Sub Capsule Hull
	rect := sdl.Rect{
		x: sx
		y: sy
		w: sw
		h: sh
	}
	sdl.set_render_draw_color(renderer, sub.color.r, sub.color.g, sub.color.b, sub.color.a)
	sdl.render_fill_rect(renderer, &rect)

	// Bevel Top Line Highlight
	top_line := sdl.Rect{
		x: sx + 2
		y: sy + 1
		w: sw - 4
		h: 2
	}
	sdl.set_render_draw_color(renderer, 255, 255, 255, 90)
	sdl.render_fill_rect(renderer, &top_line)

	// Conning Tower / Periscope
	tower_rect := sdl.Rect{
		x: sx + sw / 2 - 6
		y: sy - 8
		w: 12
		h: 8
	}
	sdl.set_render_draw_color(renderer, sub.color.r, sub.color.g, sub.color.b, 255)
	sdl.render_fill_rect(renderer, &tower_rect)

	// Lit Portholes
	for p := 0; p < 3; p++ {
		px := sx + 12 + p * (sw / 4)
		py := sy + sh / 2
		draw_filled_circle(renderer, px, py, 3, Color{ r: 250, g: 204, b: 21, a: 220 })
	}

	// Glowing Navigation Beacon LED
	beacon_x := if sub.speed > 0 { sx + 4 } else { sx + sw - 4 }
	draw_filled_circle(renderer, beacon_x, sy + 3, 3, Color{ r: 239, g: 68, b: 68, a: 255 })

	// Spinning Tail Propeller Animation
	prop_x := if sub.speed > 0 { sx - 4 } else { sx + sw }
	prop_phase := int(math.sin(f64(ticks) * 0.3) * 6.0)
	prop_rect := sdl.Rect{
		x: prop_x
		y: sy + sh / 2 - 3 + prop_phase / 2
		w: 4
		h: 6
	}
	sdl.set_render_draw_color(renderer, 200, 200, 200, 255)
	sdl.render_fill_rect(renderer, &prop_rect)

	// Hull Border
	sdl.set_render_draw_color(renderer, 255, 255, 255, 120)
	sdl.render_draw_rect(renderer, &rect)
}

fn render_supply_crate(renderer &sdl.Renderer, crate Crate, ticks u32) {
	cx := int(crate.x)
	cy := int(crate.y)

	// Canvas Parachute Canopy Overhead (if falling above water)
	if crate.y < f64(water_level_y - 10) {
		sdl.set_render_draw_color(renderer, 255, 255, 255, 220)
		for px := -14; px <= 14; px++ {
			py := int(math.sqrt(f64(196 - px * px)))
			sdl.render_draw_point(renderer, cx + px, cy - 20 - py / 2)
		}
		// Parachute Strings
		sdl.set_render_draw_color(renderer, 200, 200, 200, 180)
		sdl.render_draw_line(renderer, cx - 12, cy - 20, cx - 8, cy - 8)
		sdl.render_draw_line(renderer, cx + 12, cy - 20, cx + 8, cy - 8)
	}

	// Crate Box Body
	c_rect := sdl.Rect{
		x: cx - 10
		y: cy - 10
		w: 20
		h: 20
	}

	c_color := match crate.kind {
		.shield {
			Color{
				r: 34
				g: 211
				b: 238
			}
		}
		.triple {
			Color{
				r: 99
				g: 102
				b: 241
			}
		}
		.hyper {
			Color{
				r: 245
				g: 158
				b: 11
			}
		}
		.nuke {
			Color{
				r: 239
				g: 68
				b: 68
			}
		}
	}

	sdl.set_render_draw_color(renderer, c_color.r, c_color.g, c_color.b, 255)
	sdl.render_fill_rect(renderer, &c_rect)

	// Bevel Highlight
	sdl.set_render_draw_color(renderer, 255, 255, 255, 160)
	sdl.render_draw_rect(renderer, &c_rect)

	// Emblem Letter in Center
	emblem := match crate.kind {
		.shield { 'S' }
		.triple { '3' }
		.hyper { 'H' }
		.nuke { 'N' }
	}
	draw_text_centered(renderer, cx, cy - 6, emblem, 1, Color{ r: 15, g: 23, b: 42 })
}
