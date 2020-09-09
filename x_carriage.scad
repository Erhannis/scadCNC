/**
A carriage, designed for running on angle aluminum.
Currently set up for 8x 686 bearings.
Could probably move opposing bearing to middle and use 6x instead.
Printed at -0.08mm horizontal extrusion (Cura).
*/

use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/getriebe/Getriebe.scad>
include <belt_clamp.scad>
include <common.scad>

$fn=60;

echo(25.6-18.7);

B_WIDTH = 5;
B_BORE = 6;
B_DIAM = 13;

EDGE_SLOP = 5;
METAL_THICK = 3.33;
EDGE_LEN = 25.64 - METAL_THICK;
THICK_SLOP = 1.5;

WALL_THICK = 26;
LIP = B_WIDTH*2;
WALL_HEIGHT = 110;

SLOT_FREE = 0.6;
SLOT_WIDTH = B_WIDTH+SLOT_FREE;

B_INSET = B_DIAM/2+METAL_THICK/2;

DUMMY = true;

N = 0;
E = 270;
S = 180;
W = 90;

difference() { // Carriage
  union() {
    // Walls
    linear_extrude(height=WALL_HEIGHT)
      difference() {
        union() {
          channel([0,0],[0,EDGE_LEN+EDGE_SLOP],d=WALL_THICK, cap="square");
          channel([0,0],[EDGE_LEN,0],d=WALL_THICK, cap="square");
          channel([EDGE_LEN,0],[EDGE_LEN,EDGE_LEN+EDGE_SLOP],d=WALL_THICK, cap="square");
        }
        channel([0,0],[0,EDGE_LEN+EDGE_SLOP],d=METAL_THICK+THICK_SLOP, cap="square");
        channel([0,0],[EDGE_LEN,0],d=METAL_THICK+THICK_SLOP, cap="square");
        channel([EDGE_LEN,0],[EDGE_LEN,EDGE_LEN+EDGE_SLOP],d=METAL_THICK+THICK_SLOP, cap="square");
      }
    // Sockets
    translate([-WALL_THICK/2,WALL_THICK/2+EDGE_LEN+EDGE_SLOP,0]) {
      socket();
      up(WALL_HEIGHT) mirror([0,0,1]) socket();
    }
    translate([-WALL_THICK/2,B_WIDTH/2,0]) {
      socket();
      up(WALL_HEIGHT) mirror([0,0,1]) socket();
    }
  }
  // They face Y+ by default
  for (i = [
        [E, [-B_INSET, 0, 0.5]],
        [W, [EDGE_LEN+B_INSET, 0, 0.5]],
        [N, [EDGE_LEN/2, -B_INSET, 0.5]],
        [S, [EDGE_LEN/2, B_INSET, 0.15], WALL_THICK*2], [S, [EDGE_LEN/2, B_INSET, 0.85], WALL_THICK*2],
        [W, [B_INSET, EDGE_LEN, 0.27], WALL_THICK*2], [W, [B_INSET, EDGE_LEN, 0.73], WALL_THICK*2],
        [E, [EDGE_LEN-B_INSET, EDGE_LEN, 0.5], WALL_THICK*2],
      ]) {
    translate([i[1][0],i[1][1],i[1][2]*WALL_HEIGHT]) rotate([0,0,i[0]]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.25], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=(i[2] ? i[2] : 5), dummy=DUMMY);
  }
  //OZp([0,0,WALL_HEIGHT*0.85]);
  //OXp([EDGE_LEN/2,0,0]);
}

* difference() { // Test slot
  cube([B_WIDTH*3,B_BORE*1.1,B_DIAM*3],center=true);
  bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.25], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=(i[2] ? i[2] : 5), dummy=DUMMY);
  //OZp(); // For inspection
}

// Bearing placer
* rotate([90,0,0]) bearingPlacer([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.25],bearing_diam=B_DIAM*1.05);

// Bearing shover 1
* rotate([90,0,0]) bearingSlot([SLOT_WIDTH,30,B_DIAM*1.25], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=0, dummy=true);

* union() { // Bearing shover 2
  h=20;
  translate([0,0,h/2]) rotate([90,0,0])
    bearingSlot([SLOT_WIDTH,h,B_DIAM*1.25], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=0, dummy=true);
  cylinder(d=30,h=5);
}

// Motor gear
* difference() {
  SZ = 20;
  stirnrad(modul=1, zahnzahl=19, breite=SZ, bohrung=0, eingriffswinkel=20, schraegungswinkel=0, optimiert=false);
  flattedShaft(h=BIG,r=2.5 + 0.15,center=true);
}