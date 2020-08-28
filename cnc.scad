/**
A carriage, designed for running on angle aluminum.
Currently set up for 8x 686 bearings.
Could probably move opposing bearing to middle and use 6x instead.
Printed at -0.08mm horizontal extrusion (Cura).
*/

use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/BOSL/shapes.scad>
include <params.scad>

$fn=60;
BIG = 1000;
EPS = 1e-8;


METAL_T = 1.5;
METAL_H = 32;
BLOCK_T = 40;

BLOCK_L = 90;
CUTOUT_W = 5*(9/5);

ENDSTOP_SCREW_HOLE_L = BLOCK_T/2;//40;

EXTRA_TOP = 40;








/**
Note that the spacer_h does NOT affect the overall size of the gap!
I.e., if spacer_h gets too big, you won't be able to fit the pulley between the spacers.
*/
module pulley_housing(p_od = 18, p_oh = 8.5, hole_d = 5, brace_w = 30, brace_t = 14.2, dslop = 2, hslop = 1, rim_h=0, rim_t=1, spacer_h = 0.5, spacer_t = 1, cutout = false) {
  if (cutout) {
    teardrop(d=hole_d,h=brace_t*2);
  } else {
    difference() {
      union() {
        translate([0,p_oh+hslop*2+brace_t/2,0]) {
          cmirror([0,0,1]) translate([-brace_w/2,-brace_t/2,(p_od+dslop*2)/2]) skew([0,0,0,-45,0,0])
            cube([brace_w, brace_t, (p_od+dslop*2)*2]);
          cube([brace_w, brace_t, p_od+dslop*2], center=true);
        }
        rotate([-90,0,0]) tube(h=spacer_h, id=hole_d, d=hole_d+spacer_t*2);
        translate([0,p_oh+hslop*2,0]) rotate([90,0,0]) tube(h=spacer_h, id=hole_d, d=hole_d+spacer_t*2);
      }
      OYm();
      translate([0,(p_oh+hslop*2+brace_t)/2,0]) teardrop(d=hole_d,h=p_oh+hslop*2+brace_t);
    }
  }
}

module peg(d, h, taper_d=undef, taper_l=5, double_taper=false) {
  if (taper_d == undef) {
    peg(d=d,h=h,taper_d=d*0.75,taper_l=taper_l,double_taper=double_taper);
  } else {
    if (double_taper) {
      cmirror([0,0,1]) translate([0,0,(h-taper_l*2)/2]) cylinder(h=taper_l,d1=d,d2=taper_d);
    } else {
      translate([0,0,(h-taper_l*2)/2]) cylinder(h=taper_l,d1=d,d2=taper_d);
      mirror([0,0,1]) translate([0,0,(h-taper_l*2)/2]) cylinder(h=taper_l,d=d);
    }
    cylinder(h=h-taper_l*2,d=d,center=true);
  }
}

module corner() {
  difference() {
    union() {
      cmirror([-1,1,0]) translate([-BLOCK_T/2,-BLOCK_T/2,-BLOCK_T/2-EXTRA_TOP]) cube([BLOCK_L+BLOCK_T/2,BLOCK_T,METAL_H+BLOCK_T/2+EXTRA_TOP]);
      rotate([0,0,45]) translate([-BLOCK_T/2,-BLOCK_T/2,-BLOCK_T/2-EXTRA_TOP]) cube([BLOCK_L+BLOCK_T/2,BLOCK_T,METAL_H+BLOCK_T/2+EXTRA_TOP]);
    }
    linear_extrude(height=BIG) {
      channel([0,0],[0,BLOCK_L],d=METAL_T, cap="square");
      channel([0,0],[BLOCK_L,BLOCK_L],d=METAL_T, cap="square");
      channel([0,0],[BLOCK_L,0],d=METAL_T, cap="square");
    }
    difference() { // Cutouts
      union() {
        cmirror([-1,1,0]) difference() {
          translate([BLOCK_L+0.1,0,0]) rotate([0,-90,0]) cylinder($fn=3,d=CUTOUT_W,h=BLOCK_L+CUTOUT_W+1000);
          rotate([0,0,-45]) OXm();
        }
        difference() {
          rotate([0,0,45]) translate([BLOCK_L+0.1,0,0]) rotate([0,-90,0]) cylinder($fn=3,d=CUTOUT_W,h=BLOCK_L+CUTOUT_W+1000);
          OXm();
          OYm();
        }
      }
      OZm();
    }
    translate([BLOCK_L/2,BLOCK_L/2,-(-BLOCK_T/2-EXTRA_TOP)/4]) rotate([0,0,45]) teardrop(d=2.5,h=50);
    OXm([-BLOCK_T/2,0,0]);
    OYm([0,-BLOCK_T/2,0]);
  }
}

motor_height = 39.3;
//rotate([180,0,0])
//mirror([1,0,0]) // Opposite side
union() { // Corner with motor
  difference() {
    corner();
    // Endstop cutout
    translate([BLOCK_L-ENDSTOP_CUTOUT_SX,-BLOCK_T/2,0]) cmirror([0,0,1]) undercut([ENDSTOP_CUTOUT_SX, ENDSTOP_CUTOUT_SY, ENDSTOP_CUTOUT_SZ/2], center=false);
    // Endstop screw holes
    translate([BLOCK_L+ENDSTOP_SCREW_HOLE_DX,-BLOCK_T/2,0]) cmirror([0,0,1]) translate([0,0,ENDSTOP_SCREW_SEPARATION/2]) rotate([-90,0,0]) cylinder(d=ENDSTOP_SCREW_HOLE_D,h=ENDSTOP_SCREW_HOLE_L);
  }
  translate([-BLOCK_T/2,-BLOCK_T/2,-BLOCK_T/2-EXTRA_TOP])
    translate([
      -(2*MOTOR_HOUSING_TOP_THICKNESS+nema_motor_width(17) + 2*MOTOR_HOUSING_SLOP)/2,
      (2*MOTOR_HOUSING_SIDE_THICKNESS+motor_height+ 2*MOTOR_HOUSING_SLOP)/2,
      (2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*MOTOR_HOUSING_SLOP)/2])
    rotate([0,0,180]) nema17_housing(motor_height=motor_height, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=false, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS);
}

// Motor cover
* rotate([0,-90,0]) nema17_housing(motor_height=motor_height, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=true, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS);

//difference() { // For test
//mirror([1,0,0]) // Opposite side
*union() { // Corner with pulley
  difference() {
    corner();
    translate([0,0,(2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*MOTOR_HOUSING_SLOP)/2])
      translate([-BLOCK_T/2,BLOCK_L-BLOCK_T/2,-BLOCK_T/2-EXTRA_TOP])
      rotate([0,0,90]) pulley_housing(cutout=true);
  }
  translate([0,0,(2*MOTOR_HOUSING_SIDE_THICKNESS+nema_motor_width(17) + MOTOR_HOUSING_JOINER_EXTRA_SPACING + 2*MOTOR_HOUSING_SLOP)/2])
    translate([-BLOCK_T/2,BLOCK_L-BLOCK_T/2,-BLOCK_T/2-EXTRA_TOP])
    rotate([0,0,90]) pulley_housing();
}
//OXp(); // For test
//OYm([0,50,0]); // For test
//OZp([0,0,15]); // For test
//} // For test

// Pulley peg - print at high infill and/or shells.  Maybe >75%?  Maybe 100%?
// peg(d=5,h=40,taper_l=1.5);*