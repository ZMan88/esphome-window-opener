# Wiring — Linear Actuator variant

12V DC linear actuator driven by a BTS7960 H-bridge, controlled by an ESP32.

## Pin map (Seeed Studio XIAO ESP32-C6)

| XIAO label | GPIO | Goes to | Notes |
|---|---|---|---|
| D1 | GPIO1 | BTS7960 `RPWM` | Forward PWM (extend) |
| D2 | GPIO2 | BTS7960 `LPWM` | Reverse PWM (retract) |
| 3V3 | — | BTS7960 `R_EN` + `L_EN` | Tie both enables high |
| GND | — | BTS7960 `GND` | Common ground |
| (optional) D0 / A0 | GPIO0 | 10-turn pot wiper | ADC1_CH0 |
| (optional) 3V3 / GND | — | Pot ends | Orient so extend = higher voltage |

The XIAO ESP32-C6 has 11 broken-out GPIOs. Pins above use only D0/D1/D2 — leaves D3-D10 free for future expansion (status LED, additional sensors, etc.).

## Power

| From | To | Notes |
|---|---|---|
| 12V PSU `+` | BTS7960 `B+` via inline 5A fuse | Fuse near the PSU, not at the driver |
| 12V PSU `−` | BTS7960 `B−` | Common ground with ESP32 |
| 12V PSU `+` | Buck converter IN+ | Same 12V rail |
| Buck OUT+ / OUT− (5V) | ESP32 `5V` / `GND` | Feed ESP32 via its 5V pin, not 3V3 |
| BTS7960 `M+` / `M−` | Actuator motor leads | Polarity determines extend direction |

Add a **TVS diode** (1.5KE18CA) across the actuator motor leads to snub inductive spikes.

## Direction sanity check

After first flash:

1. Send **open** → actuator should **extend** (push sash away from frame anchor).
2. Send **close** → actuator should **retract**.

If reversed, swap `M+` / `M−` at the driver (easier than editing firmware).

## Schematic

```
     +12V PSU+ ──┬── 5A fuse ──┬── BTS7960 B+ ──┐
                 │             │                │
                 │             └── Buck IN+     │
                 │                 Buck OUT+ ── ESP32 5V
                 │                 Buck OUT− ─┬ ESP32 GND
     +12V PSU− ──┴─────────────── BTS7960 B−─┤
                                              └─ common GND

    XIAO D1 (GPIO1) ── BTS7960 RPWM           BTS7960 M+ ── Actuator +
    XIAO D2 (GPIO2) ── BTS7960 LPWM           BTS7960 M− ── Actuator −
    XIAO 3V3        ─┬─ BTS7960 R_EN                    (TVS 1.5KE18CA across M+/M−)
                     └─ BTS7960 L_EN
```
