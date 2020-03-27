/**
An x-carriage, designed for running on angle aluminum, set on a surface.
Printed at -0.08mm horizontal extrusion (Cura).
*/

use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>

$fn=60;

B_WIDTH = 5;
B_BORE = 6;
B_DIAM = 13;

METAL_SIZE = 32+5;
METAL_THICK = 1.5;

WALL_THICK = METAL_THICK * 20;
LIP = B_WIDTH*2;
WALL_HEIGHT = WALL_THICK*5;

//TODO Or should it envelop the angle-metal entirely?

SLOT_FREE = 0.6;
SLOT_WIDTH = B_WIDTH+SLOT_FREE;

DUMMY = false;

difference() { // Carriage
  linear_extrude(height=WALL_HEIGHT)
    difference() {
      union() {
        channel([0,0],[0,METAL_SIZE],d=WALL_THICK, cap="none");
        channel([0,METAL_SIZE-WALL_THICK/10],[0,METAL_SIZE],d=WALL_THICK, cap="square");
      }
      channel([0,0],[0,METAL_SIZE],d=METAL_THICK*2, cap="none");
      channel([0,METAL_SIZE-METAL_THICK*2],[0,METAL_SIZE],d=METAL_THICK*2, cap="square");
    }
  INSET = -B_DIAM/2-METAL_THICK/2;
  mirror([1,0,0]) translate([0,0,WALL_HEIGHT*0.5]) translate([0,METAL_SIZE*0.8,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK, dummy=DUMMY);
  for (j=[0.3,0.7]) mirror([1,0,0]) translate([0,0,WALL_HEIGHT*j]) translate([0,METAL_SIZE*0.2,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK, dummy=DUMMY);
  for (j=[0.3,0.7]) translate([0,0,WALL_HEIGHT*j]) translate([0,METAL_SIZE*0.8,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK, dummy=DUMMY);
  for (j=[0.2,0.5,0.8]) translate([0,0,WALL_HEIGHT*j]) translate(-[(WALL_THICK/2-METAL_THICK*2/2)/2+METAL_THICK*2/2,0,0]) translate([0,-INSET-METAL_THICK,0]) rotate([0,0,180]) {
    bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, dummy=DUMMY);
    translate([0,-B_DIAM*0.8,0]) {
      bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, dummy=true);
      OZ = B_DIAM*1.5/2+SLOT_WIDTH/2;
      SX = 10;
      cmirror([0,0,1]) translate([0,-B_DIAM*1.1/2,OZ]) rotate([0,45,0]) cube([SX*sqrt(2),B_DIAM*1.1,SX*sqrt(2)]);
      translate([SX,0,0]) cube([SX*2,B_DIAM*1.1,B_DIAM*1.5+SLOT_WIDTH],center=true);
    }
  }
}

* difference() { // Test slot
  cube([B_WIDTH*3,B_BORE*1.1,B_DIAM*3],center=true);
  bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2);
  //OZp(); // For inspection
}

// Bearing placer
* rotate([90,0,0]) bearingPlacer([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5],bearing_diam=B_DIAM*1.05);