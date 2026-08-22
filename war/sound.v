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

// Card flip slide swoosh
pub fn (mut sm SoundManager) play_card_flip() {
	dur := 0.08
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		noise := (rand.f64() * 2.0 - 1.0) * math.exp(-35.0 * t) * 0.5
		tone := math.sin(2.0 * math.pi * 320.0 * t) * math.exp(-30.0 * t) * 0.4
		sample := noise + tone
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Dramatic sword clash on WAR declaration!
pub fn (mut sm SoundManager) play_war_clash() {
	dur := 0.55
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		clash1 := math.sin(2.0 * math.pi * 1250.0 * t) * math.exp(-15.0 * t) * 0.5
		clash2 := math.sin(2.0 * math.pi * 2100.0 * t) * math.exp(-22.0 * t) * 0.4
		metal := (rand.f64() * 2.0 - 1.0) * math.exp(-25.0 * t) * 0.5
		sample := clash1 + clash2 + metal
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Round win point chime
pub fn (mut sm SoundManager) play_round_win() {
	dur := 0.20
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		sample := math.sin(2.0 * math.pi * 880.0 * t) * math.exp(-10.0 * t) * 0.5
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Match victory horn fanfare
pub fn (mut sm SoundManager) play_victory() {
	dur := 1.10
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		step := int(t * 6.0) % 3
		freq := match step {
			0 { 523.25 } // C5
			1 { 659.25 } // E5
			else { 783.99 } // G5
		}
		decay := 1.0 - (t / dur) * 0.3
		sample := math.sin(2.0 * math.pi * freq * t) * decay * 0.7
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}
