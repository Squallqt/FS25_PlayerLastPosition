# Changelog

## v1.0.0.0 — Initial Release

- Save player position on disconnect (on-foot and in-vehicle)
- Restore position on reconnect with adaptive spawn detection
- Per-player XML persistence in `modSettings/`
- Vehicle exit point capture via `getCurrentVehicle()` / `getExitNode()`
- Origin position rejection `(0, 0)` to prevent invalid saves
- Terrain bounds validation
- 15s timeout fallback for spawn detection
- Singleplayer, multiplayer, and dedicated server support
