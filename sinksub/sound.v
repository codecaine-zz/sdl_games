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

fn (sm &SoundManager) play_sonar_ping() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 600
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		// Main Ping 1046Hz with exponential decay
		ping := math.sin(2.0 * math.pi * 1046.50 * t) * math.exp(-6.0 * t)
		// Echo tail at 523Hz starting at t > 0.15s
		echo_t := math.max(0.0, t - 0.15)
		echo := if t > 0.15 {
			math.sin(2.0 * math.pi * 523.25 * echo_t) * math.exp(-8.0 * echo_t) * 0.4
		} else {
			0.0
		}
		val := (ping + echo) * 22000.0
		pcm[i] = i16(math.max(-32767.0, math.min(32767.0, val)))
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_splash() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 200
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		// White noise burst mixed with downward pitch sweep
		noise := (rand.f64() * 2.0 - 1.0) * math.exp(-12.0 * t)
		sweep := math.sin(2.0 * math.pi * (300.0 - 180.0 * (f64(i) / f64(num_samples))) * t) * math.exp(-15.0 * t)
		val := (noise * 0.6 + sweep * 0.4) * 20000.0
		pcm[i] = i16(math.max(-32767.0, math.min(32767.0, val)))
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_launch() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 140
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		// Upward pitch whiz + thud
		freq := 120.0 + (450.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-18.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
		pcm[i] = i16(val)
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_explosion(is_deep bool) {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := if is_deep { 500 } else { 300 }
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		// Sub-bass rumble + noisy cavitation crackle
		freq := math.max(15.0, (if is_deep { 90.0 } else { 180.0 }) - (70.0 * (f64(i) / f64(num_samples))))
		rumble := math.sin(2.0 * math.pi * freq * t)
		noise := (rand.f64() * 2.0 - 1.0)
		env := math.exp((if is_deep { -6.0 } else { -12.0 }) * t)
		val := (rumble * 0.7 + noise * 0.3) * env * 28000.0
		pcm[i] = i16(math.max(-32767.0, math.min(32767.0, val)))
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_powerup() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [440.0, 554.37, 659.25, 880.0, 1108.73]
	note_dur := 55
	total_samples := (sample_rate * note_dur * notes.len) / 1000
	mut pcm := []i16{len: total_samples}

	for n_idx, freq in notes {
		start := (sample_rate * note_dur * n_idx) / 1000
		n_samples := (sample_rate * note_dur) / 1000
		for i in 0 .. n_samples {
			t := f64(i) / f64(sample_rate)
			env := math.exp(-12.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 20000.0
			pcm[start + i] = i16(val)
		}
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(total_samples * 2))
}

fn (sm &SoundManager) play_nuke() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 800
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		// Multi-layered pitch sweep + heavy rumble shockwave
		freq := math.max(20.0, 1200.0 - (1150.0 * math.pow(f64(i) / f64(num_samples),
			0.5)))
		noise := (rand.f64() * 2.0 - 1.0) * 0.4
		env := math.exp(-3.5 * t)
		val := (math.sin(2.0 * math.pi * freq * t) + noise) * env * 30000.0
		pcm[i] = i16(math.max(-32767.0, math.min(32767.0, val)))
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_rank_up() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [261.63, 329.63, 392.00, 523.25, 659.25, 783.99]
	note_dur := 75
	total_samples := (sample_rate * note_dur * notes.len) / 1000
	mut pcm := []i16{len: total_samples}

	for n_idx, freq in notes {
		start := (sample_rate * note_dur * n_idx) / 1000
		n_samples := (sample_rate * note_dur) / 1000
		for i in 0 .. n_samples {
			t := f64(i) / f64(sample_rate)
			env := math.exp(-10.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 24000.0
			pcm[start + i] = i16(val)
		}
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(total_samples * 2))
}

fn (sm &SoundManager) play_torpedo_warning() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 80
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		val := math.sin(2.0 * math.pi * 880.0 * t) * math.exp(-20.0 * t) * 16000.0
		pcm[i] = i16(val)
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) play_click_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 30
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 700.0
		env := math.exp(-50.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 14000.0
		pcm[i] = i16(val)
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

fn (sm &SoundManager) cleanup() {
	if sm.dev != 0 {
		sdl.close_audio_device(sm.dev)
	}
}
