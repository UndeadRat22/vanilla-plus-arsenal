# Mod portal page text

Paste into the description field on the Factorio mod portal. Markdown on
purpose — the portal documents its description field as markdown (see the
Mod details API on wiki.factorio.com). Kept conservative (headings, bold,
flat lists, links, code spans) since the portal's renderer is a partial
markdown implementation; nested structures and tables are avoided.

---

# Vanilla+ Arsenal

A curation and balance layer over standalone turret mods for vanilla+ /
Space Age games: the turret variety of a K2SO Arsenal stack without the
modpack. All parents are optional — the mod adapts to whichever are
installed, and stays a no-op without them.

## What it does

- **Vanilla turret buffs (K2-style, buffs not nerfs)**: gun turret range 18 → 24 with double per-shot damage (48 per uranium round, 480 DPS); laser turret range 24 → 28 with double per-shot damage (40 per shot, 60 DPS). The damage buffs are per-shot, not fire rate, so the same kills cost half the bullet belt. Both are startup settings, on by default.
- **Roster detection**: logs which turret parents are present; future balance modules key off it.
- The heavy gun turret is deliberately untouched — it stays the DPS wall you graduate to on Vulcanus, and demolishers stay laser-immune (that is basegame design).

The resulting role split: bullets are the damage, missiles are the reach.

## Parents (all optional)

- [Two more Turrets](https://mods.factorio.com/mod/TwoMoreTurrets) — cannon + heavy gun pair, tuned for Space Age. Fully defers to the standalone parents when they are installed.
- [Heavy Gun Turret](https://mods.factorio.com/mod/heavy_gun_turret) — the bullet-DPS wall (Vulcanus science).
- [VortiK Cannon Turret](https://mods.factorio.com/mod/vtk-cannon-turret) — single-target cannon punch.
- [Missile Defense Systems Redux](https://mods.factorio.com/mod/missile-defense-systems-redux) — guided missile family; keeps the vanilla rocket turret.
- [doeWorks Rocket Artillery Continued](https://mods.factorio.com/mod/doeworks-deer-continued) — early-game area softening at 90 tiles.

## Ammo economy

The stack stays vanilla-lean on ammunition: gun and heavy gun turrets share the vanilla bullet line, the rocket turret and both missile systems share the vanilla rocket line (atomic bombs included), artillery and railgun are vanilla. VortiK's cannon turrets ship magazines that mirror vanilla cannon shells — set its `vtk-cannon-turret-ammo-use` startup setting to 3 to also feed them plain tank shells.

## Quality

Every claim above is verified by an A/B data-stage harness against the full 94-mod save-synced stack: Phase A asserts vanilla base values without this mod, Phase B asserts the roster, the parents' prototypes and the buffed values. The balance baseline (ranges, dead zones, DPS, tech placement for all 13 turrets, from a `--dump-data` dump of the live stack) lives in the repository.
