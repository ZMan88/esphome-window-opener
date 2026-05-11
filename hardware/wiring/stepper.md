# Wiring — Stepper variant

NEMA17 stepper driven by a BIGTREETECH TMC2209 V1.3 driver, controlled by a Seeed Studio XIAO ESP32-C6. STEP/DIR variant uses the bottom 6 lines; UART variant adds D6/D7 (and optionally D9 for stall detection).

## Pin map (XIAO ESP32-C6 → BTT TMC2209 V1.3)

| XIAO label | GPIO | Driver pad | Used by | Notes |
|---|---|---|---|---|
| D1 | GPIO1 | `DIR` | both variants | |
| D2 | GPIO2 | `STEP` | both variants | |
| D3 | GPIO21 | `EN` | both variants | Active-low. **Do not** set `inverted: true` in the UART variant — the slimcdk component inverts internally. |
| D6 | GPIO16 | `TX` | UART variant only | **1 kΩ in series** with this line. R10 on the driver bottom must be bridged first (factory NC). |
| D7 | GPIO17 | `RX` | UART variant only | Direct, no resistor. |
| D8 | GPIO19 | endstop switch (COM) | both variants | NO contact of switch → `GND`. Firmware uses `INPUT_PULLUP` + `inverted: true`. |
| D9 | GPIO20 | `DIAG` | UART variant, **optional** | **Not currently wired.** Adding this single wire enables interrupt-based stall detection in the slimcdk component (otherwise stall events are unreliable). Set `diag_pin: GPIO20` in `firmware/variants/stepper-uart.yaml` once wired. |
| 3V3 | — | `VIO` | both variants | Logic supply. |
| GND | — | `GND` | both variants | Logic ground (common with 12 V PSU GND). |
| 5V | — | (Buck `OUT+`) | both variants | Powered by MP1584 buck converter, not the driver. |

### V1.3 UART quirk — R10 must be bridged

The TMC2209 chip has a single bidirectional UART pin (`PDN_UART`). On the BTT V1.3 the `RX` and `TX` header pads are connected via **R10**, but **R10 ships unpopulated** (factory default). With R10 open:

- The `RX` pad is wired to `PDN_UART` directly — this is the only live UART pad out of the box.
- The `TX` pad is **not connected to anything** — wiring to it does nothing.

This is why a multimeter shows no continuity between RX and TX on a stock V1.3. The official BTT manual ([`BIGTREETECH-Stepper-Motor-Driver/TMC2209/V1.3/manual`](https://github.com/bigtreetech/BIGTREETECH-Stepper-Motor-Driver/tree/master/TMC2209/V1.3/manual)) says:

> *"To alter UART pin assignments for compatibility with different boards, solder the two pads at R10 together."*

So before flashing the UART variant: flip the driver over, find the **R10** pads on the bottom side (between the RX/TX header pins), and bridge them. After bridging, both `RX` and `TX` header pins go to the same `PDN_UART` net and the cross-wiring above (XIAO D6 → driver `RX`, XIAO D7 → driver `TX`) works as drawn.

**You also need a 1 kΩ resistor in series with the XIAO TX line.** The slimcdk ESPHome component README explicitly requires it:

> *"This is the ESPHome device's transmit pin. This should be connected through a 1 kΩ resistor to PDN_UART on the TMC2209."*

The 1 kΩ provides contention protection — when the chip is responding, it actively drives the line at the same time the XIAO TX is idling HIGH; without the resistor, the two outputs fight directly. Two equally good ways to add it:

1. **Solder a 1 kΩ SMD (0603/0805) into the R10 footprint** instead of a solder blob. This bridges R10 *through* the resistor — driver TX pad → 1 kΩ → PDN_UART, while RX pad stays direct. Cleanest option.
2. **Inline 1 kΩ on the wire** between XIAO D6 and the driver's TX pad. Solder-blob R10 closed, then put the 1 kΩ on the cable side.

Either way, XIAO D7 → driver RX stays direct (no resistor on the receive side).

**Alternative — single-wire UART** (no soldering on the driver): tie both XIAO `D6` (TX, with the 1 kΩ inline) and `D7` (RX, direct) to the driver's `RX` pad only. In the YAML, set `tx_pin` and `rx_pin` to the same GPIO. Same electrical behavior as option 2 above.

The XIAO ESP32-C6 only breaks out 11 GPIOs (D0-D10), so most ESP32-C6 examples that use GPIO 4-7 won't apply directly. **Avoid D0 (GPIO0) for the endstop** — it's a strapping pin and a low at boot causes the chip to enter download mode. D1-D3 + D8 give clean breakouts on opposite sides of the small board.

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
- One lead to XIAO `D8` (GPIO19), other lead to `GND`.
- Firmware uses `INPUT_PULLUP` with `inverted: true`.

## Current limit

- **STEP/DIR variant (`variants/stepper.yaml`):** set the trimpot on the BTT V1.3 so Vref ≈ 1.0 V (for the LDO 42STH48-1684MAC motor at ~70 % of its 1.68 A rating). Vref formula: `I_RMS = Vref × (1/√2) / (R_SENSE × 2.5)`.
- **UART variant (`variants/stepper-uart.yaml`):** Vref is **ignored**. The component sets `run_current: 1100mA` (motion) and `hold_current: 500mA` (standstill) via UART register writes; the chip's `I_SCALE_ANALOG` is left at 0 so the VREF pin is disconnected from the current scaler. Turning the pot has no effect.

## Direction sanity check

1. Home the carriage against the endstop.
2. Send **open** → carriage should move **away** from the endstop.
3. Send **close** → carriage should move **toward** the endstop.

If reversed, swap one coil pair (e.g. A1 ↔ A2) at the driver.

## Schematic

```
     +12V PSU+ ──┬── 3A fuse ──┬── TMC2209 VM ──┬── 100–470µF ─┐
                 │             │                │              │
                 │             └── Buck IN+     │              │
                 │                 Buck OUT+ ── XIAO 5V        │
                 │                 Buck OUT− ─┬ XIAO GND       │
     +12V PSU− ──┴─────────────── TMC2209 GND┤                 │
                                              └──── common GND

    XIAO D1  (GPIO1)  ──────────── TMC2209 DIR        TMC2209 A1/A2 ── motor coil A
    XIAO D2  (GPIO2)  ──────────── TMC2209 STEP       TMC2209 B1/B2 ── motor coil B
    XIAO D3  (GPIO21) ──────────── TMC2209 EN
    XIAO D6  (GPIO16) ──[1 kΩ]──── TMC2209 TX  ┐
    XIAO D7  (GPIO17) ──────────── TMC2209 RX  ┘ (UART; both pads → PDN_UART once R10 is bridged)
    XIAO D8  (GPIO19) ──────────── endstop COM ── (NO) ── GND
    XIAO D9  (GPIO20) ┄┄┄┄┄┄┄┄┄┄┄┄ TMC2209 DIAG  (optional, not yet wired; enables stall detection)
    XIAO 3V3          ──────────── TMC2209 VIO
```
