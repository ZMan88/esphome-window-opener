# Bill of Materials

Romanian online sources are listed first; international fallbacks (AliExpress, Amazon) where the part is uncommon locally. Prices are rough April 2026 estimates and should be re-verified at order time.

Pick **one** actuator track (Variant A or B), then add the common parts and the parts for that variant.

## Common to both variants

| Qty | Part | Source | ~RON | ~EUR |
|---:|---|---|---:|---:|
| 1 | **ESP32-C6 DevKitC-1** (Wi-Fi 6, BT 5 LE, Thread/Zigbee) | [optimusdigital.ro ESP32 boards](https://www.optimusdigital.ro/358-placi-cu-esp32) · AliExpress / Amazon for the official Espressif kit | 50–80 | 10–16 |
| 1 | 12V DC power supply, 60W / 5A, plastic case | [webled.ro YDS 60W](https://webled.ro/sursa-alimentare-yds-12v-5a-60w-cu-fir-carcasa-plastic/) · [led-box.ro 60W](https://led-box.ro/products/sursa-alimentare-5a-60w-12v) | 60–100 | 12–20 |
| 1 | LM2596 buck module 12V → 5V (3A or 5A) | [optimusdigital.ro 5A](https://www.optimusdigital.ro/en/adjustable-step-down-power-supplies/1109-lm2596-dc-dc-step-down-module-5a.html) · [optimusdigital.ro w/ voltmeter](https://www.optimusdigital.ro/ro/surse-coboratoare-reglabile/805-modul-dc-dc-lm2596-cu-afisaj-de-tensiune.html) | 10–20 | 2–4 |
| 1 | Inline blade fuse holder + 5A fuse | [optimusdigital.ro fuse holders](https://www.optimusdigital.ro/ro/sigurante-fuzibile/) · auto parts shop | 10–15 | 2–3 |
| 1 | TVS diode 1.5KE18CA (linear-actuator variant only) | [optimusdigital.ro diode category](https://www.optimusdigital.ro/ro/77-diode) · AliExpress | 5–10 | 1–2 |
| 1 | M4 × 16 self-tapping screws (4–6 pcs) | hardware store / [emag.ro](https://www.emag.ro/) | 5–10 | 1–2 |
| 1 | 3M VHB tape (4950 or 5952), ~1 m × 19 mm | [emag.ro 3M VHB search](https://www.emag.ro/search/3M+VHB) · auto parts shop | 30–50 | 6–10 |
| 2 | M6 rod-end (heim joint), male, 50 mm shank | [emag.ro rod-end search](https://www.emag.ro/search/rod+end+m6) · AliExpress / Amazon.de — search "M6 rod end heim" | 25–50 | 5–10 |
| 1 | 3D-printed bracket set (2 pcs) | self-print from `mechanical/cad/*.scad` | filament cost | — |
| 1 | 3D-printed ESP32 enclosure | self-print (CAD pending Phase 1) | — | — |

## Variant A — 12V linear actuator (recommended for first build)

| Qty | Part | Source | ~RON | ~EUR |
|---:|---|---|---:|---:|
| 1 | **12V DC linear actuator, 200 mm stroke, 500 N, 20 mm/s** | [spy-shop.ro 200mm/500N](https://www.spy-shop.ro/actuator-liniar-pentru-cursa-de-200-mm-20-mm-s-12-vdc-500-n.html) · [emag.ro HS1471 series](https://www.emag.ro/search/actuator+liniar+12V+500N) | 250–400 | 50–80 |
| 1 | BTS7960 H-bridge module (43 A) | [optimusdigital.ro BTS7960](https://www.optimusdigital.ro/en/brushed-motor-drivers/174-bts7960-43-a-motor-driver.html) | 30–55 | 6–11 |
| 1 | (optional) 10-turn linear potentiometer for closed-loop position | [optimusdigital.ro potentiometers](https://www.optimusdigital.ro/ro/96-potentiometre-rezistente) · AliExpress | 25–40 | 5–8 |

Wiring: [`wiring/linear-actuator.md`](wiring/linear-actuator.md).

## Variant B — Stepper + lead screw

| Qty | Part | Source | ~RON | ~EUR |
|---:|---|---|---:|---:|
| 1 | NEMA17 stepper, ≥ 40 N·cm (e.g. 17HS19-2004S) | [optimusdigital.ro stepper category](https://www.optimusdigital.ro/ro/76-motoare-pas-cu-pas) · [emag.ro NEMA17](https://www.emag.ro/search/nema+17+stepper) | 50–100 | 10–20 |
| 1 | TMC2209 stepper driver | [optimusdigital.ro TMC2209](https://www.optimusdigital.ro/en/motor-drivers/13023-tmc2209-stepper-motor-driver.html) | 25–45 | 5–9 |
| 1 | T8 × 8 lead screw + brass nut, 300–500 mm | [piese3d.ro T8x8 400mm](https://piese3d.ro/surub-trapezoidal-400mm-t8x8-cu-piulita) · [reprapmania.ro lead screws](https://www.reprapmania.ro/catalog/suruburi-si-piulite-trapezoidale-398) | 40–80 | 8–16 |
| 1 | Flexible coupler 5 mm → 8 mm | [optimusdigital.ro couplings](https://www.optimusdigital.ro/ro/) · [reprapmania.ro](https://www.reprapmania.ro) | 10–20 | 2–4 |
| 2 | KP08 bearing blocks (or equivalent) | [reprapmania.ro](https://www.reprapmania.ro) · [piese3d.ro](https://piese3d.ro) · AliExpress | 15–30 | 3–6 |
| 1 | Normally-open micro-switch or reed + magnet | [optimusdigital.ro switches](https://www.optimusdigital.ro/ro/95-comutatoare-i-butoane) | 5–10 | 1–2 |
| 1 | 100 µF electrolytic cap (across TMC2209 motor supply) | [optimusdigital.ro caps](https://www.optimusdigital.ro/ro/68-condensatoare) | 1–3 | 0.20–0.60 |

Wiring: [`wiring/stepper.md`](wiring/stepper.md).

## Notes on sourcing

- **optimusdigital.ro** is the go-to Romanian hobbyist electronics shop — fastest delivery, most ESPHome-friendly parts in stock. Default first place to check for any electronic component.
- **spy-shop.ro / a2t.ro** carry ready-made 12V linear actuators in many stroke lengths (100, 200, 300, 500, 800 mm). The 200 mm / 500 N spec we want is mainstream — usually in stock.
- **piese3d.ro / reprapmania.ro** are 3D-printer parts shops; lead screws, couplers, and bearings live there. Lead times are usually 1–3 days within RO.
- **M6 rod-ends** are not commonly stocked at hobbyist electronics shops in RO. Easiest path: search `emag.ro` for "rod end m6" or order from AliExpress / Amazon.de (1–2 weeks delivery).
- **AC-DC 12V PSUs** are everywhere — LED supply shops (`webled.ro`, `led-box.ro`, `v-tac-led.ro`) usually beat electronics shops on price for the same MEAN-WELL-equivalent unit.
- **Currency:** ~5 RON ≈ 1 EUR in 2026. Optimus Digital lists in RON; AliExpress/Amazon in USD/EUR.

## Not included (yet)

- Rain sensor — v1 relies on HA weather integrations, not on-device sensing.
- Battery backup — v1 is mains-only.
- Device-side pushbuttons — v1 uses the window handle as manual override.
