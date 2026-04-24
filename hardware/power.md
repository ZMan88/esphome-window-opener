# Power design

Single 12V mains PSU powers both the actuator and the ESP32. The ESP32 runs from 5V via a buck converter on the same 12V rail.

## Sizing the PSU

- **Linear actuator variant.** Size to roughly 1.5× the actuator's stall current. A typical 150 N / 50 mm-s actuator stalls at ~3 A, so a 5 A / 12 V / 60 W PSU is a safe baseline. Verify against the specific actuator's datasheet before ordering.
- **Stepper variant.** NEMA17 at 1.5 A/coil with both coils energised ≈ 3 A peak, but TMC2209 chopper drops typical draw well below that. A 3 A / 12 V / 36 W PSU is usually fine; go to 5 A if you're running near the stepper's rated current.

Headroom matters more than efficiency — the 12V rail also feeds the ESP32 buck.

## Protection

- **5 A inline blade fuse** on the 12V+ lead out of the PSU, close to the PSU (not close to the driver). Motor fault or stuck carriage should pop the fuse, not melt wires.
- **TVS diode (1.5KE18CA or similar)** across the actuator motor leads to snub inductive flyback. Linear actuator variant only — TMC2209 handles its own flyback.
- **100 µF electrolytic cap** across `VM`/`GND` at the TMC2209. Stepper variant only — *required*, not optional.
- The ESP32 buck converter is fed from the same 12V rail, after the fuse. If the fuse blows, the ESP32 loses power too — this is intentional so HA flags the outage.

## Grounding

All grounds (PSU −, driver GND, ESP32 GND, endstop GND) tie together at a single star point at the PSU. Do **not** daisy-chain grounds through the driver — motor return currents on a shared wire will introduce noise on the ESP32 GND.

## What's not here (yet)

- **No battery backup.** If mains drops, the window holds its last physical position. Intentional for v1.
- **No mains switch on the device.** Unplug the PSU if you need to service.
- **No opto-isolation** between ESP32 and driver. Both drivers referenced here are happy with direct 3.3V logic, but if you switch to a high-side driver or a 24V setup, add an isolator.
