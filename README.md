<div align="center">
  <h1>Marquee</h1>
  <p><i>Synced lyrics + DaD-native performance tracking for <b>Dead as Disco</b> (UE4SS Lua mod)</i></p>
</div>

**Marquee** adds a karaoke-style synced-lyrics bar, performance tracking built on the game's *own* scoring (Score / Combo / Sync / Stars), session leveling, a post-song report, and a Career Stats panel to *Dead as Disco*.

It is a fork of **[DiscoTracker](https://github.com/lucashort7/dad-performance-tracker)** by *hort (lucashort7)*, rebuilt around two ideas: read the game's real combat tallies instead of inventing hit-accuracy, and put the lyrics on screen.

> ⚠️ **Status — pending re-verification.** Marquee was developed and verified working on *Dead as Disco* build `++brainjar+release-CL-28108`. It has **not yet been re-tested** against the June 16 2026 *"Summer Flames Tour"* update (`CL-29008`), which rebuilt the game binary. Treat current-version compatibility as **unverified** until confirmed.

## Features

- **Synced lyrics** — a karaoke bar that scrolls in time with the music, reading the game's playhead so it stays drift-free through pauses and restarts. Per-song timing nudge saved to disk.
- **DaD-native tracking** — *polls* the game's own combat tallies (Score, Max Combo, Music Sync meter, score multiplier, Stars) rather than hooking individual moves. No invented accuracy — it's the game's model.
- **Post-song report** — a score-share breakdown (which moves earned what, as a % of the run plus compact totals), Stars earned, sync avg/peak, and a level-up hero panel.
- **Leveling** — sync-weighted XP, levels, and titles that persist across sessions.
- **Career Stats (F6)** — most-played tracks, top scores, and your level, aggregated from local history.
- **Live glance** — a small top-right panel with your PB and live Sync %.
- **Hub badge** — a quiet "Marquee ON" indicator, shown only in The Encore.

## Why the rewrite?

DiscoTracker tracked invented hit-accuracy ("Perfect" rates, letter ranks) by hooking every combat move. Marquee instead **reads the game's own combat tallies** (the same numbers it uses for unlocks). That's truer to *Dead as Disco* — which isn't an accuracy game — and a lighter-touch design that leans on the game's existing data instead of instrumenting every move.

## Install

Marquee runs on **UE4SS** (the Unreal Engine scripting system) — it is **not** bundled here. For *Dead as Disco*, use the game-matched build from Nexus, which is the version Marquee is developed and tested against:

➡️ **[UE4SS for Dead as Disco — Nexus Mods #872](https://www.nexusmods.com/deadasdisco/mods/872?tab=files)**  ·  built on the [UE4SS project](https://github.com/UE4SS-RE/RE-UE4SS)

1. Install that UE4SS into `Dead as Disco/Pagoda/Binaries/Win64` — its `dwmapi.dll` and `ue4ss/` folder go directly in `Win64`.
2. Copy this repo's `src/` into `…/Win64/ue4ss/Mods/Marquee/Scripts/` (so `…/Marquee/Scripts/main.lua` exists).
3. Add `Marquee : 1` to `…/ue4ss/Mods/mods.txt`.
4. Launch the game.

### Lyrics (optional, and BYO)

Marquee is **display-only** for lyrics: it reads cached `.lrc` files but never fetches, generates, or bundles them — **no song lyrics ship in this repo** (copyright). To produce synced lyrics, use the companion importer **dadtool** (separate project), which drains Marquee's request queue and writes `<key>.lrc` files into `…/Marquee/Scripts/data/lyrics/`. The on-disk contract is documented in [`docs/IMPORTER_LRC_SPEC.md`](docs/IMPORTER_LRC_SPEC.md).

## Keybinds

| Key | Action |
|---|---|
| **F2** | Toggle lyrics |
| **F3** | Toggle the tracker HUD |
| **F4 / F5** | Force HUD on / off |
| **F6** | Career Stats panel |
| **F9 / F10** | Nudge the current song's lyric timing earlier / later (saved per song) |
| **F11** | Reset the current song's lyric offset |

## Configuration (`Scripts/config.lua`)

| Variable | Default | Description |
|---|---|---|
| `HUD_MAIN_ALLIGNMENT` | `"topright"` | Anchor for the live PB / Sync panel. |
| `HUD_UPDATE_INTERVAL_MS` | `400` | Live-HUD refresh rate (ms). |
| `LYRICS_ENABLED` | `true` | Master lyrics on/off (also toggled with F2). |
| `LYRICS_DUMP_CATALOG` | `true` | At boot: dump the full song-catalog manifest (`_catalog.jsonl`) for the importer (dadtool). |
| `LEVELING_ENABLED` | `true` | Track XP and levels. |

## Credits & License

- Fork of **[DiscoTracker](https://github.com/lucashort7/dad-performance-tracker)** by **hort (lucashort7)** — MIT.
- Marquee additions (synced lyrics, the score/sync tracking pivot, leveling, Career Stats) by **Gregory Conroy** ([@sudravirodhin](https://github.com/sudravirodhin)).
- Released under the **MIT License** — see [`LICENSE`](LICENSE).

*Dead as Disco* and its assets belong to their respective owners. This is an unofficial, fan-made mod, distributed with **no game assets and no song lyrics**.
