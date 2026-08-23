module main

import math
import sdl

pub struct SoundManager {
pub mut:
	dev           sdl.AudioDeviceID
	sound_enabled bool = true
	bgm_step      int
	bgm_phase     f64
}

pub fn new_sound_manager() SoundManager {
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

pub fn (sm &SoundManager) toggle_sound() bool {
	mut mutable_sm := unsafe { &SoundManager(sm) }
	mutable_sm.sound_enabled = !mutable_sm.sound_enabled
	if !mutable_sm.sound_enabled && sm.dev != 0 {
		sdl.clear_queued_audio(sm.dev)
	}
	return mutable_sm.sound_enabled
}

// Procedural Yie Ar Kung-Fu Arcade BGM
pub fn (sm &SoundManager) update_bgm(dt f64, is_active bool) {
	if !sm.sound_enabled || sm.dev == 0 || !is_active {
		return
	}
	queued := sdl.get_queued_audio_size(sm.dev)
	if queued > u32(44100 * 2 / 5) {
		return
	}

	mut mutable_sm := unsafe { &SoundManager(sm) }

	sample_rate := 44100
	step_duration := 0.115 // ~130 BPM fast arcade martial rhythm
	samples_per_step := int(f64(sample_rate) * step_duration)
	mut pcm := []i16{len: samples_per_step}

	// Yie Ar Kung-Fu Asian scale arcade lead (F minor / oriental pentatonic)
	lead_melody := [
		349.23, 0.0, 392.00, 415.30, 523.25, 415.30, 392.00, 349.23,
		311.13, 0.0, 349.23, 392.00, 415.30, 523.25, 622.25, 0.0,
		698.46, 0.0, 622.25, 523.25, 415.30, 523.25, 622.25, 698.46,
		783.99, 0.0, 698.46, 622.25, 523.25, 415.30, 349.23, 0.0,
	]
	// Driving martial bassline
	bass_notes := [
		174.61, 174.61, 261.63, 174.61, 207.65, 174.61, 261.63, 174.61,
		155.56, 155.56, 233.08, 155.56, 174.61, 174.61, 261.63, 174.61,
		174.61, 174.61, 261.63, 174.61, 207.65, 207.65, 261.63, 207.65,
		174.61, 174.61, 261.63, 174.61, 155.56, 155.56, 174.61, 174.61,
	]

	step := mutable_sm.bgm_step % lead_melody.len
	lead_freq := lead_melody[step]
	bass_freq := bass_notes[step]

	for i in 0 .. samples_per_step {
		t := f64(i) / f64(sample_rate)
		env := math.exp(-7.5 * (f64(i) / f64(samples_per_step)))

		mut lead := 0.0
		if lead_freq > 0.0 {
			lead = if math.sin(2.0 * math.pi * lead_freq * (t + mutable_sm.bgm_phase)) > 0.0 { 1.0 } else { -1.0 }
		}

		bass := math.sin(2.0 * math.pi * bass_freq * (t + mutable_sm.bgm_phase))

		// Fast hi-hat / temple woodblock
		mut drum := 0.0
		if step % 2 == 1 && i < samples_per_step / 3 {
			noise := f64((i * 1103515245 + 12345) % 65536) / 32768.0 - 1.0
			drum = noise * math.exp(-28.0 * t)
		}

		sample_val := (lead * 0.26 * env + bass * 0.24 + drum * 0.16) * 11500.0
		pcm[i] = i16(math.max(-32767.0, math.min(32767.0, sample_val)))
	}

	mutable_sm.bgm_phase += step_duration
	mutable_sm.bgm_step++
	sdl.queue_audio(sm.dev, pcm.data, u32(samples_per_step * 2))
}

pub fn (sm &SoundManager) play_punch_whoosh() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 65
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		progress := f64(i) / f64(num_samples)
		freq := 380.0 - 200.0 * progress
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := 1.0 - progress
		pcm[i] = i16(sq * env * 11000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_kick_whoosh() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 85
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		progress := f64(i) / f64(num_samples)
		freq := 280.0 - 150.0 * progress
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := 1.0 - progress
		pcm[i] = i16(sq * env * 13000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_hit_impact() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 110
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := f64((i * 1103515245 + 12345) % 65536) / 32768.0 - 1.0
		freq := 160.0 - 90.0 * (f64(i) / f64(num_samples))
		sine := math.sin(2.0 * math.pi * freq * t)
		env := math.exp(-12.0 * t)
		pcm[i] = i16((sine * 0.7 + noise * 0.3) * env * 17000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_weapon_clank() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 95
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		s1 := math.sin(2.0 * math.pi * 1760.0 * t)
		s2 := math.sin(2.0 * math.pi * 2340.0 * t)
		env := math.exp(-22.0 * t)
		pcm[i] = i16((s1 * 0.6 + s2 * 0.4) * env * 16000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}

pub fn (sm &SoundManager) play_ko_victory() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	duration_ms := 750
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}

	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51] // C5, E5, G5, C6, E6
	note_len := num_samples / notes.len

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		note_idx := int(math.min(f64(i / note_len), f64(notes.len - 1)))
		freq := notes[note_idx]
		sq := if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }
		env := 1.0 - (f64(i % note_len) / f64(note_len)) * 0.3
		pcm[i] = i16(sq * env * 15000.0)
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(num_samples * 2))
}
