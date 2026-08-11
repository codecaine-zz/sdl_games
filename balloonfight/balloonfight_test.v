module main

fn test_new_game_engine() {
	ge := new_game_engine()
	assert ge.state == .title
	assert ge.mode == .mode_a_1p
	assert ge.high_score == 25000
	assert ge.world_w == 800.0
	assert ge.world_h == 600.0
}

fn test_flap_physics() {
	mut m := MotionState{
		x:           200
		y:           300
		vx:          0
		vy:          0
		is_grounded: true
	}
	apply_flap(mut m, 180.0)
	assert m.vy == -180.0
	assert m.is_grounded == false
}

fn test_wraparound_physics() {
	mut m := MotionState{
		x:           -25.0
		y:           300
		vx:          -50.0
		vy:          0
		is_grounded: false
	}
	update_motion(mut m, 0.016, 800.0)
	assert m.x > 700.0
}

fn test_stage_setup() {
	mut ge := new_game_engine()
	ge.start_game(.mode_a_1p)
	assert ge.state == .playing
	assert ge.players.len == 1
	assert ge.enemies.len > 0
	assert ge.platforms.len > 0
}

fn test_balloon_collisions() {
	mut ge := new_game_engine()
	sm := new_sound_manager()
	ge.start_game(.mode_a_1p)

	// Position player directly above enemy (p_feet <= e_head + 12)
	ge.players[0].motion.x = 200.0
	ge.players[0].motion.y = 90.0
	ge.players[0].motion.vy = 50.0

	ge.enemies[0].motion.x = 200.0
	ge.enemies[0].motion.y = 120.0
	ge.enemies[0].motion.vy = 0.0
	ge.enemies[0].balloons = 2
	ge.enemies[0].state = .flying

	ge.check_balloon_collisions(&sm)

	assert ge.enemies[0].balloons == 1
}

fn test_giant_fish_trigger() {
	mut ge := new_game_engine()
	sm := new_sound_manager()
	ge.start_game(.mode_a_1p)

	// Player hovers low over water
	ge.players[0].motion.x = 300.0
	ge.players[0].motion.y = 480.0
	ge.fish.cooldown = 3.5

	ge.update_giant_fish(0.016, &sm)

	assert ge.fish.active == true
	assert ge.fish.x == 300.0
}

fn test_balloon_trip_mode() {
	mut ge := new_game_engine()
	sm := new_sound_manager()
	ge.start_game(.balloon_trip)

	assert ge.mode == .balloon_trip
	assert ge.trip_balloons.len > 0

	// Player collects trip balloon
	ge.players[0].motion.x = ge.trip_balloons[0].x - ge.trip_scroll_x
	ge.players[0].motion.y = ge.trip_balloons[0].y

	ge.update_balloon_trip_mode(0.016, false, false, false, &sm)

	assert ge.trip_balloons[0].collected == true
	assert ge.score > 0
}
