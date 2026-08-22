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

pub fn (mut sm SoundManager) play_rotate_sound() {
	count := int(audio_sample_rate * 0.04)
	mut samples := []i16{cap: count}
	attack_samples := int(audio_sample_rate * 0.002)

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		freq := 450.0 + 350.0 * (t / 0.04)
		env := math.exp(-35.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		val := i16(harm * env * attack * 15000.0)
		samples << val
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_drop_sound() {
	count := int(audio_sample_rate * 0.065)
	mut samples := []i16{cap: count}
	attack_samples := int(audio_sample_rate * 0.002)

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		freq := 240.0 - 160.0 * (t / 0.065)
		env := math.exp(-28.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.4 * math.sin(math.pi * freq * t)
		val := i16(harm * env * attack * 22000.0)
		samples << val
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_chain_pop_sound(chain_level int) {
	// Ascending pentatonic chord fanfare based on chain multiplier
	base_freqs := [440.0, 523.25, 659.25, 783.99, 880.0, 1046.50, 1318.51]
	idx := int(math.clamp(f64(chain_level - 1), 0.0, f64(base_freqs.len - 1)))
	freq := base_freqs[idx]

	dur := 0.16 + f64(chain_level) * 0.03
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	attack_samples := int(audio_sample_rate * 0.002)

	for i in 0 .. count {
		t := f64(i) / f64(audio_sample_rate)
		env := math.exp(-12.0 * t / dur)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) * 0.7 + math.sin(4.0 * math.pi * freq * t) * 0.35 + math.sin(6.0 * math.pi * freq * t) * 0.15
		val := i16(harm * env * attack * 22000.0)
		samples << val
	}
	sm.play_samples(samples)
}

pub fn (mut sm SoundManager) play_game_over_sound() {
	notes := [440.0, 370.0, 311.13, 261.63]
	note_dur := 0.12
	count := int(audio_sample_rate * note_dur * f64(notes.len))
	mut samples := []i16{cap: count}
	attack_samples := int(audio_sample_rate * 0.002)

	for freq in notes {
		sub_count := int(audio_sample_rate * note_dur)
		for i in 0 .. sub_count {
			t := f64(i) / f64(audio_sample_rate)
			env := math.exp(-8.0 * t)
			attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
			val := i16(math.sin(2.0 * math.pi * freq * t) * env * attack * 18000.0)
			samples << val
		}
	}
	sm.play_samples(samples)
}
