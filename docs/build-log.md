# Build log

Tracks parts ordered, prices paid, and assembly progress. The repo's `hardware/BOM.md` is the *spec*; this file is the *as-built* record.

## Variant chosen

**Variant B — Stepper + lead screw.** Decided in late April 2026 based on parts availability and pricing in Romania.

## Parts ordered

### Mechanical — lead-screw drive

| Part | Vendor | Price (RON) | Status |
|---|---|---:|---|
| Tr8 trapezoidal lead screw, 8 mm pitch, 400 mm | TBD | 34.99 | ✅ |
| Prusa MK3 brass nut, Tr8x8 | TBD | 18.12 | ✅ |
| Generic Tr8x8 trapezoidal nut × 2 | TBD | 29.00 (set) | ✅ |
| KP08 pillow-block bearing × 2 | TBD | 24.00 (set) | ✅ |
| **Subtotal** | | **106.11** | |

### Stepper

| Part | Vendor | Price (RON) | Status |
|---|---|---:|---|
| LDO-42STH48-1684MAC NEMA17 (0.9°, 1.68 A) | TBD | TBD | ✅ |

### Still to order

Open shopping list — see `hardware/BOM.md` for sources:

- [ ] TMC2209 stepper driver (with heatsink)
- [ ] ESP32 DevKit V1
- [ ] Flexible coupler 5 mm → 8 mm
- [ ] 12 V / 5 A AC-DC PSU
- [ ] LM2596 buck converter (12 V → 5 V)
- [ ] M6 rod-ends, male, **short-shank ≤ 20 mm preferred** (2 pcs)
- [ ] Endstop micro-switch or magnetic reed
- [ ] 100 µF / 25 V electrolytic cap (TMC2209 motor supply)
- [ ] 3M VHB 4950 / 5952, 19 mm × ~1 m
- [ ] M4 × 16 self-tapping screws (8 pcs)
- [ ] Inline 5 A blade fuse holder + fuses
- [ ] Filament for 3D-printed brackets (PETG or ABS)

## Sanity-check on what was bought

### Lead screw & nut compatibility

The Prusa MK3 lead screws are **Tr8x8** (4-start, 2 mm pitch, 8 mm/rev), so the "Prusa MK3 nut" matches the Tr8 / 8 mm-pitch screw. The two generic Tr8x8 nuts are spares + can be used for an **anti-backlash double-nut** configuration on the carriage if turn-mode position needs more precision.

### Stepper torque vs Tr8x8 lead

LDO-42STH48-1684MAC: 0.9° step, 1.68 A rated, ~0.45 N·m holding torque.

Theoretical linear force on a Tr8x8 screw:
> F = 2π · τ / lead = 2π · 0.45 / 0.008 = **353 N (theoretical)**
> at 30–50 % real efficiency = **105–175 N**

Earlier spec called for ≥500 N. With these parts, expect:

- **Tilt mode** (needs <50 N): comfortable headroom. ✅
- **Turn mode** (needs ~150–250 N for a typical 20 kg sash): borderline, may stall under load.

**Mitigation if turn stalls:**
1. Try first — friction estimates are very rough; many windows turn with <100 N once the seal is broken.
2. If insufficient, swap the Tr8x8 lead screw for a **Tr8x4** (half the speed, ~2× the force). The motor, nut, and bearings stay the same.

### KP08 bearings

KP08 = pillow-block bearing with an 8 mm bore. Two of them support both ends of the lead screw (one near the motor, one at the far end), keeping the screw concentric and preventing it from whipping. Standard for DIY linear actuators.

## Mechanical CAD still to design

The stepper variant needs more 3D-printed parts than the linear-actuator variant. Items to add to `mechanical/cad/`:

- [ ] **Motor mount** — holds NEMA17 to one end of the assembly; aligns with one KP08 bearing.
- [ ] **Far-end bearing block bracket** — holds the second KP08 at the opposite end of the lead screw, including a way to anchor that end to the fixed frame bracket.
- [ ] **Carriage** — slides along the lead screw via the brass nut (M3 mounting pattern from the Prusa MK3 nut). Holds the rod-end at one end. Optional anti-backlash double-nut housing.
- [ ] **Outer rail / linear guide** (optional) — keeps the carriage from rotating with the screw. Could be a printed slot on a parallel rod, or rely on the rod-end constraint at the moving end.

These come after the user has the parts in hand and can measure the actual nut and bearing dimensions.

## Assembly progress

- [x] Phase 0 — Repo scaffolded
- [ ] Phase 1 — Bench prototype (electronics + motor on the desk)
- [ ] Phase 2 — Mechanical assembly (lead-screw rig, dry-fit on window)
- [ ] Phase 3 — Tuning + HA integration on real window
- [ ] Phase 4 — Polish (enclosure, automations, CAD STLs released)
