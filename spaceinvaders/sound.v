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

fn (sm &SoundManager) play_pcm(pcm []i16) {
	if !sm.sound_enabled || sm.dev == 0 || pcm.len == 0 {
		return
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_march_beat(note_idx int) {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 60
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	base_freqs := [175.0, 164.0, 155.0, 146.0] // 4-tone descending bass
	freq := base_freqs[note_idx % 4]

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		env := math.exp(-32.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		// Square/triangle chiptune bass
		phase := math.fmod(t * freq, 1.0)
		wave := if phase < 0.5 { 0.85 } else { -0.85 }
		harm := wave + 0.3 * math.sin(2.0 * math.pi * freq * t)
		sample := harm * env * attack * 16000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_player_laser() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 110
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1700.0 - (1400.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-16.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		sample := harm * env * attack * 18000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_alien_explosion() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (f64(rand.intn(2000) or { 1000 }) / 1000.0) - 1.0
		sub := math.sin(2.0 * math.pi * (160.0 - 120.0 * (f64(i) / f64(num_samples))) * t)
		env := math.exp(-18.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		sample := (noise * 0.7 + sub * 0.3) * env * attack * 22000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_player_explosion() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 550
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (f64(rand.intn(2000) or { 1000 }) / 1000.0) - 1.0
		sub_freq := 110.0 - (80.0 * (f64(i) / f64(num_samples)))
		sub := math.sin(2.0 * math.pi * sub_freq * t)
		env := math.exp(-5.5 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		sample := (noise * 0.7 + sub * 0.3) * env * attack * 24000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_ufo_siren() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 80
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 4 / 1000
	release_samples := sample_rate * 4 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 480.0 + 160.0 * math.sin(t * 40.0)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		release := if i > num_samples - release_samples { f64(num_samples - i) / f64(release_samples) } else { 1.0 }
		sample := math.sin(2.0 * math.pi * freq * t) * attack * release * 12000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_ufo_bonus() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 300
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 880.0 + (600.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-10.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		sample := (math.sin(2.0 * math.pi * freq * t) + 0.4 * math.sin(4.0 * math.pi * freq * t)) * env * attack * 18000.0
		pcm[i] = i16(sample)
	}
	sm.play_pcm(pcm)
}
