# Marquee Lyrics — LRC Generation Spec (for the Song Importer)

This is a handoff spec so the **song importer** can generate synced-lyrics (`.lrc`) files at import
time that **Marquee** (the Dead as Disco HUD mod) reads with **zero changes on the mod side**. The
importer already has everything it needs per song: the **audio**, the **`ImportedSongUniqueId`**, and
the **`startSongOffset`** from `Meta.json`.

The contract is intentionally tiny. Everything else in this doc is "how to do it well."

---

## TL;DR — the contract

For each imported song **with vocals**, write a UTF-8 LRC file:

```
<game>/Pagoda/Binaries/Win64/ue4ss/Mods/Marquee/Scripts/data/lyrics/<ImportedSongUniqueId>.lrc
```

- **Filename key** = `ImportedSongUniqueId` from `Meta.json`, as a plain string (e.g. `3029492291.lrc`).
- **Format** = standard LRC, `[mm:ss.xx]` timestamps (see §3).
- **Timing** = relative to the **audio you ship** (the trimmed `Audio.ogg`), starting at `0:00.00` (see §4).
- **Instrumental / no vocals** = write **no** file (optionally a `.miss` marker, §6).
- **Encoding** = UTF-8 (no BOM).

That's it. If you get the path, the key, and the timing right, the lyrics appear in-game.

---

## Discovering songs to generate — the catalog manifest

Marquee writes a **full catalog manifest** to the cache dir, once per game load:

```
ue4ss/Mods/Marquee/Scripts/data/lyrics/_catalog.jsonl
```

It's the **source of truth for what songs exist** and is the importer's entry point — JSONL, one object
per line, **every** in-game and imported song, overwritten each load:

```json
{"key": "<string>", "artist": "<string>", "title": "<string>", "songName": "<string>", "durationSec": <int>, "isImported": <bool>}
```

| field | meaning |
|---|---|
| `key` | the cache key = the `.lrc` filename. **imported** → `ImportedSongUniqueId`; **built-in** → asset short-name (e.g. `PS_MC_Remedy_128`) |
| `artist` / `title` / `songName` | for the lyric lookup / your reconcile pass |
| `durationSec` | song length, for duration-matched fetches |
| `isImported` | `true` = a player import (you produce these at import time, §1–§8); `false` = a packed game song (you fetch online / from the OST) |

**To find what needs lyrics:** read the manifest and generate for each entry where **neither `<key>.lrc`
nor `<key>.miss` exists** — the manifest is the *whole* catalog, so that check is your gap-finder.

There is **no per-song queue.** Marquee no longer writes `_requests.jsonl`; the manifest replaces it (a
strict superset). If your importer still reads `_requests.jsonl`, point it at `_catalog.jsonl` instead.

---

## 1. Where to write

Marquee reads from a fixed cache directory, relative to the game's `Win64` folder:

```
ue4ss/Mods/Marquee/Scripts/data/lyrics/
```

Files in that directory, **all keyed by `<key>` = the song's `ImportedSongUniqueId`**:

| File | Who writes it | Meaning |
|------|---------------|---------|
| `<key>.lrc` | **the importer** ✅ | synced lyrics (this spec) |
| `<key>.miss` | Marquee, or importer (optional) | "no synced lyrics exist" — suppresses re-fetch attempts |
| `<key>.offset` | **Marquee only — do NOT write** ⛔ | the player's live F9/F10 fine-tune nudge, in seconds |

- Create the `data/lyrics/` directory if it doesn't exist.
- **Never write `<key>.offset`.** It's the user's in-game manual calibration. If you need a baseline
  time shift, bake it into the LRC with the `[offset:]` tag instead (§4).
- The importer already locates the game install (it writes `ImportedSongs/`). Resolve the same
  `Win64` base and append the path above.

> Optional future cleanup (mod-side change, ask Greg): Marquee could instead read a co-located
> `lyrics.lrc` from each song's `ImportedSongs/<song>/` folder, keeping lyrics next to their audio.
> Not supported today — today it reads the cache path above.

---

## 2. The key (filename)

Use the **exact** `ImportedSongUniqueId` value from `Meta.json`, stringified — no hashing, no renaming.

Marquee derives the same key at runtime (`tostring(ImportedSongUniqueId)`), so the filename must match
byte-for-byte. This is deliberately rename-proof: the player can retitle a song and the lyrics still resolve.

```
Meta.json: { "ImportedSongUniqueId": 3029492291, ... }   ->   3029492291.lrc
```

---

## 3. LRC format (what Marquee's parser accepts)

Marquee ships a permissive standard-LRC parser. Supported:

```lrc
[ti:Pouring Rain (SaneBeats Remix)]   ; optional metadata tags, each on its own line
[ar:David Stewart]
[offset:0]                            ; optional, milliseconds (see §4)

[00:19.22] I said baby, I've been here before
[00:23.80] I know this room and I've walked this floor
[01:04.10][01:38.55] repeated line — multiple stamps share one line
```

Rules the parser enforces / tolerates:

- **Timestamp** = `[minutes:seconds.fraction]`. Minutes and seconds are integers; the `.fraction` is
  optional. Centiseconds (`.34`) are standard; `[00:12]` and `[00:12.5]` also parse.
- **Multiple stamps** before one line are fine (`[t1][t2] text`) — the line shows at each time.
- **Metadata tags** (`[ti:]`, `[ar:]`, `[offset:]`, etc.) must be **alone on their line**. Unknown
  tags are ignored harmlessly.
- **Enhanced/word-level stamps** (`<00:12.5>word`) are stripped down to the line — safe to include or omit.
- Lines may arrive in any order; Marquee sorts by time.
- Blank lines and lines without a stamp are ignored (good for spacing your source file).

Keep it line-level (one timestamp → one displayed line). Word-karaoke isn't rendered.

---

## 4. Timing — the trimmed-audio gotcha (read this)

Marquee syncs off the game's **playhead** (`GetTimelinePosition()`), in seconds from the start of the
audio the game is playing. Your importer **trims leading silence** (`startSongOffset` in `Meta.json`)
and ships the trimmed `Audio.ogg`. So:

**✅ Recommended: timestamp against the audio you ship.**
If you transcribe/align the **trimmed `Audio.ogg`** (the file the game actually plays), your timestamps
are already 0-based and correct. **No offset tag needed.** This is the clean path and avoids the whole problem.

**⚠️ Only if you reuse lyrics timed to the ORIGINAL (untrimmed) track** (e.g. an external LRC, or you
ran ASR on the pre-trim master): every timestamp is late by `startSongOffset`. Correct it with one tag —
positive milliseconds shift lyrics **earlier**:

```
[offset:<round(startSongOffset * 1000)>]      e.g. startSongOffset 19.198  ->  [offset:19198]
```

(`offset` sign: **positive = earlier**, negative = later. Marquee computes `time - offset/1000`.)

**Assumption + escape hatch:** this assumes the game's playhead reads `0:00` at the start of the trimmed
audio (our testing supports that). If a song ends up uniformly off by roughly `startSongOffset`, the game
is indexing the original audio — bake the `[offset:]` above. Either way, the player can fine-tune live
with **F9 (later) / F10 (earlier) / F11 (reset)**, which writes the `<key>.offset` file — so perfection
isn't required, just "close."

---

## 5. Recommended generation pipeline

This mirrors the proven `lyrics_lab` setup (CPU-only, no CUDA, no ffmpeg CLI):

1. **ASR**: `faster-whisper` (CTranslate2) `large-v3`, `int8`, CPU. Decode audio via PyAV
   (`faster_whisper.audio.decode_audio`) — no ffmpeg binary required.
2. **VAD**: set `vad_filter=False`. Silero's VAD is too aggressive on sung/EDM tracks (it ate ~half the
   vocals in testing). Instead, **manually drop obvious hallucinations** Whisper emits over instrumental
   gaps (`"We'll be right back."`, `"Thanks for watching"`, etc.). `no_speech_prob` is unreliable on
   heavy backing tracks — don't gate on it alone.
3. **Reconcile, don't trust raw ASR text**: fetch the official lyric text (e.g. the `syncedlyrics` pip
   package) and use it to fix mishearings (e.g. "sunny morning" → "Sunday morning feeling"). **Keep
   Whisper's _timestamps_, swap in the official _words_.**
   - ⚠️ An LLM can **reconcile known text to existing timestamps**, but it **cannot time audio** and must
     not invent word timings or supply unknown lyrics. Timing comes from ASR/forced-alignment only.
4. **Remix vs. original**: match the lyric source to the actual audio. (Lesson learned: a remix's DB
   entry may be a *different language/version* than the file you ship — verify before trusting it.)
5. **Emit** `<ImportedSongUniqueId>.lrc` per §1–§4.

If you later want tighter per-line timing, forced alignment (WhisperX / aeneas) is an option — but it
needs an **isolated venv** with a matched `torch`+`torchaudio` CPU build (the global env has an ABI
mismatch that breaks anything importing `torchaudio`). faster-whisper alone has been good enough.

---

## 6. Instrumentals / no vocals

- If a song has no sung vocals, **write no `.lrc`.** Marquee will simply show no lyric bar (clean).
- Optional nicety: write an **empty `<key>.miss`** file. That marks the song "known to have no lyrics,"
  so the manifest gap-check (and your own re-runs) skip it. Purely optional.
- **Do not** write an empty or placeholder `.lrc` — that renders a blank bar.

---

## 7. Legal / distribution

- **Do not bundle generated lyrics in the importer's source repo or any redistributable.** Lyrics are
  copyrighted.
- Generate **per-user, at import time, on the user's machine**, writing into that user's game cache. The
  importer already runs locally per user, so this is the natural model — same as Marquee's own offline
  fetch tool. The repo ships the *generator*, never the *lyrics*.

---

## 8. Edge cases & checklist

- **Encoding**: UTF-8, no BOM. Lyrics often contain non-ASCII (accents, em dashes) — write raw UTF-8 bytes.
- **Idempotency**: by default, **skip if `<key>.lrc` already exists** — the player may have hand-authored
  one (e.g. a custom remix). Offer a `--force`/`--regenerate` flag for deliberate overwrites.
- **Exact key**: filename must equal `tostring(ImportedSongUniqueId)` exactly. A mismatched key = silently
  no lyrics in-game.
- **Line content**: trim trailing whitespace; one lyric line per timestamp; blank source lines are fine.
- **Sanity**: first line's timestamp should be ≥ `0:00` and within the song length; a first stamp near the
  very end usually means a bad transcription.

### Per-song checklist
- [ ] Song has vocals? If no → no `.lrc` (optional `.miss`) and stop.
- [ ] Transcribed/aligned the **shipped (trimmed)** audio (0-based timing)?
- [ ] Reconciled ASR text against official lyrics?
- [ ] Wrote `data/lyrics/<ImportedSongUniqueId>.lrc`, UTF-8, standard LRC?
- [ ] Did **not** touch `<key>.offset`?

---

## Appendix — minimal valid example

`3029492291.lrc`:
```lrc
[ti:Pouring Rain (SaneBeats Remix)]
[ar:David Stewart]

[00:19.22] I said baby, I've been here before
[00:23.80] I know this room, I've walked this floor
[00:28.45] I used to live alone before I knew ya
```

In-game: at playhead 19.22s the first line shows; F9/F10 nudge if the user wants it tighter. Done.
