module main

import math
import sdl

// Pre-generated sound buffers (generated once at startup)
struct SoundBuffers {
mut:
	waka_a      []i16
	waka_b      []i16
	power_pellet []i16
	eat_ghost   []i16
	eat_fruit   []i16
	death       []i16
	extra_life  []i16
}

struct SoundManager {
mut:
	dev           sdl.AudioDeviceID
	sound_enabled bool = true
	waka_phase    bool
	buffers       SoundBuffers
}

fn gen_waka(phase bool) []i16 {
	sample_rate := 44100
	duration_ms := 65
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	base_freq := if phase { 460.0 } else { 620.0 }
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := base_freq + (80.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-22.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_power_pellet() []i16 {
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 300.0 + math.sin(2.0 * math.pi * 15.0 * t) * 120.0
		env := math.exp(-6.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 20000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_eat_ghost() []i16 {
	sample_rate := 44100
	duration_ms := 180
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 600.0 + (900.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-12.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 25000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_eat_fruit() []i16 {
	sample_rate := 44100
	duration_ms := 160
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	half := num_samples / 2
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := if i < half { 523.25 } else { 783.99 }
		env := math.exp(-20.0 * (t - (if i < half { 0.0 } else { f64(half) / f64(sample_rate) })))
		val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_death() []i16 {
	sample_rate := 44100
	duration_ms := 450
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 500.0 - (420.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-4.5 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 24000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_extra_life() []i16 {
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50]
	note_dur := 90
	total_dur := notes.len * note_dur
	num_samples := (sample_rate * total_dur) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		for i in 0 .. samples_per_note {
			sample_idx := start_sample + i
			if sample_idx >= num_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			env := math.exp(-14.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
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

fn (sm &SoundManager) play_waka_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	mut mutable_sm := unsafe { &SoundManager(sm) }
	mutable_sm.waka_phase = !mutable_sm.waka_phase
	pcm := gen_waka(mutable_sm.waka_phase)
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_power_pellet_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_power_pellet()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_eat_ghost_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_eat_ghost()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_eat_fruit_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_eat_fruit()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_death_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_death()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_extra_life_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_extra_life()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) cleanup() {
	if sm.dev != 0 {
		sdl.close_audio_device(sm.dev)
	}
}
