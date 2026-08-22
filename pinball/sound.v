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

fn (sm &SoundManager) play_flick() {
	sample_rate := 44100
	duration_ms := 40
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 400.0 + (t * 8000.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_bumper() {
	sample_rate := 44100
	duration_ms := 90
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 880.0 - (t * 4000.0)
		env := math.exp(-25.0 * t)
		val := math.sin(2.0 * math.pi * math.max(120.0, freq) * t) * env * 0.6
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_slingshot() {
	sample_rate := 44100
	duration_ms := 60
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 600.0 + (t * 2400.0)
		noise := (rand.f64() * 2.0 - 1.0) * 0.2
		env := math.exp(-20.0 * t)
		val := (math.sin(2.0 * math.pi * freq * t) * 0.8 + noise) * env * 0.5
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_target() {
	sample_rate := 44100
	duration_ms := 100
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1200.0 + (t * 1800.0)
		env := math.exp(-15.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.45
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_spinner() {
	sample_rate := 44100
	duration_ms := 30
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1800.0
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.3
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_mario_bounce() {
	sample_rate := 44100
	duration_ms := 120
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 300.0 + (t * 3000.0)
		env := math.exp(-12.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.55
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_damsel_rescue() {
	sample_rate := 44100
	duration_ms := 400
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	notes := [523.25, 659.25, 783.99, 1046.50] // C5, E5, G5, C6
	note_len := num_samples / notes.len
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		note_idx := math.min(i / note_len, notes.len - 1)
		freq := notes[note_idx]
		env := 1.0 - (f64(i % note_len) / f64(note_len))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.5
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_drain() {
	sample_rate := 44100
	duration_ms := 300
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 600.0 - (t * 1500.0)
		env := math.exp(-6.0 * t)
		val := math.sin(2.0 * math.pi * math.max(60.0, freq) * t) * env * 0.5
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_plunger_release() {
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 150.0 + (t * 2200.0)
		env := math.exp(-10.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.6
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_tilt() {
	sample_rate := 44100
	duration_ms := 250
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 180.0
		val := if math.sin(2.0 * math.pi * freq * t) > 0 { 0.4 } else { -0.4 }
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}
