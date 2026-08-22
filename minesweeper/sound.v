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

fn (sm &SoundManager) play_click_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 40
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 800.0 - (500.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-60.0 * t)
		sample := math.sin(2.0 * math.pi * freq * t) * env * 12000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_flag_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 70
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 523.25 + (350.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-35.0 * t)
		sample := math.sin(2.0 * math.pi * freq * t) * env * 14000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_unflag_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 60
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 650.0 - (300.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-40.0 * t)
		sample := math.sin(2.0 * math.pi * freq * t) * env * 12000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_cascade_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 180
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 300.0 + 800.0 * math.sin(t * 25.0)
		env := math.exp(-12.0 * t)
		sample := (math.sin(2.0 * math.pi * freq * t) * 0.7 + math.sin(4.0 * math.pi * freq * t) * 0.3) * env * 14000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_explode_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 550
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (f64(rand.intn(2000) or { 1000 }) / 1000.0) - 1.0
		sub_freq := 120.0 - (90.0 * (f64(i) / f64(num_samples)))
		sub := math.sin(2.0 * math.pi * sub_freq * t)
		env := math.exp(-6.5 * t)
		sample := (noise * 0.65 + sub * 0.35) * env * 22000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_win_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 800
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	notes := [523.25, 659.25, 783.99, 1046.50] // C5, E5, G5, C6
	note_len := num_samples / 4

	for i in 0 .. num_samples {
		note_idx := i / note_len
		freq := notes[if note_idx < 4 { note_idx } else { 3 }]
		local_i := i % note_len
		t := f64(local_i) / f64(sample_rate)
		global_t := f64(i) / f64(sample_rate)
		env := math.exp(-8.0 * t) * (1.0 - global_t * 0.4)
		harm := math.sin(2.0 * math.pi * freq * global_t) + 0.4 * math.sin(4.0 * math.pi * freq * global_t)
		sample := harm * env * 15000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}
