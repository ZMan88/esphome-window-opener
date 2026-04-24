# Architecture

## Why one actuator drives both modes

A European tilt-and-turn window has two pivot axes that intersect at the bottom-hinge corner. That corner is the only point on the sash that **does not move** in either mode. Anchoring one end of a linear actuator at that corner and the other end at the diagonally-opposite sash corner means:

- In tilt mode: extending the actuator pushes the top of the sash inward (tilt opens).
- In turn mode: extending the actuator pushes the opposite side of the sash inward (turn opens).

The two arcs are in different planes, which is why both ends of the actuator need ball-joint rod ends — see `mechanical/README.md`.

The firmware is kept mode-agnostic: it commands a stroke position in 0–100 %. Whichever mode the user has selected on the window handle determines what that stroke does. This keeps the firmware, the HA integration, and the calibration data simple — one position scale, one `cover` entity.

## Software stack

```
Home Assistant
       │  (native ESPHome API, encrypted)
       ▼
     ESP32 ── ESPHome firmware (firmware/window-opener.yaml)
       │      - cover entity state machine
       │      - variant package (linear or stepper)
       ▼
  Motor driver ── Actuator
 (BTS7960 / TMC2209)
```

HA sees one entity: `cover.window_opener` with `position` 0–100. It does not know or care which actuator variant is flashed or which window mode the handle is in.

## Position tracking

- **Linear-actuator variant:** ESPHome's `cover.time_based` platform interpolates position from commanded duration. Cheap, no extra hardware. Drifts after repeated partial moves — full open/close periodically re-syncs the estimate. An optional 10-turn pot on GPIO35 upgrades this to closed-loop.
- **Stepper variant:** step counting after homing against a closed-side endstop. Exact, but the device reports `unknown` until the first homing sweep completes on boot.

## Safety model

- New movement commands pre-empt in-flight ones.
- Stall or obstruction → stop and hold. No auto-retry. HA surfaces the stuck state so a human can intervene.
- On boot: position unknown → HA cover state `unknown` → first command triggers homing.
- The window handle is the physical manual override. Turning the handle mid-travel doesn't hurt anything — the sash disengages from whichever pivot path it was on.

## What's explicitly out of scope for v1

- Battery backup.
- On-device pushbuttons.
- Rain / CO₂ sensors on the device itself (HA handles these).
- Multi-window coordination.
- Remote web UI outside of HA.
