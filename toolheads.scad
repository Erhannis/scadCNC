$fn = 80;
H = 25;
ID = 13;
OD = ID + 10;

// This is a hack; I'm supergluing it on the side of a blank AH HECK!  I've been getting x-carriage vs y-carriage backwards this whole time!
difference() {
  union() {
    cylinder(d=OD,h=H,center=true);
    translate([OD/4,0,0]) cube([OD/2,OD,H],center=true);
  }
  cylinder(d=ID,h=1000,center=true);
}