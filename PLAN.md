# Window Opener — Roadmap & Decision Log

## Context

DIY opener for a European tilt-and-turn window, ESP32 + ESPHome + Home Assistant. A single actuator anchored at the bottom-hinge-side corner drives both tilt (short arc) and turn (long arc) modes — the user pre-selects the mode via the window handle, the firmware commands only a 0–100% position. Tilt is the primary case; turn must work but is secondary.

## Locked decisions

- **MCU:** ESP32 (DevKit V1)
- **HA integration:** ESPHome, one `cover` entity with position 0–100
- **Mounting:** fixed end on frame at bottom-hinge corner, moving end on opposite sash corner, ball-joint rod ends both sides
- **Actuator:** dual-track — 12V linear actuator **or** NEMA17 + lead screw, pick at build time
- **Power:** 12V mains PSU → buck to 5V for the ESP32; no battery backup in v1
- **Manual override:** window handle (no device buttons in v1)

## Phases

- [x] **Phase 0 — Scaffolding.** Repo structure, docs, base firmware YAML, BOM, wiring templates. (This PR.)
- [ ] **Phase 1 — Bench prototype.** ESP32 + one driver + actuator on a bench jig. Home Assistant discovers `cover.window_opener`. % travel works against a dummy load, no window yet.
- [ ] **Phase 2 — Tilt on real window.** Print brackets, mount on the frame, tune stroke calibration for tilt. Stall detection dialed in.
- [ ] **Phase 3 — Turn validation.** Verify the same mount drives turn mode without binding; measure max stroke actually used.
- [ ] **Phase 4 — Polish.** Safety edge cases, HA automations, Lovelace card, enclosure, OTA workflow.

## Decision log

Append entries as decisions get made. Format: `YYYY-MM-DD — decision — reason.`

- 2026-04-24 — Anchor actuator at bottom-hinge-side corner — single fixed point across both modes; one stroke drives both.
- 2026-04-24 — Defer final actuator choice (linear vs stepper) to build time — dictated by parts availability, and ESPHome packages make the swap cheap.
- 2026-04-24 — Tilt takes priority over turn in firmware/UX trade-offs — tilt is the everyday ventilation case.

## Open questions

- License choice (placeholder MIT).
- Git remote — GitHub, public or private?
- Exact window dimensions (width × height, sash weight) — needed to size actuator force and stroke before ordering parts.
- 3D-print material for brackets — PETG vs ABS (sun/heat resistance).
- Do we want an `esphome` `switch` for "home now" on boot, or keep homing fully automatic?
- Stall detection threshold — decide empirically in Phase 1.
