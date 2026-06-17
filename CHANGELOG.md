# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.6] - 2026-06-17

### Fixed
- Star Rating Projection Build-up: Resolved the issue where the live projected star rating `Proj` showed `—` throughout gameplay on low or normal-scoring tracks. Added standard default milestones for passing 1-star (`40k`) and 2-star (`80k`) thresholds so the rating updates progressively from the start of the song. Also implemented an asynchronous retry counter inside `Accumulate` to attempt star threshold metadata discovery up to 5 times (over 2 seconds) to handle game playthrough data initialization delays.

## [0.4.5] - 2026-06-17

## [0.4.5] - 2026-06-17

### Fixed

- Missing Move Data at Results: Fixed the issue where no move data was displayed on the results screen. Because mid-combat polling was disabled, and the game clears `CombatActionScores` immediately upon song completion before the UI constructs, the results screen hooks were reading an empty map. Restored move data capturing by polling `ReadMoveScores` safely during the song's ending window (the last 3 seconds of the track). During this window, combat has ceased, making it safe from concurrent mutation crashes, while the score component and map are still fully intact before the level transitions.

## [0.4.4] - 2026-06-17

### Fixed

- Mid-combat Counter Crash: Fixed native game crash (`0xc0000005` in `UE4SS.dll` during `luaH_getint` lookup) occurring mid-combat when countering. This was caused by iterating over the game's `CombatActionScores` `TMap` using `ForEach` in the background loop while the game thread concurrently mutated the map's C++ memory layout. Introduced a configuration toggle `cfg.POLL_MOVE_SCORES_IN_GAME` defaulting to `false` to disable mid-combat move polling, and registered a hook on `WBP_LevelEndScreen:Construct` to safely capture final scores exactly once when combat has ceased but before the score component is cleared. Added `state.__capturedFinal` flag and value guards to prevent redundant calculations and nil overwrites.

## [0.4.3] - 2026-06-17

### Added

- Default Layout Adjustments: Moved the in-game progress HUD to the bottom-left corner by default (`cfg.HUD_MAIN_ALLIGNMENT = "bottomleft"`) to prevent it from overlapping or bleeding over the game's native top-right score interface.

### Fixed

- HUD Pause State Visibility: Fixed the issue where the live stats panel would not hide when pausing the game. The script was calling the native `widget:GetVisibility()` method, which is known to throw a native exception on UE4SS v4.0.0 and abort the visibility update logic. Replaced it with a robust local Lua visibility state cache, identical to the pattern used in the lyrics HUD.

## [0.4.2] - 2026-06-17

### Fixed

- Missing Move Data on Results Screen: Restored the move breakdown on the post-song results screen. The previous version's userdata validation check was too strict and marked internal `LocalUnrealParam` wrappers (used to pass move name keys and score values during TMap iteration) as invalid because calling `:IsValid()` on polymorphic base types in Lua throws an error. Upgraded the validation helper to treat any userdata that throws an error when calling `IsValid` as valid/indexable (such as local parameters), only filtering out wrappers that explicitly return `false` (meaning nullptr).

## [0.4.1] - 2026-06-17

### Fixed

- Built-in Song Crash: Fixed native game crash (`0xc0000005` in `UE4SS.dll` during table lookup) on built-in songs (like "Remedy") by upgrading `is_indexable` to verify userdata validity via `IsValid()`. This prevents crashes when indexing non-existent metadata properties (like `StarThresholds` which only exist on imported songs).
- HUD Sync Loop Error: Resolved a repeating `attempt to call a nil value (global 'GetMusicSubsystem')` error by placing the definition of `GetMusicSubsystem` above its usage in the file.

## [0.4.0] - 2026-06-17

### Added

- Projected Star Rating: Live star projection calculation (3★, 4★, or 5★) based on current score trajectory and level thresholds.
- PB Ghost Tracker: Live score delta (+/-) showing comparison to the personal best linear score trajectory at the current timeline playhead position.
- "On Fire" Status: Dynamic Hype status indicating if average sync accuracy over the last 10 seconds is 90%+. Flared border overlay turns glowing gold/orange when "On Fire".
- Automatic Star Score Threshold Discovery: Runtime reflection lookup of star score milestones from song asset metadata and playthrough records.

## [0.3.0] - 2026-06-17

### Added

- Staged custom-compiled, stable `UE4SS` binaries inside the release package to bypass upstream loader crashes on game build `CL-29008`.
- Safe `GetFirstTArrayElement` utility in `hud_utils.lua` to fetch and unwrap `PerformedBy` elements safely via native `ForEach` iteration.

### Fixed

- Garbage Collection crash: Fixed UMG layout GC crash (`0xc0000409` in `ucrtbase.dll`) by ensuring a strict, single-parent widget layout hierarchy across all 5 HUD definition files.
- Subsystem / UObject transition crash: Added `is_indexable(obj)` verification checks to guard against property reads on nullptr/light userdata handles (`0xc0000005` in `UE4SS.dll`) during world/level transitions.
- Catalog Manifest numeric fallback: Wrapped fallback `arr[i]` TArray indexing in `pcall` blocks to protect against out-of-bounds exceptions.

## [0.2.0] - 2026-06-16 — Marquee fork

Fork of DiscoTracker, re-architected (see README). Re-versioned for the rebrand.

### Added

- Synced karaoke lyrics (display-only; produced by the companion **dadtool** importer — none bundled here).
- Session leveling: sync-weighted XP, levels, and titles.
- Career Stats panel (F6): most-played tracks, top scores, level.
- One-time catalog sweep that queues every song lacking lyrics for the importer.

### Changed

- **Combat tracking pivoted** from invented hit-accuracy (per-move hooking) to _reading the game's own tallies_ (Score / Combo / Sync meter / Stars) — truer to the game's model and a lighter touch.
- Results report rebuilt around score-share % and a level-up hero.
- Rebranded DiscoTracker → **Marquee**.

> Verified on game build `CL-28108`; pending re-test on the June 16 2026 `CL-29008` update.

* * *

_DiscoTracker upstream history below._

## [1.2.1] - 2026-06-02

### Fixed

- **In-game HUD:** Fix a bug where was showing wrong PB if didn't found.

## [1.2.0] - 2026-06-02

### Added

- **Windmill:** New Hook.

### Modified

- **Final Result HUD:** Position on screen now is fixed on top.

### Fixed

- **Dodge**: Fixed an issue detecting perfect when there wasn't enemies.
- **History:**: Fixed SAVE_PATH dir.

## [1.1.6] - 2026-06-02

### Added

- **Results Badge:** Stylized high-score indicator on the end-of-song screen.
- **Atomic History:** New JSON-based persistence system with atomic writes to prevent data corruption.
- **Combat Pipeline:** Granular tracking for Perfect vs. Normal hits across all player abilities.
- **Mocking Tool:** Developer shortcut (F6) to test results UI without full playthroughs.
- **Dynamic UI:** Real-time accuracy and combo tracking HUD during gameplay.

### Fixed

- **Invisible Widget Bug:** Resolved UI hierarchy issues where borders wouldn't render correctly.
- **Data Race Conditions:** Fixed PB comparisons failing due to late score polling.
- **Zero-score Glitch:** Fixed an issue where dying mid-song would wipe historical data.

## [1.0.0] - 2026-06-01

### Initial Release

- Performance tracking engine for Dead as Disco.
- Accuracy and Combo monitoring.
- HighScore persistence.

[unreleased]: https://github.com/sudravirodhin/dadtool-marquee-hud/compare/v0.4.5...HEAD
[0.4.5]: https://github.com/sudravirodhin/dadtool-marquee-hud/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/sudravirodhin/dadtool-marquee-hud/compare/v1.2.1...v0.4.4
[1.2.1]: https://github.com/sudravirodhin/dadtool-marquee-hud/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/sudravirodhin/dadtool-marquee-hud/compare/v1.1.6...v1.2.0
[1.1.6]: https://github.com/sudravirodhin/dadtool-marquee-hud/compare/44851ca618e13dcdcbf15e37ade571940b69e559...v1.1.6
