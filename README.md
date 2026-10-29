# Vanilla+ Arsenal

A curation and balance layer over standalone turret mods for vanilla+ /
Space Age games: the turret variety of a K2SO Arsenal stack without the
modpack. All parents are optional dependencies; the mod adapts to whichever
are installed.

Status: skeleton (v0.1.x). The mod detects the installed parents and logs
the roster; balance modules follow. The full-stack load test is real and
green.

## Parents (all optional)

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

## Layout

- `data-final-fixes.lua` - entry point; requires `arsenal/` modules
- `arsenal/roster.lua` - parent detection + logging (the current extent
  of the mod)
- `tests/` - harness (lib.sh, run-stack.sh, proto-check scenario, asserts)
- Later: `arsenal/<module>.lua` per balance concern, `settings.lua` for
  curation knobs

## Conventions

Inherited from k2so-rats-fixes: one concern per module with guard clauses,
`log("[vanilla-plus-arsenal] ...")` prefixes with patched counts,
startup settings with auto/override defaults, changelog in Factorio's
format, `PORTAL.md` for portal copy, and repo-only files (tests, Makefile,
README) stay out of the packaged zip.
