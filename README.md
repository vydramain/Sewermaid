# Sewermaid

**Sewermaid** is a Godot-based action-arcade game (jam project) where you play as a sewer collector cleaning up a nasty underground mess.  
Fight off toxic waste, collect valuables, avoid hazards, and see how long you can survive.

---

## Game Concept

> You are the Sewermaid — the last hope for subterranean sanitation.  
> Dive into the depths, mop up filth, fend off creatures, and reclaim the underground from biohazards.

From the Ludum Dare 58 jam concept **Sewer Collector** (your original description), Sewermaid expands on the idea: more polished visuals, more enemy types, better feedback, and persistent scoring.

Key features:
- Top-down or side view (depending on level) gameplay.
- Cleanse the sewers by collecting waste and avoiding hazards.
- Enemies and evolving difficulty.
- Power-ups, obstacles, and environmental challenges.
- Stylized pixel / minimal art aesthetic (fonts, textures, etc included in repo).

---

## Structure / Contents

Here’s a high-level view of what’s in the repo (from what I saw):  
- `.editorconfig`, `.gitattributes`, `.gitignore`  
- Asset folders: images (PNG, ASE), fonts (TTF), sound/music files  
- Godot files: `.gd` scripts, `.tscn` scenes, `project.godot`, `export_presets.cfg`  
- Scenes & systems: menu, camera, input providers, character, particle, etc.  
- UI / HUD: health bars, progress bars, etc  
- Audio: effects, background music, environmental sound  

You’ll want to flesh this out (modules, which script handles what, dependencies) as you refine.

---

## Requirements & Setup

To run/build the project:

1. Install **Godot (version compatible with repo)** — likely 4.x or 3.x depending on project file.  
2. Clone this repo:  
   ```bash
   git clone https://github.com/vydramain/Sewermaid.git
   cd Sewermaid
