// Common parameters for the window-opener brackets.
//
// Units: millimetres. All parts share these values so changes propagate.
// Render with:
//   openscad -o sash-bracket.stl sash-bracket.scad
//   openscad -o frame-bracket.stl frame-bracket.scad

// -------- hole / clearance sizes --------
M4_HOLE      = 4.5;   // self-tapper clearance in PVC
M6_CLEAR     = 6.5;   // clearance for M6 rod-end shank
M6_TAP       = 5.0;   // tap drill for M6 (tap-to-size in post)

// -------- target window --------
// Reference only — used by consumers of these bracket CAD files.
WIN_WIDTH    = 845;
WIN_HEIGHT   = 1325;
D_FROM_HINGE = 120;   // moving-anchor offset from the hinge side

// -------- bracket common --------
BRACKET_WIDTH  = 190;  // along the top rail (X axis in both parts)
PLATE_THK      = 5;    // plate wall thickness
PRINT_CLR      = 0.2;  // generic printer tolerance

// Render resolution — fine enough for holes, cheap enough for iteration.
$fa = 4;
$fs = 0.3;
