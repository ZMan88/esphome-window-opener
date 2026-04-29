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
| Rod-end M6 RH (CS10, MGK) | [rulmentika.ro](https://www.rulmentika.ro/) | 14.00 | ✅ |
| Rod-end M6 LH (CSL10, MGK) | [rulmentika.ro](https://www.rulmentika.ro/) | 14.00 | ✅ |
| **Subtotal** | | **134.11** | |

### Stepper

| Part | Vendor | Price (RON) | Status |
|---|---|---:|---|
| LDO-42STH48-1684MAC NEMA17 (0.9°, 1.68 A) | TBD | TBD | ✅ |
| Flexible coupler 5 mm → 8 mm × 2 (1 spare) | TBD | 21.42 | ✅ |
| BIGTREETECH TMC2209 V1.3 × 2 (1 spare) | TBD | 73.98 | ✅ |
| Creality mechanical endstop × 2 (1 spare) | TBD | TBD | ✅ |

### Power & support

| Part | Vendor | Price (RON) | Status |
|---|---|---:|---|
| LM2596 DC-DC step-down regulator × 4 (3 spare) | TBD | 37.48 | ✅ |

### Spares / parts ordered but not used in this build

| Part | Vendor | Price (RON) | Note |
|---|---|---:|---|
| Flexible coupler 5 mm → 5 mm | TBD | 9.06 | Doesn't fit this build (motor shaft is 5 mm but lead screw is 8 mm). Save for a future project. |

### Running totals

- Mechanical (lead-screw + nuts + bearings + rod-ends): **134.11 RON**
- Stepper + coupler + driver + endstops: motor TBD + endstops TBD + **95.40 RON**
- Power: **37.48 RON**
- (Spares: 9.06 RON not counted)

### Still to order

Open shopping list — see `hardware/BOM.md` for sources:

- [ ] ESP32 DevKit V1
- [ ] 12 V / 5 A AC-DC PSU
- [ ] **1× LH M6 nut** for the LH rod-end (rulmentika.ro or specialty fasteners — needed because standard RH nuts won't thread onto the CSL10's left-hand shank). *Or* skip the LH rod-end and buy a 2nd RH (CS10) instead.
- [ ] 100 µF / 25 V electrolytic cap (TMC2209 motor supply — *required*, snubs voltage spikes; without it the driver dies)
- [ ] 3M VHB 4950 / 5952, 19 mm × ~1 m
- [ ] M4 × 16 self-tapping screws (~8 pcs)
- [ ] Inline 5 A blade fuse holder + fuses
- [ ] Filament for 3D-printed brackets (PETG or ABS, ~50 g total)
- [ ] Hookup wire (silicone, 18-22 AWG) for motor + endstop runs

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
