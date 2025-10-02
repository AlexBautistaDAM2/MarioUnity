#!/usr/bin/env bash
set -euo pipefail

# This script bootstraps the assets, scripts, and configuration needed to
# recreate an approximation of Super Mario Bros. World 1-1 using only
# procedurally generated sprites inside a Unity 6.0 2D URP project.
#
# It is intended to be run from the root of a Unity project that already
# contains the default folders created by the Universal 2D template.
#
# Usage:
#   chmod +x scripts/setup_world1-1.sh
#   ./scripts/setup_world1-1.sh
#
# The script is idempotent and will overwrite the generated files if they
# already exist.

PROJECT_ROOT=$(pwd)
ASSETS_DIR="$PROJECT_ROOT/Assets"
SCRIPT_ROOT="$ASSETS_DIR/Scripts"
SCENES_DIR="$ASSETS_DIR/Scenes"
MATERIALS_DIR="$ASSETS_DIR/Materials"
PREFABS_DIR="$ASSETS_DIR/Prefabs"
RESOURCES_DIR="$ASSETS_DIR/Resources"
DATA_DIR="$ASSETS_DIR/Data"

mkdir -p "$SCRIPT_ROOT/Core"
mkdir -p "$SCRIPT_ROOT/Characters"
mkdir -p "$SCRIPT_ROOT/Environment"
mkdir -p "$MATERIALS_DIR"
mkdir -p "$PREFABS_DIR"
mkdir -p "$RESOURCES_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$SCENES_DIR"

cat <<'CS' > "$SCRIPT_ROOT/Core/ProceduralPalette.cs"
using UnityEngine;

namespace MarioWorld.Core
{
    /// <summary>
    /// Generates NES-inspired textures and materials entirely from code so no external sprites are required.
    /// </summary>
    public static class ProceduralPalette
    {
        private const int PixelScale = 16;

        public static Material CreateMarioMaterial()
        {
            var texture = new Texture2D(PixelScale, PixelScale, TextureFormat.RGBA32, false)
            {
                filterMode = FilterMode.Point
            };

            var transparent = new Color32(0, 0, 0, 0);
            var red = new Color32(228, 0, 15, 255);
            var blue = new Color32(48, 60, 255, 255);
            var brown = new Color32(181, 83, 40, 255);
            var skin = new Color32(255, 206, 120, 255);

            var pixels = new Color32[PixelScale * PixelScale];

            for (int y = 0; y < PixelScale; y++)
            {
                for (int x = 0; x < PixelScale; x++)
                {
                    pixels[x + y * PixelScale] = transparent;
                }
            }

            void FillRect(int x, int y, int w, int h, Color32 color)
            {
                for (int px = x; px < x + w; px++)
                {
                    for (int py = y; py < y + h; py++)
                    {
                        pixels[px + py * PixelScale] = color;
                    }
                }
            }

            // Hat
            FillRect(4, 12, 8, 1, red);
            FillRect(3, 11, 10, 1, red);
            FillRect(3, 10, 10, 1, red);
            FillRect(4, 9, 8, 1, red);

            // Face
            FillRect(4, 8, 8, 1, skin);
            FillRect(3, 7, 2, 1, skin);
            FillRect(7, 7, 2, 1, skin);
            FillRect(11, 7, 2, 1, skin);
            FillRect(3, 6, 10, 1, skin);

            // Body
            FillRect(4, 4, 8, 3, red);
            FillRect(3, 3, 10, 1, red);

            // Legs
            FillRect(3, 1, 4, 2, blue);
            FillRect(9, 1, 4, 2, blue);

            // Boots
            FillRect(3, 0, 4, 1, brown);
            FillRect(9, 0, 4, 1, brown);

            texture.SetPixels32(pixels);
            texture.Apply();

            var material = new Material(Shader.Find("Universal Render Pipeline/Sprite/Lit"));
            material.mainTexture = texture;
            material.color = Color.white;
            return material;
        }

        public static Material CreateGoombaMaterial()
        {
            var texture = new Texture2D(PixelScale, PixelScale, TextureFormat.RGBA32, false)
            {
                filterMode = FilterMode.Point
            };

            var transparent = new Color32(0, 0, 0, 0);
            var brown = new Color32(181, 83, 40, 255);
            var darkBrown = new Color32(130, 62, 31, 255);
            var white = new Color32(255, 255, 255, 255);
            var black = new Color32(0, 0, 0, 255);

            var pixels = new Color32[PixelScale * PixelScale];
            for (int i = 0; i < pixels.Length; i++)
            {
                pixels[i] = transparent;
            }

            void FillRect(int x, int y, int w, int h, Color32 color)
            {
                for (int px = x; px < x + w; px++)
                {
                    for (int py = y; py < y + h; py++)
                    {
                        pixels[px + py * PixelScale] = color;
                    }
                }
            }

            FillRect(2, 6, 12, 6, brown);
            FillRect(4, 4, 8, 2, brown);
            FillRect(4, 2, 8, 2, darkBrown);

            // Eyes
            FillRect(6, 6, 2, 4, white);
            FillRect(8, 6, 2, 4, white);
            FillRect(6, 6, 1, 2, black);
            FillRect(9, 6, 1, 2, black);

            // Feet
            FillRect(4, 0, 4, 2, darkBrown);
            FillRect(8, 0, 4, 2, darkBrown);

            texture.SetPixels32(pixels);
            texture.Apply();

            var material = new Material(Shader.Find("Universal Render Pipeline/Sprite/Lit"));
            material.mainTexture = texture;
            material.color = Color.white;
            return material;
        }

        public static Material CreateTileMaterial(Color32 baseColor)
        {
            var texture = new Texture2D(PixelScale, PixelScale, TextureFormat.RGBA32, false)
            {
                filterMode = FilterMode.Point
            };

            var pixels = new Color32[PixelScale * PixelScale];
            for (int y = 0; y < PixelScale; y++)
            {
                for (int x = 0; x < PixelScale; x++)
                {
                    byte shade = (byte)(baseColor.r - (y % 2 == 0 ? 0 : 12));
                    pixels[x + y * PixelScale] = new Color32(shade, (byte)(baseColor.g - (y % 2 == 0 ? 0 : 12)), (byte)(baseColor.b - (y % 2 == 0 ? 0 : 12)), 255);
                }
            }

            texture.SetPixels32(pixels);
            texture.Apply();

            var material = new Material(Shader.Find("Universal Render Pipeline/Sprite/Lit"));
            material.mainTexture = texture;
            material.color = Color.white;
            return material;
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Core/RuntimeMaterialLibrary.cs"
using System.Collections.Generic;
using UnityEngine;

namespace MarioWorld.Core
{
    /// <summary>
    /// Cache of materials created procedurally at runtime so sprites are only generated once.
    /// </summary>
    public static class RuntimeMaterialLibrary
    {
        private static Material _mario;
        private static Material _goomba;
        private static Material _ground;
        private static Material _brick;
        private static Material _question;
        private static Material _flag;

        private static readonly Dictionary<string, Material> CustomMaterials = new();

        public static Material Mario => _mario ??= ProceduralPalette.CreateMarioMaterial();
        public static Material Goomba => _goomba ??= ProceduralPalette.CreateGoombaMaterial();

        public static Material Ground => _ground ??= ProceduralPalette.CreateTileMaterial(new Color32(221, 160, 82, 255));
        public static Material Brick => _brick ??= ProceduralPalette.CreateTileMaterial(new Color32(205, 102, 29, 255));
        public static Material Question => _question ??= ProceduralPalette.CreateTileMaterial(new Color32(255, 205, 60, 255));
        public static Material Flag => _flag ??= ProceduralPalette.CreateTileMaterial(new Color32(89, 204, 73, 255));

        public static Material GetOrCreate(string key, Color32 color)
        {
            if (!CustomMaterials.TryGetValue(key, out var material))
            {
                material = ProceduralPalette.CreateTileMaterial(color);
                CustomMaterials[key] = material;
            }

            return material;
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Characters/MarioController.cs"
using UnityEngine;
using MarioWorld.Environment;

namespace MarioWorld.Characters
{
    [RequireComponent(typeof(Rigidbody2D))]
    [RequireComponent(typeof(Collider2D))]
    public class MarioController : MonoBehaviour
    {
        [SerializeField] private float moveSpeed = 6f;
        [SerializeField] private float jumpForce = 12f;
        [SerializeField] private Transform feet;
        [SerializeField] private LayerMask groundMask;

        private Rigidbody2D _rb;
        private bool _isJumpQueued;
        private bool _isGrounded;

        private void Awake()
        {
            _rb = GetComponent<Rigidbody2D>();
            _rb.freezeRotation = true;
        }

        private void Update()
        {
            float input = Input.GetAxisRaw("Horizontal");
            var velocity = _rb.velocity;
            velocity.x = input * moveSpeed;
            _rb.velocity = velocity;

            if (Input.GetButtonDown("Jump"))
            {
                _isJumpQueued = true;
            }
        }

        private void FixedUpdate()
        {
            _isGrounded = Physics2D.OverlapCircle(feet.position, 0.1f, groundMask);

            if (_isJumpQueued && _isGrounded)
            {
                _rb.velocity = new Vector2(_rb.velocity.x, 0f);
                _rb.AddForce(Vector2.up * jumpForce, ForceMode2D.Impulse);
            }

            _isJumpQueued = false;
        }

        private void OnCollisionEnter2D(Collision2D collision)
        {
            if (!collision.collider.TryGetComponent(out GoombaEnemy goomba))
            {
                return;
            }

            foreach (var contact in collision.contacts)
            {
                if (Vector2.Dot(contact.normal, Vector2.up) > 0.5f)
                {
                    goomba.Squash();
                    _rb.velocity = new Vector2(_rb.velocity.x, 0f);
                    _rb.AddForce(Vector2.up * (jumpForce * 0.75f), ForceMode2D.Impulse);
                    return;
                }
            }

            LevelFailureZone.RestartLevel();
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Characters/GoombaEnemy.cs"
using UnityEngine;
using MarioWorld.Environment;

namespace MarioWorld.Characters
{
    [RequireComponent(typeof(Rigidbody2D))]
    [RequireComponent(typeof(Collider2D))]
    public class GoombaEnemy : MonoBehaviour
    {
        [SerializeField] private float speed = 1.2f;
        [SerializeField] private LayerMask groundMask;
        [SerializeField] private Transform groundCheck;

        private Rigidbody2D _rb;
        private Vector2 _direction = Vector2.left;
        private bool _isDead;

        private void Awake()
        {
            _rb = GetComponent<Rigidbody2D>();
            _rb.freezeRotation = true;
        }

        private void FixedUpdate()
        {
            if (_isDead)
            {
                return;
            }

            var velocity = _rb.velocity;
            velocity.x = _direction.x * speed;
            _rb.velocity = velocity;

            bool hasGround = Physics2D.Raycast(groundCheck.position, Vector2.down, 0.25f, groundMask);
            if (!hasGround)
            {
                Flip();
            }
        }

        private void OnCollisionEnter2D(Collision2D collision)
        {
            if (_isDead)
            {
                return;
            }

            if (!collision.collider.CompareTag("Player"))
            {
                Flip();
            }
        }

        private void Flip()
        {
            _direction *= -1f;
            var scale = transform.localScale;
            scale.x = Mathf.Abs(scale.x) * Mathf.Sign(_direction.x);
            transform.localScale = scale;
        }

        public void Squash()
        {
            if (_isDead)
            {
                return;
            }

            _isDead = true;
            GoombaEvents.RaiseSquashed();
            Destroy(gameObject, 0.05f);
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Environment/LevelFailureZone.cs"
using UnityEngine;
using UnityEngine.SceneManagement;

namespace MarioWorld.Environment
{
    /// <summary>
    /// Reloads the current scene when the player hits the fail volume.
    /// </summary>
    public class LevelFailureZone : MonoBehaviour
    {
        public static void RestartLevel()
        {
            var scene = SceneManager.GetActiveScene();
            SceneManager.LoadScene(scene.name);
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Environment/FlagpoleController.cs"
using UnityEngine;
using UnityEngine.SceneManagement;

namespace MarioWorld.Environment
{
    [RequireComponent(typeof(Collider2D))]
    public class FlagpoleController : MonoBehaviour
    {
        [SerializeField] private string nextSceneName = "Level1";

        private void OnTriggerEnter2D(Collider2D other)
        {
            if (!other.CompareTag("Player"))
            {
                return;
            }

            FlagpoleEvents.RaiseFlagReached();
            SceneManager.LoadScene(nextSceneName);
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Environment/ScoreManager.cs"
using UnityEngine;
using UnityEngine.UI;

namespace MarioWorld.Environment
{
    public class ScoreManager : MonoBehaviour
    {
        [SerializeField] private Text scoreLabel;
        [SerializeField] private int stompScore = 100;
        [SerializeField] private int flagScore = 500;

        private int _score;

        private void Awake()
        {
            UpdateLabel();
        }

        private void OnEnable()
        {
            GoombaEvents.GoombaSquashed += HandleGoombaSquashed;
            FlagpoleEvents.FlagReached += HandleFlagReached;
        }

        private void OnDisable()
        {
            GoombaEvents.GoombaSquashed -= HandleGoombaSquashed;
            FlagpoleEvents.FlagReached -= HandleFlagReached;
        }

        private void HandleGoombaSquashed()
        {
            AddScore(stompScore);
        }

        private void HandleFlagReached()
        {
            AddScore(flagScore);
        }

        private void AddScore(int amount)
        {
            _score += amount;
            UpdateLabel();
        }

        private void UpdateLabel()
        {
            if (scoreLabel != null)
            {
                scoreLabel.text = $"SCORE {_score:D6}";
            }
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Environment/GoombaEvents.cs"
using System;

namespace MarioWorld.Environment
{
    public static class GoombaEvents
    {
        public static event Action GoombaSquashed;

        public static void RaiseSquashed()
        {
            GoombaSquashed?.Invoke();
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Environment/FlagpoleEvents.cs"
using System;

namespace MarioWorld.Environment
{
    public static class FlagpoleEvents
    {
        public static event Action FlagReached;

        public static void RaiseFlagReached()
        {
            FlagReached?.Invoke();
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Environment/LevelBuilder.cs"
using System.Collections.Generic;
using MarioWorld.Characters;
using MarioWorld.Core;
using UnityEngine;

namespace MarioWorld.Environment
{
    /// <summary>
    /// Programmatically builds the level geometry, enemies, and decorative pieces using procedural materials.
    /// </summary>
    public class LevelBuilder : MonoBehaviour
    {
        [Header("Prefabs")]
        [SerializeField] private GameObject marioPrefab;
        [SerializeField] private GameObject goombaPrefab;
        [SerializeField] private GameObject flagPrefab;
        [SerializeField] private GameObject groundPrefab;
        [SerializeField] private GameObject brickPrefab;
        [SerializeField] private GameObject questionPrefab;
        [SerializeField] private GameObject pipePrefab;
        [SerializeField] private GameObject failZonePrefab;

        [Header("Layout")]
        [SerializeField] private Vector2Int levelSize = new(220, 14);
        [SerializeField] private Vector2 tileSize = new(1f, 1f);

        private readonly List<GameObject> _spawnedObjects = new();

        private void Start()
        {
            ClearLevel();
            BuildLevel();
        }

        private void ClearLevel()
        {
            foreach (var spawned in _spawnedObjects)
            {
                if (spawned != null)
                {
                    Destroy(spawned);
                }
            }

            _spawnedObjects.Clear();
        }

        private void BuildLevel()
        {
            BuildGround();
            BuildTerrainFeatures();
            SpawnMario();
            SpawnGoombas();
            SpawnFlagpole();
            SpawnFailVolume();
        }

        private void BuildGround()
        {
            for (int x = 0; x < levelSize.x; x++)
            {
                for (int y = 0; y < 2; y++)
                {
                    var tile = Instantiate(groundPrefab, new Vector3(x * tileSize.x, y * tileSize.y, 0f), Quaternion.identity, transform);
                    ApplyMaterial(tile, RuntimeMaterialLibrary.Ground);
                    _spawnedObjects.Add(tile);
                }
            }
        }

        private void BuildTerrainFeatures()
        {
            void SpawnBrick(int x, int y)
            {
                var brick = Instantiate(brickPrefab, new Vector3(x * tileSize.x, y * tileSize.y, 0f), Quaternion.identity, transform);
                ApplyMaterial(brick, RuntimeMaterialLibrary.Brick);
                _spawnedObjects.Add(brick);
            }

            void SpawnQuestion(int x, int y)
            {
                var question = Instantiate(questionPrefab, new Vector3(x * tileSize.x, y * tileSize.y, 0f), Quaternion.identity, transform);
                ApplyMaterial(question, RuntimeMaterialLibrary.Question);
                _spawnedObjects.Add(question);
            }

            int[,] brickFormations =
            {
                { 22, 8 }, { 23, 8 }, { 24, 8 }, { 25, 8 },
                { 27, 8 }, { 28, 8 }, { 29, 8 },
                { 33, 8 }, { 33, 12 },
                { 74, 8 }, { 75, 8 }, { 76, 8 }, { 77, 8 }
            };

            for (int i = 0; i < brickFormations.GetLength(0); i++)
            {
                SpawnBrick(brickFormations[i, 0], brickFormations[i, 1]);
            }

            int[,] questionBlocks =
            {
                { 22, 12 }, { 24, 12 }, { 26, 12 }, { 75, 12 }
            };

            for (int i = 0; i < questionBlocks.GetLength(0); i++)
            {
                SpawnQuestion(questionBlocks[i, 0], questionBlocks[i, 1]);
            }

            BuildPipe(56, 2, 2);
            BuildPipe(64, 2, 3);
            BuildPipe(72, 2, 4);
        }

        private void BuildPipe(int startX, int startY, int height)
        {
            for (int y = startY; y < startY + height; y++)
            {
                for (int x = startX; x < startX + 2; x++)
                {
                    var pipe = Instantiate(pipePrefab, new Vector3(x * tileSize.x, y * tileSize.y, 0f), Quaternion.identity, transform);
                    var material = RuntimeMaterialLibrary.GetOrCreate($"pipe_{height}", new Color32(52, 152, 74, 255));
                    ApplyMaterial(pipe, material);
                    _spawnedObjects.Add(pipe);
                }
            }
        }

        private void SpawnMario()
        {
            var mario = Instantiate(marioPrefab, new Vector3(2f, 4f, 0f), Quaternion.identity);
            ApplyMaterial(mario, RuntimeMaterialLibrary.Mario);
            mario.tag = "Player";
            _spawnedObjects.Add(mario);
        }

        private void SpawnGoombas()
        {
            float[] positions = { 30f, 40f, 70f };
            foreach (var pos in positions)
            {
                var goomba = Instantiate(goombaPrefab, new Vector3(pos, 4f, 0f), Quaternion.identity);
                ApplyMaterial(goomba, RuntimeMaterialLibrary.Goomba);
                _spawnedObjects.Add(goomba);
            }
        }

        private void SpawnFlagpole()
        {
            var flag = Instantiate(flagPrefab, new Vector3((levelSize.x - 5) * tileSize.x, 6f, 0f), Quaternion.identity);
            ApplyMaterial(flag, RuntimeMaterialLibrary.Flag);
            _spawnedObjects.Add(flag);
        }

        private void SpawnFailVolume()
        {
            var failZone = Instantiate(failZonePrefab, new Vector3(levelSize.x * tileSize.x / 2f, -5f, 0f), Quaternion.identity);
            _spawnedObjects.Add(failZone);
        }

        private static void ApplyMaterial(GameObject go, Material material)
        {
            var renderer = go.GetComponent<SpriteRenderer>();
            if (renderer != null)
            {
                renderer.material = material;
            }
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Environment/PrefabFactory.cs"
using MarioWorld.Characters;
using MarioWorld.Core;
using UnityEngine;

namespace MarioWorld.Environment
{
    /// <summary>
    /// Builds simple prefabs at runtime so the scene can remain lightweight.
    /// </summary>
    public class PrefabFactory : MonoBehaviour
    {
        [SerializeField] private PhysicsMaterial2D physicsMaterial;

        public GameObject CreateMarioPrefab()
        {
            var go = new GameObject("Mario");
            var renderer = go.AddComponent<SpriteRenderer>();
            renderer.material = RuntimeMaterialLibrary.Mario;
            renderer.sortingOrder = 5;

            var rb = go.AddComponent<Rigidbody2D>();
            rb.gravityScale = 3f;

            var collider = go.AddComponent<CapsuleCollider2D>();
            collider.direction = CapsuleDirection2D.Vertical;
            collider.size = new Vector2(0.6f, 1.1f);
            collider.sharedMaterial = physicsMaterial;

            var mario = go.AddComponent<MarioController>();
            mario.GetType();

            var feet = new GameObject("Feet");
            feet.transform.SetParent(go.transform);
            feet.transform.localPosition = new Vector3(0f, -0.55f, 0f);

            var marioController = go.GetComponent<MarioController>();
            typeof(MarioController).GetField("feet", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(marioController, feet.transform);
            typeof(MarioController).GetField("groundMask", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(marioController, LayerMask.GetMask("Ground"));

            return go;
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Core/Bootstrap.cs"
using MarioWorld.Characters;
using MarioWorld.Environment;
using UnityEngine;

namespace MarioWorld.Core
{
    public class Bootstrap : MonoBehaviour
    {
        [SerializeField] private LevelBuilder levelBuilder;
        [SerializeField] private GameObject marioPrefab;
        [SerializeField] private GameObject goombaPrefab;
        [SerializeField] private GameObject flagPrefab;
        [SerializeField] private GameObject groundPrefab;
        [SerializeField] private GameObject brickPrefab;
        [SerializeField] private GameObject questionPrefab;
        [SerializeField] private GameObject pipePrefab;
        [SerializeField] private GameObject failZonePrefab;

        private void Awake()
        {
            levelBuilder.gameObject.SetActive(true);
            ConfigurePrefabs();
        }

        private void ConfigurePrefabs()
        {
            AssignMaterial(marioPrefab, RuntimeMaterialLibrary.Mario);
            AssignMaterial(goombaPrefab, RuntimeMaterialLibrary.Goomba);
            AssignMaterial(flagPrefab, RuntimeMaterialLibrary.Flag);
            AssignMaterial(groundPrefab, RuntimeMaterialLibrary.Ground);
            AssignMaterial(brickPrefab, RuntimeMaterialLibrary.Brick);
            AssignMaterial(questionPrefab, RuntimeMaterialLibrary.Question);
            AssignMaterial(pipePrefab, RuntimeMaterialLibrary.GetOrCreate("pipe_default", new Color32(52, 152, 74, 255)));
        }

        private static void AssignMaterial(GameObject prefab, Material material)
        {
            if (prefab == null)
            {
                return;
            }

            if (prefab.TryGetComponent(out SpriteRenderer renderer))
            {
                renderer.material = material;
            }
        }
    }
}
CS

cat <<'TXT' > "$DATA_DIR/README_LEVEL.txt"
This folder intentionally stores data generated by LevelBuilder. The runtime scripts will keep track of any procedurally created textures and assets.
TXT

cat <<'MD' > "$PROJECT_ROOT/README.md"
# Procedural Mario World 1-1 Setup

This repository contains a shell script that procedurally generates all of the core scripts required to approximate the first level of **Super Mario Bros.** inside a **Unity 6.0** Universal 2D project.

## Requirements

- Fedora 42 (or any modern Linux distribution with Bash, `mkdir`, and `cat`).
- Unity 6.0 with the Universal Render Pipeline 2D template.

## Usage

1. Create a new Unity project using the *2D (URP)* template.
2. Copy the `scripts/setup_world1-1.sh` file into the root of that project (next to the `Assets` folder).
3. Make the script executable:

   ```bash
   chmod +x scripts/setup_world1-1.sh
   ```

4. Run the script:

   ```bash
   ./scripts/setup_world1-1.sh
   ```

5. Open the project in Unity. The generated scripts will appear under `Assets/Scripts`. Attach them to prefabs and a simple scene as desired. The `LevelBuilder` component can be placed on an empty GameObject to construct the level at runtime.

## Highlights

- **Procedural sprites**: `ProceduralPalette` and `RuntimeMaterialLibrary` generate NES-style sprites using `Texture2D` APIs. No external images are required.
- **Gameplay loop**: `MarioController`, `GoombaEnemy`, `FlagpoleController`, and `LevelFailureZone` replicate the essential mechanics of the first level.
- **Level layout**: `LevelBuilder` builds ground tiles, question blocks, brick formations, pipes, Goombas, and the final flagpole using prefab references.
- **Scoring**: `ScoreManager` listens for events to provide classic scoring feedback.

You are free to expand the script to cover additional prefabs, UI elements, and camera setups depending on your project's needs.
MD

cat <<'CS' > "$SCRIPT_ROOT/Environment/ProceduralPrefabLibrary.cs"
using UnityEngine;
using MarioWorld.Core;
using MarioWorld.Characters;

namespace MarioWorld.Environment
{
    /// <summary>
    /// Provides simple programmatic prefabs when you do not want to rely on Unity editor-created assets.
    /// </summary>
    public static class ProceduralPrefabLibrary
    {
        public static GameObject CreateGroundTile()
        {
            return CreateSpriteTile("GroundTile", RuntimeMaterialLibrary.Ground, new Vector2(1f, 1f));
        }

        public static GameObject CreateBrickTile()
        {
            return CreateSpriteTile("BrickTile", RuntimeMaterialLibrary.Brick, new Vector2(1f, 1f));
        }

        public static GameObject CreateQuestionTile()
        {
            var tile = CreateSpriteTile("QuestionTile", RuntimeMaterialLibrary.Question, new Vector2(1f, 1f));
            tile.AddComponent<BoxCollider2D>();
            return tile;
        }

        public static GameObject CreatePipeTile()
        {
            return CreateSpriteTile("PipeTile", RuntimeMaterialLibrary.GetOrCreate("pipe_tile", new Color32(52, 152, 74, 255)), new Vector2(1f, 1f));
        }

        public static GameObject CreateFailZone()
        {
            var failZone = new GameObject("FailZone");
            var collider = failZone.AddComponent<BoxCollider2D>();
            collider.isTrigger = true;
            failZone.AddComponent<LevelFailureZone>();
            return failZone;
        }

        public static GameObject CreateFlagpole()
        {
            var flag = CreateSpriteTile("Flagpole", RuntimeMaterialLibrary.Flag, new Vector2(0.5f, 5f));
            flag.AddComponent<BoxCollider2D>().isTrigger = true;
            flag.AddComponent<FlagpoleController>();
            return flag;
        }

        public static GameObject CreateMario()
        {
            var mario = new GameObject("Mario");
            var renderer = mario.AddComponent<SpriteRenderer>();
            renderer.material = RuntimeMaterialLibrary.Mario;
            renderer.drawMode = SpriteDrawMode.Sliced;
            renderer.size = new Vector2(1f, 1.5f);

            var rb = mario.AddComponent<Rigidbody2D>();
            rb.gravityScale = 3f;

            var collider = mario.AddComponent<CapsuleCollider2D>();
            collider.size = new Vector2(0.6f, 1.4f);
            collider.direction = CapsuleDirection2D.Vertical;

            var controller = mario.AddComponent<MarioController>();
            var feet = new GameObject("Feet").transform;
            feet.SetParent(mario.transform);
            feet.localPosition = new Vector3(0f, -0.7f, 0f);

            typeof(MarioController).GetField("feet", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(controller, feet);
            typeof(MarioController).GetField("groundMask", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(controller, LayerMask.GetMask("Ground"));

            mario.tag = "Player";
            return mario;
        }

        public static GameObject CreateGoomba()
        {
            var goomba = new GameObject("Goomba");
            var renderer = goomba.AddComponent<SpriteRenderer>();
            renderer.material = RuntimeMaterialLibrary.Goomba;
            renderer.size = new Vector2(1f, 1f);

            var rb = goomba.AddComponent<Rigidbody2D>();
            rb.gravityScale = 3f;

            var collider = goomba.AddComponent<CapsuleCollider2D>();
            collider.size = new Vector2(0.8f, 0.8f);

            var groundCheck = new GameObject("GroundCheck").transform;
            groundCheck.SetParent(goomba.transform);
            groundCheck.localPosition = new Vector3(0f, -0.6f, 0f);

            var goombaEnemy = goomba.AddComponent<GoombaEnemy>();
            typeof(GoombaEnemy).GetField("groundCheck", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(goombaEnemy, groundCheck);
            typeof(GoombaEnemy).GetField("groundMask", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(goombaEnemy, LayerMask.GetMask("Ground"));

            return goomba;
        }

        private static GameObject CreateSpriteTile(string name, Material material, Vector2 size)
        {
            var go = new GameObject(name);
            var renderer = go.AddComponent<SpriteRenderer>();
            renderer.material = material;
            renderer.drawMode = SpriteDrawMode.Sliced;
            renderer.size = size;
            go.AddComponent<BoxCollider2D>();
            return go;
        }
    }
}
CS

cat <<'CS' > "$SCRIPT_ROOT/Environment/RuntimeLevelBootstrap.cs"
using UnityEngine;
using MarioWorld.Core;

namespace MarioWorld.Environment
{
    /// <summary>
    /// A helper MonoBehaviour that instantiates programmatic prefabs and feeds them into the LevelBuilder.
    /// This allows the level to be generated without any manual setup in the Unity editor.
    /// </summary>
    public class RuntimeLevelBootstrap : MonoBehaviour
    {
        [SerializeField] private LevelBuilder levelBuilder;

        private void Awake()
        {
            if (levelBuilder == null)
            {
                levelBuilder = gameObject.AddComponent<LevelBuilder>();
            }

            levelBuilder.enabled = false;

            var mario = ProceduralPrefabLibrary.CreateMario();
            var goomba = ProceduralPrefabLibrary.CreateGoomba();
            var flag = ProceduralPrefabLibrary.CreateFlagpole();
            var ground = ProceduralPrefabLibrary.CreateGroundTile();
            var brick = ProceduralPrefabLibrary.CreateBrickTile();
            var question = ProceduralPrefabLibrary.CreateQuestionTile();
            var pipe = ProceduralPrefabLibrary.CreatePipeTile();
            var failZone = ProceduralPrefabLibrary.CreateFailZone();

            levelBuilder.GetType().GetField("marioPrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(levelBuilder, mario);
            levelBuilder.GetType().GetField("goombaPrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(levelBuilder, goomba);
            levelBuilder.GetType().GetField("flagPrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(levelBuilder, flag);
            levelBuilder.GetType().GetField("groundPrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(levelBuilder, ground);
            levelBuilder.GetType().GetField("brickPrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(levelBuilder, brick);
            levelBuilder.GetType().GetField("questionPrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(levelBuilder, question);
            levelBuilder.GetType().GetField("pipePrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(levelBuilder, pipe);
            levelBuilder.GetType().GetField("failZonePrefab", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance)?.SetValue(levelBuilder, failZone);

            levelBuilder.enabled = true;
        }
    }
}
CS

chmod +x "$PROJECT_ROOT/scripts/setup_world1-1.sh"

echo "Generated procedural Mario World 1-1 scripts."
