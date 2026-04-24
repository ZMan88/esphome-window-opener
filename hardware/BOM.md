# Bill of Materials

Prices are rough EU hobbyist-market estimates (AliExpress / local electronics shops) and should be re-checked at order time. Pick **one** actuator track.

## Common to both variants

| Qty | Part | Notes | ~EUR |
|---:|---|---|---:|
| 1 | ESP32 DevKit V1 (30-pin) | Any ESP-WROOM-32 board works | 5 |
| 1 | 12V DC power supply, ≥ 5A | Size to actuator stall current | 10–15 |
| 1 | Buck converter 12V → 5V, ≥ 2A | Mini360 or LM2596 | 2 |
| 1 | Inline blade fuse holder + 5A fuse | On the 12V rail | 2 |
| 1 | TVS diode (1.5KE18CA or similar) | Across motor leads | 1 |
| 1 | Terminal blocks / JST-XH pigtails | Whatever suits the enclosure | 3 |
| 2 | M6 or M8 ball-joint rod ends | Both actuator ends — do not substitute fixed pivots | 4 |
| 1 | 3D-printed frame bracket | See `mechanical/stl/` | — |
| 1 | 3D-printed sash bracket | See `mechanical/stl/` | — |
| 1 | 3D-printed ESP32 enclosure | See `mechanical/stl/` | — |

## Variant A — 12V linear actuator

| Qty | Part | Notes | ~EUR |
|---:|---|---|---:|
| 1 | 12V DC linear actuator | **200 mm stroke, ≥500 N force** (sized for 845×1325 mm sash, d=120 mm — see `docs/window-spec.md`). IP54+ if outdoor-facing. | 35–55 |
| 1 | BTS7960 H-bridge module (43A) | Overkill on current headroom, but cheap and reliable | 5 |
| 1 | (optional) 10-turn linear potentiometer | For closed-loop % feedback — omit if you accept time-based | 5 |

Wiring: [`wiring/linear-actuator.md`](wiring/linear-actuator.md).

## Variant B — Stepper + lead screw

| Qty | Part | Notes | ~EUR |
|---:|---|---|---:|
| 1 | NEMA17 stepper, ≥ 40 N·cm | 42BYGH48 or similar | 10 |
| 1 | TMC2209 driver module | UART optional; STEP/DIR is enough | 5 |
| 1 | 8mm lead screw + brass nut, matching stroke length | 300–500 mm typical | 10 |
| 1 | Flexible coupler 5mm → 8mm | Connects motor shaft to lead screw | 2 |
| 2 | KP08 bearing blocks (or equivalent) | Supports both ends of the lead screw | 4 |
| 1 | Normally-open micro-switch or reed + magnet | Closed-side endstop | 1 |
| 1 | 100 µF electrolytic cap | Across TMC2209 motor supply — required | 0.20 |

Wiring: [`wiring/stepper.md`](wiring/stepper.md).

## Not included (yet)

- Rain sensor — v1 relies on HA weather integrations.
- Battery backup — v1 is mains-only.
- Device-side pushbuttons — v1 uses the window handle as manual override.
