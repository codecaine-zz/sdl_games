module main

import math
import rand

enum GameState {
	menu
	playing
	paused
	game_over
}

enum EnemyType {
	zako      // Blue/yellow bee
	goei      // Red/yellow moth
	boss      // Green/purple commander (2 hits, can shoot tractor beam)
}

enum EnemyMode {
	formation
	swooping
	tractor_beam
	returning
}

struct Star {
mut:
	x          f32
	y          f32
	speed      f32
	size       int
	brightness u8
}

struct Bullet {
mut:
	x        f32
	y        f32
	vy       f32
	is_enemy bool
	active   bool
}

struct Enemy {
mut:
	id           int
	enemy_type   EnemyType
	mode         EnemyMode
	x            f32
	y            f32
	home_x       f32
	home_y       f32
	vx           f32
	vy           f32
	swoop_time   f32
	swoop_param  f32
	hp           int
	active       bool
	has_captured bool
}

struct Particle {
mut:
	x        f32
	y        f32
	vx       f32
	vy       f32
	life     f32
	max_life f32
	color    Color
}

struct Player {
mut:
	x            f32
	y            f32
	width        f32
	height       f32
	speed        f32
	is_dual      bool
	dual_offset  f32
	lives        int
	is_captured  bool
	invuln_timer f32
}

struct GalagaGame {
mut:
	state            GameState = .menu
	score            int
	high_score       int = 5000
	stage            int = 1
	player           Player
	enemies          []Enemy
	player_bullets   []Bullet
	enemy_bullets    []Bullet
	particles        []Particle
	stars            []Star
	sound_mgr        SoundManager
	wave_timer       f32
	tractor_active   bool
	tractor_enemy_id int = -1
	tractor_beam_y   f32
	captured_ship_x  f32
	captured_ship_y  f32
	key_left         bool
	key_right        bool
	key_fire         bool
	fire_cooldown    f32
}

fn new_galaga_game() GalagaGame {
	mut g := GalagaGame{
		score:     0
		high_score: 5000
		stage:      1
		sound_mgr:  new_sound_manager()
	}
	g.init_stars()
	g.reset_game()
	return g
}

fn (mut g GalagaGame) init_stars() {
	g.stars.clear()
	for _ in 0 .. 60 {
		g.stars << Star{
			x:          f32(rand.intn(800) or { 400 })
			y:          f32(rand.intn(600) or { 300 })
			speed:      f32(rand.intn(3) or { 1 }) + 0.5
			size:       (rand.intn(2) or { 0 }) + 1
			brightness: u8(100 + (rand.intn(155) or { 100 }))
		}
	}
}

fn (mut g GalagaGame) reset_game() {
	g.score = 0
	g.stage = 1
	g.player = Player{
		x:            400.0
		y:            540.0
		width:        32.0
		height:       28.0
		speed:        320.0
		is_dual:      false
		dual_offset:  24.0
		lives:        3
		is_captured:  false
		invuln_timer: 2.0
	}
	g.player_bullets.clear()
	g.enemy_bullets.clear()
	g.particles.clear()
	g.spawn_wave()
	g.state = .playing
	g.sound_mgr.play_stage_start_sound()
}

fn (mut g GalagaGame) spawn_wave() {
	g.enemies.clear()
	g.tractor_active = false
	g.tractor_enemy_id = -1

	mut id_counter := 0

	for col in 0 .. 4 {
		g.enemies << Enemy{
			id:         id_counter
			enemy_type: .boss
			mode:       .formation
			home_x:     280.0 + f32(col) * 80.0
			home_y:     100.0
			x:          280.0 + f32(col) * 80.0
			y:          -50.0 - f32(col) * 20.0
			hp:         2
			active:     true
		}
		id_counter++
	}

	for col in 0 .. 8 {
		g.enemies << Enemy{
			id:         id_counter
			enemy_type: .goei
			mode:       .formation
			home_x:     200.0 + f32(col) * 55.0
			home_y:     150.0
			x:          200.0 + f32(col) * 55.0
			y:          -100.0 - f32(col) * 15.0
			hp:         1
			active:     true
		}
		id_counter++
	}

	for col in 0 .. 10 {
		g.enemies << Enemy{
			id:         id_counter
			enemy_type: .zako
			mode:       .formation
			home_x:     150.0 + f32(col) * 50.0
			home_y:     200.0
			x:          150.0 + f32(col) * 50.0
			y:          -150.0 - f32(col) * 12.0
			hp:         1
			active:     true
		}
		id_counter++
	}
}

fn (mut g GalagaGame) update(dt f32) {
	g.update_stars(dt)

	if g.state != .playing {
		return
	}

	if g.fire_cooldown > 0 {
		g.fire_cooldown -= dt
	}

	if g.player.invuln_timer > 0 {
		g.player.invuln_timer -= dt
	}

	// Player Movement
	if g.key_left {
		g.player.x -= g.player.speed * dt
		min_x := if g.player.is_dual { f32(32.0) } else { f32(20.0) }
		if g.player.x < min_x {
			g.player.x = min_x
		}
	}
	if g.key_right {
		g.player.x += g.player.speed * dt
		max_x := if g.player.is_dual { f32(768.0) } else { f32(780.0) }
		if g.player.x > max_x {
			g.player.x = max_x
		}
	}

	// Player Shooting
	if g.key_fire && g.fire_cooldown <= 0 {
		g.fire_cooldown = 0.18
		if g.player.is_dual {
			g.player_bullets << Bullet{
				x:        g.player.x - g.player.dual_offset / 2.0
				y:        g.player.y - 14.0
				vy:       -650.0
				is_enemy: false
				active:   true
			}
			g.player_bullets << Bullet{
				x:        g.player.x + g.player.dual_offset / 2.0
				y:        g.player.y - 14.0
				vy:       -650.0
				is_enemy: false
				active:   true
			}
		} else {
			g.player_bullets << Bullet{
				x:        g.player.x
				y:        g.player.y - 14.0
				vy:       -650.0
				is_enemy: false
				active:   true
			}
		}
		g.sound_mgr.play_shoot_sound()
	}

	// Update Bullets
	for mut b in g.player_bullets {
		if !b.active {
			continue
		}
		b.y += b.vy * dt
		if b.y < -20 {
			b.active = false
		}
	}

	for mut eb in g.enemy_bullets {
		if !eb.active {
			continue
		}
		eb.y += eb.vy * dt
		if eb.y > 620 {
			eb.active = false
		}
	}

	// Update Enemies
	g.wave_timer += dt
	mut active_count := 0

	for mut e in g.enemies {
		if !e.active {
			continue
		}
		active_count++

		match e.mode {
			.formation {
				dx := e.home_x - e.x
				dy := e.home_y - e.y
				dist := f32(math.sqrt(dx * dx + dy * dy))
				if dist > 5.0 {
					e.x += f32((dx / dist) * 200.0 * dt)
					e.y += f32((dy / dist) * 200.0 * dt)
				} else {
					e.x = e.home_x + f32(math.sin(g.wave_timer * 2.0 + e.home_x)) * 12.0
					e.y = e.home_y + f32(math.cos(g.wave_timer * 1.5)) * 6.0
				}

				if rand.intn(400) or { 0 } == 1 && g.wave_timer > 3.0 {
					e.mode = .swooping
					e.swoop_time = 0.0
					e.swoop_param = f32((rand.intn(200) or { 100 }) - 100)
				}
			}
			.swooping {
				e.swoop_time += dt
				e.y += (180.0 + f32(g.stage) * 20.0) * dt
				e.x += f32(math.sin(e.swoop_time * 4.0)) * 120.0

				if rand.intn(90) or { 0 } == 1 {
					g.enemy_bullets << Bullet{
						x:        e.x
						y:        e.y + 10.0
						vy:       320.0
						is_enemy: true
						active:   true
					}
				}

				if e.enemy_type == .boss && !g.tractor_active && !g.player.is_dual && e.y > 220
					&& e.y < 340 {
					e.mode = .tractor_beam
					g.tractor_active = true
					g.tractor_enemy_id = e.id
					g.sound_mgr.play_tractor_beam_sound()
				}

				if e.y > 640 {
					e.y = -40.0
					e.mode = .formation
				}
			}
			.tractor_beam {
				if g.tractor_enemy_id == e.id {
					g.tractor_beam_y = e.y + 20.0
					beam_width := f32(80.0)
					if math.abs(g.player.x - e.x) < beam_width / 2.0 && g.player.y > g.tractor_beam_y {
						g.player.is_captured = true
						e.has_captured = true
						g.captured_ship_x = e.x
						g.captured_ship_y = e.y + 40.0
						g.tractor_active = false
						e.mode = .returning
						g.handle_player_death()
					}
				}
			}
			.returning {
				e.y += 150.0 * dt
				if e.has_captured {
					g.captured_ship_x = e.x
					g.captured_ship_y = e.y + 35.0
				}
				if e.y > 640 {
					e.y = -30.0
					e.mode = .formation
				}
			}
		}
	}

	if active_count == 0 {
		g.stage++
		g.spawn_wave()
	}

	// Bullet - Enemy Collision Check
	for mut b in g.player_bullets {
		if !b.active {
			continue
		}
		for mut e in g.enemies {
			if !e.active {
				continue
			}
			dx := b.x - e.x
			dy := b.y - e.y
			if math.abs(dx) < 18.0 && math.abs(dy) < 18.0 {
				b.active = false
				e.hp--
				if e.hp <= 0 {
					e.active = false
					points := match e.enemy_type {
						.zako { 100 }
						.goei { 160 }
						.boss { 400 }
					}
					g.add_score(points)
					g.spawn_explosion(e.x, e.y, Color{
						r: 255
						g: 200
						b: 50
						a: 255
					})
					g.sound_mgr.play_explosion_sound()

					if e.has_captured {
						e.has_captured = false
						g.player.is_dual = true
						g.player.lives++
						g.spawn_explosion(e.x, e.y, Color{
							r: 100
							g: 255
							b: 100
							a: 255
						})
					}
				} else {
					g.sound_mgr.play_hit_sound()
				}
				break
			}
		}
	}

	// Enemy Bullet - Player Collision Check
	if g.player.invuln_timer <= 0 {
		for mut eb in g.enemy_bullets {
			if !eb.active {
				continue
			}
			dx := eb.x - g.player.x
			dy := eb.y - g.player.y
			if math.abs(dx) < 16.0 && math.abs(dy) < 16.0 {
				eb.active = false
				g.handle_player_death()
				break
			}
		}
	}

	// Update Particles
	for mut p in g.particles {
		p.x += p.vx * dt
		p.y += p.vy * dt
		p.life -= dt
	}
	g.particles = g.particles.filter(it.life > 0)
	g.player_bullets = g.player_bullets.filter(it.active)
	g.enemy_bullets = g.enemy_bullets.filter(it.active)
}

fn (mut g GalagaGame) handle_player_death() {
	g.spawn_explosion(g.player.x, g.player.y, Color{
		r: 255
		g: 80
		b: 80
		a: 255
	})
	g.sound_mgr.play_explosion_sound()

	if g.player.is_dual {
		g.player.is_dual = false
		g.player.invuln_timer = 2.0
	} else {
		g.player.lives--
		if g.player.lives <= 0 {
			g.state = .game_over
		} else {
			g.player.x = 400.0
			g.player.invuln_timer = 2.5
		}
	}
}

fn (mut g GalagaGame) add_score(pts int) {
	g.score += pts
	if g.score > g.high_score {
		g.high_score = g.score
	}
}

fn (mut g GalagaGame) update_stars(dt f32) {
	for mut s in g.stars {
		s.y += s.speed * 60.0 * dt
		if s.y > 600 {
			s.y = 0
			s.x = f32(rand.intn(800) or { 400 })
		}
	}
}

fn (mut g GalagaGame) spawn_explosion(x f32, y f32, color Color) {
	for _ in 0 .. 18 {
		angle := f32(rand.intn(360) or { 0 }) * f32(math.pi) / 180.0
		speed := f32(rand.intn(150) or { 50 }) + 50.0
		g.particles << Particle{
			x:        x
			y:        y
			vx:       f32(math.cos(angle)) * speed
			vy:       f32(math.sin(angle)) * speed
			life:     0.35 + f32(rand.intn(20) or { 0 }) / 100.0
			max_life: 0.55
			color:    color
		}
	}
}
