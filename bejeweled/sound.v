module main

import math
import rand
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

fn (sm &SoundManager) play_pcm(pcm []i16) {
	if !sm.sound_enabled || sm.dev == 0 || pcm.len == 0 {
		return
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_select_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 35
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1250.0
		env := math.exp(-45.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.25 * math.sin(4.0 * math.pi * freq * t)
		sample := harm * env * attack * 14000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_swap_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 45
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 480.0 + (320.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-32.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.25 * math.sin(4.0 * math.pi * freq * t)
		sample := harm * env * attack * 12000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_match_sound(combo int) {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 160
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	// Pentatonic scale base frequencies: C5, D5, E5, G5, A5, C6, D6, E6
	scale := [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50, 1174.66, 1318.51]
	idx := math.min(combo - 1, scale.len - 1)
	base_freq := scale[math.max(0, idx)]

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		env := math.exp(-12.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		// Fundamental + bell harmonics
		harm := math.sin(2.0 * math.pi * base_freq * t) * 0.7 +
			math.sin(2.0 * math.pi * base_freq * 2.0 * t) * 0.3 +
			math.sin(2.0 * math.pi * base_freq * 3.0 * t) * 0.15
		sample := harm * env * attack * 20000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_flame_explosion_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 280
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 180.0 - (130.0 * (f64(i) / f64(num_samples)))
		noise := (rand.f64() * 2.0 - 1.0)
		env := math.exp(-8.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		sample := (math.sin(2.0 * math.pi * freq * t) * 0.4 + noise * 0.6) * env * attack * 24000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_hypercube_zap_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 320
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 220.0 + (1300.0 * math.sin(45.0 * math.pi * t))
		env := math.exp(-6.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		sample := harm * env * attack * 20000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_win_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 420
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51]
	note_len := num_samples / notes.len
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		note_idx := math.min(i / note_len, notes.len - 1)
		freq := notes[note_idx]
		local_i := i % note_len
		t_note := f64(local_i) / f64(sample_rate)
		decay := if note_idx == notes.len - 1 { -6.0 } else { -10.0 }
		env := math.exp(decay * t_note)
		attack := if local_i < attack_samples { f64(local_i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t_note) + 0.35 * math.sin(4.0 * math.pi * freq * t_note)
		sample := harm * env * attack * 20000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_invalid_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 70
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 180.0
		env := math.exp(-32.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		sample := math.sin(2.0 * math.pi * freq * t) * env * attack * 14000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) cleanup() {
	if sm.dev != 0 {
		sdl.close_audio_device(sm.dev)
	}
}
