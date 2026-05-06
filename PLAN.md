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
- [ ] **Phase 1 — Bench prototype.** ESP32 + one driver + actuator on a bench jig. Home Assistant discovers `cover.window_opener`. % travel works against a dummy load, no window yet. **See `docs/bench-test.md` for the wiring + test procedure.**
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

## Open questions

- License choice (placeholder MIT).
- 3D-print material for brackets — PETG vs ABS (sun/heat resistance).
- Do we want an `esphome` `switch` for "home now" on boot, or keep homing fully automatic?
- Stall detection threshold — decide empirically in Phase 1.
- Handle-position sensor (reed switch) to detect tilt vs turn mode — if added, firmware can remap `cover.position` per mode for clean HA UX. Defer to v1.5.
- Exact sash weight — estimated 15–25 kg; confirm with a luggage scale before final actuator purchase.
