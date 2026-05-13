// Lead-screw rig — carriage.
//
// Slides along the lead screw, driven by the Prusa MK3 brass nut.
// Carries the LH M6 rod-end (CSL10) on its bottom face — that rod-end
// is what attaches the carriage to the sash bracket on the window.
//
// Anti-rotation: a parallel 8 mm smooth steel rod runs through the
// carriage at the same offset used by the motor mount and far bearing.
// The body extends below the lead-screw axis far enough to actually
// enclose the rod hole (the previous design had the hole drilling air).
//
// The M6 rod-end tap and the anti-rotation rod hole would collide if
// both sat at the carriage's Z centerline (same Z column, overlapping
// Y), so the M6 tap is OFFSET in Z by M6_TAP_Z_OFFSET. The sash
// bracket's M6 hole must use the same Z offset to align with the
// rod-end's ball joint.
//
// Print orientation: bottom face (toward the rod-end) on the bed; the
// nut pocket and anti-rotation hole print upward as cavities. M3 holes
// for the Prusa nut go all the way through.
//
// Render:   openscad -o ../stl/rig-carriage.stl rig-carriage.scad

include <common.scad>;

// ---- design parameters ----
BODY_W               = 32;     // X (along screw)
BODY_D               = 36;     // Z (across rig)
ANTI_ROT_OFFSET      = 30;     // must match motor mount and far bearing
ANTI_ROT_HOLE_D      = 8.4;    // 8 mm rod with print clearance for sliding fit
ROD_END_TAP_D        = 18;     // M6 tap depth for the rod-end shank
NUT_FLANGE_CLEAR     = 0.4;    // clearance around the Prusa nut flange
ANTI_ROT_HOLE_MARGIN = 5;      // distance from rod center to body bottom (matches motor mount + far bearing)
TOP_MARGIN           = 2;      // material above the Prusa nut flange pocket
M6_TAP_Z_OFFSET      = -11;    // M6 tap Z offset from carriage centerline (clears rod hole; see comments above)

// ---- derived ----
// Bottom of body at Y = 0. SHAFT_Y must satisfy two constraints:
//   • rod hole (Y = SHAFT_Y - ANTI_ROT_OFFSET) sits inside the body with
//     ANTI_ROT_HOLE_MARGIN below the rod center: SHAFT_Y ≥ 35.
//   • M6 tap (depth ROD_END_TAP_D from bottom) clears the lead-screw bore
//     bottom: ROD_END_TAP_D + 2 ≤ SHAFT_Y - (LEAD_SCREW_D + 2) / 2,
//     i.e. SHAFT_Y ≥ 25. Always satisfied when the rod-hole constraint is.
SHAFT_Y              = ANTI_ROT_OFFSET + ANTI_ROT_HOLE_MARGIN;             // 35
SHAFT_Z              = BODY_D / 2;                                          // 18
M6_TAP_Z             = SHAFT_Z + M6_TAP_Z_OFFSET;                           //  7
BODY_H               = SHAFT_Y + (PRUSA_NUT_FLANGE_D + NUT_FLANGE_CLEAR) / 2 + TOP_MARGIN;  // 49.7
NUT_POCKET_DEPTH     = PRUSA_NUT_FLANGE_THK + 0.5;                          // 4.5

module carriage() {
  difference() {
    cube([BODY_W, BODY_H, BODY_D], center = false);

    // Lead screw clearance (full through-hole)
    translate([-1, SHAFT_Y, SHAFT_Z])
      rotate([0, 90, 0])
        cylinder(d = LEAD_SCREW_D + 2, h = BODY_W + 2);

    // Prusa nut flange pocket — counterbore for the flange on the X- face
    translate([-1, SHAFT_Y, SHAFT_Z])
      rotate([0, 90, 0])
        cylinder(d = PRUSA_NUT_FLANGE_D + NUT_FLANGE_CLEAR, h = NUT_POCKET_DEPTH);

    // 4× M3 mounting holes for the Prusa nut, square pattern around the lead screw
    for (dy = [-PRUSA_NUT_M3_SPACING / 2, PRUSA_NUT_M3_SPACING / 2])
      for (dz = [-PRUSA_NUT_M3_SPACING / 2, PRUSA_NUT_M3_SPACING / 2])
        translate([-1, SHAFT_Y + dy, SHAFT_Z + dz])
          rotate([0, 90, 0])
            cylinder(d = PRUSA_NUT_M3_HOLE_D, h = BODY_W + 2);

    // Anti-rotation rod hole — full through-hole at Z = SHAFT_Z, below
    // the lead-screw axis by ANTI_ROT_OFFSET.
    translate([-1, SHAFT_Y - ANTI_ROT_OFFSET, SHAFT_Z])
      rotate([0, 90, 0])
        cylinder(d = ANTI_ROT_HOLE_D, h = BODY_W + 2);

    // M6 tap for the LH rod-end on the BOTTOM face (Y-), offset in Z
    // by M6_TAP_Z_OFFSET to avoid the anti-rotation rod hole.
    translate([BODY_W / 2, -1, M6_TAP_Z])
      rotate([-90, 0, 0])
        cylinder(d = M6_TAP, h = ROD_END_TAP_D + 1);
  }
}

carriage();
