use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>

// Metal

METAL_T = 1.5;
METAL_H = 32;


// ????

CORNER_BLOCK_T = 40;
CORNER_BLOCK_L = 90;
CORNER_EXTRA_TOP = 40;


// Endstop

ENDSTOP_SCREW_HOLE_D = 2;
ENDSTOP_SCREW_SEPARATION = 9.5;
ENDSTOP_CUTOUT_SY = 7;
ENDSTOP_CUTOUT_SZ = 20;
ENDSTOP_CUTOUT_SX = 17;
ENDSTOP_SCREW_HOLE_DX = -ENDSTOP_CUTOUT_SX/2;


// Motors

MOTOR_HOUSING_SLOP = 0.0;
MOTOR_HOUSING_SIDE_THICKNESS = 10;
MOTOR_HOUSING_TOP_THICKNESS = 3.5;
MOTOR_HOUSING_JOINER_EXTRA_SPACING = 10;
motor_height = 39.3;

BIG = 1000;

module nema17_housing(motor_height = 39.3, plug_width = 18, side_thickness = 10, top_thickness = 3.5, slop = 0, joiner_clearance = 0, holes = true, top = false, support = false, point_up = false) {
  NEMA = 17;
  SX = nema_motor_width(NEMA);
  SY0 = motor_height;
  SZ0 = nema_motor_width(NEMA);
  SY = point_up ? SZ0 : SY0;
  SZ = point_up ? SY0 : SZ0;
  THICK = side_thickness;
  
  rotate([0,90,0]) {
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

//nema17_housing(motor_height=motor_height, plug_width=18, slop=MOTOR_HOUSING_SLOP, top=false, side_thickness=MOTOR_HOUSING_SIDE_THICKNESS, top_thickness=MOTOR_HOUSING_TOP_THICKNESS, point_up=true, support=true);