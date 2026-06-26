# FS25_PlayerLastPosition

Automatically saves and restores each player's last position in Farming Simulator 25.

[![Version](https://img.shields.io/badge/version-1.0.2.0-blue.svg)](https://github.com/Squallqt/FS25_PlayerLastPosition/releases)
[![FS25](https://img.shields.io/badge/FS25-compatible-green.svg)](https://farming-simulator.com/)
[![Multiplayer](https://img.shields.io/badge/multiplayer-supported-success.svg)](#)

## Overview

FS25_PlayerLastPosition keeps track of each player's last known position and restores it when they rejoin the game.

It is designed for multiplayer servers, dedicated servers, and realism-focused gameplay where players should continue from where they left off.

## Features

* Automatically saves player position
* Restores players to their last saved position when reconnecting
* Supports players on foot and in vehicles
* Works in multiplayer and dedicated server environments
* Stores positions separately for each player
* Isolates saved positions per savegame slot
* No configuration required

## Installation

### From ModHub

Download the mod from the official [Farming Simulator ModHub](https://www.farming-simulator.com/mod.php?mod_id=354067&title=fs2025).

### Manual Installation

1. Place the downloaded `FS25_PlayerLastPosition.zip` file into your Farming Simulator 25 `mods/` folder (do not extract)
2. Start the game
3. Enable the mod in the mod selection screen

## Usage

Once enabled, the mod works automatically.

When a player leaves the game, their last position is saved.
When they rejoin, they are restored to that position after the game has finished spawning them.

## Storage

Saved player positions are stored in:

```text
[UserProfile]/modSettings/FS25_PlayerLastPosition/
```

Each savegame slot and player has its own stored data.

## Changelog

### v1.0.2.0

* Minor script optimizations
* Fixed position being lost if the game was quit without saving after reconnecting

### v1.0.1.0

* Saved position on game save

### v1.0.0.1

* Fixed saved positions being shared across different savegames

### v1.0.0.0

* Initial release

## Support

* [GitHub Issues](https://github.com/Squallqt/FS25_PlayerLastPosition/issues)
* [GitHub Discussions](https://github.com/Squallqt/FS25_PlayerLastPosition/discussions)

## License

All Rights Reserved © 2026 Squallqt

## Author

**Squallqt**

*Not affiliated with or endorsed by GIANTS Software GmbH*
