module main

import math
import sdl

pub fn render_scorched_game(renderer &sdl.Renderer, mut g ScorchedGame, win_w int, win_h int, mouse_x int, mouse_y int, sound_enabled bool) {
	// 1. Dynamic Sky with Atmosphere & Sun
	sdl.set_render_draw_color(renderer, 20, 25, 45, 255)
	clear_rect := sdl.Rect{0, 0, win_w, win_h}
	sdl.render_fill_rect(renderer, &clear_rect)

	// Glowing Warm Sun
	draw_filled_circle(renderer, win_w - 120, 90, 32, Color{255, 215, 80, 255})
	draw_filled_circle(renderer, win_w - 120, 90, 42, Color{255, 180, 40, 70})

	// 2. Destructible Mountain & Dirt Terrain
	for x in 0 .. g.width {
		gy := g.terrain_y[x]
		// Grass top rim
		sdl.set_render_draw_color(renderer, 75, 175, 60, 255)
		sdl.render_draw_line(renderer, x, gy, x, gy + 3)

		// Soil / Dirt body
		sdl.set_render_draw_color(renderer, 130, 80, 45, 255)
		sdl.render_draw_line(renderer, x, gy + 4, x, gy + 30)

		// Deep bedrock
		sdl.set_render_draw_color(renderer, 85, 50, 30, 255)
		sdl.render_draw_line(renderer, x, gy + 31, x, win_h)
	}

	// 3. Draw Tanks (Live and Dead Wreckage)
	for i, t in g.tanks {
		render_tank(renderer, t, i == g.current_turn && !t.is_dead)
	}

	// 4. Draw Projectiles & Vapor Trails
	for p in g.projectiles {
		// Vapor trail
		sdl.set_render_draw_color(renderer, 255, 230, 150, 160)
		for t_i := 0; t_i < p.trail.len; t_i += 2 {
			tx := int(p.trail[t_i])
			ty := int(p.trail[t_i + 1])
			sdl.render_draw_point(renderer, tx, ty)
		}

		// Glowing Projectile Head
		px := int(p.x)
		py := int(p.y)
		head_col := if p.wtype == .baby_nuke { Color{255, 220, 50, 255} } else { Color{255, 80, 40, 255} }
		draw_filled_circle(renderer, px, py, if p.wtype == .baby_nuke { 4 } else { 3 }, head_col)
	}

	// 5. Draw Explosions
	for exp in g.explosions {
		cx := int(exp.x)
		cy := int(exp.y)
		r := int(exp.radius)
		draw_filled_circle(renderer, cx, cy, r, exp.col)
		draw_filled_circle(renderer, cx, cy, r / 2, Color{255, 255, 200, 255})
	}

	// 6. Draw Floating Damage Numbers
	for dt_item in g.damage_texts {
		draw_text_centered(renderer, int(dt_item.x), int(dt_item.y), dt_item.text, 1, dt_item.col)
	}

	// 7. Top HUD & Wind Gauge
	render_top_hud(renderer, g, win_w, sound_enabled)

	// 8. Bottom Artillery Dashboard
	if !g.in_shop {
		render_artillery_dashboard(renderer, g, win_w, win_h)
	}

	// 9. Weapons Shop Overlay if active
	if g.in_shop {
		render_weapons_shop(renderer, g, win_w, win_h, mouse_x, mouse_y)
	}

	// 10. Announcement Banner
	if g.banner_timer > 0.0 && g.banner_text != '' {
		bw := g.banner_text.len * 8 * 2 + 40
		bx := win_w / 2 - bw / 2
		by := 200

		sdl.set_render_draw_color(renderer, 20, 25, 35, 240)
		bg := sdl.Rect{bx, by, bw, 44}
		sdl.render_fill_rect(renderer, &bg)
		sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
		sdl.render_draw_rect(renderer, &bg)

		draw_text_centered(renderer, win_w / 2, by + 14, g.banner_text, 2, Color{255, 230, 80, 255})
	}
}

fn render_tank(renderer &sdl.Renderer, t Tank, is_active bool) {
	x := t.x
	y := t.y

	if t.is_dead {
		// Charred wreckage & smoke
		sdl.set_render_draw_color(renderer, 30, 30, 30, 255)
		wreck := sdl.Rect{x - 12, y - 4, 24, 5}
		sdl.render_fill_rect(renderer, &wreck)
		draw_text_centered(renderer, x, y - 18, 'DESTROYED', 1, Color{255, 70, 50, 255})
		return
	}

	// Treads
	sdl.set_render_draw_color(renderer, 40, 45, 50, 255)
	treads := sdl.Rect{x - 14, y - 5, 28, 6}
	sdl.render_fill_rect(renderer, &treads)

	// Hull
	sdl.set_render_draw_color(renderer, t.color.r, t.color.g, t.color.b, 255)
	hull := sdl.Rect{x - 10, y - 11, 20, 7}
	sdl.render_fill_rect(renderer, &hull)

	// Turret Dome
	draw_filled_circle(renderer, x, y - 11, 6, t.color)

	// Cannon Barrel
	rad := t.angle * math.pi / 180.0
	barrel_len := 16.0
	bx := x + int(math.cos(rad) * barrel_len)
	by := (y - 11) - int(math.sin(rad) * barrel_len)

	sdl.set_render_draw_color(renderer, 230, 230, 235, 255)
	for i in -1 .. 2 {
		sdl.render_draw_line(renderer, x + i, y - 11, bx + i, by)
	}

	// Active turn indicator pointer
	if is_active {
		sdl.set_render_draw_color(renderer, 255, 220, 0, 255)
		draw_filled_circle(renderer, x, y - 32, 3, Color{255, 220, 0, 255})
	}

	// Tank Name & Numeric Health Bar
	draw_text_centered(renderer, x, y - 42, t.name, 1, Color{240, 240, 240, 255})
	draw_text_centered(renderer, x, y - 30, '${t.health}/100 HP', 1, if t.health > 50 { Color{100, 255, 120, 255} } else { Color{255, 120, 60, 255} })

	sdl.set_render_draw_color(renderer, 180, 30, 30, 255)
	hp_bg := sdl.Rect{x - 16, y - 18, 32, 4}
	sdl.render_fill_rect(renderer, &hp_bg)

	hp_w := int(32.0 * (f64(t.health) / 100.0))
	if hp_w > 0 {
		sdl.set_render_draw_color(renderer, if t.health > 50 { u8(50) } else { u8(240) }, if t.health > 50 { u8(220) } else { u8(180) }, 60, 255)
		hp_bar := sdl.Rect{x - 16, y - 18, hp_w, 4}
		sdl.render_fill_rect(renderer, &hp_bar)
	}
}

fn render_top_hud(renderer &sdl.Renderer, g ScorchedGame, win_w int, sound_enabled bool) {
	sdl.set_render_draw_color(renderer, 15, 20, 30, 220)
	bar := sdl.Rect{0, 0, win_w, 42}
	sdl.render_fill_rect(renderer, &bar)

	sdl.set_render_draw_color(renderer, 180, 140, 30, 255)
	sdl.render_draw_line(renderer, 0, 41, win_w, 41)

	// Title & Round
	draw_text(renderer, 20, 14, '★ SCORCHED EARTH DELUXE ★', 1, Color{255, 215, 0, 255})
	draw_text(renderer, 240, 14, 'ROUND: ${g.round}/${g.max_rounds}', 1, Color{240, 240, 240, 255})

	// Wind Indicator
	wind_str := if g.wind >= 0 { 'WIND: +${int(g.wind)} MPH >>' } else { 'WIND: << ${int(g.wind)} MPH' }
	wind_col := if g.wind >= 0 { Color{100, 220, 255, 255} } else { Color{255, 140, 100, 255} }
	draw_text(renderer, 380, 14, wind_str, 1, wind_col)

	// Player Cash & Kills
	draw_text(renderer, 580, 14, 'CASH: $${g.tanks[0].cash}', 1, Color{100, 255, 140, 255})
	draw_text(renderer, 700, 14, 'KILLS: ${g.tanks[0].kills}', 1, Color{255, 200, 80, 255})

	// Sound toggle badge
	sound_x := win_w - 110
	if sound_enabled {
		sdl.set_render_draw_color(renderer, 40, 120, 60, 255)
		btn := sdl.Rect{sound_x, 8, 95, 24}
		sdl.render_fill_rect(renderer, &btn)
		draw_text_centered(renderer, sound_x + 47, 13, 'SOUND: ON', 1, Color{255, 255, 255, 255})
	} else {
		sdl.set_render_draw_color(renderer, 120, 35, 40, 255)
		btn := sdl.Rect{sound_x, 8, 95, 24}
		sdl.render_fill_rect(renderer, &btn)
		draw_text_centered(renderer, sound_x + 47, 13, 'MUTED [M]', 1, Color{255, 180, 180, 255})
	}
}

fn render_artillery_dashboard(renderer &sdl.Renderer, g ScorchedGame, win_w int, win_h int) {
	cur := g.tanks[g.current_turn]
	info := get_weapon_info(cur.active_wep)

	sdl.set_render_draw_color(renderer, 15, 20, 32, 230)
	dash := sdl.Rect{0, win_h - 55, win_w, 55}
	sdl.render_fill_rect(renderer, &dash)

	sdl.set_render_draw_color(renderer, 180, 140, 30, 255)
	sdl.render_draw_line(renderer, 0, win_h - 55, win_w, win_h - 55)

	// Angle & Power Controls
	draw_text(renderer, 20, win_h - 40, 'ANGLE: ${int(cur.angle)}° [A/D]', 1, Color{255, 220, 80, 255})
	draw_text(renderer, 200, win_h - 40, 'POWER: ${int(cur.power)} [W/S]', 1, Color{255, 220, 80, 255})

	// Weapon Selection & Ammo
	ammo := if cur.active_wep == .standard { 'INF' } else { '${cur.inventory[cur.active_wep.str()]}' }
	draw_text(renderer, 380, win_h - 40, 'WEAPON [1-6]: ${info.name.to_upper()} (AMMO: ${ammo})', 1, Color{100, 240, 255, 255})

	// Fire Action
	if !cur.is_ai {
		draw_text(renderer, win_w - 200, win_h - 40, '[SPACE] FIRE CANNON', 1, Color{50, 255, 120, 255})
	} else {
		draw_text(renderer, win_w - 200, win_h - 40, 'BOT IS AIMING...', 1, Color{255, 160, 80, 255})
	}
}

fn render_weapons_shop(renderer &sdl.Renderer, g ScorchedGame, win_w int, win_h int, _ int, _ int) {
	// Dark semi-transparent modal overlay
	sdl.set_render_draw_color(renderer, 5, 10, 18, 230)
	modal := sdl.Rect{80, 60, win_w - 160, win_h - 120}
	sdl.render_fill_rect(renderer, &modal)

	sdl.set_render_draw_color(renderer, 255, 215, 0, 255)
	sdl.render_draw_rect(renderer, &modal)

	draw_text_centered(renderer, win_w / 2, 85, '★ ARSENAL WEAPONS SHOP ★', 2, Color{255, 215, 0, 255})
	draw_text_centered(renderer, win_w / 2, 120, 'YOUR CASH: $${g.tanks[0].cash}  |  PREPARE FOR ROUND ${g.round}', 1, Color{100, 255, 140, 255})

	w_list := [
		WeaponType.baby_nuke,
		WeaponType.mirv,
		WeaponType.mountain_mover,
		WeaponType.napalm,
		WeaponType.digger,
	]

	mut row_y := 160
	for i, w in w_list {
		info := get_weapon_info(w)
		owned := g.tanks[0].inventory[w.str()]

		sdl.set_render_draw_color(renderer, 25, 35, 50, 255)
		item_r := sdl.Rect{110, row_y, win_w - 220, 48}
		sdl.render_fill_rect(renderer, &item_r)
		sdl.set_render_draw_color(renderer, 60, 80, 110, 255)
		sdl.render_draw_rect(renderer, &item_r)

		draw_text(renderer, 125, row_y + 10, '${i + 1}. ${info.name}', 1, Color{255, 230, 80, 255})
		draw_text(renderer, 125, row_y + 26, info.desc, 1, Color{180, 190, 200, 255})
		draw_text(renderer, 480, row_y + 18, 'COST: $${info.cost}', 1, Color{100, 255, 140, 255})
		draw_text(renderer, 600, row_y + 18, 'OWNED: ${owned}', 1, Color{200, 220, 255, 255})

		// Buy button
		sdl.set_render_draw_color(renderer, 40, 120, 60, 255)
		buy_btn := sdl.Rect{win_w - 200, row_y + 10, 75, 28}
		sdl.render_fill_rect(renderer, &buy_btn)
		draw_text_centered(renderer, win_w - 162, row_y + 18, 'BUY [${i + 1}]', 1, Color{255, 255, 255, 255})

		row_y += 58
	}

	draw_text_centered(renderer, win_w / 2, win_h - 100, 'PRESS [SPACE] TO COMMENCE NEXT ROUND', 1, Color{255, 255, 255, 255})
}
