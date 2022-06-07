// Start config

// Standoffs
length = 6.5; //mm
diameter = 2+0.4; //mm (m2 + 0.4mm clearance)
wall_thickness = 1;//mm
// Misc
resolution = 100;
// End config

// Modeling
difference(){
    cylinder(length,diameter/2+wall_thickness,diameter/2+wall_thickness,$fn=resolution);
    cylinder(length,diameter/2,diameter/2,$fn=resolution);
   }