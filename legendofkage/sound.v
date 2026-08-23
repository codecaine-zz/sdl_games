module main

import math
import rand
import sdl

pub struct SoundManager {
pub mut:
	dev           sdl.AudioDeviceID
	sound_enabled bool = true
	bgm_step      int
	bgm_phase     f64
}

pub fn new_sound_manager() SoundManager {
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

pub fn (sm &SoundManager) toggle_sound() bool {
	mut mutable_sm := unsafe { &SoundManager(sm) }
	mutable_sm.sound_enabled = !mutable_sm.sound_enabled
	if !mutable_sm.sound_enabled && sm.dev != 0 {
		sdl.clear_queued_audio(sm.dev)
	}
	return mutable_sm.sound_enabled
}

// Procedural The Legend of Kage Feudal Ninja BGM
pub fn (sm &SoundManager) update_bgm(dt f64, is_active bool) {
	if !sm.sound_enabled || sm.dev == 0 || !is_active {
		return
	}
	queued := sdl.get_queued_audio_size(sm.dev)
	if queued > u32(44100 * 2 / 5) {
		return
	}

	mut mutable_sm := unsafe { &SoundManager(sm) }

	sample_rate := 44100
	step_duration := 0.125 // ~120 BPM
	samples_per_step := int(f64(sample_rate) * step_duration)
	mut pcm := []i16{len: samples_per_step}

	// Japanese Hirajoshi / Insen pentatonic scale (A, Bb, D, E, F)
	lead_melody := [
		440.00, 0.0, 466.16, 587.33, 659.25, 587.33, 466.16, 440.00,
		392.00, 0.0, 440.00, 466.16, 587.33, 659.25, 698.46, 0.0,
		880.00, 0.0, 698.46, 659.25, 587.33, 659.25, 698.46, 880.00,
		932.33, 0.0, 880.00, 698.46, 659.25, 587.33, 440.00, 0.0,
	]
	// Taiko drum / bass cadence
	bass_notes := [
		110.00, 110.00, 164.81, 110.00, 130.81, 110.00, 164.81, 110.00,
		98.00,  98.00,  146.83, 98.00,  110.00, 110.00, 164.81, 110.00,
		110.00, 110.00, 164.81, 110.00, 146.83, 146.83, 174.61, 174.61,
		110.00, 110.00, 164.81, 110.00, 98.00,  98.00,  110.00, 110.00,
	]

	step := mutable_sm.bgm_step % lead_melody.len
	lead_freq := lead_melody[step]
	bass_freq := bass_notes[step]

	for i in 0 .. samples_per_step {
		t := f64(i) / f64(sample_rate)
		env := math.exp(-6.0 * (f64(i) / f64(samples_per_step)))

		// Shakuhachi flute-like breathy square wave
		mut lead := 0.0
		if lead_freq > 0.0 {
			sq := if math.sin(2.0 * math.pi * lead_freq * (t + mutable_sm.bgm_phase)) > 0.0 { 1.0 } else { -1.0 }
			breath := (f64(rand.intn(1000) or { 500 }) / 1000.0) - 0.5
			lead = sq * 0.85 + breath * 0.15
		}

		// Low Taiko resonance
		bass := math.sin(2.0 * math.pi * bass_freq * (t + mutable_sm.bgm_phase)) * math.exp(-8.0 * (f64(i) / f64(samples_per_step)))

		// Taiko Rim Click
		mut drum := 0.0
		if step % 4 == 0 && i < samples_per_step / 4 {
			noise := f64((i * 1103515245 + 12345) % 65536) / 32768.0 - 1.0
			drum = noise * math.exp(-35.0 * t)
		}

		sample_val := (lead * 0.28 * env + bass * 0.28 + drum * 0.14) * 12000.0
		pcm[i] = i16(math.max(-32767.0, math.min(32767.0, sample_val)))
	}

	mutable_sm.bgm_phase += step_duration
	mutable_sm.bgm_step++
	sdl.queue_audio(sm.dev, pcm.data, u32(samples_per_step * 2))
}

pub fn (sm &SoundManager) play_sword_slash() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 85
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		progress := f64(i) / f64(num_samples)
		noise := (f64(rand.intn(2000) or { 1000 }) / 1000.0) - 1.0
		freq := 900.0 - 650.0 * progress
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := math.exp(-14.0 * t)
		pcm[i] = i16((noise * 0.7 + sq * 0.3) * env * 16000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_parry_clink() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 140
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		// Twin resonant metallic frequencies
		s1 := math.sin(2.0 * math.pi * 2489.0 * t) // D#7
		s2 := math.sin(2.0 * math.pi * 3136.0 * t) // G7
		env := math.exp(-22.0 * t)
		pcm[i] = i16((s1 * 0.6 + s2 * 0.4) * env * 19000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_shuriken_throw() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 75
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		progress := f64(i) / f64(num_samples)
		freq := 1200.0 + 800.0 * math.sin(progress * math.pi * 4.0)
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := 1.0 - progress
		pcm[i] = i16(sq * env * 11000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_jump_leap() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		progress := f64(i) / f64(num_samples)
		freq := 280.0 + 720.0 * progress
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := 1.0 - progress * 0.4
		pcm[i] = i16(sq * env * 12000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_scroll_jutsu() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 400
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		progress := f64(i) / f64(num_samples)
		noise := (f64(rand.intn(2000) or { 1000 }) / 1000.0) - 1.0
		sub := math.sin(2.0 * math.pi * (80.0 - 40.0 * progress) * t)
		env := math.exp(-4.0 * t)
		pcm[i] = i16((noise * 0.6 + sub * 0.4) * env * 20000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_enemy_death() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 100
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		progress := f64(i) / f64(num_samples)
		freq := 450.0 - 300.0 * progress
		noise := (f64(rand.intn(2000) or { 1000 }) / 1000.0) - 1.0
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := math.exp(-12.0 * t)
		pcm[i] = i16((noise * 0.5 + sq * 0.5) * env * 15000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_fire_breath() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 220
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (f64(rand.intn(2000) or { 1000 }) / 1000.0) - 1.0
		env := math.exp(-5.0 * t)
		pcm[i] = i16(noise * env * 17000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_stage_clear() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 650
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	notes := [440.0, 523.25, 659.25, 783.99, 880.0, 1046.50] // A4, C5, E5, G5, A5, C6 (Japanese Insen/pentatonic)
	note_len := num_samples / notes.len

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		note_idx := int(math.min(f64(i / note_len), f64(notes.len - 1)))
		freq := notes[note_idx]
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := 1.0 - (f64(i % note_len) / f64(note_len)) * 0.4
		pcm[i] = i16(sq * env * 14000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_die() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 450
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		progress := f64(i) / f64(num_samples)
		freq := 400.0 - 320.0 * progress
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := math.exp(-5.0 * progress)
		pcm[i] = i16(sq * env * 14000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}
