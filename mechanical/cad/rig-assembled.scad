// Lead-screw rig — full assembled view.
//
// Places each printed part at its assembled position plus simple stand-ins
// for the off-the-shelf hardware (motor, lead screw, KP08 bearings, rod-ends,
// Prusa brass nut). The stand-ins are intentionally crude geometry — just
// boxes / cylinders — so the visual focus stays on the printed parts.
//
// Coordinate convention (matches the individual part files):
//   X axis: along the lead screw, +X = forward (toward the carriage / sash)
//   Y axis: vertical, +Y = up (Y=0 is the lead-screw axis)
//   Z axis: across the rig, +Z = away from the parallel anti-rotation rod
//
// Render:
//   openscad -o ../stl/rig-assembled.stl rig-assembled.scad
//   openscad --camera=200,0,0,90,0,90,800 --imgsize=1400,900 \
//            -o ../stl/rig-assembled-side.png rig-assembled.scad
//   openscad --camera=200,0,0,90,0,0,800   --imgsize=1400,900 \
//            -o ../stl/rig-assembled-top.png  rig-assembled.scad

include <common.scad>;

use <rig-motor-mount.scad>;
use <rig-far-bearing.scad>;
use <rig-carriage.scad>;
use <frame-bracket.scad>;
use <sash-bracket.scad>;

// ---- assembly parameters ----

LEAD_SCREW_LEN     = 400;                // physical screw length
COUPLER_LEN        = 24;
COUPLER_OD         = 19;
COUPLER_INTO_SCREW = 12;                 // how deep the screw sits in the coupler
SCREW_START_X      = -6 + NEMA17_SHAFT_L + 2; // just past the motor shaft + coupler gap
                                         // (matches rig-motor-mount's KP08_START_X)
SCREW_END_X        = SCREW_START_X + LEAD_SCREW_LEN;

// Carriage placed at mid-stroke for the visualisation.
CARRIAGE_X         = SCREW_START_X + LEAD_SCREW_LEN * 0.5;

// Far-bearing block: position so its KP08 #2 bore aligns with the screw end.
// In far_bearing local coords, KP08 bore centre is at X = SIDE_MARGIN + KP08_BASE_L/2 = 4 + 27 = 31.
FAR_BEARING_LOCAL_BORE_X = 4 + KP08_BASE_L / 2;     // 31
FAR_BEARING_X            = SCREW_END_X - 20 - FAR_BEARING_LOCAL_BORE_X;
                                         // 20mm screw protrusion past KP08 #2

// Frame bracket: rotated so its plate spans the world Z axis and its arm
// extends in +X toward the motor mount. We want the arm tip's M6 tap to sit
// just behind the motor-mount's rod-end tab so the RH rod-end can bridge
// them. Motor-mount tab opens at X = -PLATE_THK - ROD_END_TAB_LEN = -31.
// We want the frame-bracket arm tip at X ≈ -50 (gap ~19 mm for the rod-end
// body). With rotate([0,90,0]) the local Z axis (plate thickness + arm
// length) maps to world +X, so:
//   plate front face at world X = FRAME_BRACKET_X + PLATE_THK = -77
//   arm tip      at world X = FRAME_BRACKET_X + PLATE_THK + ARM_L = -50
FRAME_BRACKET_X    = -82;

// Sash bracket: lies horizontally below the carriage. The plate's top face
// faces UP (toward the LH rod-end body), the hex pocket and M6 hole are on
// the bottom face (so the M6 nut sits flush against the sash top rail).
SASH_BRACKET_Y     = -80;                // top face at Y = -75, bottom face at Y = -80

// ---- off-the-shelf hardware stand-ins ----

module nema17(face = NEMA17_FACE, body_l = NEMA17_BODY_L, shaft_l = NEMA17_SHAFT_L) {
  color([0.15, 0.15, 0.15]) {
    // Body: extends in -X behind the motor mount back plate
    translate([-PLATE_THK - body_l, -face/2, -face/2])
      cube([body_l, face, face]);
    // Shaft: extends in +X through the back plate cutout into the coupler
    translate([-PLATE_THK, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = NEMA17_SHAFT_D, h = shaft_l);
  }
}

module coupler() {
  color([0.7, 0.72, 0.74]) {
    translate([SCREW_START_X - COUPLER_LEN + COUPLER_INTO_SCREW, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = COUPLER_OD, h = COUPLER_LEN);
  }
}

module lead_screw() {
  color([0.55, 0.58, 0.62]) {
    translate([SCREW_START_X, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = LEAD_SCREW_D, h = LEAD_SCREW_LEN);
  }
}

// KP08 stand-in matching the measured envelope.
module kp08() {
  color([0.6, 0.65, 0.7]) {
    // base
    translate([0, -KP08_BORE_HEIGHT, -KP08_BASE_L/2])
      // base lies in XZ plane: length along X, width along Z (axis-of-bearing)
      cube([KP08_BASE_L, 0.001, KP08_BODY_W]); // flat — placeholder
    // body
    translate([0, -KP08_BORE_HEIGHT, (KP08_BODY_W - KP08_BASE_W)/2])
      cube([KP08_BASE_L, KP08_TOTAL_H, KP08_BASE_W]);
    // bore highlight
    translate([KP08_BASE_L/2, 0, KP08_BODY_W/2 - 0.1])
      rotate([90, 0, 0])
        cylinder(d = LEAD_SCREW_D + 4, h = 1, center = true);
  }
}

// Prusa MK3 brass nut — flange + cylindrical body
module prusa_nut() {
  color([0.85, 0.7, 0.25]) {
    // flange (thick disc), at one end of the body
    translate([0, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = PRUSA_NUT_FLANGE_D, h = PRUSA_NUT_FLANGE_THK);
    // body extending out from the flange
    translate([PRUSA_NUT_FLANGE_THK, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = PRUSA_NUT_BODY_D, h = PRUSA_NUT_TOTAL_L - PRUSA_NUT_FLANGE_THK);
  }
}

// Rod-end ball joint — simple representation: ball housing + two threaded shanks.
module rod_end(shank1_l = 14, shank2_l = 14, body_d = 18, body_l = 16) {
  color([0.55, 0.6, 0.65]) {
    // shank 1
    rotate([0, 90, 0])
      cylinder(d = 6, h = shank1_l);
    // ball housing (sphere with hole)
    translate([shank1_l + body_l/2, 0, 0])
      sphere(d = body_d);
    // shank 2
    translate([shank1_l + body_l, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = 6, h = shank2_l);
  }
}

// Anti-rotation rod
module anti_rot_rod(length, x_start) {
  color([0.7, 0.72, 0.75]) {
    translate([x_start, -30, 0])
      rotate([0, 90, 0])
        cylinder(d = 8, h = length);
  }
}

// ---- the assembly ----

module rig_assembled() {
  // ----- printed parts -----

  // Motor mount at the origin (its local origin = world origin)
  color([0.9, 0.5, 0.2])
    motor_mount();

  // Carriage at mid-stroke
  // The carriage's local origin is at [0,0,0]; in local coords SHAFT_Y = BODY_H*0.6.
  // World lead screw is at Y=0, so carriage Y-offset = -BODY_H*0.6 = -21.6.
  // Carriage is centered on the lead screw in X (cube width 50), so X-offset = CARRIAGE_X - 25.
  // Centered in Z (cube depth 50), so Z-offset = -25.
  color([0.9, 0.5, 0.2])
    translate([CARRIAGE_X - 25, -21.6, -25])
      carriage();

  // Far bearing block
  color([0.9, 0.5, 0.2])
    translate([FAR_BEARING_X, 0, 0])
      far_bearing();

  // Frame bracket — rotate([0,90,0]) maps:
  //   local +X (plate long axis, 190 mm) → world -Z
  //   local +Y (plate height, 18 mm)     → world +Y
  //   local +Z (plate thickness + arm)   → world +X (arm extends toward rig)
  // Then translate: centre plate on Z=0, centre on lead-screw at Y=0,
  // and set FRAME_BRACKET_X for the desired X position.
  color([0.9, 0.5, 0.2])
    translate([FRAME_BRACKET_X, -9, BRACKET_WIDTH/2])
      rotate([0, 90, 0])
        frame_bracket();

  // Sash bracket — rotate([-90,0,0]) maps:
  //   local +X (plate long axis, 190 mm)  → world +X
  //   local +Y (plate height, 45 mm)       → world -Z
  //   local +Z (plate thickness, 5 mm)     → world +Y
  // So back face (local Z=0) ends up at the BOTTOM of the plate, hex pocket
  // and M6 nut hide under the plate against the sash — top face faces UP.
  color([0.9, 0.5, 0.2])
    translate([CARRIAGE_X - BRACKET_WIDTH/2, SASH_BRACKET_Y, 22.5])
      rotate([-90, 0, 0])
        sash_bracket();

  // ----- off-the-shelf hardware -----

  // NEMA17 motor (body behind the back plate)
  nema17();

  // Coupler
  coupler();

  // Lead screw
  lead_screw();

  // KP08 #1 — near the motor end. In motor mount local, KP08 sits at
  // X = NEMA17_SHAFT_L + 2 (= SCREW_START_X), on the floor at Y = -KP08_BORE_HEIGHT.
  translate([SCREW_START_X, 0, 0])
    kp08();

  // KP08 #2 — at the far bearing. Local X = SIDE_MARGIN = 4 inside far_bearing.
  translate([FAR_BEARING_X + 4, 0, 0])
    kp08();

  // Prusa brass nut on carriage X- face (flange side flush with carriage)
  // Body extends back into the carriage. In world, flange faces -X.
  translate([CARRIAGE_X - 25 - PRUSA_NUT_FLANGE_THK, 0, 0])
    prusa_nut();

  // RH rod-end (CS10) between motor-mount tab and frame-bracket arm
  // Spans roughly from X = motor-tab-tap-mouth (-PLATE_THK - ROD_END_TAB_LEN = -31)
  // to X = FRAME_BRACKET_X + some_arm_depth.
  translate([FRAME_BRACKET_X + 12, 0, 0])
    rod_end(shank1_l = 14, shank2_l = 14);

  // LH rod-end (CSL10) hanging below carriage. The carriage's M6 tap is on
  // the bottom face at world Y = -21.6 (carriage bottom). Rotate the rod-end
  // so it points in world -Y (downward) from the tap.
  translate([CARRIAGE_X, -21.6, 0])
    rotate([0, 0, -90])
      rod_end(shank1_l = 4, shank2_l = 50);

  // Anti-rotation rod — through motor mount back plate, through carriage's
  // lower hole (at Y = -30), through far-bearing end wall.
  anti_rot_rod(length = FAR_BEARING_X + 68 + 4 - (-PLATE_THK - 5),
               x_start = -PLATE_THK - 5);
}

rig_assembled();
