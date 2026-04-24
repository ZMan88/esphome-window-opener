# Assembly

Photo-led build guide. Not written yet — gets filled in during Phase 2 of `PLAN.md`, after the brackets are printed and the first physical install is done.

Sections planned:

1. **Bench-test first.** Wire the ESP32 + driver + actuator on the bench per `hardware/wiring/<variant>.md`. Flash firmware. Verify open/close from HA before touching the window.
2. **Measure the window.** Width, height, sash weight; confirm the chosen actuator stroke covers turn mode (usually the longer arc).
3. **Dry-fit.** Place the printed brackets on the frame/sash with painter's tape. Cycle the window manually in tilt and turn modes to confirm no interference.
4. **Attach brackets.** VHB tape first, screws later (PVC window frames don't forgive mistakes).
5. **Install actuator.** Rod ends at both ends. Confirm no binding at any point in the stroke, in both modes.
6. **Route cables.** 12V + ESP32 USB-power (if keeping USB for serial) along the hinge side where flex is minimal.
7. **Calibrate.** Follow `calibration.md`.
8. **Mount enclosure.** ESP32 + driver + buck go in the enclosure on the frame near the actuator.
