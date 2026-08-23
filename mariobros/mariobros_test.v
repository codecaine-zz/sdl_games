module main

fn test_game_initialization() {
	mut game := new_mario_bros_game()
	assert game.state == .title
	assert game.platforms.len >= 5
	assert game.high_score >= 20000

	game.start_game(.single_player)
	assert game.state == .playing
	assert game.players.len == 1
	assert game.players[0].id == 1
	assert game.players[0].lives == 3
	assert game.pow_block.hits_left == 3
	assert game.pow_block.active == true
}

fn test_two_player_mode() {
	mut game := new_mario_bros_game()
	game.start_game(.two_players)
	assert game.state == .playing
	assert game.players.len == 2
	assert game.players[0].id == 1
	assert game.players[1].id == 2
	assert game.players[0].lives == 3
	assert game.players[1].lives == 3
}

fn test_platform_bump_and_shellcreeper_flip() {
	mut game := new_mario_bros_game()
	game.start_game(.single_player)
	game.enemies_left = 0
	game.enemies.clear()

	// Spawn a shellcreeper on Tier 2 platform (Y=290, top at 262)
	mut turtle := Enemy{
		id: 10
		enemy_type: .shellcreeper
		state: .walking
		x: 300.0
		y: 262.0
		vx: 100.0
		vy: 0.0
		is_grounded: true
		active: true
	}
	game.enemies << turtle

	// Trigger a bump wave right underneath the turtle at (300, 290)
	game.trigger_bump_wave(300.0, 290.0)

	assert game.enemies[0].state == .stunned
	assert game.enemies[0].stun_timer > 5.0
	assert game.enemies[0].vy < 0.0 // Bounced upward
}

fn test_sidestepper_two_hits() {
	mut game := new_mario_bros_game()
	game.start_game(.single_player)
	game.enemies_left = 0
	game.enemies.clear()

	// Crab on platform
	mut crab := Enemy{
		id: 11
		enemy_type: .sidestepper
		state: .walking
		x: 300.0
		y: 262.0
		vx: 100.0
		vy: 0.0
		is_grounded: true
		active: true
	}
	game.enemies << crab

	// 1st hit -> Enrages the crab (turns red / angry, doubles speed)
	game.trigger_bump_wave(300.0, 290.0)
	assert game.enemies[0].state == .angry
	assert game.enemies[0].angry_level == 1

	// 2nd hit while angry -> Flips crab onto its back!
	game.enemies[0].is_grounded = true
	game.enemies[0].y = 262.0
	game.trigger_bump_wave(300.0, 290.0)
	assert game.enemies[0].state == .stunned
	assert game.enemies[0].stun_timer > 4.0
}

fn test_pow_block_mechanics() {
	mut game := new_mario_bros_game()
	game.start_game(.single_player)
	game.enemies_left = 0
	game.enemies.clear()

	// Add 2 grounded enemies across the stage
	game.enemies << Enemy{
		id: 1
		enemy_type: .shellcreeper
		state: .walking
		x: 200.0
		y: 132.0
		is_grounded: true
		active: true
	}
	game.enemies << Enemy{
		id: 2
		enemy_type: .fighterfly
		state: .walking
		x: 400.0
		y: 262.0
		is_grounded: true
		active: true
	}

	assert game.pow_block.hits_left == 3
	game.hit_pow_block()

	assert game.pow_block.hits_left == 2
	assert game.screen_shake > 0.0
	assert game.enemies[0].state == .stunned
	assert game.enemies[1].state == .stunned

	// Exhaust POW block
	game.hit_pow_block()
	assert game.pow_block.hits_left == 1
	game.hit_pow_block()
	assert game.pow_block.hits_left == 0
	assert game.pow_block.active == false
}

fn test_enemy_kick_and_combo_scoring() {
	mut game := new_mario_bros_game()
	game.start_game(.single_player)
	game.enemies_left = 0
	game.enemies.clear()
	game.players[0].x = 300.0
	game.players[0].y = 504.0
	game.players[0].score = 0

	// Flipped enemy right in front of Mario
	game.enemies << Enemy{
		id: 1
		enemy_type: .shellcreeper
		state: .stunned
		stun_timer: 6.0
		x: 310.0
		y: 504.0
		is_grounded: true
		active: true
	}

	// Update game step to trigger collision
	game.update(0.016)

	assert game.enemies[0].state == .kicked
	assert game.players[0].score == 800
	assert game.players[0].combo_count == 1

	// Kick second enemy within combo window
	game.enemies.clear()
	game.enemies << Enemy{
		id: 2
		enemy_type: .shellcreeper
		state: .stunned
		stun_timer: 6.0
		x: 310.0
		y: 504.0
		is_grounded: true
		active: true
	}
	game.update(0.016)
	assert game.players[0].score == 800 + 1600
	assert game.players[0].combo_count == 2
}

fn test_screen_wrap_around() {
	mut game := new_mario_bros_game()
	game.start_game(.single_player)
	game.enemies_left = 0

	// Move player past left screen edge
	game.players[0].x = -35.0
	game.players[0].vx = -100.0
	game.update(0.016)
	assert game.players[0].x >= 750.0

	// Move player past right screen edge
	game.players[0].x = 805.0
	game.players[0].vx = 100.0
	game.update(0.016)
	assert game.players[0].x <= 0.0
}

fn test_bonus_phase_coin_collection() {
	mut game := new_mario_bros_game()
	game.setup_phase(3)
	assert game.state == .bonus_phase
	assert game.coins.len == 10

	// Collect coin
	game.players << Player{
		id: 1
		x: game.coins[0].x
		y: game.coins[0].y
		lives: 3
	}
	initial_coins := game.coins.len
	game.update(0.016)
	assert game.players[0].score == 800
	assert game.coins.len == initial_coins - 1
}

fn test_sound_manager_toggle() {
	mut sm := new_sound_manager()
	initial := sm.sound_enabled
	toggled := sm.toggle_sound()
	assert toggled != initial
	assert sm.toggle_sound() == initial
}
