-- Vanilla turret buffs (v0.2, K2-style).
--
-- The vanilla pair falls behind the arsenal parents: the laser turret
-- tops out at 24 range while the modded ladder starts at 35 (vtk cannon,
-- blue science - the same tier as the laser), and the gun turret is
-- replaced wholesale by heavy-gun-turret on Vulcanus.
--
-- Buffs instead of nerfs:
--   gun-turret:   damage_modifier 1 -> 2 (24 -> 48 per uranium round,
--                 480 DPS), range 18 -> 24
--   laser-turret: damage_modifier 2 -> 4 (20 -> 40 per shot, 60 DPS),
--                 range 24 -> 28
--
-- The damage buffs are per-shot, not fire rate, so the bullet belt feeds
-- half as many magazines for the same kills (the K2 trick). 24 keeps the
-- gun turret under the modded ladder (vtk 35) while doubling its bite;
-- the laser's 28 likewise. heavy-gun-turret is untouched - it remains the
-- DPS wall you graduate to on Vulcanus, and demolishers stay laser-
-- immune (that is basegame design, not ours to fix).

local function apply(label, entity, fields)
  if type(entity) ~= "table" then
    log(("[vanilla-plus-arsenal] buffs: %s prototype not found, skipped")
      :format(label))
    return false
  end
  local ap = entity.attack_parameters
  if type(ap) ~= "table" then
    log(("[vanilla-plus-arsenal] buffs: %s has no attack_parameters, skipped")
      :format(label))
    return false
  end
  for k, v in pairs(fields) do
    ap[k] = v
  end
  -- keep the laser's inline beam delivery length in sync with the range
  if fields.range and type(ap.ammo_type) == "table"
    and type(ap.ammo_type.action) == "table"
    and type(ap.ammo_type.action.action_delivery) == "table" then
    ap.ammo_type.action.action_delivery.max_length = fields.range
  end
  log(("[vanilla-plus-arsenal] buffs: %s range=%s damage_modifier=%s")
    :format(label, tostring(ap.range), tostring(ap.damage_modifier or 1)))
  return true
end

local patched = 0

local gun_setting = settings.startup["vanilla-plus-arsenal-buff-gun-turret"]
if gun_setting and gun_setting.value then
  if apply("gun-turret",
      data.raw["ammo-turret"] and data.raw["ammo-turret"]["gun-turret"],
      { range = 24, damage_modifier = 2 }) then
    patched = patched + 1
  end
else
  log("[vanilla-plus-arsenal] buffs: gun-turret buff disabled by setting")
end

local laser_setting = settings.startup["vanilla-plus-arsenal-buff-laser-turret"]
if laser_setting and laser_setting.value then
  if apply("laser-turret",
      data.raw["electric-turret"] and data.raw["electric-turret"]["laser-turret"],
      { range = 28, damage_modifier = 4 }) then
    patched = patched + 1
  end
else
  log("[vanilla-plus-arsenal] buffs: laser-turret buff disabled by setting")
end

log(("[vanilla-plus-arsenal] buffs: %d vanilla turret(s) patched")
  :format(patched))
