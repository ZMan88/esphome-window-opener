# CAD

Parametric OpenSCAD sources for the two brackets. Text-based so the
geometry is diffable in git.

## Files

- `common.scad` — shared parameters (hole sizes, bracket width, etc.).
  Edit here to update both brackets at once.
- `sash-bracket.scad` — moving-end bracket, attaches to the sash top rail.
- `frame-bracket.scad` — fixed-end bracket, attaches to the 20 mm strip of
  frame face between the sash top and the ceiling.

## Install OpenSCAD

macOS: `brew install --cask openscad`  ·  [download page](https://openscad.org/downloads.html)

## Render STLs

```
cd mechanical/cad
openscad --export-format binstl -o ../stl/sash-bracket.stl  sash-bracket.scad
openscad --export-format binstl -o ../stl/frame-bracket.stl frame-bracket.scad
```

`--export-format binstl` emits binary STL (`~30–130 KB`) instead of
ASCII (`~10× larger`). Sliced STLs from the same `.scad` will be
identical between machines.

Optional preview render (PNG, no slicer needed):

```
openscad --colorscheme=Nature --imgsize=900,600 -o ../stl/sash-bracket.png  sash-bracket.scad
openscad --colorscheme=Nature --imgsize=900,600 -o ../stl/frame-bracket.png frame-bracket.scad
```

The repo ships with the current STLs and PNGs in `mechanical/stl/`;
re-render after any change to the `.scad` sources.

> **macOS note:** the default `brew install --cask openscad` ships an
> Intel-only build that fails Gatekeeper on Apple Silicon. Use
> `brew install --cask openscad@snapshot` instead — it's the
> dev/nightly build with native Apple Silicon support.

## Print settings (starting point)

- Filament: PETG or ABS (don't use PLA — sun on the window frame can
  exceed its glass-transition temperature).
- Layer: 0.2 mm.
- Walls: 4 perimeters.
- Infill: 40 % gyroid.

### Orientation

- **`frame-bracket.scad`** — flat on the bed, **back face (VHB side) down**.
  The arm prints upward, no supports needed.
- **`sash-bracket.scad`** — flat on the bed, **back face UP**.
  The hex pocket for the M6 nut is on the back face; printing back-up
  means the pocket prints as a clean cavity. The M4 holes go all the
  way through, so orientation does not affect them.

## Post-print

- **Frame bracket:** tap the M6 hole at the end of the arm with an M6 ×
  1.0 hand tap. The hole is printed at 5.0 mm (tap-drill size).
- **Sash bracket:** *no tapping*. The M6 hole is a clearance through-hole
  (6.5 mm). The rod-end shank passes through and is locked with an M6
  nut sitting flush in the hex pocket on the back face.
- Apply VHB tape (3M 4950 or 5952) to the back face of both brackets
  before installing.
- Attach with M4 × 16 self-tappers into the PVC after positioning.

### Sash bracket — rod-end mounting in detail

Standard M6 male rod-ends usually have a 30 mm threaded shank. After:

1. drop the M6 nut into the hex pocket on the bracket's back face,
2. pass the rod-end shank through from the front,
3. thread it down into the nut and tighten,

…the tail of the shank will protrude ~20 mm past the back of the bracket.
You'll need to **drill a Ø6.5 × 25 mm pilot hole into the sash top rail**
where the shank tail will sit. PVC sash profiles have hollow chambers
inside, so you're drilling into air — no problem.

If you'd rather avoid drilling the sash, source a **short-shank rod-end**
(15–20 mm thread) instead; the tail then ends inside the bracket plate.
