module main

import sdl
import galaga
import bomberman
import frogger
import lunarlander
import digdug
import missilecommand
import donkeykong
import towerdefense
import shinobi
import rain

fn capture_game_snapshot(game_name string, render_fn fn(&sdl.Renderer)) {
	surface := sdl.create_rgb_surface(0, 800, 600, 32, 0x00FF0000, 0x0000FF00, 0x000000FF, 0xFF000000)
	if unsafe { surface == nil } { return }
	defer { sdl.free_surface(surface) }

	renderer := sdl.create_software_renderer(surface)
	if unsafe { renderer == nil } { return }
	defer { sdl.destroy_renderer(renderer) }

	render_fn(renderer)

	bmp_path := "screenshots/${game_name}.bmp"
	sdl.save_bmp(surface, bmp_path.str)
}

fn main() {
	sdl.init(sdl.init_video)
	defer { sdl.quit() }

	// 1. Galaga
	mut g_galaga := galaga.new_galaga_game()
	g_galaga.state = .playing
	capture_game_snapshot("galaga", fn [mut g_galaga] (r &sdl.Renderer) {
		galaga.render_galaga_game(r, mut g_galaga)
	})

	// 2. Bomberman
	mut g_bm := bomberman.new_bomberman_game()
	g_bm.state = .playing
	capture_game_snapshot("bomberman", fn [mut g_bm] (r &sdl.Renderer) {
		bomberman.render_bomberman_game(r, mut g_bm)
	})

	// 3. Frogger
	mut g_fr := frogger.new_frogger_game()
	g_fr.state = .playing
	capture_game_snapshot("frogger", fn [mut g_fr] (r &sdl.Renderer) {
		frogger.render_frogger_game(r, mut g_fr)
	})

	// 4. Lunar Lander
	mut g_ll := lunarlander.new_lunarlander_game()
	g_ll.state = .playing
	capture_game_snapshot("lunarlander", fn [mut g_ll] (r &sdl.Renderer) {
		lunarlander.render_lunarlander_game(r, mut g_ll)
	})

	// 5. Dig Dug
	mut g_dd := digdug.new_digdug_game()
	g_dd.state = .playing
	capture_game_snapshot("digdug", fn [mut g_dd] (r &sdl.Renderer) {
		digdug.render_digdug_game(r, mut g_dd)
	})

	// 6. Missile Command
	mut g_mc := missilecommand.new_missilecommand_game()
	g_mc.state = .playing
	capture_game_snapshot("missilecommand", fn [mut g_mc] (r &sdl.Renderer) {
		missilecommand.render_missilecommand_game(r, mut g_mc)
	})

	// 7. Donkey Kong
	mut g_dk := donkeykong.new_donkeykong_game()
	g_dk.state = .playing
	capture_game_snapshot("donkeykong", fn [mut g_dk] (r &sdl.Renderer) {
		donkeykong.render_donkeykong_game(r, mut g_dk)
	})

	// 8. Tower Defense
	mut g_td := towerdefense.new_towerdefense_game()
	g_td.state = .playing
	g_td.place_turret(1, 1, .laser)
	g_td.place_turret(3, 4, .cannon)
	capture_game_snapshot("towerdefense", fn [mut g_td] (r &sdl.Renderer) {
		towerdefense.render_towerdefense_game(r, mut g_td)
	})

	// 9. Shinobi
	mut g_sh := shinobi.new_shinobi_game()
	g_sh.state = .playing
	capture_game_snapshot("shinobi", fn [mut g_sh] (r &sdl.Renderer) {
		shinobi.render_shinobi_game(r, mut g_sh)
	})

	// 10. Rain Simulator & M4 Benchmark
	mut g_rain := rain.new_rain_game()
	g_rain.update(0.016)
	capture_game_snapshot("rain", fn [mut g_rain] (r &sdl.Renderer) {
		rain.render_rain_game(r, mut g_rain)
	})
}
