# Parkour Runner

Urban freerunning game built with LÖVE2D (Lua).
Linux exclusive (Debian / HackerOS).

---

## Requirements

- **LÖVE2D 11.5+**

### Install on Debian / HackerOS

```bash
# Debian
sudo apt install love

# or from the official PPA (latest version)
sudo add-apt-repository ppa:bartbes/love-stable
sudo apt update && sudo apt install love
```

---

## Running the game

```bash
love parkour-runner.love
```

Or if you extracted the archive:
```bash
love /path/to/parkour-runner/
```

---

## Controls (default)

| Action      | Key          |
|-------------|--------------|
| Move left   | A            |
| Move right  | D            |
| Jump        | SPACE        |
| Double jump | SPACE (air)  |
| Slide       | LEFT SHIFT   |
| Pause       | ESCAPE       |
| Fullscreen  | F11          |

All controls are rebindable in **Settings → Controls**.

---

## Modes

### Time Attack
Race through hand-crafted parkour levels as fast as possible.
Beat the PAR time to earn gold. Your best times are saved locally.

### Hunter Mode
A hunter AI chases you across large maps.
Reach the goal before time runs out or you get caught.

### Endless Run
Procedurally generated obstacles, infinite scrolling.
The world speeds up over time. Survive as long as possible.
Scores are saved to the local leaderboard.

---

## Settings

Saved to:
```
~/.config/HackerOS/parkour-runner/settings.json
```

Includes: audio volumes, fullscreen, difficulty, keybinds, player name.

---

## Planned features

- More Time Attack levels
- Hunter Mode: multiple maps, multiplayer (LAN)
- Endless: more chunk types, biomes, cosmetics
- Sound effects & music
- Character customization / skins
- Online leaderboards

---
