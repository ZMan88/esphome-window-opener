# Mechanical design

The mechanical design is the load-bearing part of this project — the firmware only works if the geometry works. Read this before opening CAD.

## Mounting geometry

A European tilt-and-turn window has two pivot axes that share **one corner**: the **bottom-hinge-side corner** of the sash/frame. That corner stays fixed in both tilt mode (horizontal axis pivot along the bottom edge) and turn mode (vertical axis pivot along the hinge side).

The device is designed around that insight:

- **Fixed end** of the actuator is anchored at the bottom-hinge-side corner of the frame (`cad/frame-bracket.FCStd`).
- **Moving end** attaches to the opposite corner of the sash — diagonally opposite the fixed end (`cad/sash-bracket.FCStd`).
- Extending the actuator pushes the opposite sash corner away from the frame; in tilt mode it opens the top, in turn mode it swings the sash inward. The firmware does not know or care which mode the handle is in.

```
  Frame (top-left corner)            Sash moving end
   ┌─────────────────────────────────┐ ← sash bracket attaches here
   │                               ╱ │
   │                         ╱       │
   │                   ╱             │
   │             ╱                   │
   │       ╱       ← actuator        │
   │ ╱                               │
   └─────────────────────────────────┘
   ↑
   Fixed end: bottom-hinge corner of the frame
   (same corner is the shared pivot for tilt + turn)
```

## Ball-joint rod ends are required

In tilt mode the moving end traces a short arc around the bottom edge. In turn mode the same point traces a wide arc around the hinge side. These arcs are in different planes, so the actuator must be free to swing in **two axes** at each end.

Use **M6 or M8 rod-end (heim) joints** at both ends of the actuator. Fixed pivots or single-axis hinges will bind in one of the two modes — most likely it'll work in tilt during bench testing and snap a bracket the first time you hit turn.

## Bracket design notes

- Print in PETG or ABS, not PLA — summer sun on the frame easily exceeds PLA's glass transition.
- Brackets are held to the window frame with **double-sided VHB tape** as a reversible baseline; add self-tapping screws only after you're happy with placement (drilling into a PVC window is a one-way door).
- Leave clearance around the sash bracket for the handle's own travel — especially if the handle is on the opposite side.

## CAD files

- `cad/frame-bracket.FCStd` — fixed-end bracket, attaches to the frame at the bottom-hinge corner.
- `cad/sash-bracket.FCStd` — moving-end bracket, attaches to the opposite sash corner.
- `cad/esp32-enclosure.FCStd` — ESP32 + driver + buck enclosure, mounts on the frame near the actuator.
- `stl/` — exported printable STLs. Re-export after any `.FCStd` change.

None of these are designed yet — they land in Phase 2 of `PLAN.md`.
