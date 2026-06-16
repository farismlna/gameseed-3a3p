# Metamorcapsule
> A bizarre top-down exploration puzzle game - made for GameSeed Game Jam

**Genre:** 2.5D Top-Down Exploration / Puzzle  
**Engine:** Godot 4.6.2  
**Platform:** Windows, Linux, macOS (export target: itch.io)  
**Theme:** Inner Childhood Dream + So Absurd, It's Cool

---

## 📖 About the Game

You are a cylinder. You don't know what you are. You don't know where you came from.

So you do what any reasonable cylinder would do to absorb the traits of every animal and object you meet, piece by piece, until you figure it out.

*Metamorcapsule* is a short puzzle-exploration game where the player absorbs physical traits from animals and objects in the world, equipping them as body parts to solve puzzles, unlock new areas, and interact with NPCs in increasingly absurd ways.

---

## 👥 Team

| Name | Role |
|---|---|
| Azfa | Programmer & GDD Organizer |
| Farris | Programmer |
| Daniel | Programmer & Music |
| Hanif & Nazwa | Lead Designer & Artist |
| Bara | UI/UX Designer & Artist |

---

## 🛠️ System Requirements & Environment Setup

### Prerequisites

- [Godot Engine 4.6.2](https://godotengine.org/download) — make sure to download the **Standard** version (not .NET/Mono unless the project uses C#)
- Git

### All Platforms (Windows, Linux, macOS)

Godot 4 runs natively on all major platforms. No additional configuration is required beyond installing the engine.

> **Windows users:** Standard Command Prompt and PowerShell both work fine for Git operations. No WSL required.

---

## 🚀 How to Run the Project

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

### 4. Required setup after opening (IMPORTANT)

Two things must be configured manually after opening the project. Without these, the game will not run correctly.

#### A. Register TraitInventory as Autoload

```
Project → Project Settings → Autoload
Click the folder icon → navigate to: src/traits/trait_inventory.gd
Node Name: TraitInventory
Click Add
```

> Make sure the name is exactly `TraitInventory` — capitalization matters.

#### B. Add "Absorb" Input Action

```
Project → Project Settings → Input Map
Type "Absorb" in the Add Action field → click Add
Click the + icon next to the new action
Press the F key on your keyboard → click OK
```

### 5. Run the project

Press **F5** (or the ▶ Play button) to run from the main scene.

---

## 📦 Exporting for itch.io

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

## 🌿 Git Workflow

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
           contoh: docs: update setup instructions

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
git checkout -b feature/nama-fitur

# Kerjakan, lalu commit dengan format conventional
git add .
git commit -m "feat: implement trait absorption interaction prompt"

# Push dan buat Pull Request ke dev
git push origin feature/nama-fitur
```

---

## 📁 Project Structure

```
gameseed-3a3p/
├── levels/
│   └── level_0.tscn
├── src/
│   ├── obj/
│   │   ├── background/        # Background assets
│   │   ├── interactable/      # Interactable objects (absorbable.gd)
│   │   ├── player/            # Player scripts and sprites
│   │   └── UserInterface/     # UI scenes and scripts
│   └── traits/
│       ├── trait_data.gd      # TraitData resource class
│       ├── trait_inventory.gd # Global trait storage (Autoload)
│       └── data/              # .tres files for each trait
├── ost/                       # Background music
├── sfx/                       # Sound effects
├── exports/                   # Export output (gitignored)
└── project.godot
```

> **Note:** The `exports/` folder is gitignored. Do not commit exported builds to the repository.

---

## ⚠️ Notes for Programmers

- Godot version **must be atleast 4.6.x version** — do not use a different minor version as scene files may break
- All scripts use **GDScript** — tabs for indentation, not spaces (Godot will throw a parse error otherwise)
- Trait logic is centralized in `src/traits/` — do not hardcode trait behavior inside player scripts
- All new traits should be created as `.tres` files inside `src/traits/data/` — no new `.gd` files needed per trait
- Coordinate with Azfa before making changes to the quest manager or main scene
- Each programmer should own their scene files — communicate before editing someone else's scene to avoid merge conflicts

### Known Limitations / TODO

- `change_part_menu.gd` still uses hardcoded `"trait_1"`, `"trait_2"`, `"trait_3"` strings — needs to be updated to read from `TraitInventory.collected_traits`
- Trait `.tres` files are created manually one by one in the editor — no batch tool yet
- `PromptLabel` size and position need to be adjusted per object in the scene

---

*Built with Godot 4.6.2 - GameSeed Game Jam 2026*
