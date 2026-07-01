# Marquee Future Optimizations & Stability Design

This document details the architectural findings, optimizations, and safety guidelines compiled during the development of Marquee (specifically the `v0.4.12` to `v0.4.21` sweeps). It outlines key strategies to keep the mod 100% crash-free, stutter-free, and responsive.

---

## 1. Safety & Pointer Sanitization Guidelines

Unreal Engine 5.7 and UE4SS Lua have strict memory/threading constraints. Any stale reference to a deleted C++ pointer will cause native Access Violations (`0xc0000005`) if not sanitized correctly.

### The Stale Pointer Caching Rule
* **The Problem**: Cached actor/component/subsystem pointers (e.g. `PlayerState`, `ScoreComponent`, or `PagodaMusicSubsystem`) can survive level changes or GC passes. Their Lua userdata wrappers may still report `IsValid() == true` even if they point to memory that is no longer active for the current map.
* **The Solution**:
  1. **Dynamic Resolution**: For fast-changing actors/components, always resolve them dynamically via player controllers (`UEHelpers.GetPlayerController()`) rather than caching them locally.
  2. **Cache Cleansers**: For heavy subsystems (like `PagodaMusicSubsystem`), cache them locally for performance, but **unconditionally clear them** (`_musicSubsys = nil`) on song start (`OnSongStart`) and level cleanup (`ReceiveEndPlay`).

### Safe Lua Indexability check
Never evaluate `obj.IsValid` directly inside a `pcall` argument list like this:
```lua
-- DANGER: obj.IsValid table lookup is evaluated on the main thread BEFORE pcall is invoked.
-- If the metatable __index throws on a stale pointer, the script crashes!
local ok, res = pcall(obj.IsValid, obj)
```
Instead, always wrap the method invocation in a static, pre-allocated helper function passed directly to `pcall`:
```lua
-- SAFE & ALLOCATION-FREE:
local function call_is_valid(o)
  return o:IsValid()
end
local ok, res = pcall(call_is_valid, obj)
```

---

## 2. Memory & Performance Optimizations (Zero-Stutter Ticking)

Rhythm-combat games require butter-smooth framerates. Minor stutters (micro-stutters) are highly disruptive.

### Closure Allocation Churn
* **The Problem**: Creating anonymous functions inside high-frequency loops (like the `60ms` lyrics tick or the `100ms` HUD sync loop) forces the Lua VM to allocate memory closures. When the Lua VM's heap fills up, it triggers garbage collection pauses, causing tiny frame drops.
* **The Solution**: Avoid inline closures inside high-frequency methods:
```lua
-- AVOID (creates a closure on every execution):
pcall(function() obj:DoSomething() end)

-- PREFER (safe static helper calls):
local function call_do_something(o) o:DoSomething() end
pcall(call_do_something, obj)
```

### Event-Driven Ticking vs. Polling
* **Combo-Driven Streaks**: Perfect Streaks are now driven by hooking the game's native combat score UI event:
  `/Game/Pagoda/UI/Game/CombatScore/WBP_CombatScore.WBP_CombatScore_C:HandleComboCountChanged`
  This runs only when notes are hit or missed, guaranteeing real-time updates and zero polling cost.
* **Coarse Heartbeat Polling**: Continuous stats (BPM, Sync average, Hype, PB, Delta) are polled on a `100ms` timer loop. This provides a balance of responsiveness and low overhead.

---

## 3. Robust UTF-8 File I/O

Custom song titles and metadata often contain high-bit UTF-8 characters (e.g. Japanese kanji/hiragana).
* On Windows systems, opening files in default text mode (`"r"` / `"w"`) can translate carriage returns or corrupt multi-byte UTF-8 sequences. Under some locales, it can even cause early EOF truncation if a sequence happens to contain a byte matching the Ctrl-Z code.
* **Standard**: Always open files in binary mode (`"rb"` and `"wb"`) when reading or writing JSON manifests, offset files, or lyrics text files.

---

## 4. Hook Architecture Roadmap

For future features or deeper tracking, the following Blueprint/UFunction paths are verified stable for hooks:

| Target Hook Path | Event Purpose | Trigger Frequency |
|------------------|---------------|-------------------|
| `/Game/Pagoda/UI/Game/CombatScore/WBP_CombatScore.WBP_CombatScore_C:HandleComboCountChanged` | Note hit (combo increments) / miss (resets to 0) | Every note hit/miss |
| `/Game/Pagoda/Characters/Player/BP_PagodaPlayerController.BP_PagodaPlayerController_C:ReceiveEndPlay` | Level transition / song exit | Once per song exit |
| `/Game/Pagoda/Core/GameModes/BP_PagodaGameMode.BP_PagodaGameMode_C:ResetPlayerAttributesForRespawn` | Game start / retry in any game mode | Once per play start |
| `/Game/Pagoda/UI/Game/WBP_LevelEndScreen.WBP_LevelEndScreen_C:Construct` | Results screen constructed (final stats snapshot) | Once per song end |
| `/Game/Pagoda/UI/Game/HighScores/WBP_HighScoresList.WBP_HighScoresList_C:Construct` | High scores screen shown (alternative results trigger) | Once per song end |
