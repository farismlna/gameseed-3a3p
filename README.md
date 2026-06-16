# Metamorcapsule
> A bizarre top-down exploration puzzle game — made for GameSeed Game Jam

**Genre:** 2.5D Top-Down Exploration / Puzzle  
**Engine:** Godot 4.6.2  
**Platform:** Windows, Linux, macOS (export target: itch.io)  
**Theme:** Inner Childhood Dream + So Absurd, It's Cool

---

##  About the Game

You are a cylinder. You don't know what you are. You don't know where you came from.

So you do what any reasonable cylinder would do — absorb the traits of every animal and object you meet, piece by piece, until you figure it out.

*Metamorcapsule* is a short puzzle-exploration game where the player absorbs physical traits from animals and objects in the world, equipping them as body parts to solve puzzles, unlock new areas, and interact with NPCs in increasingly absurd ways.

---

##  Team

| Name | Role |
|---|---|
| Azfa | Programmer & GDD Organizer |
| Farris | Programmer |
| Daniel | Programmer & Music |
| Hanif & Nazwa | Lead Designer & Artist |
| Bara | UI/UX Designer & Artist |

---

##  System Requirements & Environment Setup

### Prerequisites

- [Godot Engine 4.6.2](https://godotengine.org/download) — make sure to download the **Standard** version (not .NET/Mono unless the project uses C#)
- Git

### All Platforms (Windows, Linux, macOS)

Godot 4 runs natively on all major platforms. No additional configuration is required beyond installing the engine.

> **Windows users:** Standard Command Prompt and PowerShell both work fine for Git operations. No WSL required.

---

##  How to Run the Project

### 1. Clone the repository

```bash
git clone https://github.com/farismlna/gameseed-3a3p.git
```

### 2. Enter the project directory

```bash
cd gameseed-3a3p
```

### 3. Open in Godot

- Launch **Godot 4.6.2**
- Click **Import**
- Navigate to the cloned folder and select `project.godot`
- Click **Import & Edit**

### 4. Run the project

Press **F5** (or the ▶ Play button) to run from the main scene.

---

##  Exporting for itch.io

### Web Export (Recommended for itch.io)

1. In Godot, go to **Project → Export**
2. Add a new export preset: **Web**
3. Make sure export templates are installed — if not, click **Manage Export Templates** and download them
4. Set the export path to `exports/web/index.html`
5. Click **Export Project**
6. Upload the entire `exports/web/` folder as a ZIP to itch.io
7. On itch.io, set **Kind of project** to `HTML` and enable **This file will be played in the browser**

### Windows Export (Optional)

1. Add a **Windows Desktop** export preset
2. Export path: `exports/windows/Metamorcapsule.exe`
3. Zip the folder and upload to itch.io as an additional download

---

##  Git Workflow

### Branch Structure

```
main        → stable build only, submit-ready
dev         → active development branch
feature/*   → individual feature branches (branch off from dev)
```

> **Never push directly to `main`.** All changes go through `dev` first.

### Conventional Commits

Wajib menggunakan format berikut saat commit untuk menjaga riwayat Git tetap bersih dan mudah dibaca:

```
feat:      penambahan fitur baru
           contoh: feat: implement trait absorption system

fix:       perbaikan bug
           contoh: fix: resolve double jump not resetting on land

docs:      perubahan dokumentasi atau README
           contoh: docs: update export guide for itch.io

refactor:  merapikan kode tanpa mengubah fungsi
           contoh: refactor: clean up trait equip slot logic

assets:    penambahan atau perubahan aset (sprite, audio, dsb)
           contoh: assets: add frog leg sprite variants

chore:     hal-hal non-kode (konfigurasi, .gitignore, dsb)
           contoh: chore: update .gitignore for Godot 4
```

### Recommended Workflow

```bash
# Selalu mulai dari branch dev yang up-to-date
git checkout dev
git pull origin dev

# Buat branch baru untuk fitur yang dikerjakan
git checkout -b feature/trait-absorption

# Kerjakan, lalu commit dengan format conventional
git add .
git commit -m "feat: implement trait absorption interaction prompt"

# Push dan buat Pull Request ke dev
git push origin feature/trait-absorption
```

---

##  Project Structure

```
gameseed-3a3p/
├── src/
│   ├── main.tscn          # Main scene entry point
│   ├── player/            # Player scenes & scripts
│   ├── areas/             # Area/level scenes
│   ├── ui/                # UI scenes (catalogue, HUD, inventory)
│   └── npcs/              # NPC scenes
├── scripts/
│   ├── player/            # Player controller, trait system
│   ├── traits/            # Individual trait logic
│   ├── quests/            # Quest manager
│   └── ui/                # UI logic
├── assets/
│   ├── sprites/           # All sprite assets
│   ├── audio/             # BGM and SFX
│   └── fonts/             # UI fonts
├── exports/               # Export output (gitignored)
└── project.godot
```

> **Note:** The `exports/` folder is gitignored. Do not commit exported builds to the repository.

---

## ⚠️ Notes for Programmers

- Godot version **must be 4.6.2** — do not use a different minor version as scene files may break
- All scripts use **GDScript** unless otherwise noted in the file header
- Trait logic is centralized in `scripts/traits/` — do not hardcode trait behavior inside player scripts
- If you add a new scene, make sure the folder structure follows the convention above
- Coordinate with Azfa before making changes to `main.tscn` or the quest manager

---

*Built with Godot 4.6.2 — GameSeed Game Jam 2025*
