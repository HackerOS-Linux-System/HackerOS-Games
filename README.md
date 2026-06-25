# HackerOS Games

The official game launcher and game collection for [HackerOS](https://github.com/HackerOS-Linux-System).

---

## Overview

**HackerOS Games** is a native Tauri 2 + React 18 + Rust launcher bundled with every HackerOS edition. It provides a unified, cyberpunk-styled interface for launching, tracking playtime, configuring and installing games — both bundled titles and community submissions from the Store.

All games run inside a **lightweight, kernel-native sandbox** (bubblewrap/bwrap). Performance impact is negligible — network access is disabled and the filesystem is read-only except for save data.

---

## Repository structure

```
HackerOS-Games/
├── app/                    # Launcher (Tauri 2 + React 18 + Rust)
│   ├── src-tauri/          # Rust backend
│   │   └── src/main.rs     # Commands: launch, playtime, store install, sandbox
│   ├── components/
│   │   ├── GamesSection.tsx
│   │   ├── StoreSection.tsx    # Community store with install/launch/uninstall
│   │   ├── AddonsSection.tsx
│   │   ├── SettingsSection.tsx # System Info + sandbox model panel
│   │   └── ParticlesBackground.tsx
│   ├── App.tsx
│   ├── constants.ts        # GAMES[], ADDON_GAMES[], COMMUNITY_GAMES_URL
│   └── types.ts
│
├── the-racer/              # Rust + macroquad (binary)
├── cosmonaut/              # Lua + LÖVE2D (.love file)
├── starblaster/            # Rust + macroquad (binary)
├── bark-squadron/          # TypeScript + React + Tauri 2 + Rust (binary)
├── bit-jump/               # Lua + LÖVE2D (.love file)
├── addons/
│   └── parkour-runner/     # Lua + LÖVE2D (.love file, addon pack)
└── HackerOS-Community-Games/
    └── list.json           # Community store listing
```

---

## Games — Library

Games are installed to `/usr/share/HackerOS/Scripts/HackerOS-Games/`.

| Game | Type | Launch method |
|------|------|---------------|
| **The Racer** | Rust + macroquad | Binary: `the-racer` |
| **Cosmonaut** | Lua + LÖVE2D | `love cosmonaut.love` |
| **Starblaster** | Rust + macroquad | Binary: `starblaster` |
| **Bark Squadron** | TypeScript + React + Tauri | Binary: `bark-squadron` |
| **Bit Jump** | Lua + LÖVE2D | `love bit-jump.love` |

### Addon pack games (installed via Addons tab)

| Game | Launch method |
|------|--------------|
| **Parkour Runner** | `love addons/parkour-runner.love` |

---

## Sandbox model

All games (built-in and community) are launched inside a lightweight sandbox:

- **Engine**: bubblewrap (`bwrap`) — kernel namespace isolation, no extra daemon, near-zero overhead
- **Fallback**: firejail (if bwrap unavailable) → direct launch
- **What's isolated**:
  - `/usr`, `/bin`, `/lib` — read-only bind mounts
  - `/tmp` — private tmpfs (game cannot see host /tmp)
  - Network — completely disabled (`--unshare-net`)
  - PID namespace — isolated (`--unshare-pid`)
  - UTS namespace — isolated (`--unshare-uts`)
- **What's writable**: `~/.hackeros-games/` (save data, playtime, settings) — bind-mounted read-write
- **Security**: no privilege escalation, no setuid; runs as the current user inside its own namespace

Community games (Python, Ruby, Lua, binary, archive) all go through the same sandbox.

---

## Store (Community Games)

The store reads `HackerOS-Community-Games/list.json` from GitHub. Each entry supports:

- **Git repos** (`.git` URL) → `git clone --depth=1`; auto-detects Python/Ruby/Lua/binary entry point
- **ZIP archives** → `unzip` into install dir
- **TAR.GZ archives** → `tar -xf` into install dir
- **Direct binaries** → downloaded, marked executable
- **Windows EXE** → downloaded (not sandboxable on Linux — noted in UI)

Install path: `/usr/share/HackerOS/Scripts/HackerOS-Games/community/<game-id>/`

### list.json format

```json
{
  "HackerOS-Community-Games": [
    {
      "id": 1,
      "title": "Game Title",
      "genre": "Genre / Subgenre",
      "description-en": "English description.",
      "description-pl": "Polish description.",
      "install": "https://github.com/org/repo.git",
      "repo": "https://github.com/org/repo",
      "authors": "Author Name",
      "image": "https://example.com/icon.png"
    }
  ]
}
```

New games can be added to the list at any time — the launcher fetches it live on every Store tab open.

---

## Building

### Launcher (`app/`)

Requires: Rust stable, Node.js ≥ 20, `@tauri-apps/cli` v2.

```bash
cd app
npm install
npm run tauri:build    # produces a single binary (no .deb/.rpm)
```

The binary is output to `app/src-tauri/target/release/hackeros-games`.

### Bark Squadron (`bark-squadron/`)

Same stack as the launcher — Tauri 2 + React 18 + Rust.

```bash
cd bark-squadron
npm install
npm run tauri:build    # produces bark-squadron binary
```

### Rust games (the-racer, starblaster)

```bash
cd the-racer   # or starblaster
cargo build --release
```

### Lua/LÖVE games (cosmonaut, bit-jump, parkour-runner)

No build step — the `.love` archive is the distributable. Package with:

```bash
cd cosmonaut
zip -9 -r cosmonaut.love . -i "*.lua" "*.png" "*.ogg" "*.ttf"
```

---

## Installing games on HackerOS

```bash
# Install all binaries and .love files
sudo cp the-racer/target/release/the-racer   /usr/share/HackerOS/Scripts/HackerOS-Games/
sudo cp cosmonaut/cosmonaut.love              /usr/share/HackerOS/Scripts/HackerOS-Games/
sudo cp starblaster/target/release/starblaster /usr/share/HackerOS/Scripts/HackerOS-Games/
sudo cp bark-squadron/src-tauri/target/release/bark-squadron /usr/share/HackerOS/Scripts/HackerOS-Games/
sudo cp bit-jump/bit-jump.love                /usr/share/HackerOS/Scripts/HackerOS-Games/
```

---

## License

MIT — see [LICENSE](./LICENSE).
