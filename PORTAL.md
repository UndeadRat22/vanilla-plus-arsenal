# Mod portal page text

Paste into the description field on the Factorio mod portal. Markdown on
purpose — the portal documents its description field as markdown (see the
Mod details API on wiki.factorio.com). Kept conservative (headings, bold,
flat lists, links, code spans) since the portal's renderer is a partial
markdown implementation; nested structures and tables are avoided.

---

# Vanilla+ Arsenal

Turret variety for a mostly vanilla game: five standalone turret mods, each with one job, plus small balance tweaks that keep all of them worth building.

I like what big modpacks do to defenses. Suddenly there are cannons, missile platforms, rocket artillery, and an actual reason to think about which turret goes where. What I don't like is paying for that with the rest of the modpack. So this is the middle ground: your factory stays vanilla, your wall gets interesting.

## Design

- Every turret has a niche. Bullets are the damage, missiles are the reach, cannons hit big single targets, rocket artillery softens waves before they arrive. None of them is strictly the best; what to build depends on what's coming.
- Buffs, not nerfs. In my experience bringing things up balances better than dragging the leader down, and nothing you already built becomes worthless overnight.
- No ammo zoo. Wherever possible the turrets eat vanilla ammo: the same bullets, rockets and cannon shells your factory already makes.

## What it changes today

The gun and laser turrets were the underdogs, so they got the first buffs:

- Gun turret: range 18 to 24, double damage per shot (48 per uranium round). The buff is per shot, not fire rate, so the same kills cost half the bullet belt.
- Laser turret: range 24 to 28, double damage per shot (40 instead of 20).

Both are startup settings, on by default, and can be turned off separately.

## The turrets

Install this mod and the game installs all five with it. They're required dependencies, which is the honest contract: this mod exists to coordinate them. (Disabling one disables this mod too - the game enforces it.) What each one brings:

- [Two more Turrets](https://mods.factorio.com/mod/TwoMoreTurrets) - a cannon turret and a heavy gun turret balanced for Space Age
- [Heavy Gun Turret](https://mods.factorio.com/mod/heavy_gun_turret) - the bullet wall: triple fire rate, more health, needs power (Vulcanus science)
- [VortiK Cannon Turret](https://mods.factorio.com/mod/vtk-cannon-turret) - slow, heavy single-target punch with cannon shells
- [Missile Defense Systems Redux](https://mods.factorio.com/mod/missile-defense-systems-redux) - guided missile turrets from short range up to artillery range; keeps the vanilla rocket turret
- [doeWorks Rocket Artillery Continued](https://mods.factorio.com/mod/doeworks-deer-continued) - early artillery at 90 tiles with a wide dead zone; it won't save you by itself, it softens what's coming

## Ammo

Gun turrets and the heavy gun turret share the vanilla bullet line. The rocket turret and both missile systems share the vanilla rocket line, atomic bombs included. Artillery and railguns are vanilla. The only custom ammo in the set is the ballistic missile line (artillery class, nothing vanilla to reuse) and the rocket artillery's own rockets. VortiK's cannon turrets ship magazines that mirror vanilla cannon shells; set its `vtk-cannon-turret-ammo-use` setting to 3 and they take plain tank shells too.

## Where the numbers come from

Every number in this description comes from a data dump of the actual mod stack, not from a wiki, and every claim is checked by an automated test that loads the full stack and verifies the prototypes, the unlock technologies, and whether the buffs applied. The baseline for all turrets (ranges, dead zones, DPS, tech placement) lives in the repository.
