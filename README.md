<div align="center">
  <h1>Marquee</h1>
  <p><i>Synced lyrics + DaD-native performance tracking for <b>Dead as Disco</b> (UE4SS Lua mod)</i></p>
</div>

> [!IMPORTANT]
> **AI Assistance Disclosure & Disclaimer**
> This project was developed with the assistance of an AI Large Language Model (LLM). It is a purely personal, non-profit project built for fun to speed up development and make it easier to enjoy the game. If you are not comfortable using software that has been touched or written with the help of AI, please do not proceed.

**Marquee** adds a karaoke-style synced-lyrics bar, performance tracking built on the game's *own* scoring (Score / Combo / Sync / Stars), session leveling, a post-song report, and a Career Stats panel to *Dead as Disco*.

It is a fork of **[DiscoTracker](https://github.com/lucashort7/dad-performance-tracker)** by *hort (lucashort7)*, rebuilt around two ideas: read the game's real combat tallies instead of inventing hit-accuracy, and put the lyrics on screen.

> ✅ **Status — Verified Stable.** Marquee has been fully tested and verified stable on *Dead as Disco* build `++brainjar+release-CL-29008` (the June 16 2026 *"Summer Flames Tour"* update) when used with our custom-compiled UE4SS loader binaries included in the full release bundle.

## Features

- **Synced lyrics** — a karaoke bar that scrolls in time with the music, reading the game's playhead so it stays drift-free through pauses and restarts. Per-song timing nudge saved to disk.
- **DaD-native tracking** — *polls* the game's own combat tallies (Score, Max Combo, Music Sync meter, score multiplier, Stars) rather than hooking individual moves. No invented accuracy — it's the game's model.
- **Post-song report** — a score-share breakdown (which moves earned what, as a % of the run plus compact totals), Stars earned, sync avg/peak, and a level-up hero panel.
- **Leveling** — sync-weighted XP, levels, and titles that persist across sessions.
- **Career Stats (F6)** — most-played tracks, top scores, and your level, aggregated from local history.
- **Live glance** — a small bottom-left panel showing your PB, live Sync %, live Star rating projection (e.g. 3★/4★/5★), PB Delta trajectory comparison, and dynamic "ON FIRE" Hype indicator.
- **Hub badge** — a quiet "Marquee ON" indicator, shown only in The Encore.

## Why the rewrite?

DiscoTracker tracked invented hit-accuracy ("Perfect" rates, letter ranks) by hooking every combat move. Marquee instead **reads the game's own combat tallies** (the same numbers it uses for unlocks). That's truer to *Dead as Disco* — which isn't an accuracy game — and a lighter-touch design that leans on the game's existing data instead of instrumenting every move.

## Install

Marquee requires **UE4SS** (the Unreal Engine scripting system). We provide three release options on our **[GitHub Releases page](https://github.com/sudravirodhin/dadtool-marquee-hud/releases)**:

### Option A: Full Bundle (Recommended)
This includes the Marquee mod and our custom-compiled, stable UE4SS loader binaries configured for *Dead as Disco* build `CL-29008`.
1. Download the full bundle (`Marquee-vX.Y.Z.zip`) from the releases page.
2. Unzip its contents directly into `Dead as Disco/Pagoda/Binaries/Win64/` (so that `dwmapi.dll` and the `ue4ss/` directory sit next to `Pagoda-Win64-Shipping.exe`).
3. Launch the game.

### Option B: Mod-Only Standalone
This contains only the `Marquee` mod folder itself, meant to be swapped into an existing UE4SS installation.
1. Download the mod-only bundle (`Marquee-STANDALONE-vX.Y.Z.zip`).
2. Unzip and place the `Marquee` folder inside your existing `ue4ss/Mods/` directory.
3. Make sure the mod is enabled by having the `enabled.txt` file in `ue4ss/Mods/Marquee/` (which is included in the zip).
4. Launch the game.

> [!WARNING]
> **No guarantee on stability is provided for the mod-only package** if used with standard or upstream UE4SS releases. Upstream loader versions are prone to native crashes (e.g. use-after-free hook faults on game build `CL-29008`). Our full bundle is custom-built and optimized to bypass these crashes.

### Option C: Custom UE4SS Binaries Only (Standalone)
Looking just for our custom UE4SS? Here it is!
1. Download the standalone custom UE4SS package (`UE4SS-custom-vX.Y.Z.zip`) from the releases page.
2. Unzip its contents directly into `Dead as Disco/Pagoda/Binaries/Win64/` (so that `dwmapi.dll` and the `ue4ss/` folder structure sit next to `Pagoda-Win64-Shipping.exe`).
3. Proceed with running any other UE4SS Lua mods without the Marquee mod.

### Lyrics (optional, and BYO)

Marquee is **display-only** for lyrics: it reads cached `.lrc` files but never fetches, generates, or bundles them — **no song lyrics ship in this repo** (copyright). To produce synced lyrics, use the companion importer **[dadtool](https://github.com/sudravirodhin/dadtool-importer)**, which drains Marquee's request queue and writes `<key>.lrc` files into `…/Marquee/Scripts/data/lyrics/`. The on-disk contract is documented in [`docs/IMPORTER_LRC_SPEC.md`](docs/IMPORTER_LRC_SPEC.md).

## Keybinds

| Key | Action |
|---|---|
| **F2** | Toggle lyrics |
| **F3** | Toggle the tracker HUD |
| **F6** | Career Stats panel |
| **F9 / F10** | Nudge the current song's lyric timing earlier / later (saved per song) |
| **F11** | Reset the current song's lyric offset |

## Configuration (`Scripts/config.lua`)

| Variable | Default | Description |
|---|---|---|
| `HUD_MAIN_ALLIGNMENT` | `"bottomleft"` | Anchor for the live PB / Sync panel. |
| `HUD_UPDATE_INTERVAL_MS` | `400` | Live-HUD refresh rate (ms). |
| `LYRICS_ENABLED` | `true` | Master lyrics on/off (also toggled with F2). |
| `LYRICS_DUMP_CATALOG` | `true` | At boot: dump the full song-catalog manifest (`_catalog.jsonl`) for the importer (dadtool). |
| `LEVELING_ENABLED` | `true` | Track XP and levels. |

## Credits & License

- Fork of **[DiscoTracker](https://github.com/lucashort7/dad-performance-tracker)** by **hort (lucashort7)** — MIT.
- Marquee additions (synced lyrics, the score/sync tracking pivot, leveling, Career Stats) by **Gregory Conroy** ([@sudravirodhin](https://github.com/sudravirodhin)).
- Released under the **MIT License** — see [`LICENSE`](LICENSE).

*Dead as Disco* and its assets belong to their respective owners. This is an unofficial, fan-made mod, distributed with **no game assets and no song lyrics**.
