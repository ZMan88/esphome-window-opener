# Vendored ESPHome components

These components are vendored (copied) from
[slimcdk/esphome-custom-components](https://github.com/slimcdk/esphome-custom-components)
at commit **`b5f0e44ae8732f68b9bbeaed9e962ca052d04cdb`** (which was `origin/master`
HEAD at the time). They were previously pulled at build time via
`external_components: github://…`; `firmware/variants/stepper-uart.yaml` now
points at this local copy so we can carry a **local patch**.

## Why vendored — the local patch

The upstream stepper computed `micros()` timing deltas in `time_t` (signed/wider)
instead of the wrap-safe `uint32_t` core ESPHome uses. `micros()` overflows every
~71.6 min; after a wrap the delta went negative, the STEP-pulse gate never fired,
and the motor froze for up to ~71 min before self-healing ("driver not responding,
then works again after a while"). The bug is **unfixed on upstream master**, so
bumping the ref would not help — hence a local vendored patch.

Patched (search for `WRAP-SAFE (local patch)`):

- `stepper/stepper.cpp` — `calculate_speed_()` ramp delta → `uint32_t`
- `tmc2209/stepper/tmc2209_stepper.cpp` — `loop()` step gate → `uint32_t`, plus a
  `vactual_ > 0` guard against a div-by-zero when speed is 0.

Full diagnosis: `docs/build-log.md` → "micros() wrap bug".

## Updating from upstream

Re-copy the component trees from a newer upstream commit, then re-apply the two
`WRAP-SAFE (local patch)` edits (unless upstream has fixed them by then). Drop the
`tmc2209/docs/` folder (large datasheet PDF + images) as we do here.
