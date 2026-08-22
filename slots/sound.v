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

// Mechanical one-armed bandit lever ratchet pull
pub fn (mut sm SoundManager) play_lever_pull() {
	dur := 0.20
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		// Click ratchet ticks
		tick_pulse := if int(t * 70.0) % 2 == 0 { 0.5 } else { -0.5 }
		spring := math.sin(2.0 * math.pi * 320.0 * t) * math.exp(-15.0 * t)
		sample := (tick_pulse * 0.4 + spring * 0.6) * 0.7
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Reel whirr sound during spinning
pub fn (mut sm SoundManager) play_reel_spin() {
	dur := 0.14
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		noise := (rand.f64() * 2.0 - 1.0) * 0.3
		hum := math.sin(2.0 * math.pi * 180.0 * t) * 0.5
		sample := (noise + hum) * 0.35
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Solid mechanical solenoid reel lock/click stop
pub fn (mut sm SoundManager) play_reel_stop(reel_idx int) {
	dur := 0.08
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}
	pitch := 380.0 + f64(reel_idx) * 60.0

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		tone := math.sin(2.0 * math.pi * pitch * t) * math.exp(-45.0 * t)
		click := (rand.f64() * 2.0 - 1.0) * math.exp(-60.0 * t) * 0.7
		sample := (tone * 0.6 + click * 0.5) * 0.8
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Metallic coins clinking cascade
pub fn (mut sm SoundManager) play_coin_payout() {
	dur := 0.30
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		step := int(t * 22.0)
		f := 2000.0 + f64((step * 347) % 1800)
		ping := math.sin(2.0 * math.pi * f * t) * math.exp(-math.fmod(t * 22.0, 1.0) * 20.0)
		sample := ping * 0.6
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Winning payline chord chime
pub fn (mut sm SoundManager) play_win_chime() {
	dur := 0.45
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		step := int(t * 10.0) % 3
		freq := match step {
			0 { 659.25 } // E5
			1 { 830.61 } // G#5
			else { 987.77 } // B5
		}
		decay := math.exp(-5.0 * t)
		sample := math.sin(2.0 * math.pi * freq * t) * decay * 0.65
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}

// Mega Jackpot / Free Spins Fanfare
pub fn (mut sm SoundManager) play_jackpot_fanfare() {
	dur := 1.20
	count := int(audio_sample_rate * dur)
	mut samples := []i16{cap: count}

	for i := 0; i < count; i++ {
		t := f64(i) / f64(audio_sample_rate)
		step := int(t * 7.0) % 5
		freq := match step {
			0 { 523.25 } // C5
			1 { 659.25 } // E5
			2 { 783.99 } // G5
			3 { 1046.50 } // C6
			else { 1318.51 } // E6
		}
		decay := 1.0 - (t / dur) * 0.3
		sample := math.sin(2.0 * math.pi * freq * t) * decay * 0.75
		samples << i16(sample * 16000.0)
	}
	sm.play_samples(samples)
}
