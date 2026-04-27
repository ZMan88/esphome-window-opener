// Sash-end (moving) bracket.
//
// A flat plate that bolts to the room-side face of the sash top rail with
// VHB tape + 4 M4 self-tappers into the PVC. The M6 rod-end's shank passes
// through the central CLEARANCE hole and is locked with an M6 nut. The
// hex pocket on the back face lets the nut sit flush so it does not poke
// into the sash. (You'll still need to drill a small Ø6.5 mm pilot in the
// sash for the protruding tail of the rod-end shank — see install notes.)
//
// Print orientation: BACK FACE UP (so the hex pocket prints clean,
// without supports inside the cavity). The M4 holes will print over the
// pocket-side; that's fine, they're large enough.
// Recommended filament: PETG or ABS (sun-heat resistance).
//
// Render:   openscad -o sash-bracket.stl sash-bracket.scad

include <common.scad>;

// -------- dimensions --------
PLATE_H          = 45;    // plate height (vertical on the sash face)

NUT_AF           = 10.0;  // M6 nut across-flats
NUT_THK          = 5.5;   // M6 nut nominal thickness + a hair of clearance
POCKET_DEPTH     = 4.0;   // hex pocket depth on the back face (deeper = more nut hidden)

SCREW_INSET_X    = 20;    // distance from short edge to M4 centre
SCREW_INSET_Y    = 10;    // distance from long edge to M4 centre
ROD_END_OFFSET_Y = PLATE_H / 2;   // M6 centred vertically

// -------- the part --------
module hex_prism(across_flats, h) {
  // OpenSCAD cylinder($fn=6) is point-to-point, so use the inscribed-circle
  // diameter (= AF / cos(30°)) to make the hex measure across-flats correctly.
  cylinder(h = h, d = across_flats / cos(30), $fn = 6);
}

module sash_bracket() {
  difference() {
    // Main plate: lies in the XY plane, thickness in Z.
    cube([BRACKET_WIDTH, PLATE_H, PLATE_THK]);

    // --- M4 mounting holes (4 corners) ---
    for (x = [SCREW_INSET_X, BRACKET_WIDTH - SCREW_INSET_X])
      for (y = [SCREW_INSET_Y, PLATE_H - SCREW_INSET_Y])
        translate([x, y, -0.1])
          cylinder(h = PLATE_THK + 0.2, d = M4_HOLE);

    // --- M6 clearance through-hole for the rod-end shank ---
    translate([BRACKET_WIDTH / 2, ROD_END_OFFSET_Y, -0.1])
      cylinder(h = PLATE_THK + 0.2, d = M6_CLEAR);

    // --- Hex pocket on the BACK face (z = 0) for the M6 nut ---
    translate([BRACKET_WIDTH / 2, ROD_END_OFFSET_Y, -0.05])
      hex_prism(NUT_AF + 0.3, POCKET_DEPTH);

    // --- Small chamfer on the M4 holes, front face only ---
    for (x = [SCREW_INSET_X, BRACKET_WIDTH - SCREW_INSET_X])
      for (y = [SCREW_INSET_Y, PLATE_H - SCREW_INSET_Y])
        translate([x, y, PLATE_THK - 0.5])
          cylinder(h = 0.6, d1 = M4_HOLE, d2 = M4_HOLE + 1.2);
  }
}

sash_bracket();
