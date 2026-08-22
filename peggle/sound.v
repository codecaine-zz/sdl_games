module main

import math
import rand
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

pub fn (mut sm SoundManager) toggle_sound() bool {
	sm.enabled = !sm.enabled
	if !sm.enabled && sm.dev_id != 0 {
		sdl.clear_queued_audio(sm.dev_id)
	}
	return sm.enabled
}

fn (mut sm SoundManager) play_samples(samples []i16) {
	if !sm.enabled || sm.dev_id == 0 || samples.len == 0 {
		return
	}
	queued := sdl.get_queued_audio_size(sm.dev_id)
	if queued > u32(audio_sample_rate * int(sizeof(i16)) / 3) {
		return
	}
	sdl.queue_audio(sm.dev_id, samples.data, u32(samples.len * int(sizeof(i16))))
}

// Cannon Shot Pop
pub fn (mut sm SoundManager) play_cannon() {
	dur := 0.12
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		env := math.exp(-t * 30.0)
		freq := 320.0 * math.exp(-t * 20.0)
		s := math.sin(2.0 * math.pi * freq * t)
		noise := (rand.f64() * 2.0 - 1.0) * 0.3
		val := i16((s + noise) * env * 18000.0)
		samples << val
	}
	sm.play_samples(samples)
}

// Peg Bounce Ding (Ascending Pentatonic Scale)
pub fn (mut sm SoundManager) play_peg_ding(combo int) {
	scale := [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50, 1174.66, 1318.51]
	freq := scale[combo % scale.len]

	dur := 0.15
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		env := math.exp(-t * 18.0)
		s := math.sin(2.0 * math.pi * freq * t)
		val := i16(s * env * 15000.0)
		samples << val
	}
	sm.play_samples(samples)
}

// Bucket Catch Free Ball
pub fn (mut sm SoundManager) play_bucket_catch() {
	dur := 0.3
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	notes := [659.25, 880.00, 1318.51]

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		n_idx := int(t / (dur / 3.0))
		freq := if n_idx < notes.len { notes[n_idx] } else { notes.last() }
		local_t := math.fmod(t, dur / 3.0)
		env := math.exp(-local_t * 15.0)
		s := math.sin(2.0 * math.pi * freq * t)
		val := i16(s * env * 15000.0)
		samples << val
	}
	sm.play_samples(samples)
}

// EXTREME FEVER Ode to Joy Celebration!
pub fn (mut sm SoundManager) play_fever() {
	dur := 0.85
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	// Ode to Joy opening notes: E5, E5, F5, G5, G5, F5, E5, D5
	notes := [659.25, 659.25, 698.46, 783.99, 783.99, 698.46, 659.25, 587.33]

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		n_idx := int(t / (dur / 8.0))
		freq := if n_idx < notes.len { notes[n_idx] } else { notes.last() }
		local_t := math.fmod(t, dur / 8.0)
		env := math.exp(-local_t * 12.0)
		s1 := math.sin(2.0 * math.pi * freq * t)
		s2 := math.sin(2.0 * math.pi * (freq * 2.0) * t) * 0.3
		val := i16((s1 + s2) * env * 16000.0)
		samples << val
	}
	sm.play_samples(samples)
}
