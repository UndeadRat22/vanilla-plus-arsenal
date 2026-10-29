# Vanilla+ Arsenal

A curation and balance layer over standalone turret mods for vanilla+ /
Space Age games: the turret variety of a K2SO Arsenal stack without the
modpack. All five turret mods are required dependencies with version
floors, so the in-game Install button pulls them automatically; the roster
guards still degrade cleanly on a force-load without them.

Status: 1.0.0. The roster detects parents; the vanilla turret buffs are
live and covered by the A/B stack test; all parents are required
dependencies (one-click install).

## Parents (required dependencies, auto-installed)

All five are required with version floors at the versions this mod is
tested against (`>=` in info.json). The in-game Install button downloads
the whole set in one click, and disabling a parent disables this mod with
it (game-enforced). The roster guards remain as defense in depth: a
force-load without a parent (the portal's "install without dependencies"
path) logs and no-ops instead of crashing.

| Parent | Niche |
| --- | --- |
| [Two more Turrets](https://mods.factorio.com/mod/TwoMoreTurrets) | cannon + heavy gun pair, tuned for Space Age |
| [Heavy Gun Turret](https://mods.factorio.com/mod/heavy_gun_turret) | bullet-DPS wall |
| [VortiK Cannon Turret](https://mods.factorio.com/mod/vtk-cannon-turret) | single-target cannon punch |
| [Missile Defense Systems Redux](https://mods.factorio.com/mod/missile-defense-systems-redux) | guided missile family |
| [doeWorks Rocket Artillery Continued](https://mods.factorio.com/mod/doeworks-deer-continued) | early-game area softening |

The MDS Redux and DEER entries are community forks; the originals
(`missile_defense_systems_sa`, `doeworks-deer`) could not be found on the
portal anymore when the stack was assembled.

## Verified stack behavior

- **Two more Turrets fully defers** to `heavy_gun_turret` and
  `vtk-cannon-turret` when they are enabled: its own `cannon-turret` /
  `heavy-gun-turret` prototypes are skipped in its `data.lua`. With all
  parents present it contributes no entities - keep it around as the
  "minimal variant" provider, or drop it from the stack.
- **Missile Defense Systems Redux keeps the vanilla SA rocket turret.**
  The original `_sa` mod removed it and re-anchored rocket turrets on
  Nauvis research; Redux instead adds a `rocket-turret` prerequisite and
  ships `basic` / `advanced` / `ballistic` missile turrets alongside it.
- All five parents' turrets load together with the full 94-mod vanilla+
  save-synced stack (`make test-stack`, below).

## Ammo re-use (verified from the live dump)

The stack is already vanilla-lean on ammunition - 10 custom ammo items
total, and three of the five parents use none at all:

- **bullets**: gun-turret and heavy-gun-turret share the vanilla firearm /
  piercing / uranium rounds line. Zero custom items.
- **rockets**: rocket-turret, basic and advanced missile systems all share
  the vanilla rocket line (including atomic bombs). Zero custom items.
- **artillery-shell / railgun**: vanilla only.
- **vtk-cannon-turret** ships 4 magazine items that statistically mirror
  the vanilla cannon shells. The mod has a built-in startup setting,
  `vtk-cannon-turret-ammo-use` (1 = magazines only [default], 2 = vanilla
  shells only, 3 = both): set it to 3 to feed the turrets plain tank
  shells. Recommended.
- **missile-defense-systems-redux** adds 4 ballistic missiles (artillery
  class; no vanilla equivalent to re-use) and **doeworks-deer-continued**
  2 items (basic + the joke crate). Left as-is on purpose.

## Testing

```
make test-stack   # full-stack data-stage load + roster/prototype asserts
make lint         # luacheck (lua52 + factorio stds, see .luacheckrc)
make package      # build the distributable zip into releases/
make install      # package + copy into the local Factorio mods dir
```

`tests/run-stack.sh` mirrors the live save-synced mod set (every zip in
the Factorio mods dir + the live `mod-list.json`), adds this repo and the
roster assert mod, and loads everything through `--scenario2map` - the
same harness pattern as [k2so-rats-fixes](../k2so-rats-fixes). The assert
mod (`tests/proto/roster/assert-mod/`) logs `E2E_CHECK` markers that
`expected-B.txt` greps for: parent prototypes exist, Two more Turrets
deferred, and the vanilla rocket turret survived.

## v0.2 balance module: vanilla turret buffs

Buffs, not nerfs (K2-style): gun-turret range 18 -> 24 with
`damage_modifier` 1 -> 2 (48 per uranium round, 480 DPS, half the ammo
belt for the same kills), laser-turret range 24 -> 28 with
`damage_modifier` 2 -> 4 (40 per shot, 60 DPS). Both startup settings,
on by default. heavy-gun-turret is untouched - it stays the DPS wall you
graduate to on Vulcanus, and demolishers stay laser-immune (basegame
design). Resulting role split: bullets are the damage, missiles are the
reach.

## Layout

- `data-final-fixes.lua` - entry point; requires `arsenal/` modules
- `arsenal/roster.lua` - parent detection + logging
- `arsenal/vanilla-buffs.lua` - the v0.2 K2-style vanilla turret buffs
- `settings.lua` - startup toggles for the buffs
- `tests/` - harness (lib.sh, run-stack.sh A/B, proto-check scenario,
  asserts)
- Later: `arsenal/<module>.lua` per balance concern

## Conventions

Inherited from k2so-rats-fixes: one concern per module with guard clauses,
`log("[vanilla-plus-arsenal] ...")` prefixes with patched counts,
startup settings with auto/override defaults, changelog in Factorio's
format, `PORTAL.md` for portal copy, and repo-only files (tests, Makefile,
README) stay out of the packaged zip.
