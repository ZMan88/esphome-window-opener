# Window Opener — v2 (motor on sash, screw on frame)

Variant of the v1 design with the actuator topology inverted: the
motor lives on the moving sash, the lead screw is anchored to the
static frame. Driving the motor rotates the screw, which threads
through a captive nut on the frame, pulling the motor (and the sash)
along with it.

v1 (in `mechanical/cad/`) remains the reference design; v2 explores
whether the inversion buys fewer parts and a simpler kinematic chain
at the cost of cable management and an exposed screw.

## How it works

```
   sash bracket                                            frame bracket
   ┌────────────┐  U-joint   ┌──────────────────────┐    ┌──────────────┐
   │ NEMA17     ├──[ ✕ ]─────┤ Tr8x8 lead screw ████├────┤ brass nut    │
   │ rigidly    │            │ rotates with motor   │    │ in 2-DOF     │
   │ on bracket │            └──────────────────────┘    │ gimbal       │
   └────────────┘                                        └──────────────┘
        │                                                       │
   bolted to sash                                          bolted to frame
   top rail at d=120 mm                                    top-middle
```

Motor spins the screw via a small U-joint. The screw passes through a
brass nut held in a 2-DOF gimbal on the frame bracket. The nut is
rotationally locked by the gimbal but free to pivot in pitch and
yaw — so the screw can swing through the angle range the sash
demands (tilt: arc in the X-Y plane; turn: arc in the X-Z plane)
while still translating through the threads.

When the motor turns clockwise the screw threads INTO the nut → screw
+ motor + sash get pulled toward the frame. Counter-clockwise →
pushed away.

## Components

| # | Part | Source |
|---|------|--------|
| 1 | NEMA17 motor (LDO 42STH48-1684MAC) | reused from v1 |
| 2 | Tr8x8 lead screw, ~500 mm | reused from v1 (longer; see stroke notes) |
| 3 | Prusa MK3 brass nut | reused from v1 |
| 4 | Ø5–Ø8 single Cardan U-joint, L=35 mm, OD=14 mm | QUARKZMAN / Aopin pin-and-block style, 45° max angle, 2× M4 set screws per bore. Listing: Amazon DE `B0DTTRBWLK` (QUARKZMAN, 2-pack with wrench and spare grub screws). Equivalent Amazon US `B08V92X8M8` (Aopin). |
| 5 | Cross pins for gimbal (Ø3 × 25 mm) | sourced (steel dowel) |
| 6 | sash-motor-mount | printed — `cad/sash-motor-mount.scad` |
| 7 | frame-nut-gimbal | printed — `cad/frame-nut-gimbal.scad` |

What's gone vs v1: rig-motor-mount, rig-far-bearing, rig-carriage, 2×
KP08 pillow blocks, anti-rotation rod, both rod-ends. v2 needs 2
printed parts where v1 needed 5.

## Mechanical considerations

**Cantilevered motor.** NEMA17 ≈ 280 g hangs off the sash bracket's
M3 mounting holes. The bracket has a small "floor" that the motor
body rests on (mirror of v1's rig motor mount) so the four M3 bolts
don't carry the full bending moment.

**Exposed lead screw.** Most of the screw's length is in free air
between the brackets. A flexible sleeve over the screw (corrugated
plastic, cable-management style) is recommended for dust + accidental
contact.

**Motor cable on the moving part.** Cable runs from the controller
(static, on the frame or wall) to the motor (moving, on the sash).
Needs strain relief at the bracket and slack management through the
sash's motion range — a small drag chain or a service loop pinned at
the hinge corner is usually enough.

**Gimbal anti-roll.** The brass nut MUST be rotationally locked
relative to the frame bracket. If the nut can spin freely with the
screw, no axial translation happens. Both gimbal pins are perpendicular
to the screw axis, so they prevent roll while allowing pitch + yaw.

**Stroke length.** Effective max screw-to-anchor distance under full
tilt is ≈ 450 mm (see `docs/window-spec.md`); under 90° turn it's
≈ 440 mm. Use a 500 mm screw with the nut at mid-travel when closed,
giving ~150 mm of stroke each way.

## Range of motion at the gimbal

| Mode | Frame-to-sash anchor angle change |
|------|-----------------------------------|
| Closed → full tilt (~15°) | screw pitch + yaw both vary, max ~25° from horizontal |
| Closed → 90° turn | screw yaw varies by ~25° in the horizontal plane |

A 2-DOF gimbal with ±30° pin clearance handles both, and the
sourced 45°-max U-joint covers the motor-shaft side with ~20°
headroom.

## U-joint install notes

- **Motor end (5 mm bore):** seat both M4 set screws on the LDO 42STH48's
  D-flat (15 mm long × 4.5 mm deep, declared in `common.scad`). Loctite
  blue on the threads — the joint sees full motor torque and constant
  vibration.
- **Lead-screw end (8 mm bore):** Tr8 has no flat. File a small flat
  (~6 mm × 0.3 mm) on the smooth end-section of the screw for the
  set screws to bite. Loctite there too.
- **Backlash:** budget 1–2° of rotational play in the joint. At the
  Tr8 lead this is < 0.05 mm of axial slop — invisible at the percent
  resolution the HA `cover` entity exposes.
- **Velocity-ratio variation:** a single Cardan introduces ±10% RPM
  ripple at 25° angle. Irrelevant for a slow window cover, but if
  position holding ever feels jittery at the extremes, the upgrade is
  a double-Cardan or a constant-velocity joint of the same family.

## Render

```
cd mechanical/v2/cad
openscad --export-format binstl -o ../stl/sash-motor-mount.stl  sash-motor-mount.scad
openscad --export-format binstl -o ../stl/frame-nut-gimbal.stl  frame-nut-gimbal.scad
openscad --colorscheme=Nature --imgsize=900,600 -o ../stl/sash-motor-mount.png sash-motor-mount.scad
openscad --colorscheme=Nature --imgsize=900,600 -o ../stl/frame-nut-gimbal.png frame-nut-gimbal.scad
openscad --camera=350,-350,500,250,0,-15 --imgsize=1600,900 --colorscheme=Tomorrow \
         -o ../stl/v2-assembled-iso.png  v2-assembled.scad

# Single mesh STL of the whole assembly (viewing aid, not for slicing —
# the hardware stand-ins for motor / U-joint / screw / nut are baked in)
openscad --export-format binstl -o ../stl/v2-assembled.stl v2-assembled.scad
```
