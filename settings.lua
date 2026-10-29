-- Startup settings for vanilla-plus-arsenal.
--
-- Vanilla turret buffs (K2-style): double the per-shot damage and extend
-- the range of the vanilla pair so they keep up with the arsenal parents.
-- Damage buffs are per-shot, not fire rate: same kills for half the ammo
-- belt. Both on by default; each can be turned off independently.
data:extend({
  {
    type = "bool-setting",
    name = "vanilla-plus-arsenal-buff-gun-turret",
    setting_type = "startup",
    default_value = true,
    order = "aa-buff-gun-turret",
  },
  {
    type = "bool-setting",
    name = "vanilla-plus-arsenal-buff-laser-turret",
    setting_type = "startup",
    default_value = true,
    order = "ab-buff-laser-turret",
  },
})
