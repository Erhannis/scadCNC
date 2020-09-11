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

union() { // Belt clamp
  DY = -METAL_THICK/2
        + (YC_BELT_INTERVAL/2+YC_X_BELT_OZREAL-(YC_BELT_INTERVAL/2-TAPER_H-BELT_H/2)+YC_MOTOR_OY)
        - (CROSSBAR_SEAT_OY-(CROSSBAR_SY+2*CROSSBAR_SEAT_SLOP)/2);
  DZ = METAL_THICK/2
        + (YC_CLAMP_OZ+8)
        - (CROSSBAR_SEAT_OZ-CROSSBAR_SZ/2+(CROSSBAR_SZ+2*CROSSBAR_SEAT_SLOP)/2);

  //translate([EDGE_LEN,0,0]) cube([1,1,BIG],center=true);
  //translate([EDGE_LEN+DZ,DY,0]) cube([1,1,BIG],center=true);
  difference() {
    BLOCK_T = 2*(DZ-WALL_THICK/2);
    translate([EDGE_LEN+WALL_THICK/2,DY,10]) translate([BLOCK_T/2,0,0]) rotate([0,90,90]) translate([0,0,TAPER_H+BELT_H/2]) beltClamp(t=BLOCK_T,l=50);
    up(8) translate([EDGE_LEN+WALL_THICK/2,0,0]) rotate([0,-45,0]) OZm();
  }
}

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
    // Motor
    translate([-WALL_THICK/2,EDGE_LEN+EDGE_SLOP+WALL_THICK/2,WALL_HEIGHT]) rotate([0,0,90]) mirror([0,1,0])
        difference() {
          nema17_housing(motor_height=MOTOR_HEIGHT, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=false, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS, acenter=[1,1,-1], point_up=false, support=true);
          //TODO Undercut is hardcoded
          translate([0,73.25,-75]) rotate([45,0,0]) OZm();
          translate([25,0,-75]) rotate([0,-45,0]) OZm();
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

//Motor cover
* rotate([0,-90,0]) nema17_housing(motor_height=MOTOR_HEIGHT, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=true, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS, acenter=[1,1,-1], point_up=false, support=false);