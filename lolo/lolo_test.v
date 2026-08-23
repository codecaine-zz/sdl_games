module main

fn test_new_game() {
	mut g := new_game()
	assert g.campaign_levels.len >= 6
	assert g.current_level_idx == 0
	assert g.hearts_remaining > 0
	assert g.lolo.x >= 0 && g.lolo.x < grid_cols
	assert g.lolo.y >= 0 && g.lolo.y < grid_rows
}

fn test_block_pushing() {
	mut g := new_game()
	// Set up custom grid: Lolo at (3, 3), Emerald frame at (4, 3), Water at (5, 3)
	g.lolo.x = 3
	g.lolo.y = 3
	g.lolo.dir = .right
	g.grid[3][5] = .water
	g.entities[3][4] = .emerald_frame

	// Move right -> pushes block into water -> turns water at (5,3) into bridge!
	step, heart, push, chest, victory, hammer := g.move_lolo(.right)
	assert push == true
	assert g.lolo.x == 4
	assert g.entities[3][4] == .none
	assert g.grid[3][5] == .bridge
}

fn test_magic_shot_and_egg() {
	mut g := new_game()
	g.lolo.x = 2
	g.lolo.y = 2
	g.lolo.dir = .right
	g.lolo.shots = 2

	// Add Snakey at (4, 2)
	g.enemies.clear()
	g.enemies << Enemy{
		kind:    .snakey
		x:       4
		y:       2
		spawn_x: 4
		spawn_y: 2
	}

	// Fire Magic Shot
	fired := g.fire_magic_shot()
	assert fired == true
	assert g.lolo.shots == 1
	assert g.magic_shot.active == true

	// Step simulation in small frame increments so shot steps through col 3 to col 4
	for _ in 0 .. 10 {
		g.update(0.05)
		if g.enemies[0].is_egg {
			break
		}
	}
	assert g.enemies[0].is_egg == true
}

fn test_medusa_line_of_sight() {
	mut g := new_game()
	g.lolo.x = 5
	g.lolo.y = 8
	g.enemies.clear()
	for r in 0 .. grid_rows {
		for c in 0 .. grid_cols {
			g.entities[r][c] = .none
		}
	}
	g.enemies << Enemy{
		kind:    .medusa
		x:       5
		y:       2
		spawn_x: 5
		spawn_y: 2
	}

	// Unblocked Medusa line of sight -> Laser strikes!
	g.update(0.1)
	assert g.medusa_laser_active == true

	// Block Medusa line of sight with Emerald frame at (5, 5)
	g.medusa_laser_active = false
	g.lolo.is_dead = false
	g.entities[5][5] = .emerald_frame

	g.update(0.1)
	assert g.medusa_laser_active == false
}

fn test_level_validation() {
	g := new_game()

	// Empty level is invalid
	mut empty_lvl := Level{
		name: 'Invalid Level'
	}
	err := g.validate_level(empty_lvl)
	assert err != ''

	// Valid Level 1
	val_err := g.validate_level(g.campaign_levels[0])
	assert val_err == ''
}

fn test_level_serialization() {
	g := new_game()
	lvl1 := g.campaign_levels[0]
	serialized := g.serialize_level(lvl1)
	assert serialized.contains('Room 1')

	parsed := parse_level(serialized)
	assert parsed.name == lvl1.name
}

fn test_door_entry() {
	mut g := new_game()
	g.lolo.x = 5
	g.lolo.y = 1
	g.hearts_remaining = 0
	g.door_open = true

	// Step up into door at (5, 0)
	_, _, _, _, victory, _ := g.move_lolo(.up)
	assert victory == true
	assert g.status == .level_clear
	assert g.lolo.x == 5
	assert g.lolo.y == 0
}

fn test_undo_mechanics() {
	mut g := new_game()
	start_x := g.lolo.x
	start_y := g.lolo.y

	// Move right
	g.move_lolo(.right)
	assert g.lolo.x == start_x + 1
	assert g.undo_stack.len > 0

	// Undo!
	undone := g.undo()
	assert undone == true
	assert g.lolo.x == start_x
	assert g.lolo.y == start_y
}

fn test_twenty_levels_loaded() {
	g := new_game()
	assert g.campaign_levels.len == 20
	assert g.campaign_levels[19].name.contains('King Egger')
}

fn test_every_level_is_valid_and_playable() {
	mut g := new_game()
	assert g.campaign_levels.len == 20

	for i, lvl in g.campaign_levels {
		err := g.validate_level(lvl)
		assert err == '' // Every single room MUST have valid spawn, chest, door, hearts

		// Load level into game and check initialization
		g.load_level(i)
		assert g.hearts_remaining > 0
		assert g.lolo.x == 5 && g.lolo.y == 9
		assert g.chest_open == false
		assert g.door_open == false
		assert g.status == .playing
	}
}
