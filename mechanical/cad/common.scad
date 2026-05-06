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

// -------- KP08 pillow-block bearing (measured 2026-05-06) --------
// Caliper readings: 54 (base length), 30 (body width along axis),
//                   47 (across mounting holes outer-to-outer),
//                   12.1 (width of one foot at the mounting hole),
//                   10.8 / 10.7 (bore region — uncertain),
//                   7.6 (slot length dimension),
//                   1.8 (uncertain — possibly wall thickness).
KP08_BASE_L      = 54;        // measured
KP08_BASE_W      = 21;        // not directly measured — KP08 standard width through bearing centre
KP08_HOLE_SPACING = 39;       // c-to-c, derived from outer-to-outer (47) − slot length (~8) ≈ 39 mm
KP08_HOLE_D      = 6.5;       // M5 slot clearance + a hair
KP08_HOLE_SLOT_L = 8;         // slot length (allows lateral adjustment)
KP08_BORE_HEIGHT = 17;        // base bottom → bore centre — CRITICAL, KP08 standard, NOT directly measured
KP08_BODY_W      = 30;        // measured — width along bearing axis
KP08_TOTAL_H     = 33;        // KP08 standard, not directly measured

// -------- Prusa MK3 brass nut (measured 2026-05-06) --------
// Caliper readings: 14.7 (total length), 19.0 (flange OD), 9.0 (body length),
//                   12.1 (M3 hole spacing across opposite holes).
PRUSA_NUT_FLANGE_D   = 19;       // measured — flange OD
PRUSA_NUT_FLANGE_THK = 5.7;      // derived from total (14.7) − body length (9.0)
PRUSA_NUT_BODY_D     = 10.2;     // not directly measured — Prusa MK3 standard
PRUSA_NUT_TOTAL_L    = 14.7;     // measured
PRUSA_NUT_M3_SPACING = 12.1;     // measured — across opposite M3 holes (square pattern)
PRUSA_NUT_M3_HOLE_D  = 3.4;      // M3 clearance

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
