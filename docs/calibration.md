# Calibration

Once the device is mounted and wired, calibrate the stroke → position mapping. This is what makes the HA `cover` percentage match reality.

## Linear-actuator variant

The `full_stroke_seconds` substitution in `firmware/variants/linear-actuator.yaml` must match the measured time the actuator takes to travel from fully closed (retracted) to fully open (extended) at full PWM, **under load** — i.e. with the window actually attached. Unloaded bench timings are usually 10–20% faster.

Procedure:

1. Close the window fully (handle to the locked position, then unlock to tilt or turn).
2. Command `open` from HA and start a stopwatch.
3. Stop timing when the actuator reaches its mechanical limit (you'll hear the motor stall or see the carriage stop).
4. Repeat 3× and average.
5. Update `full_stroke_seconds` in `firmware/variants/linear-actuator.yaml` and reflash.

Repeat the same procedure in the close direction. If the two numbers differ by more than ~10%, split `open_duration` and `close_duration` in the YAML and give each its own value.

**Drift management.** Time-based tracking drifts after repeated partial moves. A daily automation that closes fully, then opens to the desired position, resets the estimate. Or wire the optional 10-turn pot for closed-loop position.

## Stepper variant

The `steps_full_stroke` substitution in `firmware/variants/stepper.yaml` must match the number of steps from endstop-trigger (closed) to the mechanical open limit.

Procedure:

1. Power on with the carriage somewhere mid-travel. The device reports `unknown` until homed.
2. Command `close` from HA — the carriage drives toward the endstop and zeros.
3. Command `open` and watch the log for the step count when the actuator hits its mechanical open limit (current-based stall or visual confirmation).
4. Update `steps_full_stroke` to a value ~5% below that peak (safety margin so you don't slam the limit on every full-open).
5. Reflash.

**Sanity rule:** if `steps_full_stroke` changes by more than ±10% between runs on the same hardware, something is slipping — check the coupler set screws and the lead-screw support bearings.

## Common to both variants

- Calibrate in the window mode you use most often (tilt). Turn mode uses a longer arc of the stroke, so the same stroke time/steps naturally maps to a smaller % in turn — this is fine; HA still sees 0–100.
- Re-calibrate after any mechanical change (bracket replacement, rod-end swap, actuator swap).
- If 0% doesn't fully close the window physically, the actuator is undersized or the geometry is off — don't paper over it in firmware.
