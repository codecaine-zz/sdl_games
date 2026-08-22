# 🕹️ V Arcade SDL Games Suite

A production-ready suite of 2D arcade games built in [V](https://vlang.io/) using [vlang/sdl](https://github.com/vlang/sdl). Features zero external asset dependencies (100% procedural PCM sound synthesis, vector graphics rendering, and embedded ASCII bitmap fonts).

---

## ⚡ Requirements & Setup

Before running any game, you must have [V](https://vlang.io/) installed along with the official **V SDL wrapper**:

```bash
# Install V SDL module (https://github.com/vlang/sdl)
v install sdl
```

> **Note**: `vlang/sdl` requires SDL2 development libraries on your system:
> - **macOS**: `brew install sdl2 sdl2_gfx`
> - **Linux**: `sudo apt install libsdl2-dev libsdl2-gfx-dev`
> - **Windows**: Included DLLs or via vpkg

---

## 🎮 Included Games & Visual Showcase

| Game | Folder | Features | Controls | Preview |
| :--- | :--- | :--- | :--- | :--- |
| **NES Pinball** | `pinball/` | 1984 arcade classic recreation, two-screen vertically scrolling playfield, Mario Bonus Sub-stage, damsel rescue, tilt nudge. | `Z`/`X` flippers, `Space` plunger, `T` tilt, `S` sound | [Preview](#1-nes-pinball) |
| **NES Balloon Fight** | `balloonfight/` | Dual helium balloon inertia flight physics, parachuting enemies, Giant Fish hazard, 1P/2P Local Co-op, Balloon Trip mode. | `WASD`/`Arrows` move, `W`/`Space` flap, `P` pause, `M` sound | [Preview](#2-nes-balloon-fight) |
| **Cyberpunk Vanguard** | `sidescroller/` | 2D action side-scroller shooter, 8 weapon systems, jetpack & cyber dash, 5 enemy types, 3 stage bosses, 4-layer parallax. | `WASD` move, `W`/`Space` jetpack, `J`/`Z` fire, `K`/`Shift` dash, `1-8` weapons | [Preview](#3-cyberpunk-vanguard) |
| **Adventures of Lolo** | `lolo/` | Classic NES puzzle game recreation + interactive Level Designer! 11x11 grid engine, block pushing, Medusa line-of-sight laser, painter UI. | `Arrows`/`WASD` move, `Space` fire, `Tab` level designer, `R` reset | [Preview](#4-adventures-of-lolo) |
| **Cyber Drift Racer** | `racer/` | 2D top-down racing engine with drift physics, slip angles, surface friction (asphalt, grass, oil), AI racers, skid mark trails. | `W`/`S` accel/brake, `A`/`D` steer, `Space` handbrake drift, `R` reset | [Preview](#5-cyber-drift-racer) |
| **Asteroids Pro** | `asteroids/` | Vector space shooter, asteroid splitting hierarchy, alien UFOs, 6 power-ups (3x Spread, Shield, Rapid Fire, EMP Nuke, Plasma Beam). | `A`/`D` rotate, `W` thrust, `Space` fire, `H` hyperspace, `S` shield | [Preview](#6-asteroids-pro) |
| **Breakout Overdrive** | `breakout/` | Brick breaker with 5 level maps, 5 brick classes (Armored, TNT Explosive), paddle spin physics, 8 power-ups (Multiball, Laser, Sticky). | `Mouse`/`A`/`D` paddle, `Space`/`Click` launch & lasers, `L` level select | [Preview](#7-breakout-overdrive) |
| **Pac-Man Arcade** | `pacman/` | Classic 28x31 maze, 4 ghost AIs (Blinky, Pinky, Inky, Clyde), Chase/Scatter/Frightened modes, Power Pellets, Fruit bonuses. | `Arrows`/`WASD` move, `R` reset, `P` pause, `S` sound | [Preview](#8-pac-man-arcade) |
| **GNUjump** | `gnujump/` | Vertical tower jumper, platform variants (Ice, Spring, Crumbly), rising lava, combo jumps, 1P/2P local modes. | `Arrows`/`WASD` steer & jump, `M` mode, `R` reset, `O` sound | [Preview](#9-gnujump) |
| **SinkSub Pro** | `sinksub/` | Submarine hunter, 4 sub classes, homing torpedoes, floatmines, supply drops, upgrade shop terminal, 14 navy ranks. | `Left`/`Right` steer, `Z` depth charge, `X` rocket, `Space` nuke | [Preview](#10-sinksub-pro) |
| **Connect 4** | `connect4/` | Minimax AI (Alpha-Beta pruning, 3 difficulties), 3D bevel disc rendering, fireworks, sound synthesis. | `Left`/`Right`/`Click` drop, `U` undo, `R` reset, `M` mode, `D` diff | [Preview](#11-connect-4) |
| **Cyberpunk Snake** | `snake/` | Glowing neon snake segments, regular & golden star food, particle bursts, sound effects. | `WASD`/`Arrows` move, `R` reset, `P` pause, `S` sound | [Preview](#12-cyberpunk-snake) |
| **Modern Tetris** | `tetris/` | 7 Tetromino shapes, SRS rotation wall-kicks, ghost piece projection, hold piece, line-clear fireworks. | `Left`/`Right` move, `Up` rotate, `Down` soft drop, `Space` hard drop, `C` hold | [Preview](#13-modern-tetris) |
| **Hyper Pong** | `pong/` | 1P vs Adaptive AI & 2P Local modes, ball speed motion trails, angle spin reflections, score tracking. | `W`/`S` P1 paddle, `Up`/`Down` P2 paddle, `M` mode, `R` reset | [Preview](#14-hyper-pong) |
| **Ragdoll Physics** | `ragdoll/` | 2D Verlet physics sandbox, skeletal constraints, interactive tools (Gravity Gun, Tether Ropes, Slice Cutter, Bombs), 3 arenas. | `Mouse Drag`/`Click` tools, `1-3` arenas, `Q-I` tool shortcuts, `G` gravity flip | [Preview](#15-ragdoll-physics) |
| **Cyber Centipede Pro** | `centipede/` | Advanced Atari Centipede recreation, multi-segment chain physics, Poison Mushrooms, Fleas, Spiders, Scorpions, 6 stackable power-ups, Armored Mega-Centipede Boss waves. | `WASD`/`Arrows` move, `Space` fire, `R` reset, `P` pause, `O` sound | [Preview](#16-cyber-centipede-pro) |
| **Monsoon Overdrive** | `rain/` | Realistic rain simulator & M4 hardware benchmark game. Up to 1,000,000 active particles, up to 32GB RAM stress allocation, 2D fluid heightfield puddle wave dynamics, interactive umbrella shield, weather themes, procedural PCM audio. | `Mouse` umbrella, `1-5` presets, `WASD`/`Arrows` wind, `[`/`]` or `-`/`+` RAM stress, `Up`/`Dn` drops, `B` mode, `Tab` theme | [Preview](#17-monsoon-overdrive) |
| **Neon Vector Run 3D** | `cyberrunner/` | High-speed 3D neon highway runner built natively with `sokol.sgl` & Apple Silicon Metal. Dynamic 3D perspective camera, low-poly 3D hovercraft physics, jumping, hyper boost, near-miss combo multiplier system, 3D particle thruster trails, and procedural PCM synth audio. | `A`/`D` or `Arrows` steer, `Space`/`W` jump, `Shift`/`S` boost, `R` restart, `P` pause, `M` sound | [Preview](#18-neon-vector-run-3d) |
| **Minesweeper Pro** | `minesweeper/` | Classic Windows/Arcade puzzle recreation with 3 difficulty modes (Beginner, Intermediate, Expert), guaranteed first-click safety, BFS cascade reveal, chording, 7-segment digital LED timers, animated smiley face expressions, 3D beveled tiles, and procedural PCM sound synthesis. | `Left Click`/`Space` reveal & chord, `Right Click`/`F` flag, `1-3` difficulty, `T` theme, `R` reset, `S` sound | [Preview](#19-minesweeper-pro) |
| **Space Invaders Pro** | `spaceinvaders/` | The 1978 arcade legend! 55-alien marching matrix (Squids, Crabs, Octopuses), dynamic 4-tone accelerating bass heartbeat march audio, Mystery Flying Saucer UFO (50-300 bonus pts), 4 destructible voxel bunker shields with pixel crater erosion, and procedural audio. | `A`/`D` or `Arrows` steer, `Space` fire laser, `R` restart, `S` sound | [Preview](#20-space-invaders-pro) |
| **Sokoban Master** | `sokoban/` | The Japanese warehouse box-pushing puzzle masterpiece! 15+ handcrafted classic levels, smooth movement interpolation, unlimited undo history, 3-star rating mastery system, and resonant goal chime audio. | `WASD`/`Arrows` move, `U`/`Z` undo, `R` reset level, `N`/`P` next/prev level, `S` sound | [Preview](#21-sokoban-master) |
| **2048 Neon Pulse** | `game2048/` | Cyberpunk sliding number merge sensation! 4x4 rounded beveled grid, dynamic glowing neon color grading (2 to 4096+), ascending pentatonic musical merge chimes, undo history, score persistence, and endless play mode. | `WASD`/`Arrows`/`Mouse Drag` slide, `U` undo, `R` restart, `Space` keep playing, `S` sound | [Preview](#22-2048-neon-pulse) |
| **Tron Light Cycles** | `lightcycles/` | High-speed cyber arena light cycle racing leaving solid neon light ribbon walls! 1P vs Intelligent Lookahead AI (3 difficulties) and 2P Local Versus mode, turbo boost thrusters, and explosive cycle crash disintegration effects. | `WASD`/`Arrows` P1 move, `Space` P1 boost, `IJKL` P2 move, `RShift` P2 boost, `M` mode, `D` diff, `R` restart | [Preview](#23-tron-light-cycles) |

---

## 🖼️ Game Screenshots Gallery

### 1. NES Pinball
```bash
v run pinball
```
![NES Pinball Screenshot](screenshots/pinball.png)

### 2. NES Balloon Fight
```bash
v run balloonfight
```
![NES Balloon Fight Screenshot](screenshots/balloonfight.png)

### 3. Cyberpunk Vanguard
```bash
v run sidescroller
```
![Cyberpunk Vanguard Screenshot](screenshots/sidescroller.png)

### 4. Adventures of Lolo
```bash
v run lolo
```
![Adventures of Lolo Screenshot](screenshots/lolo.png)

### 5. Cyber Drift Racer
```bash
v run racer
```
![Cyber Drift Racer Screenshot](screenshots/racer.png)

### 6. Asteroids Pro
```bash
v run asteroids
```
![Asteroids Pro Screenshot](screenshots/asteroids.png)

### 7. Breakout Overdrive
```bash
v run breakout
```
![Breakout Overdrive Screenshot](screenshots/breakout.png)

### 8. Pac-Man Arcade
```bash
v run pacman
```
![Pac-Man Arcade Screenshot](screenshots/pacman.png)

### 9. GNUjump
```bash
v run gnujump
```
![GNUjump Screenshot](screenshots/gnujump.png)

### 10. SinkSub Pro
```bash
v run sinksub
```
![SinkSub Pro Screenshot](screenshots/sinksub.png)

### 11. Connect 4
```bash
v run connect4
```
![Connect 4 Screenshot](screenshots/connect4.png)

### 12. Cyberpunk Snake
```bash
v run snake
```
![Cyberpunk Snake Screenshot](screenshots/snake.png)

### 13. Modern Tetris
```bash
v run tetris
```
![Modern Tetris Screenshot](screenshots/tetris.png)

### 14. Hyper Pong
```bash
v run pong
```
![Hyper Pong Screenshot](screenshots/pong.png)

### 15. Ragdoll Physics
```bash
v run ragdoll
```
![Ragdoll Physics Screenshot](screenshots/ragdoll.png)

### 16. Cyber Centipede Pro
```bash
v run centipede
```
![Cyber Centipede Pro Screenshot](screenshots/centipede.png)

### 17. Monsoon Overdrive (Rain Simulator & M4 Benchmark)
```bash
v run rain
```
![Monsoon Overdrive Screenshot](screenshots/rain.png)

### 18. Neon Vector Run 3D
```bash
v run cyberrunner
```
![Neon Vector Run 3D](screenshots/cyberrunner.png)

### 19. Minesweeper Pro
```bash
v run minesweeper
```
![Minesweeper Pro Screenshot](screenshots/minesweeper.png)

### 20. Space Invaders Pro
```bash
v run spaceinvaders
```
![Space Invaders Pro Screenshot](screenshots/spaceinvaders.png)

### 21. Sokoban Master
```bash
v run sokoban
```
![Sokoban Master Screenshot](screenshots/sokoban.png)

### 22. 2048 Neon Pulse
```bash
v run game2048
```
![2048 Neon Pulse Screenshot](screenshots/game2048.png)

### 23. Tron Light Cycles
```bash
v run lightcycles
```
![Tron Light Cycles Screenshot](screenshots/lightcycles.png)

---

## 🚀 How to Run

From the root repository directory:

```bash
v run minesweeper
v run spaceinvaders
v run sokoban
v run game2048
v run lightcycles
v run pinball
v run balloonfight
v run sidescroller
v run lolo
v run racer
v run asteroids
v run breakout
v run pacman
v run gnujump
v run sinksub
v run connect4
v run snake
v run tetris
v run pong
v run ragdoll
v run centipede
v run rain
v run cyberrunner
```

---

## 🧪 Automated Testing

Run unit tests for game modules:

```bash
v test minesweeper/
v test spaceinvaders/
v test sokoban/
v test game2048/
v test lightcycles/
v test pinball/
v test balloonfight/
v test sidescroller/
v test lolo/
v test racer/
v test ragdoll/
v test centipede/
v test rain/
v test cyberrunner/
```

---

## 📁 Workspace Structure

```
sdl_games/
├── minesweeper/            # Minesweeper Pro (3 Difficulties, First-Click Safety, 7-Seg LED, Chording)
├── spaceinvaders/          # Space Invaders 1978 Arcade Pro (55 Aliens, Heartbeat Audio, Voxel Shields, UFO)
├── sokoban/                # Sokoban Master (15+ Handcrafted Levels, Undo Stack, 3-Star Rating)
├── game2048/               # 2048 Neon Pulse (Smooth Sliding, Pentatonic Merge Chimes, Undo)
├── lightcycles/            # Tron Light Cycles (Lookahead AI, 1P/2P Local Versus, Turbo Boost)
├── pinball/                # NES Pinball Recreation (1984 Arcade Classic)
├── balloonfight/           # NES Balloon Fight Recreation (1984 Arcade Classic)
├── sidescroller/           # Cyberpunk Vanguard 2D Side-Scroller Shooter
├── lolo/                   # Adventures of Lolo & Level Designer
├── racer/                  # 2D Top-Down Cyber Drift Racing Engine
├── asteroids/              # Asteroids Pro Vector Space Shooter
├── breakout/               # Breakout Overdrive Brick Breaker
├── pacman/                 # Pac-Man Arcade Game
├── gnujump/                # GNUjump Vertical Tower Jumper
├── sinksub/                # SinkSub Pro Submarine Hunter
├── connect4/               # Connect 4 Minimax AI
├── snake/                  # Cyberpunk Snake Game
├── tetris/                 # Modern Tetris Game
├── pong/                   # Hyper Pong Game
├── ragdoll/                # Ragdoll Physics Sandbox
├── centipede/              # Cyber Centipede Pro Arcade Game
├── rain/                   # Monsoon Overdrive Realistic Rain & M4 Benchmark Game
├── cyberrunner/            # Neon Vector Run 3D High-Speed Highway Runner Engine
├── screenshots/            # Showcase screenshots of all 23 games
└── README.md
```
