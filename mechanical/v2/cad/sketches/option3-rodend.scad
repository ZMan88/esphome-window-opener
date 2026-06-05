// Option 3 — Rod end (ball joint) + anti-roll pin.
//
// Frame-side captive-nut mount using a sourced rod end as the pivot, plus
// a separate anti-roll pin to block X-axis rotation (which a ball joint
// alone allows freely).
//
// Printed parts (one STL each):
//   * plate — frame plate + tapped M6 boss for the rod-end shank + smaller
//             offset boss with a press-fit hole for the anti-roll pin.
//   * block — main block holding the Prusa MK3 brass nut, with two clevis
//             ears reaching back toward the wall to capture the rod-end
//             ball via an X-axis bolt; plus an anti-roll slot on the
//             wall-side face that engages the pin from the plate's offset
//             boss.
//
// Sourced parts (shown as stand-ins, not exported):
//   * 1× CSL6-style M6 male rod end (Ø6 shank, Ø10 ball nominal here)
//   * 1× M5 × 25 mm shoulder bolt + nut (through the ball)
//   * 1× Ø4 × 18 mm steel dowel (anti-roll pin)
//   * 2× M3 × 12 mm bolts (Prusa nut)
//   * 4× M4 self-tappers (plate to frame)
//
// Prusa nut: installed rotated so its M3 threaded pair sits on the Z axis.
// Block has 4× clearance holes on the actual Ø19 bolt circle (0/90/180/270°);
// user uses the Z-axis pair.
//
// Anti-roll: pin is offset in X from the central rod-end axis to keep it
// clear of the M6 boss. The block has a matching X-oriented slot on its
// wall-side face — the slot's X length sets the maximum pitch/yaw before
// the pin binds. With this offset arrangement the anti-roll pin is
// load-bearing for the X-roll moment; it MUST be steel, not printed.
//
// Coords (match frame-nut-gimbal.scad):
//   X: along screw, +X away from frame
//   Y: vertical, +Y up
//   Z: perpendicular to frame face, +Z into the room
// Origin: ball centre. The block centre sits at GIMBAL_CTR_Z (positive Z),
// past the sash; the rod-end boss sits between the plate and the ball.
//
// Renders:
//   PNG: openscad -o option3-rodend.png option3-rodend.scad
//   STL: openscad -D 'RENDER="plate"' -D 'SHOW_REFERENCE=false' \
//                 -o option3-plate.stl option3-rodend.scad
//        openscad -D 'RENDER="block"' -D 'SHOW_REFERENCE=false' \
//                 -o option3-block.stl option3-rodend.scad

include <../../../cad/common.scad>;

$fa = 4;
$fs = 0.3;

// ---- top-level toggles (override with -D) ----
RENDER         = "all";   // "all", "plate", "block"
SHOW_REFERENCE = true;

// ---- 20 mm Y strip constraint envelope ----
WALL_Z      = -33;
STRIP_Y     = 10;
SASH_DEPTH  = 20;

module reference_geometry() {
  color([0.85, 0.78, 0.55, 0.30])
    translate([-60, -55, WALL_Z - 0.5])
      cube([120, 80, 1]);
  color([0.45, 0.30, 0.18, 0.25])
    translate([-60, -55, WALL_Z])
      cube([120, 45, SASH_DEPTH]);
  color([0.75, 0.75, 0.78, 0.22])
    translate([-60, STRIP_Y, WALL_Z])
      cube([120, 1, 90]);
}

// ---- design parameters ----
PLATE_W       = 100;
PLATE_H       = 20;
PLATE_THK     = 5;
PLATE_Z_BOT   = WALL_Z;
PLATE_Z_TOP   = PLATE_Z_BOT + PLATE_THK;     // -28
SCREW_INSET_X = 18;
SCREW_INSET_Y = 6;

// Rod-end mounting boss (centred, tapped M6 along Z). OD = 10 keeps the
// boss inside Y = ±5 so the anti-roll boss can sit beside it on -Y.
BOSS_OD       = 10;
BOSS_LEN      = 12;                          // boss height above plate
BOSS_TOP_Z    = PLATE_Z_TOP + BOSS_LEN;      // -16
M6_TAP_DEPTH  = 10;                          // tap depth into the boss

// Rod end body + ball (sourced)
ROD_BODY_D    = 8;
ROD_BODY_L    = 10;                          // exposed body between boss and ball
BALL_D        = 10;
BALL_Z        = BOSS_TOP_Z + ROD_BODY_L + BALL_D/2;  // ball centre at Z = +1

// Anti-roll boss: on the screw axis in X (so the block slot can sit
// centred between the clevis ears), offset in -Y to clear the central M6
// boss. The two bosses overlap slightly and union into one shape.
ANTI_BOSS_OD     = 8;
ANTI_BOSS_H      = 4;
ANTI_BOSS_X      = 0;
ANTI_BOSS_Y      = -6;                       // -Y offset, keeps boss in strip
ANTI_PIN_D       = 4;
ANTI_PIN_HOLE_D  = ANTI_PIN_D;               // press fit in plate
ANTI_PIN_LEN     = 40;                       // reaches across the long Z gap to the block

// Block (downstream of the ball, holds the Prusa nut)
BLOCK_W       = 24;                          // X — slot is centred, no offset needed
BLOCK_H       = 14;                          // Y
BLOCK_D       = 22;                          // Z
GIMBAL_CTR_Z  = BALL_Z + 14;                 // block centre Z — leaves room for clevis

// Clevis ears (extend in -Z from the block, capture the ball)
CLEVIS_THK    = 4;                           // each ear thickness in X
CLEVIS_X_GAP  = BALL_D + 1;                  // gap between ear inner faces
CLEVIS_Y      = 16;
CLEVIS_Z_LEN  = (GIMBAL_CTR_Z - BLOCK_D/2) - (BALL_Z - BALL_D/2 - 1);
CLEVIS_BOLT_D = 5.5;                         // M5 clearance through both ears + ball

// Anti-roll slot on block (-Z face). Centred in X between the clevis ears.
SLOT_LEN_X    = 16;                          // sets max pitch/yaw before binding
SLOT_W_Y      = ANTI_PIN_D + 0.6;
SLOT_DEPTH_Z  = 8;

// ---- printed parts ----

module plate() {
  difference() {
    union() {
      // Plate
      translate([-PLATE_W/2, -PLATE_H/2, PLATE_Z_BOT])
        cube([PLATE_W, PLATE_H, PLATE_THK]);
      // Central M6 boss (rod-end shank tap)
      translate([0, 0, PLATE_Z_TOP - 0.5])
        cylinder(h = BOSS_LEN + 0.5, d = BOSS_OD);
      // Anti-roll boss — on the screw axis in X, offset -Y from the
      // central boss. The two bosses overlap and union into one shape.
      translate([ANTI_BOSS_X, ANTI_BOSS_Y, PLATE_Z_TOP - 0.5])
        cylinder(h = ANTI_BOSS_H + 0.5, d = ANTI_BOSS_OD);
    }

    // 4× M4 self-tapper holes
    for (x = [-PLATE_W/2 + SCREW_INSET_X, PLATE_W/2 - SCREW_INSET_X])
      for (y = [-PLATE_H/2 + SCREW_INSET_Y, PLATE_H/2 - SCREW_INSET_Y])
        translate([x, y, PLATE_Z_BOT - 0.1])
          cylinder(h = PLATE_THK + 0.2, d = M4_HOLE);

    // M6 tap drill — into the central boss along Z
    translate([0, 0, BOSS_TOP_Z - M6_TAP_DEPTH])
      cylinder(h = M6_TAP_DEPTH + 0.2, d = M6_TAP);

    // Anti-roll pin press-fit hole through the anti-roll boss + plate
    translate([ANTI_BOSS_X, ANTI_BOSS_Y, PLATE_Z_BOT - 0.1])
      cylinder(h = PLATE_THK + ANTI_BOSS_H + 0.2, d = ANTI_PIN_HOLE_D);
  }
}

module block() {
  difference() {
    union() {
      // Main block body (centred at origin in block frame)
      translate([-BLOCK_W/2, -BLOCK_H/2, -BLOCK_D/2])
        cube([BLOCK_W, BLOCK_H, BLOCK_D]);
      // Two clevis ears — extend in -Z from block bottom toward the ball.
      // The +X ear sits at X ∈ [+gap/2, +gap/2 + thk]; the -X ear mirrors
      // it at X ∈ [-(gap/2 + thk), -gap/2]. (The single-expression form
      // `xsign * gap/2` would have put the -X ear at [-gap/2, -gap/2 + thk]
      // — inside the ball region, not flanking it.)
      for (xsign = [-1, 1])
        translate([xsign > 0 ? CLEVIS_X_GAP/2 : -(CLEVIS_X_GAP/2 + CLEVIS_THK),
                   -CLEVIS_Y/2,
                   -BLOCK_D/2 - CLEVIS_Z_LEN + 0.5])
          cube([CLEVIS_THK, CLEVIS_Y, CLEVIS_Z_LEN]);
    }

    // Lead screw bore (along X)
    translate([-BLOCK_W/2 - 1, 0, 0])
      rotate([0, 90, 0])
        cylinder(h = BLOCK_W + 2, d = LEAD_SCREW_D + 2);

    // Prusa nut flange pocket (counterbore on +X face)
    translate([BLOCK_W/2 - PRUSA_NUT_FLANGE_THK - 0.5, 0, 0])
      rotate([0, 90, 0])
        cylinder(h = PRUSA_NUT_FLANGE_THK + 0.6,
                 d = PRUSA_NUT_FLANGE_D + 0.4);

    // 4× M3 clearance holes on the Ø19 bolt circle (user uses the Z pair)
    for (theta = [0, 90, 180, 270])
      translate([-BLOCK_W/2 - 1,
                 (PRUSA_NUT_BOLT_CIRCLE_D / 2) * cos(theta),
                 (PRUSA_NUT_BOLT_CIRCLE_D / 2) * sin(theta)])
        rotate([0, 90, 0])
          cylinder(h = BLOCK_W + 2, d = PRUSA_NUT_M3_HOLE_D);

    // Ball pocket inside the clevis cavity (so the ball sits between ears,
    // not against block body). Block bottom face stays above the ball.
    // In block frame the ball centre is at Z = BALL_Z - GIMBAL_CTR_Z.
    ball_z_in_block = BALL_Z - GIMBAL_CTR_Z;
    translate([0, 0, ball_z_in_block])
      sphere(d = BALL_D + 1);

    // M5 bolt clearance through both clevis ears + ball
    translate([-(CLEVIS_X_GAP/2 + CLEVIS_THK + 1), 0, ball_z_in_block])
      rotate([0, 90, 0])
        cylinder(h = CLEVIS_X_GAP + 2*CLEVIS_THK + 2, d = CLEVIS_BOLT_D);

    // Anti-roll slot on the block's wall-side face (-Z face).
    // Centred in X at X=0 (between the clevis ears), offset in Y to match
    // the anti-roll pin's Y position. X-oriented so the pin can travel
    // along it as the block pitches/yaws.
    translate([-SLOT_LEN_X/2,
               ANTI_BOSS_Y - SLOT_W_Y/2,
               -BLOCK_D/2 - 0.1])
      cube([SLOT_LEN_X, SLOT_W_Y, SLOT_DEPTH_Z + 0.1]);
  }
}

// ---- sourced-part stand-ins (not exported) ----

module rod_end_stub() {
  color([0.55, 0.55, 0.62]) {
    // Body
    translate([0, 0, BOSS_TOP_Z])
      cylinder(h = ROD_BODY_L, d = ROD_BODY_D);
    // Ball
    translate([0, 0, BALL_Z])
      sphere(d = BALL_D);
  }
}

module ball_bolt_stub() {
  color([0.30, 0.30, 0.32])
    translate([-(CLEVIS_X_GAP/2 + CLEVIS_THK + 2), 0, BALL_Z])
      rotate([0, 90, 0])
        cylinder(h = CLEVIS_X_GAP + 2*CLEVIS_THK + 4, d = 5);
}

module anti_roll_pin_stub() {
  color([0.85, 0.20, 0.20])
    translate([ANTI_BOSS_X, ANTI_BOSS_Y, PLATE_Z_BOT])
      cylinder(h = ANTI_PIN_LEN, d = ANTI_PIN_D);
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
  color([0.95, 0.55, 0.20]) plate();
  translate([0, 0, GIMBAL_CTR_Z]) color([0.85, 0.70, 0.30]) block();
  rod_end_stub();
  ball_bolt_stub();
  anti_roll_pin_stub();
  lead_screw_stub();
  prusa_nut_stub();
} else if (RENDER == "plate") {
  plate();
} else if (RENDER == "block") {
  block();
}
