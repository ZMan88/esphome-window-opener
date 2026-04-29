# Wiring — Stepper variant

NEMA17 stepper driven by a TMC2209 in STEP/DIR mode, controlled by an ESP32.

## Pin map (ESP32-C6 DevKitC-1)

| ESP32-C6 GPIO | Goes to | Notes |
|---|---|---|
| GPIO4 | TMC2209 `STEP` | |
| GPIO5 | TMC2209 `DIR` | |
| GPIO6 | TMC2209 `EN` | Active-low; firmware inverts |
| GPIO7 | Endstop switch | Other side of switch to GND; firmware uses internal pull-up |
| 3V3 | TMC2209 `VIO` | Logic supply |
| GND | TMC2209 `GND` | Common ground |

**Avoid GPIOs 8, 9, 15** (strapping pins) and **GPIOs 12, 13** (USB-Serial-JTAG) on the C6. GPIOs 24-30 are typically reserved for SPI flash. The pins above (4-7) are all safe general-purpose I/O.

## Power

| From | To | Notes |
|---|---|---|
| 12V PSU `+` | Via 3A fuse → TMC2209 `VM` | Motor supply |
| 12V PSU `−` | TMC2209 `GND` | Common ground with ESP32 |
| 12V PSU `+` | Buck converter IN+ | Same 12V rail |
| Buck OUT 5V | ESP32 `5V` | ESP32 power |
| TMC2209 coil A1/A2 | Motor A-phase pair | Check datasheet for coil pairings |
| TMC2209 coil B1/B2 | Motor B-phase pair | |

**Required:** a 100 µF electrolytic capacitor across `VM` and `GND`, close to the TMC2209. Missing this cap is the #1 cause of driver death.

## Endstop

- Normally-open micro-switch (or magnetic reed + magnet on the carriage).
- One lead to `GPIO34`, other lead to `GND`.
- Firmware uses `INPUT_PULLUP` with `inverted: true`.

## Current limit

Set the TMC2209 Vref so peak coil current is ~70% of the motor's rated current. For a typical 1.5A-rated NEMA17, aim for Vref around 0.8–1.0 V (exact formula in the TMC2209 datasheet and varies slightly by module).

## Direction sanity check

1. Home the carriage against the endstop.
2. Send **open** → carriage should move **away** from the endstop.
3. Send **close** → carriage should move **toward** the endstop.

If reversed, swap one coil pair (e.g. A1 ↔ A2) at the driver.

## Schematic

```
     +12V PSU+ ──┬── 3A fuse ──┬── TMC2209 VM ──┬── 100µF ─┐
                 │             │                │          │
                 │             └── Buck IN+     │          │
                 │                 Buck OUT+ ── ESP32 5V   │
                 │                 Buck OUT− ─┬ ESP32 GND  │
     +12V PSU− ──┴─────────────── TMC2209 GND┤             │
                                              └──── common GND

    ESP32-C6 GPIO4 ── TMC2209 STEP        TMC2209 A1/A2 ── motor coil A
    ESP32-C6 GPIO5 ── TMC2209 DIR         TMC2209 B1/B2 ── motor coil B
    ESP32-C6 GPIO6 ── TMC2209 EN
    ESP32-C6 3V3   ── TMC2209 VIO
    ESP32-C6 GPIO7 ── endstop ── GND
```
