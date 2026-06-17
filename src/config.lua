local cfg = {}

-- ~version (bump MARQUEE_VERSION on releases; UE4SS_VERSION updated when the loader is swapped)
cfg.MARQUEE_VERSION = "0.2.0"
cfg.UE4SS_VERSION = "4.0.0-rc1"

-- ~log
cfg.LOG_LEVEL = "debug"

-- ~timing
cfg.HUD_UPDATE_INTERVAL_MS = 400

--[[
    ============ ~hud cfg ============
--]]
cfg.HUD_MAIN_ALLIGNMENT = "topright"   -- live PB + Sync panel: top-right, near the game's score
cfg.HUD_POS_X = -10                   -- live panel offset px: - = in from the right edge
cfg.HUD_POS_Y = 290                    -- + = down from top; sits BELOW the native score block (457 / Score / xMult)
cfg.HUD_LABEL_LAYOUT = "friendly"
-- The "♪ Marquee" status badge is only drawn in the hub world. "The Encore" hub logs
-- as L_DiveBar_V2 (path .../Pagoda/Levels/DiveBar/). The live map's full path is matched
-- against these (case-insensitive substrings) — add a fragment here if there are other
-- free-roam/hub maps the badge should appear in. Logged once per change as "[hud] current map".
cfg.HUB_MAP_NAMES = { "divebar", "encore" }

--[[
    ============ ~lyrics cfg ============
--]]
cfg.LYRICS_ENABLED = true          -- master on/off (also toggled in-game with F2)
cfg.LYRICS_TICK_MS = 60            -- playhead poll interval (ms) for smooth line changes
cfg.LYRICS_OFFSET_SEC = 0.0        -- global nudge if lyrics run early/late (seconds)
cfg.LYRICS_ALIGNMENT = "top"       -- a hud_utils.Alignments key ("top"/"bottom"/"center"/...)
cfg.LYRICS_POS_X = 0               -- horizontal nudge (px)
cfg.LYRICS_POS_Y = 60              -- offset from the anchor edge (px; + = down from top, - = up from bottom)
cfg.LYRICS_FONT_SIZE = 20          -- current line
cfg.LYRICS_NEXT_FONT_SIZE = 13     -- upcoming line preview
cfg.LYRICS_SHOW_NOTICE = true      -- brief "lyrics not found" message at song start when none cached
cfg.LYRICS_NOTICE_HOLD_TICKS = 28  -- ticks held at full before fading (~1.7s at 60ms)
cfg.LYRICS_NOTICE_FADE_TICKS = 18  -- ticks spent fading out (~1.1s)
cfg.LYRICS_NUDGE_STEP = 0.1        -- seconds per F9/F10 lyric-offset nudge
cfg.LYRICS_READY_MIN_WAIT = 4      -- show "lyrics ready" only if the first line is >N sec away
cfg.LYRICS_DEBUG = false           -- true = write per-tick stage to _tick_stage.txt (crash localization)
cfg.LYRICS_DUMP_CATALOG = true     -- at boot: dump the full song-catalog manifest (_catalog.jsonl) for dadtool

--[[
    ============ ~results cfg ============
--]]
cfg.RESULTS_ALIGNMENT = "center"   -- Performance Report placement (keeps it off the native results UI)
cfg.RESULTS_POS_X = 0
cfg.RESULTS_POS_Y = 90             -- + = lower in frame (nudged down to clear the native "RESULT" banner)

--[[
    ============ ~leveling cfg ============
--]]
cfg.LEVELING_ENABLED = true        -- track XP + levels and show them on the results screen
-- ROADMAP: full-combo XP bonus (not yet implemented in leveling.XpForRun)
-- cfg.XP_FULLCOMBO_BONUS = true      -- grant a bonus for a full-combo run
-- cfg.XP_FULLCOMBO_BONUS_PCT = 10    -- +% XP when full combo
-- cfg.LEVEL_TITLES = { ... }      -- optional override of the 20 level titles
-- cfg.LEVEL_THRESHOLDS = { ... }  -- optional override of the cumulative XP curve

return cfg
