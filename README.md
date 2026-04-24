# Window Opener

A DIY ESP32-based device that opens and closes a European tilt-and-turn window, integrated with Home Assistant via ESPHome. One actuator anchored at the bottom-hinge corner of the frame drives both tilt and turn modes, controllable as a percentage (0–100%).

**Status:** scaffolding (Phase 0). No hardware built yet. See `PLAN.md`.

## How it works

A tilt-and-turn window has one corner — the bottom-hinge-side corner — that stays fixed in both tilt mode (short inward tilt from the top) and turn mode (full inward swing like a door). Anchoring one end of a linear actuator at that fixed corner and the other end at the opposite sash corner means the same stroke drives both modes. The user picks the mode on the window handle; the firmware only commands position.

## Hardware (at a glance)

- **MCU:** ESP32 DevKit V1
- **Actuator (choose one at build time):**
  - 12V DC linear actuator + BTS7960 H-bridge (robust, simple)
  - NEMA17 stepper + TMC2209 + lead screw (silent, precise)
- **Power:** 12V PSU → buck to 5V for the ESP32
- **Feedback:** time-based position (with optional 10-turn pot) or step counting

Full BOM: [`hardware/BOM.md`](hardware/BOM.md). Wiring: [`hardware/wiring/`](hardware/wiring/).

## Quick start (firmware)

```
cp firmware/common/secrets.example.yaml firmware/common/secrets.yaml
# edit secrets.yaml with Wi-Fi + OTA creds
esphome run firmware/window-opener.yaml
```

Home Assistant auto-discovers the ESPHome device and exposes `cover.window_opener`.

## Repository map

- [`firmware/`](firmware/) — ESPHome YAML
- [`hardware/`](hardware/) — BOM, wiring, power
- [`mechanical/`](mechanical/) — CAD and 3D-print STLs
- [`home-assistant/`](home-assistant/) — example automations and Lovelace card
- [`docs/`](docs/) — architecture, assembly, calibration
- [`PLAN.md`](PLAN.md) — roadmap, decisions, open questions
- [`CLAUDE.md`](CLAUDE.md) — guidance for Claude Code sessions
