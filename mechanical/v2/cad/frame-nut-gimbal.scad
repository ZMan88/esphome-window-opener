// v2 frame-side nut gimbal.
//
// Bolts to the frame at top-middle of the window (4× M4 self-tappers,
// VHB tape on the back). Holds the Prusa MK3 brass nut in a 2-DOF
// gimbal so the nut can pivot in pitch (about Y) and yaw (about Z),
// but NOT roll (about the screw's X axis). Roll would let the nut
// spin along with the screw — no translation happens. Pitch+yaw lets
// the screw enter from whichever angle the sash demands.
//
// Gimbal stack (inner → outer):
//   • Nut block — holds the brass nut, has Z-axis cross-pin holes
//   • Outer yoke — U-shape that grips the nut block via the Z-pin;
//                  itself held by the base posts via the Y-pin
//   • Base plate + two posts — bolts to the frame
//
// Two Ø3 × ~25 mm steel cross-pins are sourced.
//
// The three pieces print SEPARATELY and assemble with the pins. This
// .scad shows the assembled view for visualization — see notes in the
// README for the print-plate layout (each part oriented for clean
// overhang-free printing).
//
// Coordinate convention (assembly local):
//   X axis: along the lead screw, +X = away from the frame
//   Y axis: vertical
//   Z axis: perpendicular to the frame face, +Z = into the room
//
// Origin: at the gimbal center (nut center when at rest).
//
// Render:   openscad -o ../stl/frame-nut-gimbal.stl frame-nut-gimbal.scad

include <../../cad/common.scad>;

// ---- design parameters ----
PLATE_W            = 120;   // X length of frame mounting plate
PLATE_H            = 60;    // Y height of frame mounting plate
FRAME_PLATE_THK    = 5;
SCREW_INSET_X      = 20;
SCREW_INSET_Y      = 10;

GIMBAL_OFFSET_Z    = -(NEMA17_FACE / 2 + 6);    // gimbal center matches sash bracket's SHAFT_Z
PIN_D              = 3;
POST_THK           = 6;     // upright post wall thickness in X (= Y-pin holder)
POST_W             = 12;    // X width of the upright post
NUT_BLOCK_W        = 24;    // X (along screw)
NUT_BLOCK_H        = 20;    // Y
NUT_BLOCK_D        = 20;    // Z
YOKE_THK           = 5;     // yoke wall thickness
YOKE_GAP           = NUT_BLOCK_W + 3;   // space between yoke prongs (X)
YOKE_BASE_H        = 6;     // Y thickness of yoke's base bar
YOKE_PRONG_H       = NUT_BLOCK_H + 6;   // Y height of yoke prongs (above base)
PLATE_TO_GIMBAL    = 32;    // Z distance from plate top to gimbal center
PLATE_Z_TOP        = GIMBAL_OFFSET_Z - PLATE_TO_GIMBAL;
PLATE_Z_BOT        = PLATE_Z_TOP - FRAME_PLATE_THK;
POST_BOT_Y         = -(YOKE_BASE_H + YOKE_PRONG_H / 2 + 4);
POST_TOP_Y         = -POST_BOT_Y;

// ---- 1. Base plate + posts ----
module base_and_posts() {
  difference() {
    union() {
      // Frame mounting plate
      translate([-PLATE_W / 2, -PLATE_H / 2, PLATE_Z_BOT])
        cube([PLATE_W, PLATE_H, FRAME_PLATE_THK]);

      // Two upright posts that hold the Y-axis cross pin (gimbal's
      // outer pivot). Posts straddle the yoke base in Y.
      for (ysign = [-1, 1])
        translate([-POST_W / 2,
                   ysign * (YOKE_BASE_H / 2 + YOKE_PRONG_H + 2),
                   PLATE_Z_TOP])
          cube([POST_W,
                ysign > 0 ? POST_THK : -POST_THK,
                GIMBAL_OFFSET_Z + 4 - PLATE_Z_TOP]);
      // ^ The post height brings its top a few mm above the gimbal
      // center so the Y pin (at GIMBAL_OFFSET_Z) is well inside the post.
    }

    // M4 self-tapper holes
    for (x = [-PLATE_W / 2 + SCREW_INSET_X, PLATE_W / 2 - SCREW_INSET_X])
      for (y = [-PLATE_H / 2 + SCREW_INSET_Y, PLATE_H / 2 - SCREW_INSET_Y])
        translate([x, y, PLATE_Z_BOT - 0.1])
          cylinder(h = FRAME_PLATE_THK + 0.2, d = M4_HOLE);

    // Y-axis pin holes through the two posts (Y is the pin direction;
    // axis allows rotation about Y → pitch of the yoke + nut block in
    // the X-Z plane).
    translate([0, -(YOKE_BASE_H / 2 + YOKE_PRONG_H + 2 + POST_THK + 1),
               GIMBAL_OFFSET_Z])
      rotate([-90, 0, 0])
        cylinder(d = PIN_D + 0.3,
                 h = 2 * (YOKE_BASE_H / 2 + YOKE_PRONG_H + 2 + POST_THK + 1));
  }
}

// ---- 2. Outer yoke ----
// U-shape, base at +Y (above gimbal center), prongs extending in -Y
// to grip the nut block on either X side. Y-axis cross pin runs
// through the base from one post into the other.
module outer_yoke() {
  difference() {
    union() {
      // Yoke base bar (above the nut block, spanning the X gap)
      translate([-YOKE_GAP / 2 - YOKE_THK,
                 YOKE_PRONG_H / 2,
                 -NUT_BLOCK_D / 2])
        cube([YOKE_GAP + 2 * YOKE_THK, YOKE_BASE_H, NUT_BLOCK_D]);

      // Two prongs hanging down in -Y from the base
      for (xsign = [-1, 1])
        translate([xsign * YOKE_GAP / 2 - (xsign > 0 ? 0 : YOKE_THK),
                   -YOKE_PRONG_H / 2,
                   -NUT_BLOCK_D / 2])
          cube([YOKE_THK, YOKE_PRONG_H + YOKE_BASE_H, NUT_BLOCK_D]);
    }

    // Z-axis cross pin holes in the prongs (carries the nut block)
    for (xsign = [-1, 1])
      translate([xsign * (YOKE_GAP / 2 + YOKE_THK / 2), 0, -NUT_BLOCK_D / 2 - 1])
        cylinder(d = PIN_D + 0.3, h = NUT_BLOCK_D + 2);

    // Y-axis pin hole through the yoke base (so the Y pin from the
    // upright posts threads through the yoke)
    translate([0, YOKE_PRONG_H / 2 - 1, 0])
      rotate([-90, 0, 0])
        cylinder(d = PIN_D + 0.3, h = YOKE_BASE_H + 2);
  }
}

// ---- 3. Nut block ----
module nut_block() {
  difference() {
    translate([-NUT_BLOCK_W / 2, -NUT_BLOCK_H / 2, -NUT_BLOCK_D / 2])
      cube([NUT_BLOCK_W, NUT_BLOCK_H, NUT_BLOCK_D]);

    // Screw through-hole (along X)
    translate([-NUT_BLOCK_W / 2 - 1, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = LEAD_SCREW_D + 2, h = NUT_BLOCK_W + 2);

    // Brass nut pocket — flange counterbore opening toward +X (the
    // motor side, where the screw enters)
    translate([NUT_BLOCK_W / 2 - PRUSA_NUT_FLANGE_THK - 0.5, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = PRUSA_NUT_FLANGE_D + 0.4,
                 h = PRUSA_NUT_FLANGE_THK + 0.6);

    // Z-axis cross-pin holes (run all the way through the block in Z)
    translate([0, 0, -NUT_BLOCK_D / 2 - 1])
      cylinder(d = PIN_D + 0.3, h = NUT_BLOCK_D + 2);
  }
}

// ---- assembly ----
module frame_nut_gimbal() {
  translate([0, 0, GIMBAL_OFFSET_Z]) {
    color([0.95, 0.55, 0.20]) base_and_posts();
    color([0.30, 0.60, 0.80]) outer_yoke();
    color([0.85, 0.70, 0.30]) nut_block();
  }
}

frame_nut_gimbal();
