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
	if !mutable_sm.sound_enabled && sm.dev != 0 {
		sdl.clear_queued_audio(sm.dev)
	}
	return mutable_sm.sound_enabled
}

fn (sm &SoundManager) clear_audio() {
	if sm.dev != 0 {
		sdl.clear_queued_audio(sm.dev)
	}
}

fn (sm &SoundManager) play_pcm(pcm []i16) {
	if !sm.sound_enabled || sm.dev == 0 || pcm.len == 0 {
		return
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_laser_sound() {
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
		freq := 950.0 - (750.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-22.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		pcm[i] = i16(harm * env * attack * 20000.0)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_plasma_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 90
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1300.0 - (1000.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-16.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.4 * math.sin(4.0 * math.pi * freq * t)
		pcm[i] = i16(harm * env * attack * 22000.0)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_explosion_sound(size int) {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := if size == 3 { 380 } else if size == 2 { 240 } else { 160 }
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (rand.f64() * 2.0) - 1.0
		sub_freq := if size == 3 { 90.0 } else { 130.0 }
		sub := math.sin(2.0 * math.pi * (sub_freq - 50.0 * (f64(i) / f64(num_samples))) * t)
		decay := if size == 3 { 7.0 } else if size == 2 { 12.0 } else { 18.0 }
		env := math.exp(-decay * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		val := (noise * 0.65 + sub * 0.35) * env * attack * 24000.0
		pcm[i] = i16(val)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_powerup_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [440.0, 554.37, 659.25, 880.0]
	note_dur := 45
	num_samples := (sample_rate * note_dur * notes.len) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	attack_samples := sample_rate * 2 / 1000

	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		for i in 0 .. samples_per_note {
			sample_idx := start_sample + i
			if sample_idx >= num_samples { break }
			t := f64(i) / f64(sample_rate)
			env := math.exp(-12.0 * t)
			attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
			harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
			pcm[sample_idx] = i16(harm * env * attack * 20000.0)
		}
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_emp_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 380
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1600.0 * math.exp(-6.0 * t) + 80.0
		noise := (rand.f64() * 2.0) - 1.0
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := (math.sin(2.0 * math.pi * freq * t) * 0.7 + noise * 0.3)
		pcm[i] = i16(harm * math.exp(-4.0 * t) * attack * 24000.0)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_warp_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 240
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 4 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 200.0 + (1600.0 * math.sin(math.pi * f64(i) / f64(num_samples)))
		env := math.sin(math.pi * f64(i) / f64(num_samples))
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		val := math.sin(2.0 * math.pi * freq * t) * env * attack * 20000.0
		pcm[i] = i16(val)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_shield_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 120
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 240.0 + math.sin(60.0 * t) * 60.0
		env := math.exp(-15.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		pcm[i] = i16(harm * env * attack * 18000.0)
	}
	sm.play_pcm(pcm)
}
