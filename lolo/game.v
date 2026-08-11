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
	grid     [11][11]TileType
	entities [11][11]EntityType
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
	lives               int = 3
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
	// Default spawn, chest, door
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
				.snakey, .alma, .leeper, .skull, .medusa, .don_medusa_h, .don_medusa_v {
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
					// Remove enemy from static entity grid so it moves dynamically
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

	if g.mode == .editor {
		return play_step, play_heart, play_shot, play_egg, play_push, play_laser, play_chest, play_victory
	}

	if g.status != .playing {
		return play_step, play_heart, play_shot, play_egg, play_push, play_laser, play_chest, play_victory
	}

	// Update Medusa Laser timer
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
			// Check collision with tiles/obstacles
			tile := g.grid[cur_row][cur_col]
			ent := g.entities[cur_row][cur_col]

			if tile == .wall || tile == .tree || tile == .rock || ent == .emerald_frame {
				g.magic_shot.active = false
			} else {
				// Check enemy collision
				for mut enemy in g.enemies {
					if enemy.x == cur_col && enemy.y == cur_row {
						if !enemy.is_egg {
							enemy.is_egg = true
							enemy.egg_timer = 12.0 // 12 seconds in egg form
							play_egg = true
						} else {
							// Second shot blasts egg off screen, respawns after 10s
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
			// Respawning off-screen egg
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
				// Moves towards Lolo every 0.75s
				if enemy.move_timer >= 0.75 {
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
				// Chases Lolo every 0.5s. If adjacent/on top -> falls asleep as permanent barrier!
				if enemy.move_timer >= 0.5 {
					enemy.move_timer = 0
					dx := g.lolo.x - enemy.x
					dy := g.lolo.y - enemy.y

					if math.abs(dx) <= 1 && math.abs(dy) <= 1 && (dx == 0 || dy == 0) {
						// Sleep right next to Lolo
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
				// Only active when chest is open!
				if g.chest_open {
					if enemy.move_timer >= 0.4 {
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
				// Patrols horizontally back and forth
				if enemy.move_timer >= 0.4 {
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
				// Patrols vertically back and forth
				if enemy.move_timer >= 0.4 {
					enemy.move_timer = 0
					target_y := enemy.y + enemy.patrol_dir
					if g.is_valid_enemy_move(enemy.x, target_y) {
						enemy.y = target_y
					} else {
						enemy.patrol_dir = -enemy.patrol_dir
					}
				}
			}
			else {}
		}

		// Touch Lolo check (for active enemies like Alma, Skull)
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
		if enemy.kind == .medusa || enemy.kind == .don_medusa_h || enemy.kind == .don_medusa_v {
			// Check if Lolo is in cardinal line of sight
			if enemy.x == g.lolo.x {
				// Same column
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
					// Trigger laser strike!
					g.medusa_laser_active = true
					g.laser_x1 = enemy.x
					g.laser_y1 = enemy.y
					g.laser_x2 = g.lolo.x
					g.laser_y2 = g.lolo.y
					g.laser_timer = 0.25
					return
				}
			} else if enemy.y == g.lolo.y {
				// Same row
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
			return true // Enemies block Medusa laser line of sight!
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
		g.status_msg = 'LOLO DIED! PRESS [R] TO RETRY LEVEL'
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

	// Check current tile one-way arrow restriction
	cur_tile := g.grid[g.lolo.y][g.lolo.x]
	if cur_tile == .arrow_up && dir != .up {
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}
	if cur_tile == .arrow_down && dir != .down {
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}
	if cur_tile == .arrow_left && dir != .left {
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}
	if cur_tile == .arrow_right && dir != .right {
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}

	target_tile := g.grid[ny][nx]
	target_ent := g.entities[ny][nx]

	// Check Door FIRST (so open door on boundary is reachable)
	if target_ent == .door {
		if g.door_open {
			// ESCAPED / LEVEL CLEAR!
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
				g.status_msg = 'CONGRATULATIONS! YOU BEAT THE CAMPAIGN!'
			}
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		} else {
			// Locked door blocks movement
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		}
	}

	// Check Chest SECOND
	if target_ent == .chest {
		if g.chest_open {
			// Collect Magic Jewel! Open exit door!
			g.entities[ny][nx] = .none
			g.door_open = true
			g.score += 500
			g.lolo.x = nx
			g.lolo.y = ny
			s_chest = true
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		} else {
			// Closed chest blocks movement
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		}
	}

	// Check solid walls / trees
	if target_tile == .wall || target_tile == .tree {
		return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
	}

	// Check water
	if target_tile == .water {
		// Check if Lolo has a bridge plank to build a bridge
		if g.lolo.bridges > 0 {
			g.lolo.bridges--
			g.grid[ny][nx] = .bridge
			g.lolo.x = nx
			g.lolo.y = ny
			s_step = true
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		} else {
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		}
	}

	// Check rock (smash with hammer if available)
	if target_tile == .rock {
		if g.lolo.hammers > 0 {
			g.lolo.hammers--
			g.grid[ny][nx] = .grass
			g.lolo.x = nx
			g.lolo.y = ny
			s_hammer = true
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		} else {
			return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
		}
	}

	// Check Emerald Frame (Pushable Green Block)
	if target_ent == .emerald_frame {
		bx := nx + dx
		by := ny + dy
		if bx >= 0 && bx < grid_cols && by >= 0 && by < grid_rows {
			b_tile := g.grid[by][bx]
			b_ent := g.entities[by][bx]
			if b_tile == .grass && b_ent == .none {
				// Push block to empty space
				g.entities[ny][nx] = .none
				g.entities[by][bx] = .emerald_frame
				g.lolo.x = nx
				g.lolo.y = ny
				s_push = true
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			} else if b_tile == .water {
				// Push block into water to form a bridge!
				g.entities[ny][nx] = .none
				g.grid[by][bx] = .bridge
				g.lolo.x = nx
				g.lolo.y = ny
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
				// Push Egg!
				ex := nx + dx
				ey := ny + dy
				if ex >= 0 && ex < grid_cols && ey >= 0 && ey < grid_rows {
					e_tile := g.grid[ey][ex]
					e_ent := g.entities[ey][ex]
					if e_tile == .grass && e_ent == .none {
						enemy.x = ex
						enemy.y = ey
						g.lolo.x = nx
						g.lolo.y = ny
						s_push = true
						return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
					} else if e_tile == .water {
						// Egg pushed into water acts as bridge!
						enemy.x = -99 // Remove egg
						g.grid[ey][ex] = .bridge
						g.lolo.x = nx
						g.lolo.y = ny
						s_push = true
						return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
					}
				}
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			} else if enemy.is_asleep {
				// Sleeping Leeper is a solid barrier
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			} else if enemy.kind == .snakey {
				// Snakey is harmless obstacle unless shot
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			} else {
				// Active lethal enemy
				g.kill_lolo()
				return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
			}
		}
	}

	// Move Lolo to empty space
	g.lolo.x = nx
	g.lolo.y = ny
	s_step = true

	// Pick up Heart Frame
	if target_ent == .heart_frame {
		g.entities[ny][nx] = .none
		g.hearts_remaining--
		g.score += 100
		g.lolo.shots += 2 // Classic Lolo: hearts grant 2 magic shots!
		s_heart = true

		if g.hearts_remaining <= 0 {
			g.chest_open = true
			g.door_open = true
			s_chest = true
		}
	}

	// Pick up Hammer item
	if target_ent == .hammer {
		g.entities[ny][nx] = .none
		g.lolo.hammers++
		g.score += 50
	}

	return s_step, s_heart, s_push, s_chest, s_victory, s_hammer
}

pub fn (mut g Game) fire_magic_shot() bool {
	if g.status != .playing || g.lolo.is_dead || g.lolo.shots <= 0 || g.magic_shot.active {
		return false
	}

	g.lolo.shots--
	g.magic_shot.x = f64(g.lolo.x)
	g.magic_shot.y = f64(g.lolo.y)
	g.magic_shot.dir = g.lolo.dir
	g.magic_shot.active = true

	match g.lolo.dir {
		.up {
			g.magic_shot.vx = 0
			g.magic_shot.vy = -1
		}
		.down {
			g.magic_shot.vx = 0
			g.magic_shot.vy = 1
		}
		.left {
			g.magic_shot.vx = -1
			g.magic_shot.vy = 0
		}
		.right {
			g.magic_shot.vx = 1
			g.magic_shot.vy = 0
		}
	}

	return true
}

pub fn (mut g Game) next_level() {
	if g.current_level_idx + 1 < g.campaign_levels.len {
		g.load_level(g.current_level_idx + 1)
	}
}

pub fn (mut g Game) restart_level() {
	if g.is_testing_custom {
		g.load_level_struct(g.editor_level)
		g.is_testing_custom = true
	} else {
		g.load_level(g.current_level_idx)
	}
}

// --------------------------------------------------
// Level Designer & Editor Logic
// --------------------------------------------------

pub fn (mut g Game) toggle_editor_mode() {
	if g.mode == .play {
		g.mode = .editor
		g.status_msg = 'LEVEL DESIGNER MODE'
	} else {
		g.mode = .play
		g.status_msg = 'PLAY MODE'
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
		// If placing lolo_spawn, chest, or door, remove previous instances to keep exactly 1
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
		// If placing solid wall/tree/water on an entity, remove entity
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

	if lolo_count != 1 {
		return 'Level must have exactly 1 Lolo Spawn!'
	}
	if chest_count != 1 {
		return 'Level must have exactly 1 Treasure Chest!'
	}
	if door_count != 1 {
		return 'Level must have exactly 1 Exit Door!'
	}
	if heart_count < 1 {
		return 'Level must have at least 1 Heart Frame!'
	}

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

// --------------------------------------------------
// Built-in Classic Puzzle Campaign Levels
// --------------------------------------------------

fn get_default_levels() []Level {
	mut levels := []Level{}

	// Level 1: Introduction to Block Pushing & Heart Collecting
	mut l1 := create_empty_level('Level 1: First Steps')
	l1.grid[4][3] = .wall
	l1.grid[4][7] = .wall
	l1.entities[5][3] = .heart_frame
	l1.entities[5][7] = .heart_frame
	l1.entities[6][5] = .emerald_frame
	l1.entities[7][5] = .snakey
	levels << l1

	// Level 2: Medusa & Block Shielding
	mut l2 := create_empty_level('Level 2: Medusa\'s Gaze')
	l2.entities[5][5] = .medusa
	l2.entities[3][5] = .emerald_frame
	l2.entities[7][5] = .emerald_frame
	l2.entities[5][3] = .emerald_frame
	l2.entities[5][7] = .emerald_frame
	l2.entities[1][1] = .heart_frame
	l2.entities[1][9] = .heart_frame
	l2.entities[9][1] = .heart_frame
	l2.entities[9][9] = .heart_frame
	levels << l2

	// Level 3: Water Crossing & Bridge Construction
	mut l3 := create_empty_level('Level 3: Water Moat')
	for c in 1 .. 10 {
		l3.grid[5][c] = .water
	}
	l3.grid[5][5] = .grass
	l3.entities[4][3] = .emerald_frame
	l3.entities[4][7] = .emerald_frame
	l3.entities[2][5] = .heart_frame
	l3.entities[8][5] = .heart_frame
	levels << l3

	// Level 4: Leeper Block Trap & Alma Patrol
	mut l4 := create_empty_level('Level 4: Leeper & Alma')
	l4.entities[4][4] = .leeper
	l4.entities[4][6] = .alma
	l4.entities[2][2] = .heart_frame
	l4.entities[2][8] = .heart_frame
	l4.entities[8][2] = .heart_frame
	l4.entities[8][8] = .heart_frame
	l4.entities[6][5] = .emerald_frame
	levels << l4

	// Level 5: Don Medusa Timing Corridor
	mut l5 := create_empty_level('Level 5: Don Medusa Patrol')
	l5.entities[3][5] = .don_medusa_h
	l5.entities[7][5] = .don_medusa_h
	l5.entities[5][2] = .emerald_frame
	l5.entities[5][8] = .emerald_frame
	l5.entities[1][5] = .heart_frame
	l5.entities[9][5] = .heart_frame
	l5.entities[5][5] = .heart_frame
	levels << l5

	// Level 6: The Awakening Skulls
	mut l6 := create_empty_level('Level 6: Skull Nightmare')
	l6.entities[3][3] = .skull
	l6.entities[3][7] = .skull
	l6.entities[7][3] = .skull
	l6.entities[7][7] = .skull
	l6.entities[1][5] = .heart_frame
	l6.entities[9][5] = .heart_frame
	l6.entities[5][1] = .heart_frame
	l6.entities[5][9] = .heart_frame
	levels << l6

	return levels
}
