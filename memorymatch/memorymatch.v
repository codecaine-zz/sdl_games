module main

import math
import rand

pub enum GridMode {
	grid_4x4
	grid_6x4
	grid_6x6
}

pub enum CardIcon {
	gem
	crown
	star
	key
	potion
	fire
	lightning
	heart
	crescent
	atom
	rocket
	shield
	diamond
	coin
	music
	clover
	bell
	skull
}

pub struct Card {
pub mut:
	id            int
	icon          CardIcon
	is_face_up    bool
	is_matched    bool
	flip_progress f64 // 0.0 = face down, 1.0 = face up
	flip_target   f64
	shake_timer   f64
}

pub enum MemoryState {
	playing
	mismatch_delay
	game_won
}

pub struct MemoryGame {
pub mut:
	grid_mode      GridMode = .grid_4x4
	state          MemoryState = .playing
	cols           int = 4
	rows           int = 4
	cards          []Card
	first_card_idx int = -1
	second_card_idx int = -1
	turns          int
	matches        int
	total_pairs    int = 8
	combo          int
	max_combo      int
	timer          f64
	mismatch_timer f64
	stars          int = 3
	best_turns_4x4 int
	best_turns_6x4 int
	best_turns_6x6 int
	best_time_4x4  f64
	best_time_6x4  f64
	best_time_6x6  f64
}

pub fn new_memory_game() MemoryGame {
	mut g := MemoryGame{}
	g.reset_game()
	return g
}

pub fn (mut g MemoryGame) reset_game() {
	match g.grid_mode {
		.grid_4x4 {
			g.cols = 4
			g.rows = 4
			g.total_pairs = 8
		}
		.grid_6x4 {
			g.cols = 6
			g.rows = 4
			g.total_pairs = 12
		}
		.grid_6x6 {
			g.cols = 6
			g.rows = 6
			g.total_pairs = 18
		}
	}

	g.cards.clear()
	g.first_card_idx = -1
	g.second_card_idx = -1
	g.turns = 0
	g.matches = 0
	g.combo = 0
	g.max_combo = 0
	g.timer = 0.0
	g.mismatch_timer = 0.0
	g.state = .playing
	g.stars = 3

	// Create pairs of icons
	all_icons := [
		CardIcon.gem, .crown, .star, .key, .potion, .fire,
		.lightning, .heart, .crescent, .atom, .rocket, .shield,
		.diamond, .coin, .music, .clover, .bell, .skull,
	]

	mut pair_icons := []CardIcon{cap: g.total_pairs * 2}
	for i in 0 .. g.total_pairs {
		icon := all_icons[i % all_icons.len]
		pair_icons << icon
		pair_icons << icon
	}

	// Fisher-Yates Shuffle
	for i := pair_icons.len - 1; i > 0; i-- {
		j := rand.intn(i + 1) or { 0 }
		temp := pair_icons[i]
		pair_icons[i] = pair_icons[j]
		pair_icons[j] = temp
	}

	for id, icon in pair_icons {
		g.cards << Card{
			id:            id
			icon:          icon
			is_face_up:    false
			is_matched:    false
			flip_progress: 0.0
			flip_target:   0.0
		}
	}
}

pub struct MemoryEvents {
pub mut:
	card_flipped   bool
	cards_matched  bool
	cards_mismatch bool
	game_won       bool
	combo_level    int
}

pub fn (mut g MemoryGame) update(dt f64) MemoryEvents {
	mut ev := MemoryEvents{}

	if g.state == .playing || g.state == .mismatch_delay {
		g.timer += dt
	}

	// Update 3D card flipping animations
	for mut card in g.cards {
		if card.flip_progress < card.flip_target {
			card.flip_progress = math.min(card.flip_progress + dt * 6.0, card.flip_target)
		} else if card.flip_progress > card.flip_target {
			card.flip_progress = math.max(card.flip_progress - dt * 6.0, card.flip_target)
		}

		if card.shake_timer > 0.0 {
			card.shake_timer -= dt
		}
	}

	if g.state == .mismatch_delay {
		g.mismatch_timer -= dt
		if g.mismatch_timer <= 0.0 {
			// Flip mismatched cards back down
			if g.first_card_idx >= 0 && g.first_card_idx < g.cards.len {
				g.cards[g.first_card_idx].is_face_up = false
				g.cards[g.first_card_idx].flip_target = 0.0
			}
			if g.second_card_idx >= 0 && g.second_card_idx < g.cards.len {
				g.cards[g.second_card_idx].is_face_up = false
				g.cards[g.second_card_idx].flip_target = 0.0
			}
			g.first_card_idx = -1
			g.second_card_idx = -1
			g.state = .playing
		}
	}

	return ev
}

pub fn (mut g MemoryGame) flip_card(idx int) (bool, MemoryEvents) {
	mut ev := MemoryEvents{}
	if g.state != .playing || idx < 0 || idx >= g.cards.len {
		return false, ev
	}

	if g.cards[idx].is_face_up || g.cards[idx].is_matched {
		return false, ev
	}

	// Flip chosen card face up
	g.cards[idx].is_face_up = true
	g.cards[idx].flip_target = 1.0
	ev.card_flipped = true

	if g.first_card_idx == -1 {
		// First card in turn
		g.first_card_idx = idx
	} else if g.second_card_idx == -1 {
		// Second card in turn
		g.second_card_idx = idx
		g.turns++

		c1 := g.cards[g.first_card_idx]
		c2 := g.cards[g.second_card_idx]

		if c1.icon == c2.icon {
			// Matched!
			g.cards[g.first_card_idx].is_matched = true
			g.cards[g.second_card_idx].is_matched = true
			g.matches++
			g.combo++
			if g.combo > g.max_combo { g.max_combo = g.combo }

			ev.cards_matched = true
			ev.combo_level = g.combo

			g.first_card_idx = -1
			g.second_card_idx = -1

			if g.matches >= g.total_pairs {
				// All pairs matched -> Victory!
				g.state = .game_won
				ev.game_won = true
				g.calculate_stars()

				match g.grid_mode {
					.grid_4x4 {
						if g.best_turns_4x4 == 0 || g.turns < g.best_turns_4x4 { g.best_turns_4x4 = g.turns }
						if g.best_time_4x4 == 0.0 || g.timer < g.best_time_4x4 { g.best_time_4x4 = g.timer }
					}
					.grid_6x4 {
						if g.best_turns_6x4 == 0 || g.turns < g.best_turns_6x4 { g.best_turns_6x4 = g.turns }
						if g.best_time_6x4 == 0.0 || g.timer < g.best_time_6x4 { g.best_time_6x4 = g.timer }
					}
					.grid_6x6 {
						if g.best_turns_6x6 == 0 || g.turns < g.best_turns_6x6 { g.best_turns_6x6 = g.turns }
						if g.best_time_6x6 == 0.0 || g.timer < g.best_time_6x6 { g.best_time_6x6 = g.timer }
					}
				}
			}
		} else {
			// Mismatch!
			g.combo = 0
			g.state = .mismatch_delay
			g.mismatch_timer = 0.75
			g.cards[g.first_card_idx].shake_timer = 0.35
			g.cards[g.second_card_idx].shake_timer = 0.35
			ev.cards_mismatch = true
		}
	}
	return true, ev
}

pub fn (mut g MemoryGame) calculate_stars() {
	par_turns := g.total_pairs + int(f64(g.total_pairs) * 0.4)
	if g.turns <= par_turns {
		g.stars = 3
	} else if g.turns <= par_turns + 6 {
		g.stars = 2
	} else {
		g.stars = 1
	}
}

pub fn (mut g MemoryGame) toggle_grid_mode() {
	g.grid_mode = match g.grid_mode {
		.grid_4x4 { .grid_6x4 }
		.grid_6x4 { .grid_6x6 }
		.grid_6x6 { .grid_4x4 }
	}
	g.reset_game()
}
