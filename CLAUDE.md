# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A DIY ESP32-based opener for a European **tilt-and-turn** window, integrated with Home Assistant via ESPHome. A single actuator is anchored at the **bottom-hinge-side corner** of the window frame — the one point fixed in both tilt and turn modes — and drives the opposite corner of the sash. The user pre-selects the mode via the window handle; the firmware only commands a 0–100% position along the actuator's stroke.

Full roadmap, phase tracker, and open questions live in `PLAN.md`.

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

The device is always anchored at the bottom-hinge-side corner of the frame. The moving end attaches to the opposite corner of the sash. **Both ends must use ball-joint rod ends** so the actuator can swing through the two different arcs (short tilt arc, wide turn arc) without binding. Any CAD change that replaces rod ends with fixed pivots will break turn mode.

### Priority: tilt > turn

Tilt is the everyday ventilation case. Firmware defaults, calibration, and HA UX favor tilt. A trade-off that improves tilt at the cost of turn-mode precision is usually acceptable. The reverse is not.

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
