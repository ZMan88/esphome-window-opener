// Sash-end (moving) bracket.
//
// Mounts on the room-side face of the sash top rail with VHB tape + 4 M4
// self-tappers into the PVC. Holds an M6 rod-end through a central boss
// that gives ~15 mm of thread engagement (5 mm plate + 10 mm boss).
//
// Print orientation: flat on the bed, back face (the VHB side) down.
// Recommended filament: PETG or ABS (sun-heat resistance). No supports.
//
// Render:   openscad -o sash-bracket.stl sash-bracket.scad

include <common.scad>;

// -------- dimensions --------
PLATE_H          = 45;    // plate height (vertical on the sash face)

BOSS_D           = 20;    // boss diameter around the rod-end thread
BOSS_H           = 10;    // boss protrusion past the plate front face

SCREW_INSET_X    = 20;    // distance from short edge to M4 centre
SCREW_INSET_Y    = 10;    // distance from long edge to M4 centre
ROD_END_OFFSET_Y = PLATE_H / 2;   // M6 centred vertically

// -------- the part --------
module sash_bracket() {
  difference() {
    union() {
      // Main plate: lies in the XY plane, thickness in Z.
      cube([BRACKET_WIDTH, PLATE_H, PLATE_THK]);

      // Central boss for the M6 rod-end thread.
      translate([BRACKET_WIDTH / 2, ROD_END_OFFSET_Y, PLATE_THK])
        cylinder(h = BOSS_H, d = BOSS_D);

      // Small fillet-ish base under the boss for strength.
      translate([BRACKET_WIDTH / 2, ROD_END_OFFSET_Y, PLATE_THK])
        cylinder(h = 1.5, d1 = BOSS_D + 3, d2 = BOSS_D);
    }

    // --- M4 mounting holes (4 corners) ---
    for (x = [SCREW_INSET_X, BRACKET_WIDTH - SCREW_INSET_X])
      for (y = [SCREW_INSET_Y, PLATE_H - SCREW_INSET_Y])
        translate([x, y, -0.1])
          cylinder(h = PLATE_THK + 0.2, d = M4_HOLE);

    // --- M6 rod-end hole (tap drill — tap M6 after printing) ---
    translate([BRACKET_WIDTH / 2, ROD_END_OFFSET_Y, -0.1])
      cylinder(h = PLATE_THK + BOSS_H + 0.2, d = M6_TAP);

    // --- Small chamfer on the screw holes, front face only ---
    for (x = [SCREW_INSET_X, BRACKET_WIDTH - SCREW_INSET_X])
      for (y = [SCREW_INSET_Y, PLATE_H - SCREW_INSET_Y])
        translate([x, y, PLATE_THK - 0.5])
          cylinder(h = 0.6, d1 = M4_HOLE, d2 = M4_HOLE + 1.2);
  }
}

sash_bracket();
