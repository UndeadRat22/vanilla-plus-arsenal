#!/usr/bin/env python3
"""Print the turret stat baseline for the vanilla-plus-arsenal stack.

Parses a Factorio --dump-data JSON (see `make stats`) and prints range,
dead zone, cycle time, best-ammo damage, DPS, health and the canonical
unlock technology + science packs for every turret of interest.

Usage: python3 scripts/dump_turret_stats.py <data-raw-dump.json>
"""
import json
import sys

TURRETS = [
    "gun-turret", "laser-turret", "flamethrower-turret", "artillery-turret",
    "rocket-turret", "railgun-turret", "heavy-gun-turret",
    "vtk-cannon-turret", "vtk-cannon-turret-heavy",
    "basic-missile-defense-system", "advanced-missile-defense-system",
    "ballistic-missile-defense-system", "dw-deer-turret",
]
TYPES = ("ammo-turret", "electric-turret", "fluid-turret", "artillery-turret")
# Delivery type -> category table holding the referenced prototype.
DELIVERY_TABLE = {
    "projectile": "projectile",
    "artillery": "artillery-projectile",
    "beam": "beam",
    "stream": "stream",
}
# Conventional ammo only for the DPS baseline (nuke-class excluded).
SKIP_AMMO = {"atomic-bomb", "capture-robot-rocket",
             "mds-ballistic-atomic-bomb-missile"}


def chase_damage(obj, data, depth=0):
    """Recursively collect (amount, type) damage pairs, resolving named
    projectile/beam/stream/artillery deliveries exactly once."""
    out = []
    if depth > 24 or obj is None:
        return out
    if isinstance(obj, dict):
        dmg = obj.get("damage")
        if isinstance(dmg, dict) and "amount" in dmg:
            out.append((dmg["amount"], dmg.get("type")))
        ref = obj.get("projectile") or obj.get("beam") or obj.get("stream")
        table = DELIVERY_TABLE.get(obj.get("type"))
        if table and isinstance(ref, str):
            # a delivery referencing a named prototype; prototypes
            # themselves (same `type` value, no ref key) fall through
            out += chase_damage((data.get(table) or {}).get(ref),
                                data, depth + 1)
        else:
            for key in ("action", "actions", "action_delivery",
                        "action_deliveries", "final_action", "target_effects",
                        "effects", "area_effects"):
                out += chase_damage(obj.get(key), data, depth + 1)
    elif isinstance(obj, list):
        for x in obj:
            out += chase_damage(x, data, depth + 1)
    return out


def ammo_damage(item, data):
    at = item.get("ammo_type")
    if isinstance(at, list):  # multi-variant ammo_type entries
        acts = [x.get("action") for x in at if isinstance(x, dict)]
    elif isinstance(at, dict):
        acts = [at.get("action")]
    else:
        acts = []
    total = {}
    for act in acts:
        for amt, typ in chase_damage(act, data):
            total[typ] = total.get(typ, 0) + (amt or 0)
    return total


def turret_damage(e, data):
    """Damage for turrets with no ammo items (inline ammo_type: laser)."""
    total = {}
    for amt, typ in chase_damage(e.get("attack_parameters", {})
                                 .get("ammo_type", {}).get("action"), data):
        total[typ] = total.get(typ, 0) + (amt or 0)
    return sum(total.values())


def main(path):
    data = json.load(open(path))
    ents = {}
    for t in TYPES:
        for name, e in (data.get(t) or {}).items():
            if name in TURRETS:
                ents[name] = dict(e, _type=t)

    # best conventional ammo per category
    cats = set()
    for e in ents.values():
        ap = e.get("attack_parameters", {})
        if ap.get("ammo_category"):
            cats.add(ap["ammo_category"])
        for c in (ap.get("ammo_categories") or []):
            cats.add(c)
        if e["_type"] == "artillery-turret":
            gap = (data.get("gun") or {}).get(e.get("gun"), {}) \
                .get("attack_parameters", {})
            if gap.get("ammo_category"):
                cats.add(gap["ammo_category"])
    best = {}
    for name, item in (data.get("ammo") or {}).items():
        c = item.get("ammo_category")
        if c in cats and name not in SKIP_AMMO:
            dmg = sum(ammo_damage(item, data).values())
            if dmg > best.get(c, (0, None))[0]:
                best[c] = (dmg, name)

    # canonical unlock tech: fewest parseable science packs (skips
    # later-game techs from other mods that re-unlock the same recipe)
    def packs(tech):
        unit = tech.get("unit") or {}
        ings = unit.get("ingredients", []) if isinstance(unit, dict) else []
        return [i.get("name") if isinstance(i, dict) else i[0] for i in ings]

    unlock = {}
    for tname, tech in (data.get("technology") or {}).items():
        for eff in tech.get("effects") or []:
            if eff.get("type") != "unlock-recipe":
                continue
            rec = (data.get("recipe") or {}).get(eff.get("recipe")) or {}
            results = rec.get("results") or ([rec["result"]] if rec.get("result") else [])
            for res in results:
                if isinstance(res, dict) and res.get("name") in TURRETS:
                    p = packs(tech)
                    if not p:
                        continue
                    if res["name"] not in unlock or len(p) < unlock[res["name"]][1]:
                        unlock[res["name"]] = (tname, len(p))

    print(f"{'turret':32s} {'tech':30s} {'rng':>4s} {'dead':>4s} {'cyc/s':>5s} "
          f"{'shot':>6s} {'DPS':>6s} {'HP':>5s}  ammo")
    for name in TURRETS:
        e = ents.get(name)
        if not e:
            print(f"{name:32s} NOT FOUND")
            continue
        ap = e.get("attack_parameters", {})
        rng, minr, cd = ap.get("range", "?"), ap.get("min_range", "-"), ap.get("cooldown")
        cats_used = ([ap["ammo_category"]] if ap.get("ammo_category")
                     else list(ap.get("ammo_categories") or []))
        if e["_type"] == "artillery-turret":
            gap = (data.get("gun") or {}).get(e.get("gun"), {}).get("attack_parameters", {})
            rng, minr, cd = gap.get("range", rng), gap.get("min_range", minr), gap.get("cooldown", cd)
            cats_used = [gap.get("ammo_category")]
        cycle = (cd / 60) if isinstance(cd, (int, float)) and cd else None
        dmg_mod = ap.get("damage_modifier") or 1
        if cats_used and cats_used[0] in best:
            shot = best[cats_used[0]]
        else:
            shot = (turret_damage(e, data), "(inline)")
        dps = (shot[0] * dmg_mod / cycle) if cycle and shot[0] else None
        tech = unlock.get(name, ("?", 0))[0]
        print(f"{name:32s} {tech:30s} {str(rng):>4s} {str(minr):>4s} "
              f"{cycle or 0:5.2f} {shot[0]:6.0f} {(dps or 0):6.0f} "
              f"{str(e.get('max_health', '?')):>5s}  {shot[1]}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: dump_turret_stats.py <data-raw-dump.json>")
    main(sys.argv[1])
