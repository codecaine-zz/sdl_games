# 🕹️ V Arcade SDL Games Suite

A massive collection of **63 playable 2D and 3D arcade games, retro classics, puzzle adventures, board games, and physics simulations** built in [V](https://vlang.io/) using [vlang/sdl](https://github.com/vlang/sdl). 

Every single game is engineered with **zero external asset dependencies** — utilizing 100% procedural PCM sound synthesis, vector graphics rasterization, and embedded pixel/bitmap fonts.

---

## ⚡ Requirements & Setup

Before running any game, ensure you have [V](https://vlang.io/) installed along with the official **V SDL wrapper**:

```bash
# Install V SDL module
v install sdl
```

> **System Dependencies**: `vlang/sdl` requires SDL2 development libraries on your machine:
> - **macOS**: `brew install sdl2 sdl2_gfx`
> - **Linux (Ubuntu/Debian)**: `sudo apt install libsdl2-dev libsdl2-gfx-dev`
> - **Windows**: Pre-built SDL2 DLLs or via `vpkg`

---

## 🎮 Master Game Index (63 Games)

| # | Game | Folder | Genre | Quick Controls | How to Play |
| :-: | :--- | :--- | :--- | :--- | :-: |
| **1** | [Air Hockey](#1-hyper-air-hockey-airhockey) | `airhockey/` | Sports / Physics | `Mouse` / `WASD` (P1), `Arrows` / `IJKL` (P2) | [Guide](#1-hyper-air-hockey-airhockey) |
| **2** | [Asteroids Pro](#2-asteroids-pro-asteroids) | `asteroids/` | Vector Space Shooter | `A`/`D` rotate, `W` thrust, `Space` fire, `H` hyper | [Guide](#2-asteroids-pro-asteroids) |
| **3** | [Balloon Fight](#3-nes-balloon-fight-balloonfight) | `balloonfight/` | 1984 Flight Arcade | `WASD`/`Arrows` steer, `W`/`Space` flap, `P` pause | [Guide](#3-nes-balloon-fight-balloonfight) |
| **4** | [Battleship Pro](#4-battleship-pro-battleship) | `battleship/` | Naval Strategy | `Left Click` target/place, `Right Click`/`R` rotate | [Guide](#4-battleship-pro-battleship) |
| **5** | [Bejeweled Match-3](#5-bejeweled-match-3-bejeweled) | `bejeweled/` | Match-3 Cascade | `Mouse Drag` / `Click` swap gems, `H` hint | [Guide](#5-bejeweled-match-3-bejeweled) |
| **6** | [Bomberman Arcade](#6-bomberman-arcade-bomberman) | `bomberman/` | Action Maze Puzzle | `WASD`/`Arrows` move, `Space` plant bomb | [Guide](#6-bomberman-arcade-bomberman) |
| **7** | [Boulder Dash Retro](#7-boulder-dash-retro-boulderdash) | `boulderdash/` | Digging / Physics | `WASD`/`Arrows` dig, `P`/`N` cave select | [Guide](#7-boulder-dash-retro-boulderdash) |
| **8** | [Breakout Overdrive](#8-breakout-overdrive-breakout) | `breakout/` | Brick Breaker | `Mouse` / `A`/`D` paddle, `Space`/`Click` launch | [Guide](#8-breakout-overdrive-breakout) |
| **9** | [Bubble Shooter Pro](#9-bubble-shooter-pro-bubbleshooter) | `bubbleshooter/` | Match-3 Arcade | `Mouse Aim`, `Left Click`/`Space` fire bubble | [Guide](#9-bubble-shooter-pro-bubbleshooter) |
| **10** | [Centipede Pro](#10-cyber-centipede-pro-centipede) | `centipede/` | Fixed Shooter | `WASD`/`Arrows` move, `Space` rapid fire | [Guide](#10-cyber-centipede-pro-centipede) |
| **11** | [Chimp Test Pro](#11-chimp-test-pro-chimptest) | `chimptest/` | Cognitive Memory | `Left Click` numbers in ascending order | [Guide](#11-chimp-test-pro-chimptest) |
| **12** | [Chip's Challenge Deluxe](#12-chips-challenge-deluxe-chipschallenge) | `chipschallenge/` | Tile Puzzle Adventure | `WASD`/`Arrows` step/push, `R` restart | [Guide](#12-chips-challenge-deluxe-chipschallenge) |
| **13** | [Click Arcade](#13-click-arcade-4-in-1-clickarcade) | `clickarcade/` | 4-in-1 Casual Suite | `Left Click` / `Mouse Drag` all mini-games | [Guide](#13-click-arcade-4-in-1-clickarcade) |
| **14** | [Connect 4](#14-connect-4-connect4) | `connect4/` | Board Strategy / AI | `Left`/`Right` / `Click` column, `U` undo | [Guide](#14-connect-4-connect4) |
| **15** | [Cyber Vector Run 3D](#15-neon-vector-run-3d-cyberrunner) | `cyberrunner/` | 3D Highway Runner | `A`/`D` steer, `Space`/`W` jump, `Shift`/`S` boost | [Guide](#15-neon-vector-run-3d-cyberrunner) |
| **16** | [Dig Dug Classic](#16-dig-dug-classic-digdug) | `digdug/` | Underground Action | `WASD`/`Arrows` dig, `Space` pump harpoon | [Guide](#16-dig-dug-classic-digdug) |
| **17** | [Donkey Kong Arcade](#17-donkey-kong-arcade-donkeykong) | `donkeykong/` | Platformer Classic | `A`/`D` run, `W`/`S` climb ladders, `Space` jump | [Guide](#17-donkey-kong-arcade-donkeykong) |
| **18** | [Dope Wars 1990](#18-dope-wars-1990-dopewars) | `dopewars/` | Turn-Based Economy | `1-8` commodities, `B` buy, `S` sell, `T` subway | [Guide](#18-dope-wars-1990-dopewars) |
| **19** | [Duke Nukem: Cyber Outpost](#19-duke-nukem-cyber-outpost-duke) | `duke/` | Side-Scroll Platformer | `A`/`D` move, `W` climb/aim, `Space` jump, `Ctrl` fire | [Guide](#19-duke-nukem-cyber-outpost-duke) |
| **20** | [Etch A Sketch Deluxe](#20-etch-a-sketch-deluxe-etchasketch) | `etchasketch/` | Creative Drawing | `WASD`/`Arrows`/`Drag` draw, `Space` shake | [Guide](#20-etch-a-sketch-deluxe-etchasketch) |
| **21** | [Flappy Bird Pro](#21-flappy-bird-pro-flappy) | `flappy/` | Physics Tap Arcade | `Space` / `Up` / `Click` flap wings | [Guide](#21-flappy-bird-pro-flappy) |
| **22** | [Frogger Arcade](#22-frogger-arcade-frogger) | `frogger/` | Road & River Crossing | `WASD` / `Arrows` hop 4-way, `R` reset | [Guide](#22-frogger-arcade-frogger) |
| **23** | [Galaga Space Shooter](#23-galaga-space-shooter-galaga) | `galaga/` | Fixed Wave Shooter | `A`/`D`/`Arrows` slide ship, `Space` fire | [Guide](#23-galaga-space-shooter-galaga) |
| **24** | [2048 Neon Pulse](#24-2048-neon-pulse-game2048) | `game2048/` | Sliding Merge Puzzle | `WASD` / `Arrows` / `Drag` slide tiles | [Guide](#24-2048-neon-pulse-game2048) |
| **25** | [GNUjump Tower](#25-gnujump-tower-gnujump) | `gnujump/` | Vertical Tower Jumper | `A`/`D`/`Arrows` steer, `Space` high jump | [Guide](#25-gnujump-tower-gnujump) |
| **26** | [Gold Miner Classic](#26-gold-miner-classic-goldminer) | `goldminer/` | Winch & Reel Arcade | `Down`/`Space`/`Click` reel claw, `Up` dynamite | [Guide](#26-gold-miner-classic-goldminer) |
| **27** | [JezzBall Pro](#27-jezzball-pro-jezzball) | `jezzball/` | Kinetic Containment | `Left Click` build wall, `Right Click` rotate axis | [Guide](#27-jezzball-pro-jezzball) |
| **28** | [Lemmings Master](#28-lemmings-master-lemmings) | `lemmings/` | Colony Puzzle Strategy | `Mouse Click` assign skills, `F` fast forward | [Guide](#28-lemmings-master-lemmings) |
| **29** | [Liar's Dice Deluxe](#29-liars-dice-deluxe-liarsdice) | `liarsdice/` | Bluffing Dice Party | `Space` bid, `L` call Liar!, `C` Spot On! | [Guide](#29-liars-dice-deluxe-liarsdice) |
| **30** | [Tron Light Cycles](#30-tron-light-cycles-lightcycles) | `lightcycles/` | Grid Arena Racing | `WASD` P1 move + `Space` boost, `IJKL` P2 | [Guide](#30-tron-light-cycles-lightcycles) |
| **31** | [Adventures of Lolo](#31-adventures-of-lolo-lolo) | `lolo/` | Top-Down Grid Puzzle | `WASD`/`Arrows` move/push, `Space` magic shot | [Guide](#31-adventures-of-lolo-lolo) |
| **32** | [Lunar Lander Simulator](#32-lunar-lander-simulator-lunarlander) | `lunarlander/` | Vector Moon Landing | `A`/`D` rotate, `W`/`Up`/`Space` thruster | [Guide](#32-lunar-lander-simulator-lunarlander) |
| **33** | [Mappy Arcade](#33-mappy-arcade-mappy) | `mappy/` | Police Trampoline Run | `A`/`D` move/dismount, `Space`/`W` open doors | [Guide](#33-mappy-arcade-mappy) |
| **34** | [Memory Match Pro](#34-memory-match-pro-memorymatch) | `memorymatch/` | Card Flipping Pairs | `Left Click` flip cards, `G` grid size (4x4 to 6x6) | [Guide](#34-memory-match-pro-memorymatch) |
| **35** | [Micro Mayhem](#35-micro-mayhem-micromayhem) | `micromayhem/` | 4-Second Micro Marathon | `Space` / `1-3` / `WASD` / `Mouse` per game | [Guide](#35-micro-mayhem-micromayhem) |
| **36** | [Minesweeper Pro](#36-minesweeper-pro-minesweeper) | `minesweeper/` | Minefield Logic | `Left Click` reveal/chord, `Right Click` flag | [Guide](#36-minesweeper-pro-minesweeper) |
| **37** | [Missile Command](#37-missile-command-air-defense-missilecommand) | `missilecommand/` | Anti-Ballistic Defense | `Mouse Aim` + `Left Click` fire counter-missile | [Guide](#37-missile-command-air-defense-missilecommand) |
| **38** | [Pac-Man Arcade](#38-pac-man-arcade-pacman) | `pacman/` | Maze Dot-Chomp | `WASD` / `Arrows` steer Pac-Man | [Guide](#38-pac-man-arcade-pacman) |
| **39** | [Peggle Extreme](#39-peggle-extreme-peggle) | `peggle/` | Pachinko Ballistics | `Mouse Aim` / `Left Click` or `Space` launch ball | [Guide](#39-peggle-extreme-peggle) |
| **40** | [Picross Pro](#40-picross-pro-picross) | `picross/` | Nonogram Logic Grid | `Left Click` fill, `Right Click` cross, `H` hint | [Guide](#40-picross-pro-picross) |
| **41** | [NES Pinball](#41-nes-pinball-pinball) | `pinball/` | 1984 Pinball Simulation | `Z`/`X` flippers, `Space` plunger, `T` tilt | [Guide](#41-nes-pinball-pinball) |
| **42** | [Hyper Pong](#42-hyper-pong-pong) | `pong/` | 2D Paddle Rally | `W`/`S` (P1 paddle), `Up`/`Down` (P2 paddle) | [Guide](#42-hyper-pong-pong) |
| **43** | [Puyo Puyo Cascade](#43-puyo-puyo-cascade-puyopuyo) | `puyopuyo/` | Match-4 Jelly Drop | `A`/`D` move, `W`/`Z` rotate CW, `Space` drop | [Guide](#43-puyo-puyo-cascade-puyopuyo) |
| **44** | [Q*bert Isometric](#44-qbert-isometric-qbert) | `qbert/` | 2.5D Pyramid Hop | `Q/E/A/D` / `Numpad 7/9/1/3` / `Arrows` hop | [Guide](#44-qbert-isometric-qbert) |
| **45** | [Cyber Drift Racer](#45-cyber-drift-racer-racer) | `racer/` | Top-Down Drift Racing | `W`/`S` gas/brake, `A`/`D` steer, `Space` drift | [Guide](#45-cyber-drift-racer-racer) |
| **46** | [Ragdoll Physics](#46-ragdoll-physics-sandbox-ragdoll) | `ragdoll/` | Verlet Physics Lab | `Mouse Drag` joints, `Q-I` tools, `G` gravity | [Guide](#46-ragdoll-physics-sandbox-ragdoll) |
| **47** | [Monsoon Overdrive](#47-monsoon-overdrive-rain-benchmark-rain) | `rain/` | Fluid Rain & Benchmark | `Mouse` umbrella, `1-5` presets, `[`/`]` stress | [Guide](#47-monsoon-overdrive-rain-benchmark-rain) |
| **48** | [Reversi Master](#48-reversi-master-reversi) | `reversi/` | 8x8 Board Reversi | `Left Click` place disc, `U` undo, `H` hint | [Guide](#48-reversi-master-reversi) |
| **49** | [Rodent's Revenge](#49-rodents-revenge-rodentsrevenge) | `rodentsrevenge/` | Cat Trapping Puzzle | `WASD`/`Arrows` push crates & trap cats | [Guide](#49-rodents-revenge-rodentsrevenge) |
| **50** | [Scorched Earth](#50-scorched-earth-deluxe-scorchedearth) | `scorchedearth/` | Tank Artillery War | `A`/`D` angle, `W`/`S` power, `1-6` weapons | [Guide](#50-scorched-earth-deluxe-scorchedearth) |
| **51** | [Cyber Shinobi](#51-cyber-shinobi-runner-shinobi) | `shinobi/` | Ninja Action Platformer | `A`/`D` run, `W` jump, `J` katana, `K` shuriken | [Guide](#51-cyber-shinobi-runner-shinobi) |
| **52** | [Cyberpunk Vanguard](#52-cyberpunk-vanguard-sidescroller) | `sidescroller/` | 2D Action Side-Scroller | `WASD` move, `W`/`Space` jetpack, `J` fire, `K` dash | [Guide](#52-cyberpunk-vanguard-sidescroller) |
| **53** | [Cyber Simon](#53-cyber-simon-simon) | `simon/` | Audio-Visual Sequence | `Click` / `1-4` / `Q-S` pads, `M` mode | [Guide](#53-cyber-simon-simon) |
| **54** | [SinkSub Pro](#54-sinksub-pro-sinksub) | `sinksub/` | Submarine Hunter | `Left`/`Right` steer ship, `Z` depth charge, `X` rocket | [Guide](#54-sinksub-pro-sinksub) |
| **55** | [SkiFree Extreme](#55-skifree-extreme-skifree) | `skifree/` | Downhill Slalom Stunts | `Arrows`/`WASD` steer & tricks, `Space` jump | [Guide](#55-skifree-extreme-skifree) |
| **56** | [Cyberpunk Snake](#56-cyberpunk-snake-snake) | `snake/` | Neon Snake Slither | `WASD` / `Arrows` steer snake, `P` pause | [Guide](#56-cyberpunk-snake-snake) |
| **57** | [Sokoban Master](#57-sokoban-master-sokoban) | `sokoban/` | Warehouse Box Pushing | `WASD`/`Arrows` move, `U` undo, `N`/`P` level | [Guide](#57-sokoban-master-sokoban) |
| **58** | [Space Invaders Pro](#58-space-invaders-pro-spaceinvaders) | `spaceinvaders/` | 1978 Space Defense | `A`/`D` steer cannon, `Space` fire laser | [Guide](#58-space-invaders-pro-spaceinvaders) |
| **59** | [Modern Tetris](#59-modern-tetris-tetris) | `tetris/` | SRS Matrix Puzzle | `Left`/`Right` move, `Up` rotate, `Space` hard drop, `C` hold | [Guide](#59-modern-tetris-tetris) |
| **60** | [Cyber Tower Defense](#60-cyber-tower-defense-towerdefense) | `towerdefense/` | Strategic Path Defense | `1-3` select tower, `Mouse Click` build, `U` upgrade | [Guide](#60-cyber-tower-defense-towerdefense) |
| **61** | [Party Trivia Show](#61-party-trivia-show-trivia) | `trivia/` | TV Studio Quiz Battle | `1-4`/`A-D` (P1), `U-P` (P2), `Space` next | [Guide](#61-party-trivia-show-trivia) |
| **62** | [CyberType Typist](#62-cybertype-neon-typist-typing) | `typing/` | Typing Space Shooter | `A-Z` type target words, `Backspace` cancel lock | [Guide](#62-cybertype-neon-typist-typing) |
| **63** | [Yahtzee Deluxe](#63-yahtzee-deluxe-yahtzee) | `yahtzee/` | 5-Dice Strategy | `Space`/`Click` roll, `1-5` hold dice, `Click row` score | [Guide](#63-yahtzee-deluxe-yahtzee) |

---

# 📖 Complete "How to Play" Guides

---

### 1. Hyper Air Hockey (`airhockey/`)
*High-Speed 2D Table Hockey with Elastic Collision Physics*

```bash
v run airhockey
```
![Hyper Air Hockey](screenshots/airhockey.png)

- **Objective**: Use your mallet to strike the puck across the centerline and score into your opponent's goal. First to 7 goals wins the match!
- **Controls**:
  - **Player 1 (Left Mallet)**: `Mouse` cursor tracking or `WASD` keyboard navigation.
  - **Player 2 (Right Mallet)**: `Arrow Keys` or `IJKL`.
  - **Game Options**: `Tab` cycles AI difficulty (Easy, Medium, Pro), `M` toggles 1P vs AI / 2P Local mode, `R` resets match, `V` toggles audio.
- **Rules & Mechanics**:
  - Continuous circle-on-circle collision physics with mallet-to-puck momentum transfer, bank shots, and friction decay.
  - Mallets are physically constrained to their respective halves of the table.
  - Goal horn sounds and dynamic particle spark explosions celebrate every scored point.
- **Pro Tip**: Hit the puck while your mallet is actively accelerating forward to execute high-speed bank trick shots off the side rails!

---

### 2. Asteroids Pro (`asteroids/`)
*Vector Inertia Space Dogfight with Asteroid Splitting & Power-Ups*

```bash
v run asteroids
```
![Asteroids Pro](screenshots/asteroids.png)

- **Objective**: Pilot your spacecraft in zero-gravity space, pulverize floating asteroid fields into smaller fragments, eliminate hostile alien UFOs, and survive infinite waves.
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Rotate spacecraft.
  - `W` or `Up`: Fire main inertia thrusters.
  - `Space`: Fire photon laser cannons.
  - `H`: Engage emergency Hyperspace teleportation (random spatial coordinates).
  - `S`: Deploy plasma shield (absorbs 1 collision).
  - `R`: Restart game.
- **Rules & Mechanics**:
  - Asteroids split hierarchically: Large (20 pts) $\to$ 2 Medium (50 pts) $\to$ 2 Small (100 pts) $\to$ Destroyed.
  - Flying Saucers hunt the player and fire targeted laser bursts (200-1,000 pts).
  - Collect floating power-up orbs: **3x Spread Shot**, **Overcharged Shield**, **Rapid-Fire Pulse**, and **EMP Screen Nuke**.
- **Pro Tip**: Keep your spacecraft near the center of the screen and avoid excessive forward thrust momentum to prevent drifting uncontrollably into off-screen asteroid spawns.

---

### 3. NES Balloon Fight (`balloonfight/`)
*1984 Nintendo Flight Classic with Dual Helium Balloon Aerodynamics*

```bash
v run balloonfight
```
![NES Balloon Fight](screenshots/balloonfight.png)

- **Objective**: Flap your arms to gain altitude, swoop down from above to pop enemy balloons, and kick parachuting enemies into the water before they re-inflate!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Steer horizontal flight trajectory.
  - `W` / `Space` / `Up`: Flap wings for vertical lift.
  - `P`: Pause game.
  - `M`: Toggle procedural audio.
  - `R`: Restart game.
- **Rules & Mechanics**:
  - Height Advantage: Colliding with an enemy when you are higher pops their balloon. Colliding when lower pops your own balloon!
  - You have 2 helium balloons. Losing both results in falling into the abyss.
  - **Giant Fish Hazard**: Lingering too close to the water surface triggers the giant carnivorous fish!
  - **Balloon Trip Mode**: Navigate side-scrolling obstacle courses avoiding electrified spark nodes.
- **Pro Tip**: Tap flap rhythmically rather than holding it down to maintain precise altitude control and effortlessly swoop over oncoming birds.

---

### 4. Battleship Pro (`battleship/`)
*10x10 Tactical Naval Warfare with Sonar Radar Sweeps*

```bash
v run battleship
```
![Battleship Pro](screenshots/battleship.png)

- **Objective**: Secretly position your 5-ship naval fleet on a 10x10 grid and hunt down the enemy's hidden warships before they sink yours!
- **Controls**:
  - `Left Click`: Target coordinate grid / Place selected ship.
  - `Right Click` or `R`: Rotate ship horizontally / vertically during placement.
  - `F`: Instant random fleet auto-placement.
  - `Space`: Confirm fleet and start combat phase.
  - `V`: Toggle sound effects.
- **Rules & Mechanics**:
  - 5 Fleet Classes: Aircraft Carrier (5 cells), Battleship (4 cells), Cruiser (3 cells), Submarine (3 cells), Destroyer (2 cells).
  - Red markers indicate **HIT**, White pegs indicate **MISS**. Sunk ships reveal their entire hull.
  - **Radar Recon Scan**: Deploy a 3x3 sonar sweep once per game to reveal any enemy vessels hiding in that sector.
  - Intelligent Hunt-and-Target AI systematically checks adjacent coordinates upon registering a hit.
- **Pro Tip**: Use a checkerboard (parity) firing pattern to locate all ships of length 2 or greater in half the total shots!

---

### 5. Bejeweled Match-3 (`bejeweled/`)
*Cascading Gem Match-3 with Explosive Flame & Hypercube Gems*

```bash
v run bejeweled
```
![Bejeweled Match-3](screenshots/bejeweled.png)

- **Objective**: Swap adjacent gems to form horizontal or vertical lines of 3 or more matching colors to clear them from the board and trigger gravity cascades.
- **Controls**:
  - `Left Click` or `Mouse Drag`: Select and swap adjacent gems.
  - `H`: Highlight a valid legal move hint.
  - `M`: Switch between **Classic Mode** (Score Milestones) and **Time Attack Mode** (60s Blitz).
  - `R`: Reset board.
  - `S`: Toggle sound.
- **Special Power Gems**:
  - **Flame Gem (4-Match)**: Explodes a 3x3 grid area upon being matched, clearing 9 gems at once.
  - **Hypercube (5-Match)**: Swapping with any adjacent gem obliterates every single gem of that color from the entire board!
- **Pro Tip**: Focus your matches near the bottom of the grid to trigger cascading chain reactions that rack up massive multiplier combos automatically.

---

### 6. Bomberman Arcade (`bomberman/`)
*Grid Maze Demolition with Explosive Chain Reactions*

```bash
v run bomberman
```
![Bomberman Arcade](screenshots/bomberman.png)

- **Objective**: Navigate destructible soft brick mazes, plant timed bombs to demolish barriers, uncover hidden power-ups, and eliminate all roaming monsters before reaching the exit!
- **Controls**:
  - `WASD` or `Arrow Keys`: Move Bomberman through grid corridors.
  - `Space`: Plant a timed bomb at your current tile.
  - `P`: Pause game.
  - `R`: Restart game.
  - `M`: Toggle sound.
- **Power-Ups (Demolish Soft Blocks to Find)**:
  - **Bomb Up (Flame +)**: Increases maximum simultaneous bombs placed (+1).
  - **Fire Up (Explosion Icon)**: Increases explosion cross radius by +1 tile.
  - **Speed Skates**: Increases Bomberman's movement speed.
  - **Detonator / Remote Fuse**: Grants remote bomb detonation.
- **Pro Tip**: Never trap yourself in a dead-end alley with your own bomb! Plan your escape route before dropping a bomb.

---

### 7. Boulder Dash Retro (`boulderdash/`)
*Subterranean Cave Excavation with Falling Rocks & Amoeba Core*

```bash
v run boulderdash
```
![Boulder Dash Retro](screenshots/boulderdash.png)

- **Objective**: Dig through dirt caves, collect the required quota of sparkling diamonds, avoid or crush hostile creatures, and escape through the exit vault before the timer expires!
- **Controls**:
  - `WASD` or `Arrow Keys`: Dig dirt, push boulders, and move Rockford.
  - `P` / `N` or `[` / `]`: Select previous/next cave (5 Handcrafted Levels).
  - `R`: Restart current cave.
  - `S`: Toggle sound.
- **Physics & Hazards**:
  - **Boulders & Diamonds**: Obey gravity and roll sideways off rounded edges. Falling rocks will crush enemies and player!
  - **Fireflies**: Patrol walls counter-clockwise; explode into empty space when crushed.
  - **Butterflies**: Patrol walls clockwise; explode into a **3x3 grid of 9 diamonds** when crushed by a boulder!
  - **Amoeba**: Expanding fluid hazard. Enclose it completely to transform it into diamonds!
- **Pro Tip**: Drop a boulder on top of a Butterfly to generate an instant jackpot of 9 diamonds!

---

### 8. Breakout Overdrive (`breakout/`)
*Dynamic Brick Breaker with Paddle Spin Physics & Multi-Weapons*

```bash
v run breakout
```
![Breakout Overdrive](screenshots/breakout.png)

- **Objective**: Deflect the bouncing energy sphere with your paddle to smash all bricks in each level without letting the ball fall past the bottom!
- **Controls**:
  - `Mouse` or `A` / `D` or `Left` / `Right`: Slide paddle.
  - `Space` or `Left Click`: Launch ball from paddle / Fire equipped blaster lasers.
  - `L`: Cycle level selection (5 Distinct Level Layouts).
  - `R`: Restart game.
- **Brick Types & Power-Ups**:
  - **Armored Bricks**: Require multiple hits to shatter.
  - **TNT Bricks**: Detonate surrounding bricks in a fiery chain reaction.
  - **Power-Up Capsules**: Multiball (3x balls), Laser Cannons, Paddle Expander, Sticky Catch, and Slow Ball.
- **Pro Tip**: Hitting the ball with the outer edges of your paddle imparts aggressive spin angles to reach the upper ceiling rows and bounce repeatedly behind brick clusters!

---

### 9. Bubble Shooter Pro (`bubbleshooter/`)
*Hexagonal Match-3 Bubble Popper with Wall Trajectory Reflections*

```bash
v run bubbleshooter
```
![Bubble Shooter Pro](screenshots/bubbleshooter.png)

- **Objective**: Aim and fire colored bubbles from the bottom cannon into the ceiling cluster. Match 3 or more bubbles of the same color to pop them and clear the board before the descending ceiling crushes you!
- **Controls**:
  - `Mouse Aim`: Direct laser aiming trajectory guide.
  - `Left Click` or `Space`: Fire bubble from cannon.
  - `S`: Toggle sound effects.
  - `R`: Restart game.
- **Rules & Mechanics**:
  - **Hexagonal Grid**: Bubbles snap into an interlocking honeycomb structure.
  - **Bank Shots**: Rebound bubbles off the left and right walls to access tight pockets.
  - **Avalanche Drop**: Any bubbles left floating without a connection to the ceiling immediately detach and fall for bonus points!
- **Pro Tip**: Target the high anchor bubbles holding large groups of dissimilar colors to drop dozens of bubbles in a single shot.

---

### 10. Cyber Centipede Pro (`centipede/`)
*Atari Arcade Classic with Segmented Insects & Poison Mushrooms*

```bash
v run centipede
```
![Cyber Centipede Pro](screenshots/centipede.png)

- **Objective**: Defend the enchanted mushroom forest from a multi-segmented Centipede winding down toward your player zone, while fending off Fleas, Spiders, and Scorpions!
- **Controls**:
  - `WASD` or `Arrow Keys`: Move Bug Blaster freely in the bottom player zone.
  - `Space`: Rapid-fire laser bolts.
  - `P`: Pause game.
  - `O`: Toggle sound.
  - `R`: Restart game.
- **Enemies & Hazards**:
  - **Centipede**: Shooting a middle segment splits the centipede into two independent bugs, leaving behind a mushroom!
  - **Spider**: Bounces erratically through the player zone, eating mushrooms.
  - **Flea**: Drops vertically from the top, planting mushrooms in its wake.
  - **Scorpion**: Runs horizontally, poisoning mushrooms (poisoned mushrooms cause centipedes to dive straight down).
- **Pro Tip**: Clear a wide horizontal channel near the bottom to cleanly pick off descending centipedes without mushrooms obstructing your laser shots.

---

### 11. Chimp Test Pro (`chimptest/`)
*Primate Spatial Working Memory Benchmark*

```bash
v run chimptest
```
![Chimp Test Pro](screenshots/chimptest.png)

- **Objective**: Test your working memory capacity against the famous primate cognitive benchmark! Memorize the positions of scattered numbered tiles (1 to N), then click them in ascending numerical order after they mask into blank squares!
- **Controls**:
  - `Left Click`: Select tiles in order (1 $\to$ 2 $\to$ 3 $\to$ ... $\to$ N).
  - `Space`: Advance to next round after completing a level.
  - `R`: Reset test.
- **Rules & Mechanics**:
  - Level 1 begins with 4 numbers. Each successful round adds +1 additional number.
  - The moment you click tile **1**, all remaining numbers on the grid mask into blank white squares.
  - 3 Strikes: You have 3 lives before your final working memory score and cognitive percentile ranking are evaluated.
- **Pro Tip**: Chunk numbers into spatial clusters (e.g., "top-left triangle, bottom-right pair") to hold more than 9 digits in working memory simultaneously!

---

### 12. Chip's Challenge Deluxe (`chipschallenge/`)
*Classic 1989 Windows Entertainment Pack Tile Puzzle Adventure*

```bash
v run chipschallenge
```
![Chip's Challenge Deluxe](screenshots/chipschallenge.png)

- **Objective**: Guide Chip through complex obstacle mazes, collect all required computer microchips on the floor, unlock color-coded security doors with matching keys, and step into the exit portal!
- **Controls**:
  - `WASD` or `Arrow Keys`: Move Chip and push movable dirt/ice blocks.
  - `R`: Restart current level.
  - `N` / `P`: Next / Previous level.
  - `M`: Toggle sound.
- **Special Items & Terrain**:
  - **Keys & Doors**: Red, Blue, Yellow, and Green keys unlock corresponding security doors.
  - **Flipper Boots**: Allows swimming across blue water pools without drowning.
  - **Fire Boots**: Allows walking over red fire pits without burning.
  - **Suction Boots & Ice Skates**: Negate force floors and sliding ice tiles.
- **Pro Tip**: Use movable wooden blocks to bridge water gaps and absorb lethal bomb hazards before stepping through.

---

### 13. Click Arcade (4-in-1) (`clickarcade/`)
*Addictive Casual Mouse-Clicking Mini-Game Suite*

```bash
v run clickarcade
```
![Click Arcade](screenshots/clickarcade.png)

- **Objective**: Enjoy 4 distinct clicking experiences from a single unified arcade terminal:
  1. **Gem Rush Tycoon**: Deep idle clicker with automation upgrades (Pickaxes, Dwarf Miners, Laser Bores, Cosmic Forges), Golden Frenzy rush (7x multiplier), and Celestial Shard Ascension.
  2. **Chain Reaction Pop**: Zero-gravity cascading atomic detonation puzzle. Click once to drop expanding shockwaves that explode colliding atoms into chain combos.
  3. **Whack-A-Boss**: Reflex monster smasher. Whack goblins, speedster gnomes, clock bonuses (+6s), avoid skull bombs, and crush armored bosses.
  4. **Blade Slicer**: Fluid mouse-swiping blade ninja slicer. Slash flying fruit and star gems in mid-air with sword trails and combo multipliers.
- **Controls**:
  - `Left Click` / `Mouse Drag`: All in-game clicking and slicing actions.
  - `Esc`: Return to Main Menu.
  - `M`: Toggle audio.

---

### 14. Connect 4 (`connect4/`)
*Classic 7x6 Disc-Dropping Strategy with Minimax Alpha-Beta AI*

```bash
v run connect4
```
![Connect 4](screenshots/connect4.png)

- **Objective**: Take turns dropping colored discs into a 7-column vertical grid. Be the first player to connect 4 discs in a row horizontally, vertically, or diagonally!
- **Controls**:
  - `Left` / `Right` or `Mouse Hover`: Select target column.
  - `Space` / `Enter` or `Left Click`: Drop disc into column.
  - `U`: Undo last move.
  - `M`: Toggle 1P (vs AI) or 2P (Local Pass-and-Play) mode.
  - `D`: Cycle AI difficulty (Easy, Medium, Grandmaster).
  - `R`: Reset board.
- **Pro Tip**: Control the center column (Column 4) from the start — every horizontal and diagonal 4-in-a-row connection passes through the center column more often than any other!

---

### 15. Neon Vector Run 3D (`cyberrunner/`)
*High-Speed 3D Highway Runner Powered by Apple Silicon Metal*

```bash
v run cyberrunner
```
![Neon Vector Run 3D](screenshots/cyberrunner.png)

- **Objective**: Pilot a glowing 3D vector hovercraft down an infinite cybernetic highway, weave between obstacles, vault over road hazards, collect energy cubes, and survive hyper-speed velocities!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Steer hovercraft across highway lanes.
  - `Space` or `W` / `Up`: Jump over floor barriers.
  - `Shift` or `S` / `Down`: Engage hyper turbo boost.
  - `P`: Pause game.
  - `R`: Restart run.
  - `M`: Toggle sound.
- **Scoring & Combos**:
  - **Near-Miss System**: Grazing obstacles within inches without colliding awards massive Near-Miss combo multiplier points!
  - Thruster energy refills by collecting glowing cyan cubes scattered across the track.
- **Pro Tip**: Use short hops rather than holding jump to land quickly and maintain precise lateral lane control between rapid obstacle waves.

---

### 16. Dig Dug Classic (`digdug/`)
*1982 Namco Underground Monster Infiltration Classic*

```bash
v run digdug
```
![Dig Dug Classic](screenshots/digdug.png)

- **Objective**: Dig subterranean tunnels throughout the dirt, pump up underground monsters (Pookas and Fygars) with your air pump until they pop, or crush them under falling boulders!
- **Controls**:
  - `WASD` or `Arrow Keys`: Dig tunnels and move Dig Dug.
  - `Space`: Fire harpoon air hose / Rapidly pump to inflate enemies until they pop.
  - `P`: Pause game.
  - `R`: Restart game.
  - `M`: Toggle sound.
- **Enemies & Environmental Hazards**:
  - **Pookas**: Red round goggles monsters that turn into ghosts to float through solid dirt.
  - **Fygars**: Green fire-breathing dragons that periodically breathe lethal horizontal flame jets through dirt tunnels!
  - **Falling Rocks**: Tunnel underneath a rock to loosen it. Move out of the way before it drops to crush pursuing enemies beneath it!
- **Pro Tip**: Lure a cluster of 3 or more monsters into a vertical tunnel directly under a boulder, then dig out the last block to crush the entire group for massive bonus points!

---

### 17. Donkey Kong Arcade (`donkeykong/`)
*1981 Nintendo Girder Climbing & Barrel Jumping Platformer*

```bash
v run donkeykong
```
![Donkey Kong Arcade](screenshots/donkeykong.png)

- **Objective**: Guide Jumpman up steel construction girders, leap over rolling wooden barrels, scale ladders, grab the power hammer, and rescue Pauline at the top platform!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Run left and right.
  - `W` / `S` or `Up` / `Down`: Climb up and down ladders.
  - `Space`: Jump over rolling barrels and fireballs.
  - `P`: Pause game.
  - `R`: Restart game.
  - `M`: Toggle sound.
- **Rules & Hazards**:
  - Jumping over rolling barrels awards **+100 pts** (or +300 pts for jumping 2 barrels at once).
  - **Power Hammer**: Grabbing the hammer allows you to smash incoming barrels and flaming oil fireballs for 10 seconds (you cannot jump or climb ladders while wielding the hammer).
  - Falling from heights greater than 1 platform level results in losing a life.
- **Pro Tip**: Do not linger on ladders when barrels roll overhead — Jumpman can only dodge barrels with timed jumps on flat girder platforms.

---

### 18. Dope Wars 1990 (`dopewars/`)
*Turn-Based NYC Economic Strategy Classic*

```bash
v run dopewars
```
![Dope Wars 1990](screenshots/dopewars.png)

- **Objective**: Start with $2,000 in cash and $5,500 in debt to the ruthless Loan Shark. Buy low and sell high across 6 NYC boroughs over 30 days to pay off your debt and amass a multi-million dollar fortune!
- **Controls**:
  - `1-8`: Select commodity from market list.
  - `B`: Buy commodity (specify quantity).
  - `S`: Sell commodity.
  - `T`: Take the NYC Subway to travel to another borough (advances 1 day).
  - `K`: Visit the 1st National Bank of NYC (5% daily deposit interest).
  - `L`: Visit the Loan Shark (10% daily compounding debt interest).
  - `M`: Toggle audio.
- **6 Boroughs**: Manhattan, The Bronx, Brooklyn, Queens, Staten Island, and Coney Island.
- **Random Events**: Police chases by Officer Bob (Fight / Run / Bribe), DEA raids, and drug bust shortages that skyrocket prices (e.g., "Cops make huge Weed bust! Prices are outrageous!").
- **Pro Tip**: Pay off your loan shark debt completely within the first 7 days to stop interest from draining your profits!

---

### 19. Duke Nukem: Cyber Outpost (`duke/`)
*1991 Apogee Cyberpunk Side-Scrolling Platformer*

```bash
v run duke
```
- **Sector 1 (Night City)**:
![Sector 1](screenshots/duke.png)
- **Sector 2 (Subterranean Reactor Core)**:
![Sector 2](screenshots/duke_sector2.png)
- **Sector 3 (Orbital Fortress & Mega Boss)**:
![Sector 3](screenshots/duke_sector3.png)

- **Objective**: Fight through 3 sprawling dystopian sectors, eliminate Robodroid armies and automated turrets, find color-coded security keycards, unlock blast doors, and destroy the Orbital Mega Mech Boss!
- **Controls**:
  - `A` / `D`: Run left and right.
  - `W`: Aim weapon up / Climb ladders and overhead pipes.
  - `S`: Crouch / Climb down.
  - `Space`: Somersault jump.
  - `Ctrl` / `J` / `F`: Fire equipped weapon.
  - `R`: Restart sector.
- **Weapons & Equipment**:
  - **Blaster**: Standard infinite plasma firearm.
  - **Dual Laser**: Twin high-velocity piercing beam.
  - **Flamethrower**: Short-range area of effect fire blast.
  - **Missile Launcher**: Long-range explosive armor-piercing rockets.
- **Pro Tip**: Shoot supply crates and security cameras to uncover hidden soda cans (health recovery) and access keycards.

---

### 20. Etch A Sketch Deluxe (`etchasketch/`)
*Mechanical Drawing Studio with Spirograph & Symmetry CAD*

```bash
v run etchasketch
```
![Etch A Sketch Deluxe](screenshots/etchasketch.png)

- **Objective**: Create intricate line art drawings with dual rotary knob mechanics, or explore advanced mathematical drawing studios including Spirograph gear engines and 4-way kaleidoscope symmetry!
- **Controls**:
  - `WASD` / `Arrow Keys` or `Mouse Drag`: Turn left/right and up/down stylus knobs.
  - `Space`: Shake the screen to erase the aluminum powder!
  - `1-4`: Switch modes (**1: Freehand Etch**, **2: Spirograph Studio**, **3: Stencil Academy**, **4: 4-Way Symmetry CAD**).
  - `Tab`: Cycle stencils / Spirograph gear ratios.
  - `C`: Change bezel and screen color themes.
  - `R`: Replay time-lapse recording of your drawing stroke-by-stroke!

---

### 21. Flappy Bird Pro (`flappy/`)
*Precision Tap-to-Flap Physics Arcade with Parallax City Skyline*

```bash
v run flappy
```
![Flappy Bird Pro](screenshots/flappy.png)

- **Objective**: Tap to flap your bird's wings and navigate through gaps between vertical green pipes without touching the pipes or the ground!
- **Controls**:
  - `Space` / `Up` / `Left Click`: Flap wings for upward aerodynamic lift.
  - `S`: Toggle sound effects.
  - `R`: Restart run.
- **Rules & Scoring**:
  - Passing through each pipe pair awards **+1 point**.
  - Medal Trophies: Bronze (10 pts), Silver (20 pts), Gold (30 pts), Platinum (40+ pts).
  - Features real-time pitch rotation physics (tilts up when flapping, dives downward when falling).
- **Pro Tip**: Establish a steady rhythm of short, gentle taps rather than waiting until the bird falls too low.

---

### 22. Frogger Arcade (`frogger/`)
*1981 Konami Road & River Crossing Arcade Legend*

```bash
v run frogger
```
![Frogger Arcade](screenshots/frogger.png)

- **Objective**: Guide 5 frogs from the bottom safety zone across a high-speed multi-lane traffic highway and a treacherous rushing river into 5 empty lily pad home bays!
- **Controls**:
  - `WASD` or `Arrow Keys`: Hop 1 grid unit (Up, Down, Left, Right).
  - `P`: Pause game.
  - `R`: Restart game.
  - `M`: Toggle sound.
- **Hazards & Scoring**:
  - **Highway**: Dodge cars, trucks, bulldozers, and speeding race cars.
  - **River**: Ride on the backs of floating logs and turtles. Beware of diving turtles that submerge underwater!
  - **River Hazards**: Snapping crocodiles and floating otters. Catch bonus ladybugs in home bays for **+200 pts**!
- **Pro Tip**: Time your river leaps so you land on the front of a floating log, giving you ample time to prepare your jump into the next row.

---

### 23. Galaga Space Shooter (`galaga/`)
*1981 Namco Fixed Wave Space Shooter with Dual Ship Fighter Mechanics*

```bash
v run galaga
```
![Galaga Space Shooter](screenshots/galaga.png)

- **Objective**: Blast through swarms of insect-like alien armadas that fly in formation loops before entering attack dive-bombs!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Slide fighter left and right along the bottom.
  - `Space`: Fire twin photon torpedoes.
  - `P`: Pause game.
  - `R`: Restart game.
  - `M`: Toggle sound.
- **Boss Galaga Tractor Beam**:
  - Boss Galagas emit blue tractor beams. If your ship gets captured, destroy the Boss Galaga during its dive-bomb run to free your captured fighter and create a **Dual Ship Fighter** with double firepower!
- **Challenging Stages**: Every 3rd wave is a bonus target practice stage where 40 aliens fly across the screen without firing. Destroy all 40 for a **10,000 pt Perfect Bonus**!
- **Pro Tip**: Allow a Boss Galaga to capture your ship on Wave 1 so you can unlock the Dual Fighter on Wave 2 to double your fire output for the rest of the game!

---

### 24. 2048 Neon Pulse (`game2048/`)
*Cyberpunk Sliding Number Merge Sensation*

```bash
v run game2048
```
![2048 Neon Pulse](screenshots/game2048.png)

- **Objective**: Slide numbered tiles across a 4x4 grid. When two tiles with the same number collide, they merge into one tile with double the value. Build your way up to the coveted **2048** tile!
- **Controls**:
  - `WASD` / `Arrow Keys` or `Mouse Drag`: Slide all tiles across the grid.
  - `U`: Undo last slide.
  - `Space`: Continue playing in Endless Mode after reaching 2048.
  - `R`: Restart game.
  - `S`: Toggle sound.
- **Musical Chimes**: Merging tiles triggers harmonic pentatonic notes that scale in pitch as tile values increase from 2 to 4096+.
- **Pro Tip**: Keep your highest-value tile locked in one fixed corner (e.g., bottom-right) and build descending numerical snakes along that edge.

---

### 25. GNUjump Tower (`gnujump/`)
*Vertical Tower Platform Jumper with Rising Lava*

```bash
v run gnujump
```
![GNUjump Tower](screenshots/gnujump.png)

- **Objective**: Jump upward from platform to platform as high as you can while escaping rising lethal boiling lava below!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Steer horizontal jump momentum.
  - `Space` / `W` / `Up`: High jump leap.
  - `M`: Toggle 1P Solo / 2P Local Co-op mode.
  - `R`: Restart game.
  - `O`: Toggle sound.
- **Platform Types**:
  - **Standard**: Solid stable platforms.
  - **Ice**: High-slip low-friction surfaces.
  - **Spring**: Launches the player high into the air upon contact.
  - **Crumbly**: Disintegrates 1 second after being stepped on.
- **Pro Tip**: Execute combo jumps by landing on platforms that are off-screen above to zoom the camera upward and earn combo multipliers!

---

### 26. Gold Miner Classic (`goldminer/`)
*Underground Winch & Reel Arcade with Dynamite Blasting*

```bash
v run goldminer
```
![Gold Miner Classic](screenshots/goldminer.png)

- **Objective**: Time the release of your oscillating pendulum claw to grab high-value gold nuggets, sparkling diamonds, and mystery bags to reach each stage's cash target before time runs out!
- **Controls**:
  - `Down` / `Space` / `Left Click`: Drop claw down into the earth.
  - `Up` / `W`: Throw a stick of dynamite to blow up heavy low-value rocks currently being reeled in.
  - `S`: Toggle sound.
  - `R`: Restart game.
- **Items & Weights**:
  - **Small/Large Gold**: High cash value ($50 - $500), fast to medium reel speed.
  - **Diamonds**: Extremely valuable ($600), fast reel speed.
  - **Rocks**: Heavy, slow reel speed, low value ($10 - $20).
  - **TNT Barrels**: Explode when touched by claw, destroying adjacent items.
  - **Mystery Bags**: Award random bonuses (cash, strength boost, or a stick of dynamite).
- **Pro Tip**: Purchase Dynamite and Strength Drink from the between-levels shop to reel in heavy gold at lightning speed.

---

### 27. JezzBall Pro (`jezzball/`)
*1992 Windows Entertainment Pack Kinetic Energy Containment Puzzle*

```bash
v run jezzball
```
![JezzBall Pro](screenshots/jezzball.png)

- **Objective**: Build horizontal and vertical laser barrier walls across the arena to isolate bouncing kinetic energy atoms and trap them into compartments until **75% or more** of the playfield is cleared!
- **Controls**:
  - `Left Click`: Start constructing a laser wall at cursor position.
  - `Right Click` or `Space`: Toggle wall orientation between **Horizontal** and **Vertical**.
  - `R`: Restart level.
- **Rules & Lives**:
  - Walls grow outward in two directions from where you clicked.
  - If a bouncing atom strikes an expanding wall before it finishes connecting with both boundary edges, the wall shatters and you lose **1 Life**!
- **Pro Tip**: Wait for balls to drift apart into opposite corners before laying a wall right between them to safely slice the arena in half.

---

### 28. Lemmings Master (`lemmings/`)
*1991 DMA Design Lemming Colony Strategy Puzzle*

```bash
v run lemmings
```
![Lemmings Master](screenshots/lemmings.png)

- **Objective**: Guide mindless marching lemmings safely from the entry trapdoor across lethal drops, pits, and traps to the home exit portal by assigning them specialized jobs!
- **Controls**:
  - `Mouse Click`: Select skill from bottom toolbar / Assign skill to hovered lemming.
  - `F`: Toggle Fast-Forward speed.
  - `P`: Pause game.
  - `Space`: Armageddon Nuke countdown (detonates all active lemmings).
- **8 Assignable Skills**:
  1. **Climber**: Scales vertical cliffs.
  2. **Floater**: Deploys an umbrella to survive high falls.
  3. **Bomber**: 5-second countdown self-sacrifice that blasts through terrain.
  4. **Blocker**: Stands firmly in place to turn other lemmings around.
  5. **Builder**: Constructs a 12-step diagonal staircase.
  6. **Basher**: Digs a horizontal tunnel through dirt walls.
  7. **Miner**: Excavates a diagonal tunnel downward.
  8. **Digger**: Drills a vertical shaft straight down.
- **Pro Tip**: Use a Blocker to contain the crowd in a safe zone while a single Climber/Builder lemming paves the way to the exit portal!

---

### 29. Liar's Dice Deluxe (`liarsdice/`)
*Pirate Bluffing & Bidding Dice Party Game (Perudo / Dudo)*

```bash
v run liarsdice
```
![Liar's Dice Deluxe](screenshots/liarsdice.png)

- **Objective**: Roll 5 dice under your cup, bid on the total number of dice showing a specific face across the entire table, bluff your opponents, and challenge inaccurate claims!
- **Controls**:
  - `Space`: Place bid / Advance round.
  - `L`: Call **"Liar!"** (Dudo) on the previous player's bid.
  - `C`: Call **"Spot On!"** (Calza) claiming the exact dice count.
  - `Up` / `Down`: Increase/decrease bid quantity.
  - `Left` / `Right` or `1-6`: Select dice face value.
  - `M`: Toggle 1P (vs 3 Pirate Bots) / 2P Local Pass-and-Play.
  - `S`: Toggle sound.
- **Rules**:
  - Bids must always increase in either quantity (e.g., four 3s $\to$ five 3s) or face value (e.g., four 3s $\to$ four 5s).
  - **Wild 1s (Aces)**: 1s count as wild and match any face value unless someone bids 1s directly.
  - Calling "Liar!" lifts all cups around the table. If the bid was false, the bidder loses a die; if true, the challenger loses a die!
- **Pro Tip**: Watch how often AI pirates bid on faces they don't have — if a bot jumps bid quantities aggressively, they are likely bluffing!

---

### 30. Tron Light Cycles (`lightcycles/`)
*High-Speed Grid Arena Cyber Racing leaving Solid Neon Light Ribbon Walls*

```bash
v run lightcycles
```
![Tron Light Cycles](screenshots/lightcycles.png)

- **Objective**: Pilot a cyber light cycle leaving an impassable solid neon light ribbon wall behind you. Force your opponent to crash into arena boundaries, trail ribbons, or their own tail!
- **Controls**:
  - **Player 1 (Cyan)**: `WASD` or `Arrow Keys` to steer, `Space` for Turbo Boost.
  - **Player 2 (Orange)**: `IJKL` to steer, `Right Shift` for Turbo Boost.
  - **Options**: `M` toggles 1P vs AI / 2P Local, `D` cycles AI difficulty (Easy, Medium, Master), `R` restarts round.
- **Mechanics**:
  - Any collision with the outer perimeter walls or light trails causes instantaneous cycle explosion.
  - Turbo Boost temporarily doubles your velocity to cut off opponents before they can turn.
- **Pro Tip**: Box in your opponent against the perimeter wall by boxing them into an ever-shrinking spiral rectangle!

---

### 31. Adventures of Lolo (`lolo/`)
*NES Puzzle Legend with 11x11 Grid Physics & Level Designer*

```bash
v run lolo
```
![Adventures of Lolo](screenshots/lolo.png)

- **Objective**: Collect all Heart Framers scattered across the room to unlock the Jewel Chest, pick up the Magic Gem, and open the exit door to advance to the next floor!
- **Controls**:
  - `WASD` or `Arrow Keys`: Move Lolo and push Emerald Framer blocks.
  - `Space`: Fire Magic Egg shot (encases enemies into rolling eggs for 10 seconds).
  - `Tab`: Open interactive **Level Designer Studio**!
  - `R`: Reset current room.
  - `S`: Toggle sound.
- **Hazards & Monsters**:
  - **Medusa**: Instantly fires lethal line-of-sight laser beams if Lolo steps in front of her. Push Emerald blocks in front of Medusa to block her vision!
  - **Snakey**: Harmless passive serpents that can be turned into eggs and pushed into water to serve as rafts.
  - **Gol & Alma**: Fireballs and charging rolling armadillos.
- **Pro Tip**: You can push an enemy encased in an egg into water and ride it across streams to access isolated islands before the egg sinks!

---

### 32. Lunar Lander Simulator (`lunarlander/`)
*1979 Atari Vector Lunar Descent Simulation*

```bash
v run lunarlander
```
![Lunar Lander Simulator](screenshots/lunarlander.png)

- **Objective**: Pilot the Lunar Module (LEM) across a jagged mountainous moon terrain, manage limited fuel reserves, and execute a soft touchdown on designated landing pads!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Rotate spacecraft attitude thrusters.
  - `W` / `Up` / `Space`: Fire main rocket thruster.
  - `P`: Pause simulation.
  - `R`: Restart flight.
  - `M`: Toggle sound.
- **Touchdown Conditions**:
  - **Landing Angle**: Must be within $\pm 5^\circ$ of vertical.
  - **Descent Velocity**: Vertical speed must be below safe touchdown threshold ($V_y \le 2.0\text{ m/s}$).
  - **Lateral Speed**: Horizontal speed must be near zero ($V_x \le 1.0\text{ m/s}$).
  - Landing on narrow mountain pads awards **2x, 3x, or 5x score multipliers**!
- **Pro Tip**: Use short feathering burns of the main thruster on final approach rather than continuous burns to conserve precious fuel.

---

### 33. Mappy Arcade (`mappy/`)
*1983 Namco Police Mouse Platformer with Trampolines & Microwave Doors*

```bash
v run mappy
```
![Mappy Arcade](screenshots/mappy.png)

- **Objective**: Bounce across trampoline shafts, run through a 6-floor mansion, retrieve stolen goods (Radios, TVs, Safes), stun pursuing cats with swinging doors, and clear all loot!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Steer in mid-air / Dismount trampoline onto adjacent floor.
  - `Space` / `W` / `Up`: Open doors / Fire microwave shockwaves.
  - `1-4`: Select difficulty (Cadet, Officer, Detective, Mania).
  - `5` / `B`: Bonus Balloon Stage.
  - `P`: Pause game.
  - `M`: Toggle sound.
- **Trampolines & Safety**:
  - While bouncing on trampolines, Mappy is invulnerable and passes through cats safely!
  - Trampoline ropes degrade on each consecutive bounce (Green $\to$ Blue $\to$ Yellow $\to$ Red $\to$ Snaps!). Land on a floor to reset the trampoline to Green.
- **Loot Multipliers**:
  - Stolen loot items come in identical pairs. Collecting two of the same item consecutively multiplies points by **2x, 3x, 4x, 5x, 6x**!
- **Pro Tip**: Open Microwave Super Doors when several cats are chasing behind to sweep the entire pack off-screen in a single ultrasonic wave!

---

### 34. Memory Match Pro (`memorymatch/`)
*Card-Flipping Spatial Pair Recall with 3D Animations*

```bash
v run memorymatch
```
![Memory Match Pro](screenshots/memorymatch.png)

- **Objective**: Flip over pairs of face-down cards to match identical geometric symbols (Gems, Crowns, Stars, Keys, Potions, Atoms, Shields, Rockets) and clear the entire board in the fewest moves and fastest time!
- **Controls**:
  - `Left Click`: Flip card face-up.
  - `G`: Cycle grid dimensions (**4x4 (16 cards)**, **6x4 (24 cards)**, **6x6 (36 cards)**).
  - `R`: Deal new shuffled deck.
  - `S`: Toggle sound.
- **Combos & Rating**:
  - Making consecutive pair matches builds up a **Combo Multiplier** that multiplies your round score!
  - 3-Star Rating awarded based on accuracy percentage and completion time.
- **Pro Tip**: When you flip an unmatched card, mentally anchor its position relative to nearby cards so you can immediately claim the match when its pair is revealed.

---

### 35. Micro Mayhem (`micromayhem/`)
*High-Speed 4-Second Micro-Game Party Gauntlet*

```bash
v run micromayhem
```
![Micro Mayhem](screenshots/micromayhem.png)

- **Objective**: Survive a nonstop marathon of rapid 4-second micro-challenges that test split-second reflexes, memory, and timing!
- **8 Rapid Mini-Games**:
  1. **Defuse the Bomb**: Cut the requested colored wire (`1-3`) before the fuse detonates!
  2. **Catch the Gem**: Slide the basket (`A`/`D` or Mouse) to catch falling crystals.
  3. **Dodge the Laser**: Step into the safe lane (`A`/`D`) before the orbital death beam discharges.
  4. **Arm Wrestle Mash**: Rapidly mash `Space` to overpower your opponent's gauge.
  5. **Stop the Needle**: Tap `Space` to freeze the oscillating needle in the green sweet spot.
  6. **Unicycle Balance**: Physics balance steering (`Left`/`Right`) to stay upright against gravity.
  7. **Pattern Match**: Memorize and repeat 3-color sequence inputs (`1-3`).
  8. **Pop the Targets**: Swiftly click or press keys to pop all floating balloons.
- **Controls**:
  - `Space` / `1-3` / `WASD` / `Arrow Keys` / `Mouse` per micro-game instruction prompt.
  - `R`: Restart gauntlet.
  - `V`: Toggle sound.
- **Speed Multiplier**: Every 5 cleared micro-games increases the game BPM, giving you less time to react!

---

### 36. Minesweeper Pro (`minesweeper/`)
*Classic Minefield Deduction with Guaranteed First-Click Safety*

```bash
v run minesweeper
```
![Minesweeper Pro](screenshots/minesweeper.png)

- **Objective**: Uncover all safe tiles on the grid without detonating any hidden landmines!
- **Controls**:
  - `Left Click` or `Space`: Reveal selected tile.
  - `Right Click` or `F`: Place / Remove warning flag on suspected mine.
  - `Left + Right Click` or `Double Click` on a revealed number: **Chord** (automatically reveals all surrounding unflagged tiles if neighbor flag count matches the number).
  - `1-3`: Change difficulty preset (**1: Beginner 9x9**, **2: Intermediate 16x16**, **3: Expert 30x16**).
  - `T`: Cycle visual themes (Classic Gray, Cyberpunk Neon, Emerald Mint).
  - `R`: Start new game / Click smiley face.
- **Pro Tip**: Use chording constantly to clear large clusters of numbers with a single click and shave seconds off your best time records.

---

### 37. Missile Command Air Defense (`missilecommand/`)
*1980 Atari Anti-Ballistic Defense with Destructible Cities*

```bash
v run missilecommand
```
![Missile Command Air Defense](screenshots/missilecommand.png)

- **Objective**: Defend 6 coastal cities and 3 anti-missile launch batteries from relentless waves of descending nuclear ICBM warheads, MIRV splitters, and enemy bomber jets!
- **Controls**:
  - `Mouse Move`: Aim crosshair targeting reticle.
  - `Left Click` or `Space`: Fire interceptor missile from battery to detonate an expanding flak explosion at cursor position.
  - `P`: Pause game.
  - `R`: Restart game.
  - `M`: Toggle sound.
- **Detonation Mechanics**:
  - Interceptor missiles travel to the target point and detonate into an expanding sphere of flak.
  - Any descending warhead that touches an active flak cloud is vaporized, setting off secondary chain reaction explosions!
- **Pro Tip**: Lead descending missiles by aiming ahead of their trajectory so they fly directly into the center of your expanding flak clouds.

---

### 38. Pac-Man Arcade (`pacman/`)
*1980 Namco Maze Classic with 4 Ghost AIs & Power Pellets*

```bash
v run pacman
```
![Pac-Man Arcade](screenshots/pacman.png)

- **Objective**: Guide Pac-Man through the maze, eat all 244 dots and 4 Power Pellets, avoid the 4 ghosts, and clear each stage!
- **Controls**:
  - `WASD` or `Arrow Keys`: Steer Pac-Man at maze intersections.
  - `P`: Pause game.
  - `R`: Restart game.
  - `S`: Toggle sound.
- **4 Ghost Personalities**:
  - **Blinky (Red)**: The aggressive shadow chaser; pursues Pac-Man's exact coordinates.
  - **Pinky (Pink)**: Ambusher; aims for 4 tiles ahead of Pac-Man's direction.
  - **Inky (Cyan)**: Fickle flanker; calculates trajectory based on Blinky and Pac-Man.
  - **Clyde (Orange)**: Cowardly; chases when far away, retreats to corner when near.
- **Power Pellets**: Eating a Power Pellet turns all ghosts blue for 8 seconds. Chomp blue ghosts for **+200, +400, +800, +1600 pts**!
- **Pro Tip**: Use the side escape tunnels — Pac-Man travels through side tunnels at full speed while ghosts are slowed down to half speed!

---

### 39. Peggle Extreme (`peggle/`)
*Pachinko Peg-Popping Physics Arcade with Extreme Fever Finale*

```bash
v run peggle
```
![Peggle Extreme](screenshots/peggle.png)

- **Objective**: Aim the top ball cannon, shoot metal spheres into the peg board, clear all **25 Orange Goal Pegs**, and trigger the grand **Extreme Fever** finale!
- **Controls**:
  - `Mouse Aim` or `Left` / `Right`: Aim ball cannon angle.
  - `Left Click` or `Space`: Fire ball into the peg field.
  - `M`: Toggle audio.
  - `R`: Restart game.
- **Peg Types & Power-Ups**:
  - **Orange Pegs**: Goal targets (clear all 25 to achieve Extreme Fever).
  - **Blue Pegs**: Score pegs.
  - **Purple Pegs**: Bonus score multiplier pegs.
  - **Green Pegs**: Activates Multi-Ball power-up (splits into 2 active balls).
- **Moving Catcher Bucket**:
  - A bucket slides continuously along the bottom. If a falling ball lands inside the bucket, you earn **+1 FREE BALL**!
- **Extreme Fever**: Triggering Fever awards massive end-stage score bins (10k to 100k pts) with procedural *Ode to Joy* orchestral fanfare!
- **Pro Tip**: Time your shots so the falling ball lines up with the moving catcher bucket at the bottom to never run out of balls!

---

### 40. Picross Pro (`picross/`)
*Classic Nonogram Logic Grid Puzzle with Pixel Art Masterpieces*

```bash
v run picross
```
![Picross Pro](screenshots/picross.png)

- **Objective**: Use the numerical clues along the rows and columns to deduce which grid cells to fill and which to mark with an X to reveal hidden pixel art images!
- **Controls**:
  - `Left Click` or `Space` / `Z`: Fill selected tile.
  - `Right Click` or `X` / `F`: Mark tile with an **X** cross.
  - `H`: Reveal a hint.
  - `M`: Toggle **Zen Logic Mode** (Freeform) or **Strikes Mode** (3 Mistakes Limit).
  - `P` / `N` or `[` / `]`: Select puzzle (10+ Handcrafted Puzzles: Heart, Duck, Ghost, Sword, Mushroom, Skull, etc.).
  - `C`: Clear board.
  - `S`: Toggle sound.
- **Deduction Rule**: A clue of `3 2` means there is a group of 3 filled cells followed by at least 1 empty cell, followed by a group of 2 filled cells.
- **Pro Tip**: Cross out empty spaces with `Right Click` as soon as a row or column clue is satisfied to immediately reveal intersections for adjacent perpendicular lines!

---

### 41. NES Pinball (`pinball/`)
*1984 Nintendo Arcade Pinball with Mario Bonus Sub-Stage*

```bash
v run pinball
```
![NES Pinball](screenshots/pinball.png)

- **Objective**: Launch the silver ball onto a vertically scrolling two-tier pinball table, rack up bumper points with flippers, enter the hole to reach Mario's sub-stage, and rescue Pauline!
- **Controls**:
  - `Z` / `Left Arrow`: Left Flipper.
  - `X` / `Right Arrow`: Right Flipper.
  - `Space` / `Down Arrow`: Pull back & release spring plunger.
  - `T`: Tilt table (nudge ball trajectory — beware of tilt penalty!).
  - `S`: Toggle sound.
  - `R`: Restart game.
- **Mario Bonus Sub-Stage**:
  - Landing the ball in the bonus sinkhole transports you to a breakout mini-game where Mario controls a sliding platform to bounce the ball, destroy ceiling blocks, and safely catch Pauline as she falls!
- **Pro Tip**: Trap the ball on a raised flipper to stop its momentum and line up precision shots at the upper ramp multipliers.

---

### 42. Hyper Pong (`pong/`)
*2D Arcade Paddle Table Rally with Motion Blur & Spin Physics*

```bash
v run pong
```
![Hyper Pong](screenshots/pong.png)

- **Objective**: Rally the bouncing ball past your opponent's paddle to score points. First player to reach the winning score wins!
- **Controls**:
  - **Player 1 (Left)**: `W` / `S` to move paddle up and down.
  - **Player 2 (Right)**: `Up` / `Down` arrow keys.
  - **Options**: `M` toggles 1P vs Adaptive AI / 2P Local mode, `R` resets match.
- **Ball Velocity & Angle**:
  - Each successful paddle deflection increases the ball's speed.
  - Striking the ball while the paddle is moving imparts spin, creating sharp deflection angles that catch opponents off guard.
- **Pro Tip**: Move your paddle at the exact moment of ball contact to hit sharp angled slice shots into the opposing corners.

---

### 43. Puyo Puyo Cascade (`puyopuyo/`)
*Japanese Match-4 Jelly Blob Drop with Gravity Chain Combos*

```bash
v run puyopuyo
```
![Puyo Puyo Cascade](screenshots/puyopuyo.png)

- **Objective**: Drop pairs of colored jelly Puyos into the matrix. Connect 4 or more Puyos of the same color in any orthogonal direction to pop them, triggering gravity cascades and combo multipliers!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Move falling Puyo pair left and right.
  - `W` / `Up` / `Z`: Rotate pair Clockwise.
  - `X`: Rotate pair Counter-Clockwise.
  - `S` / `Down`: Soft drop.
  - `Space`: Hard drop (instantly locks pair).
  - `M`: Toggle audio.
  - `R`: Restart game.
- **Cascading Chain Combos**:
  - Clearing Puyos allows unsupported Puyos above to fall. Setting up multi-tier staircases creates cascading 2-Chain, 3-Chain, and 4-Chain combos that yield astronomical scores!
- **Pro Tip**: Build diagonal "staircase" formations of 3 Puyos each so when the lowest group pops, the upper Puyos drop precisely to complete the next 4-match!

---

### 44. Q*bert Isometric (`qbert/`)
*1982 2.5D Isometric Pyramid Hopper with Coily Snake Chase AI*

```bash
v run qbert
```
![Q*bert Isometric](screenshots/qbert.png)

- **Objective**: Hop Q\*bert diagonally across a 28-cube 2.5D pyramid to change the top face of every cube to the target color, while dodging purple snakes and bouncing balls!
- **Controls**:
  - `Q` / `E` / `A` / `D` or `Numpad 7/9/1/3` or `Arrow Keys`: Hop diagonally across cubes (Up-Left, Up-Right, Down-Left, Down-Right).
  - `S`: Toggle sound.
  - `R`: Restart game.
- **Hazards & Flying Discs**:
  - **Coily (Purple Snake)**: Hatches from a bouncing purple egg and relentlessly pursues Q\*bert across the pyramid.
  - **Flying Escape Discs**: Hop onto floating discs on the edge of the pyramid to fly Q\*bert safely back to the top peak, luring Coily off the cliff to his doom!
  - **Red Balls**: Bouncing hazards that fall from the top of the pyramid.
- **Pro Tip**: Lead Coily toward an edge where an escape disc is hovering, then hop onto the disc at the last second to trick Coily into leaping off the edge!

---

### 45. Cyber Drift Racer (`racer/`)
*Top-Down 2D Racing with Tire Friction & Skid Mark Physics*

```bash
v run racer
```
![Cyber Drift Racer](screenshots/racer.png)

- **Objective**: Pilot a high-performance cyber race car around winding asphalt circuits, master slip-angle drift physics, out-maneuver AI rival racers, and set record lap times!
- **Controls**:
  - `W` / `S` or `Up` / `Down`: Throttle acceleration and brakes / reverse.
  - `A` / `D` or `Left` / `Right`: Steer wheels.
  - `Space`: Handbrake (initiates high-angle power slide drift).
  - `R`: Reset car onto track.
- **Surface Friction Dynamics**:
  - **Asphalt**: High grip, optimal for high-speed cornering.
  - **Grass / Off-Track**: High drag deceleration.
  - **Oil Slicks**: Zero friction — triggers instant spin-outs!
- **Pro Tip**: Tap the Handbrake (`Space`) just as you enter a turn while keeping the throttle held down to initiate a sustained controlled power drift.

---

### 46. Ragdoll Physics Sandbox (`ragdoll/`)
*2D Verlet Physics Playground with Skeletal Interactive Tools*

```bash
v run ragdoll
```
![Ragdoll Physics](screenshots/ragdoll.png)

- **Objective**: Experiment with realistic skeletal Verlet ragdoll physics across 3 interactive sandbox arenas using an array of creative manipulation tools!
- **Controls**:
  - `Mouse Drag`: Grab and fling ragdoll limbs and torso joints with spring tension.
  - `1-3`: Switch arenas (**1: Obstacle Gym**, **2: Zero-G Space Lab**, **3: Pinball Plinko Arena**).
  - `G`: Invert / Toggle gravity direction.
  - `Q`: Gravity Grabber Gun.
  - `W`: Spawn Pin Constraint (anchors joint to background).
  - `E`: Spawn Elastic Tether Rope.
  - `R`: Spawn Explosive TNT Bomb (`Click` to detonate).
  - `T`: Laser Cutter / Scalpel (severs limb constraints).
  - `Y`: Spawn Bouncy Balls.
  - `U`: Spawn Thruster Jet.
  - `I`: Reset all ragdolls.

---

### 47. Monsoon Overdrive (Rain Benchmark) (`rain/`)
*Realistic Fluid Rain Simulator & M4 Hardware Stress Benchmark*

```bash
v run rain
```
![Monsoon Overdrive](screenshots/rain.png)

- **Objective**: Experience a hyper-realistic atmospheric rain simulator and hardware stress-test capable of rendering up to **1,000,000 active fluid particles** and allocating up to **32 GB of RAM**!
- **Controls**:
  - `Mouse`: Position and angle the interactive umbrella shield.
  - `1-5`: Rain density presets (Drizzle, Heavy Shower, Monsoon, Category 5 Typhoon, Hardware Meltdown).
  - `WASD` or `Arrow Keys`: Adjust wind velocity vector and atmospheric turbulence.
  - `[` / `]` or `-` / `+`: Allocate / deallocate RAM stress buffers.
  - `Up` / `Down`: Adjust particle spawn rates.
  - `Tab`: Switch weather themes (Cyberpunk Neon, Midnight Storm, Acid Rain, Crimson Aurora).
  - `B`: Toggle benchmark performance analytics overlay (FPS, Frame Time, Particle Count, VRAM usage).

---

### 48. Reversi Master (`reversi/`)
*8x8 Disc-Flipping Board Strategy with Minimax Lookahead AI*

```bash
v run reversi
```
![Reversi Master](screenshots/reversi.png)

- **Objective**: Outflank and trap your opponent's discs between your own to flip them to your color. Have the majority of discs on the 8x8 board when neither player can make a legal move!
- **Controls**:
  - `Left Click`: Place disc on any highlighted legal square.
  - `U`: Undo last move.
  - `H`: Highlight the optimal move recommended by the Minimax AI.
  - `M`: Toggle 1P (vs AI) / 2P Local Pass-and-Play.
  - `D`: Cycle AI difficulty (**Novice**, **Tactician**, **Grandmaster**).
  - `R`: Reset game.
  - `S`: Toggle sound.
- **Rules & Strategy**:
  - A legal move must bracket at least one opposing disc horizontally, vertically, or diagonally.
  - **Corner squares (A1, A8, H1, H8)** can never be flipped once captured — secure corners at all costs!
- **Pro Tip**: Avoid placing discs on the squares immediately adjacent to open corners (X-squares and C-squares) to prevent giving your opponent an easy path to capture the corner.

---

### 49. Rodent's Revenge (`rodentsrevenge/`)
*1991 Microsoft Windows Cat-Trapping Puzzle Classic*

```bash
v run rodentsrevenge
```
![Rodent's Revenge](screenshots/rodentsrevenge.png)

- **Objective**: Guide the clever mouse through warehouse grids, push wooden crates to box in pursuing cats until they have no legal moves, and transform them into delicious edible cheese wedges!
- **Controls**:
  - `WASD` or `Arrow Keys`: Move mouse and push single or multiple crates in a line.
  - `R`: Restart level.
  - `M`: Toggle sound.
- **Cat Trapping Mechanics**:
  - Cats actively hunt the mouse.
  - When a cat is surrounded on all 4 adjacent sides by crates or walls (0 open squares), it instantly transforms into a giant cheese wedge (**+1,000 pts**)!
  - Eat all cheese wedges to advance to the next level.
- **Warehouse Hazards**:
  - Avoid snapping mousetraps and sinkholes. Watch out for slumbering cats that wake up when approached!
- **Pro Tip**: Build U-shaped crate enclosures, lure chasing cats inside, and push the final block into place to trap them instantly.

---

### 50. Scorched Earth Deluxe (`scorchedearth/`)
*1991 MS-DOS Tank Ballistics War Classic with Destructible Voxel Terrain*

```bash
v run scorchedearth
```
![Scorched Earth](screenshots/scorchedearth.png)

- **Objective**: Command your artillery battle tank, dial in precise turret elevation angles and gunpowder velocity, factor in changing crosswinds, and destroy rival tanks across deformable mountain terrains!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Adjust barrel elevation angle ($0^\circ - 180^\circ$).
  - `W` / `S` or `Up` / `Down`: Adjust shot firing power ($50 - 1000\text{ m/s}$).
  - `1-6`: Select active weapon from arsenal.
  - `Space`: Fire artillery shot!
  - `M`: Toggle sound.
- **6-Weapon Arsenal**:
  1. **Standard Shell**: Reliable ballistic artillery explosive.
  2. **Baby Nuke**: Medium-radius high-yield shockwave.
  3. **MIRV Death's Head**: Warhead that splits into 5 cluster bombs at the apex of its arc!
  4. **Mountain Mover**: Creates an instant massive dirt barrier wall on impact.
  5. **Napalm Roller**: Liquid fire that rolls down mountain slopes into craters.
  6. **Digger Drill**: Burrows deep into underground bedrock before detonating.
- **Between-Rounds Shop**: Spend cash earned from victories to purchase tactical nuclear warheads, battery shields, and guidance systems!
- **Pro Tip**: Note the wind speed banner at the top — positive wind blows shots right, negative wind pushes shots left!

---

### 51. Cyber Shinobi Runner (`shinobi/`)
*Fast Ninja Action Platformer with Katana Slashes & Shurikens*

```bash
v run shinobi
```
![Cyber Shinobi Runner](screenshots/shinobi.png)

- **Objective**: Run across rooftops and cybernetic temples, slash through enemy cyborg ninjas with your katana blade, throw razor shurikens at distant snipers, leap over spike chasms, and defeat stage bosses!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Run left and right.
  - `W` or `Up`: Jump / Wall jump.
  - `J` or `Z`: Katana melee slash attack.
  - `K` or `X`: Throw ranged ninja shuriken star.
  - `Space`: Start game / Jump.
  - `P`: Pause game.
  - `R`: Restart stage.
  - `M`: Toggle sound.
- **Combat Mechanics**:
  - Timed katana slashes deflect incoming hostile bullets back at enemies!
  - String together aerial jump-slashes to maintain momentum and build combo score meters.
- **Pro Tip**: Use shurikens against airborne drones and save your melee katana slashes for armored ground guards.

---

### 52. Cyberpunk Vanguard (`sidescroller/`)
*2D Side-Scrolling Action Shooter with 8 Weapons & Jetpack*

```bash
v run sidescroller
```
![Cyberpunk Vanguard](screenshots/sidescroller.png)

- **Objective**: Infiltrate heavily guarded neon cyber cities, eliminate hostile drone swarms and mechanized turrets, defeat multi-stage bosses, and survive intense bullet hell shootouts!
- **Controls**:
  - `WASD`: Move soldier (W to jump / engage jetpack, S to crouch).
  - `W` / `Space`: Hold for vertical jetpack thruster flight.
  - `J` or `Z`: Fire equipped weapon.
  - `K` or `Shift`: Cyber Dash (brief invulnerability dash through bullets).
  - `1-8`: Instant weapon selection.
- **8 Futuristic Weapon Systems**:
  - **1: Pulse Blaster**, **2: Spread Shotgun**, **3: Homing Swarm Missiles**, **4: Plasma Railgun**, **5: Flamethrower**, **6: Lightning Arc**, **7: Bouncing Grenades**, **8: Orbital Singularity Nuke**.
- **Pro Tip**: Use Cyber Dash (`Shift`) to phase straight through dense walls of enemy laser fire without taking damage!

---

### 53. Cyber Simon (`simon/`)
*Electronic Memory Light & Sound Synthesizer*

```bash
v run simon
```
![Cyber Simon](screenshots/simon.png)

- **Objective**: Watch the glowing colored quadrant pads light up with musical tones, memorize the sequence, and repeat it back correctly without making a mistake!
- **Controls**:
  - `Left Click` on quadrant pads or press `1-4` / `Q`, `W`, `A`, `S`.
  - `Space`: Start sequence.
  - `M`: Toggle game mode (**Classic**, **Reverse Sequence**, **Speed Simon**).
  - `R`: Reset game.
  - `S`: Toggle audio.
- **Modes**:
  - **Classic**: Sequence grows by +1 tone each successful round.
  - **Reverse**: Repeat the shown sequence in backwards reverse order!
  - **Speed Simon**: Sequence speeds up dramatically with each step.
- **Pro Tip**: Assign each color a mental number or rhythmic phrase to recall long sequences of 15+ steps effortlessly.

---

### 54. SinkSub Pro (`sinksub/`)
*Submarine Hunter Destroyer with Depth Charges & Naval Upgrades*

```bash
v run sinksub
```
![SinkSub Pro](screenshots/sinksub.png)

- **Objective**: Command a surface navy destroyer, drop depth charges off your stern to destroy enemy submarines patrolling the deep ocean, dodge homing torpedoes, and earn promotions through 14 navy ranks!
- **Controls**:
  - `Left` / `Right` or `A` / `D`: Steer destroyer ship along surface.
  - `Z`: Drop depth charge (sinks into ocean and detonates).
  - `X`: Launch forward anti-sub rocket.
  - `Space`: Deploy nuclear depth bomb (full-screen shockwave).
  - `M`: Toggle audio.
- **Submarine Classes**:
  - **Scout Sub**: Fast, light armor.
  - **Attack Sub**: Fires upward homing torpedoes.
  - **Mine-Layer**: Deploys floating proximity contact mines.
  - **Nuclear Dreadnought Sub**: Heavily armored boss vessel.
- **Drydock Upgrade Shop**: Spend combat bounty cash between sectors to upgrade engine speed, depth charge reload rate, hull armor plating, and blast radius!
- **Pro Tip**: Depth charges take time to sink — drop charges well ahead of a moving submarine's path so they detonate at the submarine's exact depth.

---

### 55. SkiFree Extreme (`skifree/`)
*1991 Windows Shareware Skiing Classic with Mid-Air Stunts & Yeti*

```bash
v run skifree
```
![SkiFree Extreme](screenshots/skifree.png)

- **Objective**: Ski down infinite snow-covered mountain slopes, weave between pine trees and boulders, jump off snow ramps to perform acrobatic stunt combos, and outrun the terrifying fast-running Abominable Snow Monster Yeti!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Carve left and right.
  - `W` / `Up`: Tuck forward for maximum downhill speed.
  - `S` / `Down`: Snowplow brake to slow down.
  - `Space`: Jump off moguls and ramps.
  - `WASD` in mid-air: Perform aerial stunts (**Daffy**, **360 Spin**, **Backflip**, **Spread Eagle**)!
  - `M`: Cycle game mode (Slalom, Free Style, Tree Slalom).
  - `R`: Restart run.
- **The Yeti Hazard**:
  - After passing the 2,000-meter mark, the monstrous Abominable Yeti sprints out from the forest to chase you down!
- **Pro Tip**: Ski diagonally downhill at maximum speed while performing quick ramp hops to stay ahead of the Yeti!

---

### 56. Cyberpunk Snake (`snake/`)
*Neon Vector Snake with Particle Bursts & Golden Star Food*

```bash
v run snake
```
![Cyberpunk Snake](screenshots/snake.png)

- **Objective**: Guide your glowing neon snake around the grid, eat energy orbs to grow longer, and avoid crashing into arena boundaries or your own growing tail!
- **Controls**:
  - `WASD` or `Arrow Keys`: Change snake heading direction.
  - `P`: Pause game.
  - `R`: Restart game.
  - `S`: Toggle sound.
- **Food Types**:
  - **Regular Cyan Orbs**: +10 pts, grows snake length by +1 segment.
  - **Golden Stars**: Temporary timed bonus food (+50 pts, builds combo multiplier).
- **Pro Tip**: Coil your snake along the perimeter walls in a back-and-forth zigzag pattern to leave the entire center open for safe maneuvering.

---

### 57. Sokoban Master (`sokoban/`)
*Japanese Warehouse Box-Pushing Puzzle with Handcrafted Levels*

```bash
v run sokoban
```
![Sokoban Master](screenshots/sokoban.png)

- **Objective**: Push all wooden cargo crates onto the designated green goal storage targets. Crates can only be pushed, never pulled!
- **Controls**:
  - `WASD` or `Arrow Keys`: Move warehouse keeper and push adjacent crates.
  - `U` or `Z`: Unlimited move undo history.
  - `R`: Reset current level.
  - `N` / `P`: Next / Previous level (15+ Handcrafted Levels).
  - `S`: Toggle sound.
- **Golden Rule of Sokoban**: Never push a crate into a dead corner wall where it cannot be pushed out, unless that corner is already a goal target!
- **Pro Tip**: Work backward from the most isolated goal target to determine which crate must be placed there first.

---

### 58. Space Invaders Pro (`spaceinvaders/`)
*1978 Taito Arcade Legend with Destructible Voxel Bunker Shields*

```bash
v run spaceinvaders
```
![Space Invaders Pro](screenshots/spaceinvaders.png)

- **Objective**: Defend Earth from a 55-alien marching matrix marching down the screen, shoot down the Mystery Flying Saucer UFO, and eliminate all invaders before they land!
- **Controls**:
  - `A` / `D` or `Left` / `Right`: Slide laser cannon left and right.
  - `Space`: Fire laser beam.
  - `R`: Restart game.
  - `S`: Toggle sound.
- **Marching Aliens & Bunker Shields**:
  - **Squids (Top Row)**: 30 pts.
  - **Crabs (Middle Rows)**: 20 pts.
  - **Octopuses (Bottom Rows)**: 10 pts.
  - **Mystery Flying Saucer UFO**: Spawns across the top periodically (**50 - 300 bonus pts**).
  - **4 Destructible Bunkers**: Take damage and erode from both enemy missiles and player laser fire.
- **Accelerating Tempo**: As fewer aliens remain on screen, their marching speed and sound heartbeat accelerate exponentially!
- **Pro Tip**: Fire through a narrow hole in one of your bunkers to shoot aliens while staying completely shielded from incoming return fire.

---

### 59. Modern Tetris (`tetris/`)
*Modern Guideline Tetris with Super Rotation System (SRS) & Hold*

```bash
v run tetris
```
![Modern Tetris](screenshots/tetris.png)

- **Objective**: Rotate and fit falling geometric Tetrominoes into a 10x20 matrix to complete solid horizontal lines and clear them before the stack reaches the top!
- **Controls**:
  - `Left` / `Right` or `A` / `D`: Move falling piece horizontally.
  - `Up` or `W` / `X`: Rotate piece Clockwise (Super Rotation System wall kicks).
  - `Z`: Rotate piece Counter-Clockwise.
  - `Down` or `S`: Soft drop (accelerates fall).
  - `Space`: Hard drop (instantly locks piece into place).
  - `C` or `Shift`: **Hold Piece** (stores current piece for later swap).
  - `P`: Pause game.
  - `R`: Restart game.
- **Scoring**: Single Line (100), Double (300), Triple (500), **Tetris (4 Lines simultaneously - 800 pts)**, Back-to-Back Tetris multipliers!
- **Pro Tip**: Keep the rightmost column (Column 10) open to slide straight I-pieces (long bars) into the gap for consecutive 4-line Tetris clears.

---

### 60. Cyber Tower Defense (`towerdefense/`)
*Strategic Path Defense with Upgradeable Particle Towers*

```bash
v run towerdefense
```
![Cyber Tower Defense](screenshots/towerdefense.png)

- **Objective**: Place defensive particle and laser towers along the winding road to destroy waves of invading mechanized creeps before they breach your base core!
- **Controls**:
  - `1-3` or `L`/`C`/`F`: Select tower type from build menu (**1: Laser Turret**, **2: Heavy Plasma Cannon**, **3: Frost Slow Tower**).
  - `Left Click` or `Space`: Place tower on grid tile.
  - `U`: Upgrade selected tower to next power tier.
  - `X` / `Delete`: Sell selected tower for cash refund.
  - `P`: Pause game.
  - `R`: Restart game.
  - `M`: Toggle audio.
- **Tower Strategies**:
  - **Laser Turret**: High firing rate, ideal for fast swarming scout creeps.
  - **Plasma Cannon**: High damage area-of-effect blast, great against armored heavy tanks.
  - **Frost Tower**: Emits cryogenic cold fields that slow down enemy movement speed by 50%.
- **Pro Tip**: Place Frost Slow Towers at major hairpin turns so your heavy Plasma Cannons can hit clustered enemies multiple times!

---

### 61. Party Trivia Show (`trivia/`)
*TV Studio Quiz Arena with Multi-Category Questions & Buzzer Duels*

```bash
v run trivia
```
![Party Trivia Show](screenshots/trivia.png)

- **Objective**: Test your knowledge across 5 rich trivia categories! Race against the 15-second timer bar to choose the correct answers and build massive winning streaks!
- **Controls**:
  - **Player 1 / Solo Mode**: `1-4` or `A` / `B` / `C` / `D` or `Mouse Click`.
  - **Player 2 (Buzzer Duel Mode)**: `U` / `I` / `O` / `P`.
  - `Space`: Advance to next question / Reveal score breakdown.
  - `M`: Toggle 1P Solo Marathon / 2P Local Buzzer Duel.
  - `T`: Reset quiz with newly shuffled questions.
  - `S`: Toggle audio.
- **5 Categories (60+ Handcrafted Questions)**:
  1. **Gaming & Retro Tech**
  2. **Science & Space Exploration**
  3. **Pop Culture & Cinema**
  4. **World History & Geography**
  5. **Logic Riddles & Brainteasers**
- **Pro Tip**: Answering within the first 3 seconds awards a substantial Speed Bonus on top of standard correct answer points!

---

### 62. CyberType: Neon Typist (`typing/`)
*Arcade Space Typing Shooter with Tactical Lock-On & Real-Time WPM*

```bash
v run typing
```
![CyberType: Neon Typist](screenshots/typing.png)

- **Objective**: Target descending alien spacecraft by typing the first letter of their word to acquire laser lock-on, then type out the full word to obliterate them before they breach your planetary shields!
- **Controls**:
  - `A-Z`: Type letters to lock onto targets and fire plasma lasers.
  - `Backspace` or `Esc`: Cancel current target lock-on.
  - `1-4`: Select game mode on title screen (**1: Arcade Campaign**, **2: 60s Speed Blitz**, **3: Developer Code Syntax**, **4: Endless Survival**).
  - `Space` / `Enter`: Start game.
  - `F1`: Pause game.
  - `F9`: Toggle sound.
- **Special Power-Up Words**:
  - **EMP Nuke Words (Cyan)**: Detonates full-screen shockwave destroying all active hostiles.
  - **Time Warp Words (Purple)**: Freezes all enemy movement for 4 seconds.
  - **Shield Repair Words (Green)**: Restores +1 hull integrity block.
- **Real-Time Analytics**: Live WPM (Words Per Minute) gauge, accuracy percentage, and streak multipliers up to **100x**!
- **Pro Tip**: Prioritize low-altitude enemies with short words to prevent incoming hull damage before acquiring long multi-syllable Dreadnought targets.

---

### 63. Yahtzee Deluxe (`yahtzee/`)
*5-Dice Strategy with Full Scorecard, AI Bot & Yahtzee Bonuses*

```bash
v run yahtzee
```
![Yahtzee Deluxe](screenshots/yahtzee.png)

- **Objective**: Roll 5 dice up to 3 times per turn to score the highest possible combination across all 13 scorecard categories (Upper Section numbers and Lower Section poker hands)!
- **Controls**:
  - `Space` or `Left Click Roll Button`: Roll active dice.
  - `1-5` or `Click on Die`: Hold / Unhold individual dice between rolls.
  - `Left Click on Scorecard Row`: Select category to record score and end turn.
  - `M`: Toggle audio.
  - `R`: Start new game.
- **Official Rules & Bonuses**:
  - **Upper Section Bonus (+35 pts)**: Earned if your total score in Aces through Sixes is 63 or higher.
  - **Yahtzee (5 of a Kind - 50 pts)**: Rolling five identical dice.
  - **Yahtzee Bonus (+100 pts per additional Yahtzee)**: Extra Yahtzees score +100 bonus points with Joker card rules!
- **Pro Tip**: Always aim to secure at least 3 of each number in the Upper Section (three 4s, three 5s, three 6s) to guarantee the +35 Upper Bonus!

---

## 🧪 Automated Unit Testing

You can run automated test suites for the game modules using the V test runner:

```bash
# Run tests across games
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

## 📁 Repository Directory Structure

```
sdl_games/
├── airhockey/              # 1. Hyper Air Hockey
├── asteroids/              # 2. Asteroids Pro
├── balloonfight/           # 3. NES Balloon Fight
├── battleship/             # 4. Battleship Pro
├── bejeweled/              # 5. Bejeweled Match-3
├── bomberman/              # 6. Bomberman Arcade
├── boulderdash/            # 7. Boulder Dash Retro
├── breakout/               # 8. Breakout Overdrive
├── bubbleshooter/          # 9. Bubble Shooter Pro
├── centipede/              # 10. Cyber Centipede Pro
├── chimptest/              # 11. Chimp Test Pro
├── chipschallenge/         # 12. Chip's Challenge Deluxe
├── clickarcade/            # 13. Click Arcade (4-in-1 Suite)
├── connect4/               # 14. Connect 4
├── cyberrunner/            # 15. Neon Vector Run 3D
├── digdug/                 # 16. Dig Dug Classic
├── donkeykong/             # 17. Donkey Kong Arcade
├── dopewars/               # 18. Dope Wars 1990
├── duke/                   # 19. Duke Nukem: Cyber Outpost
├── etchasketch/            # 20. Etch A Sketch Deluxe
├── flappy/                 # 21. Flappy Bird Pro
├── frogger/                # 22. Frogger Arcade
├── galaga/                 # 23. Galaga Space Shooter
├── game2048/               # 24. 2048 Neon Pulse
├── gnujump/                # 25. GNUjump Tower
├── goldminer/              # 26. Gold Miner Classic
├── jezzball/               # 27. JezzBall Pro
├── lemmings/               # 28. Lemmings Master
├── liarsdice/              # 29. Liar's Dice Deluxe
├── lightcycles/            # 30. Tron Light Cycles
├── lolo/                   # 31. Adventures of Lolo
├── lunarlander/            # 32. Lunar Lander Simulator
├── mappy/                  # 33. Mappy Arcade
├── memorymatch/            # 34. Memory Match Pro
├── micromayhem/            # 35. Micro Mayhem
├── minesweeper/            # 36. Minesweeper Pro
├── missilecommand/         # 37. Missile Command Air Defense
├── pacman/                 # 38. Pac-Man Arcade
├── peggle/                 # 39. Peggle Extreme
├── picross/                # 40. Picross Pro
├── pinball/                # 41. NES Pinball
├── pong/                   # 42. Hyper Pong
├── puyopuyo/               # 43. Puyo Puyo Cascade
├── qbert/                  # 44. Q*bert Isometric
├── racer/                  # 45. Cyber Drift Racer
├── ragdoll/                # 46. Ragdoll Physics Sandbox
├── rain/                   # 47. Monsoon Overdrive
├── reversi/                # 48. Reversi Master
├── rodentsrevenge/         # 49. Rodent's Revenge
├── scorchedearth/          # 50. Scorched Earth Deluxe
├── shinobi/                # 51. Cyber Shinobi Runner
├── sidescroller/           # 52. Cyberpunk Vanguard
├── simon/                  # 53. Cyber Simon
├── sinksub/                # 54. SinkSub Pro
├── skifree/                # 55. SkiFree Extreme
├── snake/                  # 56. Cyberpunk Snake
├── sokoban/                # 57. Sokoban Master
├── spaceinvaders/          # 58. Space Invaders Pro
├── tetris/                 # 59. Modern Tetris
├── towerdefense/           # 60. Cyber Tower Defense
├── trivia/                 # 61. Party Trivia Show
├── typing/                 # 62. CyberType: Neon Typist
├── yahtzee/                # 63. Yahtzee Deluxe
└── screenshots/            # Visual gallery screenshots for all games
```

---

## 📜 License & Credits

Built with ❤️ in [V](https://vlang.io/) using [SDL2](https://www.libsdl.org/) and [vlang/sdl](https://github.com/vlang/sdl).
All game logic, physics engines, procedural sound synthesizers, and vector graphics are custom-built for high performance and zero external binary dependencies.
