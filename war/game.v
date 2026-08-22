module main

import rand

pub enum CardSuit {
	hearts
	diamonds
	clubs
	spades
}

pub struct Card {
pub mut:
	rank int // 2 .. 14 (11=J, 12=Q, 13=K, 14=A)
	suit CardSuit
}

pub enum WarPhase {
	ready
	flipping
	comparing
	war_declared
	war_flipping
	game_over
}

pub struct WarGame {
pub mut:
	player_draw_pile  []Card
	player_win_pile   []Card
	ai_draw_pile      []Card
	ai_win_pile       []Card
	battle_player     Card
	battle_ai         Card
	has_battle_card   bool
	war_pot           []Card
	phase             WarPhase = .ready
	round_winner      int      // 1: Player, 2: AI, 3: War tie
	phase_timer       f64
	round_count       int
	wars_fought       int
	auto_play         bool
	auto_speed        f64 = 0.6
	celebration       string
	celeb_timer       f64
	match_winner      int // 1: Player, 2: AI
}

pub fn new_war_game() WarGame {
	mut game := WarGame{
		phase: .ready
	}
	game.start_new_match()
	return game
}

pub fn (mut g WarGame) start_new_match() {
	mut deck := generate_52_deck()
	shuffle_52_deck(mut deck)

	g.player_draw_pile.clear()
	g.player_win_pile.clear()
	g.ai_draw_pile.clear()
	g.ai_win_pile.clear()
	g.war_pot.clear()
	g.has_battle_card = false

	// Deal 26 cards to each player
	for i := 0; i < 26; i++ {
		g.player_draw_pile << deck[i]
		g.ai_draw_pile << deck[i + 26]
	}

	g.phase = .ready
	g.round_count = 0
	g.wars_fought = 0
	g.match_winner = 0
	g.celebration = ''
}

pub fn generate_52_deck() []Card {
	mut deck := []Card{cap: 52}
	suits := [CardSuit.hearts, CardSuit.diamonds, CardSuit.clubs, CardSuit.spades]
	for s in suits {
		for r := 2; r <= 14; r++ {
			deck << Card{ rank: r, suit: s }
		}
	}
	return deck
}

pub fn shuffle_52_deck(mut deck []Card) {
	for i := deck.len - 1; i > 0; i-- {
		j := rand.int_in_range(0, i + 1) or { 0 }
		temp := deck[i]
		deck[i] = deck[j]
		deck[j] = temp
	}
}

pub fn (g &WarGame) get_player_total_cards() int {
	return g.player_draw_pile.len + g.player_win_pile.len
}

pub fn (g &WarGame) get_ai_total_cards() int {
	return g.ai_draw_pile.len + g.ai_win_pile.len
}

// Recycle win pile into draw pile if draw pile is depleted
fn (mut g WarGame) recycle_player_deck() {
	if g.player_draw_pile.len == 0 && g.player_win_pile.len > 0 {
		g.player_draw_pile = g.player_win_pile.clone()
		g.player_win_pile.clear()
		shuffle_52_deck(mut g.player_draw_pile)
	}
}

fn (mut g WarGame) recycle_ai_deck() {
	if g.ai_draw_pile.len == 0 && g.ai_win_pile.len > 0 {
		g.ai_draw_pile = g.ai_win_pile.clone()
		g.ai_win_pile.clear()
		shuffle_52_deck(mut g.ai_draw_pile)
	}
}

pub fn (mut g WarGame) step_battle(mut sound_mgr SoundManager) {
	if g.phase != .ready && g.phase != .comparing {
		return
	}

	g.recycle_player_deck()
	g.recycle_ai_deck()

	// Check victory
	if g.player_draw_pile.len == 0 {
		g.match_winner = 2
		g.phase = .game_over
		g.celebration = 'GENERAL BOB WINS THE WAR!!'
		return
	}
	if g.ai_draw_pile.len == 0 {
		g.match_winner = 1
		g.phase = .game_over
		g.celebration = 'VICTORY! YOU CONQUERED ALL 52 CARDS!!'
		sound_mgr.play_victory()
		return
	}

	g.round_count++
	p_card := g.player_draw_pile.pop()
	ai_card := g.ai_draw_pile.pop()

	g.battle_player = p_card
	g.battle_ai = ai_card
	g.has_battle_card = true
	sound_mgr.play_card_flip()

	g.war_pot << p_card
	g.war_pot << ai_card

	if p_card.rank > ai_card.rank {
		// Player Wins Round
		g.round_winner = 1
		g.phase = .comparing
		g.phase_timer = 0.0
		sound_mgr.play_round_win()
	} else if ai_card.rank > p_card.rank {
		// AI Wins Round
		g.round_winner = 2
		g.phase = .comparing
		g.phase_timer = 0.0
		sound_mgr.play_round_win()
	} else {
		// Tie -> "I DECLARE WAR!"
		g.round_winner = 3
		g.wars_fought++
		g.phase = .war_declared
		g.phase_timer = 0.0
		g.celebration = '⚔️ I DECLARE WAR!! ⚔️'
		g.celeb_timer = 2.5
		sound_mgr.play_war_clash()
	}
}

pub fn (mut g WarGame) update(dt f64, mut sound_mgr SoundManager) {
	if g.celeb_timer > 0.0 {
		g.celeb_timer -= dt
		if g.celeb_timer <= 0.0 {
			g.celebration = ''
		}
	}

	match g.phase {
		.comparing {
			g.phase_timer += dt
			threshold := if g.auto_play { g.auto_speed } else { 1.2 }
			if g.phase_timer >= threshold {
				// Award war pot to winner
				if g.round_winner == 1 {
					for c in g.war_pot {
						g.player_win_pile << c
					}
				} else if g.round_winner == 2 {
					for c in g.war_pot {
						g.ai_win_pile << c
					}
				}
				g.war_pot.clear()
				g.has_battle_card = false
				g.phase = .ready

				if g.auto_play {
					g.step_battle(mut sound_mgr)
				}
			}
		}
		.war_declared {
			g.phase_timer += dt
			threshold := if g.auto_play { 0.8 } else { 1.2 }
			if g.phase_timer >= threshold {
				g.execute_war_flip(mut sound_mgr)
			}
		}
		.ready {
			if g.auto_play {
				g.phase_timer += dt
				if g.phase_timer >= g.auto_speed {
					g.step_battle(mut sound_mgr)
				}
			}
		}
		else {}
	}
}

fn (mut g WarGame) execute_war_flip(mut sound_mgr SoundManager) {
	// Put up to 3 cards face down each, then 1 face-up
	for _ in 0 .. 3 {
		g.recycle_player_deck()
		if g.player_draw_pile.len > 1 {
			g.war_pot << g.player_draw_pile.pop()
		}
		g.recycle_ai_deck()
		if g.ai_draw_pile.len > 1 {
			g.war_pot << g.ai_draw_pile.pop()
		}
	}

	g.recycle_player_deck()
	g.recycle_ai_deck()

	if g.player_draw_pile.len == 0 || g.ai_draw_pile.len == 0 {
		g.step_battle(mut sound_mgr)
		return
	}

	p_war_card := g.player_draw_pile.pop()
	ai_war_card := g.ai_draw_pile.pop()

	g.battle_player = p_war_card
	g.battle_ai = ai_war_card
	g.has_battle_card = true
	g.war_pot << p_war_card
	g.war_pot << ai_war_card

	sound_mgr.play_card_flip()

	if p_war_card.rank > ai_war_card.rank {
		g.round_winner = 1
		g.phase = .comparing
		g.phase_timer = 0.0
		g.celebration = 'YOU WON THE WAR! +${g.war_pot.len} CARDS!'
		g.celeb_timer = 2.0
		sound_mgr.play_round_win()
	} else if ai_war_card.rank > p_war_card.rank {
		g.round_winner = 2
		g.phase = .comparing
		g.phase_timer = 0.0
		g.celebration = 'GENERAL BOB WON THE WAR! +${g.war_pot.len} CARDS'
		g.celeb_timer = 2.0
		sound_mgr.play_round_win()
	} else {
		// Double War!
		g.round_winner = 3
		g.wars_fought++
		g.phase = .war_declared
		g.phase_timer = 0.0
		g.celebration = '⚔️ DOUBLE WAR!! ⚔️'
		g.celeb_timer = 2.5
		sound_mgr.play_war_clash()
	}
}

pub fn get_rank_str(r int) string {
	return match r {
		14 { 'A' }
		13 { 'K' }
		12 { 'Q' }
		11 { 'J' }
		10 { '10' }
		else { '${r}' }
	}
}
