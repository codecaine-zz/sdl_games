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
	if sdl.init(sdl.init_audio) < 0 {
		eprintln('Failed to init SDL Audio')
		return SoundManager{
			dev:           0
			sound_enabled: false
		}
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

fn (sm &SoundManager) play_flap() {
	sample_rate := 44100
	duration_ms := 60
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 180.0 + (t * 1200.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.35
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_balloon_pop() {
	sample_rate := 44100
	duration_ms := 120
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 2400.0 - (t * 8000.0)
		noise := (rand.f64() * 2.0 - 1.0) * 0.3
		env := math.exp(-15.0 * t)
		val := (math.sin(2.0 * math.pi * math.max(100.0, freq) * t) * 0.6 + noise) * env * 0.5
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_splash() {
	sample_rate := 44100
	duration_ms := 200
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (rand.f64() * 2.0 - 1.0)
		env := math.exp(-8.0 * t)
		val := noise * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_fish_gulp() {
	sample_rate := 44100
	duration_ms := 300
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 120.0 + math.sin(t * 50.0) * 80.0
		noise := (rand.f64() * 2.0 - 1.0) * 0.4
		env := math.exp(-6.0 * t)
		val := (math.sin(2.0 * math.pi * freq * t) + noise) * env * 0.55
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_spark_zap() {
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 800.0 + (rand.f64() * 1600.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_pickup() {
	sample_rate := 44100
	duration_ms := 100
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 523.25 + (t * 2000.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_phase_clear() {
	sample_rate := 44100
	duration_ms := 400
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	notes := [261.63, 329.63, 392.00, 523.25]
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		note_idx := int(t * 10.0) % notes.len
		freq := notes[note_idx]
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.45
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}
