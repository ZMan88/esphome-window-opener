# Wiring assembly — soldering order

This page tells you in what order to put the perfboard together so you don't paint yourself into a corner. Use the schematic at [`../schematic.svg`](../schematic.svg) as the source of truth for which pin connects where, and [`../perfboard-layout.svg`](../perfboard-layout.svg) for physical placement.

## Bill of materials

| Qty | Part | Notes |
|---:|---|---|
| 1 | Perfboard, 70 × 90 mm, 2.54 mm grid | Generic, available at any electronics shop. |
| 1 | ESP32-C6 DevKitC-1 | Goes on female pin headers, removable. |
| 1 | TMC2209 V1.3 (with heatsink) | Goes on female pin headers, removable. |
| 1 | LM2596 DC-DC buck module | Soldered direct or on female headers. |
| 1 | 470 µF / 35 V electrolytic cap | Mind polarity. |
| 1 | Inline 5 A blade fuse holder + fuse | Or panel-mount fuse holder. |
| 2 | 2-pin screw terminal (5.08 mm pitch) | 12 V input + endstop. |
| 1 | 4-pin screw terminal | Motor output. |
| ~30 cm | Solid 22 AWG wire (multiple colours) | For jumpers between modules. |
| 4 | M3 × 6 mm screws + nylon spacers | To mount the perfboard in an enclosure later. |

## Tools

- Soldering iron (350 °C for lead-free, 320 °C for leaded)
- Solder (0.6 – 0.8 mm)
- Solder wick or sucker (for mistakes)
- Multimeter (for continuity + Vref tuning)
- Wire stripper, side cutters
- Helping hands or a board holder

## Soldering order

The rule: **solder the lowest-profile parts first**, then progressively taller. Otherwise the board won't sit flat against your work surface for soldering taller parts.

### 1. Female pin headers for ESP32-C6 and TMC2209

These are the lowest profile after the bare board. Use **female** headers so the modules plug in/out — saves you from soldering a $7 module permanently and discovering it's a dud.

- ESP32-C6: two rows of 1×15 (or 1×20 — count the pins on your board).
- TMC2209: two rows of 1×8.

Solder one corner pin first, flip the board, check the header is flush and square against the board, then solder the rest. **Don't solder all pins at once on one side** — heat warps the plastic.

### 2. Power-side jumpers (red and black)

Lay down the +12 V and GND buses now while the board is still mostly flat. Use **solid 22 AWG** so you can route along the back side of the board cleanly.

- Red wire from the 12 V input terminal → through the fuse → to a node where the LM2596 IN+ and the TMC2209 VM both tap in.
- Black wire (GND) bus from the input terminal across the bottom edge of the board, with stubs going up to: LM2596 IN−, LM2596 OUT−, TMC2209 GND (×2), ESP32 GND (×2), 470 µF cap minus, endstop NO.

**Star ground**: every GND wire converges on one point. Don't daisy-chain — stub from the bus.

### 3. The 470 µF capacitor

Solder it directly across the TMC2209's VM and GND pins, leads as short as possible — under 2 cm.

> Polarity check before soldering: the **white stripe on the cap = negative lead**. Solder negative to GND, positive to +12 V (VM).

### 4. Logic-side jumpers (yellow / signal wires)

Connect from the ESP32-C6's GPIOs to the TMC2209's logic pins:

| ESP32-C6 | TMC2209 |
|---|---|
| GPIO4 | STEP |
| GPIO5 | DIR |
| GPIO6 | EN |
| 3V3 | VIO |
| GND | GND |

And the endstop:

| ESP32-C6 | Endstop |
|---|---|
| GPIO7 | COM |
| GND | NO |

These are low-current — any 22-26 AWG wire is fine.

### 5. The 5 V jumper from LM2596 to ESP32

Orange wire, one stub: LM2596 OUT+ → ESP32 5 V. (LM2596 OUT− is already on the GND bus.)

> **Set the LM2596 to 5 V before this connection.** With nothing on OUT, hook a multimeter between OUT+ and OUT−, power up the 12 V side, and turn the brass screw on the LM2596's pot until you read 5.00 V. Power down, then make the connection.

### 6. Screw terminals

Power input (2-pin), motor output (4-pin), endstop (2-pin) — soldered last because they're tall and stick up off the board.

## First power-up

Bench PSU at 12.0 V, current limit 1 A.

1. Plug ESP32-C6 into its female headers.
2. Plug TMC2209 into its female headers (no motor connected yet).
3. Power up. Multimeter on the LM2596 OUT+ → should read 5.0 V.
4. Touch the multimeter to the TMC2209's VREF test point and tweak its pot to **1.0 V**. (Skip if you already did this in `bench-test.md`.)
5. Power down. Connect the motor wires to the screw terminal — pair the wires by coil (multimeter continuity test if unsure).
6. Connect the endstop.
7. Power up again. Watch the bench PSU's current readout — should sit around 100-300 mA at idle.
8. Flash firmware (`esphome run firmware/window-opener.yaml`) over USB.
9. Run the four success-criteria tests from [`docs/bench-test.md`](../../docs/bench-test.md).

If anything weird happens, **kill power first** before debugging. The bench PSU's current limit is your safety net.

## Going to a fabricated PCB later

If you decide later you want a proper PCB instead of perfboard:

1. The schematic in `hardware/schematic.svg` is the source of truth — it translates directly to KiCad.
2. JLCPCB will fab 5× of a 100 × 80 mm 2-layer PCB for ~$5 + ~$10 shipping. Total: $15 for a stack of cleaner-looking boards.
3. KiCad project skeleton is **not yet committed** to the repo — open question, see `PLAN.md`.

The perfboard build above is plenty for v1; PCB fab is a polish step.
