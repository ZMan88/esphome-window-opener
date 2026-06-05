// v2 frame-side nut gimbal.
//
// Bolts to the frame at top-middle of the window (4× M4 self-tappers,
// VHB tape on the back). Holds the Prusa MK3 brass nut in a 2-DOF
// gimbal so the nut can pivot in pitch (about Y) and yaw (about Z),
// but NOT roll (about the screw's X axis).
//
// Construction (3 printed pieces + 4 sourced steel dowel pins):
//
//   1. base-and-posts: frame plate + two upright posts straddling the
//      yoke in Y. Posts sit fully inside the plate's footprint so they
//      union solidly with the plate. Each post has a Y-direction
//      through hole at the gimbal-centre height for one Y-pin.
//
//   2. outer-yoke: a hollow rectangular ring (in the Y–Z plane) with
//      cavity sized to contain the nut block. Has Y-direction BLIND
//      holes on its +Y and -Y outer faces (mate with the post pins)
//      and Z-direction THROUGH holes on its +Z and -Z outer faces
//      (the inner pins pass through these and into the nut block).
//
//   3. nut-block: cube holding the Prusa nut; has Z-direction BLIND
//      holes on its +Z and -Z outer faces (mate with the yoke's Z
//      pins).
//
//   Pins: 4× Ø3 × ~14 mm steel dowels.
//     2× Y-pins: post (through-hole) → 1 mm gap → yoke +Y wall (blind).
//                Repeat on -Y side. Pins are SHORT so neither reaches
//                Y=0 — they never cross the screw bore at the gimbal
//                centre.
//     2× Z-pins: outside yoke → +Z wall (through) → 1 mm gap → nut
//                block +Z face (blind). Repeat on -Z side. Same idea:
//                each pin is short, the screw passes through the gap
//                between the +Z and -Z pin tips along the Z=0 axis.
//
// Coordinate convention (assembly local):
//   X axis: along the lead screw, +X = away from the frame
//   Y axis: vertical (parallel to gravity), +Y = up
//   Z axis: perpendicular to the frame face, +Z = into the room
// Origin: gimbal centre (nut centre when the gimbal is at rest).
//
// Print orientation: each part flat on the bed for clean overhangs —
// base+posts with posts pointing up, yoke ring flat (X-axis vertical),
// nut block on either Y face. Assemble with the dowel pins.
//
// Render:   openscad -o ../stl/frame-nut-gimbal.stl frame-nut-gimbal.scad

include <../../cad/common.scad>;

// ---- design parameters ----
PLATE_W            = 100;    // X length of frame mounting plate
PLATE_H            = 60;     // Y height of frame mounting plate (must contain posts)
FRAME_PLATE_THK    = 5;
SCREW_INSET_X      = 18;
SCREW_INSET_Y      = 12;     // keeps M4 screw centres clear of the post footprints

GIMBAL_OFFSET_Z    = -(NEMA17_FACE / 2 + 6);   // -27.15: matches sash bracket's SHAFT_Z

// Outer yoke: hollow rectangular ring in Y–Z plane.
YOKE_OUTER_Y       = 20;    // half-extent in Y of yoke outer wall (sized for yawed block + clearance)
YOKE_OUTER_Z       = 18;    // half-extent in Z of yoke outer wall
YOKE_WALL_THK      = 4;     // ring wall thickness
YOKE_X_DEPTH       = 10;    // ring thickness along screw axis

// Nut block — must fit inside the yoke cavity with clearance, and must be
// big enough in Y and Z to host the Prusa nut's Ø19 bolt circle (holes at
// radius 9.5 from screw axis, M3 clearance Ø3.4 → block half-extent ≥ 11.2).
NUT_BLOCK_W        = 20;    // X (along screw); covers Prusa nut + 6 mm pocket
NUT_BLOCK_H        = 24;    // Y; ≥ 22.4 to contain the Y=±9.5 mounting holes
NUT_BLOCK_D        = 24;    // Z; ≥ 22.4 to contain the Z=±9.5 mounting holes

// Posts (rise from plate to gimbal height)
POST_W             = 12;    // X width
POST_THK           = 6;     // Y thickness
POST_INNER_Y       = YOKE_OUTER_Y + 1;          // 1 mm gap to yoke
POST_OUTER_Y       = POST_INNER_Y + POST_THK;
PLATE_TO_GIMBAL    = 28;    // Z distance from plate top to gimbal centre

// Pin dimensions (steel dowel stand-ins for visualisation)
PIN_D              = 3;
Y_PIN_LEN          = (POST_OUTER_Y + 1) - (YOKE_OUTER_Y - (YOKE_WALL_THK - 0.5));  // ≈ 11.5
Z_PIN_LEN          = (YOKE_OUTER_Z + 1) - (NUT_BLOCK_D / 2 - 3);                   // ≈ 12

// ---- derived ----
PLATE_Z_TOP        = -PLATE_TO_GIMBAL;          // = -28: top of plate
PLATE_Z_BOT        = PLATE_Z_TOP - FRAME_PLATE_THK;  // = -33
POST_HEIGHT        = PLATE_TO_GIMBAL + YOKE_OUTER_Z + 4;  // post reaches 4 mm above yoke top

// ---- 1. Base plate + posts (one printed part) ----
module base_and_posts() {
  difference() {
    union() {
      // Frame mounting plate
      translate([-PLATE_W / 2, -PLATE_H / 2, PLATE_Z_BOT])
        cube([PLATE_W, PLATE_H, FRAME_PLATE_THK]);

      // Two posts. Y range straddles the yoke; both posts sit inside
      // the plate's Y footprint so they union solidly into the plate.
      for (ysign = [-1, 1])
        translate([-POST_W / 2,
                   ysign > 0 ? POST_INNER_Y : -POST_OUTER_Y,
                   PLATE_Z_TOP - 0.5])      // -0.5 overlaps the plate for a clean union
          cube([POST_W, POST_THK, POST_HEIGHT + 0.5]);
    }

    // M4 self-tapper holes
    for (x = [-PLATE_W / 2 + SCREW_INSET_X, PLATE_W / 2 - SCREW_INSET_X])
      for (y = [-PLATE_H / 2 + SCREW_INSET_Y, PLATE_H / 2 - SCREW_INSET_Y])
        translate([x, y, PLATE_Z_BOT - 0.1])
          cylinder(h = FRAME_PLATE_THK + 0.2, d = M4_HOLE);

    // Y-pin through holes — one through each post, at the gimbal-centre
    // height (Z = 0), centred in X. Rotation flips with ysign so the
    // cylinder bores INWARD through each post (the +Y post drills toward
    // -Y, the -Y post drills toward +Y); a single rotation drilled the
    // -Y hole into empty space below the post.
    for (ysign = [-1, 1])
      translate([0, ysign * (POST_OUTER_Y + 0.5), 0])
        rotate([ysign > 0 ? 90 : -90, 0, 0])
          cylinder(d = PIN_D + 0.3, h = POST_THK + 1);
  }
}

// ---- 2. Outer yoke ----
module outer_yoke() {
  difference() {
    // Solid yoke "tube" (rectangular tube along X)
    translate([-YOKE_X_DEPTH / 2, -YOKE_OUTER_Y, -YOKE_OUTER_Z])
      cube([YOKE_X_DEPTH, 2 * YOKE_OUTER_Y, 2 * YOKE_OUTER_Z]);

    // Inner cavity (through-hole in X) — sized so nut block has slop for pivot
    translate([-YOKE_X_DEPTH / 2 - 1,
               -(YOKE_OUTER_Y - YOKE_WALL_THK),
               -(YOKE_OUTER_Z - YOKE_WALL_THK)])
      cube([YOKE_X_DEPTH + 2,
            2 * (YOKE_OUTER_Y - YOKE_WALL_THK),
            2 * (YOKE_OUTER_Z - YOKE_WALL_THK)]);

    // Y-pin blind holes on +Y and -Y outer faces.
    // Each goes into the wall but stops short of the inner cavity.
    for (ysign = [-1, 1])
      translate([0, ysign * (YOKE_OUTER_Y + 0.1), 0])
        rotate([ysign > 0 ? 90 : -90, 0, 0])
          cylinder(d = PIN_D + 0.3, h = YOKE_WALL_THK - 0.3);

    // Z-pin THROUGH holes on +Z and -Z walls
    // Each goes from outside the yoke through the wall and into the cavity.
    for (zsign = [-1, 1])
      translate([0, 0, zsign * (YOKE_OUTER_Z + 0.1)])
        rotate([0, zsign > 0 ? 180 : 0, 0])
          cylinder(d = PIN_D + 0.3, h = YOKE_WALL_THK + 1);
  }
}

// ---- 3. Nut block ----
module nut_block() {
  difference() {
    translate([-NUT_BLOCK_W / 2, -NUT_BLOCK_H / 2, -NUT_BLOCK_D / 2])
      cube([NUT_BLOCK_W, NUT_BLOCK_H, NUT_BLOCK_D]);

    // Screw clearance (along X)
    translate([-NUT_BLOCK_W / 2 - 1, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = LEAD_SCREW_D + 2, h = NUT_BLOCK_W + 2);

    // Prusa nut flange pocket (counterbore opening toward +X)
    translate([NUT_BLOCK_W / 2 - PRUSA_NUT_FLANGE_THK - 0.5, 0, 0])
      rotate([0, 90, 0])
        cylinder(d = PRUSA_NUT_FLANGE_D + 0.4,
                 h = PRUSA_NUT_FLANGE_THK + 0.6);

    // 4× M3 mounting holes for the Prusa nut. The Prusa nut has 4 holes
    // on a Ø19 bolt circle at 0°/90°/180°/270°: 2× M3 threaded
    // (vertically opposed) + 2× Ø4.1 clearance (horizontally opposed).
    // The block drills all 4 in X direction; the user picks the
    // threaded pair when installing the nut. Bolts pass from the -X
    // face, through the body, into the pocket where the flange sits,
    // and thread into the nut.
    //
    // (The legacy PRUSA_NUT_M3_SPACING / 2 inset put the holes at 45°
    // on the Ø19 circle — none of them lined up with a real thread.)
    for (theta = [0, 90, 180, 270])
      translate([-NUT_BLOCK_W / 2 - 1,
                 (PRUSA_NUT_BOLT_CIRCLE_D / 2) * cos(theta),
                 (PRUSA_NUT_BOLT_CIRCLE_D / 2) * sin(theta)])
        rotate([0, 90, 0])
          cylinder(d = PRUSA_NUT_M3_HOLE_D, h = NUT_BLOCK_W + 2);

    // Z-pin blind holes on +Z and -Z faces.
    // Depth is bounded so the hole tip stays out of the screw bore at
    // Z = ±(LEAD_SCREW_D/2 + 1) = ±5.
    for (zsign = [-1, 1])
      translate([0, 0, zsign * (NUT_BLOCK_D / 2 + 0.1)])
        rotate([0, zsign > 0 ? 180 : 0, 0])
          cylinder(d = PIN_D + 0.3, h = NUT_BLOCK_D / 2 - 6);
  }
}

// ---- 4. Steel dowel pin stand-ins (not printed; for visualisation) ----
module gimbal_pins() {
  // 2× Y-pins
  for (ysign = [-1, 1])
    translate([0, ysign * (POST_OUTER_Y + 0.5 - Y_PIN_LEN / 2), 0])
      rotate([90, 0, 0])
        translate([0, 0, -Y_PIN_LEN / 2])
          cylinder(d = PIN_D, h = Y_PIN_LEN);

  // 2× Z-pins
  for (zsign = [-1, 1])
    translate([0, 0, zsign * (YOKE_OUTER_Z + 0.5 - Z_PIN_LEN / 2)])
      translate([0, 0, -Z_PIN_LEN / 2])
        cylinder(d = PIN_D, h = Z_PIN_LEN);
}

// ---- assembly module ----
module frame_nut_gimbal(show_pins = false) {
  translate([0, 0, GIMBAL_OFFSET_Z]) {
    color([0.95, 0.55, 0.20]) base_and_posts();
    color([0.30, 0.60, 0.80]) outer_yoke();
    color([0.85, 0.70, 0.30]) nut_block();
    if (show_pins)
      color([0.55, 0.55, 0.60]) gimbal_pins();
  }
}

frame_nut_gimbal(show_pins = true);
