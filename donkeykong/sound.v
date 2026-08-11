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

fn (sm &SoundManager) play_jump_sound() {
	if !sm.sound_enabled || sm.dev == 0 { return }
	sample_rate := 44100
	duration_ms := 80
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 300.0 + 500.0 * (f64(i) / f64(num_samples))
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		pcm[i] = i16(sq * 12000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_hammer_smash_sound() {
	if !sm.sound_enabled || sm.dev == 0 { return }
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (f64(rand.intn(2000) or { 1000 }) / 1000.0) - 1.0
		sq := if math.sin(2.0 * math.pi * 500.0 * t) > 0.0 { 1.0 } else { -1.0 }
		env := math.exp(-12.0 * t)
		pcm[i] = i16((noise * 0.5 + sq * 0.5) * env * 16000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_victory_sound() {
	if !sm.sound_enabled || sm.dev == 0 { return }
	sample_rate := 44100
	duration_ms := 400
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		note := int(t * 10.0)
		freq := 400.0 + f64(note) * 100.0
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		pcm[i] = i16(sq * 14000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}
