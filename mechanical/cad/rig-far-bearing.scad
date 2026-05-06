// Lead-screw rig — far end bearing block.
//
// Holds KP08 #2 at the far end of the lead screw and supports the
// anti-rotation rod's far end. No motor, no rod-end attachment — this
// end of the rig hangs in space, supported only by the rig's structure
// (the parallel rails / lead screw between this and the motor mount).
//
// Print orientation: floor (the base) flat on the bed.
//
// Render:   openscad -o ../stl/rig-far-bearing.stl rig-far-bearing.scad

include <common.scad>;

// ---- design parameters ----
FLOOR_THK       = 6;
ANTI_ROT_OFFSET = 30;        // must match motor mount
ANTI_ROT_HOLE_D = 8.4;
END_WALL_THK    = 6;         // small wall at the far end to stop the anti-rot rod
SIDE_MARGIN     = 4;         // floor margin around KP08 base

// ---- derived ----
FLOOR_LEN_X     = KP08_BASE_L + 2 * SIDE_MARGIN + END_WALL_THK;
FLOOR_W         = max(KP08_BASE_W + 2 * SIDE_MARGIN, ANTI_ROT_OFFSET + 12);
KP08_START_X    = SIDE_MARGIN;
KP08_BASE_Y     = -KP08_BORE_HEIGHT;
FLOOR_TOP_Y     = KP08_BASE_Y;
FLOOR_BOTTOM_Y  = FLOOR_TOP_Y - FLOOR_THK;

module far_bearing() {
  difference() {
    union() {
      // Floor (KP08 sits on top)
      translate([0, FLOOR_BOTTOM_Y, -FLOOR_W / 2])
        cube([FLOOR_LEN_X, FLOOR_THK, FLOOR_W]);

      // End wall at the far end (X+ side) — supports the anti-rotation rod end
      translate([FLOOR_LEN_X - END_WALL_THK, FLOOR_TOP_Y, -FLOOR_W / 2])
        cube([END_WALL_THK, 30, FLOOR_W]);
    }

    // KP08 mounting holes
    KP08_HOLE_X1 = KP08_START_X + (KP08_BASE_L - KP08_HOLE_SPACING) / 2;
    KP08_HOLE_X2 = KP08_START_X + (KP08_BASE_L + KP08_HOLE_SPACING) / 2;
    for (x = [KP08_HOLE_X1, KP08_HOLE_X2])
      translate([x, FLOOR_BOTTOM_Y - 1, 0])
        cylinder(d = KP08_HOLE_D, h = FLOOR_THK + 2);

    // Anti-rotation rod hole through the end wall
    translate([FLOOR_LEN_X - END_WALL_THK - 1, -ANTI_ROT_OFFSET, 0])
      rotate([0, 90, 0])
        cylinder(d = ANTI_ROT_HOLE_D, h = END_WALL_THK + 5);

    // Lead screw clearance through the end wall (in case it pokes past KP08)
    translate([FLOOR_LEN_X - END_WALL_THK - 1, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = LEAD_SCREW_D + 2, h = END_WALL_THK + 5);
  }
}

far_bearing();
