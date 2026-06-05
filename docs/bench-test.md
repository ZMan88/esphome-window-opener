# Bench test — Phase 1

The goal of this phase is **proving the electronics drive the motor before touching the window**. If anything is going to be wrong (mis-flashed firmware, wrong pin map, dead driver, miswired coils), it's much cheaper to find out at the desk than after you've stuck a bracket to a window with VHB.

## Success criteria

By the end of this phase, all of the following work:

1. Home Assistant auto-discovers `cover.window_opener` after the ESP32-C6 is flashed.
2. `cover.open_cover` from HA → motor spins one way.
3. `cover.close_cover` from HA → motor spins the other way.
4. `cover.set_cover_position 50` → motor moves a calibrated amount and stops.
5. Touching the endstop switch resets reported position to 0 in HA.

No window. No brackets. No lead screw yet. **Just a bare motor on the desk** moving on command.

## Parts you need on the bench

- Seeed Studio XIAO ESP32-C6 + USB-C cable
- TMC2209 V1.3 (with stick-on heatsink)
- LDO 42STH48-1684MAC stepper motor
- **≥ 100 µF / ≥ 25 V electrolytic capacitor** — non-negotiable, see "Why the cap" below. 470 µF / 35 V is a fine upgrade.
- 12 V supply: a configurable bench PSU (set 12.0 V, current limit 1 A for first power-on, raise to 3 A once moving cleanly) or a fixed 12 V / 5 A AC-DC brick.
- XIAO power: USB during bench testing — no need for the buck (MP1584 / LM2596) yet.
- Creality endstop microswitch (optional for steps 1-4, required for step 5)
- 8-10 jumper wires (Dupont female-to-female / female-to-male)
- A breadboard or just twisted/soldered wire splices
- Multimeter (for setting Vref)

> **Why the cap:** stepper coils are inductors. Every microstep, the TMC2209 switches coil current off; the inductor's stored energy creates a voltage spike on `VM`. Without a local cap to absorb those spikes, they exceed the IC's 28 V rating and silicon-erode the FETs until one shorts. ≥100 µF / ≥25 V electrolytic, mounted *within a few cm of the chip's VM/GND pins*, polarity-correct (white stripe to GND). The cap at the PSU end of the wires is *not* a substitute — wire inductance is what makes the cap-at-the-driver mandatory.

## Wiring — do this with everything powered off

### 1. The cap goes first

Solder a **100 µF / ≥ 25 V electrolytic** directly across the TMC2209's `VM` and `GND` pins on the underside of the module, with the leads as short as you can manage. Mind the polarity — the white stripe is the negative side, goes to GND. *Do not skip this step. Do not power up without it.*

### 2. Logic side: XIAO ESP32-C6 → TMC2209

| XIAO label | GPIO | → | TMC2209 pin |
|---|---|:-:|---|
| D2 | GPIO2 | → | STEP |
| D1 | GPIO1 | → | DIR |
| D3 | GPIO21 | → | EN |
| 3V3 | — | → | VIO |
| GND | — | → | GND |

Five wires. The TMC2209 has eight other pins on the logic side (DIAG, INDEX, MS1, MS2, etc.) — leave them disconnected for v1; the defaults are fine (1/16 microstepping, STEP/DIR mode, no UART tuning).

### 3. Motor side: TMC2209 → motor

The LDO 42STH48 is a 4-wire bipolar stepper. The wires come in two pairs (one pair per coil). With coil pairs `A` and `B`:

| TMC2209 pin | → | Motor wire |
|---|:-:|---|
| A1 | → | Coil A, end 1 |
| A2 | → | Coil A, end 2 |
| B1 | → | Coil B, end 1 |
| B2 | → | Coil B, end 2 |

If you don't know which two motor wires form a pair, **measure with a multimeter on continuity**: the two within a coil have low resistance (a few Ω), the two across coils have no continuity. LDO motors usually have a wiring diagram on the datasheet that maps the connector pinout; check that first.

### 4. Power: PSU → TMC2209

| 12 V PSU | → | TMC2209 |
|---|:-:|---|
| `+12 V` | (via 3 A inline fuse) | `VM` |
| `GND` | → | `GND` (same as logic GND — single star point) |

If you're using the buck (MP1584 mini or LM2596) for the XIAO instead of USB power, also tap the 12 V into the buck VIN/GND and run the buck VOUT/GND to the XIAO's 5V/GND pins.

### 5. Endstop (only needed for step 5 of success criteria)

| XIAO label | GPIO | → | Endstop |
|---|---|:-:|---|
| D8 | GPIO19 | → | Switch common (`COM`) |
| GND | — | → | Normally-open contact (`NO`) |

The firmware uses `INPUT_PULLUP` with `inverted: true`, so closing the switch pulls GPIO19 to ground and the firmware reads it as "triggered → reset position to 0".

## Set Vref before commanding motion

The TMC2209 has a tiny potentiometer that sets the **per-coil current limit**. Out of the box it's usually set conservatively low; if you skip this you'll get weak / stalling motion.

Procedure:

1. Connect everything *except* the motor (or unplug the motor wires temporarily).
2. Power up 12 V and the ESP32. The driver is now energised but no motor coils are switching.
3. Touch a multimeter probe (set to DC volts) between the TMC2209's `Vref` test point (a small via labelled `VREF`) and `GND`.
4. Adjust the pot with a small flat screwdriver until the multimeter reads about **1.0 V**.
5. Power off, reconnect the motor.

The TMC2209 conversion is roughly `I_rms ≈ Vref × 1.77 × √2 / Rsense_ratio` — the simplified rule of thumb is **Vref ≈ 0.55 × I_rms**, so Vref = 1.0 V → ~1.8 A RMS, which is just above the LDO's 1.68 A rating. Drop to **0.9 V** if the driver gets uncomfortably warm at idle (>70 °C — fingertip "ow" temperature).

## Flash the firmware

```
cp firmware/common/secrets.example.yaml firmware/common/secrets.yaml
# edit secrets.yaml: wifi_ssid, wifi_password, fallback_password,
#                    api_encryption_key (openssl rand -base64 32),
#                    ota_password
esphome run firmware/window-opener.yaml
```

First compile takes 5–10 minutes (ESP-IDF building its toolchain). After the first build, subsequent flashes go over Wi-Fi via OTA.

## Test sequence

In Home Assistant, with the ESPHome integration:

1. **`cover.open_cover` on `cover.window_opener`** → motor should spin away from the closed direction. If it spins the *wrong way*, swap coil pairs `A1↔A2` (or set `dir_pin: { number: GPIO5, inverted: true }` in `firmware/variants/stepper.yaml` and re-flash).
2. **`cover.close_cover`** → motor spins the opposite direction.
3. **`cover.set_cover_position` to 50** → motor runs for half the calibrated stroke and stops. Position attribute in HA shows `50`.
4. **Trigger the endstop manually** (touch a wire from GPIO7 to GND) → HA position attribute jumps to 0.

If all four pass, Phase 1 is done.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Motor vibrates / hums but doesn't rotate | Coil pairs miswired (mixed across coils) | Swap any two adjacent motor wires — try `A2 ↔ B1`. |
| Motor moves only one direction | DIR signal stuck or unwired | Re-seat the D1 (GPIO1) wire; multimeter the signal during a `cover.close_cover` action. |
| Motor stalls under modest load | Current limit too low | Raise Vref by 0.05 V at a time, retest. |
| TMC2209 visibly hot (>70 °C at idle) | Current limit too high, or no heatsink, or no airflow | Lower Vref, attach the stick-on heatsink. |
| HA shows the device offline | Wi-Fi creds, encryption key mismatch, or HA can't reach the subnet | Check ESPHome logs (`esphome logs firmware/window-opener.yaml`); verify `secrets.yaml`. |
| ESPHome compile fails on `framework: esp-idf` | First-time toolchain build interrupted | `rm -rf .esphome/` and re-run; first build genuinely takes 5–10 min. |
| TMC2209 dies on first power-up | **Missing 100 µF cap** | Order another driver. Don't skip the cap this time. |
| Position drifts after multiple moves | Steps lost (current too low, speed too high, or mechanical bind) | Lower `max_speed` in `stepper.yaml`; increase Vref; check the lead screw moves freely by hand. |

## Feature test — lock / free-wheel / HA closed sensor (`stepper-uart` variant)

These exercise the firmware feature set added 2026-06-05. Run them at the desk
(bare motor, no window) before mounting. They only apply to
`firmware/variants/stepper-uart.yaml` — the linear-actuator and basic-stepper
variants don't have current-based lock/free-wheel.

### Simulating the window contact on the bench

There's no real window contact on the desk, so fake it with a Home Assistant
helper and point the firmware at it:

1. In HA: **Settings → Devices & services → Helpers → Create → Toggle**, name it
   e.g. *Fake window contact* (`input_boolean.fake_window_contact`).
2. In `firmware/variants/stepper-uart.yaml` set
   `closed_sensor_entity: "input_boolean.fake_window_contact"`, flash.
3. Polarity matches the real convention used in the lambda: **toggle ON = window
   OPEN, toggle OFF = window CLOSED**. (Flip the `!...state` in `window_closed`'s
   lambda if your real sensor is the other way round.)

Watch `esphome logs firmware/window-opener.yaml` throughout — every transition
logs a line.

### Tests

| # | Do this | Expect |
|---|---|---|
| F1 | Flash with the fake contact **ON** (open). Look at `cover.window` position. | Position is **`unknown`** — no homing has happened, and boot is passive (motor does **not** move). |
| F2 | Toggle the fake contact **OFF** (closed). | `window_closed` → on_press fires: position snaps to **0** with **no motor motion** (homed in place). Log: "Homed…". |
| F3 | Toggle contact **ON** (open) again, then call `cover.open_cover`. | Position was known, so it just runs toward open. (If you'd toggled to make position unknown first, the move would **home toward closed first**, then open.) |
| F4 | Call **`lock.lock`** on `lock.window_lock`. | Motor drives to closed (pos 0), then *Window opener — actual current* climbs to ~**900 mA** (the lock clamp). Lock entity shows **locked**. |
| F5 | While locked, call `cover.open_cover` or set position 50. | **Ignored.** Log: "Locked — open/position command ignored". Slider snaps back. `cover.close_cover` is still allowed. |
| F6 | While locked, turn on `switch.window_freewheel`. | **Rejected.** Log: "Cannot free-wheel while locked". Toggle reverts to off on its own. |
| F7 | Call `lock.unlock`. | Hold current drops back to ~**500 mA**; lock shows **unlocked**. |
| F8 | Power-cycle while **locked** (lock first, then unplug/replug). | On boot it actively drives closed and re-clamps to ~900 mA; lock entity comes back **locked**. (Only the locked state moves the motor on boot.) |
| F9 | Unlocked: turn on `switch.window_freewheel`. | *actual current* drops to **0**; the shaft spins **freely by hand** (driver disabled via `tmc2209.disable`). |
| F10 | While free-wheeling, toggle the fake contact (simulate the sash crossing the closed point), then turn the switch **off**. | Position goes **`unknown`** (move detected). Next `cover.*` command **homes first**, then moves. |
| F11 | While free-wheeling, *don't* toggle the contact, then turn the switch off. | Position is **kept** (no crossing detected → assumed unmoved). Known limitation: a real hand-move that never crosses the contact isn't caught — see `PLAN.md`. |

> **Open-end stall (F-extra):** StallGuard is disabled on the bench (`threshold: 0`)
> because an unloaded motor reads near-stall constantly. The "stall while opening
> → reported full stroke" path is therefore inert until SGTHRS is tuned on the
> real rig — see `docs/build-log.md` "Phase 3 — StallGuard tuning procedure".

## After Phase 1 passes

Move to **Phase 2 — mechanical bring-up**:

- Print both brackets (`mechanical/cad/*.scad`).
- Tap the M6 holes per `mechanical/cad/README.md`.
- Source the remaining mechanical bits (1× LH M6 nut, VHB, M4 screws, fuse holder, hookup wire).
- Design the lead-screw rig brackets (motor mount, far-end bearing block, carriage with rod-end + Prusa nut). These aren't modelled yet — they need physical parts in hand for measurement.

Don't skip Phase 1. Bench-test passes are the only thing that distinguishes "the motor is fine, it's the firmware" from "the firmware is fine, it's the motor" when something later goes wrong on the window.
