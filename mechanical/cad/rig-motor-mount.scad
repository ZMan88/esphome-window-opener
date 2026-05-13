// Lead-screw rig — motor mount + KP08 #1 holder + frame-side rod-end mount.
//
// L-shaped bracket. The vertical back plate carries the NEMA17 motor
// (4× M3 in a 31 × 31 pattern, 22 mm bore for the shaft flange). The
// horizontal floor extends forward; KP08 #1 bolts to the floor at a
// height that aligns its bore with the motor shaft. A short rear tab
// has a tapped M6 hole for the right-hand rod-end (CS10) that links
// the rig to the frame bracket on the window.
//
// Coordinate convention:
//   X axis: along the lead screw, +X = forward (toward the carriage / sash)
//   Y axis: vertical, +Y = up (Y=0 is the lead-screw axis)
//   Z axis: across the rig, +Z = away from the parallel anti-rotation rod
//
// Motor body extends in -X (behind the back plate). KP08 #1 sits at +X.
// Rod-end tab extends further into -X.
//
// Print orientation: back plate flat on the bed (the X- direction
// becomes the print +Z). Floor and rod-end tab will need a few support
// columns under their overhangs — slicer auto-supports work.
//
// Render:   openscad -o ../stl/rig-motor-mount.stl rig-motor-mount.scad

include <common.scad>;

// ---- design parameters (tune as needed) ----
PLATE_THK       = 6;         // back-plate thickness (X direction)
FLOOR_THK       = 6;         // KP08 mounting floor thickness (Y direction)
ROD_END_TAB_LEN = 25;        // how far behind the back plate the rod-end tab sticks
ROD_END_TAP_D   = 18;        // M6 tap depth for the rod-end shank
ANTI_ROT_OFFSET = 30;        // anti-rotation rod offset below the lead-screw axis
ANTI_ROT_HOLE_D = 8.4;       // 8 mm rod with print clearance
GUSSET_T        = 4;         // gusset rib thickness for L-corner stiffness

// ---- derived geometry ----
SHAFT_Y         = 0;                            // lead-screw axis at Y=0
KP08_BASE_Y     = SHAFT_Y - KP08_BORE_HEIGHT;   // KP08 base sits H below shaft axis
FLOOR_TOP_Y     = KP08_BASE_Y;                  // top of floor = KP08 base bottom
FLOOR_BOTTOM_Y  = FLOOR_TOP_Y - FLOOR_THK;
NEMA_FACE_HALF  = NEMA17_FACE / 2;
BACK_PLATE_TOP_Y    = SHAFT_Y + NEMA_FACE_HALF + 4;
BACK_PLATE_BOT_Y    = FLOOR_BOTTOM_Y;            // join cleanly with floor
BACK_PLATE_W        = NEMA17_FACE + 16;          // Z width with margin

// KP08 position along X (the bore axis):
//   KP08_START_X = where the KP08 base STARTS in X (motor side)
//   The base is KP08_BASE_W (= A = 13 mm) wide along X.
//   Floor extends from X=0 (back plate) to past the KP08, with a margin.
KP08_START_X        = NEMA17_SHAFT_L + 2;        // clearance for the motor shaft + a hair
KP08_CENTER_X       = KP08_START_X + KP08_BASE_W / 2;
FLOOR_LEN_X         = KP08_START_X + KP08_BASE_W + 12;  // small margin past the KP08

// ---- the part ----
module motor_mount() {
  difference() {
    union() {
      // Back plate (motor mounts on the X- face)
      translate([-PLATE_THK, BACK_PLATE_BOT_Y, -BACK_PLATE_W / 2])
        cube([PLATE_THK, BACK_PLATE_TOP_Y - BACK_PLATE_BOT_Y, BACK_PLATE_W]);

      // Floor (KP08 sits on the Y+ face at FLOOR_TOP_Y)
      translate([0, FLOOR_BOTTOM_Y, -BACK_PLATE_W / 2])
        cube([FLOOR_LEN_X, FLOOR_THK, BACK_PLATE_W]);

      // Rod-end tab extending in -X behind the back plate
      translate([-PLATE_THK - ROD_END_TAB_LEN, SHAFT_Y - 9, -9])
        cube([ROD_END_TAB_LEN, 18, 18]);

      // Gussets at the L-corner (left and right)
      for (z = [-BACK_PLATE_W / 2, BACK_PLATE_W / 2 - GUSSET_T])
        translate([0, FLOOR_TOP_Y, z])
          linear_extrude(GUSSET_T)
            polygon([[0, 0], [25, 0], [0, 25]]);
    }

    // ---- removals ----

    // Motor shaft clearance bore through back plate
    translate([-PLATE_THK - 1, SHAFT_Y, 0])
      rotate([0, 90, 0])
        cylinder(d = NEMA17_BORE_D, h = PLATE_THK + 2);

    // 4× M3 motor mount holes (31 × 31 pattern around the shaft)
    for (dy = [-NEMA17_HOLE_SPACING / 2, NEMA17_HOLE_SPACING / 2])
      for (dz = [-NEMA17_HOLE_SPACING / 2, NEMA17_HOLE_SPACING / 2])
        translate([-PLATE_THK - 1, SHAFT_Y + dy, dz])
          rotate([0, 90, 0])
            cylinder(d = NEMA17_HOLE_D, h = PLATE_THK + 2);

    // KP08 mounting holes through the floor.
    // The bolt-hole axis is PERPENDICULAR to the bore (Z in this local
    // frame), spaced J = KP08_HOLE_SPACING centre-to-centre. Both holes
    // share the same X (the KP08's centre along the bore axis).
    // The cylinder must be rotated so its axis runs VERTICALLY (along
    // local Y), matching the floor's thickness — otherwise the hole
    // pokes the side of the floor instead of through it (the "scoop"
    // bug seen in earlier renders).
    for (z = [-KP08_HOLE_SPACING / 2, KP08_HOLE_SPACING / 2])
      translate([KP08_CENTER_X, FLOOR_BOTTOM_Y - 1, z])
        rotate([-90, 0, 0])
          cylinder(d = KP08_HOLE_D, h = FLOOR_THK + 2);

    // Access slots in the floor for the bottom 2 motor mount bolts.
    // The motor's M3 holes sit at Y = ±NEMA17_HOLE_SPACING/2 = ±15.5.
    // The floor (top at Y = FLOOR_TOP_Y = -14) covers the lower two
    // (at Y = -15.5) — you can't fit a bolt head + driver in there.
    // These slots are cut through the floor at each lower-bolt Z so
    // a screwdriver can come in from outside the back plate.
    ACCESS_SLOT_X_LEN = 12;       // how far in front of the back plate
    ACCESS_SLOT_W     = 8;        // along Z; clears the M3 bolt head + tool
    for (dz = [-NEMA17_HOLE_SPACING / 2, NEMA17_HOLE_SPACING / 2])
      translate([0, FLOOR_BOTTOM_Y - 1, dz - ACCESS_SLOT_W / 2])
        cube([ACCESS_SLOT_X_LEN, FLOOR_THK + 2, ACCESS_SLOT_W]);

    // Anti-rotation rod hole — passes through the back plate, extends some way into the rig
    translate([-PLATE_THK - 1, SHAFT_Y - ANTI_ROT_OFFSET, 0])
      rotate([0, 90, 0])
        cylinder(d = ANTI_ROT_HOLE_D, h = PLATE_THK + 5);

    // M6 tap for the rod-end shank (in the rod-end tab, opening toward -X)
    translate([-PLATE_THK - ROD_END_TAB_LEN - 1, SHAFT_Y, 0])
      rotate([0, 90, 0])
        cylinder(d = M6_TAP, h = ROD_END_TAP_D + 1);
  }
}

motor_mount();
