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

fn (sm &SoundManager) play_laser() {
	sample_rate := 44100
	duration_ms := 80
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 900.0 - (t * 8000.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * math.max(100.0, freq) * t) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_spread() {
	sample_rate := 44100
	duration_ms := 100
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 400.0 - (t * 2000.0)
		noise := (rand.f64() * 2.0 - 1.0) * 0.3
		env := 1.0 - (f64(i) / f64(num_samples))
		val := (math.sin(2.0 * math.pi * math.max(80.0, freq) * t) * 0.5 + noise) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_plasma() {
	sample_rate := 44100
	duration_ms := 140
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1200.0 + math.sin(t * 120.0) * 400.0
		env := math.exp(-12.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.5
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_missile() {
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 300.0 + (t * 2500.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.45
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_flame() {
	sample_rate := 44100
	duration_ms := 70
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		noise := (rand.f64() * 2.0 - 1.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := noise * env * 0.25
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_grenade() {
	sample_rate := 44100
	duration_ms := 180
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 250.0 - (t * 800.0)
		noise := (rand.f64() * 2.0 - 1.0) * 0.4
		env := math.exp(-8.0 * t)
		val := (math.sin(2.0 * math.pi * math.max(40.0, freq) * t) * 0.6 + noise) * env * 0.5
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_hyper_laser() {
	sample_rate := 44100
	duration_ms := 120
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1600.0 + math.sin(t * 300.0) * 600.0
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_tesla() {
	sample_rate := 44100
	duration_ms := 100
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 800.0 + (rand.f64() * 1200.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.35
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_explosion() {
	sample_rate := 44100
	duration_ms := 250
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (rand.f64() * 2.0 - 1.0)
		low_freq := math.sin(2.0 * math.pi * 60.0 * t)
		env := math.exp(-10.0 * t)
		val := (noise * 0.7 + low_freq * 0.3) * env * 0.5
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_powerup() {
	sample_rate := 44100
	duration_ms := 200
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 440.0 + (t * 2400.0)
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.4
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_emp_bomb() {
	sample_rate := 44100
	duration_ms := 500
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1500.0 - (t * 2600.0)
		noise := (rand.f64() * 2.0 - 1.0) * 0.3
		env := math.exp(-5.0 * t)
		val := (math.sin(2.0 * math.pi * math.max(30.0, freq) * t) + noise) * env * 0.6
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}

fn (sm &SoundManager) play_boss_siren() {
	sample_rate := 44100
	duration_ms := 400
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 400.0 + math.sin(t * 40.0) * 300.0
		env := 1.0 - (f64(i) / f64(num_samples))
		val := math.sin(2.0 * math.pi * freq * t) * env * 0.45
		pcm[i] = i16(val * 32767.0)
	}
	sm.play_sound_raw(pcm)
}
