// v2 sash-side motor mount.
//
// L-bracket that bolts to the sash top rail (4× M4 self-tappers, VHB
// tape on the back) and carries the NEMA17 motor (4× M3 in the
// standard 31×31 pattern). The motor's shaft points along the rail,
// toward the frame anchor at the top-middle of the window. From the
// motor's faceplate, the shaft connects to a Ø5–Ø8 universal joint,
// then to the lead screw — both off-bracket.
//
// Coordinate convention (bracket local):
//   X axis: along the lead screw / sash top rail, +X = toward the frame anchor
//   Y axis: vertical (parallel to gravity when installed), +Y = up
//   Z axis: perpendicular to the sash face, +Z = into the room
//
// Origin: at the center of the motor mount wall's +X face (where the
// shaft exits). The motor body sits at X < 0, sash plate at X > 0.
//
// Print orientation: sash plate flat on the bed (Z = 0 side down).
// The motor mount wall rises in print +Z. Floor + gussets under the
// motor body need supports under their X-direction overhangs.
//
// Render:   openscad -o ../stl/sash-motor-mount.stl sash-motor-mount.scad

include <../../cad/common.scad>;

// ---- design parameters ----
PLATE_W           = 150;    // X length of sash mounting plate
PLATE_H           = 60;     // Y height of sash mounting plate
SASH_PLATE_THK    = 5;      // Z thickness of sash plate
WALL_THK          = 6;      // X thickness of motor mount wall
SCREW_INSET_X     = 20;     // M4 self-tapper inset from short edges
SCREW_INSET_Y     = 10;     // M4 self-tapper inset from long edges
GUSSET_T          = 4;      // gusset rib thickness
GUSSET_LEG        = 22;
MOTOR_FLOOR_EXT   = NEMA17_BODY_L + 2;  // floor under motor body in -X

// ---- derived geometry ----
SHAFT_Y           = 0;
FLOOR_TOP_Y       = SHAFT_Y - NEMA17_FACE / 2;       // -21.15: motor sits on floor
FLOOR_BOTTOM_Y    = FLOOR_TOP_Y - SASH_PLATE_THK;    // -26.15: matches plate Z thickness
SHAFT_Z           = -(NEMA17_FACE / 2 + 6);          // motor body in -Z, sash plate at Z=0

// Wall extends a bit above and below the motor face so the M3 holes
// have a few mm of material around them.
WALL_Y_TOP        = SHAFT_Y + NEMA17_FACE / 2 + 4;   // = 25.15
WALL_Y_BOT        = FLOOR_TOP_Y;                     // = -21.15 — joins motor floor
WALL_Z_OUTER      = SHAFT_Z - NEMA17_FACE / 2 - 4;   // -31.15: behind the motor body
WALL_Z_INNER      = 0;                               // toward the sash plate

// Sash plate sits AGAINST the sash room-side face. Plate occupies the
// X range covered by the bracket; the motor body extends in -X beyond
// the plate's -X edge.
SASH_PLATE_X_MIN  = -PLATE_W / 2;
SASH_PLATE_X_MAX  =  PLATE_W / 2;
SASH_PLATE_Z_MAX  = 0;
SASH_PLATE_Z_MIN  = -SASH_PLATE_THK;

// Motor faceplate sits at X = -WALL_THK (against the wall's -X face);
// motor body extends 48 mm further in -X. Shaft exits the wall at X = 0
// and continues another (NEMA17_SHAFT_L - WALL_THK) = 18 mm into open
// air, where the U-joint picks it up.
MOTOR_FACE_X      = -WALL_THK;
MOTOR_BACK_X      = MOTOR_FACE_X - NEMA17_BODY_L;
SHAFT_TIP_X       = MOTOR_FACE_X + NEMA17_SHAFT_L;   // 18

// Small "floor" under the motor body — supports its weight so the
// M3 mounting bolts don't carry the full cantilever moment. Floor
// sits between motor bottom and where the sash plate would be.
FLOOR_Z_MIN       = SHAFT_Z - NEMA17_FACE / 2 - 2;
FLOOR_Z_MAX       = SHAFT_Z + NEMA17_FACE / 2 + 2;
FLOOR_BOT_Y       = FLOOR_TOP_Y - SASH_PLATE_THK;

module sash_motor_mount() {
  difference() {
    union() {
      // Sash plate (against sash room-side face).
      translate([SASH_PLATE_X_MIN, -PLATE_H / 2, SASH_PLATE_Z_MIN])
        cube([PLATE_W, PLATE_H, SASH_PLATE_THK]);

      // Motor mount wall (perpendicular to the screw axis).
      translate([-WALL_THK, WALL_Y_BOT, WALL_Z_OUTER])
        cube([WALL_THK, WALL_Y_TOP - WALL_Y_BOT, WALL_Z_INNER - WALL_Z_OUTER]);

      // Floor under motor body — supports the cantilever weight.
      translate([MOTOR_BACK_X, FLOOR_BOT_Y, FLOOR_Z_MIN])
        cube([MOTOR_FLOOR_EXT, SASH_PLATE_THK, FLOOR_Z_MAX - FLOOR_Z_MIN]);

      // Connector ribs from the motor mount wall down to the sash plate
      // (one above, one below the motor body) so the wall doesn't just
      // cantilever off the plate at one edge.
      for (zsign = [-1, 1]) {
        translate([-WALL_THK,
                   FLOOR_TOP_Y,
                   zsign > 0 ? -GUSSET_T / 2 : -GUSSET_T / 2])
          linear_extrude(GUSSET_T)
            polygon([
              [0, 0],
              [0, -PLATE_H / 2 - FLOOR_TOP_Y + GUSSET_LEG],
              [GUSSET_LEG, 0]]);
      }
    }

    // ---- removals ----

    // M4 self-tapper holes through the sash plate, four corners.
    for (x = [SASH_PLATE_X_MIN + SCREW_INSET_X, SASH_PLATE_X_MAX - SCREW_INSET_X])
      for (y = [-PLATE_H / 2 + SCREW_INSET_Y, PLATE_H / 2 - SCREW_INSET_Y])
        translate([x, y, SASH_PLATE_Z_MIN - 0.1])
          cylinder(h = SASH_PLATE_THK + 0.2, d = M4_HOLE);

    // Motor shaft clearance bore through the wall.
    translate([-WALL_THK - 1, SHAFT_Y, SHAFT_Z])
      rotate([0, 90, 0])
        cylinder(d = NEMA17_BORE_D, h = WALL_THK + 2);

    // 4× M3 motor mount holes (31 × 31 pattern around the shaft).
    for (dy = [-NEMA17_HOLE_SPACING / 2, NEMA17_HOLE_SPACING / 2])
      for (dz = [-NEMA17_HOLE_SPACING / 2, NEMA17_HOLE_SPACING / 2])
        translate([-WALL_THK - 1, SHAFT_Y + dy, SHAFT_Z + dz])
          rotate([0, 90, 0])
            cylinder(d = NEMA17_HOLE_D, h = WALL_THK + 2);
  }
}

sash_motor_mount();
