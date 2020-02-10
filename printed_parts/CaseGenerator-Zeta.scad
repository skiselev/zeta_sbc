////////////////////////////////////////////////////////////////////////////////
// Parametric Case Generator for Electronic Projects
// Copyright (C) 2020 Sergey Kiselev
// 
// Inspired by FB Aka Heartman/Hearty 2016 OpenScad Parametric Box
// http://heartygfx.blogspot.com
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Notes:
// The case dimensions are the internal dimensions. The external dimensions
//   are automatically calculated based on the internal dimensions, the wall
//   thickness, and the PCB supports height. The internal height does not include
//   the height of the PCB standoffs
// The origin for the top and the bottom of the case
//   is left/front/bottom of the PCB
// The origin for the front panel is left/0/bottom of the PCB
// The origin for the back panel is right/0/bottom of the PCB. It is mirrored
//   relative to the front panel, so that it can be printed with the face down

// Rendering control. Set respective value to 1 to render the part, or to 0 to
//   skip rendering
top = 1;
bottom = 1;
front = 1;
back = 1;
vent = 1; // Render ventilation holes
standoffs = 0; // Render PCB standoffs
// Project specific - Zeta SBC. Set to 1 to render the front panel with
// a large rectangular cutout for the floppy drive. Set to 0 to render the front
// panel to be used with the Sony MPF920L floppy drive without bezel.
floppy_bezel = 0;

// Project-specific settings
pcb_thick = 1.6;
board_spacing = 15; // distance between two boards (standoffs length)

// Inside dimensions of the case
length = 172.18; // the actual board length 170.18 + front_thick-thick
width = 101.6;
height = (pcb_thick+board_spacing)*2+25.4;
// Middle - indicates the height at which the top/bottom connecting screws
//   are placed
middle = (pcb_thick+board_spacing)*2+5;

// Parameters
// Tolerance - added to the internal dimensions and also to the slots width for
//   the front and the back panels
xy = 0.4; // tolerance for X/Y
z = 0.2; // tolerance for Z
// Resolution for the cylinder shapes (holes, case corners).
//   Indicates the number of rectangular segments per cylinder
r = 60;
// Wall thickness
thick = 2;
// Front panel thickness
front_thick = 4;
// Back panel thickness
back_thick = 2;
// Radius of the corners for the top and the bottom
corner_radius = 2;
// Diameter of the ventilation holes
vent_diameter = 6;
// Spacing of the ventilation holes
vent_y_spacing = 10;
vent_z_spacing = 8.6;
// Standoffs height from the inner side of the bottom of the case to the 
//   bottom of the PCB. To ensure proper front panel fit, it is recommended
//   that the standoffs height would be more than or equal to wall thickenss
standoff_height = 3;
// Standoffs outer diameter
standoff_diameter = 10;
// Ear parameters
// Location (Y/depth) of the mounting ears (relative to the board front)
// and hex nut slot - 0 = no hex nut slot, 1 = hex nut slot
// Zeta - removed two middle ears, and add slot for a hex nut for the back ear?
//ear_params = [[21,0], [21+60,0], [21+90,0], [length-21,1]];
ear_params = [[23,0], [23+60,0], [length-23,1]];
// Standoff parameters 
// Location X,Y relative to front left corner of the PCB
standoff_params = [[(width-94)/2,(front_thick-thick)+31],[(width-94)/2,(front_thick-thick)+31+70],[width-(width-94)/2,(front_thick-thick)+31],[width-(width-94)/2,(front_thick-thick)+31+70]];
// Holes diameter
hole_diameter = 3.2;
// Screw head diameter
head_diameter = 6+xy;
// Mounting ears radius
ears_radius = 10;
// The height of the mounting holes in the ears, relative to the middle line
hole_height = 5;
// Nut slot inside dimensions
nut_width = 5.5;
nut_thick = 1.6;
// Nut slot outside dimensions - Width of the nut slot across corners
nut_slot_width = 8.6;
nut_slot_height = 7.6;
// Top / bottom color
color1 = "Orange";
// Panels color
color2 = "OrangeRed";

// Dimensions calculations
// External width - walls thickness added two times, once for the
//   actual wall, another one for the hinge/connector
ext_width = width+thick*4+xy*2;
// External length - tolernace is added 6 times, twice for each panel slot
//   and once for the tolerance between the wall and the PCB
ext_length = length+thick*4+xy*6;
// External height - thickenss is added 3 times, twice for the wall
//   thickness and once for the panel slot
ext_height = height+standoff_height+thick*3+z*2;
bottom_height = middle-hole_height+standoff_height+thick+z;
top_height = height-middle+hole_height+thick*2+z;

render_case();

module render_case () {
    if (top == 1 || bottom == 1) color (color1) case();
    if (front == 1) {
        color(color2) {
            translate([thick+xy,thick*2+xy-front_thick,thick+z]) {
                front_panel();
            }
        }
    }

    if (back == 1) {
        color(color2) {
            translate([ext_width-(thick+xy),ext_length-(thick*2+xy)+back_thick,thick+z]) rotate([0,0,180]) {
                back_panel();
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Front Panel
module front_panel()
{
    difference() {
        union () {
            translate([0,thick,0]) {
                rounded_box(ext_width-thick*2,thick,ext_height-thick*2);
            }
            translate([thick,thick*2,thick]) {
                rounded_box(ext_width-thick*4,front_thick-thick,ext_height-thick*4);
            }
        }
        translate([thick,thick-0.1,standoff_height]) {
            // Cutout thickness
            cut_thick = front_thick+0.2;
            // Front panel cutouts go here
            // Coordinates are relative to lower left of the PCB
            // 3 mm LED
            led_diameter = 3+xy;
            // SD Card Slot
            sd_width = 24.2+xy*2;
            sd_height = 2.8+xy*2;
            // Reset switch
            sw_width = 4.2+xy*2;
            sw_height = 4.2+xy*2;
            // Floppy bazel
            floppy_width = 101.6+xy*2;
            floppy_height = 25.4+xy*2;
            // Floppy slot
            floppy_slot_width = 90.6+xy*2;
            floppy_slot_height = 4.6+xy*2;
            floppy_slot_z = 17-floppy_slot_height/2;
            // Floppy window
            floppy_window_width = 25+xy*2;
            floppy_window_height = 8+xy*2;
            // Floppy button
            // Teac
            //floppy_led_z = 6;
            //floppy_button_width = 12+xy*2; // Actual width is 11.5
            //floppy_button_height = 6.4+xy*2; // Actual height is 6
            //floppy_button_x = 80.8;
            //floppy_button_z = 6;
            // Sony MPF920-L
            floppy_led_z = 5;
            floppy_button_width = 14.4+xy*2; // Actual width is 14
            floppy_button_height = 5.4+xy*2; // Actual height is 5
            floppy_button_x = 79.3;
            floppy_button_z = 5.5;
            floppy_back_z = 11;
            floppy_back_height = 7;
            // Lower PCB (ParPortProp)
            translate([0.8,0,pcb_thick]) {
                // ParPortProp - LED
                translate([22.695,0,5.08]) {
                    $fn=r;
                    rotate([0,90,90]) cylinder(d=led_diameter,h=cut_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=led_diameter+0.4,h=0.3);  
                }
                // ParPortProp - SD Card Slot
                translate([49.356-sd_width/2,0,-xy]) {
                    rounded_box(sd_width,cut_thick,sd_height,0.2);
                    // beveled edge
                    for (i = [1:-0.2:0.2]) {
                        translate ([-i,0,-i]) {
                            rounded_box(sd_width+i*2,(1-i)+0.1,sd_height+i*2,0.4);
                        }
                    }
                }
            }
            // Upper PCB (Zeta SBC)
            translate([0.8,0,pcb_thick*2+board_spacing]) {
                // Zeta SBC - Reset Switch
                translate([6.185-sw_width/2,0,4-sw_height/2]) {
                    rounded_box(sw_width,cut_thick,sw_height,0.2);
                    // beveled edge
                    translate([-0.2,0,-0.2]) {
                        rounded_box(sw_width+0.4,0.3,sw_height+0.4,0.2);
                    }
                }
                // Zeta SBC - Lower LED
                translate([22.695,0,2.54]) {
                    $fn=r;
                    rotate([0,90,90]) cylinder(d=led_diameter,h=cut_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=led_diameter+0.4,h=0.3);
                }
                // Zeta SBC - Upper LED
                translate([22.695,0,2.54+5.08]) {
                    $fn=r;
                    rotate([0,90,90]) cylinder(d=led_diameter,h=cut_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=led_diameter+0.4,h=0.3);
                }
            }
            // Floppy Drive
            translate([0,0,pcb_thick*2+board_spacing*2]) {
                if (floppy_bezel == 1) {
                    translate([0,0,-xy]) {
                        rounded_box(floppy_width,cut_thick,floppy_height,0.4);
                    }
                } else {
                    // Floppy Drive - LED
                    translate([23.3,0,floppy_led_z]) {
                        $fn=r;
                        rotate([0,90,90]) cylinder(d=led_diameter,h=cut_thick);
                        // beveled edge
                        rotate([0,90,90]) cylinder(d=led_diameter+0.4,h=0.3);
                    }
                    // Floppy Drive - Eject Button
                    translate([floppy_button_x-floppy_button_width/2,0,floppy_button_z-floppy_button_height/2]) {
                        rounded_box(floppy_button_width,cut_thick,floppy_button_height,0.2);
                        // beveled edge
                        translate([-0.2,0,-0.2]) {
                            rounded_box(floppy_button_width+0.4,0.3,floppy_button_height+0.4,0.2);
                        }
                    }
                    // Floppy Drive - Floppy Slot
                    translate([(101.6-floppy_slot_width)/2,0,17-floppy_slot_height/2]) {
                        rounded_box(floppy_slot_width,cut_thick,floppy_slot_height,0.4);
                        // beveled edge
                        for (i = [1:-0.2:0.2]) {
                            translate ([-i,0,-i]) {
                                rounded_box(floppy_slot_width+i*2,(1-i)+0.1,floppy_slot_height+i*2,0.4);
                            }
                        }
                    }
                    translate([(101.6-floppy_window_width)/2,0,17-floppy_window_height/2]) {
                        rounded_box(floppy_window_width,cut_thick,floppy_window_height,0.4);
                        // beveled edge
                        for (i = [1:-0.2:0.2]) {
                            translate ([-i,0,-i]) {
                                rounded_box(floppy_window_width+i*2,(1-i)+0.1,floppy_window_height+i*2,0.4);
                            }
                        }
                    }
                    // floppy space for the diskette behind the bezel
                    translate([(101.6-floppy_slot_width)/2,thick,floppy_back_z]) {
                        rounded_box(floppy_slot_width,cut_thick-thick,floppy_back_height,0.4);
                    }
                }
            }
            // Text / Logo
            translate ([30,0.5,20]) {
                rotate([90,0,0]) {
                    linear_extrude(height=0.6) {
                        text("Zeta SBC",size=8,font="Bauhaus 93");
                    }
                }
            }
            translate ([45,0.5,10]) {
                rotate([90,0,0]) {
                    linear_extrude(height=0.6) {
                        text("V2",size=8,font="Bauhaus 93");
                    }
                }
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Back Panel
module back_panel()
{
    // Back Panel - settings
    // Cutout thickness
    cut_thick = back_thick+0.2;
    // Back panel cutouts go here
    // Coordinates are relative to lower left of the PCB
    
    // DE-9 / Serial / VGA
    de9_thick = 0.4; // make the panel 0.4 mm thicker around DE9 connectors
    de9_hole_spacing = 24.99;
    de9_width = 19.2+xy*2;
    de9_height = 11.2+xy*2;
    de9_z_offset = 12.55/2;
    serial_x_offset = 17.615;
    vga_x_offset = 83.655;
    //size for rectangular cutout
    //de9_width = 30.81+0.38+xy*2;
    //de9_height = 12.55+0.25+xy*2;
    // PS/2 - Mini DIN Connector
    //size for rectangular cutout
    //din_width = 14+xy*2;
    //din_height = 13+xy*2;
    din_diameter = 13+xy*2;
    din_z_offset = 6.5;
    // DC Connector
    //size for rectangular cutout
    //dc_width = 9+xy*2;
    //dc_height =11+xy*2;
    dc_diameter = 12+xy*2;
    dc_z_offset = 6.5;
    $fn=r;
    difference() {
        // Back Panel - Solid
        union () {
            // Panel
            translate([thick,0,thick]) {
                rounded_box(ext_width-thick*4,back_thick-thick,ext_height-thick*4);
            }
            translate([0,back_thick-thick,0]) {
                rounded_box(ext_width-thick*2,thick,ext_height-thick*2);
            }
            // Panel Add-ons
            translate([thick,thick,standoff_height]) {
                // Lower PCB (ParPortProp)
                translate([0.8,0,pcb_thick]) {
                    translate([serial_x_offset-de9_hole_spacing/2,0,de9_z_offset]) {
                        rotate([0,90,90]) cylinder(d=de9_hole_spacing-de9_width,h=de9_thick);
                    }
                    translate([serial_x_offset+de9_hole_spacing/2,0,de9_z_offset]) {
                        rotate([0,90,90]) cylinder(d=de9_hole_spacing-de9_width,h=de9_thick);
                    }
                    translate([vga_x_offset-de9_hole_spacing/2,0,de9_z_offset]) {
                        rotate([0,90,90]) cylinder(d=de9_hole_spacing-de9_width,h=de9_thick);
                    }
                    translate([vga_x_offset+de9_hole_spacing/2,0,de9_z_offset]) {
                        rotate([0,90,90]) cylinder(d=de9_hole_spacing-de9_width,h=de9_thick);
                    }
                }
                // Upper PCB (Zeta SBC)
                translate([0.8,0,pcb_thick*2+board_spacing]) {
                    translate([serial_x_offset-de9_hole_spacing/2,0,de9_z_offset]) {
                        rotate([0,90,90]) cylinder(d=de9_hole_spacing-de9_width,h=de9_thick);
                    }
                    translate([serial_x_offset+de9_hole_spacing/2,0,de9_z_offset]) {
                        rotate([0,90,90]) cylinder(d=de9_hole_spacing-de9_width,h=de9_thick);
                    }
                }
            }
        }
        // Back Panel - Cut-outs
        translate([thick,-0.1,standoff_height]) {
            // Lower PCB (ParPortProp)
            translate([0.8,0,pcb_thick]) {
                // ParPortProp - Serial Connector
                translate([serial_x_offset-de9_width/2,0,de9_z_offset-de9_height/2]) {
                    rounded_box(de9_width,cut_thick,de9_height,3);
                    // beveled edge
                    translate([-0.2,0,-0.2]) {
                        rounded_box(de9_width+0.4,0.3,de9_height+0.4,3);
                    }
                }
                translate([serial_x_offset-de9_hole_spacing/2,0,de9_z_offset]) {
                    rotate([0,90,90]) cylinder(d=hole_diameter,h=cut_thick+de9_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=hole_diameter+0.4,h=0.3);
                }
                translate([serial_x_offset+de9_hole_spacing/2,0,de9_z_offset]) {
                    rotate([0,90,90]) cylinder(d=hole_diameter,h=cut_thick+de9_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=hole_diameter+0.4,h=0.3);
                }
                // ParPortProp - PS/2 Connector
                translate([50.635,0,din_z_offset]) {
                    rotate([0,90,90]) cylinder(d=din_diameter,h=cut_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=din_diameter+0.4,h=0.3);
                }
                // ParPortProp - VGA Connector
                translate([vga_x_offset-de9_width/2,0,de9_z_offset-de9_height/2]) {
                    rounded_box(de9_width,cut_thick,de9_height,3);
                    // beveled edge
                    translate([-0.2,0,-0.2]) {
                        rounded_box(de9_width+0.4,0.3,de9_height+0.4,3);
                    }
                }
                translate([vga_x_offset-de9_hole_spacing/2,0,de9_z_offset]) {
                    rotate([0,90,90]) cylinder(d=hole_diameter,h=cut_thick+de9_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=hole_diameter+0.4,h=0.3);
                }
                translate([vga_x_offset+de9_hole_spacing/2,0,de9_z_offset]) {
                    rotate([0,90,90]) cylinder(d=hole_diameter,h=cut_thick+de9_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=hole_diameter+0.4,h=0.3);
                }
            }
            // Upper PCB (Zeta SBC)
            translate([0.8,0,pcb_thick*2+board_spacing]) {
                // Zeta SBC - Serial Connector
                translate([serial_x_offset-de9_width/2,0,de9_z_offset-de9_height/2]) {
                    rounded_box(de9_width,cut_thick,de9_height,3);
                    // beveled edge
                    translate([-0.2,0,-0.2]) {
                        rounded_box(de9_width+0.4,0.3,de9_height+0.4,3);
                    }
                }
                translate([serial_x_offset-de9_hole_spacing/2,0,de9_z_offset]) {
                    rotate([0,90,90]) cylinder(d=hole_diameter,h=cut_thick+de9_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=hole_diameter+0.4,h=0.3);
                }
                translate([serial_x_offset+de9_hole_spacing/2,0,de9_z_offset]) {
                    rotate([0,90,90]) cylinder(d=hole_diameter,h=cut_thick+de9_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=hole_diameter+0.4,h=0.3);
                }
                // Zeta SBC - DC Connector
                translate([41.11,0,dc_z_offset]) {
                    rotate([0,90,90]) cylinder(d=dc_diameter,h=cut_thick);
                    // beveled edge
                    rotate([0,90,90]) cylinder(d=dc_diameter+0.4,h=0.3);
                }
            }
            // Text / Logo
            translate ([50,0.5,25]) {
                rotate([90,0,0]) {
                    linear_extrude(height=0.6) {
                        text("5VDC",size=4,font="Arial Black");
                    }
                }
            }
            translate ([51,0.5,20]) {
                rotate([90,0,0]) {
                    linear_extrude(height=0.6) {
                        text("Only",size=4,font="Arial Black");
                    }
                }
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Case
module case()
{
    difference () {
        // build the top and bottom
        union () {
            difference () {
                // outside of the box
                rounded_box(ext_width,ext_length,ext_height);
                union () {
                    if (top == 0) translate([-0.1,-0.1,bottom_height-z]) {
                        // remove the top to the middle line
                        cube([ext_width+0.2,ext_length+0.2,top_height+z+0.1]);
                    }
                    if (bottom == 0) translate([-0.1,-0.1,-0.1]) {
                        // remove the bottom to the middle line
                        cube([ext_width+0.2,ext_length+0.2,bottom_height+0.1]);
                    }

                    // remove the front and the back for the panel slots
                    translate([thick*2,-0.1,thick*2]) {
                        rounded_box(width+xy*2,ext_length+0.2,ext_height-thick*4);
                    }
                    // make the slot for the front panel
                    translate([thick,thick,thick]) {
                        rounded_box(width+thick*2+xy,thick+xy*2,ext_height-thick*2);
                    }
                    // make the slot for the back panel
                    translate([thick,ext_length-thick*2-xy*2,thick]) {
                        rounded_box(width+thick*2+xy,thick+xy*2,ext_height-thick*2);
                    }
                    // remove the middle / inside of the case
                    translate([thick,thick*3+xy*2,thick]) {
                        rounded_box(width+thick*2+xy*2,length-thick*2+xy*2,ext_height-thick*2);
                    }
                }
            }
            if (bottom == 1) {
                // add mounting ears
                for (ear_param = ear_params) {
                    translate ([thick,ear_param[0]+thick*2+xy*3,bottom_height]) mounting_ear(ear_param[1]);
                    translate ([ext_width-thick,ear_param[0]+thick*2+xy*3,bottom_height]) rotate([0,0,180]) mounting_ear(ear_param[1]);
                }
                // add standoffs
                if (standoffs == 1) {
                    for (standoff_param = standoff_params) {
                        translate([standoff_param[0]+thick*2+xy,standoff_param[1]+thick*2+xy*3,thick]) {
                            $fn=r;
                            cylinder(d=standoff_diameter,h=standoff_height);
                        }
                    }
                }
            }
        }
        // make holes in the case
        // side screw holes
        for (ear_param = ear_params) {
            translate ([-0.1,ear_param[0]+thick*2+xy*3,bottom_height+hole_height]) {
                rotate([90,0,90]) {
                    $fn=r;
                    cylinder(d=hole_diameter,h=ext_width+0.2, center=false);
                    cylinder(d1=(head_diameter+0.1),d2=0,h=(head_diameter+0.1)/2);
                }
            }
            translate([ext_width+0.1,ear_param[0]+thick*2+xy*3,bottom_height+hole_height]) {
                    rotate([0,270,0]) {
                    $fn=r;
                    cylinder(d1=(head_diameter+0.1),d2=0,h=(head_diameter+0.1)/2);
                }
            }
        }
        // standoff holes
        if (bottom == 1 && standoffs == 1) {
            for (standoff_param = standoff_params) {
                translate([standoff_param[0]+thick*2+xy,standoff_param[1]+thick*2+xy*3,-0.1]) {
                    $fn=r;
                    cylinder(d=hole_diameter,h=standoff_height+thick+0.2);
                    cylinder(d1=head_diameter,d2=0,h=head_diameter/2);
                }
            }
        }
        // Ventilation Holes
        vent_y_offset = (length%vent_y_spacing)/2;

        // ventilation holes - bottom
        if (bottom == 1) {
            for (z_off = [vent_diameter/2:vent_z_spacing*2:middle-ears_radius-vent_diameter/2]) {
                for (y_off = [vent_y_offset+vent_diameter/2:vent_y_spacing:length-vent_diameter/2-vent_y_offset]) {
                    translate([-0.1,y_off+thick*3+xy*3,z_off+thick+standoff_height+z]) {
                        rotate ([90,90,90]) {
                            $fn=6;
                            cylinder (d=vent_diameter,h=ext_width+0.2,center=false);
                        }
                    }
                }
            }
            for (z_off = [vent_diameter/2+vent_z_spacing:vent_z_spacing*2:middle-ears_radius-vent_diameter/2]) {
                for (y_off = [vent_y_offset+vent_diameter/2+vent_y_spacing/2:vent_y_spacing:length-vent_diameter/2-vent_y_offset]) {
                    translate([-0.1,y_off+thick*3+xy*3,z_off+thick+standoff_height+z]) {
                        rotate ([90,90,90]) {
                            $fn=6;
                            cylinder (d=vent_diameter,h=ext_width+0.2,center=false);
                        }
                    }
                }
            }
        }
        // ventilation holes - top
        if (top == 1) {
            for (z_off = [middle+ears_radius+vent_diameter/2:vent_z_spacing*2:height-corner_radius-vent_diameter/2]) {
                for (y_off = [vent_y_offset+vent_diameter/2:vent_y_spacing:length-vent_diameter/2-vent_y_offset]) {
                    translate([-0.1,y_off+thick*3+xy*3,z_off+thick+standoff_height+z]) {
                        rotate ([90,90,90]) {
                            $fn=6;
                            cylinder (d=vent_diameter,h=ext_width+0.2,center=false);
                        }
                    }
                }
            }
            for (z_off = [middle+ears_radius+vent_diameter/2+vent_z_spacing:vent_z_spacing*2:height-corner_radius-vent_diameter/2]) {
                for (y_off = [vent_y_offset+vent_diameter/2+vent_y_spacing/2:vent_y_spacing:length-vent_diameter/2-vent_y_offset]) {
                    translate([-0.1,y_off+thick*3+xy*3,z_off+thick+standoff_height+z]) {
                        rotate ([90,90,90]) {
                            $fn=6;
                            cylinder (d=vent_diameter,h=ext_width+0.2,center=false);
                        }
                    }
                }
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Mounting ear
module mounting_ear (nut_slot=1)
{
    rotate([90,0,90]) {
        difference () {
            $fn=6;
            union () {
                cylinder(r=ears_radius,h=thick,center=false);
                if (nut_slot == 1) {
                    translate([0,hole_height,thick]) {
                        difference () {
                            union () {
                                // nut slot outside
                                translate([-nut_slot_width/2,-nut_slot_height/2,0])
                                    cube([nut_slot_width,nut_slot_height,thick]);
                                // support under nut slot
                                translate([-nut_slot_width/2,-nut_slot_height/2-thick,0])
                                    cube([nut_slot_width,thick,thick]);
                            }
                            // 45 degrees overhang under the support
                            translate([-nut_slot_width/2-0.1,-nut_slot_height+thick/sqrt(2),0]) rotate([45,0,0]) {
                                cube([nut_slot_width+0.2,thick*2,thick*2]);
                            }
                        }
                    }
                }
            }
            translate([-ears_radius,-ears_radius+thick*0.7,0]) rotate([45,0,0]) {
                cube([ears_radius*2,thick*2,thick*2]);
            }
            translate([-ears_radius,-z,0]) {
                cube([ears_radius*2,ears_radius,xy/2]);
            }
            if (nut_slot == 1) {
                translate([-nut_width/2-xy,hole_height-nut_width/2-z,thick*0.6])
                    cube([nut_width+xy*2,ears_radius-hole_height+nut_width+z*2,nut_thick+xy]);
            }
        }
    }
}


////////////////////////////////////////////////////////////////////////////////
// Rounded Box
module rounded_box(w,l,h,cr=corner_radius)
{
    $fn=r;
    translate([cr,0,cr]) {
        minkowski () {
            cube ([w-cr*2,l/2,h-cr*2]);
            rotate ([-90,0,0]) {
                cylinder(r=cr,h=l/2,center=false);
            }
        }
    }
}