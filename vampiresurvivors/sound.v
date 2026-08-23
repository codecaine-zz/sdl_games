module main

import math
import sdl

pub enum BgmTrack {
	gothic_rondo
	vampires_eclipse
	bloodlust_symphony
	off
}

pub struct SoundManager {
pub mut:
	dev           u32
	sound_enabled bool
	bgm_track     BgmTrack
	bgm_phase     f64
	bgm_beat      int
	sample_pos    f64
}

pub fn new_sound_manager() SoundManager {
	mut sm := SoundManager{
		sound_enabled: true
		bgm_track:     .gothic_rondo
	}

	desired := sdl.AudioSpec{
		freq:     44100
		format:   sdl.AudioFormat(sdl.audio_s16sys)
		channels: 1
		samples:  1024
		callback: unsafe { nil }
	}
	mut obtained := sdl.AudioSpec{}

	dev := sdl.open_audio_device(unsafe { nil }, 0, &desired, &obtained, 0)
	if dev > 0 {
		sm.dev = dev
		sdl.pause_audio_device(dev, 0)
	}

	return sm
}

pub fn (mut sm SoundManager) toggle_sound() {
	sm.sound_enabled = !sm.sound_enabled
	if !sm.sound_enabled && sm.dev > 0 {
		sdl.clear_queued_audio(sm.dev)
	}
}

pub fn (mut sm SoundManager) cycle_bgm() {
	sm.bgm_track = match sm.bgm_track {
		.gothic_rondo { BgmTrack.vampires_eclipse }
		.vampires_eclipse { BgmTrack.bloodlust_symphony }
		.bloodlust_symphony { BgmTrack.off }
		.off { BgmTrack.gothic_rondo }
	}
	if sm.dev > 0 {
		sdl.clear_queued_audio(sm.dev)
	}
}

fn (sm &SoundManager) push_samples(samples []i16) {
	if !sm.sound_enabled || sm.dev == 0 || samples.len == 0 {
		return
	}
	sdl.queue_audio(sm.dev, unsafe { samples.data }, u32(samples.len * 2))
}

// Procedural Multi-Theme Gothic BGM Synthesizer
pub fn (mut sm SoundManager) update_bgm(_dt f64, is_active bool) {
	if !sm.sound_enabled || sm.dev == 0 || !is_active || sm.bgm_track == .off {
		return
	}
	queued := sdl.get_queued_audio_size(sm.dev)
	if queued > u32(44100 * 2 / 5) {
		return
	}

	sample_rate := 44100.0
	samples_to_gen := 44100 / 10 // 100ms chunk
	mut samples := []i16{len: samples_to_gen}

	match sm.bgm_track {
		.gothic_rondo {
			// Castlevania-inspired Gothic minor arpeggios at 140 BPM
			notes_arpeggio := [
				220.0, 261.63, 329.63, 440.0, 523.25, 440.0, 329.63, 261.63, // Am
				174.61, 220.0, 261.63, 349.23, 440.0, 349.23, 261.63, 220.0,  // F
				196.0, 246.94, 293.66, 392.0, 493.88, 392.0, 293.66, 246.94,  // G
				164.81, 207.65, 246.94, 329.63, 415.30, 329.63, 246.94, 207.65 // E7
			]
			bass_notes := [110.0, 87.31, 98.0, 82.41] // A1, F1, G1, E1
			samples_per_step := int(sample_rate * 0.107)

			for i in 0 .. samples_to_gen {
				total_sample := int(sm.sample_pos) + i
				step_idx := (total_sample / samples_per_step) % notes_arpeggio.len
				measure_idx := (total_sample / (samples_per_step * 8)) % bass_notes.len

				freq_lead := notes_arpeggio[step_idx]
				freq_bass := bass_notes[measure_idx]

				t := f64(total_sample) / sample_rate
				env_lead := 1.0 - (f64(total_sample % samples_per_step) / f64(samples_per_step))

				wave_lead := if math.sin(t * freq_lead * 2.0 * math.pi) > 0.0 { 1.0 } else { -1.0 }
				wave_bass := (t * freq_bass - math.floor(t * freq_bass)) * 2.0 - 1.0

				beat_step := (total_sample / (samples_per_step * 2)) % 4
				beat_sample := total_sample % (samples_per_step * 2)
				mut kick := 0.0
				if beat_step % 2 == 0 {
					kt := f64(beat_sample) / sample_rate
					kick = math.sin(kt * (120.0 - kt * 300.0) * 2.0 * math.pi) * math.exp(-kt * 25.0)
				}

				mix := wave_lead * env_lead * 0.35 + wave_bass * 0.25 + kick * 0.40
				samples[i] = i16(mix * 14000.0)
			}
		}
		.vampires_eclipse {
			// High-intensity 155 BPM Dark Electro Synthmetal
			notes_riff := [
				146.83, 146.83, 293.66, 146.83, 220.0, 146.83, 261.63, 146.83, // Dm
				130.81, 130.81, 261.63, 130.81, 196.0, 130.81, 220.0, 130.81,  // C
				116.54, 116.54, 233.08, 116.54, 174.61, 116.54, 196.0, 116.54,  // Bb
				130.81, 130.81, 261.63, 130.81, 220.0, 246.94, 261.63, 293.66  // C -> Dm
			]
			samples_per_step := int(sample_rate * 0.0967)

			for i in 0 .. samples_to_gen {
				total_sample := int(sm.sample_pos) + i
				step_idx := (total_sample / samples_per_step) % notes_riff.len
				freq_riff := notes_riff[step_idx]

				t := f64(total_sample) / sample_rate
				env := 1.0 - (f64(total_sample % samples_per_step) / f64(samples_per_step)) * 0.6

				phase := t * freq_riff
				saw := (phase - math.floor(phase)) * 2.0 - 1.0
				distorted_saw := math.max(-0.8, math.min(0.8, saw * 2.2))

				kick_sample := total_sample % samples_per_step
				kt := f64(kick_sample) / sample_rate
				kick := math.sin(kt * (160.0 - kt * 500.0) * 2.0 * math.pi) * math.exp(-kt * 30.0)

				mix := distorted_saw * env * 0.45 + kick * 0.50
				samples[i] = i16(mix * 14000.0)
			}
		}
		.bloodlust_symphony {
			// Epic 160 BPM Galloping Gothic Power Synth
			notes_melody := [
				440.0, 493.88, 523.25, 659.25, 587.33, 523.25, 493.88, 440.0,
				392.0, 440.0, 493.88, 587.33, 523.25, 493.88, 440.0, 392.0,
				349.23, 392.0, 440.0, 523.25, 493.88, 440.0, 392.0, 349.23,
				329.63, 415.30, 493.88, 659.25, 783.99, 659.25, 493.88, 415.30
			]
			samples_per_step := int(sample_rate * 0.0937)

			for i in 0 .. samples_to_gen {
				total_sample := int(sm.sample_pos) + i
				step_idx := (total_sample / samples_per_step) % notes_melody.len
				freq := notes_melody[step_idx]

				t := f64(total_sample) / sample_rate
				env := 1.0 - (f64(total_sample % samples_per_step) / f64(samples_per_step)) * 0.5

				sq := if math.sin(t * freq * 2.0 * math.pi) > 0.0 { 1.0 } else { -1.0 }
				sub := math.sin(t * (freq * 0.5) * 2.0 * math.pi)

				gallop_sample := total_sample % samples_per_step
				gt := f64(gallop_sample) / sample_rate
				gallop_kick := math.sin(gt * 110.0 * 2.0 * math.pi) * math.exp(-gt * 32.0)

				mix := sq * env * 0.35 + sub * 0.25 + gallop_kick * 0.40
				samples[i] = i16(mix * 14500.0)
			}
		}
		.off {
			return
		}
	}

	sm.sample_pos += f64(samples_to_gen)
	sm.push_samples(samples)
}

// Combat SFX Engine
pub fn (sm &SoundManager) play_whip_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 3500
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 900.0 * math.exp(-t * 22.0) + 90.0
		noise := (math.sin(f64(i) * 0.45) * 2.0 - 1.0) * 0.4
		wave := math.sin(t * freq * 2.0 * math.pi) + noise
		env := math.exp(-t * 28.0)
		samples[i] = i16(wave * env * 14000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_magic_wand_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 3000
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 450.0 + 800.0 * t
		wave := math.sin(t * freq * 2.0 * math.pi)
		env := (1.0 - f64(i) / f64(num_samples))
		samples[i] = i16(wave * env * 10000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_knife_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 2000
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1200.0 - 600.0 * t
		wave := if math.sin(t * freq * 2.0 * math.pi) > 0.0 { 1.0 } else { -1.0 }
		env := (1.0 - f64(i) / f64(num_samples))
		samples[i] = i16(wave * env * 8000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_gem_pickup_sound(val int) {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 2500
	mut samples := []i16{len: num_samples}
	base_f := if val >= 25 { 1320.0 } else if val >= 5 { 987.77 } else { 783.99 }
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := base_f + 300.0 * t
		wave := math.sin(t * freq * 2.0 * math.pi)
		env := math.exp(-t * 22.0)
		samples[i] = i16(wave * env * 11000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_level_up_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50]
	note_len := 2200
	mut samples := []i16{len: notes.len * note_len}
	for n_i, freq in notes {
		for i in 0 .. note_len {
			t := f64(i) / f64(sample_rate)
			wave := math.sin(t * freq * 2.0 * math.pi) + 0.3 * math.sin(t * freq * 4.0 * math.pi)
			env := 1.0 - f64(i) / f64(note_len)
			samples[n_i * note_len + i] = i16(wave * env * 12000.0)
		}
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_hit_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 2200
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (math.sin(f64(i * 37)) * 2.0 - 1.0)
		freq := 180.0 * (1.0 - t * 15.0)
		wave := noise * 0.7 + math.sin(t * freq * 2.0 * math.pi) * 0.3
		env := math.exp(-t * 30.0)
		samples[i] = i16(wave * env * 12000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_chest_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [440.0, 554.37, 659.25, 880.0, 1108.73]
	note_len := 2500
	mut samples := []i16{len: notes.len * note_len}
	for n_i, freq in notes {
		for i in 0 .. note_len {
			t := f64(i) / f64(sample_rate)
			sq := if math.sin(t * freq * 2.0 * math.pi) > 0.0 { 1.0 } else { -1.0 }
			env := 1.0 - f64(i) / f64(note_len)
			samples[n_i * note_len + i] = i16(sq * env * 10000.0)
		}
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_rosary_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 9000
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (math.sin(f64(i * 43)) * 2.0 - 1.0)
		freq := 300.0 * math.exp(-t * 8.0) + 60.0
		wave := noise * 0.65 + math.sin(t * freq * 2.0 * math.pi) * 0.35
		env := math.exp(-t * 5.0)
		samples[i] = i16(wave * env * 16000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_vacuum_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 6000
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 200.0 + 800.0 * (t / 0.136)
		wave := math.sin(t * freq * 2.0 * math.pi)
		env := (1.0 - math.abs(t / 0.136 - 0.5) * 2.0)
		samples[i] = i16(wave * math.max(0.0, env) * 11000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_evolution_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98]
	note_len := 2200
	mut samples := []i16{len: notes.len * note_len}
	for n_i, freq in notes {
		for i in 0 .. note_len {
			t := f64(i) / f64(sample_rate)
			wave := math.sin(t * freq * 2.0 * math.pi) + 0.4 * math.sin(t * freq * 3.0 * math.pi)
			env := 1.0 - f64(i) / f64(note_len)
			samples[n_i * note_len + i] = i16(wave * env * 13000.0)
		}
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_smash_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 2500
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		noise := (math.sin(f64(i * 67)) * 2.0 - 1.0)
		env := math.exp(-t * 35.0)
		samples[i] = i16(noise * env * 11000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_heal_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 3500
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 600.0 + math.sin(t * 80.0) * 150.0
		wave := math.sin(t * freq * 2.0 * math.pi)
		env := math.exp(-t * 20.0)
		samples[i] = i16(wave * env * 12000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_ultimate_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	num_samples := 12000
	mut samples := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		boom := math.sin(t * (240.0 - t * 450.0) * 2.0 * math.pi) * math.exp(-t * 4.0)
		noise := (math.sin(f64(i * 83)) * 2.0 - 1.0) * math.exp(-t * 8.0)
		lead := math.sin(t * 880.0 * 2.0 * math.pi) * math.exp(-t * 12.0)
		samples[i] = i16((boom * 0.5 + noise * 0.3 + lead * 0.2) * 16000.0)
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_combo_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [880.0, 1174.66, 1760.0]
	note_len := 1500
	mut samples := []i16{len: notes.len * note_len}
	for n_i, freq in notes {
		for i in 0 .. note_len {
			t := f64(i) / f64(sample_rate)
			wave := math.sin(t * freq * 2.0 * math.pi)
			env := math.exp(-t * 25.0)
			samples[n_i * note_len + i] = i16(wave * env * 11000.0)
		}
	}
	sm.push_samples(samples)
}

pub fn (sm &SoundManager) play_jackpot_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98, 2093.00]
	note_len := 1800
	mut samples := []i16{len: notes.len * note_len}
	for n_i, freq in notes {
		for i in 0 .. note_len {
			t := f64(i) / f64(sample_rate)
			sq := if math.sin(t * freq * 2.0 * math.pi) > 0.0 { 1.0 } else { -1.0 }
			env := 1.0 - f64(i) / f64(note_len)
			samples[n_i * note_len + i] = i16(sq * env * 12000.0)
		}
	}
	sm.push_samples(samples)
}
