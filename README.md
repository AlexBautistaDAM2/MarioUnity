# Procedural Mario World 1-1 Setup

This repository contains a Bash script designed for Fedora 42 (or similar Linux distributions) that generates the core Unity assets for a procedural recreation of *Super Mario Bros.* World 1-1 using the Unity 6.0 Universal 2D template.

## Quick start

1. Create or open your Unity 6.0 project that was created from the **Universal 2D** sample.
2. Copy the `scripts/setup_world1-1.sh` script into the project root.
3. Make the script executable:

   ```bash
   chmod +x scripts/setup_world1-1.sh
   ```

4. Run the script to generate all assets:

   ```bash
   ./scripts/setup_world1-1.sh
   ```

5. Open the project in Unity. Attach the generated scripts to empty GameObjects or prefabs as needed. Add the `RuntimeLevelBootstrap` component to an empty GameObject in a scene to spawn the entire level procedurally at runtime.

## What the script creates

- Procedural sprite generators (`ProceduralPalette`, `RuntimeMaterialLibrary`).
- Character logic for Mario and Goombas (`MarioController`, `GoombaEnemy`).
- Environment systems (`LevelBuilder`, `FlagpoleController`, `LevelFailureZone`, `ScoreManager`).
- A runtime bootstrapper that instantiates the level without any pre-existing prefabs.

You can further tweak the generated C# files to better match your gameplay needs.
