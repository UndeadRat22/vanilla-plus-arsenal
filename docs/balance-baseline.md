# Turret baseline (v0.1.1 stack)

Extracted from a `--dump-data` dump of the live 94-mod stack on
2026-10-29 (Factorio 2.1.23, see `make stats` / `scripts/dump_turret_stats.py`).
DPS uses the best conventional ammo per category, no damage-research
bonuses, turret `damage_modifier` applied. Two more Turrets' own turrets
are absent (deferred to the standalone parents) and are not listed.

| turret | unlock tech (packs) | range | dead zone | cycle | shot | DPS | HP |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| gun-turret | gun-turret (red) | 18 | - | 0.10s | 24 | 240 | 400 |
| flamethrower-turret | flamethrower (grey) | 30 | 6 | 0.07s | 9 + burn | 135+ | 1400 |
| laser-turret | laser-turret (blue) | 24 | - | 0.67s | 20 | 30 | 1000 |
| basic-missile-defense-system | basic-missile-defense-system (red) | 40 | 0 | 1.00s | 200 AoE | 200 | 750 |
| advanced-missile-defense-system | advanced-missile-defense-system (blue) | 80 | 40 | 2.00s | 200 AoE | 100 | 1200 |
| vtk-cannon-turret | vtk-cannon-turret-unlock (blue) | 35 | 12 | 3.00s | 2200 | 733 | 1500 |
| vtk-cannon-turret-heavy | vtk-cannon-turret-heavy-unlock (yellow) | 30 | 12 | 1.50s | 2200 | 1467 | 2000 |
| dw-deer-turret | dw-deer-tech (blue) | 90 | 35 | 7.00s | 225 AoE | 32 | 400 |
| heavy-gun-turret | heavy-gun-turret (space+metallurgic) | 20 | - | 0.03s | 24 | 720 | 1200 |
| artillery-turret | artillery (utility+space+metallurgic) | 224 | 32 | 3.33s | 2000 r4 | 600 | 2000 |
| rocket-turret | rocket-turret (Gleba) | 36 | 15 | 2.00s | 200 AoE | 100 | 1500 |
| ballistic-missile-defense-system | ballistic (metallurgic+agricultural) | 500 | 80 | 0.17s | 850 | 5100 | 1200 |
| railgun-turret | railgun (through cryogenic) | 40 | 3.5 | 2.83s | 10000 | 3529 | 4000 |

Ammo notes: gun/heavy-gun figures are uranium rounds; vtk figures are
uranium-cannon-shell-magazines (2000 phys + 200 expl); artillery is the
standard shell (1000 phys + 1000 expl, radius 4); the promethium-quality
plasma-artillery-shell raises artillery to 5050/shot; DEER lists the basic
ammo (50 phys + 175 expl), the joke crate item is 3000/shot (429 DPS);
ballistic lists the tungsten missile (700 phys + 150 expl), and it also
ships basic/explosive/atomic variants. Flamethrower burn: fire stickers do
16.67 fire/tick for 1800 ticks on burning ground.

## Findings

1. **basic-missile-defense-system is the placement outlier.** Red
   science, 40 range, zero dead zone, 200 AoE DPS - it out-damages every
   Nauvis-native turret at unlock, outranges all of them, and keeps
   scaling with rocket damage research (shared with the rocket turret).
2. **ballistic-missile-defense-system fires every 10 ticks** (vanilla
   artillery gun: 200). At 6 shots/sec of 850-damage missiles with a
   500-tile range it is 5100 DPS - presumably unintended pacing for an
   artillery-class turret; verify in play, then fix the cooldown.
3. **The inner wall (0-35 tiles) on Nauvis** is vanilla gun/laser/flame
   + vtk pair + basic-missile. Everything long-range (DEER 35-90,
   advanced-missile 40-80, ballistic 80-500) is second-line by design and
   needs the inner wall to hold.
4. **Vanilla ranges stop at 24 (laser)** while the modded ladder starts
   at 35 (vtk, blue science - the same tier as laser). A modest vanilla
   buff keeps the pair relevant without reaching into modded territory.
5. **heavy-gun-turret is gated behind space+metallurgic (Vulcanus)**, so
   the bullet-DPS wall arrives after Nauvis; on Nauvis the bullet line
   stays vanilla (240 DPS with uranium rounds).
6. flamethrower (grey) remains the strongest early area denial once burn
   is counted; nothing modded competes in its niche until basic-missile.

## v0.2 balance proposal (first module)

- laser-turret range 24 -> 28
- gun-turret range 18 -> 20 (matches heavy-gun-turret)
- basic-missile: range 40 -> 32, min_range 0 -> 8, tech requires chemical
  science (blue)
- advanced-missile min_range 40 -> 32 (aligns the second-line dead zones)
- ballistic gun cooldown 10 -> 200 (artillery pacing), pending a gameplay
  check that its 6/s rate is as unintended as it looks

Regenerate this table after balance changes with `make stats`.
