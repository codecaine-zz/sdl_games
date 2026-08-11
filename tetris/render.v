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

const block_colors = [
	Color{
		r: 0
		g: 0
		b: 0
		a: 0
	}, // 0: Empty
	Color{
		r: 40
		g: 220
		b: 240
	}, // 1: Cyan (I)
	Color{
		r: 40
		g: 80
		b: 230
	}, // 2: Blue (J)
	Color{
		r: 240
		g: 140
		b: 30
	}, // 3: Orange (L)
	Color{
		r: 245
		g: 215
		b: 40
	}, // 4: Yellow (O)
	Color{
		r: 40
		g: 220
		b: 80
	}, // 5: Green (S)
	Color{
		r: 170
		g: 50
		b: 230
	}, // 6: Purple (T)
	Color{
		r: 240
		g: 45
		b: 65
	}, // 7: Red (Z)
]

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

fn draw_block(renderer &sdl.Renderer, x int, y int, size int, kind int, is_ghost bool) {
	if kind <= 0 || kind >= block_colors.len {
		return
	}
	c := block_colors[kind]

	rect := sdl.Rect{
		x: x
		y: y
		w: size
		h: size
	}

	if is_ghost {
		sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 60)
		sdl.render_fill_rect(renderer, &rect)
		sdl.set_render_draw_color(renderer, c.r, c.g, c.b, 180)
		sdl.render_draw_rect(renderer, &rect)
		return
	}

	// Base fill
	sdl.set_render_draw_color(renderer, c.r, c.g, c.b, c.a)
	sdl.render_fill_rect(renderer, &rect)

	// Top/Left bevel highlight
	top_rect := sdl.Rect{
		x: x + 1
		y: y + 1
		w: size - 2
		h: 3
	}
	left_rect := sdl.Rect{
		x: x + 1
		y: y + 1
		w: 3
		h: size - 2
	}
	sdl.set_render_draw_color(renderer, 255, 255, 255, 90)
	sdl.render_fill_rect(renderer, &top_rect)
	sdl.render_fill_rect(renderer, &left_rect)

	// Outer border
	border_r := u8(math.max(0, int(c.r) - 60))
	border_g := u8(math.max(0, int(c.g) - 60))
	border_b := u8(math.max(0, int(c.b) - 60))
	sdl.set_render_draw_color(renderer, border_r, border_g, border_b, 255)
	sdl.render_draw_rect(renderer, &rect)
}

fn draw_glass_card(renderer &sdl.Renderer, x int, y int, w int, h int, border_color Color) {
	bg_rect := sdl.Rect{
		x: x
		y: y
		w: w
		h: h
	}
	sdl.set_render_draw_color(renderer, 24, 30, 50, 230)
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
