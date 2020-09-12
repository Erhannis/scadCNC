use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/erhannisScad/misc.scad>
include <belt_clamp.scad>

// Metal

METAL_T = 1.5;
METAL_H = 32;
METAL_SIZE = METAL_H+2;
METAL_TOP = METAL_H-METAL_T;


// Toolplate
TP_THICK = 5;
TP_BAR_THICK = 16; // Across base
TP_SOCKET_DEPTH = 8;
TP_SOCKET_THICK = 6; // Rough measurement

module socket(depth=TP_SOCKET_DEPTH,center=false) {
  translate([0,0,(TP_BAR_THICK+2*TP_SOCKET_THICK)/2+TP_THICK]) rotate([0,0,90]) rotate([0,-90,0]) {
    linear_extrude(height=depth, center=center) {
      difference() {
        triangle(height=(TP_BAR_THICK+2*TP_SOCKET_THICK)/2+TP_THICK);
        translate([0,TP_THICK,0]) triangle(height=TP_BAR_THICK/2);
      }
    }
  }
}


// ????

CORNER_BLOCK_T = 40;
CORNER_BLOCK_L = 90;
CORNER_EXTRA_TOP = 40;

PULLEY_OD = 18;
PULLEY_OH = 8.5;
PULLEY_HOLE_D = 5;


// Endstop

ENDSTOP_SCREW_HOLE_D = 2;
ENDSTOP_SCREW_SEPARATION = 9.5;
ENDSTOP_CUTOUT_SY = 7;
ENDSTOP_CUTOUT_SZ = 20;
ENDSTOP_CUTOUT_SX = 27;
ENDSTOP_SCREW_HOLE_DX = -8.5;


// Motors

MOTOR_HOUSING_SLOP = 0.0;
MOTOR_HOUSING_SIDE_THICKNESS = 10;
MOTOR_HOUSING_TOP_THICKNESS = 3.5;
MOTOR_HOUSING_JOINER_EXTRA_SPACING = 10;
MOTOR_HEIGHT = 39.3;


// Y-Carriage
YC_X_BELT_OZREAL = -2 + METAL_TOP - (-CORNER_BLOCK_T/2-CORNER_EXTRA_TOP + (2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*MOTOR_HOUSING_SLOP)/2); // Initial small slop to account for bottom bearing gap

// Defaults for pulley_housing in cnc.scad
YC_HSLOP = 1;

YC_X_BELT_OXREAL = -(CORNER_BLOCK_T/2 + (PULLEY_OH+YC_HSLOP*2)/2);

YC_X_BELT_OY = YC_X_BELT_OZREAL;
YC_X_BELT_OX = YC_X_BELT_OXREAL;

YC_CLAMP_L = 100;
YC_CLAMP_T = 15;
YC_BLOCK_H = 9+YC_CLAMP_T/2; // The 9 is kinda cheating
YC_BELT_INTERVAL = 11; // or so
YC_BELT_GAP = 17; // or so

YC_CLAMP_OY = -4+YC_BELT_GAP;
YC_CLAMP_OZ = 80;
YC_MOTOR_OY = -(TAPER_H+BELT_H/2);//BLOCK_H/3;

YC_WALL_THICK = METAL_T * 20;

CROSSBAR_SEAT_OY = METAL_SIZE+YC_WALL_THICK/2+YC_CLAMP_OY+YC_MOTOR_OY;
CROSSBAR_SEAT_OZ = YC_CLAMP_OZ-10;
CROSSBAR_SEAT_SX = 20;
CROSSBAR_SEAT_WALL = 5;
CROSSBAR_SY = 25.64;
CROSSBAR_SZ = 25.64;
CROSSBAR_SOCKET = 10;
CROSSBAR_SEAT_SLOP = 0.2;


BIG = 1000;

/**
//TODO `acenter` is a bit weird, but the -1/1 thing works nicely....
acenter = [0,0,0]
  Whether to center along each of the given axes.  0 is centered on motor, positive is face-flush against the 0-plane for that axis occupying the positive side, negative is likewise but occupying the negative side.
*/
module nema17_housing(motor_height = 39.3, plug_width = 18, side_thickness = 10, top_thickness = 3.5, slop = 0, joiner_clearance = 0, holes = true, acenter = [0,0,0], top = false, support = false, point_up = false) {
  NEMA = 17;
  SX = nema_motor_width(NEMA);
  SY0 = motor_height;
  SZ0 = nema_motor_width(NEMA);
  SY = point_up ? SZ0 : SY0;
  SZ = point_up ? SY0 : SZ0;
  THICK = side_thickness;
  
  rotate([0,90,0]) translate([
    !acenter[2] ? 0 : -sign(acenter[2])*(2*THICK+SZ + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*slop)/2,
    !acenter[1] ? 0 : sign(acenter[1])*(2*THICK+SY + 2*slop)/2,
    !acenter[0] ? 0 : sign(acenter[0])*(2*top_thickness+SX + 2*slop)/2
  ]) {
    difference() {
      union() {
        cube([2*THICK+SZ + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*slop, 2*THICK+SY + 2*slop, 2*top_thickness+SX + 2*slop], center=true);
        if (support) {
          translate([BIG/2,0,0]) cube([BIG, 2*THICK+SY + 2*slop, 2*top_thickness+SX + 2*slop], center=true);
        }
      }
      if (top) {
        // Plug hole
        if (point_up) {
          translate([(SZ+2*slop)/4,0,-BIG/2]) cube([(SZ+2*slop)/2, plug_width+2*slop, BIG], center=true);
        } else {
          translate([0,(SY+2*slop)/4,-BIG/2]) cube([plug_width+2*slop, (SY+2*slop)/2, BIG], center=true);
        }
      } else {
        // Overhang removal
        translate([-BIG/2,0,0]) cube([BIG, SY+2*slop, SX+2*slop], center=true);
      }
      HOLE = 1;
      if (HOLE == 0) {
        cube([SZ-2*THICK+2*slop, SY-2*THICK+2*slop, BIG], center=true);
      } else if (HOLE == 1) {
        rotate([0,0,45]) cube([nema_motor_plinth_diam(NEMA)+2*slop+THICK/2, nema_motor_plinth_diam(NEMA)+2*slop+THICK/2, BIG], center=true);
      } else if (HOLE == 2) {
        cylinder(d=nema_motor_plinth_diam(NEMA)+2*slop+THICK/2, h=BIG, center=true);
      } else if (HOLE == 3) {
        union() {
          cylinder(d=nema_motor_plinth_diam(NEMA)+2*slop+THICK/2, h=BIG, center=true);
          intersection() {
            rotate([0,0,45]) cube([nema_motor_plinth_diam(NEMA)+2*slop+THICK/2, nema_motor_plinth_diam(NEMA)+2*slop+THICK/2, BIG], center=true);
            cube([BIG, (nema_motor_plinth_diam(NEMA)+2*slop+THICK/2) / sqrt(2), BIG], center=true);
          }
        }
      }
      cube([SZ+2*slop, SY+2*slop, SX+2*slop], center=true);
      
      for (j = [0,1]) {
        mirror([j?1:0,0,0])
        for (i = [1,3]) {
          rotate([0,0,i*90])
            translate([SY/2 + THICK/2  + slop,-SZ/2 - MOTOR_HOUSING_JOINER_EXTRA_SPACING/2 - slop,0])
              translate([0,0,-THICK/2])
                cube([THICK, 2*THICK, THICK], center=true);
        }
      }
      
      translate([-BIG/2, -BIG/2, 0])
        cube(BIG);
      cube(BIG);
     
     rotate([0,0,point_up ? 90 : 0]) 
       rotate([90,45,0]) cube([nema_motor_plinth_diam(NEMA)+2*slop,nema_motor_plinth_diam(NEMA)+2*slop,BIG],center=true);
    }

    for (j = [0,1]) {
      mirror([j?1:0,0,0])
      for (i = [1,3]) {
        rotate([0,0,i*90])
          translate([SY/2 + THICK/2 + slop,-SZ/2 - MOTOR_HOUSING_JOINER_EXTRA_SPACING/2 - slop,0])
            rotate([90,0,0])
              if (top)
                half_joiner2(h=THICK*2, w=THICK);
              else
                half_joiner(h=THICK*2, w=THICK);
      }
    }
  }
}
//nema17_housing(motor_height=MOTOR_HEIGHT, plug_width=18, slop=MOTOR_HOUSING_SLOP, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS, acenter=[1,0,0], top=false, point_up=false, support=false);