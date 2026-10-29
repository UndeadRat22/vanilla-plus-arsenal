-- Roster: which turret parents are present, and what this mod governs.
--
-- Each entry is one parent (a required dependency at install time, but
-- still probed here: the portal offers an "install without dependencies"
-- escape hatch, and save-sync edge cases exist - a missing parent logs
-- and degrades cleanly). Detection runs in data-final-fixes after every
-- parent's own data stages, so mods[] is authoritative. Later balance
-- modules key off this roster instead of re-probing mods[] themselves.
--
-- Notes from the installed stack (verified 2026-10-29):
--   - TwoMoreTurrets fully defers to heavy_gun_turret and vtk-cannon-turret
--     when they are enabled (its own cannon-turret/heavy-gun-turret are
--     skipped in its data.lua), so with all parents present it adds no
--     entities of its own.
--   - missile-defense-systems-redux keeps the vanilla SA rocket turret
--     (unlike the original missile_defense_systems_sa, which removed it)
--     and hooks a prerequisite onto rocket-turret instead.
--   - The MDS Redux and DEER entries are community forks: the originals
--     could not be found on the portal anymore when the stack was built.

local ROSTER = {
  { id = "TwoMoreTurrets",                label = "Two more Turrets",                    niche = "cannon + heavy gun pair, tuned for Space Age (defers to standalone parents)" },
  { id = "heavy_gun_turret",              label = "Heavy Gun Turret",                    niche = "bullet-DPS wall" },
  { id = "vtk-cannon-turret",             label = "VortiK Cannon Turret",               niche = "single-target cannon punch" },
  { id = "missile-defense-systems-redux", label = "Missile Defense Systems Redux",      niche = "guided missile family (vanilla rocket turret kept)" },
  { id = "doeworks-deer-continued",       label = "doeWorks Rocket Artillery Continued", niche = "early-game area softening" },
}

local present, absent = 0, 0
for _, entry in ipairs(ROSTER) do
  if mods[entry.id] then
    present = present + 1
    log(("[vanilla-plus-arsenal] roster: %s (%s) present - %s")
      :format(entry.label, entry.id, entry.niche))
  else
    absent = absent + 1
    log(("[vanilla-plus-arsenal] roster: %s (%s) absent")
      :format(entry.label, entry.id))
  end
end

log(("[vanilla-plus-arsenal] roster: %d parents present, %d absent")
  :format(present, absent))

-- Exposed for later balance modules and for assert mods in tests.
vanilla_plus_arsenal = { roster = ROSTER }
