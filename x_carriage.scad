/**
An x-carriage, designed for running on angle aluminum, set on a surface.
Printed at -0.08mm horizontal extrusion (Cura).
*/

use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>
use <belt_clamp.scad>
include <params.scad>

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

DUMMY = true;




CLAMP_L = 100;
CLAMP_T = 15;
BLOCK_H = 9+CLAMP_T/2; // The 9 is kinda cheating
BELT_INTERVAL = 11; // or so
BELT_GAP = 17; // or so

CLAMP_OY = -4+BELT_GAP;
CLAMP_OZ = 80;
MOTOR_OY = -BLOCK_H/3;




module addons() {
  linear_extrude(height=CLAMP_OZ) {
    channel([0,METAL_SIZE+WALL_THICK/2],[0,METAL_SIZE+WALL_THICK/2+CLAMP_OY+MOTOR_OY+(2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP)/2],d=WALL_THICK, cap="none");
  }
  
  difference() {
    translate([0,CLAMP_OY,0]) translate([-CLAMP_T/2-WALL_THICK/2,METAL_SIZE+WALL_THICK/2,-CLAMP_L/2+CLAMP_OZ])
      difference() {
        union() {
          rotate([-90,0,0]) rotate([0,0,90]) beltClamp(l=CLAMP_L,t=CLAMP_T);
          
          translate([-CLAMP_T/2,MOTOR_OY,-motor_height+20])
            translate([
                -(2*MOTOR_HOUSING_TOP_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP)/2,
                0,
                (2*MOTOR_HOUSING_SIDE_THICKNESS+motor_height + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*MOTOR_HOUSING_SLOP)/2
              ])
              rotate([0,0,180]) nema17_housing(motor_height=motor_height, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=false, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS, point_up=true, support=true);

          difference() {
            translate([-CLAMP_T/2,MOTOR_OY-(2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP)/2,-50]) cube([CLAMP_T, 2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP, 100]);
            WALL = 2;
            translate([-CLAMP_T/2,0*BELT_INTERVAL,-50]) translate([WALL,-BLOCK_H,0]) cube([CLAMP_T-2*WALL, 2*BLOCK_H, 100]);
          }
        }
        // This cutoff won't print QUITE right, but hopefully good enough
        down(33-(-motor_height+20)) rotate([0,45,0]) OZm([0,0,0]);
      }
    OZm();
  }
}

difference() { // Carriage
  union() {
    addons();
    linear_extrude(height=WALL_HEIGHT) {
      difference() {
        union() {
          channel([0,0],[0,METAL_SIZE],d=WALL_THICK, cap="none");
          channel([0,METAL_SIZE-WALL_THICK/10],[0,METAL_SIZE],d=WALL_THICK, cap="square");
        }
        channel([0,0],[0,METAL_SIZE],d=METAL_THICK*2, cap="none");
        channel([0,METAL_SIZE-METAL_THICK*2],[0,METAL_SIZE],d=METAL_THICK*2, cap="square");
      }
    }
  }
  translate([0,METAL_SIZE+WALL_THICK/2+CLAMP_OY+MOTOR_OY,CLAMP_OZ]) translate([0,-BELT_INTERVAL/2,8]) rotate([0,0,90]) vslot([10,BIG,15]);
  INSET = -B_DIAM/2-METAL_THICK/2;
  //TODO Missing motor-side base wall-facing bearings - not sure if room
  mirror([1,0,0]) translate([0,0,WALL_HEIGHT*0.5]) translate([0,METAL_SIZE*0.8,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK*0.7, dummy=DUMMY);
  for (j=[0.3,0.7]) mirror([1,0,0]) translate([0,0,WALL_HEIGHT*j]) translate([0,METAL_SIZE*0.2,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK/2, dummy=DUMMY);
  for (j=[0.3,0.7]) translate([0,0,WALL_HEIGHT*j]) translate([0,METAL_SIZE*0.8,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK*0.7, dummy=DUMMY);
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

CROSSBAR_SEAT_OY = METAL_SIZE+WALL_THICK/2+CLAMP_OY+MOTOR_OY;
CROSSBAR_SEAT_OZ = CLAMP_OZ-10;
CROSSBAR_SEAT_SX = 20;
CROSSBAR_SEAT_WALL = 5;
CROSSBAR_SY = 25.64;
CROSSBAR_SZ = 25.64;
CROSSBAR_SOCKET = 5;
ENDSTOP_SCREW_HOLE_L = CROSSBAR_SEAT_WALL*3;

union() { // Crossbar seat
  translate([WALL_THICK/2,CROSSBAR_SEAT_OY,CROSSBAR_SEAT_OZ-CROSSBAR_SZ]) rotate([0,0,-90]) ledge(CROSSBAR_SY,CROSSBAR_SEAT_SX);
  translate([WALL_THICK/2,CROSSBAR_SEAT_OY-CROSSBAR_SY/2-CROSSBAR_SEAT_WALL/2,CROSSBAR_SEAT_OZ-CROSSBAR_SZ]) rotate([0,0,-90]) ledge(CROSSBAR_SEAT_WALL,CROSSBAR_SEAT_SX);
  difference() {
    translate([WALL_THICK/2,CROSSBAR_SEAT_OY-CROSSBAR_SY/2-CROSSBAR_SEAT_WALL,CROSSBAR_SEAT_OZ-CROSSBAR_SZ]) cube([CROSSBAR_SEAT_SX,CROSSBAR_SEAT_WALL,CROSSBAR_SZ]);
    // Endstop screw holes
    translate([ENDSTOP_SCREW_HOLE_DX+WALL_THICK/2+CROSSBAR_SEAT_SX,CROSSBAR_SEAT_OY-CROSSBAR_SY/2-ENDSTOP_SCREW_HOLE_L/2-CROSSBAR_SEAT_WALL/2,CROSSBAR_SEAT_OZ-CROSSBAR_SZ/2]) cmirror([0,0,1]) translate([0,0,ENDSTOP_SCREW_SEPARATION/2]) rotate([-90,0,0]) cylinder(d=ENDSTOP_SCREW_HOLE_D,h=ENDSTOP_SCREW_HOLE_L);
  }
  ctranslate([0,0,CROSSBAR_SOCKET*3])
    ctranslate([0,CROSSBAR_SOCKET*1.5,0])
      translate([WALL_THICK/2,CROSSBAR_SEAT_OY+CROSSBAR_SY/2+CROSSBAR_SOCKET/2,CROSSBAR_SEAT_OZ-CROSSBAR_SZ]) {
        down(CROSSBAR_SOCKET) rotate([0,0,-90]) ledge(CROSSBAR_SOCKET,CROSSBAR_SOCKET/3);
        translate([CROSSBAR_SOCKET/3,0,0]) rotate([0,0,-90]) half_joiner(h=CROSSBAR_SOCKET*2, w=CROSSBAR_SOCKET);
      }
}

//translate([40+2, CROSSBAR_SEAT_OY+25.5, CROSSBAR_SEAT_OZ-30.6]) rotate([0,0,180])
*rotate([0,-90,0]) union() { // Crossbar seat clip
  up(CROSSBAR_SZ+CROSSBAR_SOCKET) cube([CROSSBAR_SEAT_SX, CROSSBAR_SY/2+CROSSBAR_SOCKET*2.5, CROSSBAR_SEAT_WALL]);
  difference() {
    cube([CROSSBAR_SEAT_SX, CROSSBAR_SOCKET*2.5, CROSSBAR_SZ+CROSSBAR_SOCKET]);
    translate([CROSSBAR_SEAT_SX,0,0])
      ctranslate([0,0,CROSSBAR_SOCKET*3])
        ctranslate([0,CROSSBAR_SOCKET*1.5,0]) {
            translate([-CROSSBAR_SOCKET,0,0]) cube([CROSSBAR_SOCKET,CROSSBAR_SOCKET,CROSSBAR_SOCKET*2]);
          }
  }
  translate([CROSSBAR_SEAT_SX-CROSSBAR_SOCKET/3,CROSSBAR_SOCKET/2,CROSSBAR_SOCKET])
    ctranslate([0,0,CROSSBAR_SOCKET*3])
      ctranslate([0,CROSSBAR_SOCKET*1.5,0]) {
          translate([CROSSBAR_SOCKET/3,0,0]) rotate([0,0,-90]) half_joiner2(h=CROSSBAR_SOCKET*2, w=CROSSBAR_SOCKET);
        }
}
* difference() { // Test slot
  cube([B_WIDTH*3,B_BORE*1.1,B_DIAM*3],center=true);
  bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2);
  //OZp(); // For inspection
}

// Bearing placer
* rotate([90,0,0]) bearingPlacer([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5],bearing_diam=B_DIAM*1.05);

// Motor cover
* rotate([0,-90,0]) nema17_housing(motor_height=motor_height, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=true, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS);

