# Target window — physical specification

These measurements drive the actuator sizing and bracket geometry. Re-measure if the build targets a different window.

| Reference | Photo |
|---|---|
| Front view, tilted | [`photos/window-tilted.jpeg`](photos/window-tilted.jpeg) |
| Looking up at the tilted gap | [`photos/bottom_up_view.jpeg`](photos/bottom_up_view.jpeg) |
| Right-side profile (hinge side, showing reveal) | [`photos/side_view.jpeg`](photos/side_view.jpeg) |

Observations from the photos:

- Frame profile is ~70 mm deep; room-side face is clean and accessible for bracket mounting.
- Wall reveal on the hinge side is ~15–20 cm — the sash has ample clearance to swing past 90° into the reveal in turn mode.
- Fly screen is on the **outside** of the sash; it does not constrain room-side mounting.
- Top-of-frame to ceiling gap is ~20 mm — irrelevant because the actuator mounts on the frame's room-side face, not above it.
- No tilt-stay (scissor) at the top-middle; the tilt limit is set by the hinges, leaving the top-middle clear for the fixed-end bracket.

## Measured

| Parameter | Value | Notes |
|---|---:|---|
| Sash width (W) | 845 mm | inside of frame, horizontal |
| Sash height (H) | 1325 mm | inside of frame, vertical |
| Tilt gap at top | 160 mm | distance from frame plane to sash face at full tilt |
| Turn gap at hinge side (at 90°) | 25 mm | sash-to-frame offset when fully turned |
| **Sash protrusion past frame face** | **~20 mm** | sash room-side face sits 20 mm forward of the frame's inside face |
| **Frame face visible above sash** | **20 mm** | the sash covers the rest of the frame's inside face; bracket must fit in this 20 mm strip between sash top and ceiling |
| Hinge side | right | turn pivot axis = right edge |
| Handle side | left | mid-height |
| Tilt stay location | top-left (handle side) | visible in photo; mount clear of this |
| Turn hardstop | >90° | plan for ~100° headroom |

## Derived

| Derived quantity | Value | How |
|---|---:|---|
| Max tilt angle (θ_max) | ~7° | `arcsin(160 / 1325)` |
| Center of sash from turn pivot | 423 mm | `W / 2` |
| Sash weight (estimated) | 15–25 kg | double-glazed, PVC-framed, typical |

## Design constants used elsewhere in the repo

| Constant | Value | Where used |
|---|---:|---|
| `d` (moving-anchor offset from hinge) | 120 mm | `mechanical/README.md`, bracket CAD |
| Fixed anchor position | `(W/2, 0)` = top-middle of frame | `mechanical/README.md` |
| Moving anchor position | `(W - d, 0)` = top edge of sash, 120 mm from hinge | `mechanical/README.md` |

## Required actuator spec

| Parameter | Value | Reason |
|---|---:|---|
| Stroke | ≥ 160 mm (use 200 mm) | full-turn stroke plus margin |
| Force | ≥ 500 N | worst-case friction torque / moment arm at `d = 120 mm` |
| Voltage | 12 V DC | matches PSU choice |
| Speed | 15–25 mm/s | full stroke in 8–14 s (acceptable) |

## Stroke-to-angle table (for reference)

With `d = 120 mm`:

| Actuator stroke | Tilt angle | Turn angle |
|---:|---:|---:|
| 0 mm | 0° (closed) | 0° (closed) |
| 20 mm | ~5° | ~22° |
| 40 mm | ~7° (hardstop) | ~37° |
| 80 mm | — (stalled) | ~64° |
| 120 mm | — | ~84° |
| 137 mm | — | 90° |
| 160 mm | — | ~100° |

**Interpretation:** the same actuator stroke maps to different window angles depending on mode. Firmware exposes raw stroke %; HA automations translate to tilt or turn percentage if needed. See `docs/architecture.md`.
