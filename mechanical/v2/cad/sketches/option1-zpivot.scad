// Option 1 — Z-axis outer pivot, Y-axis inner pivot.
//
// Frame-side captive-nut mount that fits the 20 mm Y strip above the sash.
// An L-bracket bolts to the frame, rises through the strip, and cantilevers
// a single Z-axis dowel pin into the wall-side face of the yoke. The yoke
// pivots about Z; the nut block pivots about Y inside the yoke.
//
// Printed parts (one STL each):
//   * lbracket — plate + post + cap with the Z-pin hole.
//   * yoke     — rectangular ring with one Z blind hole and two Y blind holes.
//   * block    — holds the Prusa MK3 brass nut; pivots inside the yoke.
//
// Sourced parts (shown as stand-ins, not exported):
//   * 1× Ø3 × 12 mm steel dowel (outer Z pin)
//   * 2× Ø3 × 8 mm steel dowels (inner Y pins)
//   * 2× M3 × 12 mm bolts (Prusa nut)
//   * 4× M4 self-tappers (plate to frame)
//
// Prusa nut orientation: install rotated 90° from the Prusa MK3 default so
// the M3 threaded pair sits on the Z axis (block's Z bolt holes go through
// at Y=0, Z=±9.5 — the actual Ø19 bolt circle, not the legacy 45° pattern).
//
// Coords (match frame-nut-gimbal.scad):
//   X: along screw, +X away from frame
//   Y: vertical, +Y up
//   Z: perpendicular to frame face, +Z into the room
// Origin: gimbal centre. Note GIMBAL_CTR_Z below — the yoke + block sit
// past the sash protrusion (Z = WALL_Z + 20), not at Z = 0 as in v1.
//
// Renders:
//   PNG (assembly with sash/ceiling/wall ghosts):
//     openscad -o option1-zpivot.png option1-zpivot.scad
//   STL per part:
//     openscad -D 'RENDER="lbracket"' -D 'SHOW_REFERENCE=false' \
//              -o option1-lbracket.stl option1-zpivot.scad
//     openscad -D 'RENDER="yoke"'     -D 'SHOW_REFERENCE=false' \
//              -o option1-yoke.stl     option1-zpivot.scad
//     openscad -D 'RENDER="block"'    -D 'SHOW_REFERENCE=false' \
//              -o option1-block.stl    option1-zpivot.scad

include <../../../cad/common.scad>;

$fa = 4;
$fs = 0.3;

// ---- top-level toggles (override with -D) ----
RENDER         = "all";   // "all", "lbracket", "yoke", "block"
SHOW_REFERENCE = true;    // ceiling/sash/wall ghost geometry

// ---- 20 mm Y strip constraint envelope ----
WALL_Z      = -33;
STRIP_Y     = 10;
SASH_DEPTH  = 20;

module reference_geometry() {
  // Frame face slab
  color([0.85, 0.78, 0.55, 0.30])
    translate([-60, -55, WALL_Z - 0.5])
      cube([120, 80, 1]);
  // Sash protrusion (only Z ∈ [WALL_Z, WALL_Z + 20] blocks Y < -10)
  color([0.45, 0.30, 0.18, 0.25])
    translate([-60, -55, WALL_Z])
      cube([120, 45, SASH_DEPTH]);
  // Ceiling (caps +Y everywhere)
  color([0.75, 0.75, 0.78, 0.22])
    translate([-60, STRIP_Y, WALL_Z])
      cube([120, 1, 90]);
}

// ---- design parameters ----
// L-bracket: plate + post + cap, all printed as one piece
PLATE_W          = 100;
PLATE_H          = 20;                       // fits the 20 mm strip
PLATE_THK        = 5;
PLATE_Z_BOT      = WALL_Z;
PLATE_Z_TOP      = PLATE_Z_BOT + PLATE_THK;  // -28
SCREW_INSET_X    = 18;
SCREW_INSET_Y    = 6;

POST_X           = 14;                       // post width along screw
POST_Y           = 6;                        // Y thickness (inside strip)
POST_Y_CTR       = -6;                       // post at Y ∈ [-9, -3]
POST_Z_TOP       = -12;                      // post top in Z

CAP_X            = 14;
CAP_Y_LO         = POST_Y_CTR + POST_Y / 2;  // -3 (post +Y face)
CAP_Y_HI         = 4;                        // cap extends to Y = +4
CAP_THK          = 8;                        // cap thickness in Z (also pin grip)
CAP_Z_TOP        = POST_Z_TOP;               // -12
CAP_Z_BOT        = CAP_Z_TOP - CAP_THK;      // -20

// Yoke
YOKE_OUTER_Y     = 10;                       // half-extent; ±10 fits strip
YOKE_OUTER_Z     = 17;                       // half-extent
YOKE_WALL        = 3;
YOKE_X           = 14;                       // thickness along screw

// Gimbal centre — pushed past the sash protrusion so the yoke's -Z wall
// sits at Z = -11 (2 mm past the sash front at -13).
PIN_GAP          = 1;                        // cap-top to yoke-Z gap
GIMBAL_CTR_Z     = CAP_Z_TOP + PIN_GAP + YOKE_OUTER_Z;  // = +6

// Nut block (fits inside yoke cavity)
BLOCK_W          = 24;                       // X (along screw)
BLOCK_H          = 12;                       // Y, leaves 2 mm clearance in cavity
BLOCK_D          = 22;                       // Z, leaves 6 mm clearance in cavity

// Pins
PIN_D            = 3;
PIN_HOLE_PRESS   = PIN_D;                    // Ø3.0 — press fit in printed PETG
PIN_HOLE_SLIDE   = PIN_D + 0.3;              // Ø3.3 — sliding rotation fit
Z_PIN_LEN        = 12;                       // cap (8) + gap (1) + yoke wall (3)
Y_PIN_LEN        = 8;                        // block (4) + gap (1) + yoke wall (3)
BLOCK_Y_PIN_DEPTH = 4;
YOKE_PIN_DEPTH    = YOKE_WALL;

// ---- printed parts ----

module lbracket() {
  difference() {
    union() {
      // Plate
      translate([-PLATE_W/2, -PLATE_H/2, PLATE_Z_BOT])
        cube([PLATE_W, PLATE_H, PLATE_THK]);
      // Post (rises from plate, lives at -Y end of strip)
      translate([-POST_X/2, POST_Y_CTR - POST_Y/2, PLATE_Z_TOP - 0.5])
        cube([POST_X, POST_Y, POST_Z_TOP - PLATE_Z_TOP + 0.5]);
      // Cap (horizontal slab on top of the post, reaches to Y = +4)
      translate([-CAP_X/2, CAP_Y_LO - 0.1, CAP_Z_BOT])
        cube([CAP_X, CAP_Y_HI - CAP_Y_LO + 0.1, CAP_THK]);
    }

    // 4× M4 self-tapper holes
    for (x = [-PLATE_W/2 + SCREW_INSET_X, PLATE_W/2 - SCREW_INSET_X])
      for (y = [-PLATE_H/2 + SCREW_INSET_Y, PLATE_H/2 - SCREW_INSET_Y])
        translate([x, y, PLATE_Z_BOT - 0.1])
          cylinder(h = PLATE_THK + 0.2, d = M4_HOLE);

    // Z-pin press-fit hole through the cap (at X = 0, Y = 0)
    // Goes all the way through so the user can press the pin in from below.
    translate([0, 0, CAP_Z_BOT - 0.1])
      cylinder(h = CAP_THK + 0.2, d = PIN_HOLE_PRESS);
  }
}

module yoke() {
  difference() {
    // Solid rectangular tube along X
    translate([-YOKE_X/2, -YOKE_OUTER_Y, -YOKE_OUTER_Z])
      cube([YOKE_X, 2*YOKE_OUTER_Y, 2*YOKE_OUTER_Z]);

    // Inner cavity — through-hole in X for the lead screw + nut block
    translate([-YOKE_X/2 - 1,
               -(YOKE_OUTER_Y - YOKE_WALL),
               -(YOKE_OUTER_Z - YOKE_WALL)])
      cube([YOKE_X + 2,
            2*(YOKE_OUTER_Y - YOKE_WALL),
            2*(YOKE_OUTER_Z - YOKE_WALL)]);

    // Z-pin blind hole on -Z face (sliding fit — yoke pivots around the pin)
    translate([0, 0, -YOKE_OUTER_Z - 0.1])
      cylinder(h = YOKE_PIN_DEPTH + 0.1, d = PIN_HOLE_SLIDE);

    // Y-pin blind holes on +Y and -Y walls (sliding fit — block pivots inside)
    for (ysign = [-1, 1])
      translate([0, ysign * (YOKE_OUTER_Y + 0.1), 0])
        rotate([ysign > 0 ? 90 : -90, 0, 0])
          cylinder(h = YOKE_PIN_DEPTH + 0.1, d = PIN_HOLE_SLIDE);
  }
}

module block() {
  difference() {
    translate([-BLOCK_W/2, -BLOCK_H/2, -BLOCK_D/2])
      cube([BLOCK_W, BLOCK_H, BLOCK_D]);

    // Lead screw clearance (along X)
    translate([-BLOCK_W/2 - 1, 0, 0])
      rotate([0, 90, 0])
        cylinder(h = BLOCK_W + 2, d = LEAD_SCREW_D + 2);

    // Prusa nut flange pocket (counterbore opening toward +X)
    translate([BLOCK_W/2 - PRUSA_NUT_FLANGE_THK - 0.5, 0, 0])
      rotate([0, 90, 0])
        cylinder(h = PRUSA_NUT_FLANGE_THK + 0.6,
                 d = PRUSA_NUT_FLANGE_D + 0.4);

    // M3 clearance holes on the actual Ø19 bolt circle.
    // Two on the Z axis (engage the Prusa nut's threaded pair when the nut
    // is installed rotated 90° from default); two on the Y axis as the
    // clearance pair (also drilled so the orientation is reversible).
    for (theta = [0, 90, 180, 270])
      translate([-BLOCK_W/2 - 1,
                 (PRUSA_NUT_BOLT_CIRCLE_D / 2) * cos(theta),
                 (PRUSA_NUT_BOLT_CIRCLE_D / 2) * sin(theta)])
        rotate([0, 90, 0])
          cylinder(h = BLOCK_W + 2, d = PRUSA_NUT_M3_HOLE_D);

    // Y-pin press-fit blind holes on +Y and -Y faces (inner pivot).
    // Short — they stop well before the screw bore at Y = ±5.
    for (ysign = [-1, 1])
      translate([0, ysign * (BLOCK_H/2 + 0.1), 0])
        rotate([ysign > 0 ? 90 : -90, 0, 0])
          cylinder(h = BLOCK_Y_PIN_DEPTH + 0.1, d = PIN_HOLE_PRESS);
  }
}

// ---- sourced-part stand-ins (not exported as STL) ----

module z_pin_stub() {
  color([0.55, 0.55, 0.62])
    translate([0, 0, CAP_Z_BOT])
      cylinder(h = Z_PIN_LEN, d = PIN_D);
}

module y_pins_stub() {
  color([0.55, 0.55, 0.62])
    for (ysign = [-1, 1])
      translate([0, ysign * YOKE_OUTER_Y, GIMBAL_CTR_Z])
        rotate([ysign > 0 ? 90 : -90, 0, 0])
          cylinder(h = Y_PIN_LEN, d = PIN_D);
}

module lead_screw_stub() {
  color([0.65, 0.55, 0.45])
    translate([-BLOCK_W/2 - 5, 0, GIMBAL_CTR_Z])
      rotate([0, 90, 0])
        cylinder(h = 80, d = LEAD_SCREW_D);
}

module prusa_nut_stub() {
  color([0.90, 0.75, 0.30, 0.85])
    translate([BLOCK_W/2 - PRUSA_NUT_FLANGE_THK, 0, GIMBAL_CTR_Z])
      rotate([0, -90, 0])
        union() {
          cylinder(h = PRUSA_NUT_FLANGE_THK, d = PRUSA_NUT_FLANGE_D);
          translate([0, 0, PRUSA_NUT_FLANGE_THK])
            cylinder(h = PRUSA_NUT_BODY_L, d = PRUSA_NUT_BODY_D);
        }
}

// ---- assembly / part selection ----

if (RENDER == "all") {
  if (SHOW_REFERENCE) reference_geometry();
  color([0.95, 0.55, 0.20]) lbracket();
  translate([0, 0, GIMBAL_CTR_Z]) {
    color([0.30, 0.60, 0.80]) yoke();
    color([0.85, 0.70, 0.30]) block();
  }
  z_pin_stub();
  y_pins_stub();
  lead_screw_stub();
  prusa_nut_stub();
} else if (RENDER == "lbracket") {
  lbracket();
} else if (RENDER == "yoke") {
  yoke();
} else if (RENDER == "block") {
  block();
}
