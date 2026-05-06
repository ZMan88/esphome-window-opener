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

// -------- KP08 pillow-block bearing (placeholder — verify with calipers) --------
// These vary by manufacturer. Update once measured.
KP08_BASE_L      = 50;     // base footprint length along the bearing axis
KP08_BASE_W      = 25;     // base footprint width perpendicular to the axis
KP08_HOLE_SPACING = 35;    // centre-to-centre between the two M5 mounting holes
KP08_HOLE_D      = 5.2;    // M5 clearance
KP08_BORE_HEIGHT = 17;     // base bottom to bore centre — CRITICAL, sets shaft alignment
KP08_BODY_W      = 21;     // width of the bearing housing along the bearing axis
KP08_TOTAL_H     = 33;     // overall height (top of housing to bottom of base)

// -------- Prusa MK3 brass nut (placeholder — verify with calipers) --------
PRUSA_NUT_FLANGE_D   = 22;     // outer diameter of the flange
PRUSA_NUT_FLANGE_THK = 3.5;    // flange thickness
PRUSA_NUT_BODY_D     = 10.2;   // body diameter (the narrower part below the flange)
PRUSA_NUT_TOTAL_L    = 15;     // tip-to-tip total length
PRUSA_NUT_M3_SPACING = 16;     // M3 hole square-pattern centre-to-centre
PRUSA_NUT_M3_HOLE_D  = 3.4;    // M3 clearance

// -------- LDO 42STH48-1684MAC NEMA17 (standard NEMA17 dimensions) --------
NEMA17_FACE     = 42.3;    // face dimension (square)
NEMA17_BODY_L   = 48;      // body length
NEMA17_HOLE_SPACING = 31;  // M3 mounting-hole pattern (centre-to-centre)
NEMA17_HOLE_D   = 3.4;     // M3 clearance
NEMA17_BORE_D   = 22.5;    // central bore on the front face (for the shaft flange)
NEMA17_SHAFT_D  = 5;       // shaft diameter
NEMA17_SHAFT_L  = 24;      // shaft length

// -------- Coupler --------
COUPLER_OD = 19;
COUPLER_L  = 25;

// -------- Lead screw --------
LEAD_SCREW_D    = 8;       // Tr8x8 outer diameter
LEAD_SCREW_LEAD = 8;       // 8 mm linear travel per revolution

// -------- bracket common --------
BRACKET_WIDTH  = 190;  // along the top rail (X axis in both parts)
PLATE_THK      = 5;    // plate wall thickness
PRINT_CLR      = 0.2;  // generic printer tolerance

// Render resolution — fine enough for holes, cheap enough for iteration.
$fa = 4;
$fs = 0.3;
