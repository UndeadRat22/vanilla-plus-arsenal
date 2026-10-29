-- Vanilla+ Arsenal (vanilla-plus-arsenal)
--
-- Purpose:
--   A curation + balance layer over standalone turret mods for vanilla+
--   Space Age games: the turret variety of a K2SO Arsenal stack without
--   the modpack. All parents are optional dependencies; the mod adapts to
--   whichever are installed.
--
-- v0.1:
--   Detection and logging only. The roster module reports which parents
--   are present so that later balance modules (and the stack-load test)
--   can key off it. No prototypes are touched yet.

require("arsenal.roster")
require("arsenal.vanilla-buffs")
