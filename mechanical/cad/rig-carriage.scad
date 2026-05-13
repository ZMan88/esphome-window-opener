// Lead-screw rig — carriage.
//
// Slides along the lead screw, driven by the Prusa MK3 brass nut.
// Carries the LH M6 rod-end (CSL10) on its bottom face — that rod-end
// is what attaches the carriage to the sash bracket on the window.
//
// Anti-rotation: a parallel 8 mm smooth steel rod runs through the
// carriage at the same offset used by the motor mount and far bearing.
// The carriage has a sleeve hole for the rod (no separate bushing —
// PETG-on-steel is acceptable for this duty cycle, and a printed
// bushing can be added later if friction becomes an issue).
//
// Print orientation: bottom face (toward the rod-end) on the bed; the
// nut pocket and anti-rotation hole print upward as cavities. M3 holes
// for the Prusa nut go all the way through.
//
// Render:   openscad -o ../stl/rig-carriage.stl rig-carriage.scad

include <common.scad>;

// ---- design parameters ----
// The body needs to accommodate (perpendicular to the bore):
//   • Prusa nut flange OD = 25 (with print clearance)
//   • plus a few mm of wall around the flange counterbore
// Along the bore (X) it needs:
//   • a Prusa nut counterbore (4 mm flange thickness) + body (10 mm) = 14 mm
//   • plus material around it
// Vertical (Y):
//   • SHAFT_Y above the bottom to position the bore in the upper half so the
//     LH rod-end's M6 tap fits in the bottom face without intersecting the
//     screw bore. With 18 mm tap depth + the bore at SHAFT_Y = 21.6, leaves
//     comfortable wall.
BODY_W              = 32;     // X (along screw)   — was 50, shrunk
BODY_H              = 36;     // Y (vertical)      — kept (rod-end tap depth)
BODY_D              = 36;     // Z (across rig)    — was 50, shrunk
ANTI_ROT_OFFSET     = 30;     // must match motor mount and far bearing
ANTI_ROT_HOLE_D     = 8.4;    // 8 mm rod with print clearance for sliding fit
ROD_END_TAP_D       = 18;     // M6 tap depth for the rod-end shank
NUT_POCKET_DEPTH    = PRUSA_NUT_FLANGE_THK + 0.5; // counterbore for flange (~4.5)
NUT_FLANGE_CLEAR    = 0.4;    // clearance around the flange in its pocket

// ---- derived ----
SHAFT_Y         = BODY_H * 0.6;     // lead-screw axis sits a bit above the carriage centre,
                                    // putting the rod-end on the bottom face away from the screw

module carriage() {
  difference() {
    cube([BODY_W, BODY_H, BODY_D], center = false);

    // Lead screw clearance (full through-hole)
    translate([-1, SHAFT_Y, BODY_D / 2])
      rotate([0, 90, 0])
        cylinder(d = LEAD_SCREW_D + 2, h = BODY_W + 2);

    // Prusa nut pocket — counterbore for the flange on the X- face
    translate([-1, SHAFT_Y, BODY_D / 2])
      rotate([0, 90, 0])
        cylinder(d = PRUSA_NUT_FLANGE_D + NUT_FLANGE_CLEAR, h = PRUSA_NUT_FLANGE_THK + 0.5);

    // 4× M3 mounting holes for the Prusa nut, square pattern around the lead screw
    for (dy = [-PRUSA_NUT_M3_SPACING / 2, PRUSA_NUT_M3_SPACING / 2])
      for (dz = [-PRUSA_NUT_M3_SPACING / 2, PRUSA_NUT_M3_SPACING / 2])
        translate([-1, SHAFT_Y + dy, BODY_D / 2 + dz])
          rotate([0, 90, 0])
            cylinder(d = PRUSA_NUT_M3_HOLE_D, h = BODY_W + 2);

    // Anti-rotation rod hole, parallel to the lead screw, offset by ANTI_ROT_OFFSET
    translate([-1, SHAFT_Y - ANTI_ROT_OFFSET, BODY_D / 2])
      rotate([0, 90, 0])
        cylinder(d = ANTI_ROT_HOLE_D, h = BODY_W + 2);

    // M6 tap for the LH rod-end on the BOTTOM face (Y-)
    translate([BODY_W / 2, -1, BODY_D / 2])
      rotate([-90, 0, 0])
        cylinder(d = M6_TAP, h = ROD_END_TAP_D + 1);
  }
}

carriage();
