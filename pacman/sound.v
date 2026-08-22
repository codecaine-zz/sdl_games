module main

import math
import sdl

struct SoundManager {
mut:
	dev           sdl.AudioDeviceID
	sound_enabled bool = true
	waka_phase    bool
}

fn gen_waka(phase bool) []i16 {
	sample_rate := 44100
	duration_ms := 60
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000
	base_freq := if phase { 460.0 } else { 620.0 }

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := base_freq + (90.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-25.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		val := harm * env * attack * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_power_pellet() []i16 {
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 3 / 1000
	release_samples := sample_rate * 3 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 320.0 + math.sin(2.0 * math.pi * 15.0 * t) * 140.0
		env := math.exp(-6.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		release := if i > num_samples - release_samples { f64(num_samples - i) / f64(release_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.25 * math.sin(4.0 * math.pi * freq * t)
		val := harm * env * attack * release * 20000.0
		pcm[i] = i16(val)
	}
	return pcm
}

// Iconic pulsating blue ghost power siren
fn gen_frightened_siren() []i16 {
	sample_rate := 44100
	duration_ms := 140
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 3 / 1000
	release_samples := sample_rate * 4 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 440.0 + 190.0 * math.sin(2.0 * math.pi * 7.5 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		release := if i > num_samples - release_samples { f64(num_samples - i) / f64(release_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
		val := harm * attack * release * 19000.0
		pcm[i] = i16(val)
	}
	return pcm
}

// Rapid high-urgency warning siren when ghosts flash white and are about to recover
fn gen_frightened_warning_siren() []i16 {
	sample_rate := 44100
	duration_ms := 80
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000
	release_samples := sample_rate * 3 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 760.0 + 240.0 * math.sin(2.0 * math.pi * 16.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		release := if i > num_samples - release_samples { f64(num_samples - i) / f64(release_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.35 * math.sin(4.0 * math.pi * freq * t)
		val := harm * attack * release * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

// High-speed return siren when ghost eyes are fleeing back to ghost house
fn gen_eyes_siren() []i16 {
	sample_rate := 44100
	duration_ms := 100
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000
	release_samples := sample_rate * 3 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1100.0 + 350.0 * (f64(i) / f64(num_samples))
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		release := if i > num_samples - release_samples { f64(num_samples - i) / f64(release_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.25 * math.sin(4.0 * math.pi * freq * t)
		val := harm * attack * release * 20000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_eat_ghost() []i16 {
	sample_rate := 44100
	duration_ms := 180
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 600.0 + (1000.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-12.0 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.35 * math.sin(4.0 * math.pi * freq * t)
		val := harm * env * attack * 25000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_eat_fruit() []i16 {
	sample_rate := 44100
	duration_ms := 180
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	notes := [523.25, 783.99, 1046.50]
	note_dur := num_samples / notes.len
	attack_samples := sample_rate * 2 / 1000

	for note_idx, freq in notes {
		start_idx := note_idx * note_dur
		for i in 0 .. note_dur {
			idx := start_idx + i
			if idx >= num_samples { break }
			t := f64(i) / f64(sample_rate)
			env := math.exp(-14.0 * t)
			attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
			harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
			pcm[idx] = i16(harm * env * attack * 22000.0)
		}
	}
	return pcm
}

fn gen_death() []i16 {
	sample_rate := 44100
	duration_ms := 480
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	attack_samples := sample_rate * 2 / 1000

	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 520.0 - (440.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-4.5 * t)
		attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
		harm := math.sin(2.0 * math.pi * freq * t) + 0.35 * math.sin(2.0 * math.pi * 12.0 * t)
		val := harm * env * attack * 24000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_extra_life() []i16 {
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51]
	note_dur := 80
	total_dur := (notes.len - 1) * note_dur + 160
	num_samples := (sample_rate * total_dur) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	attack_samples := sample_rate * 2 / 1000

	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		dur_samples := if note_idx == notes.len - 1 { (sample_rate * 160) / 1000 } else { samples_per_note }
		for i in 0 .. dur_samples {
			sample_idx := start_sample + i
			if sample_idx >= num_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			decay := if note_idx == notes.len - 1 { -6.0 } else { -12.0 }
			env := math.exp(decay * t)
			attack := if i < attack_samples { f64(i) / f64(attack_samples) } else { 1.0 }
			harm := math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
			pcm[sample_idx] = i16(harm * env * attack * 22000.0)
		}
	}
	return pcm
}

fn new_sound_manager() SoundManager {
	if sdl.was_init(sdl.init_audio) == 0 {
		sdl.init_sub_system(sdl.init_audio)
	}

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

fn (sm &SoundManager) toggle_sound() bool {
	mut mutable_sm := unsafe { &SoundManager(sm) }
	mutable_sm.sound_enabled = !mutable_sm.sound_enabled
	return mutable_sm.sound_enabled
}

fn (sm &SoundManager) play_pcm(pcm []i16) {
	if !sm.sound_enabled || sm.dev == 0 || pcm.len == 0 {
		return
	}
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_waka_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	mut mutable_sm := unsafe { &SoundManager(sm) }
	mutable_sm.waka_phase = !mutable_sm.waka_phase
	pcm := gen_waka(mutable_sm.waka_phase)
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_power_pellet_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_power_pellet()
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_frightened_siren() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	queued := sdl.get_queued_audio_size(sm.dev)
	if queued > u32(44100 * 2 / 5) {
		return
	}
	pcm := gen_frightened_siren()
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_frightened_warning_siren() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	queued := sdl.get_queued_audio_size(sm.dev)
	if queued > u32(44100 * 2 / 5) {
		return
	}
	pcm := gen_frightened_warning_siren()
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_eyes_siren() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	queued := sdl.get_queued_audio_size(sm.dev)
	if queued > u32(44100 * 2 / 5) {
		return
	}
	pcm := gen_eyes_siren()
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_eat_ghost_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_eat_ghost()
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_eat_fruit_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_eat_fruit()
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_death_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_death()
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) play_extra_life_sound() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_extra_life()
	sm.play_pcm(pcm)
}

fn (sm &SoundManager) cleanup() {
	if sm.dev != 0 {
		sdl.close_audio_device(sm.dev)
	}
}
