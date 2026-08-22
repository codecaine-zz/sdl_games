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
	mut sm := SoundManager{
		enabled: true
	}
	sm.init()
	return sm
}

pub fn (mut sm SoundManager) init() {
	if sm.dev_id != 0 {
		return
	}
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
}

pub fn (mut sm SoundManager) toggle_sound() bool {
	sm.enabled = !sm.enabled
	if !sm.enabled && sm.dev_id != 0 {
		sdl.clear_queued_audio(sm.dev_id)
	}
	return sm.enabled
}

fn (mut sm SoundManager) play_samples(samples []i16) {
	if !sm.enabled || samples.len == 0 {
		return
	}
	if sm.dev_id == 0 {
		sm.init()
		if sm.dev_id == 0 {
			return
		}
	}
	queued := sdl.get_queued_audio_size(sm.dev_id)
	if queued > u32(audio_sample_rate * int(sizeof(i16)) / 4) {
		return
	}
	sdl.queue_audio(sm.dev_id, samples.data, u32(samples.len * int(sizeof(i16))))
}

// Solid sisal dartboard impact thud
pub fn (mut sm SoundManager) play_thud() {
	dur := 0.12
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		noise := (rand.f64() * 2.0 - 1.0) * math.exp(-35.0 * t) * 0.7
		tone := math.sin(2.0 * math.pi * 140.0 * t) * math.exp(-22.0 * t) * 0.8
		sample := (noise + tone) * 0.8
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// High crystalline chime for Double / Triple
pub fn (mut sm SoundManager) play_multiplier(mult int) {
	dur := 0.25
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	freq := if mult >= 3 { 1174.66 } else { 880.0 } // D6 for Triple, A5 for Double

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		decay := math.exp(-10.0 * t)
		sample := math.sin(2.0 * math.pi * freq * t) * decay * 0.7
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Dual harmonic resonant ring for Bullseye
pub fn (mut sm SoundManager) play_bullseye() {
	dur := 0.40
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	f1 := 1046.5 // C6
	f2 := 1318.5 // E6

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		decay := math.exp(-6.0 * t)
		sample := (math.sin(2.0 * math.pi * f1 * t) + math.sin(2.0 * math.pi * f2 * t)) * decay * 0.5
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Triumphant ascending brass fanfare chords (180 / Win)
pub fn (mut sm SoundManager) play_180_fanfare() {
	dur := 0.80
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		step := int(t * 8.0) % 4
		freq := match step {
			0 { 523.25 } // C5
			1 { 659.25 } // E5
			2 { 783.99 } // G5
			else { 1046.5 } // C6
		}
		decay := 1.0 - (t / dur) * 0.3
		sample := math.sin(2.0 * math.pi * freq * t) * decay * 0.6
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Low buzzer for Bust
pub fn (mut sm SoundManager) play_bust() {
	dur := 0.35
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		sq := if math.sin(2.0 * math.pi * 110.0 * t) > 0 { 0.4 } else { -0.4 }
		sample := sq * math.exp(-3.5 * t) * 0.8
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}
