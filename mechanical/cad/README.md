# CAD

Parametric OpenSCAD sources for the two brackets. Text-based so the
geometry is diffable in git.

## Files

- `common.scad` — shared parameters (hole sizes, bracket width, etc.).
  Edit here to update both brackets at once.
- `sash-bracket.scad` — moving-end bracket, attaches to the sash top rail.
- `frame-bracket.scad` — fixed-end bracket, attaches to the 20 mm strip of
  frame face between the sash top and the ceiling.
- `rig-motor-mount.scad` — printed L-bracket carrying the NEMA17 + KP08 #1.
- `rig-far-bearing.scad` — printed L-bracket carrying KP08 #2 + anchor for
  the anti-rotation rod.
- `rig-carriage.scad` — printed block riding on the lead screw via the
  Prusa MK3 brass nut; holds the LH M6 rod-end on its bottom face.
- `rig-assembled.scad` — **assembly preview**. Includes the parts above
  plus stylised stand-ins for the motor / screw / KP08 / brass nut / rod-ends.
  Render with the camera invocations below to get the three views in
  `../stl/rig-assembled-{top,side,iso}.png`. The standalone parts'
  STLs/PNGs remain the source-of-truth for slicing.
- `window-opener-rig.skp` — **SketchUp model** of the rig in window context.
  Each printable part appears as ONE named group matching the `.scad` file
  name (`frame-bracket`, `sash-bracket`, `rig-motor-mount`,
  `rig-far-bearing`, `rig-carriage`), with off-the-shelf hardware
  (`NEMA17-motor`, `Coupler-5to8`, `Lead-screw-Tr8x8-400`, `KP08-1/2`,
  `Prusa-MK3-brass-nut`, `Rod-end-LH-CSL10`, `Rod-end-RH-CS10`,
  `Anti-rotation-rod`) and the 845 × 1325 mm window (4 frame rails +
  4 sash rails + glass) as separate groups. 23 groups total.

  Each group is independently selectable. To export a printable STL:
  open in SketchUp, right-click the group → **Export** → **3D Model**
  → choose STL. Cutouts (bolt holes, counterbores) are not yet modelled
  — for printable STLs, still use the `.stl` files in `../stl/`. The
  `.scad` sources remain source-of-truth for slicing.

  Thumbnail beside the file: `window-opener-rig.skp.png`.

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

## Assembled view

```
cd mechanical/cad
# Top  (orthographic, looking straight down)
openscad --camera=150,800,0,150,-25,0   --imgsize=1600,500 --colorscheme=Tomorrow --projection=ortho \
         -o ../stl/rig-assembled-top.png  rig-assembled.scad
# Side (orthographic, looking along the rig's depth axis)
openscad --camera=150,-25,800,150,-25,0 --imgsize=1600,650 --colorscheme=Tomorrow --projection=ortho \
         -o ../stl/rig-assembled-side.png rig-assembled.scad
# Isometric (perspective)
openscad --camera=600,400,500,150,-25,0 --imgsize=1600,900 --colorscheme=Tomorrow \
         -o ../stl/rig-assembled-iso.png  rig-assembled.scad
# Single mesh of the whole rig (printable parts + hardware stand-ins)
openscad --export-format binstl -o ../stl/rig-assembled.stl rig-assembled.scad
```

The assembled STL is a visualization aid only — it includes the off-the-shelf
stand-ins (motor, screw, KP08s, nut, rod-ends) and is not meant for slicing.
For printing, use the individual part STLs (`rig-motor-mount.stl`, etc.).

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
