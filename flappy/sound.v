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

pub fn (mut sm SoundManager) play_flap_sound() {
	count := int(audio_sample_rate * 0.06)
	mut samples := []i16{cap: count}
	attack_samples := int(audio_sample_rate * 0.002)

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		freq := 340.0 + 450.0 * (t / 0.06)
		env := math.exp(-32.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		val := i16(harm * env * attack * 19000.0)
		samples << val
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_point_sound() {
	notes := [987.77, 1318.51] // B5 -> E6 sparkling coin chime
	note_dur := 0.07
	count := int(audio_sample_rate * note_dur * f64(notes.len))
	mut samples := []i16{cap: count}
	attack_samples := int(audio_sample_rate * 0.002)

	for n_idx, freq in notes {
		sub_count := int(audio_sample_rate * note_dur)
		for i in 0 .. sub_count {
			t := f64(i) / f64(audio_sample_rate)
			decay := if n_idx == 1 { -8.0 } else { -12.0 }
			env := math.exp(decay * t)
			attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
			harm := math.sin(2.0 * math.pi * freq * t) + 0.35 * math.sin(4.0 * math.pi * freq * t)
			val := i16(harm * env * attack * 22000.0)
			samples << val
		}
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_hit_sound() {
	count := int(audio_sample_rate * 0.1)
	mut samples := []i16{cap: count}
	attack_samples := int(audio_sample_rate * 0.002)

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		freq := 220.0 - 140.0 * (t / 0.1)
		env := math.exp(-25.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.5 * math.sin(4.0 * math.pi * freq * t)
		val := i16(harm * env * attack * 24000.0)
		samples << val
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_die_sound() {
	count := int(audio_sample_rate * 0.22)
	mut samples := []i16{cap: count}
	attack_samples := int(audio_sample_rate * 0.002)

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		freq := 450.0 - 360.0 * (t / 0.22)
		env := math.exp(-10.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(2.0 * math.pi * 10.0 * t)
		val := i16(harm * env * attack * 22000.0)
		samples << val
	}
	sm.play_samples(samples)
}
