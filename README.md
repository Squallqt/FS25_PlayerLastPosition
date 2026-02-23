# FS25_PlayerLastPosition

Automatic per-player position persistence for Farming Simulator 25
multiplayer and singleplayer sessions.

[![Version](https://img.shields.io/badge/version-1.0.0.0-blue.svg)](#)
[![FS25](https://img.shields.io/badge/FS25-compatible-green.svg)](https://farming-simulator.com/)
[![Multiplayer](https://img.shields.io/badge/multiplayer-supported-success.svg)](#)
[![Server-Side](https://img.shields.io/badge/server--side-only-important.svg)](#)

## Overview

FS25_PlayerLastPosition ensures that each player reconnects exactly
where they disconnected --- independently of the server save cycle.

Designed for realism-focused multiplayer servers, contractor gameplay,
and dedicated environments where positional continuity matters.

## Features

### Automatic Position Saving

-   Captures player position instantly on disconnect
-   Supports **on-foot and in-vehicle** scenarios
-   Stores data per unique user ID
-   No dependency on manual savegame operations

### Intelligent Restore System

-   Teleports player only after engine spawn finalization
-   Adaptive detection (no fixed delay timers)
-   Prevents premature teleport during spawn parking phase
-   Server-authoritative restore logic

### Lightweight & Performance-Safe

-   No polling loops
-   No periodic background saves
-   Event-driven execution only
-   Negligible performance impact

### Multiplayer & Dedicated Ready

-   Fully compatible with dedicated servers
-   No client-side installation required
-   Independent per-player XML storage
-   No cross-player data interaction

## Installation

### From ModHub

Download from the official Farming Simulator ModHub (when published).

### Manual Installation

1.  Place `FS25_PlayerLastPosition.zip` inside your FS25 `mods/`
    directory
2.  Launch Farming Simulator 25
3.  Activate the mod in the mod selection screen
4.  No configuration required

## Usage

### Disconnect Behavior

When a player leaves the server: - Position is captured from `rootNode`
or vehicle exit point - Data is written instantly to XML

### Reconnect Behavior

When a player rejoins: - Stored position is loaded - Engine spawn
completion is detected - Player is teleported to last known valid
position

### Storage Location

    [UserProfile]/modSettings/FS25_PlayerLastPosition/<uniqueUserId>.xml

Each player has an independent file.

## Technical

### Architecture

-   Server-side overwrite hooks
-   Event-driven execution model
-   XML-based persistence (modSettings folder)
-   Defensive validation on world coordinates
-   Minimal memory footprint

### Hooks Used

-   `Player.delete` (prepended) → capture before vehicle ejection
-   `FSBaseMission.update` (appended) → detect spawn completion

### Spawn Handling

Engine temporary spawn position:

    0, -200, 0

Restore triggers only when:

    playerY > -100

Prevents premature teleport.

## Support

-   **Issues**: GitHub Issues
-   **Discussions**: GitHub Discussions

## License

All Rights Reserved © 2026 Squallqt

## Author

**Squallqt**\
Systems Administrator & FS25 Mod Developer

------------------------------------------------------------------------

*Not affiliated with or endorsed by GIANTS Software GmbH*
