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

// Low wood lane rumble as heavy bowling ball rolls down lane
pub fn (mut sm SoundManager) play_roll_sound(power f64) {
	dur := 1.2
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	vol := math.clamp(0.4 + power * 0.5, 0.2, 1.0)

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		noise := (rand.f64() * 2.0 - 1.0) * 0.4
		rumble := math.sin(2.0 * math.pi * 65.0 * t) * 0.6
		sample := (noise + rumble) * vol * math.min(1.0, t * 4.0) * math.max(0.0, 1.0 - t / dur)
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Explosive maple wood pin-pin and ball-pin crash
pub fn (mut sm SoundManager) play_pin_hit(intensity f64) {
	dur := 0.22
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	vol := math.clamp(0.4 + intensity * 0.6, 0.2, 1.0)

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		noise := (rand.f64() * 2.0 - 1.0) * math.exp(-35.0 * t) * 0.7
		tone1 := math.sin(2.0 * math.pi * 950.0 * t) * math.exp(-40.0 * t) * 0.5
		tone2 := math.sin(2.0 * math.pi * 1450.0 * t) * math.exp(-45.0 * t) * 0.4
		sample := (noise + tone1 + tone2) * vol
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Ascending fanfare chord for Strike
pub fn (mut sm SoundManager) play_strike_fanfare() {
	dur := 0.90
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

// Dual chord for Spare
pub fn (mut sm SoundManager) play_spare_fanfare() {
	dur := 0.60
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		f1 := 659.25 // E5
		f2 := 880.0  // A5
		decay := math.exp(-4.0 * t)
		sample := (math.sin(2.0 * math.pi * f1 * t) + math.sin(2.0 * math.pi * f2 * t)) * decay * 0.4
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Gutter ball clunk
pub fn (mut sm SoundManager) play_gutter_sound() {
	dur := 0.35
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		freq := math.max(60.0, 180.0 - t * 240.0)
		sample := math.sin(2.0 * math.pi * freq * t) * math.exp(-5.0 * t) * 0.6
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}
