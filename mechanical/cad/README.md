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
openscad -o sash-bracket.stl  sash-bracket.scad
openscad -o frame-bracket.stl frame-bracket.scad
```

STL output lands in `../stl/` (or just alongside the `.scad` — move to
`../stl/` when ready to print). `.stl` is binary; commit the `.scad`
sources as the source of truth, STLs as artefacts.

## Print settings (starting point)

- Filament: PETG or ABS (don't use PLA — sun on the window frame can
  exceed its glass-transition temperature).
- Layer: 0.2 mm.
- Walls: 4 perimeters.
- Infill: 40 % gyroid.
- Orientation: flat on the bed, VHB side down. No supports needed.

## Post-print

- **Tap both rod-end holes with an M6 tap.** The holes are printed at
  tap-drill size (5.0 mm), not clearance — this gives clean threads
  instead of relying on printed threads, which are weak.
- Apply VHB tape (3M 4950 or 5952) to the back face before installing.
- Attach with M4 × 16 self-tappers into the PVC after positioning.
