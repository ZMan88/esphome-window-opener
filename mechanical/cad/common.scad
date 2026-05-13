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

// -------- KP08 pillow-block bearing (per grema3d datasheet, 2026-05-13) --------
// Datasheet variable names (KP08 column, shaft d = 8 mm):
//   L  = 55  total base width PERPENDICULAR to bore
//   A  = 13  body width ALONG bore (the bearing axis)
//   J  = 42  bolt-hole spacing (c-to-c)
//   N  = 5   bolt-hole diameter (M5)
//   H  = 14  base bottom → bore centre  (CRITICAL — was 17 in earlier guess)
//   H1 = 5   base thickness
//   H2 = 28  total height
//
// SCAD variable names retained for backwards-compat with rig-*.scad files,
// but their MEANINGS are now spec-driven, not measured-guess:
//   KP08_BASE_L      → L  (along Y, perpendicular to lead screw)
//   KP08_BASE_W      → A  (along X, along lead screw)
//   KP08_HOLE_SPACING → J
//   KP08_HOLE_D       → N (M5 clearance)
//   KP08_BORE_HEIGHT  → H
//   KP08_BODY_W       → body width along Y (perpendicular to bore)
//   KP08_TOTAL_H      → H2
KP08_BASE_L       = 55;       // L — base width perpendicular to bore
KP08_BASE_W       = 13;       // A — width ALONG bore axis (NB: lead screw direction)
KP08_HOLE_SPACING = 42;       // J — bolt-hole c-to-c
KP08_HOLE_D       = 5.5;      // M5 clearance (N = 5 mm bolt, + a hair)
KP08_HOLE_SLOT_L  = 8;        // slot length (legacy; some KP08s have slotted holes)
KP08_BORE_HEIGHT  = 14;       // H — base bottom to bore centre
KP08_BODY_W       = 30;       // approximate body width perpendicular to bore
KP08_TOTAL_H      = 28;       // H2 — total height

// -------- Prusa MK3 brass nut (per piese3d datasheet, 2026-05-13) --------
// Datasheet (Tr8x8 brass nut for MK3):
//   Flange OD      = 25       (was incorrectly measured as 19 — 19 is the
//                              bolt-hole *circle* diameter, not the flange OD)
//   Flange thk     = 4
//   Body OD        = 10
//   Body length    = 10
//   Total length   = 14       (= flange thk + body length)
//   Bolt circle    = Ø19      with 4 holes at 90°: 2× M3 threaded
//                              (vertically opposed) + 2× Ø4.1 clearance
//                              (horizontally opposed)
PRUSA_NUT_FLANGE_D       = 25;     // outer flange OD
PRUSA_NUT_FLANGE_THK     = 4;
PRUSA_NUT_BODY_D         = 10;
PRUSA_NUT_BODY_L         = 10;
PRUSA_NUT_TOTAL_L        = PRUSA_NUT_FLANGE_THK + PRUSA_NUT_BODY_L; // 14
PRUSA_NUT_BOLT_CIRCLE_D  = 19;     // diameter on which the 4 holes sit
PRUSA_NUT_M3_HOLE_D      = 3.4;    // M3 clearance (for the carriage side)
PRUSA_NUT_CLEAR_HOLE_D   = 4.1;    // the 2× Ø4.1 holes in the nut flange

// Legacy alias retained so existing rig-carriage.scad keeps compiling.
// Square-pattern spacing equivalent to the 19 mm bolt circle (diagonal 19,
// side = 19/√2 ≈ 13.43). Update rig-carriage.scad to use BOLT_CIRCLE_D for
// the correct alternating-hole pattern; this approximation gets close.
PRUSA_NUT_M3_SPACING     = 13.43;

// -------- LDO 42STH48-1684MAC NEMA17 (per LDO datasheet, 2026-05-13) --------
// Per the official LDO drawing (kb-3d datasheet):
//   Face            42.3 × 42.3 MAX
//   Body length     48 MAX
//   Mounting holes  4× M3 on 31 × 31 mm pattern, depth 4.5 min
//   Pilot boss      Ø22 (-0/-0.052)            ← was 22.5 in earlier guess
//   Shaft           Ø5 -0.002/-0.012, 24 ± 0.5 long
//   Shaft has a 15 mm flat (D-cut), 4.5 mm deep — not modelled here
NEMA17_FACE         = 42.3;
NEMA17_BODY_L       = 48;
NEMA17_HOLE_SPACING = 31;
NEMA17_HOLE_D       = 3.4;     // M3 clearance
NEMA17_HOLE_DEPTH   = 4.5;     // minimum tap depth into the motor face
NEMA17_BORE_D       = 22;      // pilot-boss OD (fits matching counterbore)
NEMA17_SHAFT_D      = 5;
NEMA17_SHAFT_L      = 24;
NEMA17_SHAFT_FLAT_L = 15;      // D-cut flat length, for coupler grip
NEMA17_SHAFT_FLAT_D = 4.5;     // D-cut depth from full Ø

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
