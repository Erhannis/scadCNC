/*
use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>
include <belt_clamp.scad>
include <common.scad>
*/
// Sorry; I don't feel like carefully extracting all the needed variables
// Just use ! in front of whatever you're trying to print here
include <x_carriage.scad>

$fn = 80;

TP_HEIGHT = ((WALL_THICK/2+EDGE_LEN+EDGE_SLOP-TP_SOCKET_DEPTH)-(B_WIDTH/2+TP_SOCKET_DEPTH)+TP_SOCKET_DEPTH);

// Blank toolplate
module toolplate() {
  rotate([90,0,0]) translate([0,-B_WIDTH/2,0]) union() {
    height = TP_HEIGHT;
    mirror([1,0,0]) translate([0,B_WIDTH/2,0]) cube([TP_THICK,height,WALL_HEIGHT]);
    // Sockets
    translate([0,WALL_THICK/2+EDGE_LEN+EDGE_SLOP-TP_SOCKET_DEPTH,0]) {
      socket(depth=height);
      up(WALL_HEIGHT) mirror([0,0,1]) socket(depth=height);
    }
  }
}

// Bars (print two)
rotate([90,0,0]) union() {
  linear_extrude(height=TP_HEIGHT+2*TP_SOCKET_DEPTH)
    triangle(height=TP_BAR_THICK/2);
  mirror([0,0,1]) translate([-TP_BAR_THICK/2,0,0]) cube([TP_BAR_THICK*1.5,TP_BAR_THICK/2,TP_BAR_THICK/3]);
}


// Pen toolplate
!union() {
  H = TP_HEIGHT;
  ID = 12.85;
  OD = ID + 10;
  toolplate();
  translate([-OD/2-TP_THICK,-WALL_HEIGHT/2,0]) difference() {
    union() {
      cylinder(d=OD,h=H);
      translate([0,-OD/2,0]) cube([OD/2,OD,H]);
    }
    cylinder(d=ID,h=1000,center=true);
  }
}

// Pen test ring
*union() {
  H = 5;
  ID = 12.85;
  OD = ID + 2;
  translate([-OD/2-TP_THICK,-WALL_HEIGHT/2,0]) difference() {
    cylinder(d=OD,h=H);
    cylinder(d=ID,h=1000,center=true);
  }
}