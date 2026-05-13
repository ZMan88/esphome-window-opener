// Lead-screw rig — motor mount + KP08 #1 holder.
//
// L-shaped bracket. The vertical back plate carries the NEMA17 motor
// (4× M3 in a 31 × 31 pattern, 22 mm bore for the shaft flange). A
// continuous horizontal floor runs UNDER the motor body (in -X) AND
// forward to KP08 #1 (in +X). The motor sits flat on the floor — the
// floor top is at Y = -NEMA17_FACE/2, so the motor's bottom corners
// rest on it. This keeps the lower two M3 bolts clear of the floor
// (they sit at Y = -15.5, above the floor top at Y = -21.15).
//
// Because the KP08 bore must align with the motor shaft (lead-screw
// axis at Y = 0), and the floor sits below the motor centreline, the
// KP08 cannot sit directly on the floor. A short pedestal (~7 mm)
// lifts the KP08 base back up to Y = -KP08_BORE_HEIGHT.
//
// Coordinate convention:
//   X axis: along the lead screw, +X = forward (toward the carriage / sash)
//   Y axis: vertical, +Y = up (Y=0 is the lead-screw axis)
//   Z axis: across the rig, +Z = away from the parallel anti-rotation rod
//
// Motor body extends in -X (behind the back plate). KP08 #1 sits at +X.
// The back plate also extends downward past the floor so the anti-
// rotation rod can pass through it (the rod is 30 mm below the shaft).
//
// FIXME: The frame-side rod-end (CS10) attachment is not modelled in
// this version. The original tab extended in -X at Y = 0, which sits
// INSIDE the motor body's 3D volume now that the motor is supported
// by the floor. Re-locate the rod-end mount before printing this part.
//
// Print orientation: back plate flat on the bed (the X- direction
// becomes the print +Z). Floor and pedestal will need a few support
// columns under their overhangs — slicer auto-supports work.
//
// Render:   openscad -o ../stl/rig-motor-mount.stl rig-motor-mount.scad

include <common.scad>;

// ---- design parameters (tune as needed) ----
PLATE_THK         = 6;         // back-plate thickness (X direction)
FLOOR_THK         = 6;         // floor thickness (Y direction)
ANTI_ROT_OFFSET   = 30;        // anti-rotation rod offset below the lead-screw axis
ANTI_ROT_HOLE_D   = 8.4;       // 8 mm rod with print clearance
GUSSET_T          = 4;         // gusset rib thickness for L-corner stiffness
MOTOR_FLOOR_EXT   = NEMA17_BODY_L + 2;  // how far floor extends in -X past back plate

// ---- derived geometry ----
SHAFT_Y           = 0;                                  // lead-screw axis at Y=0
FLOOR_TOP_Y       = SHAFT_Y - NEMA17_FACE / 2;          // -21.15: motor body sits on floor
FLOOR_BOTTOM_Y    = FLOOR_TOP_Y - FLOOR_THK;            // -27.15
PEDESTAL_HEIGHT   = -KP08_BORE_HEIGHT - FLOOR_TOP_Y;    //  7.15: lifts KP08 base up to bore alignment
KP08_BASE_Y       = -KP08_BORE_HEIGHT;                  // -14: pedestal top = KP08 base bottom
NEMA_FACE_HALF    = NEMA17_FACE / 2;

BACK_PLATE_TOP_Y    = SHAFT_Y + NEMA_FACE_HALF + 4;     //  25.15
BACK_PLATE_BOT_Y    = SHAFT_Y - ANTI_ROT_OFFSET - 5;    // -35: extends below floor for anti-rot rod
BACK_PLATE_W        = NEMA17_FACE + 16;                 //  58.3: Z width with margin

// KP08 position along X (the bore axis):
//   KP08_START_X = where the KP08 base STARTS in X (motor side)
//   The base is KP08_BASE_W (= A = 13 mm) wide along X.
KP08_START_X      = NEMA17_SHAFT_L + 2;                 // clearance for the motor shaft + a hair
KP08_CENTER_X     = KP08_START_X + KP08_BASE_W / 2;
FLOOR_LEN_X       = KP08_START_X + KP08_BASE_W + 12;    // small margin past the KP08
PEDESTAL_X_W      = KP08_BASE_W + 4;
PEDESTAL_Z_W      = KP08_BASE_L;                        // matches KP08 base depth perpendicular to bore

// ---- the part ----
module motor_mount() {
  difference() {
    union() {
      // Back plate. Top sits above the motor face; bottom extends below
      // the floor to enclose the anti-rotation rod hole.
      translate([-PLATE_THK, BACK_PLATE_BOT_Y, -BACK_PLATE_W / 2])
        cube([PLATE_THK, BACK_PLATE_TOP_Y - BACK_PLATE_BOT_Y, BACK_PLATE_W]);

      // Continuous floor: extends from behind the back plate (under the
      // motor body) all the way forward past the KP08. The motor body's
      // bottom face rests on the -X portion.
      translate([-MOTOR_FLOOR_EXT - PLATE_THK, FLOOR_BOTTOM_Y, -BACK_PLATE_W / 2])
        cube([MOTOR_FLOOR_EXT + PLATE_THK + FLOOR_LEN_X, FLOOR_THK, BACK_PLATE_W]);

      // KP08 pedestal — raises the KP08 base up to the lead-screw axis
      // alignment height. Without this the bore would sit FLOOR_THK +
      // pedestal-height too low.
      translate([KP08_CENTER_X - PEDESTAL_X_W / 2, FLOOR_TOP_Y, -PEDESTAL_Z_W / 2])
        cube([PEDESTAL_X_W, PEDESTAL_HEIGHT, PEDESTAL_Z_W]);

      // Gussets at the L-corners, both +X (KP08 side) and -X (motor side).
      for (z = [-BACK_PLATE_W / 2, BACK_PLATE_W / 2 - GUSSET_T]) {
        // +X side gusset
        translate([0, FLOOR_TOP_Y, z])
          linear_extrude(GUSSET_T)
            polygon([[0, 0], [25, 0], [0, 25]]);
        // -X side gusset (mirror — supports back plate ↔ motor-floor join)
        translate([-PLATE_THK, FLOOR_TOP_Y, z])
          linear_extrude(GUSSET_T)
            polygon([[0, 0], [-25, 0], [0, 25]]);
      }
    }

    // ---- removals ----

    // Motor shaft clearance bore through back plate
    translate([-PLATE_THK - 1, SHAFT_Y, 0])
      rotate([0, 90, 0])
        cylinder(d = NEMA17_BORE_D, h = PLATE_THK + 2);

    // 4× M3 motor mount holes (31 × 31 pattern around the shaft).
    // With FLOOR_TOP_Y = -21.15, all four holes (at Y = ±15.5) sit
    // ABOVE the floor — no access slots are needed.
    for (dy = [-NEMA17_HOLE_SPACING / 2, NEMA17_HOLE_SPACING / 2])
      for (dz = [-NEMA17_HOLE_SPACING / 2, NEMA17_HOLE_SPACING / 2])
        translate([-PLATE_THK - 1, SHAFT_Y + dy, dz])
          rotate([0, 90, 0])
            cylinder(d = NEMA17_HOLE_D, h = PLATE_THK + 2);

    // KP08 mounting holes — through floor + pedestal. The cylinder must
    // be rotated so its axis runs VERTICALLY (along local Y) — otherwise
    // OpenSCAD's default Z-axis cylinder leaves a "scoop" instead of a
    // through-hole.
    for (z = [-KP08_HOLE_SPACING / 2, KP08_HOLE_SPACING / 2])
      translate([KP08_CENTER_X, FLOOR_BOTTOM_Y - 1, z])
        rotate([-90, 0, 0])
          cylinder(d = KP08_HOLE_D, h = FLOOR_THK + PEDESTAL_HEIGHT + 2);

    // Anti-rotation rod hole — through the back plate's downward
    // extension at Y = -ANTI_ROT_OFFSET (below the floor).
    translate([-PLATE_THK - 1, SHAFT_Y - ANTI_ROT_OFFSET, 0])
      rotate([0, 90, 0])
        cylinder(d = ANTI_ROT_HOLE_D, h = PLATE_THK + 5);
  }
}

motor_mount();
