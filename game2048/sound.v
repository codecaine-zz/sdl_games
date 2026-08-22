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

fn (sm &SoundManager) play_slide_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 45
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 400.0 - (250.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-45.0 * t)
		sample := math.sin(2.0 * math.pi * freq * t) * env * 9000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_merge_sound(val int) {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 110
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	// Pentatonic scale based on tile power of 2
	mut power := 0
	mut temp := val
	for temp > 2 {
		temp /= 2
		power++
	}

	scale_notes := [
		261.63, // 4: C4
		293.66, // 8: D4
		329.63, // 16: E4
		392.00, // 32: G4
		440.00, // 64: A4
		523.25, // 128: C5
		587.33, // 256: D5
		659.25, // 512: E5
		783.99, // 1024: G5
		1046.50, // 2048: C6
		1174.66, // 4096: D6
		1318.51, // 8192: E6
	]
	idx := if power < scale_notes.len { power } else { scale_notes.len - 1 }
	freq := scale_notes[idx]

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		env := math.exp(-22.0 * t)
		harmonic := math.sin(2.0 * math.pi * freq * t) + 0.35 * math.sin(4.0 * math.pi * freq * t)
		sample := harmonic * env * 14000.0
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

	notes := [523.25, 659.25, 783.99, 1046.50]
	note_len := num_samples / 4

	for i in 0 .. num_samples {
		note_idx := i / note_len
		freq := notes[if note_idx < 4 { note_idx } else { 3 }]
		local_i := i % note_len
		t := f64(local_i) / f64(sample_rate)
		env := math.exp(-8.0 * t)
		sample := (math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)) * env * 16000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_game_over_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 500
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	notes := [330.0, 311.13, 293.66, 261.63]
	note_len := num_samples / 4

	for i in 0 .. num_samples {
		note_idx := i / note_len
		freq := notes[if note_idx < 4 { note_idx } else { 3 }]
		local_i := i % note_len
		t := f64(local_i) / f64(sample_rate)
		env := math.exp(-10.0 * t)
		sample := math.sin(2.0 * math.pi * freq * t) * env * 12000.0
		pcm[i] = i16(sample)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}
