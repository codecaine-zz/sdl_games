module main

import math
import sdl

struct SoundManager {
pub mut:
	dev           sdl.AudioDeviceID
	sound_enabled bool = true
	bgm_enabled   bool = true
	bgm_phase     f64
	bgm_tick      u32
	bgm_theme     LevelTheme = .castle
	is_fast_bgm   bool
}

// --------------------------------------------------
// Synthesized Sound Effects
// --------------------------------------------------

fn gen_step() []i16 {
	sample_rate := 44100
	duration_ms := 35
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 320.0 - (180.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-35.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 14000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_heart() []i16 {
	sample_rate := 44100
	notes := [587.33, 880.00, 1174.66]
	note_dur := 55
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		for i in 0 .. samples_per_note {
			sample_idx := start_sample + i
			if sample_idx >= num_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			env := math.exp(-18.0 * t)
			val := (math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)) * env * 18000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
}

fn gen_shot() []i16 {
	sample_rate := 44100
	duration_ms := 110
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1400.0 - (1100.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-12.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 24000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_egg() []i16 {
	sample_rate := 44100
	duration_ms := 150
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 300.0 + (700.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-8.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_push() []i16 {
	sample_rate := 44100
	duration_ms := 80
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 140.0 - (60.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-22.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 25000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_laser() []i16 {
	sample_rate := 44100
	duration_ms := 300
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1600.0 - (1200.0 * (f64(i) / f64(num_samples)))
		env := math.exp(-6.0 * t)
		phase := math.fmod(freq * t, 1.0)
		val := (if phase > 0.5 { 1.0 } else { -1.0 }) * env * 24000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_chest() []i16 {
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51]
	note_dur := 70
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		for i in 0 .. samples_per_note {
			sample_idx := start_sample + i
			if sample_idx >= num_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			env := math.exp(-10.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
}

fn gen_victory() []i16 {
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98]
	note_dur := 90
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		for i in 0 .. samples_per_note {
			sample_idx := start_sample + i
			if sample_idx >= num_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			env := math.exp(-7.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 24000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
}

fn gen_undo() []i16 {
	sample_rate := 44100
	duration_ms := 60
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 700.0 - 350.0 * (f64(i) / f64(num_samples))
		env := math.exp(-20.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 18000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_warp() []i16 {
	sample_rate := 44100
	duration_ms := 160
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 350.0 + 950.0 * (f64(i) / f64(num_samples))
		env := math.exp(-5.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_slide() []i16 {
	sample_rate := 44100
	duration_ms := 70
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 1100.0 + 200.0 * math.sin(2.0 * math.pi * 60.0 * t)
		env := math.exp(-16.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 14000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_key() []i16 {
	sample_rate := 44100
	notes := [659.25, 987.77, 1318.51]
	note_dur := 50
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		for i in 0 .. samples_per_note {
			sample_idx := start_sample + i
			if sample_idx >= num_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			env := math.exp(-16.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 20000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
}

fn gen_spike() []i16 {
	sample_rate := 44100
	duration_ms := 100
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 300.0 - 200.0 * (f64(i) / f64(num_samples))
		env := math.exp(-22.0 * t)
		val := (if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }) * env * 25000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_powerup() []i16 {
	sample_rate := 44100
	notes := [440.0, 554.37, 659.25, 880.0, 1108.73]
	note_dur := 45
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		for i in 0 .. samples_per_note {
			sample_idx := start_sample + i
			if sample_idx >= num_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			env := math.exp(-12.0 * t)
			val := math.sin(2.0 * math.pi * freq * t) * env * 20000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
}

fn gen_prism() []i16 {
	sample_rate := 44100
	duration_ms := 80
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 880.0 + 440.0 * (f64(i) / f64(num_samples))
		env := math.exp(-25.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 22000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_phase() []i16 {
	sample_rate := 44100
	duration_ms := 140
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 200.0 + 800.0 * math.sin(2.0 * math.pi * 3.0 * t)
		env := math.exp(-8.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 24000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_plate() []i16 {
	sample_rate := 44100
	duration_ms := 70
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 520.0 - 260.0 * (f64(i) / f64(num_samples))
		env := math.exp(-28.0 * t)
		val := math.sin(2.0 * math.pi * freq * t) * env * 20000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn gen_badge() []i16 {
	sample_rate := 44100
	notes := [523.25, 659.25, 783.99, 1046.50, 1567.98]
	note_dur := 60
	num_samples := (sample_rate * (notes.len * note_dur)) / 1000
	mut pcm := []i16{len: num_samples}
	samples_per_note := (sample_rate * note_dur) / 1000
	for note_idx, freq in notes {
		start_sample := note_idx * samples_per_note
		for i in 0 .. samples_per_note {
			sample_idx := start_sample + i
			if sample_idx >= num_samples {
				break
			}
			t := f64(i) / f64(sample_rate)
			env := math.exp(-9.0 * t)
			val := (math.sin(2.0 * math.pi * freq * t) + 0.5 * math.sin(4.0 * math.pi * freq * t)) * env * 24000.0
			pcm[sample_idx] = i16(val)
		}
	}
	return pcm
}

// --------------------------------------------------
// Dynamic Procedural Cyber Synth BGM Loop Generator
// --------------------------------------------------

fn (mut sm SoundManager) update_bgm_stream(theme LevelTheme, is_fast bool) {
	if !sm.bgm_enabled || !sm.sound_enabled || sm.dev == 0 {
		return
	}

	sm.bgm_theme = theme
	sm.is_fast_bgm = is_fast
	sm.bgm_tick++

	// Only enqueue music chunk periodically to prevent overflow (approx 4 bars every 1.2s)
	rate_limit := if is_fast { u32(25) } else { u32(35) }
	if sm.bgm_tick % rate_limit != 0 {
		return
	}

	// 8-step Cyber Synth Arpeggio Presets per Biome
	arps := match theme {
		.castle { [220.0, 261.63, 329.63, 440.0, 329.63, 261.63, 392.0, 440.0] } // A Minor Cyber
		.forest { [261.63, 329.63, 392.0, 523.25, 392.0, 329.63, 293.66, 349.23] } // C Major Matrix
		.desert { [293.66, 349.23, 440.0, 587.33, 440.0, 349.23, 329.63, 293.66] } // D Phrygian Solar
		.ice { [329.63, 392.0, 493.88, 659.25, 493.88, 392.0, 440.0, 523.25] } // E Minor Cryo
		.volcanic { [196.0, 233.08, 293.66, 392.0, 293.66, 233.08, 261.63, 349.23] } // G Minor Magma
		.haunted { [246.94, 293.66, 369.99, 493.88, 369.99, 293.66, 220.0, 329.63] } // B Diminished Void
	}

	tempo_multiplier := if is_fast { 1.35 } else { 1.0 }
	sample_rate := 44100
	step_dur_ms := int(90.0 / tempo_multiplier)
	total_samples := (sample_rate * (arps.len * step_dur_ms)) / 1000
	mut pcm := []i16{len: total_samples}

	samples_per_step := (sample_rate * step_dur_ms) / 1000

	for step_idx, note_freq in arps {
		start_idx := step_idx * samples_per_step
		bass_freq := note_freq / 2.0

		for s in 0 .. samples_per_step {
			out_idx := start_idx + s
			if out_idx >= total_samples {
				break
			}
			t := f64(s) / f64(sample_rate)

			// Lead Arp Sine
			lead_env := math.exp(-8.0 * t)
			lead := math.sin(2.0 * math.pi * note_freq * t) * lead_env * 3500.0

			// Cyber Bass Sawtooth
			bass_phase := math.fmod(bass_freq * t, 1.0)
			bass := (bass_phase * 2.0 - 1.0) * 2200.0

			// Cyber Hi-Hat / Kick Beat
			mut beat := 0.0
			if step_idx % 2 == 0 {
				kick_env := math.exp(-35.0 * t)
				beat = math.sin(2.0 * math.pi * 90.0 * t) * kick_env * 4000.0
			}

			val := math_clamp_f64(lead + bass + beat, -32000.0, 32000.0)
			pcm[out_idx] = i16(val)
		}
	}

	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn math_clamp_f64(val f64, min f64, max f64) f64 {
	if val < min {
		return min
	}
	if val > max {
		return max
	}
	return val
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

fn (sm &SoundManager) toggle_bgm() bool {
	mut mutable_sm := unsafe { &SoundManager(sm) }
	mutable_sm.bgm_enabled = !mutable_sm.bgm_enabled
	return mutable_sm.bgm_enabled
}

fn (sm &SoundManager) play_step() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_step()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_heart() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_heart()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_shot() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_shot()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_egg() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_egg()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_push() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_push()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_laser() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_laser()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_chest() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_chest()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_undo() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_undo()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_victory() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_victory()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_warp() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_warp()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_slide() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_slide()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_key() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_key()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_spike() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_spike()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_powerup() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_powerup()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_prism() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_prism()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_phase() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_phase()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_plate() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_plate()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_badge() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_badge()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn (sm &SoundManager) play_hammer() {
	if !sm.sound_enabled || sm.dev == 0 {
		return
	}
	pcm := gen_hammer()
	sdl.queue_audio(sm.dev, pcm.data, u32(pcm.len * 2))
}

fn gen_hammer() []i16 {
	sample_rate := 44100
	duration_ms := 120
	num_samples := (sample_rate * duration_ms) / 1000
	mut pcm := []i16{len: num_samples}
	for i in 0 .. num_samples {
		t := f64(i) / f64(sample_rate)
		freq := 220.0 - 120.0 * (f64(i) / f64(num_samples))
		env := math.exp(-14.0 * t)
		val := (if math.sin(2.0 * math.pi * freq * t) > 0.0 { 1.0 } else { -1.0 }) * env * 24000.0
		pcm[i] = i16(val)
	}
	return pcm
}

fn (sm &SoundManager) cleanup() {
	if sm.dev != 0 {
		sdl.close_audio_device(sm.dev)
	}
}
