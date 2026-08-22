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

fn (sm &SoundManager) play_pcm(pcm []i16) {
	if !sm.sound_enabled || sm.dev == 0 || pcm.len == 0 {
		return
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

// Rotation sound
fn (sm &SoundManager) play_rotate_sound() {
	sample_rate := 44100
	duration_ms := 35
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 480.0 + t * 3500.0
		env := 1.0 - (f64(i) / f64(num_samples))
		sample := math.sin(2.0 * math.pi * freq * t) * env * 11000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

// Move sound
fn (sm &SoundManager) play_move_sound() {
	sample_rate := 44100
	duration_ms := 25
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 380.0
		env := 1.0 - (f64(i) / f64(num_samples))
		sample := math.sin(2.0 * math.pi * freq * t) * env * 8000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

// Land / Lock sound
fn (sm &SoundManager) play_land_sound() {
	sample_rate := 44100
	duration_ms := 50
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 180.0 * (1.0 - t * 3.0)
		env := math.exp(-t * 30.0)
		sample := math.sin(2.0 * math.pi * freq * t) * env * 14000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

// Crash Orb detonation / Fighting impact hit
fn (sm &SoundManager) play_crash_sound(chain int) {
	sample_rate := 44100
	duration_ms := 220 + chain * 40
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	base_freq := 300.0 * math.pow(1.2, f64(chain - 1))

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		env := math.exp(-t * 12.0)
		s1 := math.sin(2.0 * math.pi * base_freq * t)
		s2 := (math.sin(2.0 * math.pi * (base_freq * 1.5) * t)) * 0.6
		noise := (f64(i % 17) / 8.5 - 1.0) * 0.4
		sample := (s1 + s2 + noise) * env * 18000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

// Garbage Counter Gem Drop
fn (sm &SoundManager) play_garbage_drop_sound() {
	sample_rate := 44100
	duration_ms := 140
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 160.0 + (t * 800.0)
		env := math.exp(-t * 15.0)
		sqr := if (int(t * freq * 2.0) % 2) == 0 { 1.0 } else { -1.0 }
		sample := sqr * env * 13000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

// Knockout / Round Win Bell
fn (sm &SoundManager) play_ko_sound() {
	sample_rate := 44100
	duration_ms := 600
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 880.0
		env := math.exp(-t * 5.0)
		s1 := math.sin(2.0 * math.pi * freq * t)
		s2 := math.sin(2.0 * math.pi * freq * 2.75 * t) * 0.4
		sample := (s1 + s2) * env * 17000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}
