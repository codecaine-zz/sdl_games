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

fn (sm &SoundManager) play_sound_raw(pcm []i16) {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

// Trampoline Boing sound
fn (sm &SoundManager) play_bounce() {
	sample_rate := 44100
	duration_ms := 90
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 180.0 + (t * 2200.0) + math.sin(t * 120.0) * 80.0
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.35
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Door swing open sound
fn (sm &SoundManager) play_door_open() {
	sample_rate := 44100
	duration_ms := 80
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 300.0 + (t * 800.0)
		noise := (rand.f64() * 2.0 - 1.0) * 0.2
		env := math.exp(-12.0 * t)
		val := (math.sin(2.0 * math.pi * freq * t) * 0.6 + noise) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Cat knocked down / stunned sound
fn (sm &SoundManager) play_door_stun() {
	sample_rate := 44100
	duration_ms := 180
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 450.0 - (t * 900.0) + math.sin(t * 240.0) * 120.0
		env := math.exp(-9.0 * t)
		val := math.sin(2.0 * math.pi * math.max(60.0, freq) * t) * env * 0.45
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Microwave ultrasonic shockwave whoosh
fn (sm &SoundManager) play_microwave_wave() {
	sample_rate := 44100
	duration_ms := 320
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1200.0 + math.sin(t * 70.0) * 800.0 + (t * 1500.0)
		env := math.sin(math.pi * (f64(i) / f64(num_samples)))
		noise := (rand.f64() * 2.0 - 1.0) * 0.15
		val := (math.sin(2.0 * math.pi * freq * t) * 0.7 + noise) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Item pickup with multiplier pitch scaling
fn (sm &SoundManager) play_item_pickup(multiplier int) {
	sample_rate := 44100
	duration_ms := 140
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	base_freq := 440.0 * math.pow(1.15, f64(multiplier - 1))
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := base_freq + (t * 1200.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Goro hidden behind item surprise jingle
fn (sm &SoundManager) play_goro_reveal() {
	sample_rate := 44100
	duration_ms := 250
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	notes := [523.25, 659.25, 783.99, 1046.50]
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		note_idx := int(t * 16.0) % notes.len
		freq := notes[note_idx]
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.45
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Balloon popped in bonus stage
fn (sm &SoundManager) play_balloon_pop() {
	sample_rate := 44100
	duration_ms := 110
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (rand.f64() * 2.0 - 1.0) * 0.5
		env := math.exp(-22.0 * t)
		freq := 1800.0 - (t * 6000.0)
		val := (math.sin(2.0 * math.pi * math.max(100.0, freq) * t) * 0.5 + noise) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Hurry up alarm
fn (sm &SoundManager) play_hurry_up() {
	sample_rate := 44100
	duration_ms := 300
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := if int(t * 12.0) % 2 == 0 { 880.0 } else { 659.25 }
		env := 1.0 - (f64(i) / f64(num_samples)) * 0.5
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.35
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Stage clear fanfare
fn (sm &SoundManager) play_stage_clear() {
	sample_rate := 44100
	duration_ms := 600
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	notes := [523.25, 587.33, 659.25, 783.99, 880.0, 1046.50]
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		note_idx := math.min(int(t * 10.0), notes.len - 1)
		freq := notes[note_idx]
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Death sound
fn (sm &SoundManager) play_death() {
	sample_rate := 44100
	duration_ms := 450
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 600.0 - (t * 1000.0)
		env := math.exp(-4.5 * t)
		noise := (rand.f64() * 2.0 - 1.0) * 0.15
		val := (math.sin(2.0 * math.pi * math.max(40.0, freq) * t) * 0.7 + noise) * env * 0.5
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Perfect clear in bonus stage
fn (sm &SoundManager) play_bonus_perfect() {
	sample_rate := 44100
	duration_ms := 700
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98]
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		note_idx := math.min(int(t * 8.5), notes.len - 1)
		freq := notes[note_idx]
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.45
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

// Gosenzo coin spawn / approach warning
fn (sm &SoundManager) play_gosenzo_appear() {
	sample_rate := 44100
	duration_ms := 400
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 90.0 + math.sin(t * 30.0) * 40.0
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.6
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}
