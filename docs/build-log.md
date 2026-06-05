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
| LM2596 DC-DC step-down regulator × 4 (kept as spares — MP1584 mini chosen for the build) | TBD | 37.48 | ✅ |
| MP1584-style mini buck (~22 × 14 mm, 12 V → 5 V) | drawer | — | ✅ |

### Spares / parts ordered but not used in this build

| Part | Vendor | Price (RON) | Note |
|---|---|---:|---|
| Flexible coupler 5 mm → 5 mm | TBD | 9.06 | Doesn't fit this build (motor shaft is 5 mm but lead screw is 8 mm). Save for a future project. |

### Running totals

- Mechanical (lead-screw + nuts + bearings + rod-ends): **134.11 RON**
- Stepper + coupler + driver + endstops: motor TBD + endstops TBD + **95.40 RON**
- Power: **37.48 RON**
- (Spares: 9.06 RON not counted)

### Already on hand (drawer)

| Part | Note |
|---|---|
| Seeed Studio XIAO ESP32-C6 | User has spares from prior projects. Chosen over classic ESP32 to keep Matter/Thread on the table, and over the DevKitC-1 for the smaller form factor. Firmware uses ESP-IDF framework + GPIO 1/2/21/19 (XIAO labels D1=DIR, D2=STEP, D3=EN, D8=endstop). |
| Configurable bench PSU | Used for Phase 1 bench testing instead of a fixed AC-DC brick. Set 12 V, 1 A limit for first power-on, 3 A limit for normal operation. A dedicated 12 V / 5 A AC-DC brick can wait until Phase 2 (window install). |
| 470 µF / 35 V electrolytic cap | Used in place of the 100 µF / 25 V called out in the wiring docs. Higher capacitance + higher voltage rating = more headroom; common 3D-printer modding upgrade. ≥100 µF is the spec, more is better. |
| Hookup wire | Mixed lengths / colours of 22 AWG silicone wire. Sufficient for bench + window runs. |
| Motor pigtail | The LDO motor shipped with a JST-XH 4-wire pigtail. Either cut the connector off and screw bare wires into the TMC2209, or use an XH-to-XH cable. |

### Phase 1 bench-test readiness

✅ **Ready to bench-test.** All Phase 1 parts on hand (motor, driver, cap, ESP32-C6, PSU, wires). Follow `docs/bench-test.md`.

### Still to order — for Phase 2 (window install)

- [ ] **1× LH M6 nut** for the LH rod-end (rulmentika.ro or specialty fasteners — needed because standard RH nuts won't thread onto the CSL10's left-hand shank). *Or* skip the LH rod-end and buy a 2nd RH (CS10) instead.
- [ ] **Dedicated 12 V / 5 A AC-DC PSU** (for permanent install — once the bench test passes and the rig is going onto the window).
- [ ] 3M VHB 4950 / 5952, 19 mm × ~1 m
- [ ] M4 × 16 self-tapping screws (~8 pcs)
- [ ] Inline 5 A blade fuse holder + fuses (for the permanent install)
- [ ] Filament for 3D-printed brackets + lead-screw rig (PETG or ABS, ~250 g total)
- [ ] (optional) 8 mm smooth steel rod for carriage anti-rotation (~150 mm length, will source after rig CAD is finalised)

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
- [x] **Phase 1 — Bench prototype passed 2026-05-08** (XIAO + TMC2209 + LDO motor on the desk; HA discovered `cover.window_opener`; open/close/% all working).
- [x] **Phase 1.5 — UART upgrade passed 2026-05-11**. R10 bridged on driver, 1 kΩ on TX line, DIAG wire from driver → XIAO D9 for hardware-interrupt stall detection. `firmware/variants/stepper-uart.yaml` is the active variant. Software currents (1100/500 mA), motor_load + actual_current sensors, temperature-band sensor all working.
- [x] **Firmware feature pass 2026-06-05** (full feature set on `stepper-uart.yaml`). Added: auto-homing on boot + on-demand (position `unknown` until first home); **closed detection from the window's own HA contact sensor** (`closed_sensor_entity` substitution; D8 micro-switch left commented, not installed); **lock** entity (drive-closed + 900 mA clamp, refuses open while locked, persists across reboot); **free-wheel** switch (`tmc2209.disable`, hand-movable, marks position unknown if the sash crosses the closed sensor while free); open-end via StallGuard hard-stop. **Not yet flashed/tested on hardware** — desk re-test pending. Set `closed_sensor_entity` to the real HA entity before flashing.
- [ ] Phase 2 — Mechanical assembly (lead-screw rig, dry-fit on window)
- [ ] Phase 3 — Tuning + HA integration on real window
- [ ] Phase 4 — Polish (enclosure, automations, CAD STLs released)

## Phase 3 — StallGuard tuning procedure (do this once mounted)

StallGuard is currently disabled (`tmc2209.stallguard: { threshold: 0 }` in `firmware/variants/stepper-uart.yaml`) because at the bench with no mechanical load the chip can't distinguish "free running" from "stalled" — SG_RESULT pins near 0 either way. Once the motor is on the lead-screw rig with the carriage and rod-ends loaded, retune as follows:

1. **First run, keep `threshold: 0`.** Run a few full open + close cycles via HA so motion completes without spurious stall trips.
2. **Watch `motor_load` in HA.** Ignore the accel/decel spikes — look for the **max reading during the constant-velocity middle portion** of motion. Call that **M** (expect 40-70% under typical sash + seal friction).
3. **Compute SGTHRS** for trip 30 points above the floor:
   ```
   target_SG = 510 * (1 - (M + 30)/100)
   SGTHRS    = target_SG / 2
   ```
   Example: M = 50% → SGTHRS = (510·0.2)/2 = **51**.
4. **Edit the YAML**, change `threshold: 0` to the computed value, flash, retest.
5. **Verify**: normal motion completes without `Stall detected — stopping window`. Manually pinching the carriage / running into the closed-handle hard stop should fire it within ~½ s. If it false-trips during normal motion, bump SGTHRS down ~10 and retry.
