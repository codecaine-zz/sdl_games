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
| **Bubble Shooter Pro** | `bubbleshooter/` | Classic arcade bubble puzzle! Hexagonal offset grid, wall-reflection trajectory laser, match-3+ BFS cluster popping, detached floating bubble gravity fall, descending ceiling timer, and glossy 3D spheres. | `Mouse Aim` / `Left Click` or `Space` shoot, `S` sound, `R` restart | [Preview](#24-bubble-shooter-pro) |
| **Flappy Bird Pro** | `flappy/` | Phenomenon tap-to-flap physics arcade! Real-time rotational pitch dynamics, procedural pipe gaps, parallax scrolling city skyline and cloud layers, bronze/silver/gold medal scoring system, and retro chimes. | `Space` / `Up` / `Click` flap, `S` sound, `R` restart | [Preview](#25-flappy-bird-pro) |
| **Q*bert 2.5D Isometric** | `qbert/` | The 1982 2.5D isometric pyramid classic! 28 shaded 3D cubes, diagonal hopping physics, purple Coily snake chase AI, bouncing red balls, flying escape discs, and `@!#?@!` comic curse synthesizer. | `Q/E/A/D` or `Keypad 7/9/1/3` or `Arrows` hop, `S` sound, `R` restart | [Preview](#26-qbert-25d-isometric) |
| **Puyo Puyo Cascade** | `puyopuyo/` | Japanese match-4 combo sensation! Bouncy jelly Puyos with expressive directional eyes, 4-way BFS group connectivity, multi-step gravity cascade chaining, ascending pentatonic combo chords, and next queue. | `A/D` move, `W/Up/Z` rotate CW, `X` rotate CCW, `S/Down` soft drop, `Space` hard drop, `M` sound, `R` restart | [Preview](#27-puyo-puyo-cascade) |
| **Gold Miner Classic** | `goldminer/` | Timeless mining winch & shop arcade! Oscillating pendulum claw, precision cable launch, mass/weight-based reel physics (Gold, Diamonds, Heavy Rocks, TNT Barrels, Mystery Bags), and dynamite stick detonation. | `Down/Space/Click` drop claw, `Up/W` use dynamite, `S` sound, `R` restart | [Preview](#28-gold-miner-classic) |
| **Duke Nukem: Cyber Outpost** | `duke/` | The 1991–1993 Apogee side-scrolling platformer legend! Somersault jumps, ladder & overhead pipe climbing, crouch shooting, 4 weapons (Blaster, Dual Laser, Flamethrower, Missiles), Red/Blue/Green keycard security doors, destructible cameras & crates, Robodroids, turrets, and Sound Blaster FM procedural synth. | `A`/`D` move, `W` climb/aim up, `S` crouch, `Space` jump, `Ctrl`/`J`/`F` fire, `R` restart | [Preview](#29-duke-nukem-cyber-outpost) |
| **Cyber Simon** | `simon/` | Electronic memory light & sound synthesizer! 4 glowing quadrant pads, authentic pitch harmonics (G#4, D#4, B3, G#3), 3 brain-training modes (Classic, Reverse Sequence, Speed Simon), streak counters, and digital 7-segment LED hub. | `Click`/`1-4`/`Q-S` pads, `Space` start, `M` mode, `R` reset, `S` sound | [Preview](#30-cyber-simon) |
| **Memory Match Pro** | `memorymatch/` | 3D card-flipping pair memory game! 3 grid modes (4x4, 6x4, 6x6), 18 handcrafted geometric icons (Gems, Crowns, Stars, Keys, Potions, Atoms, Shields, Rockets), combo multiplier streaks, mistake shake physics, and 3-star rating evaluation. | `Left Click` flip card, `G` grid mode, `R` new game, `S` sound | [Preview](#31-memory-match-pro) |
| **Chimp Test Pro** | `chimptest/` | Famous spatial working memory benchmark from cognitive primate neuroscience! Numbers 1 through N scatter on an 8x5 grid, instantly masking into blank squares on first click. 3 strikes system, working memory capacity scoring (4 to 15+ digits), and cognitive percentile ranking. | `Left Click` select tiles in order, `Space` continue, `R` reset | [Preview](#32-chimp-test-pro) |
| **Etch A Sketch Deluxe** | `etchasketch/` | The iconic mechanical drawing toy + creative studio! Authentic red bezel, dual rotary knobs, powder shake-to-erase physics, Spirograph mathematical gear studio, 5-stencil trace academy with star scoring, 4-way symmetry CAD, 6 color themes, and time-lapse replay! | `Arrows`/`WASD`/`Drag` draw, `Space` shake/erase, `1-4` modes, `Tab` preset, `C` theme, `R` replay | [Preview](#33-etch-a-sketch-deluxe) |
| **SkiFree Extreme** | `skifree/` | Classic 1991 Windows shareware winter sports recreation! Downhill slalom, jump ramps, mid-air stunt combos (Daffy, 360 Spin, Backflip, Spread Eagle), snow puff particles, 4 game modes, and the terrifying fast-running Yeti monster! | `Arrows`/`WASD` steer & tricks, `Space` jump & tuck, `M` mode, `R` restart | [Preview](#34-skifree-extreme) |
| **JezzBall Pro** | `jezzball/` | Legendary 1992 Windows Entertainment Pack containment puzzle! Red and blue bouncing kinetic energy atoms, horizontal & vertical laser wall expansion, flood-fill isolated territory capture, 75%+ containment goal, and procedural FM audio. | `Left Click` build wall, `Right Click`/`Space` toggle orientation, `R` restart | [Preview](#35-jezzball-pro) |
| **Yahtzee Deluxe** | `yahtzee/` | Classic 5-dice strategy game! Tumbling ivory dice physics, official 13-category scorecard with Upper Bonus (+35) and Yahtzee Bonus (+100) Joker rules, expected-value AI bot opponent, 2P Local mode, shaker rattle sound, and confetti celebrations! | `Space`/`Click` roll, `1-5` toggle hold, `Click row` score, `M` sound | [Preview](#36-yahtzee-deluxe) |
| **Mappy Arcade** | `mappy/` | Namco 1983 arcade classic! 6-floor mansion, trampoline bounce physics (wear states), door stun swings, microwave shockwaves, loot pair multipliers (2x-6x), Goro hide bonus, and balloon bonus rounds. | `A`/`D` or `Arrows` move/dismount, `Space`/`W` door, `1`/`2` start, `P` pause, `M` sound | [Preview](#44-mappy-arcade) |
| **CyberType: Neon Typist** | `typing/` | High-speed arcade typing space shooter! Lock-on plasma lasers, EMP nuke words, time-freeze stasis, real-time WPM/Accuracy gauges, 100x combo streaks, 4 game modes (Arcade, 60s Blitz, Code Syntax, Endless). | `A-Z` type & lock-on, `Backspace`/`Esc` cancel, `1-4` modes, `P` pause, `M` sound | [Preview](#45-cybertype-neon-typist) |

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

### 24. Bubble Shooter Pro
```bash
v run bubbleshooter
```
![Bubble Shooter Pro Screenshot](screenshots/bubbleshooter.png)

### 25. Flappy Bird Pro
```bash
v run flappy
```
![Flappy Bird Pro Screenshot](screenshots/flappy.png)

### 26. Q*bert 2.5D Isometric
```bash
v run qbert
```
![Q*bert Screenshot](screenshots/qbert.png)

### 27. Puyo Puyo Cascade
```bash
v run puyopuyo
```
![Puyo Puyo Cascade Screenshot](screenshots/puyopuyo.png)

### 28. Gold Miner Classic
```bash
v run goldminer
```
![Gold Miner Classic Screenshot](screenshots/goldminer.png)

### 29. Duke Nukem: Cyber Outpost
```bash
v run duke
```
- **Sector 1: Cyber Outpost (Night City)**:
![Duke Nukem: Cyber Outpost Screenshot](screenshots/duke.png)

- **Sector 2: Subterranean Reactor Core**:
![Duke Nukem: Sector 2 Screenshot](screenshots/duke_sector2.png)

- **Sector 3: Orbital Fortress & Mega Mech Boss**:
![Duke Nukem: Sector 3 Boss Screenshot](screenshots/duke_sector3.png)

### 30. Cyber Simon
```bash
v run simon
```
![Cyber Simon Screenshot](screenshots/simon.png)

### 31. Memory Match Pro
```bash
v run memorymatch
```
![Memory Match Pro Screenshot](screenshots/memorymatch.png)

### 32. Chimp Test Pro
```bash
v run chimptest
```
![Chimp Test Pro Screenshot](screenshots/chimptest.png)

### 33. Etch A Sketch Deluxe
```bash
v run etchasketch
```
![Etch A Sketch Deluxe Screenshot](screenshots/etchasketch.png)

### 34. SkiFree Extreme
```bash
v run skifree
```
![SkiFree Extreme Screenshot](screenshots/skifree.png)

### 35. JezzBall Pro
```bash
v run jezzball
```
![JezzBall Pro Screenshot](screenshots/jezzball.png)

### 36. Yahtzee Deluxe
```bash
v run yahtzee
```
![Yahtzee Deluxe Screenshot](screenshots/yahtzee.png)

---

## 🚀 How to Run

From the root repository directory:

```bash
v run yahtzee
v run etchasketch
v run skifree
v run jezzball
v run simon
v run memorymatch
v run chimptest
v run duke
v run bubbleshooter
v run flappy
v run qbert
v run puyopuyo
v run goldminer
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
v test yahtzee/
v test etchasketch/
v test skifree/
v test jezzball/
v test simon/
v test memorymatch/
v test chimptest/
v test duke/
v test bubbleshooter/
v test flappy/
v test qbert/
v test puyopuyo/
v test goldminer/
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
├── yahtzee/                # Yahtzee Deluxe (5-Dice Strategy, Full Scorecard, Upper/Yahtzee Bonus, AI Bot, 2P Local)
├── etchasketch/            # Etch A Sketch Deluxe (Rotary Knobs, Shake Erase, Spirograph, Stencils, Symmetry)
---

### 38. Scorched Earth Deluxe (`scorchedearth/`)
*1991 MS-DOS Tank Ballistics War Classic*

- **Destructible Voxel Terrain**: Real-time deformable 2D heightmap physics with gravity collapse and crater excavation.
- **6-Weapon Arsenal**: Standard Artillery Shells, Baby Nukes, MIRV Death's Head (apex cluster warhead split), Mountain Movers (dirt wall barriers), Napalm Rollers, and Digger Drills.
- **Ballistics Simulation**: Precision angle ($0^\circ-180^\circ$) and power ($50-1000$) dials with dynamic crosswinds ($-80$ to $+80$ mph) and bullet drop.
- **In-Between Rounds Shop**: Spend battle bounty cash on high-yield nukes, cluster bombs, and shields.
- **Smart AI Opponent**: Cyborg Bot recalculates firing angles and wind trajectories after every shot.
- **Controls**: `Left`/`Right` or `A`/`D` to adjust angle, `Up`/`Down` or `W`/`S` to adjust power, `1-6` to select weapon, `Space` to fire, `M` to toggle sound.

![Scorched Earth](screenshots/scorchedearth.png)

```bash
v run scorchedearth/
```

---

### 39. Lemmings Master (`lemmings/`)
*1991 DMA Design Puzzle Classic*

- **8 Assignable Lemming Skills**: Climber, Floater (umbrella parachute), Bomber (5s countdown "Oh No!" sacrifice), Blocker (turnaround barrier), Builder (12-step diagonal staircases), Basher (horizontal tunneling), Miner (diagonal excavation), and Digger (vertical shaft tunneling).
- **Pixel-Accurate Destructible Map**: Voxel terrain mask with real-time dynamic carving and pathfinding.
- **Complete Level Simulation**: Trapdoor drop hatch, home exit portal, save quota threshold, speed acceleration (`F`), pause (`P`), and Armageddon nuke countdown (`Space`).
- **Sound Effects**: Procedural synthesized "Let's Go!", "Oh No!", explosive pops, and victory chimes.

![Lemmings Master](screenshots/lemmings.png)

```bash
v run lemmings/
```

---

### 40. Chip's Challenge Deluxe (`chipschallenge/`)
*1989 Windows Entertainment Pack Classic*

- **Grid Physics Mechanics**: 16x16 puzzle maze with microchips, red/blue/yellow/green keys, color-coded security doors, and socket barrier gates.
- **Hazard Navigation**: Water pools, fire pits, dirt blocks, ice slides, force floors, and bomb triggers.
- **Interactive Inventory & Equipment**: Flipper boots (swim through water) and Fire boots (walk on fire).
- **Multiple Level Puzzles**: Handcrafted obstacle courses with countdown timers and victory exit portals.
- **Controls**: `Arrows` or `WASD` to move, `R` to restart level, `N` for next level, `M` to toggle sound.

![Chip's Challenge Deluxe](screenshots/chipschallenge.png)

```bash
v run chipschallenge/
```

---

### 41. Rodent's Revenge (`rodentsrevenge/`)
*1991 Microsoft Windows Cat-Trapping Classic*

- **Block Pushing Mechanics**: Push movable wooden warehouse crates singly or in rows to maneuver around hazards.
- **Cat AI & Trapping Algorithm**: Prowling and chasing cats that pathfind toward the mouse. When a cat has 0 movable adjacent squares (fully enclosed by blocks/walls), it instantly transforms into a giant edible cheese wedge (+1,000 pts)!
- **Warehouse Hazards**: Mousetraps, sinkholes, sleeping cats, and escalating level difficulties.
- **Controls**: `Arrows` or `WASD` to move mouse and push blocks, `R` to restart level, `M` to toggle sound.

![Rodent's Revenge](screenshots/rodentsrevenge.png)

```bash
v run rodentsrevenge/
```

---

### 42. Peggle Extreme (`peggle/`)
*Pachinko Peg-Popper Physics Arcade*

- **Pachinko Ballistics Physics**: Elastic bounce restitution on pegs, side wall reflections, and gravity trajectories.
- **Dynamic Peg Colors**: Orange goal pegs (clear 25 for Extreme Fever), Blue score pegs, Purple score multipliers, and Green multi-ball power-ups.
- **Moving Catcher Bucket**: Sliding bottom cart awards **+1 FREE BALL** on successful catches!
- **Extreme Fever Finale**: Slow-motion celebration with *Ode to Joy* procedural fanfare, bottom score bins (10k-100k pts), and celebratory confetti explosions!
- **Controls**: `Mouse` or `Left`/`Right` to aim cannon, `Left Click` or `Space` to shoot ball, `M` to toggle sound.

![Peggle Extreme](screenshots/peggle.png)

```bash
v run peggle/
```

---

### 43. Dope Wars 1990 (`dopewars/`)
*Turn-Based NYC Economic Strategy Classic*

- **30-Day Calendar & 6 NYC Boroughs**: Travel between Manhattan, The Bronx, Brooklyn, Queens, Staten Island, and Coney Island via the NYC Subway.
- **Volatile Commodity Market**: 8 commodities (Acid, Cocaine, Hashish, Heroin, Ludes, MDA, Opium, Weed) with realistic market fluctuations and price surges/crashes.
- **Financial Strategy**: 100-capacity trenchcoat, Loan Shark (compounding 10% daily debt interest), and 1st National Bank of NYC (5% daily deposit yield).
- **Random Street Events**: Police chases by Officer Bob and deputies (Run / Bribe), DEA raids, and drug bust surges.
- **Controls**: `1-8` to select commodity, `B` to buy, `S` to sell, `T` for subway transit, `K` for bank, `L` for loan shark, `M` to toggle sound.

![Dope Wars 1990](screenshots/dopewars.png)

```bash
v run dopewars/
```

---

### 44. Mappy Arcade (`mappy/`)
*1983 Namco Police Mouse Platformer Classic*

- **Trampoline Physics & Elastic Wear**: 4-state trampoline resilience (Green -> Blue -> Yellow -> Red -> Snap), safe mid-air passing, precision floor dismounting.
- **Doors & Microwave Shockwaves**: Wooden doors stun patrolling cats in swing arc; Microwave Super Doors fire ultrasonic shockwaves sweeping cats off-screen for escalating combo scores (+200, +400, +800, +1600...).
- **Stolen Loot Multipliers**: 5 item types in pairs (Radios, TVs, Microwaves, Paintings, Safes) award 2x, 3x, 4x, 5x, 6x multipliers for consecutive pairs.
- **Goro Ambush & Balloon Bonus Rounds**: 1000 pt Nyamco hide bonus, Hurry Up alarms, Gosenzo Coin hazard, and balloon-popping bonus stages with 5000 pt Perfect clears.
- **4 Difficulty Modes**:
  - **Easy (Cadet)**: 5 lives, slower cats (0.8x), 5 trampoline bounces, 55s hurry timer, 6s door stun.
  - **Normal (Officer)**: 3 lives, standard speed (1.0x), 4 trampoline bounces, 40s hurry timer, 4.5s door stun.
  - **Hard (Chief Detective)**: 2 lives, fast aggressive cats (1.25x), 3 trampoline bounces, 28s hurry timer, 3s door stun.
  - **Expert (Arcade Mania)**: 1 life, extreme speed (1.45x), 2 Goro boss cats, 2 trampoline bounces, 20s hurry timer (+50% bonus score!).
- **Controls**: `A`/`D` or `Left`/`Right` to move/dismount, `Space`/`W`/`Up` to open doors, `1-4` select difficulty, `D`/`Tab` cycle difficulty, `5`/`B` bonus stage, `P` to pause, `M`/`S` to toggle sound.

```bash
v run mappy/
```

---

### 45. CyberType: Neon Typist (`typing/`)
*High-Speed Arcade Typing Space Shooter*

- **Tactical Lock-On & Laser Elimination**: Typing the first letter acquires target lock; each subsequent letter fires bright plasma laser bolts directly into hostiles.
- **Enemy Classes & Power-Up Words**:
  - **Scouts & Cruisers**: Fast descending drones and armored hulls.
  - **Dreadnoughts**: Massive boss flagships requiring multi-syllable word mastery.
  - **EMP Nuke Words (Cyan)**: Detonates full-screen EMP shockwaves destroying all hostiles.
  - **Time Warp Words (Purple)**: Freezes all enemy movement for 4 seconds.
  - **Shield Repair Words (Green)**: Repairs +1 hull integrity block.
- **Real-Time Analytics & Combos**: Dynamic WPM (Words Per Minute) gauge, Accuracy percentage, and 10x/25x/50x/100x combo multiplier streaks.
- **4 Game Modes**:
  - **Arcade Campaign**: 10 progressive sector waves with asteroid belts and boss battles.
  - **60s Speed Blitz**: Intense 1-minute adrenaline rush for highest WPM records.
  - **Developer Syntax**: Falling code keywords from V, C, Rust, Python, Go, and SQL.
  - **Endless Survival**: Unlimited escalating wave assault.
- **Controls**: `A-Z` to type/target, `Backspace`/`Esc` to cancel lock, `Esc`/`F1` to pause, `1-4` or `Tab` select mode (on title), `Space`/`Enter` to start, `F9` to toggle sound, `F5` to restart.

```bash
v run typing/
```



