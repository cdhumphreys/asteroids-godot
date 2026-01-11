# Asteroids

A classic Asteroids-style arcade game built with Godot 4.5.

## Overview

This is a modern take on the classic Asteroids arcade game with difficulty scaling, and a high score system. Battle through waves of asteroids and enemy ships while trying to survive as long as possible.
## Features

- **Classic Asteroids Gameplay**: Rotate, thrust, and shoot your way through space with wrap-around mechanics
- **Dynamic Difficulty**: Game difficulty increases over time with more asteroids and enemies spawning
- **Enemy UFOs**: Face off against enemy ships that track and shoot at you
- **Lives System**: Start with 3 lives and try to survive as long as possible
- **High Score System**: Save your top 10 scores with usernames
- **Environment**: Starfield parallax background with particle effects for gas clouds
- **Sound Effects**: Audio feedback for actions and destruction
- **Component-Based Architecture**: Modular design with health, shooting, hitbox, and hurtbox components

## Controls

- **W / Up Arrow**: Thrust forward
- **S / Down Arrow**: Thrust backward
- **A / Left Arrow**: Rotate counter-clockwise
- **D / Right Arrow**: Rotate clockwise
- **Space**: Shoot
- **ESC**: Pause/Unpause game


## Running the Project

### Prerequisites
- Godot Engine 4.5 or later

### Opening in Godot
1. Download and install [Godot Engine 4.5+](https://godotengine.org/download)
2. Open Godot and click "Import"
3. Navigate to this project folder and select `project.godot`
4. Click "Import & Edit"
5. Click the "Play" button to run the game

## Project Structure

```
asteroids/
├── assets/          # Game assets (fonts, images, sounds)
├── classes/         # Core game classes (AsteroidStats, HighScore, SaveGame)
├── components/      # Reusable components (Health, Shooting, Hitbox, Hurtbox)
├── globals/         # Global utilities and event bus
├── resources/       # Game resources (asteroid configurations)
├── scenes/          # Game scenes (player, asteroids, UI)
├── scripts/         # Game logic scripts
├── shaders/         # Visual effects shaders
└── ui/              # UI theme resources
```

## Credits

### Fonts
- **Monoton**: [from Google Fonts](https://fonts.google.com/specimen/Monoton)
- **Roboto Mono**: [from Google Fonts](https://fonts.google.com/specimen/Roboto+Mono)

### Audio
- Sound effects from [Kenney](https://kenney.nl/assets/sci-fi-sounds)

### Graphics
- Sprites: [Kenney](https://kenney.nl/assets/simple-space)
