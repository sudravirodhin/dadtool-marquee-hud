# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-06-16 — Marquee fork

Fork of DiscoTracker, re-architected (see README). Re-versioned for the rebrand.

### Added
- Synced karaoke lyrics (display-only; produced by the companion **dadtool** importer — none bundled here).
- Session leveling: sync-weighted XP, levels, and titles.
- Career Stats panel (F6): most-played tracks, top scores, level.
- One-time catalog sweep that queues every song lacking lyrics for the importer.

### Changed
- **Combat tracking pivoted** from invented hit-accuracy (per-move hooking) to *reading the game's own tallies* (Score / Combo / Sync meter / Stars) — truer to the game's model and a lighter touch.
- Results report rebuilt around score-share % and a level-up hero.
- Rebranded DiscoTracker → **Marquee**.

> Verified on game build `CL-28108`; pending re-test on the June 16 2026 `CL-29008` update.

---
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

[unreleased]: https://github.com/lucashort7/dad-performance-tracker/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/lucashort7/dad-performance-tracker/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/lucashort7/dad-performance-tracker/compare/v1.1.6...v1.2.0
[1.1.6]: https://github.com/lucashort7/dad-performance-tracker/compare/44851ca618e13dcdcbf15e37ade571940b69e559...v1.1.6
