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
	rank int // 1=Ace, 2..10, 11=J, 12=Q, 13=K
	suit CardSuit
}

pub struct Hand {
pub mut:
	cards      []Card
	bet        int
	is_doubled bool
	is_stand   bool
	is_busted  bool
	is_bj      bool
	is_surrender bool
}

pub enum BJState {
	betting
	player_turn
	dealer_turn
	round_over
}

pub struct BlackjackGame {
pub mut:
	shoe            []Card
	player_hands    []Hand
	active_hand_idx int
	dealer_hand     []Card
	dealer_hidden   bool = true
	chips           int = 1000
	current_bet     int = 25
	last_payout     int
	state           BJState = .betting
	insurance_bet   int
	insurance_avail bool
	dealer_bj       bool
	celebration     string
	celeb_timer     f64
	state_timer     f64
	// Stats
	hands_played    int
	hands_won       int
	hands_lost      int
	hands_pushed    int
	blackjacks_hit  int
}

pub fn new_blackjack_game() BlackjackGame {
	mut game := BlackjackGame{
		chips: 1000
		current_bet: 25
		state: .betting
	}
	game.init_shoe(4) // 4-deck shoe
	return game
}

pub fn (mut g BlackjackGame) init_shoe(num_decks int) {
	g.shoe.clear()
	suits := [CardSuit.hearts, CardSuit.diamonds, CardSuit.clubs, CardSuit.spades]
	for _ in 0 .. num_decks {
		for s in suits {
			for r := 1; r <= 13; r++ {
				g.shoe << Card{ rank: r, suit: s }
			}
		}
	}
	shuffle_shoe(mut g.shoe)
}

pub fn shuffle_shoe(mut shoe []Card) {
	for i := shoe.len - 1; i > 0; i-- {
		j := rand.int_in_range(0, i + 1) or { 0 }
		temp := shoe[i]
		shoe[i] = shoe[j]
		shoe[j] = temp
	}
}

pub fn (mut g BlackjackGame) draw_card() Card {
	if g.shoe.len < 20 {
		g.init_shoe(4)
	}
	return g.shoe.pop()
}

pub fn calculate_hand_value(cards []Card) (int, bool) {
	mut total := 0
	mut aces := 0

	for c in cards {
		if c.rank == 1 {
			aces++
			total += 11
		} else if c.rank >= 10 {
			total += 10
		} else {
			total += c.rank
		}
	}

	mut is_soft := false
	for total > 21 && aces > 0 {
		total -= 10
		aces--
	}

	if aces > 0 {
		is_soft = true
	}

	return total, is_soft
}

pub fn is_natural_blackjack(cards []Card) bool {
	if cards.len != 2 {
		return false
	}
	c1 := cards[0]
	c2 := cards[1]
	has_ace := c1.rank == 1 || c2.rank == 1
	has_ten := (c1.rank >= 10 && c1.rank <= 13) || (c2.rank >= 10 && c2.rank <= 13)
	return has_ace && has_ten
}

pub fn (mut g BlackjackGame) place_chip(amount int) {
	if g.state == .betting {
		if g.chips >= amount {
			g.current_bet += amount
		}
	}
}

pub fn (mut g BlackjackGame) clear_bet() {
	if g.state == .betting {
		g.current_bet = 0
	}
}

pub fn (mut g BlackjackGame) deal(mut sound_mgr SoundManager) {
	if g.state != .betting || g.current_bet <= 0 || g.chips < g.current_bet {
		return
	}

	g.chips -= g.current_bet
	g.player_hands.clear()
	g.dealer_hand.clear()
	g.insurance_bet = 0
	g.insurance_avail = false
	g.last_payout = 0
	g.celebration = ''
	g.hands_played++

	mut initial_hand := Hand{
		cards: []Card{cap: 10}
		bet: g.current_bet
	}

	// Deal 2 cards to player, 2 to dealer
	initial_hand.cards << g.draw_card()
	g.dealer_hand << g.draw_card()
	initial_hand.cards << g.draw_card()
	g.dealer_hand << g.draw_card()
	g.dealer_hidden = true

	g.player_hands << initial_hand
	g.active_hand_idx = 0

	sound_mgr.play_card_deal()

	// Check natural blackjack
	if is_natural_blackjack(g.player_hands[0].cards) {
		g.player_hands[0].is_bj = true
		g.player_hands[0].is_stand = true
		g.blackjacks_hit++
		// Reveal dealer and finish
		g.state = .dealer_turn
		g.state_timer = 0.0
		return
	}

	// Offer Insurance if dealer's upcard is Ace
	if g.dealer_hand[0].rank == 1 {
		g.insurance_avail = true
	}

	g.state = .player_turn
}

pub fn (mut g BlackjackGame) hit(mut sound_mgr SoundManager) {
	if g.state != .player_turn {
		return
	}

	mut hand := &g.player_hands[g.active_hand_idx]
	if hand.is_stand || hand.is_busted {
		return
	}

	hand.cards << g.draw_card()
	sound_mgr.play_card_deal()

	val, _ := calculate_hand_value(hand.cards)
	if val > 21 {
		hand.is_busted = true
		hand.is_stand = true
		sound_mgr.play_bust()
		g.advance_hand_or_dealer()
	} else if val == 21 {
		hand.is_stand = true
		g.advance_hand_or_dealer()
	}
}

pub fn (mut g BlackjackGame) stand(mut sound_mgr SoundManager) {
	if g.state != .player_turn {
		return
	}

	mut hand := &g.player_hands[g.active_hand_idx]
	hand.is_stand = true
	sound_mgr.play_stand_knock()
	g.advance_hand_or_dealer()
}

pub fn (mut g BlackjackGame) double_down(mut sound_mgr SoundManager) {
	if g.state != .player_turn {
		return
	}

	mut hand := &g.player_hands[g.active_hand_idx]
	if hand.cards.len != 2 || g.chips < hand.bet {
		return
	}

	g.chips -= hand.bet
	hand.bet *= 2
	hand.is_doubled = true

	// Receive exactly 1 card then stand
	hand.cards << g.draw_card()
	sound_mgr.play_card_deal()

	val, _ := calculate_hand_value(hand.cards)
	if val > 21 {
		hand.is_busted = true
		sound_mgr.play_bust()
	}
	hand.is_stand = true
	g.advance_hand_or_dealer()
}

pub fn (mut g BlackjackGame) split(mut sound_mgr SoundManager) {
	if g.state != .player_turn || g.player_hands.len >= 2 {
		return
	}

	mut hand := &g.player_hands[0]
	if hand.cards.len != 2 || g.chips < hand.bet {
		return
	}

	r1 := if hand.cards[0].rank >= 10 { 10 } else { hand.cards[0].rank }
	r2 := if hand.cards[1].rank >= 10 { 10 } else { hand.cards[1].rank }
	if r1 != r2 {
		return
	}

	g.chips -= hand.bet
	c2 := hand.cards.pop()

	mut hand2 := Hand{
		cards: [c2, g.draw_card()]
		bet: hand.bet
	}
	hand.cards << g.draw_card()

	g.player_hands << hand2
	sound_mgr.play_card_deal()
}

pub fn (mut g BlackjackGame) buy_insurance() {
	if g.state == .player_turn && g.insurance_avail && g.insurance_bet == 0 {
		ins_cost := g.current_bet / 2
		if g.chips >= ins_cost {
			g.chips -= ins_cost
			g.insurance_bet = ins_cost
			g.insurance_avail = false
		}
	}
}

fn (mut g BlackjackGame) advance_hand_or_dealer() {
	if g.active_hand_idx < g.player_hands.len - 1 {
		g.active_hand_idx++
	} else {
		g.state = .dealer_turn
		g.state_timer = 0.0
		g.dealer_hidden = false
	}
}

pub fn (mut g BlackjackGame) update(dt f64, mut sound_mgr SoundManager) {
	if g.celeb_timer > 0.0 {
		g.celeb_timer -= dt
		if g.celeb_timer <= 0.0 {
			g.celebration = ''
		}
	}

	if g.state == .dealer_turn {
		g.state_timer += dt
		if g.state_timer >= 0.7 {
			g.state_timer = 0.0
			g.process_dealer_step(mut sound_mgr)
		}
	}
}

fn (mut g BlackjackGame) process_dealer_step(mut sound_mgr SoundManager) {
	g.dealer_hidden = false

	// Check if all player hands busted
	mut all_busted := true
	for h in g.player_hands {
		if !h.is_busted {
			all_busted = false
			break
		}
	}

	if all_busted {
		g.evaluate_round_payouts(mut sound_mgr)
		return
	}

	dealer_val, _ := calculate_hand_value(g.dealer_hand)

	// Dealer hits on 16 or less, stands on 17+
	if dealer_val < 17 {
		g.dealer_hand << g.draw_card()
		sound_mgr.play_card_deal()
	} else {
		g.evaluate_round_payouts(mut sound_mgr)
	}
}

fn (mut g BlackjackGame) evaluate_round_payouts(mut sound_mgr SoundManager) {
	g.state = .round_over
	dealer_val, _ := calculate_hand_value(g.dealer_hand)
	dealer_bj := is_natural_blackjack(g.dealer_hand)
	mut total_won := 0
	mut win_count := 0
	mut loss_count := 0

	// Resolve Insurance
	if g.insurance_bet > 0 {
		if dealer_bj {
			ins_pay := g.insurance_bet * 3
			g.chips += ins_pay
			total_won += ins_pay
		}
	}

	for h in g.player_hands {
		p_val, _ := calculate_hand_value(h.cards)

		if h.is_busted {
			loss_count++
			g.hands_lost++
		} else if h.is_bj {
			if dealer_bj {
				// Push
				g.chips += h.bet
				total_won += h.bet
				g.hands_pushed++
			} else {
				// Natural Blackjack (3:2 payout)
				payout := h.bet + int(f64(h.bet) * 1.5)
				g.chips += payout
				total_won += payout
				win_count++
				g.hands_won++
			}
		} else if dealer_val > 21 {
			// Dealer Busted! Player wins 1:1
			payout := h.bet * 2
			g.chips += payout
			total_won += payout
			win_count++
			g.hands_won++
		} else if p_val > dealer_val {
			// Higher hand!
			payout := h.bet * 2
			g.chips += payout
			total_won += payout
			win_count++
			g.hands_won++
		} else if p_val == dealer_val {
			// Push
			g.chips += h.bet
			total_won += h.bet
			g.hands_pushed++
		} else {
			// Loss
			loss_count++
			g.hands_lost++
		}
	}

	g.last_payout = total_won

	if win_count > 0 {
		if g.player_hands[0].is_bj && !dealer_bj {
			g.celebration = 'BLACKJACK 21!! PAYS 3:2 ($${total_won})'
			sound_mgr.play_blackjack_fanfare()
		} else {
			g.celebration = 'YOU WIN!! +$${total_won}'
			sound_mgr.play_win_payout()
		}
	} else if loss_count > 0 && win_count == 0 && total_won == 0 {
		g.celebration = 'DEALER WINS'
		sound_mgr.play_bust()
	} else {
		g.celebration = 'PUSH (TIE)'
	}
	g.celeb_timer = 3.5
}
