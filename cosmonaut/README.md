# Cosmonaut — Space Agency Management
### Lua/LÖVE2D Edition v2.0

A full port and expansion of the original Odin/Raylib *Cosmonaut* game.  
Manage rockets, astronauts, missions, research, facilities, and a Space Race against rival agencies.

---

## Requirements

| Tool | Version | Download |
|------|---------|----------|
| **LÖVE2D** | 11.4 or 11.5 | https://love2d.org |
| Lua | bundled with LÖVE | — |

---

## Running the Game

### Option A — Command line
```bash
# From the cosmonaut_lua/ folder:
love .

# Or passing the folder explicitly:
love /path/to/cosmonaut_lua
```

### Option B — Drag & drop (Windows / macOS)
Drag the `cosmonaut_lua/` folder onto the `love.exe` / `love` application icon.

### Option C — Build a .love file
```bash
cd cosmonaut_lua
zip -9 -r ../cosmonaut.love .
love ../cosmonaut.love
```

---

## Controls

| Key / Mouse | Action |
|-------------|--------|
| **Mouse click** | All UI interaction |
| **Space** | Advance one month (Dashboard) |
| **Escape** | Back / return to Dashboard |
| **1 – 8** | Jump to nav tab directly |
| **Backspace** | Delete character in text fields |

---

## Files

```
cosmonaut_lua/
├── main.lua         Entry point, love callbacks
├── constants.lua    Colors, screen names, nav tabs
├── helpers.lua      Drawing primitives, button, stat bar, color utils
├── init.lua         Default data, new game state, stars
├── simulation.lua   Mission data, monthly tick, rival AI
├── ui_shared.lua    Top bar, bottom nav, notification toast
├── ui_screens.lua   All 13 screen draw functions
└── README.md        This file
```

---

## Gameplay Guide

### Starting Out (1957)
1. **Found your agency** — pick an era for your starting budget.
2. Go to **MISSIONS** and plan an **Orbital Test** — cheapest, highest success rate.
3. Hit **ADVANCE MONTH** (Space) to progress time.
4. Watch the mission complete and earn prestige.

### Growth Loop
- **Prestige** = score. Win the Space Race by outpacing rivals.
- **Budget** comes from monthly income ± events. Don't go broke.
- **Research** unlocks engine upgrades, longer life support, nuclear propulsion.
- **Facilities** increase income, mission success, and research speed.
- **Astronaut experience** improves over repeated missions. Assign specializations after 2 missions.

### Mission Types (easiest → hardest)
| Mission | Prestige | Notes |
|---------|----------|-------|
| Orbital Test | 5 | Safe first step |
| Satellite Network | 8 | Boosts income indirectly |
| Crewed Orbit | 20 | First crewed flight |
| Lunar Flyby | 25 | Moon milestones |
| Lunar Orbit | 40 | |
| **Lunar Landing** | **100** | Historic milestone +50 bonus |
| Mars Probe | 30 | Long journey |
| Mars Surface | 120 | Hardest crewed mission |
| Space Station | 60 | 36-month commitment |
| Deep Space Probe | 35 | Neptune flyby |

### Expanded Features (vs. original)
- **15 mission types** (added Venus Probe, Jupiter Flyby, Saturn Flyby)
- **Rival agencies** with their own milestone race and prestige bars
- **Research prerequisites** — some techs require earlier discoveries
- **Astronaut aging, retirement, and specialization**
- **Lab speed bonus** — higher Research Lab level = faster R&D
- **Reusable booster** rocket config
- **Milestones ribbon** on dashboard tracking your historic firsts
- **Intelligence feed** on Rivals screen
- **6 recruit pool** (8 candidates) with random stat variance
- **Rocket reliability improves** slightly after successful flights
- Keyboard shortcuts 1–8 for nav tabs

---

## Tips
- Always keep $50M+ buffer — random events can drain budget fast.
- Fund **Navigation** research early for a free +10% mission success.
- Upgrade **Tracking Network** before attempting Mars missions.
- A **Reusable Booster** costs less per mission over time.
- Lost astronauts are gone permanently — don't rush crewed missions.
- The **Soviet Space Program** is aggressive — watch the Rivals tab.

---

*Original game concept: Cosmonaut (Odin/Raylib) — ported to Lua/LÖVE2D with expansions.*
