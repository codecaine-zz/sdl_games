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

// Mouse Step Click
pub fn (mut sm SoundManager) play_step() {
	dur := 0.03
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		env := math.exp(-t * 90.0)
		s := math.sin(2.0 * math.pi * 650.0 * t)
		val := i16(s * env * 11000.0)
		samples << val
	}
	sm.play_samples(samples)
}

// Block Push Thud
pub fn (mut sm SoundManager) play_push() {
	dur := 0.06
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		env := math.exp(-t * 40.0)
		s := math.sin(2.0 * math.pi * 180.0 * t)
		val := i16(s * env * 14000.0)
		samples << val
	}
	sm.play_samples(samples)
}

// Cat Transformed into Cheese!
pub fn (mut sm SoundManager) play_cheese_spawn() {
	dur := 0.22
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	notes := [523.25, 659.25, 783.99]

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		n_idx := int(t / (dur / 3.0))
		freq := if n_idx < notes.len { notes[n_idx] } else { notes.last() }
		local_t := math.fmod(t, dur / 3.0)
		env := math.exp(-local_t * 18.0)
		s := math.sin(2.0 * math.pi * freq * t)
		val := i16(s * env * 14000.0)
		samples << val
	}
	sm.play_samples(samples)
}

// Eating Cheese Crunch
pub fn (mut sm SoundManager) play_eat() {
	dur := 0.12
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		env := math.exp(-t * 25.0)
		s := math.sin(2.0 * math.pi * 880.0 * t)
		noise := (rand.f64() * 2.0 - 1.0) * 0.4
		val := i16((s + noise) * env * 15000.0)
		samples << val
	}
	sm.play_samples(samples)
}

// Mouse Caught Squeak
pub fn (mut sm SoundManager) play_die() {
	dur := 0.25
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		freq := 1200.0 * math.exp(-t * 10.0)
		env := math.exp(-t * 12.0)
		s := math.sin(2.0 * math.pi * freq * t)
		val := i16(s * env * 16000.0)
		samples << val
	}
	sm.play_samples(samples)
}
