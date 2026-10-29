-- Vanilla+ Arsenal (vanilla-plus-arsenal)
--
-- Purpose:
--   A curation + balance layer over standalone turret mods for vanilla+
--   Space Age games: the turret variety of a modpack arsenal without the
--   modpack. All parents are required dependencies with version floors
--   (the in-game Install button pulls them automatically); the guards
--   below stay so a force-load without a parent (the portal's "install
--   without dependencies" path) degrades cleanly instead of crashing.
--
-- v0.1:
--   Detection and logging only. The roster module reports which parents
--   are present so that later balance modules (and the stack-load test)
--   can key off it. No prototypes are touched yet.

require("arsenal.roster")
require("arsenal.vanilla-buffs")
