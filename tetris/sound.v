module main

import math
import sdl

struct SoundManager {
mut:
	dev           sdl.AudioDeviceID
	sound_enabled bool = true
}

fn new_sound_manager() SoundManager {
	if sdl.was_init(sdl.init_audio) == 0 {
		sdl.init_sub_system(sdl.init_audio)
	}

	desired := sdl.AudioSpec{
		freq:     44100
		format:   sdl.audio_s16
		channels: 1
		samples:  1024
		callback: unsafe { nil }
		userdata: unsafe { nil }
	}
	mut obtained := sdl.AudioSpec{}
	dev_id := sdl.open_audio_device(unsafe { nil }, 0, &desired, &obtained, 0)
	if dev_id != 0 {
		sdl.pause_audio_device(dev_id, 0)
	}

	return SoundManager{
		dev:           dev_id
		sound_enabled: dev_id != 0
	}
}

fn (sm &SoundManager) toggle_sound() bool {
	mut mutable_sm := unsafe { &SoundManager(sm) }
	mutable_sm.sound_enabled = !mutable_sm.sound_enabled
	return mutable_sm.sound_enabled
}

// Helper to queue PCM with soft anti-click ramp
fn (sm &SoundManager) play_pcm(pcm []i16) {
	if !sm.sound_enabled || sm.dev == 0 || pcm.len == 0 {
		return
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_move_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 25
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 520.0
		env := math.exp(-45.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.25 * math.sin(4.0 * math.pi * freq * t)
		val := harm * env * attack * 12000.0
		pcm[i] = i16(val)
	}

	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_rotate_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 40
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 580.0 + (380.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-30.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		val := harm * env * attack * 14000.0
		pcm[i] = i16(val)
	}

	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_drop_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 65
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 240.0 - (160.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-28.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		// Low punch with sub-bass resonance
		val := (math.sin(2.0 * math.pi * freq * t) + 0.4 * math.sin(math.pi * freq * t)) * env * attack * 22000.0
		pcm[i] = i16(val)
	}

	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_hold_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 50
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 400.0 + (500.0 * math.sin(math.pi * f64(i) / f64(num_samples)))
		env := math.exp(-25.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		val := math.sin(2.0 * math.pi * freq * t) * env * attack * 15000.0
		pcm[i] = i16(val)
	}

	sm.play_pcm(pcm)
}

// Multi-tiered rewarding line clear sound
fn (sm &SoundManager) play_clear_sound(cleared int) {
	if !sm.sound_enabled || sm.dev == 0 || cleared <= 0 {
		return
	}
	sample_rate := 44100

	if cleared == 1 {
		// Single line clear: Bright sparkling bell chime (C6 + E6)
		duration_ms := 140
		num_samples := (sample_rate * duration_ms) / 1000
		mut pcm := []i16{len: num_samples}
		attack_samples := sample_rate * 2 / 1000

		for i in 0 .. num_samples {
			t := f64(i) / f64(sample_rate)
			env := math.exp(-15.0 * t)
			attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
			f1 := 1046.50 // C6
			f2 := 1318.51 // E6
			val := (math.sin(2.0 * math.pi * f1 * t) * 0.7 + math.sin(2.0 * math.pi * f2 * t) * 0.5) * env * attack * 19000.0
			pcm[i] = i16(val)
		}
		sm.play_pcm(pcm)
	} else if cleared == 2 {
		// Double line clear: Ascending dual bell chord (G5 -> C6)
		notes := [783.99, 1046.50]
		note_dur_ms := 75
		total_samples := (sample_rate * note_dur_ms * notes.len) / 1000
		mut pcm := []i16{len: total_samples}

		for n_idx, freq in notes {
			start_sample := (sample_rate * note_dur_ms * n_idx) / 1000
			note_samples := (sample_rate * note_dur_ms) / 1000
			attack_samples := sample_rate * 2 / 1000
			for i in 0 .. note_samples {
				t := f64(i) / f64(sample_rate)
				env := math.exp(-12.0 * t)
				attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
				val := (math.sin(2.0 * math.pi * freq * t) + 0.35 * math.sin(4.0 * math.pi * freq * t)) * env * attack * 20000.0
				pcm[start_sample + i] = i16(val)
			}
		}
		sm.play_pcm(pcm)
	} else if cleared == 3 {
		// Triple line clear: Radiant triple arpeggio (E5 -> G5 -> C6)
		notes := [659.25, 783.99, 1046.50]
		note_dur_ms := 70
		total_samples := (sample_rate * note_dur_ms * notes.len) / 1000
		mut pcm := []i16{len: total_samples}

		for n_idx, freq in notes {
			start_sample := (sample_rate * note_dur_ms * n_idx) / 1000
			note_samples := (sample_rate * note_dur_ms) / 1000
			attack_samples := sample_rate * 2 / 1000
			for i in 0 .. note_samples {
				t := f64(i) / f64(sample_rate)
				env := math.exp(-10.0 * t)
				attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
				val := (math.sin(2.0 * math.pi * freq * t) + 0.4 * math.sin(4.0 * math.pi * freq * t)) * env * attack * 21000.0
				pcm[start_sample + i] = i16(val)
			}
		}
		sm.play_pcm(pcm)
	} else {
		// 4 Lines (TETRIS!): EPIC triumphant 5-note fanfare arpeggio with shimmering decay
		notes := [523.25, 659.25, 783.99, 1046.50, 1318.51] // C5, E5, G5, C6, E6
		note_dur_ms := 65
		total_samples := (sample_rate * (note_dur_ms * 4 + 180)) / 1000
		mut pcm := []i16{len: total_samples}

		for n_idx, freq in notes {
			start_sample := (sample_rate * note_dur_ms * n_idx) / 1000
			note_dur := if n_idx == notes.len - 1 { 180 } else { note_dur_ms }
			note_samples := (sample_rate * note_dur) / 1000
			attack_samples := sample_rate * 2 / 1000
			for i in 0 .. note_samples {
				if start_sample + i >= total_samples {
					break
				}
				t := f64(i) / f64(sample_rate)
				decay := if n_idx == notes.len - 1 { -6.0 } else { -9.0 }
				env := math.exp(decay * t)
				attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
				harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t) + 0.15 * math.sin(6.0 * math.pi * freq * t)
				val := harm * env * attack * 22000.0
				pcm[start_sample + i] = i16(val)
			}
		}
		sm.play_pcm(pcm)
	}
}

fn (sm &SoundManager) play_level_up_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [440.0, 554.37, 659.25, 880.0, 1108.73] // A4, C#5, E5, A5, C#6
	note_dur_ms := 60
	total_samples := (sample_rate * (note_dur_ms * 4 + 160)) / 1000
	mut pcm := []i16{len: total_samples}

	for n_idx, freq in notes {
		start_sample := (sample_rate * note_dur_ms * n_idx) / 1000
		note_dur := if n_idx == notes.len - 1 { 160 } else { note_dur_ms }
		note_samples := (sample_rate * note_dur) / 1000
		attack_samples := sample_rate * 2 / 1000
		for i in 0 .. note_samples {
			if start_sample + i >= total_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			decay := if n_idx == notes.len - 1 { -7.0 } else { -10.0 }
			env := math.exp(decay * t)
			attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
			val := (math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)) * env * attack * 21000.0
			pcm[start_sample + i] = i16(val)
		}
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_game_over_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [523.25, 415.30, 349.23, 277.18] // C5, G#4, F4, C#4
	note_dur_ms := 110
	total_samples := (sample_rate * note_dur_ms * notes.len) / 1000
	mut pcm := []i16{len: total_samples}

	for n_idx, freq in notes {
		start_sample := (sample_rate * note_dur_ms * n_idx) / 1000
		note_samples := (sample_rate * note_dur_ms) / 1000
		attack_samples := sample_rate * 2 / 1000
		for i in 0 .. note_samples {
			t := f64(i) / f64(sample_rate)
			env := math.exp(-8.0 * t)
			attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
			// Slight vibrato / crunch for game over
			vibrato := math.sin(2.0 * math.pi * 6.0 * t) * 8.0
			val := (math.sin(2.0 * math.pi * (freq + vibrato) * t) + 0.25 * math.sin(4.0 * math.pi * freq * t)) * env * attack * 20000.0
			pcm[start_sample + i] = i16(val)
		}
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_click_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 25
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 750.0
		env := math.exp(-55.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		val := math.sin(2.0 * math.pi * freq * t) * env * attack * 14000.0
		pcm[i] = i16(val)
	}

	sm.play_pcm(pcm)
}

fn (sm &SoundManager) cleanup() {
	if sm.dev != 0 {
		sdl.close_audio_device(sm.dev)
	}
}
