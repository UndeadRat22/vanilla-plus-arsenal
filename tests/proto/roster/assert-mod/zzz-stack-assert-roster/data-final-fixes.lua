-- Assert: the full vanilla+ stack + vanilla-plus-arsenal loads, all five
-- turret parents contributed their prototypes, Two more Turrets deferred
-- to the standalone parents, and the vanilla SA rocket turret survived
-- Missile Defense Systems Redux (the original _sa mod removed it).
--
-- Logs E2E_CHECK markers for tests/proto/roster/expected-B.txt.

local TURRET_TYPES = { "ammo-turret", "electric-turret", "fluid-turret", "artillery-turret" }

local function find_turret(name)
  for _, t in ipairs(TURRET_TYPES) do
    local e = data.raw[t] and data.raw[t][name]
    if e then return t end
  end
  return nil
end

local EXPECTED = {
  "heavy-gun-turret",            -- heavy_gun_turret
  "vtk-cannon-turret",           -- vtk-cannon-turret
  "vtk-cannon-turret-heavy",     -- vtk-cannon-turret
  "basic-missile-defense-system",     -- missile-defense-systems-redux
  "advanced-missile-defense-system",  -- missile-defense-systems-redux
  "dw-deer-turret",              -- doeworks-deer-continued
  "rocket-turret",               -- vanilla SA rocket turret (kept by redux)
}

for _, name in ipairs(EXPECTED) do
  local t = find_turret(name)
  if t then
    log(("E2E_CHECK::turret.%s=present:%s"):format(name, t))
  else
    log(("E2E_CHECK::turret.%s=ABSENT"):format(name))
  end
end

-- Two more Turrets defers: with vtk-cannon-turret and heavy_gun_turret
-- installed, its own "cannon-turret" prototype must NOT exist.
if find_turret("cannon-turret") then
  log("E2E_CHECK::turret.cannon-turret=present (TMT defer FAILED?)")
else
  log("E2E_CHECK::turret.cannon-turret=absent")
end

-- Count the missile turret family (basic/advanced/ballistic at minimum).
local missile_count = 0
for _, t in ipairs(TURRET_TYPES) do
  for name in pairs(data.raw[t] or {}) do
    if name:find("missile-defense-system", 1, true) then
      missile_count = missile_count + 1
    end
  end
end
log(("E2E_CHECK::missile.count=%d"):format(missile_count))
log(("E2E_CHECK::missile.enough=%s"):format(tostring(missile_count >= 2)))
