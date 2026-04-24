# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A DIY ESP32-based opener for a European **tilt-and-turn** window, integrated with Home Assistant via ESPHome. A single actuator is mounted **horizontally across the top**: fixed end at the **top-middle of the frame**, moving end on the **top rail of the sash, 120 mm from the hinge**. Extending the actuator opens the window in whichever mode the handle has selected (tilt or turn).

Target window measurements and derived numbers: `docs/window-spec.md`. Geometry diagram: `docs/geometry.svg`. Full roadmap, phase tracker, and open questions: `PLAN.md`.

## Common commands

Firmware (ESPHome) — run from the repo root:

- `esphome config firmware/window-opener.yaml` — validate YAML (no hardware needed)
- `esphome compile firmware/window-opener.yaml` — build firmware image
- `esphome run firmware/window-opener.yaml` — compile + flash + follow logs (auto-selects USB vs OTA)
- `esphome logs firmware/window-opener.yaml` — follow logs only

Before first build, copy the secrets template and fill it in:

```
cp firmware/common/secrets.example.yaml firmware/common/secrets.yaml
# edit firmware/common/secrets.yaml with real Wi-Fi + OTA creds
```

## Architecture

### Mounting geometry (load-bearing — read before touching mechanical/CAD)

Fixed end at **top-middle of the frame** `(W/2, 0)`. Moving end on the **top rail of the sash, d = 120 mm from the hinge side** `(W - d, 0)`. Both endpoints are **off both pivot axes** (bottom edge = tilt axis, right edge = turn axis), which is what lets one actuator drive both modes. If either endpoint moves onto an axis, that mode stops being driveable — mechanical regressions that shift anchors toward the hinge or the bottom edge will silently break turn or tilt.

**Both ends must use ball-joint rod ends** — the actuator body swings vertically in tilt and horizontally in turn (different planes). Fixed pivots or single-axis hinges will bind in one of the modes.

See `mechanical/README.md` for the full reasoning and `docs/window-spec.md` for the measurements that produced `d = 120 mm`.

### Priority: tilt > turn

Tilt is the everyday ventilation case. Firmware defaults, calibration, and HA UX favor tilt. A trade-off that improves tilt at the cost of turn-mode precision is usually acceptable. The reverse is not.

### Mode asymmetry (important for HA UX)

Full tilt is only ~26% of the actuator's stroke; full turn is ~78%. So `cover.position = 50` means a very different window angle in the two modes. **The `cover` entity exposes raw stroke %** — it intentionally does not pretend to be symmetric. HA automations and dashboards should translate to "tilt X%" / "turn X%" per mode if needed (see `home-assistant/automations.yaml`). A future handle-position sensor can let firmware remap cleanly per mode — tracked in `PLAN.md`.

### Dual actuator variants

Parts availability varies, so the firmware supports two actuator paths selected at build time via the `packages:` block in `firmware/window-opener.yaml`:

| | `variants/linear-actuator.yaml` | `variants/stepper.yaml` |
|---|---|---|
| Drive | 12V DC linear actuator + BTS7960 H-bridge | NEMA17 + TMC2209 in STEP/DIR mode |
| Position | Time-based over calibrated stroke (optional 10-turn pot on ADC) | Step counting after endstop homing |
| Homing | Current-spike stall detection | Endstop switch on closed side |

Both variants expose the **same HA contract**: one `cover` entity with position 0–100. HA automations and Lovelace cards must not depend on which variant is flashed. If you're adding a feature, add it to both variants or explicitly document that it's variant-specific in `firmware/variants/<name>.yaml`.

### Safety invariants

- New movement commands interrupt in-flight ones — do not queue.
- Stall / obstruction → stop and hold; do **not** auto-retry.
- Position is unknown on boot until the first homing sweep completes; HA should see `unknown` during that window.

## Repository layout

- `firmware/` — ESPHome configs. `window-opener.yaml` is the entry point; motor/sensor specifics live in `variants/`. Shared WiFi/API/OTA is in `common/base.yaml`.
- `hardware/` — BOM, per-variant wiring, and power design (`hardware/power.md`).
- `mechanical/` — CAD sources (FreeCAD `.FCStd`) and exported STLs. Read `mechanical/README.md` before changing bracket geometry.
- `home-assistant/` — example cover override, automations, Lovelace card. These are references to paste into a Home Assistant install, not consumed by this repo's build.
- `docs/` — architecture, assembly, and calibration notes.
- `PLAN.md` — living roadmap, phase tracker, decision log, open questions. Update when decisions are made; don't edit history, append.

## Conventions

- **Secrets**: `firmware/common/secrets.yaml` (git-ignored). The checked-in `secrets.example.yaml` is the template.
- **Pin changes**: if you change a GPIO in a variant YAML, update the matching table in `hardware/wiring/<variant>.md` in the same change.
- **No manual pushbuttons on the device in v1**: the window handle is the manual override.
- **No battery backup in v1**: mains 12V PSU, buck-converted to 5V for the ESP32.
- **Don't rename the HA entity** (`cover.window_opener`) without grepping `home-assistant/` and updating every referencing automation.
