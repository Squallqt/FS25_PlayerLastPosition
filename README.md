# FS25_PlayerLastPosition

Automatic per-player position persistence for Farming Simulator 25.

[![Version](https://img.shields.io/badge/version-1.0.1.0-blue.svg)](https://github.com/Squallqt/FS25_PlayerLastPosition/releases)
[![FS25](https://img.shields.io/badge/FS25-compatible-green.svg)](https://farming-simulator.com/)
[![Multiplayer](https://img.shields.io/badge/multiplayer-supported-success.svg)](#)

## Overview

FS25_PlayerLastPosition ensures that each player reconnects exactly where they disconnected — independently of the server save cycle. Designed for realism-focused multiplayer servers, contractor gameplay, and dedicated environments where positional continuity matters.

## Features

### Automatic Position Saving

- Captures player position and rotation instantly on disconnect
- Saves position on game save to handle singleplayer Alt+F4 edge case
- Supports **on-foot and in-vehicle** scenarios (exit node or vehicle root with offset)
- Stores data per unique user ID with nickname and userId fallbacks
- No dependency on manual savegame operations

### Intelligent Restore System

- Teleports player only after engine spawn finalization
- Detects when player leaves engine parking zone (`y > -100`)
- 15-second timeout as safety fallback
- Applies terrain height safety check to prevent sinking into ground
- Restores both position and rotation
- Server-authoritative restore logic

### Lightweight & Performance-Safe

- No periodic background saves
- Event-driven execution only (disconnect hook + spawn detection)
- Frame polling active only while restores are pending
- Negligible performance impact

### Multiplayer & Dedicated Ready

- Fully compatible with dedicated servers
- No client-side installation required
- Independent per-player XML storage in modSettings
- Savegame slot isolation with generation system to prevent stale data

## Installation

### From ModHub
Download from the official [Farming Simulator ModHub](https://www.farming-simulator.com/mods) (when published).

### Manual Installation
1. Place `FS25_PlayerLastPosition.zip` inside your FS25 `mods/` directory
2. Launch Farming Simulator 25
3. Activate the mod in the mod selection screen
4. No configuration required

## Usage

### Disconnect Behavior

When a player leaves the server:
- Position is captured from `rootNode` or vehicle exit point
- Rotation (yaw) is captured
- Data is written instantly to XML

### Save Behavior

When the game saves (manual or autosave):
- All connected players' positions are persisted via `Player.createData` hook
- Ensures position recovery after singleplayer Alt+F4

### Reconnect Behavior

When a player rejoins:
- Stored position is loaded and validated against current generation
- Engine spawn completion is detected (player leaves parking zone)
- Player is teleported to last known valid position with correct rotation

### Storage Location

```
[UserProfile]/modSettings/FS25_PlayerLastPosition/savegame<index>/<uniqueUserId>.xml
```

Each player has an independent file, scoped per savegame slot. A generation counter prevents stale positions from previous savegame resets.

## Technical

### Architecture

- **Service layer** — `PlayerLastPositionService` handles lifecycle hooks and restore logic
- **Repository layer** — `PlayerLastPositionRepository` manages XML persistence and generation tracking
- **Bootstrap** — `Main.lua` wires mission lifecycle hooks

### Hooks Used

- `Player.delete` (prepended) — capture position before vehicle ejection on disconnect
- `Player.createData` (overwritten) — capture position during engine serialization (savegame writes)
- `FSBaseMission.update` (appended) — detect spawn completion and execute pending restores

### Spawn Handling

Engine temporary spawn position: `0, -200, 0`

Restore triggers only when `playerY > -100`, preventing premature teleport during spawn parking phase. Terrain height safety ensures `safeY = max(savedY, terrainY + 0.2)`.

## Changelog

### v1.0.1.0
- Save position on game save to handle singleplayer Alt+F4 edge case
- Fix player rotation not being restored on reconnect

### v1.0.0.1
- Fix saved positions being shared across different savegames

### v1.0.0.0
- Initial release

## Support

- **Issues**: [GitHub Issues](https://github.com/Squallqt/FS25_PlayerLastPosition/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Squallqt/FS25_PlayerLastPosition/discussions)

## License

All Rights Reserved © 2026 Squallqt

## Author

**Squallqt**  
Systems Administrator & FS25 Mod Developer

---

*Not affiliated with or endorsed by GIANTS Software GmbH*
