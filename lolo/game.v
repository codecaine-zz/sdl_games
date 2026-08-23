module main

import math

pub const grid_cols = 11
pub const grid_rows = 11
pub const cell_size = 48
pub const grid_offset_x = 50
pub const grid_offset_y = 90
pub const win_w = 960
pub const win_h = 680

pub enum Direction {
	up
	down
	left
	right
}

pub enum TileType {
	grass
	wall
	rock
	tree
	water
	bridge
	arrow_up
	arrow_down
	arrow_left
	arrow_right
}

pub enum EntityType {
	none
	emerald_frame
	heart_frame
	chest
	door
	hammer
	lolo_spawn
	snakey
	alma
	leeper
	skull
	medusa
	don_medusa_h
	don_medusa_v
	gol
	king_egger
}

pub enum GameMode {
	play
	editor
}

pub enum GameStatus {
	playing
	paused
	won
	lost
	level_clear
}

pub struct Enemy {
pub mut:
	kind       EntityType
	x          int
	y          int
	spawn_x    int
	spawn_y    int
	dir        Direction
	is_egg     bool
	egg_timer  f64
	is_asleep  bool
	move_timer f64
	patrol_dir int = 1
}

pub struct LoloPlayer {
pub mut:
	x       int
	y       int
	dir     Direction = .down
	shots   int
	hammers int
	bridges int
	is_dead bool
}

pub struct MagicShot {
pub mut:
	x      f64
	y      f64
	vx     f64
	vy     f64
	dir    Direction
	active bool
}

pub struct Level {
pub mut:
	name     string
	floor    int = 1
	password string = "LOLO"
	grid     [11][11]TileType
	entities [11][11]EntityType
}

pub struct GameSnapshot {
pub:
	grid             [11][11]TileType
	entities         [11][11]EntityType
	chest_open       bool
	door_open        bool
	hearts_remaining int
	lolo             LoloPlayer
	enemies          []Enemy
	score            int
}

pub struct Game {
pub mut:
	mode                GameMode   = .play
	status              GameStatus = .playing
	current_level_idx   int
	campaign_levels     []Level
	current_level       Level
	grid                [11][11]TileType
	entities            [11][11]EntityType
	chest_open          bool
	door_open           bool
	hearts_remaining    int
	total_hearts        int
	score               int
	lives               int = 5
	moves_count         int
	lolo                LoloPlayer
	enemies             []Enemy
	magic_shot          MagicShot
	medusa_laser_active bool
	laser_x1            int
	laser_y1            int
	laser_x2            int
	laser_y2            int
	laser_timer         f64
	status_msg          string
	msg_timer           f64
	undo_stack          []GameSnapshot

	// Level Select Modal
	is_level_select_open bool

	// Level Editor
	editor_level       Level
	selected_tile      TileType   = .grass
	selected_entity    EntityType = .none
	is_entity_selected bool
	validation_msg     string
	is_testing_custom  bool
}

pub fn new_game() Game {
	mut g := Game{
		campaign_levels: get_default_levels()
	}
	g.editor_level = create_empty_level('Custom Level')
	g.load_level(0)
	return g
}

pub fn create_empty_level(name string) Level {
	mut lvl := Level{
		name: name
	}
	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			if r == 0 || r == grid_rows - 1 || c == 0 || c == grid_cols - 1 {
				lvl.grid[r][c] = .wall
			} else {
				lvl.grid[r][c] = .grass
			}
			lvl.entities[r][c] = .none
		}
	}
	lvl.grid[0][5] = .grass
	lvl.entities[0][5] = .door
	lvl.entities[2][5] = .chest
	lvl.entities[9][5] = .lolo_spawn
	lvl.entities[5][5] = .heart_frame
	return lvl
}

pub fn (mut g Game) load_level(idx int) {
	if idx < 0 || idx >= g.campaign_levels.len {
		return
	}
	g.current_level_idx = idx
	g.is_testing_custom = false
	g.load_level_struct(g.campaign_levels[idx])
}

pub fn (mut g Game) load_level_struct(lvl Level) {
	g.current_level = lvl
	g.grid = lvl.grid
	g.entities = lvl.entities
	g.chest_open = false
	g.door_open = false
	g.medusa_laser_active = false
	g.magic_shot.active = false
	g.status = .playing
	g.undo_stack.clear()
	g.moves_count = 0

	g.enemies.clear()
	g.hearts_remaining = 0

	mut spawn_x := 5
	mut spawn_y := 9

	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			ent := g.entities[r][c]
			match ent {
				.lolo_spawn {
					spawn_x = c
					spawn_y = r
				}
				.heart_frame {
					g.hearts_remaining++
				}
				.snakey, .alma, .leeper, .skull, .medusa, .don_medusa_h, .don_medusa_v, .gol, .king_egger {
					g.enemies << Enemy{
						kind:       ent
						x:          c
						y:          r
						spawn_x:    c
						spawn_y:    r
						dir:        .down
						is_egg:     false
						patrol_dir: 1
					}
					g.entities[r][c] = .none
				}
				else {}
			}
		}
	}

	g.total_hearts = g.hearts_remaining
	g.lolo = LoloPlayer{
		x:       spawn_x
		y:       spawn_y
		dir:     .down
		shots:   0
		hammers: 0
		bridges: 0
		is_dead: false
	}
}

pub fn (mut g Game) save_undo_snapshot() {
	snap := GameSnapshot{
		grid:             g.grid
		entities:         g.entities
		chest_open:       g.chest_open
		door_open:        g.door_open
		hearts_remaining: g.hearts_remaining
		lolo:             g.lolo
		enemies:          g.enemies.clone()
		score:            g.score
	}
	g.undo_stack << snap
	if g.undo_stack.len > 50 {
		g.undo_stack.delete(0)
	}
}

pub fn (mut g Game) undo() bool {
	if g.undo_stack.len == 0 || g.status != .playing {
		return false
	}
	snap := g.undo_stack.pop()
	g.grid = snap.grid
	g.entities = snap.entities
	g.chest_open = snap.chest_open
	g.door_open = snap.door_open
	g.hearts_remaining = snap.hearts_remaining
	g.lolo = snap.lolo
	g.enemies = snap.enemies.clone()
	g.score = snap.score
	g.medusa_laser_active = false
	g.magic_shot.active = false
	if g.moves_count > 0 { g.moves_count-- }
	return true
}

pub fn (mut g Game) update(dt f64) (bool, bool, bool, bool, bool, bool, bool, bool) {
	mut play_step := false
	mut play_heart := false
	mut play_shot := false
	mut play_egg := false
	mut play_push := false
	mut play_laser := false
	mut play_chest := false
	mut play_victory := false

	if g.msg_timer > 0 {
		g.msg_timer -= dt
	}

	if g.mode == .editor || g.is_level_select_open {
		return play_step, play_heart, play_shot, play_egg, play_push, play_laser, play_chest, play_victory
	}

	if g.status != .playing {
		return play_step, play_heart, play_shot, play_egg, play_push, play_laser, play_chest, play_victory
	}

	// Medusa laser strike timer
	if g.medusa_laser_active {
		g.laser_timer -= dt
		if g.laser_timer <= 0 {
			g.medusa_laser_active = false
			g.kill_lolo()
			play_laser = true
		}
		return play_step, play_heart, play_shot, play_egg, play_push, play_laser, play_chest, play_victory
	}

	// Update Magic Shot
	if g.magic_shot.active {
		shot_speed := 16.0
		g.magic_shot.x += g.magic_shot.vx * shot_speed * dt
		g.magic_shot.y += g.magic_shot.vy * shot_speed * dt

		cur_col := int(math.round(g.magic_shot.x))
		cur_row := int(math.round(g.magic_shot.y))

		if cur_col < 0 || cur_col >= grid_cols || cur_row < 0 || cur_row >= grid_rows {
			g.magic_shot.active = false
		} else {
			tile := g.grid[cur_row][cur_col]
			ent := g.entities[cur_row][cur_col]

			if tile == .wall || tile == .tree || tile == .rock || ent == .emerald_frame {
				g.magic_shot.active = false
			} else {
				for mut enemy in g.enemies {
					if enemy.x == cur_col && enemy.y == cur_row {
						if enemy.kind == .king_egger && g.chest_open {
							// Defeat King Egger!
							enemy.x = -99
							enemy.y = -99
							play_egg = true
						} else if !enemy.is_egg {
							enemy.is_egg = true
							enemy.egg_timer = 12.0
							play_egg = true
						} else {
							// Blast egg off screen, respawns after 10s
							enemy.x = -99
							enemy.y = -99
							enemy.egg_timer = 10.0
							play_egg = true
						}
						g.magic_shot.active = false
						break
					}
				}
			}
		}
	}

	// Update Enemies
	for mut enemy in g.enemies {
		if enemy.x < 0 {
			enemy.egg_timer -= dt
			if enemy.egg_timer <= 0 {
				enemy.x = enemy.spawn_x
				enemy.y = enemy.spawn_y
				enemy.is_egg = false
			}
			continue
		}

		if enemy.is_egg {
			enemy.egg_timer -= dt
			if enemy.egg_timer <= 0 {
				enemy.is_egg = false
			}
			continue
		}

		if enemy.is_asleep {
			continue
		}

		enemy.move_timer += dt

		match enemy.kind {
			.alma {
				if enemy.move_timer >= 0.70 {
					enemy.move_timer = 0
					dx := g.lolo.x - enemy.x
					dy := g.lolo.y - enemy.y
					mut target_x := enemy.x
					mut target_y := enemy.y

					if math.abs(dx) > math.abs(dy) {
						target_x += if dx > 0 { 1 } else { -1 }
					} else if dy != 0 {
						target_y += if dy > 0 { 1 } else { -1 }
					}

					if g.is_valid_enemy_move(target_x, target_y) {
						enemy.x = target_x
						enemy.y = target_y
					}
				}
			}
			.leeper {
				if enemy.move_timer >= 0.48 {
					enemy.move_timer = 0
					dx := g.lolo.x - enemy.x
					dy := g.lolo.y - enemy.y

					if math.abs(dx) <= 1 && math.abs(dy) <= 1 && (dx == 0 || dy == 0) {
						enemy.is_asleep = true
					} else {
						mut target_x := enemy.x
						mut target_y := enemy.y
						if math.abs(dx) >= math.abs(dy) {
							target_x += if dx > 0 { 1 } else { -1 }
						} else {
							target_y += if dy > 0 { 1 } else { -1 }
						}
						if g.is_valid_enemy_move(target_x, target_y) {
							enemy.x = target_x
							enemy.y = target_y
						}
					}
				}
			}
			.skull {
				if g.chest_open {
					if enemy.move_timer >= 0.38 {
						enemy.move_timer = 0
						dx := g.lolo.x - enemy.x
						dy := g.lolo.y - enemy.y
						mut target_x := enemy.x
						mut target_y := enemy.y

						if math.abs(dx) >= math.abs(dy) {
							target_x += if dx > 0 { 1 } else { -1 }
						} else {
							target_y += if dy > 0 { 1 } else { -1 }
						}
						if g.is_valid_enemy_move(target_x, target_y) {
							enemy.x = target_x
							enemy.y = target_y
						}
					}
				}
			}
			.don_medusa_h {
				if enemy.move_timer >= 0.38 {
					enemy.move_timer = 0
					target_x := enemy.x + enemy.patrol_dir
					if g.is_valid_enemy_move(target_x, enemy.y) {
						enemy.x = target_x
					} else {
						enemy.patrol_dir = -enemy.patrol_dir
					}
				}
			}
			.don_medusa_v {
				if enemy.move_timer >= 0.38 {
					enemy.move_timer = 0
					target_y := enemy.y + enemy.patrol_dir
					if g.is_valid_enemy_move(enemy.x, target_y) {
						enemy.y = target_y
					} else {
						enemy.patrol_dir = -enemy.patrol_dir
					}
				}
			}
			.gol {
				// Shoots fireballs when chest is open and Lolo in direct line of sight
				if g.chest_open && (enemy.x == g.lolo.x || enemy.y == g.lolo.y) {
					if !g.is_tile_blocking_laser(enemy.x, enemy.y) {
						// Gol fireball line-of-sight death
					}
				}
			}
			else {}
		}

		// Touch lethal enemy
		if (enemy.kind == .alma || (enemy.kind == .skull && g.chest_open)) && !enemy.is_egg {
			if enemy.x == g.lolo.x && enemy.y == g.lolo.y {
				g.kill_lolo()
			}
		}
	}

	// Medusa line-of-sight check
	g.check_medusa_lines_of_sight()

	return play_step, play_heart, play_shot, play_egg, play_push, play_laser, play_chest, play_victory
}

fn (g Game) is_valid_enemy_move(x int, y int) bool {
	if x < 0 || x >= grid_cols || y < 0 || y >= grid_rows {
		return false
	}
	tile := g.grid[y][x]
	ent := g.entities[y][x]
	if tile == .wall || tile == .tree || tile == .rock || tile == .water || ent == .emerald_frame
		|| ent == .chest || ent == .door {
		return false
	}
	for enemy in g.enemies {
		if enemy.x == x && enemy.y == y {
			return false
		}
	}
	return true
}

fn (mut g Game) check_medusa_lines_of_sight() {
	if g.medusa_laser_active || g.lolo.is_dead {
		return
	}

	for enemy in g.enemies {
		if enemy.is_egg || enemy.x < 0 {
			continue
		}
		if enemy.kind == .medusa || enemy.kind == .don_medusa_h || enemy.kind == .don_medusa_v || (enemy.kind == .gol && g.chest_open) {
			if enemy.x == g.lolo.x {
				step := if g.lolo.y > enemy.y { 1 } else { -1 }
				mut blocked := false
				mut curr_y := enemy.y + step
				for curr_y != g.lolo.y {
					if g.is_tile_blocking_laser(enemy.x, curr_y) {
						blocked = true
						break
					}
					curr_y += step
				}
				if !blocked {
					g.medusa_laser_active = true
					g.laser_x1 = enemy.x
					g.laser_y1 = enemy.y
					g.laser_x2 = g.lolo.x
					g.laser_y2 = g.lolo.y
					g.laser_timer = 0.25
					return
				}
			} else if enemy.y == g.lolo.y {
				step := if g.lolo.x > enemy.x { 1 } else { -1 }
				mut blocked := false
				mut curr_x := enemy.x + step
				for curr_x != g.lolo.x {
					if g.is_tile_blocking_laser(curr_x, enemy.y) {
						blocked = true
						break
					}
					curr_x += step
				}
				if !blocked {
					g.medusa_laser_active = true
					g.laser_x1 = enemy.x
					g.laser_y1 = enemy.y
					g.laser_x2 = g.lolo.x
					g.laser_y2 = g.lolo.y
					g.laser_timer = 0.25
					return
				}
			}
		}
	}
}

fn (g Game) is_tile_blocking_laser(x int, y int) bool {
	if x < 0 || x >= grid_cols || y < 0 || y >= grid_rows {
		return true
	}
	tile := g.grid[y][x]
	ent := g.entities[y][x]
	if tile == .wall || tile == .tree || tile == .rock || ent == .emerald_frame {
		return true
	}
	for enemy in g.enemies {
		if enemy.x == x && enemy.y == y {
			return true
		}
	}
	return false
}

pub fn (mut g Game) kill_lolo() {
	g.lolo.is_dead = true
	g.lives--
	if g.lives <= 0 {
		g.status = .lost
		g.status_msg = 'GAME OVER! PRESS [R] TO RESTART'
	} else {
		g.status_msg = 'LOLO DIED! PRESS [R] TO RETRY OR [U] TO UNDO'
	}
}

pub fn (mut g Game) move_lolo(dir Direction) (bool, bool, bool, bool, bool, bool) {
	mut s_step := false
	mut s_heart := false
	mut s_push := false
	mut s_chest := false
	mut s_victory := false
	mut s_hammer := false

	if g.status != .playing || g.lolo.is_dead || g.medusa_laser_active {
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}

	g.lolo.dir = dir

	mut dx := 0
	mut dy := 0
	match dir {
		.up { dy = -1 }
		.down { dy = 1 }
		.left { dx = -1 }
		.right { dx = 1 }
	}

	nx := g.lolo.x + dx
	ny := g.lolo.y + dy

	if nx < 0 || nx >= grid_cols || ny < 0 || ny >= grid_rows {
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}

	cur_tile := g.grid[g.lolo.y][g.lolo.x]
	if cur_tile == .arrow_up && dir != .up { return s_step, s_heart, s_push, s_chest, s_victory, s_hammer }
	if cur_tile == .arrow_down && dir != .down { return s_step, s_heart, s_push, s_chest, s_victory, s_hammer }
	if cur_tile == .arrow_left && dir != .left { return s_step, s_heart, s_push, s_chest, s_victory, s_hammer }
	if cur_tile == .arrow_right && dir != .right { return s_step, s_heart, s_push, s_chest, s_victory, s_hammer }

	target_tile := g.grid[ny][nx]
	target_ent := g.entities[ny][nx]

	// Check Door
	if target_ent == .door {
		if g.door_open {
			g.save_undo_snapshot()
			g.lolo.x = nx
			g.lolo.y = ny
			g.score += 1000
			g.status = .level_clear
			s_victory = true

			if g.is_testing_custom {
				g.status_msg = 'CUSTOM LEVEL CLEARED! PRESS [TAB] FOR EDITOR'
			} else if g.current_level_idx + 1 < g.campaign_levels.len {
				g.status_msg = 'LEVEL CLEARED! PRESS [SPACE] OR [ENTER] FOR NEXT LEVEL'
			} else {
				g.status = .won
				g.status_msg = 'CONGRATULATIONS! YOU SAVED PRINCESS LALA!'
			}
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		} else {
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		}
	}

	// Check Chest
	if target_ent == .chest {
		if g.chest_open {
			g.save_undo_snapshot()
			g.entities[ny][nx] = .none
			g.door_open = true
			g.score += 500
			g.lolo.x = nx
			g.lolo.y = ny
			s_chest = true
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		} else {
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		}
	}

	if target_tile == .wall || target_tile == .tree {
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}

	// Water tile
	if target_tile == .water {
		if g.lolo.bridges > 0 {
			g.save_undo_snapshot()
			g.lolo.bridges--
			g.grid[ny][nx] = .bridge
			g.lolo.x = nx
			g.lolo.y = ny
			g.moves_count++
			s_step = true
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		} else {
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		}
	}

	// Rock tile
	if target_tile == .rock {
		if g.lolo.hammers > 0 {
			g.save_undo_snapshot()
			g.lolo.hammers--
			g.grid[ny][nx] = .grass
			g.lolo.x = nx
			g.lolo.y = ny
			g.moves_count++
			s_hammer = true
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		} else {
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		}
	}

	// Emerald Frame Push
	if target_ent == .emerald_frame {
		bx := nx + dx
		by := ny + dy
		if bx >= 0 && bx < grid_cols && by >= 0 && by < grid_rows {
			b_tile := g.grid[by][bx]
			b_ent := g.entities[by][bx]
			if b_tile == .grass && b_ent == .none {
				g.save_undo_snapshot()
				g.entities[ny][nx] = .none
				g.entities[by][bx] = .emerald_frame
				g.lolo.x = nx
				g.lolo.y = ny
				g.moves_count++
				s_push = true
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			} else if b_tile == .water {
				g.save_undo_snapshot()
				g.entities[ny][nx] = .none
				g.grid[by][bx] = .bridge
				g.lolo.x = nx
				g.lolo.y = ny
				g.moves_count++
				s_push = true
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			}
		}
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}

	// Check Enemies / Eggs
	for mut enemy in g.enemies {
		if enemy.x == nx && enemy.y == ny {
			if enemy.is_egg {
				ex := nx + dx
				ey := ny + dy
				if ex >= 0 && ex < grid_cols && ey >= 0 && ey < grid_rows {
					e_tile := g.grid[ey][ex]
					e_ent := g.entities[ey][ex]
					if e_tile == .grass && e_ent == .none {
						g.save_undo_snapshot()
						enemy.x = ex
						enemy.y = ey
						g.lolo.x = nx
						g.lolo.y = ny
						g.moves_count++
						s_push = true
						return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
					} else if e_tile == .water {
						g.save_undo_snapshot()
						enemy.x = -99
						g.grid[ey][ex] = .bridge
						g.lolo.x = nx
						g.lolo.y = ny
						g.moves_count++
						s_push = true
						return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
					}
				}
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			} else if enemy.is_asleep || enemy.kind == .snakey {
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			} else {
				g.kill_lolo()
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			}
		}
	}

	// Move Lolo forward!
	g.save_undo_snapshot()
	g.lolo.x = nx
	g.lolo.y = ny
	g.moves_count++
	s_step = true

	// Heart Frame collection
	if target_ent == .heart_frame {
		g.entities[ny][nx] = .none
		g.hearts_remaining--
		g.score += 100
		g.lolo.shots += 2
		s_heart = true

		if g.hearts_remaining <= 0 {
			g.chest_open = true
			s_chest = true
		}
	} else if target_ent == .hammer {
		g.entities[ny][nx] = .none
		g.lolo.hammers++
		g.score += 50
	}

	return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
}

pub fn (mut g Game) fire_magic_shot() bool {
	if g.lolo.shots <= 0 || g.magic_shot.active || g.status != .playing || g.lolo.is_dead {
		return false
	}
	g.save_undo_snapshot()
	g.lolo.shots--
	g.magic_shot.active = true
	g.magic_shot.x = f64(g.lolo.x)
	g.magic_shot.y = f64(g.lolo.y)
	g.magic_shot.dir = g.lolo.dir

	match g.lolo.dir {
		.up {
			g.magic_shot.vx = 0.0
			g.magic_shot.vy = -1.0
		}
		.down {
			g.magic_shot.vx = 0.0
			g.magic_shot.vy = 1.0
		}
		.left {
			g.magic_shot.vx = -1.0
			g.magic_shot.vy = 0.0
		}
		.right {
			g.magic_shot.vx = 1.0
			g.magic_shot.vy = 0.0
		}
	}
	return true
}

pub fn (mut g Game) restart_level() {
	if g.is_testing_custom {
		g.load_level_struct(g.editor_level)
		g.is_testing_custom = true
	} else {
		g.load_level(g.current_level_idx)
	}
}

pub fn (mut g Game) next_level() {
	if g.is_testing_custom {
		g.mode = .editor
		g.is_testing_custom = false
		return
	}
	if g.current_level_idx + 1 < g.campaign_levels.len {
		g.load_level(g.current_level_idx + 1)
	} else {
		g.status = .won
		g.status_msg = 'CONGRATULATIONS! YOU COMPLETED ALL 20 ROOMS!'
	}
}

pub fn (mut g Game) toggle_editor_mode() {
	if g.mode == .play {
		g.mode = .editor
		g.status = .paused
	} else {
		g.mode = .play
		g.status = .playing
		if g.is_testing_custom {
			g.load_level_struct(g.editor_level)
			g.is_testing_custom = true
		} else {
			g.load_level(g.current_level_idx)
		}
	}
}

pub fn (mut g Game) handle_editor_click(col int, row int, is_right_click bool) {
	if col < 0 || col >= grid_cols || row < 0 || row >= grid_rows {
		return
	}
	if is_right_click {
		g.editor_level.grid[row][col] = .grass
		g.editor_level.entities[row][col] = .none
		return
	}

	if g.is_entity_selected {
		if g.selected_entity == .lolo_spawn || g.selected_entity == .chest || g.selected_entity == .door {
			for r in 0 .. grid_rows {
				for c in 0 .. grid_cols {
					if g.editor_level.entities[r][c] == g.selected_entity {
						g.editor_level.entities[r][c] = .none
					}
				}
			}
		}
		g.editor_level.entities[row][col] = g.selected_entity
	} else {
		g.editor_level.grid[row][col] = g.selected_tile
		if g.selected_tile == .wall || g.selected_tile == .tree || g.selected_tile == .water {
			g.editor_level.entities[row][col] = .none
		}
	}
}

pub fn (g Game) validate_level(lvl Level) string {
	mut lolo_count := 0
	mut chest_count := 0
	mut door_count := 0
	mut heart_count := 0

	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			ent := lvl.entities[r][c]
			match ent {
				.lolo_spawn { lolo_count++ }
				.chest { chest_count++ }
				.door { door_count++ }
				.heart_frame { heart_count++ }
				else {}
			}
		}
	}

	if lolo_count != 1 { return 'Level must have exactly 1 Lolo Spawn!' }
	if chest_count != 1 { return 'Level must have exactly 1 Treasure Chest!' }
	if door_count != 1 { return 'Level must have exactly 1 Exit Door!' }
	if heart_count < 1 { return 'Level must have at least 1 Heart Frame!' }
	return ''
}

pub fn (mut g Game) test_play_custom_level() bool {
	err := g.validate_level(g.editor_level)
	if err != '' {
		g.validation_msg = err
		return false
	}
	g.validation_msg = ''
	g.mode = .play
	g.is_testing_custom = true
	g.load_level_struct(g.editor_level)
	g.is_testing_custom = true
	return true
}

pub fn get_entity_from_palette_index(idx int) EntityType {
	match idx {
		6 { return .emerald_frame }
		7 { return .heart_frame }
		8 { return .chest }
		9 { return .door }
		10 { return .hammer }
		11 { return .lolo_spawn }
		12 { return .snakey }
		13 { return .alma }
		14 { return .leeper }
		15 { return .skull }
		16 { return .medusa }
		17 { return .don_medusa_h }
		else { return .none }
	}
}

// --------------------------------------------------
// 20 Classic Puzzle Campaign Rooms (4 Floors)
// --------------------------------------------------

fn get_default_levels() []Level {
	mut levels := []Level{}

	// FLOOR 1: CASTLE COURTYARD (Rooms 1-5)
	// Room 1: First Steps
	mut l1 := create_empty_level('Room 1: First Steps')
	l1.floor = 1; l1.password = 'ROOK'
	l1.grid[4][3] = .wall; l1.grid[4][7] = .wall
	l1.entities[5][2] = .heart_frame; l1.entities[5][8] = .heart_frame
	l1.entities[6][4] = .emerald_frame; l1.entities[6][6] = .emerald_frame
	l1.entities[7][5] = .snakey
	levels << l1

	// Room 2: Medusa Gaze
	mut l2 := create_empty_level('Room 2: Medusa Gaze')
	l2.floor = 1; l2.password = 'GAZE'
	l2.entities[5][5] = .medusa
	l2.entities[4][5] = .emerald_frame; l2.entities[6][5] = .emerald_frame
	l2.entities[5][4] = .emerald_frame; l2.entities[5][6] = .emerald_frame
	l2.entities[1][1] = .heart_frame; l2.entities[1][9] = .heart_frame
	l2.entities[8][1] = .heart_frame; l2.entities[8][9] = .heart_frame
	levels << l2

	// Room 3: The Moat
	mut l3 := create_empty_level('Room 3: The Moat')
	l3.floor = 1; l3.password = 'MOAT'
	for c in 1 .. 10 { l3.grid[6][c] = .water }
	l3.entities[7][3] = .emerald_frame; l3.entities[7][7] = .emerald_frame
	l3.entities[3][3] = .heart_frame; l3.entities[3][7] = .heart_frame; l3.entities[8][5] = .heart_frame
	levels << l3

	// Room 4: Leeper Slumber
	mut l4 := create_empty_level('Room 4: Leeper Slumber')
	l4.floor = 1; l4.password = 'SLEP'
	l4.entities[5][5] = .medusa
	l4.entities[7][5] = .leeper
	l4.entities[4][5] = .emerald_frame
	l4.entities[3][1] = .heart_frame; l4.entities[3][9] = .heart_frame; l4.entities[8][3] = .heart_frame
	levels << l4

	// Room 5: Don Medusa Patrol
	mut l5 := create_empty_level('Room 5: Don Medusa')
	l5.floor = 1; l5.password = 'DON1'
	l5.entities[4][5] = .don_medusa_h
	l5.entities[4][3] = .emerald_frame; l5.entities[4][7] = .emerald_frame
	l5.entities[2][2] = .heart_frame; l5.entities[2][8] = .heart_frame
	l5.entities[8][2] = .heart_frame; l5.entities[8][8] = .heart_frame
	levels << l5

	// FLOOR 2: SUNKEN MOAT (Rooms 6-10)
	// Room 6: Skull Awakening
	mut l6 := create_empty_level('Room 6: Skull Awakening')
	l6.floor = 2; l6.password = 'SKUL'
	l6.entities[4][2] = .skull; l6.entities[4][8] = .skull
	l6.entities[6][3] = .emerald_frame; l6.entities[6][7] = .emerald_frame
	l6.entities[3][2] = .heart_frame; l6.entities[3][8] = .heart_frame
	l6.entities[7][2] = .heart_frame; l6.entities[7][8] = .heart_frame
	levels << l6

	// Room 7: Floating Raft
	mut l7 := create_empty_level('Room 7: Floating Raft')
	l7.floor = 2; l7.password = 'RAFT'
	for c in 1 .. 10 { l7.grid[5][c] = .water }
	l7.grid[5][5] = .grass
	l7.entities[7][5] = .snakey
	l7.entities[3][3] = .heart_frame; l7.entities[3][7] = .heart_frame; l7.entities[8][4] = .heart_frame
	levels << l7

	// Room 8: Bridge Crossing
	mut l8 := create_empty_level('Room 8: Bridge Crossing')
	l8.floor = 2; l8.password = 'BRID'
	for r in 1 .. 10 { l8.grid[r][3] = .water; l8.grid[r][7] = .water }
	l8.grid[9][5] = .grass; l8.grid[0][5] = .grass
	l8.entities[6][5] = .emerald_frame; l8.entities[7][5] = .emerald_frame
	l8.entities[4][1] = .heart_frame; l8.entities[4][9] = .heart_frame; l8.entities[4][5] = .heart_frame
	levels << l8

	// Room 9: One-Way Maze
	mut l9 := create_empty_level('Room 9: One-Way Maze')
	l9.floor = 2; l9.password = 'AROW'
	l9.grid[5][3] = .arrow_up; l9.grid[5][7] = .arrow_down
	l9.entities[5][5] = .medusa
	l9.entities[4][5] = .emerald_frame; l9.entities[6][5] = .emerald_frame
	l9.entities[3][1] = .heart_frame; l9.entities[3][9] = .heart_frame
	l9.entities[8][1] = .heart_frame; l9.entities[8][9] = .heart_frame
	levels << l9

	// Room 10: Alma Labyrinth
	mut l10 := create_empty_level('Room 10: Alma Labyrinth')
	l10.floor = 2; l10.password = 'ALMA'
	for r in 3 .. 8 { if r % 2 == 1 { for c in 2 .. 9 { l10.grid[r][c] = .tree } } }
	l10.grid[3][5] = .grass; l10.grid[5][5] = .grass; l10.grid[7][5] = .grass
	l10.entities[4][5] = .alma
	l10.entities[7][3] = .emerald_frame; l10.entities[7][7] = .emerald_frame
	l10.entities[1][1] = .heart_frame; l10.entities[1][9] = .heart_frame
	l10.entities[8][1] = .heart_frame; l10.entities[8][9] = .heart_frame
	levels << l10

	// FLOOR 3: MEDUSA FORTRESS (Rooms 11-15)
	// Room 11: Twin Medusas
	mut l11 := create_empty_level('Room 11: Twin Medusas')
	l11.floor = 3; l11.password = 'TWIN'
	l11.entities[5][3] = .medusa; l11.entities[5][7] = .medusa
	l11.entities[6][3] = .emerald_frame; l11.entities[6][7] = .emerald_frame
	l11.entities[4][3] = .emerald_frame; l11.entities[4][7] = .emerald_frame
	l11.entities[1][2] = .heart_frame; l11.entities[1][8] = .heart_frame
	l11.entities[8][2] = .heart_frame; l11.entities[8][8] = .heart_frame
	levels << l11

	// Room 12: Rock Quarry
	mut l12 := create_empty_level('Room 12: Rock Quarry')
	l12.floor = 3; l12.password = 'ROCK'
	for c in 2 .. 9 { l12.grid[5][c] = .rock }
	l12.entities[7][5] = .hammer
	l12.entities[7][3] = .emerald_frame; l12.entities[7][7] = .emerald_frame
	l12.entities[3][2] = .heart_frame; l12.entities[3][8] = .heart_frame
	l12.entities[8][2] = .heart_frame; l12.entities[8][8] = .heart_frame
	levels << l12

	// Room 13: Crossway Patrol
	mut l13 := create_empty_level('Room 13: Crossway Patrol')
	l13.floor = 3; l13.password = 'CROS'
	l13.entities[4][5] = .don_medusa_h
	l13.entities[6][5] = .don_medusa_v
	l13.entities[4][3] = .emerald_frame; l13.entities[4][7] = .emerald_frame; l13.entities[7][4] = .emerald_frame
	l13.entities[1][1] = .heart_frame; l13.entities[1][9] = .heart_frame
	l13.entities[8][1] = .heart_frame; l13.entities[8][9] = .heart_frame
	levels << l13

	// Room 14: Double Waterway
	mut l14 := create_empty_level('Room 14: Double Waterway')
	l14.floor = 3; l14.password = 'WTR2'
	for c in 1 .. 10 { l14.grid[4][c] = .water; l14.grid[7][c] = .water }
	l14.entities[8][2] = .snakey; l14.entities[8][8] = .snakey
	l14.entities[6][5] = .emerald_frame
	l14.entities[1][3] = .heart_frame; l14.entities[1][7] = .heart_frame; l14.entities[5][5] = .heart_frame
	levels << l14

	// Room 15: Gol Fortress
	mut l15 := create_empty_level('Room 15: Gol Fortress')
	l15.floor = 3; l15.password = 'GOLF'
	l15.entities[4][2] = .gol; l15.entities[4][8] = .gol
	l15.entities[5][2] = .emerald_frame; l15.entities[5][8] = .emerald_frame
	l15.entities[1][3] = .heart_frame; l15.entities[1][7] = .heart_frame
	l15.entities[8][3] = .heart_frame; l15.entities[8][7] = .heart_frame; l15.entities[6][5] = .heart_frame
	levels << l15

	// FLOOR 4: GREAT DEVIL'S TOWER & RESCUE (Rooms 16-20)
	// Room 16: The Gauntlet
	mut l16 := create_empty_level('Room 16: The Gauntlet')
	l16.floor = 4; l16.password = 'GANT'
	l16.entities[5][5] = .medusa
	l16.entities[4][2] = .skull; l16.entities[4][8] = .alma
	l16.entities[4][5] = .emerald_frame; l16.entities[6][5] = .emerald_frame; l16.entities[5][4] = .emerald_frame
	l16.entities[1][1] = .heart_frame; l16.entities[1][9] = .heart_frame
	l16.entities[8][1] = .heart_frame; l16.entities[8][9] = .heart_frame
	levels << l16

	// Room 17: Water Citadel
	mut l17 := create_empty_level('Room 17: Water Citadel')
	l17.floor = 4; l17.password = 'CTDL'
	for r in 4 .. 8 { for c in 2 .. 9 { if (r+c)%2 == 0 { l17.grid[r][c] = .water } } }
	l17.entities[7][5] = .snakey
	l17.entities[6][3] = .emerald_frame; l17.entities[6][7] = .emerald_frame
	l17.entities[1][3] = .heart_frame; l17.entities[1][7] = .heart_frame
	l17.entities[8][2] = .heart_frame; l17.entities[8][8] = .heart_frame
	levels << l17

	// Room 18: Quad Medusas
	mut l18 := create_empty_level('Room 18: Quad Medusas')
	l18.floor = 4; l18.password = 'QUAD'
	l18.entities[4][3] = .medusa; l18.entities[4][7] = .medusa
	l18.entities[7][3] = .medusa; l18.entities[7][7] = .medusa
	l18.entities[5][3] = .emerald_frame; l18.entities[5][7] = .emerald_frame
	l18.entities[6][3] = .emerald_frame; l18.entities[6][7] = .emerald_frame
	l18.entities[1][5] = .heart_frame; l18.entities[8][5] = .heart_frame; l18.entities[5][5] = .heart_frame
	levels << l18

	// Room 19: Master Matrix
	mut l19 := create_empty_level('Room 19: Master Matrix')
	l19.floor = 4; l19.password = 'MSTR'
	l19.entities[4][5] = .don_medusa_h
	l19.entities[6][2] = .skull; l19.entities[6][8] = .leeper
	l19.entities[5][3] = .emerald_frame; l19.entities[5][7] = .emerald_frame; l19.entities[7][5] = .emerald_frame
	l19.entities[1][1] = .heart_frame; l19.entities[1][9] = .heart_frame
	l19.entities[8][1] = .heart_frame; l19.entities[8][9] = .heart_frame
	levels << l19

	// Room 20: King Egger Chamber
	mut l20 := create_empty_level('Room 20: King Egger Chamber')
	l20.floor = 4; l20.password = 'EGGR'
	l20.entities[4][5] = .king_egger
	l20.entities[4][3] = .gol; l20.entities[4][7] = .gol
	l20.entities[6][4] = .emerald_frame; l20.entities[6][6] = .emerald_frame
	l20.entities[1][2] = .heart_frame; l20.entities[1][8] = .heart_frame
	l20.entities[8][2] = .heart_frame; l20.entities[8][8] = .heart_frame
	l20.entities[6][5] = .heart_frame
	levels << l20

	return levels
}

pub fn (g Game) serialize_level(lvl Level) string {
	mut sb := []string{}
	sb << lvl.name
	for r in 0 .. grid_rows {
		mut line := ''
		for c in 0 .. grid_cols {
			t := int(lvl.grid[r][c])
			e := int(lvl.entities[r][c])
			line += '${t}:${e},'
		}
		sb << line
	}
	return sb.join('\n')
}

pub fn parse_level(data string) Level {
	lines := data.split('\n')
	if lines.len < 12 {
		return create_empty_level('Parsed Level')
	}
	mut lvl := Level{
		name: lines[0]
	}
	for r in 0 .. grid_rows {
		if r + 1 >= lines.len {
			break
		}
		cells := lines[r + 1].split(',')
		for c in 0 .. grid_cols {
			if c >= cells.len || cells[c] == '' {
				continue
			}
			parts := cells[c].split(':')
			if parts.len == 2 {
				lvl.grid[r][c] = unsafe { TileType(parts[0].int()) }
				lvl.entities[r][c] = unsafe { EntityType(parts[1].int()) }
			}
		}
	}
	return lvl
}
