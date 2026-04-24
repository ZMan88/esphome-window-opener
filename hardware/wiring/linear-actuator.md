# Wiring — Linear Actuator variant

12V DC linear actuator driven by a BTS7960 H-bridge, controlled by an ESP32.

## Pin map

| ESP32 GPIO | Goes to | Notes |
|---|---|---|
| GPIO25 | BTS7960 `RPWM` | Forward PWM (extend) |
| GPIO26 | BTS7960 `LPWM` | Reverse PWM (retract) |
| 3V3 | BTS7960 `R_EN` + `L_EN` | Tie both enables high |
| GND | BTS7960 `GND` | Common ground |
| (optional) GPIO35 | 10-turn pot wiper | ADC1_CH7, safe with Wi-Fi |
| (optional) 3V3 / GND | Pot ends | Orient so extend = higher voltage |

**Do not use GPIO34/35/36/39 as outputs** — they are input-only on ESP32.

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

    ESP32 GPIO25 ──── BTS7960 RPWM            BTS7960 M+ ── Actuator +
    ESP32 GPIO26 ──── BTS7960 LPWM            BTS7960 M− ── Actuator −
    ESP32 3V3    ─┬── BTS7960 R_EN                     (TVS 1.5KE18CA across M+/M−)
                  └── BTS7960 L_EN
```
