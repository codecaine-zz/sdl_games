module main

import rand

pub enum GameMode {
	game_a
	game_b
}

pub enum GameState {
	title
	playing
	game_over
}

pub struct Jumper {
pub mut:
	step     int  // 0 to 13
	active   bool
	crashed  bool
}

pub struct FireGame {
pub mut:
	trampoline_pos int = 1 // 0: Left, 1: Middle, 2: Right
	jumpers        []Jumper
	score          int
	high_score     int
	misses         int
	state          GameState = .title
	mode           GameMode  = .game_a
	tick_timer     f64
	tick_interval  f64 = 0.40
	spawn_timer    int
	last_event     string
}

pub fn new_fire_game() FireGame {
	mut g := FireGame{
		state: .title
		high_score: 0
	}
	return g
}

pub fn (mut g FireGame) start_game(mode GameMode) {
	g.mode = mode
	g.score = 0
	g.misses = 0
	g.trampoline_pos = 1
	g.jumpers.clear()
	g.state = .playing
	g.tick_timer = 0.0
	g.tick_interval = if mode == .game_a { 0.38 } else { 0.28 }
	g.spawn_timer = 2
	g.last_event = 'START'
}

pub fn (mut g FireGame) move_left() {
	if g.trampoline_pos > 0 {
		g.trampoline_pos--
	}
}

pub fn (mut g FireGame) move_right() {
	if g.trampoline_pos < 2 {
		g.trampoline_pos++
	}
}

pub fn (mut g FireGame) set_pos(pos int) {
	if pos >= 0 && pos <= 2 {
		g.trampoline_pos = pos
	}
}

pub fn (mut g FireGame) update(dt f64, mut sm SoundManager) {
	if g.state != .playing {
		return
	}

	g.tick_timer += dt
	if g.tick_timer < g.tick_interval {
		return
	}
	g.tick_timer = 0.0

	// Adaptive speed based on score
	base_interval := if g.mode == .game_a { 0.36 } else { 0.26 }
	speedup := f64(g.score) * 0.0012
	g.tick_interval = if base_interval - speedup > 0.16 { base_interval - speedup } else { 0.16 }

	// Spawn new jumpers
	g.spawn_timer--
	if g.spawn_timer <= 0 {
		// Spawn frequency based on score and mode
		active_count := g.jumpers.filter(it.active).len
		max_active := if g.mode == .game_a { (g.score / 20) + 1 } else { (g.score / 15) + 2 }
		clamped_max := if max_active > 4 { 4 } else { max_active }

		if active_count < clamped_max {
			g.jumpers << Jumper{
				step: 0
				active: true
				crashed: false
			}
			sm.play_tick()
		}
		spawn_delay := if g.mode == .game_a { rand.int_in_range(4, 8) or { 5 } } else { rand.int_in_range(3, 6) or { 4 } }
		g.spawn_timer = spawn_delay
	}

	// Advance existing jumpers
	mut i := 0
	for i < g.jumpers.len {
		if !g.jumpers[i].active {
			g.jumpers.delete(i)
			continue
		}

		if g.jumpers[i].crashed {
			g.jumpers[i].active = false
			i++
			continue
		}

		g.jumpers[i].step++
		cur_step := g.jumpers[i].step

		// Bounce checks at trampoline heights:
		// Step 3 -> Pos 0 (Left)
		if cur_step == 3 {
			if g.trampoline_pos == 0 {
				sm.play_bounce()
				g.score++
			} else {
				g.jumpers[i].crashed = true
				g.misses++
				sm.play_miss()
			}
		} else if cur_step == 7 {
			// Step 7 -> Pos 1 (Middle)
			if g.trampoline_pos == 1 {
				sm.play_bounce()
				g.score++
			} else {
				g.jumpers[i].crashed = true
				g.misses++
				sm.play_miss()
			}
		} else if cur_step == 11 {
			// Step 11 -> Pos 2 (Right)
			if g.trampoline_pos == 2 {
				sm.play_bounce()
				g.score++
			} else {
				g.jumpers[i].crashed = true
				g.misses++
				sm.play_miss()
			}
		} else if cur_step == 13 {
			// Safe in ambulance
			g.score += 2
			g.jumpers[i].active = false
			sm.play_score()
		} else {
			sm.play_tick()
		}

		if g.score > g.high_score {
			g.high_score = g.score
		}

		if g.misses >= 3 {
			g.state = .game_over
			sm.play_game_over()
			break
		}

		i++
	}
}
