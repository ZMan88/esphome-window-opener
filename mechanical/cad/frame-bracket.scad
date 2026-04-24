// Fixed-end (frame) bracket.
//
// Mounts on the 20 mm strip of frame face between the sash top and the
// ceiling, with VHB tape + 2 M4 self-tappers into the PVC. Arm extends
// into the room and holds an M6 rod-end threaded into its front face.
//
// The top edge of the plate includes a 2 mm lip (`TAB_H`) that sticks up
// past the plate body. At install the bracket is pushed up until the tab
// compresses slightly against the ceiling — this is an install aid and a
// passive peel-resist, not a primary load path (real peel stress is
// ~140 kPa, well inside VHB's capacity).
//
// Print orientation: flat on the bed, back face (the VHB side) down.
// Recommended filament: PETG or ABS. No supports.
//
// Render:   openscad -o frame-bracket.stl frame-bracket.scad

include <common.scad>;

// -------- dimensions --------
PLATE_H          = 18;   // plate height (fits in the 20 mm strip with 2 mm slack)
TAB_H            = 2;    // ceiling-jam lip above the plate body
ARM_L            = 27;   // arm protrusion into the room (Z direction)
ARM_W            = 20;   // arm width along the sash (X direction)
ARM_H            = 15;   // arm height (Y direction)

SCREW_INSET_X    = 15;   // distance from short edge to M4 centre
SCREW_Y          = PLATE_H / 2;  // M4 centred vertically in plate

// M6 rod-end hole is at the end face of the arm, along Z
ROD_END_CX       = BRACKET_WIDTH / 2;
ROD_END_CY       = PLATE_H / 2;

// -------- the part --------
module frame_bracket() {
  difference() {
    union() {
      // Main plate
      cube([BRACKET_WIDTH, PLATE_H, PLATE_THK]);

      // Ceiling-jam tab running the full 190 mm width
      translate([0, PLATE_H, 0])
        cube([BRACKET_WIDTH, TAB_H, PLATE_THK]);

      // Arm extending from the plate front face into the room
      translate([ROD_END_CX - ARM_W / 2, ROD_END_CY - ARM_H / 2, PLATE_THK])
        cube([ARM_W, ARM_H, ARM_L]);

      // Gusset at the base of the arm (strength where arm meets plate)
      translate([ROD_END_CX - (ARM_W + 4) / 2, 0, PLATE_THK])
        cube([ARM_W + 4, PLATE_H, 2]);
    }

    // --- M4 mounting holes (2, at each short edge) ---
    for (x = [SCREW_INSET_X, BRACKET_WIDTH - SCREW_INSET_X])
      translate([x, SCREW_Y, -0.1])
        cylinder(h = PLATE_THK + 0.2, d = M4_HOLE);

    // --- M6 rod-end hole: blind, through the arm end face (Z direction) ---
    translate([ROD_END_CX, ROD_END_CY, PLATE_THK + 2])
      cylinder(h = ARM_L, d = M6_TAP);

    // --- Bevel the tab's top-front edge so it slides in under the ceiling ---
    translate([-0.1, PLATE_H + TAB_H, PLATE_THK])
      rotate([0, 90, 0])
        linear_extrude(BRACKET_WIDTH + 0.2)
          polygon([[0, 0], [1.2, 0], [0, -1.2]]);
  }
}

frame_bracket();
