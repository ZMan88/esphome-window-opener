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
END_WALL_UP     = 30;        // how far the end wall rises above the floor
SIDE_MARGIN     = 4;         // margin past KP08 (X direction; bore axis)
SIDE_MARGIN_Y   = 4;         // margin past KP08 base (Z direction; perpendicular)

// ---- derived ----
// Along X (bore axis): only need to fit A = KP08_BASE_W = 13 mm + a small
// margin + the end wall. Was previously sized to KP08_BASE_L (= 55 mm) along
// X, which was 4× larger than needed.
FLOOR_LEN_X     = KP08_BASE_W + 2 * SIDE_MARGIN + END_WALL_THK;
// Perpendicular to bore (Z): must support the KP08 base across L = 55 mm,
// and also reach down past the anti-rotation rod (offset 30) with margin.
FLOOR_W         = max(KP08_BASE_L + 2 * SIDE_MARGIN_Y, ANTI_ROT_OFFSET + 12);
KP08_START_X    = SIDE_MARGIN;
KP08_CENTER_X   = KP08_START_X + KP08_BASE_W / 2;
KP08_BASE_Y     = -KP08_BORE_HEIGHT;
FLOOR_TOP_Y     = KP08_BASE_Y;
FLOOR_BOTTOM_Y  = FLOOR_TOP_Y - FLOOR_THK;

// End-wall Y range. The wall must encompass BOTH:
//   • lead screw clearance hole at Y = 0 (top of wall well above 0)
//   • anti-rotation rod hole at Y = -ANTI_ROT_OFFSET (= -30, below floor)
// Bottom = -ANTI_ROT_OFFSET - 5 to give 5 mm of material below the rod hole.
END_WALL_BOT_Y  = -ANTI_ROT_OFFSET - 5;             // -35
END_WALL_TOP_Y  = FLOOR_TOP_Y + END_WALL_UP;        //  16

module far_bearing() {
  difference() {
    union() {
      // Floor (KP08 sits on top)
      translate([0, FLOOR_BOTTOM_Y, -FLOOR_W / 2])
        cube([FLOOR_LEN_X, FLOOR_THK, FLOOR_W]);

      // End wall at the far end (X+ side) — anchors both the lead-screw
      // clearance hole (at Y = 0) and the anti-rotation rod hole (at
      // Y = -30, below the floor). Extends from END_WALL_BOT_Y (-35) up
      // to END_WALL_TOP_Y (+16) so both holes drill through real
      // material; the original wall stopped at FLOOR_TOP_Y = -14 and
      // the rod-hole cylinder cut air.
      translate([FLOOR_LEN_X - END_WALL_THK, END_WALL_BOT_Y, -FLOOR_W / 2])
        cube([END_WALL_THK, END_WALL_TOP_Y - END_WALL_BOT_Y, FLOOR_W]);
    }

    // KP08 mounting holes — bolt-hole axis is PERPENDICULAR to the bore
    // (along Z in this local frame), spaced J = KP08_HOLE_SPACING.
    // Rotate the cylinder to run vertically (along local Y, matching
    // floor thickness) — without the rotation OpenSCAD's default Z-axis
    // cylinder pokes the side of the floor and leaves a scoop instead
    // of a through-hole.
    for (z = [-KP08_HOLE_SPACING / 2, KP08_HOLE_SPACING / 2])
      translate([KP08_CENTER_X, FLOOR_BOTTOM_Y - 1, z])
        rotate([-90, 0, 0])
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
