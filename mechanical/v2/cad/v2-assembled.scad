// v2 assembled view — shows the two printed parts with stand-ins for
// the motor, U-joint, lead screw, and brass nut, in their roles when
// the window is fully closed.
//
// Render:
//   openscad --camera=200,400,400,200,0,0 --imgsize=1600,900 \
//            --colorscheme=Tomorrow -o ../stl/v2-assembled-iso.png \
//            v2-assembled.scad

include <../../cad/common.scad>;

use <sash-motor-mount.scad>;
use <frame-nut-gimbal.scad>;

// ---- assembly parameters ----
ACTUATOR_LEN     = 302;     // distance from sash-shaft tip to frame-gimbal center when sash closed
SCREW_LEN        = 500;     // physical lead screw length
NUT_HALF_TRAVEL  = 100;     // screw protrudes through the nut by this much beyond the nut center

// In world coords:
//   - sash bracket origin at world (0, 0, 0)
//   - motor shaft axis along +X
//   - frame gimbal center at world (ACTUATOR_LEN, 0, 0)
//   - screw spans from U-joint output (just past motor shaft tip) to
//     beyond the frame gimbal
// (Coordinates of each sub-part already match this in their local
// frames, so no rotation/translation magic is needed.)

// ---- off-the-shelf hardware stand-ins ----

module nema17(face = NEMA17_FACE, body_l = NEMA17_BODY_L) {
  color([0.15, 0.15, 0.15])
    translate([-body_l, -face / 2, -face / 2])
      cube([body_l, face, face]);
}

module motor_shaft(d = NEMA17_SHAFT_D, l = NEMA17_SHAFT_L) {
  color([0.7, 0.7, 0.75])
    rotate([0, 90, 0])
      cylinder(d = d, h = l);
}

module u_joint(d = 14, l = 30) {
  // Stylised: two short cylindrical halves with a cross block in the middle
  color([0.5, 0.5, 0.55])
    union() {
      rotate([0, 90, 0]) cylinder(d = d, h = l / 2 - 2);
      translate([l / 2 - 2, 0, 0])
        cube([4, d + 2, d + 2], center = true);
      translate([l / 2 + 2, 0, 0])
        rotate([0, 90, 0]) cylinder(d = d, h = l / 2 - 2);
    }
}

module lead_screw(d = LEAD_SCREW_D, l = SCREW_LEN) {
  color([0.65, 0.55, 0.45])
    rotate([0, 90, 0])
      cylinder(d = d, h = l);
}

module prusa_nut() {
  color([0.85, 0.7, 0.3])
    rotate([0, 90, 0]) {
      // Body
      cylinder(d = PRUSA_NUT_BODY_D, h = PRUSA_NUT_BODY_L);
      // Flange
      translate([0, 0, PRUSA_NUT_BODY_L])
        cylinder(d = PRUSA_NUT_FLANGE_D, h = PRUSA_NUT_FLANGE_THK);
    }
}

// ---- the assembly ----

// Sash-side: sash motor mount + motor + shaft tip
color([0.95, 0.55, 0.20, 0.95])
  sash_motor_mount();

// Motor body sits with faceplate at X = -WALL_THK (= -6), body extending
// in -X. Motor's shaft Z position matches sash_motor_mount's SHAFT_Z.
SASH_SHAFT_Z = -(NEMA17_FACE / 2 + 6);
translate([-6, 0, SASH_SHAFT_Z]) nema17();

// Motor shaft sticking out of the wall on the +X side
translate([0, 0, SASH_SHAFT_Z]) motor_shaft(l = NEMA17_SHAFT_L - 6);

// U-joint just past the motor shaft tip
translate([NEMA17_SHAFT_L - 6 + 2, 0, SASH_SHAFT_Z])
  u_joint();

// Lead screw — starts at end of U-joint, runs all the way to and past
// the frame gimbal. The screw is at Z = SASH_SHAFT_Z because in this
// closed-sash snapshot, the screw is axially aligned with the motor
// shaft (U-joint angle = 0).
SCREW_START_X = NEMA17_SHAFT_L - 6 + 32;  // motor shaft tip + U-joint length
translate([SCREW_START_X, 0, SASH_SHAFT_Z]) lead_screw();

// Frame-side: nut gimbal at X = ACTUATOR_LEN, gimbal center matches
// frame-nut-gimbal's GIMBAL_OFFSET_Z (= SASH_SHAFT_Z)
translate([ACTUATOR_LEN, 0, 0])
  color([0.95, 0.55, 0.20, 0.95])
    frame_nut_gimbal();

// Prusa brass nut, captured in the gimbal's nut block at the gimbal center
translate([ACTUATOR_LEN - PRUSA_NUT_TOTAL_L / 2, 0, SASH_SHAFT_Z])
  prusa_nut();
