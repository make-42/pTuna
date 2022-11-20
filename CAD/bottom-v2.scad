include <BOSL/constants.scad>
include <asanoha.scad>
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

// MEMS Package (HCLGA)
mems_microphone_package_size = [3,4,1.06]; //mm https://cdn-learn.adafruit.com/assets/assets/000/049/977/original/MP34DT01-M.pdf
mems_microphone_position_offset_from_corner = [11.5,pi_board_padding+screen_pcb_size.x/2-mems_microphone_package_size.y/2,0]; //mm
mems_border_size = 0.6; // mm

// Asanoha pattern
asanoha_pattern_size = [40.7,20.35,1]; //mm 
asanoha_pattern_offset_from_corner = [(pi_board_padding+pi_board_screw_holes_diameter)*2,pi_board_padding+screen_pcb_size.x/2-asanoha_pattern_size.y/2,mems_microphone_position_offset_from_corner.z]; //mm


// Screws
m2_screw_nut_size = [5,5,1.6];

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
    // MEMS Package (HCLGA)
    translate(mems_microphone_position_offset_from_corner) cube(size=[mems_microphone_package_size.x,mems_microphone_package_size.y,walls_thickness]);
    // Screws + Nuts
    translate([pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,0]) cylinder(walls_thickness,pi_board_screw_holes_diameter/2,pi_board_screw_holes_diameter/2,$fn=resolution);
    
    translate([pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,walls_thickness-m2_screw_nut_size.z]) cylinder(m2_screw_nut_size.z,m2_screw_nut_size.x/2,m2_screw_nut_size.x/2,$fn=6);
    
    translate([pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,screen_pcb_size.x-pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,0]) cylinder(walls_thickness,pi_board_screw_holes_diameter/2,pi_board_screw_holes_diameter/2,$fn=resolution);
    
    translate([pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,screen_pcb_size.x-pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,walls_thickness-m2_screw_nut_size.z]) cylinder(m2_screw_nut_size.z,m2_screw_nut_size.x/2,m2_screw_nut_size.x/2,$fn=6);
    
    translate([pi_board_size.x-pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,0]) cylinder(walls_thickness,pi_board_screw_holes_diameter/2,pi_board_screw_holes_diameter/2,$fn=resolution);
    
    translate([pi_board_size.x-pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,walls_thickness-m2_screw_nut_size.z]) cylinder(m2_screw_nut_size.z,m2_screw_nut_size.x/2,m2_screw_nut_size.x/2,$fn=6);
    
    translate([pi_board_size.x-pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,screen_pcb_size.x-pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,0]) cylinder(walls_thickness,pi_board_screw_holes_diameter/2,pi_board_screw_holes_diameter/2,$fn=resolution);
    
    translate([pi_board_size.x-pi_board_screw_holes_center_from_board_edge_distance.y+pi_board_padding,screen_pcb_size.x-pi_board_screw_holes_center_from_board_edge_distance.x+pi_board_padding,walls_thickness-m2_screw_nut_size.z]) cylinder(m2_screw_nut_size.z,m2_screw_nut_size.x/2,m2_screw_nut_size.x/2,$fn=6);
    
    translate(asanoha_pattern_offset_from_corner) cube(size=[asanoha_pattern_size.x,asanoha_pattern_size.y,walls_thickness]);

}

difference(){
    union(){
        // MEMS Package (HCLGA)
    translate(asanoha_pattern_offset_from_corner) drawAsanoha();
    translate([mems_microphone_position_offset_from_corner.x-
mems_border_size,mems_microphone_position_offset_from_corner.y-
mems_border_size,mems_microphone_position_offset_from_corner.z]) cube(size=[mems_microphone_package_size.x+mems_border_size*2,mems_microphone_package_size.y+mems_border_size*2,walls_thickness]);
    }
    // MEMS Package (HCLGA)
    translate(mems_microphone_position_offset_from_corner) cube(size=[mems_microphone_package_size.x,mems_microphone_package_size.y,walls_thickness]);
    
    
}