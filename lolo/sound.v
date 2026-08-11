module main

import math
import sdl

struct SoundManager {
mut:
	dev           sdl.AudioDeviceID
	sound_enabled bool = true
}

fn gen_step() []i16 {
	sample_rate := 44100
	duration_ms := 30
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 200.0 - (100.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-30.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 12000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_heart() []i16 {
	sample_rate := 44100
	notes := [587.33, 880.00] // D5 -> A5
	note_dur := 70
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
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
			env := math.exp(-16.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
}

fn gen_shot() []i16 {
	sample_rate := 44100
	duration_ms := 100
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 800.0 + (600.0 * math.sin(2.0 * math.pi * 20.0 * t))
		env := math.exp(-15.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_egg() []i16 {
	sample_rate := 44100
	duration_ms := 140
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 400.0 + (500.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-10.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 24000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_push() []i16 {
	sample_rate := 44100
	duration_ms := 90
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 110.0 - (40.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-18.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 25000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_laser() []i16 {
	sample_rate := 44100
	duration_ms := 300
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1200.0 - (900.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-5.0 * t)
		// Sawtooth-ish pulse wave for harsh Medusa laser
		phase := math.fmod(freq * t, 1.0)
		val := (if phase > 0.5 { 1.0 } else { -1.0 }) * env * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_chest() []i16 {
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50] // C5 E5 G5 C6
	note_dur := 80
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
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
			env := math.exp(-12.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 23000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
}

fn gen_victory() []i16 {
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51] // Fanfare
	note_dur := 100
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
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
			env := math.exp(-8.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 24000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
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

fn (sm &SoundManager) play_step() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_step()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_heart() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_heart()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_shot() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_shot()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_egg() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_egg()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_push() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_push()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_laser() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_laser()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_chest() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_chest()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_victory() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_victory()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) cleanup() {
	if sm.dev != 0 {
		sdl.close_audio_device(sm.dev)
	}
}
