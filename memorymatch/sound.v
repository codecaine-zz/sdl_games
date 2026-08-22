module main

import math
import sdl

const audio_sample_rate = 44100

pub struct SoundManager {
pub mut:
	dev_id  u32
	enabled bool = true
}

pub fn new_sound_manager() SoundManager {
	mut sm := SoundManager{}
	if sdl.was_init(sdl.init_audio) == 0 {
		sdl.init_sub_system(sdl.init_audio)
	}
	spec := sdl.AudioSpec{
		freq:     audio_sample_rate
		format:   sdl.AudioFormat(sdl.audio_s16sys)
		channels: 1
		samples:  1024
		callback: unsafe { nil }
	}
	obtained := sdl.AudioSpec{}
	dev := sdl.open_audio_device(unsafe { nil }, 0, &spec, &obtained, 0)
	if dev > 0 {
		sm.dev_id = dev
		sdl.pause_audio_device(dev, 0)
	}
	return sm
}

pub fn (mut sm SoundManager) toggle_sound() {
	sm.enabled = !sm.enabled
}

fn (mut sm SoundManager) play_samples(samples []i16) {
	if !sm.enabled || sm.dev_id == 0 || samples.len == 0 {
		return
	}
	sdl.queue_audio(sm.dev_id, samples.data, u32(samples.len * int(sizeof(i16))))
}

pub fn (mut sm SoundManager) play_flip_sound() {
	dur := 0.08
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		freq := 400.0 + 600.0 * (t / dur)
		env := 1.0 - (t / dur)
		val := i16(math.sin(2.0 * math.pi * freq * t) * env * 14000.0)
		samples << val
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_match_sound(combo int) {
	base_freq := 523.25 * math.pow(1.05946, f64(combo * 2)) // Ascending pitch by combo
	dur := 0.22
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		env := math.exp(-6.0 * (t / dur))
		val := i16((math.sin(2.0 * math.pi * base_freq * t) * 0.7 + math.sin(2.0 * math.pi * base_freq * 1.5 * t) * 0.3) * env * 18000.0)
		samples << val
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_mismatch_sound() {
	dur := 0.15
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		freq := 180.0 - 60.0 * (t / dur)
		env := 1.0 - (t / dur)
		val := i16(math.sin(2.0 * math.pi * freq * t) * env * 15000.0)
		samples << val
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_win_fanfare() {
	notes := [523.25, 659.25, 783.99, 1046.5, 1318.5]
	dur := 0.12
	count := int(audio_sample_rate * dur * f64(notes.len))
	mut samples := []i16{cap: count}

	for _, freq in notes {
		n_count := int(audio_sample_rate * dur)
		for i in 0 .. n_count {
			t := f64(i) / f64(audio_sample_rate)
			env := 1.0 - (t / dur) * 0.3
			val := i16(math.sin(2.0 * math.pi * freq * t) * env * 16000.0)
			samples << val
		}
	}
	sm.play_samples(samples)
}
