// Lead-screw rig — motor mount + KP08 #1 holder + frame-side rod-end.
//
// L-shaped bracket with a tab off the back. From -X to +X:
//   • Rod-end tab    — 18×18 horizontal stub with M6 tap, at SHAFT_Y.
//                      Carries the right-hand rod-end (CS10) that links
//                      the rig to the frame bracket on the window.
//   • Rear wall      — 6 mm column from the floor up to SHAFT_Y + 9,
//                      anchors the rod-end tab to the floor.
//   • Floor (under motor)
//                    — NEMA17_BODY_L + 2 mm of floor at Y = FLOOR_TOP_Y
//                      so the full motor body rests on the floor, not
//                      cantilevered. Motor's lower face touches floor.
//   • Back plate     — 6 mm vertical, carries the 4× M3 (31×31) holes
//                      and a 22 mm pilot bore for the motor flange.
//                      Extends down past the floor to enclose the
//                      anti-rotation rod hole at SHAFT_Y - 30.
//   • Coupler gap    — empty +X space for the Tr8 coupler.
//   • KP08 pedestal  — 7.15 mm pedestal lifting KP08 #1 up so its bore
//                      sits on the lead-screw axis.
//
// FLOOR_TOP_Y = -NEMA17_FACE/2 — the motor's bottom corners and the
// floor's top surface meet flush, and all 4 motor M3 holes sit above
// the floor (no access slots needed).
//
// Coordinate convention:
//   X axis: along the lead screw, +X = forward (toward the carriage / sash)
//   Y axis: vertical, +Y = up (Y=0 is the lead-screw axis)
//   Z axis: across the rig, +Z = away from the parallel anti-rotation rod
//
// Print orientation: back plate flat on the bed (the X- direction
// becomes the print +Z). Floor and pedestal will need a few support
// columns under their overhangs — slicer auto-supports work.
//
// Render:   openscad -o ../stl/rig-motor-mount.stl rig-motor-mount.scad

include <common.scad>;

// ---- design parameters (tune as needed) ----
PLATE_THK          = 6;         // back-plate thickness (X direction)
FLOOR_THK          = 6;         // floor thickness (Y direction)
ANTI_ROT_OFFSET    = 30;        // anti-rotation rod offset below the lead-screw axis
ANTI_ROT_HOLE_D    = 8.4;       // 8 mm rod with print clearance
GUSSET_T           = 4;         // gusset rib thickness for L-corner stiffness
GUSSET_LEG         = 25;        // gusset leg length (square triangle)
COUPLER_MOTOR_GRIP = 12;        // mm of motor shaft buried inside the coupler
MOTOR_BACK_CLEAR   = 2;         // clearance between motor body and rear wall
REAR_WALL_THK      = 6;         // rear wall thickness along X
ROD_END_TAB_LEN    = 20;        // length of rod-end tab in -X (≥ ROD_END_TAP_D + 2 mm margin)
ROD_END_TAB_S      = 18;        // tab cross-section (square, Y and Z)
ROD_END_TAP_D      = 18;        // M6 tap depth for the rod-end shank

// ---- derived geometry ----
SHAFT_Y           = 0;                                  // lead-screw axis at Y=0
FLOOR_TOP_Y       = SHAFT_Y - NEMA17_FACE / 2;          // -21.15: motor body sits on floor
FLOOR_BOTTOM_Y    = FLOOR_TOP_Y - FLOOR_THK;            // -27.15
PEDESTAL_HEIGHT   = -KP08_BORE_HEIGHT - FLOOR_TOP_Y;    //  7.15: lifts KP08 base up to bore alignment
KP08_BASE_Y       = -KP08_BORE_HEIGHT;                  // -14: pedestal top = KP08 base bottom

BACK_PLATE_TOP_Y    = SHAFT_Y + NEMA17_FACE / 2 + 4;    //  25.15
BACK_PLATE_BOT_Y    = SHAFT_Y - ANTI_ROT_OFFSET - 5;    // -35: extends below floor for anti-rot rod
BACK_PLATE_W        = NEMA17_FACE + 16;                 //  58.3: Z width with margin

// Floor extends behind the back plate far enough to seat the full motor
// body (NEMA17_BODY_L) plus a small clearance, plus the rear wall.
MOTOR_FLOOR_EXT   = NEMA17_BODY_L + MOTOR_BACK_CLEAR;   //  50

// Coupler clearance: KP08 must sit past the coupler. Coupler grips
// COUPLER_MOTOR_GRIP of the motor shaft, so its +X end sits at
// (shaft_tip - COUPLER_MOTOR_GRIP + COUPLER_L).
SHAFT_TIP_X       = NEMA17_SHAFT_L - PLATE_THK;         //  18
COUPLER_END_X     = SHAFT_TIP_X - COUPLER_MOTOR_GRIP + COUPLER_L;  // 31
KP08_START_X      = COUPLER_END_X + 1;                  //  32: 1 mm clearance past coupler
KP08_CENTER_X     = KP08_START_X + KP08_BASE_W / 2;     //  38.5
FLOOR_LEN_X       = KP08_START_X + KP08_BASE_W + 4;     //  49: small margin past KP08
PEDESTAL_X_W      = KP08_BASE_W + 4;                    //  17
PEDESTAL_Z_W      = KP08_BASE_L;                        //  55: matches KP08 base perpendicular to bore

// Rear wall (-X end of bracket) carries the frame-side rod-end tab.
REAR_WALL_X_INNER = -PLATE_THK - MOTOR_FLOOR_EXT;       // -56: rear wall's +X face (motor-side)
REAR_WALL_X_OUTER = REAR_WALL_X_INNER - REAR_WALL_THK;  // -62
REAR_WALL_TOP_Y   = SHAFT_Y + ROD_END_TAB_S / 2;        //   9: top of wall = top of tab

// ---- the part ----
module motor_mount() {
  difference() {
    union() {
      // Back plate. Motor faceplate bolts to the X- face; extends down
      // past the floor to enclose the anti-rotation rod hole.
      translate([-PLATE_THK, BACK_PLATE_BOT_Y, -BACK_PLATE_W / 2])
        cube([PLATE_THK, BACK_PLATE_TOP_Y - BACK_PLATE_BOT_Y, BACK_PLATE_W]);

      // Floor: continuous plate from the rear wall's outer face all the
      // way forward past the KP08 pedestal. Motor body rests on the
      // -X portion (from rear wall to back plate).
      translate([REAR_WALL_X_OUTER, FLOOR_BOTTOM_Y, -BACK_PLATE_W / 2])
        cube([FLOOR_LEN_X - REAR_WALL_X_OUTER, FLOOR_THK, BACK_PLATE_W]);

      // KP08 pedestal — raises the KP08 base up to the lead-screw axis
      // alignment height (FLOOR_TOP_Y → KP08_BASE_Y).
      translate([KP08_CENTER_X - PEDESTAL_X_W / 2, FLOOR_TOP_Y, -PEDESTAL_Z_W / 2])
        cube([PEDESTAL_X_W, PEDESTAL_HEIGHT, PEDESTAL_Z_W]);

      // Rear-wall column — narrow vertical post that ties the rod-end
      // tab to the floor. Z width matches the tab.
      translate([REAR_WALL_X_OUTER, FLOOR_TOP_Y, -ROD_END_TAB_S / 2])
        cube([REAR_WALL_THK, REAR_WALL_TOP_Y - FLOOR_TOP_Y, ROD_END_TAB_S]);

      // Rod-end tab — extends in -X from the rear-wall column at the
      // lead-screw axis. M6 tap drilled inside it (see removals).
      translate([REAR_WALL_X_OUTER - ROD_END_TAB_LEN, SHAFT_Y - ROD_END_TAB_S / 2, -ROD_END_TAB_S / 2])
        cube([ROD_END_TAB_LEN, ROD_END_TAB_S, ROD_END_TAB_S]);

      // Gussets at the BACK PLATE L-corners, both +X (KP08 side) and
      // -X (motor side).
      for (z = [-BACK_PLATE_W / 2, BACK_PLATE_W / 2 - GUSSET_T]) {
        translate([0, FLOOR_TOP_Y, z])
          linear_extrude(GUSSET_T)
            polygon([[0, 0], [GUSSET_LEG, 0], [0, GUSSET_LEG]]);
        translate([-PLATE_THK, FLOOR_TOP_Y, z])
          linear_extrude(GUSSET_T)
            polygon([[0, 0], [-GUSSET_LEG, 0], [0, GUSSET_LEG]]);
      }
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

    // KP08 mounting holes — through floor + pedestal. Cylinder axis must
    // run vertically (along Y), otherwise OpenSCAD's default Z-axis
    // cylinder leaves a "scoop" instead of a through-hole.
    for (z = [-KP08_HOLE_SPACING / 2, KP08_HOLE_SPACING / 2])
      translate([KP08_CENTER_X, FLOOR_BOTTOM_Y - 1, z])
        rotate([-90, 0, 0])
          cylinder(d = KP08_HOLE_D, h = FLOOR_THK + PEDESTAL_HEIGHT + 2);

    // Anti-rotation rod hole through the back plate's downward extension.
    translate([-PLATE_THK - 1, SHAFT_Y - ANTI_ROT_OFFSET, 0])
      rotate([0, 90, 0])
        cylinder(d = ANTI_ROT_HOLE_D, h = PLATE_THK + 5);

    // M6 tap for the rod-end shank — opens toward -X, threads into the tab.
    translate([REAR_WALL_X_OUTER - ROD_END_TAB_LEN - 1, SHAFT_Y, 0])
      rotate([0, 90, 0])
        cylinder(d = M6_TAP, h = ROD_END_TAP_D + 1);
  }
}

motor_mount();
