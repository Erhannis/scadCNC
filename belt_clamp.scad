BIG = 1000;

BELT_H = 6;
DBELT_T = 2.2;
TAPER_H = 3;

module beltClamp(l=20,t=15) {
  BLOCK_L = l;
  BLOCK_T = t;
  BLOCK_H = BELT_H+TAPER_H+BLOCK_T/2;
  difference() {
    translate([0,0,-BLOCK_H/2]) cube([BLOCK_L,BLOCK_T,BLOCK_H],center=true);
    translate([0,0,-(BELT_H+TAPER_H)/2]) cube([BLOCK_L,DBELT_T,BELT_H+TAPER_H],center=true);
    translate([0,0,-TAPER_H]) rotate([45,0,0]) translate([-BLOCK_L/2,0,0]) cube([BLOCK_L,BIG,BIG]);
  }
}

beltClamp();