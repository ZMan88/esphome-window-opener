# Window Opener — Roadmap & Decision Log

## Context

DIY opener for a European tilt-and-turn window, ESP32 + ESPHome + Home Assistant. A single actuator anchored at the bottom-hinge-side corner drives both tilt (short arc) and turn (long arc) modes — the user pre-selects the mode via the window handle, the firmware commands only a 0–100% position. Tilt is the primary case; turn must work but is secondary.

## Locked decisions

- **MCU:** Seeed Studio XIAO ESP32-C6 — chosen for forward-compatibility with Matter / Thread later if desired, plus the smaller form factor
- **HA integration:** ESPHome, one `cover` entity with position 0–100 (native API; Matter is a future option)
- **Mounting:** fixed end at top-middle of frame, moving end on top edge of sash 120 mm from hinge, ball-joint rod ends at both ends
- **Actuator:** **stepper + lead screw** (Variant B) — committed late April 2026; parts ordered, see `docs/build-log.md`
- **Power:** 12V mains PSU → buck to 5V for the ESP32; no battery backup in v1
- **Manual override:** window handle (no device buttons in v1)

## Phases

- [x] **Phase 0 — Scaffolding.** Repo structure, docs, base firmware YAML, BOM, wiring templates. (This PR.)
- [x] **Phase 1 — Bench prototype.** ESP32 + driver + actuator on a bench jig. Home Assistant discovers `cover.window_opener`. % travel works against a dummy load. ✅ Passed 2026-05-08 with `variants/stepper.yaml` (basic STEP/DIR).
- [ ] **Phase 1.5 — UART upgrade (optional).** Add two wires to the driver, switch to `variants/stepper-uart.yaml`, verify current/load/temperature show up as HA sensors. Replaces the Vref pot with software current control.
- [ ] **Phase 2 — Tilt on real window.** Print brackets, mount on the frame, tune stroke calibration for tilt. Stall detection dialed in.
- [ ] **Phase 3 — Turn validation.** Verify the same mount drives turn mode without binding; measure max stroke actually used.
- [ ] **Phase 4 — Polish.** Safety edge cases, HA automations, Lovelace card, enclosure, OTA workflow.

## Decision log

Append entries as decisions get made. Format: `YYYY-MM-DD — decision — reason.`

- 2026-04-24 — Anchor actuator at bottom-hinge-side corner — single fixed point across both modes; one stroke drives both. **SUPERSEDED 2026-04-24** (see below).
- 2026-04-24 — Defer final actuator choice (linear vs stepper) to build time — dictated by parts availability, and ESPHome packages make the swap cheap.
- 2026-04-24 — Tilt takes priority over turn in firmware/UX trade-offs — tilt is the everyday ventilation case.
- 2026-04-24 — **Corrected mounting geometry: fixed end at top-middle of frame, moving end on top rail of sash 120 mm from hinge.** The earlier "bottom-hinge corner" plan was wrong: that point sits on both pivot axes, so the actuator distance is conserved in both modes — it couldn't actually drive anything. Both new endpoints are off both axes. Reason: kinematic analysis during design review.
- 2026-04-24 — Target window measured: W=845, H=1325, max tilt ≈ 7°, turn hardstop > 90°. See `docs/window-spec.md`.
- 2026-04-24 — Actuator spec: 12 V, 200 mm stroke, ≥500 N. Stroke driven by 90°+ turn; force by friction torque over a 120 mm moment arm.
- 2026-04-24 — Accept mode-asymmetry in firmware v1: `cover` reports raw stroke %, not per-mode %. Tilt full = ~26%, turn full = ~78%. HA handles mode semantics. A handle-position sensor could remap per mode later — not in v1.
- 2026-04-29 — Variant B (stepper + Tr8x8 lead screw) committed. Parts ordered (LDO 0.9° NEMA17, BIGTREETECH TMC2209 V1.3 ×2, KP08 ×2, Tr8x8 nuts ×3, lead screw 400 mm, 5→8 couplers, M6 rod-ends, LM2596). See `docs/build-log.md`.
- 2026-04-29 — **MCU swapped to ESP32-C6** (already in user's drawer). Kept ESPHome with native API for v1; the C6 keeps Matter/Thread on the table for a future migration. Required: framework switch from `arduino` to `esp-idf`, GPIO remap 25/26/27/34 → 4/5/6/7.
- 2026-05-06 — Specific board confirmed: **Seeed Studio XIAO ESP32-C6** (smaller than the DevKitC-1, only 11 GPIOs broken out). GPIO remapped 4/5/6/7 → 1/2/21/19, exposed as XIAO labels D1/D2/D3/D8. Pin assignment: D1=DIR, D2=STEP, D3=EN, D8=endstop.
- 2026-05-08 — Phase 1 bench-test passed (motor moves on command via HA). Added `variants/stepper-uart.yaml` for the UART-driven upgrade: motor current set in software, current/load/temperature surfaced as HA sensors, StallGuard available. The BTT V1.3 has buffered TX/RX (verified by multimeter — no continuity), so UART wires are direct cross-connection (XIAO D6 ↔ driver RX, XIAO D7 ↔ driver TX) with no series resistor needed.
- 2026-06-05 — **Firmware feature pass on `stepper-uart.yaml`** (now the active variant in `window-opener.yaml`):
  - **Closed detection via the window's own contact sensor imported from HA** (`closed_sensor_entity` substitution), not the printed D8 switch. The D8 endstop is **not installed at the moment** — its block is left commented, ready to OR back in. Reason: v2 mechanical has no carriage to mount the switch on yet, and the window already has a contact sensor. Trade-off: homing now depends on the HA connection.
  - **Lock** (`lock.window_lock`): drives fully closed then clamps at a firmer hold current (`lock_hold_current`, default 900 mA); refuses open/position commands while locked (closing still allowed). The manual handle remains the real mechanical lock. Lock state persists across reboot (re-homes then re-clamps on boot).
  - **Free-wheel** (`switch.window_freewheel`): `tmc2209.disable` so the sash is hand-movable. Move-detection: a transition of the closed signal while free-wheeling marks position unknown → next command re-homes first. Limitation: a bare TMC2209 has no rotor feedback, so hand-movement that never crosses the closed sensor can't be detected (keeps last position). Encoder would fix this — deferred.
  - **Open-end** = StallGuard hard-stop (DIAG on D9): a stall while opening reports position = full stroke; a stall while closing is treated as an obstruction (stop + hold, no retry). Inert until SGTHRS is tuned in Phase 3.
  - **Homing**: passive on boot (no auto-motion — a power blip won't slam an open window shut). Position reads `unknown` until the closed contact reports shut (zeroes in place) or the first move triggers a homing sweep. Locked state is the exception: it actively drives closed on boot to re-clamp. CLAUDE.md "unknown until homed" invariant now actually enforced.

## Open questions

- License choice (placeholder MIT).
- 3D-print material for brackets — PETG vs ABS (sun/heat resistance).
- ~~Do we want an `esphome` `switch` for "home now" on boot, or keep homing fully automatic?~~ **Resolved 2026-06-05:** homing is fully automatic on boot and on-demand before any move when position is unknown. No manual "home" button. (A free-wheel switch and a lock entity were added instead.)
- Free-wheel hand-movement that never crosses the closed sensor isn't detectable without rotor feedback — add a magnetic encoder (e.g. AS5600 on the screw) if per-mm position must survive manual moves. Deferred.
- Stall detection threshold — decide empirically in Phase 1.
- Handle-position sensor (reed switch) to detect tilt vs turn mode — if added, firmware can remap `cover.position` per mode for clean HA UX. Defer to v1.5.
- Exact sash weight — estimated 15–25 kg; confirm with a luggage scale before final actuator purchase.
