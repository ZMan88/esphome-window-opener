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

- ESP32-C6 DevKitC-1 + USB-C cable
- TMC2209 V1.3 (with stick-on heatsink)
- LDO 42STH48-1684MAC stepper motor
- **≥ 100 µF / ≥ 25 V electrolytic capacitor** — non-negotiable, see "Why the cap" below. 470 µF / 35 V is a fine upgrade.
- 12 V supply: a configurable bench PSU (set 12.0 V, current limit 1 A for first power-on, raise to 3 A once moving cleanly) or a fixed 12 V / 5 A AC-DC brick.
- ESP32 power: USB during bench testing — no need for the LM2596 buck yet.
- Creality endstop microswitch (optional for steps 1-4, required for step 5)
- 8-10 jumper wires (Dupont female-to-female / female-to-male)
- A breadboard or just twisted/soldered wire splices
- Multimeter (for setting Vref)

> **Why the cap:** stepper coils are inductors. Every microstep, the TMC2209 switches coil current off; the inductor's stored energy creates a voltage spike on `VM`. Without a local cap to absorb those spikes, they exceed the IC's 28 V rating and silicon-erode the FETs until one shorts. ≥100 µF / ≥25 V electrolytic, mounted *within a few cm of the chip's VM/GND pins*, polarity-correct (white stripe to GND). The cap at the PSU end of the wires is *not* a substitute — wire inductance is what makes the cap-at-the-driver mandatory.

## Wiring — do this with everything powered off

### 1. The cap goes first

Solder a **100 µF / ≥ 25 V electrolytic** directly across the TMC2209's `VM` and `GND` pins on the underside of the module, with the leads as short as you can manage. Mind the polarity — the white stripe is the negative side, goes to GND. *Do not skip this step. Do not power up without it.*

### 2. Logic side: ESP32-C6 → TMC2209

| ESP32-C6 pin | → | TMC2209 pin |
|---|:-:|---|
| GPIO4 | → | STEP |
| GPIO5 | → | DIR |
| GPIO6 | → | EN |
| 3V3 | → | VIO |
| GND | → | GND |

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

If you're using the LM2596 buck for the ESP32 instead of USB power, also tap the 12 V into the buck IN+/IN- and run the buck OUT+/OUT- to the ESP32's 5V/GND pins.

### 5. Endstop (only needed for step 5 of success criteria)

| ESP32-C6 pin | → | Endstop |
|---|:-:|---|
| GPIO7 | → | Switch common (`COM`) |
| GND | → | Normally-open contact (`NO`) |

The firmware uses `INPUT_PULLUP` with `inverted: true`, so closing the switch pulls GPIO7 to ground and the firmware reads it as "triggered → reset position to 0".

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
| Motor moves only one direction | DIR signal stuck or unwired | Re-seat GPIO5 wire; multimeter the signal during a `cover.close_cover` action. |
| Motor stalls under modest load | Current limit too low | Raise Vref by 0.05 V at a time, retest. |
| TMC2209 visibly hot (>70 °C at idle) | Current limit too high, or no heatsink, or no airflow | Lower Vref, attach the stick-on heatsink. |
| HA shows the device offline | Wi-Fi creds, encryption key mismatch, or HA can't reach the subnet | Check ESPHome logs (`esphome logs firmware/window-opener.yaml`); verify `secrets.yaml`. |
| ESPHome compile fails on `framework: esp-idf` | First-time toolchain build interrupted | `rm -rf .esphome/` and re-run; first build genuinely takes 5–10 min. |
| TMC2209 dies on first power-up | **Missing 100 µF cap** | Order another driver. Don't skip the cap this time. |
| Position drifts after multiple moves | Steps lost (current too low, speed too high, or mechanical bind) | Lower `max_speed` in `stepper.yaml`; increase Vref; check the lead screw moves freely by hand. |

## After Phase 1 passes

Move to **Phase 2 — mechanical bring-up**:

- Print both brackets (`mechanical/cad/*.scad`).
- Tap the M6 holes per `mechanical/cad/README.md`.
- Source the remaining mechanical bits (1× LH M6 nut, VHB, M4 screws, fuse holder, hookup wire).
- Design the lead-screw rig brackets (motor mount, far-end bearing block, carriage with rod-end + Prusa nut). These aren't modelled yet — they need physical parts in hand for measurement.

Don't skip Phase 1. Bench-test passes are the only thing that distinguishes "the motor is fine, it's the firmware" from "the firmware is fine, it's the motor" when something later goes wrong on the window.
