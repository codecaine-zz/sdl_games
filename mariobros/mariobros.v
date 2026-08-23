module main

import math
import rand

pub enum GameState {
	title
	playing
	bonus_phase
	phase_clear
	paused
	game_over
	victory
}

pub enum GameMode {
	single_player
	two_players
}

pub enum EnemyType {
	shellcreeper // Turtle
	sidestepper  // Crab
	fighterfly   // Fly
	slipice      // Ice monster
	fireball     // Green/Red fireball
}

pub enum EnemyState {
	spawning
	walking
	angry      // Crab enraged (speed x1.8)
	stunned    // Flipped on back
	recovering // Flashing/wiggling about to right itself
	kicked     // Hit by player, flying away
	in_pipe    // Traveling inside pipe
}

pub struct Platform {
pub:
	x      f32
	y      f32
	w      f32
	h      f32
	is_ice bool
}

pub struct BumpWave {
pub mut:
	x        f32
	y        f32
	radius   f32 = 40.0
	timer    f32 = 0.22
	duration f32 = 0.22
	active   bool = true
}

pub struct Shockwave {
pub mut:
	x        f32
	y        f32
	radius   f32   = 10.0
	max_r    f32   = 450.0
	timer    f32   = 0.45
	duration f32   = 0.45
	color    Color = Color{ r: 80, g: 190, b: 255, a: 255 }
	active   bool  = true
}

pub struct WaterDrip {
pub mut:
	x      f32
	y      f32
	vy     f32 = 180.0
	active bool = true
}

pub struct Player {
pub mut:
	id           int // 1 = Mario, 2 = Luigi
	x            f32
	y            f32
	vx           f32
	vy           f32
	width        f32 = 28.0
	height       f32 = 36.0
	facing_right bool = true
	is_grounded  bool
	is_jumping   bool
	is_skidding  bool
	is_dead      bool
	dead_timer   f32
	invuln_timer f32
	score        int
	lives        int = 3
	anim_timer   f32
	walk_frame   int
	combo_count  int
	combo_timer  f32
}

pub struct Enemy {
pub mut:
	id           int
	enemy_type   EnemyType
	state        EnemyState
	x            f32
	y            f32
	vx           f32
	vy           f32
	width        f32 = 28.0
	height       f32 = 28.0
	facing_right bool = true
	is_grounded  bool
	stun_timer   f32
	angry_level  int // 0 = normal, 1 = angry for crab
	hop_timer    f32 // For Fighter Fly
	anim_timer   f32
	pipe_timer   f32
	pipe_target  int // 0 = top left, 1 = top right
	active       bool = true
}

pub struct Coin {
pub mut:
	x           f32
	y           f32
	vx          f32
	vy          f32
	width       f32 = 20.0
	height      f32 = 20.0
	is_grounded bool
	anim_timer  f32
	life_timer  f32 = 14.0
	active      bool = true
}

pub struct ScorePopup {
pub mut:
	x      f32
	y      f32
	text   string
	color  Color
	timer  f32 = 0.9
	active bool = true
}

pub struct Particle {
pub mut:
	x      f32
	y      f32
	vx     f32
	vy     f32
	color  Color
	life   f32
	max_l  f32
	size   f32
	active bool = true
}

pub struct PowBlock {
pub mut:
	x           f32 = 376.0
	y           f32 = 384.0
	w           f32 = 48.0
	h           f32 = 32.0
	hits_left   int = 3
	active      bool = true
	shake_timer f32
}

pub struct MarioBrosGame {
pub mut:
	state              GameState = .title
	mode               GameMode  = .single_player
	phase              int       = 1
	high_score         int       = 20000
	players            []Player
	enemies            []Enemy
	coins              []Coin
	platforms          []Platform
	bump_waves         []BumpWave
	shockwaves         []Shockwave
	water_drips        []WaterDrip
	score_popups       []ScorePopup
	particles          []Particle
	pow_block          PowBlock
	sound_mgr          SoundManager
	spawn_timer        f32
	enemies_left       int
	total_in_phase     int
	screen_shake       f32
	shake_offset_x     f32
	shake_offset_y     f32
	phase_timer        f32
	bonus_timer        f32
	fireball_timer     f32
	drip_spawn_timer   f32
	phase_banner_timer f32
	combo_banner       string
	combo_banner_timer f32
	crt_filter         bool = true
	// Controls
	p1_left            bool
	p1_right           bool
	p1_jump            bool
	p2_left            bool
	p2_right           bool
	p2_jump            bool
}

pub fn new_mario_bros_game() MarioBrosGame {
	mut g := MarioBrosGame{
		sound_mgr: new_sound_manager()
	}
	g.init_platforms()
	g.reset_to_title()
	return g
}

pub fn (mut g MarioBrosGame) init_platforms() {
	g.platforms.clear()
	// Ground floor
	g.platforms << Platform{ x: 0.0, y: 540.0, w: 800.0, h: 60.0, is_ice: false }

	// Tier 1 (Top)
	g.platforms << Platform{ x: 0.0, y: 160.0, w: 340.0, h: 22.0, is_ice: false }
	g.platforms << Platform{ x: 460.0, y: 160.0, w: 340.0, h: 22.0, is_ice: false }

	// Tier 2 (Middle)
	g.platforms << Platform{ x: 170.0, y: 290.0, w: 460.0, h: 22.0, is_ice: false }

	// Tier 3 (Lower)
	g.platforms << Platform{ x: 0.0, y: 416.0, w: 320.0, h: 22.0, is_ice: false }
	g.platforms << Platform{ x: 480.0, y: 416.0, w: 320.0, h: 22.0, is_ice: false }
}

pub fn (mut g MarioBrosGame) reset_to_title() {
	g.state = .title
	g.players.clear()
	g.enemies.clear()
	g.coins.clear()
	g.bump_waves.clear()
	g.shockwaves.clear()
	g.water_drips.clear()
	g.score_popups.clear()
	g.particles.clear()
}

pub fn (mut g MarioBrosGame) start_game(mode GameMode) {
	g.mode = mode
	g.phase = 1
	g.state = .playing
	g.players.clear()

	// Mario (P1)
	g.players << Player{
		id: 1
		x: 240.0
		y: 490.0
		facing_right: true
		lives: 3
		score: 0
		invuln_timer: 2.0
	}

	// Luigi (P2) if 2-player mode
	if mode == .two_players {
		g.players << Player{
			id: 2
			x: 560.0
			y: 490.0
			facing_right: false
			lives: 3
			score: 0
			invuln_timer: 2.0
		}
	}

	g.pow_block = PowBlock{ hits_left: 3, active: true }
	g.setup_phase(1)
}

pub fn (mut g MarioBrosGame) setup_phase(phase_num int) {
	g.phase = phase_num
	g.enemies.clear()
	g.coins.clear()
	g.bump_waves.clear()
	g.shockwaves.clear()
	g.water_drips.clear()
	g.score_popups.clear()
	g.particles.clear()
	g.phase_timer = 0.0
	g.fireball_timer = 0.0
	g.phase_banner_timer = 2.2

	// Is this a bonus phase? (Every 4th phase starting at phase 3)
	if phase_num == 3 || (phase_num > 3 && (phase_num - 3) % 5 == 0) {
		g.state = .bonus_phase
		g.bonus_timer = 20.0 // 20 seconds bonus round
		g.spawn_bonus_coins()
		return
	}

	g.state = .playing
	// Determine enemy count and composition based on phase
	count := int(math.min(5 + phase_num * 2, 16))
	g.total_in_phase = count
	g.enemies_left = count
	g.spawn_timer = 1.0

	// Reset POW hits every few phases
	if phase_num % 4 == 1 {
		g.pow_block.hits_left = 3
		g.pow_block.active = true
	}
}

pub fn (mut g MarioBrosGame) spawn_bonus_coins() {
	g.coins.clear()
	// Spawn 10 golden coins across all platforms
	positions := [
		[f32(100.0), f32(130.0)], [f32(250.0), f32(130.0)], [f32(550.0), f32(130.0)], [f32(700.0), f32(130.0)],
		[f32(240.0), f32(260.0)], [f32(400.0), f32(260.0)], [f32(560.0), f32(260.0)],
		[f32(140.0), f32(386.0)], [f32(660.0), f32(386.0)],
		[f32(400.0), f32(510.0)],
	]
	for pos in positions {
		g.coins << Coin{
			x: pos[0]
			y: pos[1]
			vx: 0.0
			vy: 0.0
			is_grounded: true
			life_timer: 25.0
			active: true
		}
	}
}

pub fn (mut g MarioBrosGame) spawn_enemy() {
	if g.enemies_left <= 0 {
		return
	}
	g.enemies_left--

	// Determine enemy type based on phase and randomness
	mut e_type := EnemyType.shellcreeper
	r := rand.intn(100) or { 50 }

	if g.phase == 1 {
		e_type = .shellcreeper
	} else if g.phase == 2 {
		e_type = if r < 60 { EnemyType.shellcreeper } else { EnemyType.fighterfly }
	} else if g.phase >= 4 {
		if r < 40 {
			e_type = .sidestepper
		} else if r < 70 {
			e_type = .fighterfly
		} else if r < 90 {
			e_type = .shellcreeper
		} else {
			e_type = .slipice
		}
	}

	from_left := (rand.intn(2) or { 0 }) == 0
	start_x := if from_left { f32(40.0) } else { f32(760.0) }
	dir := if from_left { f32(1.0) } else { f32(-1.0) }
	base_speed := 95.0 + f32(g.phase * 6)

	mut enemy := Enemy{
		id: g.total_in_phase - g.enemies_left
		enemy_type: e_type
		state: .walking
		x: start_x
		y: 86.0
		vx: dir * base_speed
		vy: 0.0
		facing_right: from_left
		is_grounded: true
		active: true
	}

	if e_type == .fighterfly {
		enemy.hop_timer = 0.5
	}

	g.enemies << enemy
	g.sound_mgr.play_pipe()

	// Spawn sewer pipe smoke / steam particles
	g.add_particles(start_x, 100.0, 8, Color{ r: 70, g: 200, b: 90, a: 200 })
}

pub fn (mut g MarioBrosGame) hit_pow_block() {
	if !g.pow_block.active || g.pow_block.hits_left <= 0 {
		return
	}

	g.pow_block.hits_left--
	if g.pow_block.hits_left <= 0 {
		g.pow_block.active = false
		// Block shatter explosion
		g.add_particles(g.pow_block.x + g.pow_block.w * 0.5, g.pow_block.y + g.pow_block.h * 0.5, 30, Color{ r: 100, g: 190, b: 255, a: 255 })
	}
	g.pow_block.shake_timer = 0.4
	g.screen_shake = 0.45
	g.sound_mgr.play_pow()

	// Expanding shockwave ring across screen
	g.shockwaves << Shockwave{
		x: g.pow_block.x + g.pow_block.w * 0.5
		y: g.pow_block.y + g.pow_block.h * 0.5
		radius: 12.0
		max_r: 480.0
		timer: 0.45
		duration: 0.45
		color: Color{ r: 100, g: 220, b: 255, a: 255 }
		active: true
	}

	// Flip/damage all grounded enemies
	for mut e in g.enemies {
		if !e.active || e.state == .kicked || e.state == .in_pipe {
			continue
		}
		if e.is_grounded {
			g.bump_enemy(mut e)
		}
	}

	// Remove any active fireballs
	for mut e in g.enemies {
		if e.active && e.enemy_type == .fireball {
			e.active = false
			g.add_particles(e.x + 14.0, e.y + 14.0, 16, Color{ r: 255, g: 100, b: 0, a: 255 })
		}
	}
}

pub fn (mut g MarioBrosGame) bump_enemy(mut e Enemy) {
	match e.enemy_type {
		.shellcreeper {
			if e.state == .walking || e.state == .angry {
				e.state = .stunned
				e.stun_timer = 8.5
				e.vy = -200.0
				e.is_grounded = false
				g.sound_mgr.play_flip()
				g.add_particles(e.x + 14.0, e.y + 14.0, 10, Color{ r: 255, g: 230, b: 80, a: 255 })
			} else if e.state == .stunned || e.state == .recovering {
				e.state = .walking
				e.vy = -120.0
				e.is_grounded = false
			}
		}
		.sidestepper {
			if e.state == .walking {
				e.state = .angry
				e.angry_level = 1
				dir := if e.facing_right { f32(1.0) } else { f32(-1.0) }
				e.vx = dir * 170.0
				e.vy = -160.0
				e.is_grounded = false
				g.sound_mgr.play_bump()
				// Steam / anger puff
				g.add_particles(e.x + 14.0, e.y + 8.0, 8, Color{ r: 255, g: 60, b: 60, a: 255 })
			} else if e.state == .angry {
				e.state = .stunned
				e.stun_timer = 6.5
				e.vy = -200.0
				e.is_grounded = false
				g.sound_mgr.play_flip()
				g.add_particles(e.x + 14.0, e.y + 14.0, 12, Color{ r: 255, g: 200, b: 50, a: 255 })
			} else if e.state == .stunned || e.state == .recovering {
				e.state = .angry
				e.vy = -120.0
				e.is_grounded = false
			}
		}
		.fighterfly {
			if e.is_grounded && (e.state == .walking || e.state == .angry) {
				e.state = .stunned
				e.stun_timer = 8.0
				e.vy = -200.0
				e.is_grounded = false
				g.sound_mgr.play_flip()
				g.add_particles(e.x + 14.0, e.y + 14.0, 10, Color{ r: 180, g: 140, b: 255, a: 255 })
			} else if e.state == .stunned || e.state == .recovering {
				e.state = .walking
				e.vy = -120.0
				e.is_grounded = false
			}
		}
		.slipice {
			e.active = false
			g.add_particles(e.x + 14.0, e.y + 14.0, 20, Color{ r: 150, g: 230, b: 255, a: 255 })
			g.add_score_popup(e.x, e.y, '500', Color{ r: 100, g: 240, b: 255, a: 255 })
			if g.players.len > 0 {
				g.players[0].score += 500
			}
			g.sound_mgr.play_kick()
		}
		.fireball {
			e.active = false
			g.add_particles(e.x + 14.0, e.y + 14.0, 16, Color{ r: 255, g: 120, b: 20, a: 255 })
			g.sound_mgr.play_kick()
		}
	}
}

pub fn (mut g MarioBrosGame) trigger_bump_wave(x f32, y f32) {
	g.bump_waves << BumpWave{
		x: x
		y: y
		radius: 48.0
		timer: 0.22
		duration: 0.22
		active: true
	}
	g.sound_mgr.play_bump()

	// Platform dust particles
	g.add_particles(x, y, 6, Color{ r: 140, g: 180, b: 220, a: 200 })

	// Check if this bump hit the POW block
	if g.pow_block.active && g.pow_block.hits_left > 0 {
		pow_cx := g.pow_block.x + g.pow_block.w * 0.5
		pow_cy := g.pow_block.y + g.pow_block.h
		if math.abs(x - pow_cx) < 32.0 && math.abs(y - pow_cy) < 18.0 {
			g.hit_pow_block()
			return
		}
	}

	// Check enemies standing on the platform above the bump point
	for mut e in g.enemies {
		if !e.active || e.state == .kicked || e.state == .in_pipe {
			continue
		}
		// Must be on the same horizontal platform span and right above the bump
		if math.abs(e.x + e.width * 0.5 - x) < 46.0 && math.abs((e.y + e.height) - y) < 18.0 {
			g.bump_enemy(mut e)
		}
	}

	// Check coins above bump
	for mut c in g.coins {
		if c.active && math.abs(c.x + c.width * 0.5 - x) < 40.0 && math.abs((c.y + c.height) - y) < 18.0 {
			c.vy = -240.0
			c.is_grounded = false
			g.add_particles(c.x + 10.0, c.y + 10.0, 5, Color{ r: 255, g: 230, b: 60, a: 255 })
		}
	}
}

pub fn (mut g MarioBrosGame) add_score_popup(x f32, y f32, text string, color Color) {
	g.score_popups << ScorePopup{
		x: x
		y: y
		text: text
		color: color
		timer: 0.9
		active: true
	}
}

pub fn (mut g MarioBrosGame) add_particles(x f32, y f32, count int, color Color) {
	for _ in 0 .. count {
		angle := f32(rand.intn(360) or { 0 }) * f32(math.pi / 180.0)
		speed := 50.0 + f32(rand.intn(120) or { 60 })
		g.particles << Particle{
			x: x
			y: y
			vx: f32(math.cos(f64(angle))) * speed
			vy: f32(math.sin(f64(angle))) * speed
			color: color
			life: 0.4 + f32(rand.intn(40) or { 20 }) / 100.0
			max_l: 0.8
			size: 3.0 + f32(rand.intn(3) or { 1 })
			active: true
		}
	}
}

pub fn (mut g MarioBrosGame) spawn_coin_from_pipe(p_idx int) {
	x := if p_idx == 0 { f32(40.0) } else { f32(760.0) }
	vx := if p_idx == 0 { f32(90.0) } else { f32(-90.0) }
	g.coins << Coin{
		x: x
		y: 86.0
		vx: vx
		vy: 0.0
		is_grounded: true
		life_timer: 15.0
		active: true
	}
}

pub fn (mut g MarioBrosGame) update(dt f32) {
	if g.state == .paused || g.state == .title || g.state == .game_over {
		return
	}

	g.phase_timer += dt
	gravity := f32(650.0)

	// Phase banner animation timer
	if g.phase_banner_timer > 0.0 {
		g.phase_banner_timer -= dt
	}

	// Combo banner timer
	if g.combo_banner_timer > 0.0 {
		g.combo_banner_timer -= dt
	}

	// Sewer water drip spawner
	g.drip_spawn_timer += dt
	if g.drip_spawn_timer > 1.8 {
		g.drip_spawn_timer = 0.0
		r_val := f32(rand.intn(30) or { 0 })
		drip_x := if (rand.intn(2) or { 0 }) == 0 { 60.0 + r_val } else { 710.0 + r_val }
		g.water_drips << WaterDrip{ x: drip_x, y: 130.0, active: true }
	}

	// Update water drips
	for mut wd in g.water_drips {
		if !wd.active {
			continue
		}
		wd.y += wd.vy * dt
		if wd.y >= 540.0 {
			wd.active = false
			// Water splash ripple particles
			g.add_particles(wd.x, 540.0, 4, Color{ r: 80, g: 180, b: 240, a: 180 })
		}
	}
	g.water_drips = g.water_drips.filter(it.active)

	// Screen shake decay
	if g.screen_shake > 0.0 {
		g.screen_shake -= dt
		if g.screen_shake <= 0.0 {
			g.screen_shake = 0.0
			g.shake_offset_x = 0.0
			g.shake_offset_y = 0.0
		} else {
			g.shake_offset_x = f32(rand.intn(13) or { 6 }) - 6.0
			g.shake_offset_y = f32(rand.intn(13) or { 6 }) - 6.0
		}
	}

	// Update POW block shake
	if g.pow_block.shake_timer > 0.0 {
		g.pow_block.shake_timer -= dt
	}

	// 1. Update Bump Waves
	for mut bw in g.bump_waves {
		if !bw.active {
			continue
		}
		bw.timer -= dt
		if bw.timer <= 0.0 {
			bw.active = false
		}
	}
	g.bump_waves = g.bump_waves.filter(it.active)

	// 1b. Update Shockwaves
	for mut sw in g.shockwaves {
		if !sw.active {
			continue
		}
		sw.timer -= dt
		sw.radius += (sw.max_r / sw.duration) * dt
		if sw.timer <= 0.0 {
			sw.active = false
		}
	}
	g.shockwaves = g.shockwaves.filter(it.active)

	// 2. Bonus Phase Timer
	if g.state == .bonus_phase {
		g.bonus_timer -= dt
		if g.bonus_timer <= 0.0 || g.coins.len == 0 {
			// Perfect bonus award
			if g.coins.len == 0 && g.players.len > 0 {
				g.players[0].score += 5000
				g.add_score_popup(400.0, 300.0, 'PERFECT 5000!', Color{ r: 255, g: 230, b: 0, a: 255 })
			}
			g.state = .phase_clear
			g.sound_mgr.play_phase_clear()
			return
		}
	}

	// 3. Enemy Spawning in normal phases
	if g.state == .playing {
		if g.enemies_left > 0 {
			g.spawn_timer -= dt
			if g.spawn_timer <= 0.0 {
				g.spawn_enemy()
				g.spawn_timer = f32(2.4 - math.min(f64(g.phase) * 0.1, 1.4))
			}
		}

		// Fireball hazard if phase takes long
		g.fireball_timer += dt
		if g.fireball_timer > 16.0 {
			g.fireball_timer = 0.0
			fb_vx := if (rand.intn(2) or { 0 }) == 0 { f32(160.0) } else { f32(-160.0) }
			g.enemies << Enemy{
				id: 999
				enemy_type: .fireball
				state: .walking
				x: if (rand.intn(2) or { 0 }) == 0 { f32(20.0) } else { f32(780.0) }
				y: 200.0 + f32(rand.intn(250) or { 100 })
				vx: fb_vx
				vy: 0.0
				facing_right: true
				is_grounded: false
				active: true
			}
		}
	}

	// 4. Update Players
	for mut p in g.players {
		if p.is_dead {
			p.dead_timer -= dt
			p.vy += gravity * dt
			p.y += p.vy * dt
			if p.dead_timer <= 0.0 {
				if p.lives > 0 {
					p.lives--
					if p.lives > 0 {
						p.is_dead = false
						p.x = if p.id == 1 { f32(240.0) } else { f32(560.0) }
						p.y = 490.0
						p.vx = 0.0
						p.vy = 0.0
						p.invuln_timer = 3.0
					} else {
						// Check if all players dead
						mut any_alive := false
						for check_p in g.players {
							if check_p.lives > 0 {
								any_alive = true
							}
						}
						if !any_alive {
							g.state = .game_over
						}
					}
				}
			}
			continue
		}

		if p.invuln_timer > 0.0 {
			p.invuln_timer -= dt
		}

		// Player Combo Decay
		if p.combo_timer > 0.0 {
			p.combo_timer -= dt
			if p.combo_timer <= 0.0 {
				p.combo_count = 0
			}
		}

		// Input Controls
		left_pressed := if p.id == 1 { g.p1_left } else { g.p2_left }
		right_pressed := if p.id == 1 { g.p1_right } else { g.p2_right }
		jump_pressed := if p.id == 1 { g.p1_jump } else { g.p2_jump }

		accel := f32(800.0)
		friction := f32(650.0)
		max_vx := f32(230.0)

		if left_pressed {
			p.vx -= accel * dt
			if p.vx < -max_vx {
				p.vx = -max_vx
			}
			p.facing_right = false
			p.is_skidding = p.vx > 30.0
			// Skid dust
			if p.is_skidding && p.is_grounded && (rand.intn(3) or { 0 }) == 0 {
				g.add_particles(p.x + p.width * 0.5, p.y + p.height - 2.0, 2, Color{ r: 200, g: 200, b: 200, a: 160 })
			}
		} else if right_pressed {
			p.vx += accel * dt
			if p.vx > max_vx {
				p.vx = max_vx
			}
			p.facing_right = true
			p.is_skidding = p.vx < -30.0
			if p.is_skidding && p.is_grounded && (rand.intn(3) or { 0 }) == 0 {
				g.add_particles(p.x + p.width * 0.5, p.y + p.height - 2.0, 2, Color{ r: 200, g: 200, b: 200, a: 160 })
			}
		} else {
			p.is_skidding = false
			if p.vx > 0.0 {
				p.vx -= friction * dt
				if p.vx < 0.0 {
					p.vx = 0.0
				}
			} else if p.vx < 0.0 {
				p.vx += friction * dt
				if p.vx > 0.0 {
					p.vx = 0.0
				}
			}
		}

		// Jump
		if jump_pressed && p.is_grounded && !p.is_jumping {
			p.vy = -430.0
			p.is_grounded = false
			p.is_jumping = true
			g.sound_mgr.play_jump()
			// Jump takeoff dust
			g.add_particles(p.x + p.width * 0.5, p.y + p.height, 4, Color{ r: 180, g: 180, b: 200, a: 180 })
		}

		// Gravity
		p.vy += gravity * dt
		if p.vy > 600.0 {
			p.vy = 600.0
		}

		// Apply velocity
		old_y := p.y
		p.x += p.vx * dt
		p.y += p.vy * dt

		// Screen Wrap-Around
		if p.x < -p.width {
			p.x = 800.0
		} else if p.x > 800.0 {
			p.x = -p.width
		}

		// Platform Collision
		p.is_grounded = false
		for plat in g.platforms {
			// Land on top
			if old_y + p.height <= plat.y + 4.0 && p.y + p.height >= plat.y {
				if p.x + p.width > plat.x && p.x < plat.x + plat.w {
					p.y = plat.y - p.height
					p.vy = 0.0
					p.is_grounded = true
					p.is_jumping = false
				}
			}
			// Head bump underneath platform!
			else if p.vy < 0.0 && old_y >= plat.y + plat.h - 4.0 && p.y <= plat.y + plat.h {
				if p.x + p.width > plat.x && p.x < plat.x + plat.w {
					p.y = plat.y + plat.h
					p.vy = 40.0 // Bounce back down
					g.trigger_bump_wave(p.x + p.width * 0.5, plat.y)
				}
			}
		}

		// POW Block top landing / bottom bumping
		if g.pow_block.active && g.pow_block.hits_left > 0 {
			pb := g.pow_block
			// Land on top of POW block
			if old_y + p.height <= pb.y + 4.0 && p.y + p.height >= pb.y {
				if p.x + p.width > pb.x && p.x < pb.x + pb.w {
					p.y = pb.y - p.height
					p.vy = 0.0
					p.is_grounded = true
					p.is_jumping = false
				}
			}
			// Bump underside of POW block
			else if p.vy < 0.0 && old_y >= pb.y + pb.h - 4.0 && p.y <= pb.y + pb.h {
				if p.x + p.width > pb.x && p.x < pb.x + pb.w {
					p.y = pb.y + pb.h
					p.vy = 40.0
					g.trigger_bump_wave(pb.x + pb.w * 0.5, pb.y + pb.h)
				}
			}
		}

		// Animation frame stepping
		if math.abs(p.vx) > 10.0 {
			p.anim_timer += dt * 10.0
			p.walk_frame = int(p.anim_timer) % 4
		} else {
			p.walk_frame = 0
		}

		// High score sync
		if p.score > g.high_score {
			g.high_score = p.score
		}
	}

	// 5. Update Enemies
	for mut e in g.enemies {
		if !e.active {
			continue
		}

		// Kicked enemy flying out of stage
		if e.state == .kicked {
			e.vy += gravity * dt
			e.x += e.vx * dt
			e.y += e.vy * dt
			if e.y > 620.0 {
				e.active = false
			}
			continue
		}

		// In pipe transit
		if e.state == .in_pipe {
			e.pipe_timer -= dt
			if e.pipe_timer <= 0.0 {
				e.state = .walking
				e.x = if e.pipe_target == 0 { f32(40.0) } else { f32(760.0) }
				e.y = 86.0
				e.facing_right = e.pipe_target == 0
				e_dir := if e.facing_right { f32(1.0) } else { f32(-1.0) }
				e.vx = e_dir * (100.0 + f32(g.phase * 8))
				e.vy = 0.0
				g.sound_mgr.play_pipe()
			}
			continue
		}

		// Stun timer & recovery
		if e.state == .stunned || e.state == .recovering {
			e.stun_timer -= dt
			if e.stun_timer < 2.2 && e.state == .stunned {
				e.state = .recovering
			}
			if e.stun_timer <= 0.0 {
				// Rights itself and gets angry!
				e.state = if e.enemy_type == .sidestepper { .angry } else { .walking }
				rec_dir := if e.facing_right { f32(1.0) } else { f32(-1.0) }
				e.vx = rec_dir * (130.0 + f32(g.phase * 8))
				e.vy = -140.0
				e.is_grounded = false
			}
		}

		// Fighter Fly hopping mechanics
		if e.enemy_type == .fighterfly && (e.state == .walking || e.state == .angry) {
			if e.is_grounded {
				e.hop_timer -= dt
				if e.hop_timer <= 0.0 {
					e.vy = -280.0
					e.is_grounded = false
					e.hop_timer = 0.9
					// Hop dust
					g.add_particles(e.x + e.width * 0.5, e.y + e.height, 3, Color{ r: 170, g: 150, b: 220, a: 160 })
				}
			}
		}

		// Fireball sinusoidal motion
		if e.enemy_type == .fireball {
			e.anim_timer += dt * 8.0
			e.y += f32(math.sin(f64(e.anim_timer)) * 3.0)
			e.x += e.vx * dt
			// Flame trail
			if (rand.intn(2) or { 0 }) == 0 {
				g.add_particles(e.x + 14.0, e.y + 14.0, 1, Color{ r: 255, g: 140, b: 20, a: 180 })
			}
			if e.x < -40.0 || e.x > 840.0 {
				e.active = false
			}
			continue
		}

		// Gravity
		e.vy += gravity * dt
		if e.vy > 550.0 {
			e.vy = 550.0
		}

		old_ey := e.y
		if e.state != .stunned && e.state != .recovering {
			e.x += e.vx * dt
		}
		e.y += e.vy * dt

		// Screen Wrap-Around for enemies
		if e.x < -e.width {
			e.x = 800.0
		} else if e.x > 800.0 {
			e.x = -e.width
		}

		// Bottom pipe entry when walking into corners on ground floor
		if e.is_grounded && e.y >= 500.0 && (e.state == .walking || e.state == .angry) {
			if e.x < 50.0 && !e.facing_right {
				e.state = .in_pipe
				e.pipe_timer = 2.0
				e.pipe_target = 1 // Emerge from top right
				g.sound_mgr.play_pipe()
				continue
			} else if e.x > 720.0 && e.facing_right {
				e.state = .in_pipe
				e.pipe_timer = 2.0
				e.pipe_target = 0 // Emerge from top left
				g.sound_mgr.play_pipe()
				continue
			}
		}

		// Platform collision for enemies
		e.is_grounded = false
		for plat in g.platforms {
			if old_ey + e.height <= plat.y + 6.0 && e.y + e.height >= plat.y {
				if e.x + e.width > plat.x && e.x < plat.x + plat.w {
					e.y = plat.y - e.height
					e.vy = 0.0
					e.is_grounded = true
				}
			}
		}
	}

	// 6. Update Coins
	for mut c in g.coins {
		if !c.active {
			continue
		}
		c.life_timer -= dt
		if c.life_timer <= 0.0 {
			c.active = false
			continue
		}
		c.anim_timer += dt * 8.0

		c.vy += gravity * dt
		if c.vy > 500.0 {
			c.vy = 500.0
		}

		old_cy := c.y
		c.x += c.vx * dt
		c.y += c.vy * dt

		if c.x < -c.width {
			c.x = 800.0
		} else if c.x > 800.0 {
			c.x = -c.width
		}

		c.is_grounded = false
		for plat in g.platforms {
			if old_cy + c.height <= plat.y + 6.0 && c.y + c.height >= plat.y {
				if c.x + c.width > plat.x && c.x < plat.x + plat.w {
					c.y = plat.y - c.height
					c.vy = 0.0
					c.is_grounded = true
				}
			}
		}
	}

	// 7. Player-Enemy & Player-Coin Collisions
	for mut p in g.players {
		if p.is_dead {
			continue
		}

		// Check Enemy Interaction
		for mut e in g.enemies {
			if !e.active || e.state == .kicked || e.state == .in_pipe {
				continue
			}

			// AABB overlap test
			if p.x + p.width > e.x && p.x < e.x + e.width && p.y + p.height > e.y
				&& p.y < e.y + e.height {
				// If enemy is stunned/recovering: KICK IT!
				if e.state == .stunned || e.state == .recovering {
					e.state = .kicked
					kick_dir := if p.facing_right { f32(300.0) } else { f32(-300.0) }
					e.vx = kick_dir
					e.vy = -320.0
					g.sound_mgr.play_kick()

					// Combo multiplier
					p.combo_count++
					p.combo_timer = 2.0
					pts := match p.combo_count {
						1 { 800 }
						2 { 1600 }
						3 { 2400 }
						else { 3200 }
					}
					p.score += pts

					// Combo Notification Banner
					if p.combo_count > 1 {
						g.combo_banner = '${p.combo_count}X COMBO +${pts}!'
						g.combo_banner_timer = 1.2
					}

					g.add_score_popup(e.x, e.y, '${pts}', Color{ r: 255, g: 240, b: 60, a: 255 })
					g.add_particles(e.x + 14.0, e.y + 14.0, 18, Color{ r: 255, g: 220, b: 50, a: 255 })

					// Coin reward from sewer pipe
					g.spawn_coin_from_pipe(rand.intn(2) or { 0 })
				}
				// If enemy is upright & player not invulnerable: Player dies!
				else if p.invuln_timer <= 0.0 {
					p.is_dead = true
					p.dead_timer = 2.2
					p.vy = -380.0
					g.sound_mgr.play_die()
					g.add_particles(p.x + 14.0, p.y + 18.0, 24, Color{ r: 255, g: 60, b: 60, a: 255 })
				}
			}
		}

		// Check Coin Collection
		for mut c in g.coins {
			if !c.active {
				continue
			}
			if p.x + p.width > c.x && p.x < c.x + c.width && p.y + p.height > c.y
				&& p.y < c.y + c.height {
				c.active = false
				p.score += 800
				g.sound_mgr.play_coin()
				g.add_score_popup(c.x, c.y, '800', Color{ r: 255, g: 240, b: 80, a: 255 })
				g.add_particles(c.x + 10.0, c.y + 10.0, 14, Color{ r: 255, g: 230, b: 60, a: 255 })
			}
		}
	}

	// 8. Update Score Popups
	for mut sp in g.score_popups {
		if !sp.active {
			continue
		}
		sp.timer -= dt
		sp.y -= 35.0 * dt
		if sp.timer <= 0.0 {
			sp.active = false
		}
	}
	g.score_popups = g.score_popups.filter(it.active)

	// 9. Update Particles
	for mut pt in g.particles {
		if !pt.active {
			continue
		}
		pt.life -= dt
		pt.x += pt.vx * dt
		pt.y += pt.vy * dt
		if pt.life <= 0.0 {
			pt.active = false
		}
	}
	g.particles = g.particles.filter(it.active)
	g.coins = g.coins.filter(it.active)

	// 10. Check Phase Victory (all enemies spawned and cleared)
	if g.state == .playing {
		mut active_enemies := 0
		for e in g.enemies {
			if e.active && e.enemy_type != .fireball {
				active_enemies++
			}
		}
		if g.enemies_left <= 0 && active_enemies == 0 {
			g.state = .phase_clear
			g.sound_mgr.play_phase_clear()
		}
	}
}

pub fn (mut g MarioBrosGame) next_phase() {
	g.setup_phase(g.phase + 1)
}
