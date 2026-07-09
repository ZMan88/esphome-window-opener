# Vendored ESPHome components

These components are vendored (copied) from
[slimcdk/esphome-custom-components](https://github.com/slimcdk/esphome-custom-components)
at commit **`b5f0e44ae8732f68b9bbeaed9e962ca052d04cdb`** (which was `origin/master`
HEAD at the time). They were previously pulled at build time via
`external_components: github://…`; `firmware/variants/stepper-uart.yaml` now
points at this local copy so we can carry a **local patch**.

## Why vendored — the local patch

The upstream stepper stored `micros()` timestamps in `time_t` (signed/wider) and
computed timing deltas from them, instead of the wrap-safe `uint32_t` core ESPHome
uses. `micros()` overflows every ~71.6 min; after a wrap the delta went negative,
the STEP-pulse gate never fired, and the motor froze for up to ~71 min before
self-healing ("driver not responding, then works again after a while").

The patch changes the timestamp types to `uint32_t` so the subtraction wraps
correctly (mirroring core `esphome/components/stepper`):

- `stepper/stepper.h` — `last_calculation_` / `last_step_` and the
  `calculate_speed_` / `should_step_` `now` args → `uint32_t`
- `stepper/stepper.cpp` — matching signature update (the delta math is then
  naturally wrap-safe)
- `tmc2209/stepper/tmc2209_stepper.cpp` — `loop()` step gate `now` / `dt` →
  `uint32_t`

## Upstreamed

This exact fix has been submitted upstream:
**slimcdk/esphome-custom-components#50**
(branch `ZMan88:fix/stepper-micros-wrap`). When it merges, drop this vendored
copy and go back to `external_components: github://…` pinned at (or past) the
merge commit — the local tree here is identical to that PR, so there's nothing
else to reconcile.

Full diagnosis: `docs/build-log.md` → "micros() wrap bug".

## Updating from upstream

Re-copy the component trees from a newer upstream commit, then re-apply the
`uint32_t` type change (unless upstream has merged #50 by then). Drop the
`tmc2209/docs/` folder (large datasheet PDF + images) as we do here.
