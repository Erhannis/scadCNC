/**
An x-carriage, designed for running on angle aluminum, set on a surface.
Printed at -0.08mm horizontal extrusion (Cura).
*/

use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>
include <belt_clamp.scad>
include <common.scad>

$fn=60;

B_WIDTH = 5;
B_BORE = 6;
B_DIAM = 13;

METAL_SIZE = METAL_H+2;
METAL_TOP = METAL_H-METAL_T;

WALL_THICK = METAL_T * 20;
LIP = B_WIDTH*2;
WALL_HEIGHT = WALL_THICK*5;

//TODO Or should it envelop the angle-metal entirely?

SLOT_FREE = 0.6;
SLOT_WIDTH = B_WIDTH+SLOT_FREE;

DUMMY = false;

X_BELT_OZREAL = -2 + METAL_TOP - (-CORNER_BLOCK_T/2-CORNER_EXTRA_TOP + (2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*MOTOR_HOUSING_SLOP)/2); // Initial small slop to account for bottom bearing gap

// Defaults for pulley_housing in cnc.scad
p_oh = 8.5;
hslop = 1;

X_BELT_OXREAL = -(CORNER_BLOCK_T/2 + (p_oh+hslop*2)/2);

X_BELT_OY = X_BELT_OZREAL;
X_BELT_OX = X_BELT_OXREAL;



CLAMP_L = 100;
CLAMP_T = 15;
BLOCK_H = 9+CLAMP_T/2; // The 9 is kinda cheating
BELT_INTERVAL = 11; // or so
BELT_GAP = 17; // or so

CLAMP_OY = -4+BELT_GAP;
CLAMP_OZ = 80;
MOTOR_OY = -(TAPER_H+BELT_H/2);//BLOCK_H/3;


module addons() {
  linear_extrude(height=CLAMP_OZ) {
    EXTRA = 20/3;
    channel([0,METAL_SIZE+WALL_THICK/2],[0,EXTRA+METAL_SIZE+WALL_THICK/2+CLAMP_OY+MOTOR_OY+(2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP)/2],d=WALL_THICK, cap="none");
  }
  
  difference() {
    translate([X_BELT_OX,X_BELT_OY-(BELT_INTERVAL/2-TAPER_H-BELT_H/2),-CLAMP_L/2+CLAMP_OZ])
      difference() {
        union() {
          // Clamp
          rotate([-90,0,0]) rotate([0,0,90]) beltClamp(l=CLAMP_L,t=CLAMP_T);

          // Motor
          translate([-CLAMP_T/2,MOTOR_OY,-motor_height+20])
            translate([
                -(2*MOTOR_HOUSING_TOP_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP)/2,
                0,
                (2*MOTOR_HOUSING_SIDE_THICKNESS+motor_height + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*MOTOR_HOUSING_SLOP)/2
              ])
              rotate([0,0,180]) nema17_housing(motor_height=motor_height, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=false, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS, point_up=true, support=true);

          // Tunnel
          difference() {
            translate([-CLAMP_T/2,MOTOR_OY-(2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP)/2,-CLAMP_L/2]) cube([CLAMP_T+((-CLAMP_T/2-WALL_THICK/2)-X_BELT_OX), 2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP, CLAMP_L]);
            WALL = 2;
            translate([-CLAMP_T/2,0*BELT_INTERVAL,-CLAMP_L/2]) translate([WALL,-BLOCK_H,0]) cube([CLAMP_T-2*WALL, 2*BLOCK_H, CLAMP_L]);
          }
        }
        // Ledge cutoff
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
        channel([0,0],[0,METAL_SIZE],d=METAL_T*2, cap="none");
        channel([0,METAL_SIZE-METAL_T*2],[0,METAL_SIZE],d=METAL_T*2, cap="square");
      }
    }
  }
  // Y-Belt tunnel
  ctranslate([0,BELT_INTERVAL,0])
    translate([0,X_BELT_OY-(BELT_INTERVAL/2-TAPER_H-BELT_H/2)+MOTOR_OY,CLAMP_OZ]) translate([0,-BELT_INTERVAL/2,8]) rotate([0,0,90]) vslot([8,BIG,16.5]);
  
  INSET = -B_DIAM/2-METAL_T/2;
  //TODO Missing motor-side base wall-facing bearings - not sure if room
  mirror([1,0,0]) translate([0,0,WALL_HEIGHT*0.5]) translate([0,METAL_SIZE*0.8,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK*0.75, dummy=DUMMY);
  for (j=[0.3,0.7]) mirror([1,0,0]) translate([0,0,WALL_HEIGHT*j]) translate([0,METAL_SIZE*0.2,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK/2, dummy=DUMMY);
  for (j=[0.3,0.7]) translate([0,0,WALL_HEIGHT*j]) translate([0,METAL_SIZE*0.8,0]) translate([INSET,0,0]) rotate([0,0,90+180]) bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2, access_depth=WALL_THICK*0.75+B_DIAM, dummy=DUMMY);
  for (j=[0.2,0.5,0.8]) translate([0,0,WALL_HEIGHT*j]) translate(-[(WALL_THICK/2-METAL_T*2/2)/2+METAL_T*2/2,0,0]) translate([0,-INSET-METAL_T,0]) rotate([0,0,180]) {
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
CROSSBAR_SOCKET = 10;
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
        down(CROSSBAR_SOCKET) rotate([0,0,-90]) ledge(CROSSBAR_SOCKET,joiner_depth(w=CROSSBAR_SOCKET,h=2*CROSSBAR_SOCKET));
        translate([joiner_depth(w=CROSSBAR_SOCKET,h=2*CROSSBAR_SOCKET),0,0]) rotate([0,0,-90]) half_joiner(h=CROSSBAR_SOCKET*2, w=CROSSBAR_SOCKET);
      }
}

//translate([40+2, CROSSBAR_SEAT_OY+25.5, CROSSBAR_SEAT_OZ-30.6]) rotate([0,0,180])
*rotate([0,-90,0])
union() { // Crossbar seat clip
  JD = joiner_depth(w=CROSSBAR_SOCKET,h=2*CROSSBAR_SOCKET);
  difference() {
    union() {
      up(CROSSBAR_SZ+CROSSBAR_SOCKET) cube([CROSSBAR_SEAT_SX, CROSSBAR_SY/2+CROSSBAR_SOCKET*2.5, CROSSBAR_SEAT_WALL]);
      cube([CROSSBAR_SEAT_SX-JD, CROSSBAR_SOCKET*2.5, CROSSBAR_SZ+CROSSBAR_SOCKET]);
      translate([CROSSBAR_SEAT_SX-JD,CROSSBAR_SOCKET/2,CROSSBAR_SOCKET])
        ctranslate([0,0,CROSSBAR_SOCKET*3])
          ctranslate([0,CROSSBAR_SOCKET*1.5,0]) {
              translate([JD,0,0]) translate([-CROSSBAR_SEAT_SX/2,0,0]) cube([CROSSBAR_SEAT_SX,CROSSBAR_SOCKET,2*CROSSBAR_SOCKET], center=true);
            }
    }
    GAP = 1;
    translate([CROSSBAR_SEAT_SX,0,0])
      ctranslate([0,0,CROSSBAR_SOCKET*3])
        ctranslate([0,CROSSBAR_SOCKET*1.5,0]) {
            translate([-CROSSBAR_SOCKET,0,0]) cube([CROSSBAR_SOCKET,CROSSBAR_SOCKET,CROSSBAR_SOCKET*2]);
            translate([-JD,0,0]) translate([0,-GAP,-GAP]) cube([JD,CROSSBAR_SOCKET+2*GAP,CROSSBAR_SOCKET*2+2*GAP]);
          }
  }
  translate([CROSSBAR_SEAT_SX-JD,CROSSBAR_SOCKET/2,CROSSBAR_SOCKET])
    ctranslate([0,0,CROSSBAR_SOCKET*3])
      ctranslate([0,CROSSBAR_SOCKET*1.5,0]) {
          translate([0,0,0]) rotate([0,0,-90]) half_joiner2(h=CROSSBAR_SOCKET*2, w=CROSSBAR_SOCKET);
        }
}
* difference() { // Test slot
  cube([B_WIDTH*3,B_BORE*1.1,B_DIAM*3],center=true);
  bearingSlot([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5], nub_diam=B_BORE*1.1, nub_stem=SLOT_FREE/2, nub_slope_angle=60, nub_slope_translation=-SLOT_FREE/2);
  //OZp(); // For inspection
}

// Bearing placer
//NOTE: You may want to mess with the z-size.  I added 1mm because it was a little too loose, how I printed it.
* rotate([90,0,0]) bearingPlacer([SLOT_WIDTH,B_DIAM*1.1,B_DIAM*1.5+1],bearing_diam=B_DIAM*1.05);

// Motor cover
* rotate([0,-90,0]) nema17_housing(motor_height=motor_height, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=true, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS);

