include <BOSL/constants.scad>
use <BOSL/masks.scad>

// Start config
// Pi Board
pi_board_size = [51,21]; //mm
pi_board_screw_holes_center_from_board_edge_distance = [3.7/2/*3.7 is the difference between screen and pi pcb height 21-24.7 */+4.8,2]; //mm
pi_board_screw_holes_diameter = 2.1; //mm
pi_board_padding = 1; //mm

// Screen
screen_pcb_size = [24.7,27,13.3]; //mm (+- 0.2) 13.3mm are pin headers.
screen_pcb_screw_holes_center_from_board_edge_distance = 2.1; //mm
screen_pcb_screw_holes_diameter=2.8; //mm
screen_pcb_screw_holes_spacing=[20.5,23]; //mm
active_screen_area = [24.7,16.9,3.5]; //mm (old: 13.86)
active_screen_area_offset_from_corner = [0,5.08]; //mm

// Screws
m2_screw_head_size = [4,4,1];


// Misc
walls_thickness = 2; //mm
rounding_radius=1.5; //mm

resolution = 80;
// End config

// Modules
module sector(radius, angles, fn = resolution) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

module arc(radius, angles, width = 1, fn = resolution) {
    difference() {
        sector(radius + width, angles, fn);
        sector(radius, angles, fn);
    }
}

// Modeling
difference(){
// Body
cube(size=[pi_board_size.x+2*pi_board_padding,screen_pcb_size.x+2*pi_board_padding,walls_thickness]);
   // Fillet Edge
    fillet_mask_z(l=walls_thickness, r=rounding_radius, align=V_UP, $fn=resolution);
    
   translate([pi_board_size.x+2*pi_board_padding,screen_pcb_size.x+2*pi_board_padding,0])
    fillet_mask_z(l=walls_thickness, r=rounding_radius, align=V_UP, $fn=resolution);
    
   translate([pi_board_size.x+2*pi_board_padding,0,0]) fillet_mask_z(l=walls_thickness, r=rounding_radius, align=V_UP, $fn=resolution);
    
   translate([0,screen_pcb_size.x+2*pi_board_padding,0]) fillet_mask_z(l=walls_thickness, r=rounding_radius, align=V_UP, $fn=resolution);
    // Screen
    translate([pi_board_size.x/2+screen_pcb_size.x/2+pi_board_padding,screen_pcb_size.x/2+pi_board_padding,0])
    translate([-screen_pcb_size.x,-active_screen_area.y/2,0])
    cube([screen_pcb_size.x,active_screen_area.y,walls_thickness]);
    // Screws + Heads
    translate([pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,0]) cylinder(walls_thickness,pi_board_screw_holes_diameter/2,pi_board_screw_holes_diameter/2,$fn=resolution);
    
    translate([pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,walls_thickness-m2_screw_head_size.z]) cylinder(m2_screw_head_size.z,m2_screw_head_size.x/2,m2_screw_head_size.x/2,$fn=resolution);
    
    translate([pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,screen_pcb_size.x-pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,0]) cylinder(walls_thickness,pi_board_screw_holes_diameter/2,pi_board_screw_holes_diameter/2,$fn=resolution);
    
    translate([pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,screen_pcb_size.x-pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,walls_thickness-m2_screw_head_size.z]) cylinder(m2_screw_head_size.z,m2_screw_head_size.x/2,m2_screw_head_size.x/2,$fn=resolution);
    
    translate([pi_board_size.x-pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,0]) cylinder(walls_thickness,pi_board_screw_holes_diameter/2,pi_board_screw_holes_diameter/2,$fn=resolution);
    
    translate([pi_board_size.x-pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,walls_thickness-m2_screw_head_size.z]) cylinder(m2_screw_head_size.z,m2_screw_head_size.x/2,m2_screw_head_size.x/2,$fn=resolution);
    
    translate([pi_board_size.x-pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,screen_pcb_size.x-pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,0]) cylinder(walls_thickness,pi_board_screw_holes_diameter/2,pi_board_screw_holes_diameter/2,$fn=resolution);
    
    translate([pi_board_size.x-pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,screen_pcb_size.x-pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,walls_thickness-m2_screw_head_size.z]) cylinder(m2_screw_head_size.z,m2_screw_head_size.x/2,m2_screw_head_size.x/2,$fn=resolution);
   }