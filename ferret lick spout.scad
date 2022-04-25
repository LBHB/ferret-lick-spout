$fa = 0.5;
$fs = 0.5;

module IRSensorHousing(
    ir_sensor_length=5.58, width=3.7, ir_sensor_height=6.5,
    ir_sensor_diameter=1.58, set_screw_diameter=2.0,
    ir_sensor_offset=1.72, set_screw_offset=1.72+0.28,
    wall_thickness=2, wire_length=7, cutout_border=3) {

    height = ir_sensor_height + ir_sensor_offset;
    set_screw_height = height - set_screw_offset;

    // Create the sensor cavity
    translate([-ir_sensor_length/2, 0, 0]) {
        cube(size=[ir_sensor_length, width, height]);
        translate([ir_sensor_length/2, 0, ir_sensor_height]) {
            rotate([90, 0, 0]) {            
                cylinder(h=wall_thickness*2, d=ir_sensor_diameter);
            }
        }
        translate([ir_sensor_length/2, width, set_screw_height]) {
            rotate([-90, 0, 0]) {            
                cylinder(h=wall_thickness*2, d=set_screw_diameter);
            }
        }
    }
    
    // Create the wire cavity
    translate([-wire_length/2, 0, 0]) {
        cube(size=[wire_length, width, height-ir_sensor_length]);
        translate([0, -wall_thickness*2, cutout_border]) {
            cube(size=[wire_length, wall_thickness*2, height-ir_sensor_length-cutout_border]);
        }
    }
}


module MainWall(nose_poke_depth, wall_thickness) {
    translate([0, 0, nose_poke_depth/2]) {
        difference() {
            cube(size=[nose_poke_width, nose_poke_width, nose_poke_depth], center=true);
            union() {
                translate([0, 0.1, wall_thickness]) {
                    cube(size=[nose_poke_width-wall_thickness*2, nose_poke_width, nose_poke_depth], center=true);
                }
                translate([.1, -nose_poke_width/2+wall_thickness*2-nose_poke_height, wall_thickness]) {
                    cube(size=[nose_poke_width+.4, nose_poke_width/2, nose_poke_depth], center=true);
                }
                translate([.1, nose_poke_width/2-wall_thickness, wall_thickness]) {
                    cube(size=[nose_poke_width+.4, nose_poke_width/2-nose_poke_height+2, nose_poke_depth], center=true);
                }
            }
        }
    }
}

module LickSpout(nose_poke_depth, lick_spout_depth, lick_spout_od, lick_spout_id) {
    difference () {
        union() {
            tip = nose_poke_depth - lick_spout_depth - lick_spout_od * 0.5;
            cylinder(h=tip, d=lick_spout_od);
            translate([0, 0, tip]) {
                sphere(d=lick_spout_od);
            }
        }
        translate([0, 0, -0.1]) {
            cylinder(h=nose_poke_depth+0.2, d=lick_spout_id);
        }
    }
}

module WaterDrain(nose_poke_depth, nose_poke_radius, wall_thickness, lick_spout_depth) {
    dx = nose_poke_radius - wall_thickness * 0.5 + 10;
    dd = nose_poke_depth;
    d1 = wall_thickness*2;
    difference() {
        union() {
            children();
            rotate([0, -15, 0]) {
                translate([dx-d1/2, -d1/2, 0]) {
                    cube(size=[d1, d1, dd]);
                }
            }
        }
        rotate([0, -20, 0]) {
            translate([dx-2, 0, 0]) {
                cylinder(h=dd*.85, d=d1/2);
            }
        }
    }
}

module Mount(nose_poke_width, support_diameter, wall_thickness, tap_size_quarter_inch) {
    mount_depth = support_diameter + wall_thickness;
    mount_thickness = tap_size_quarter_inch + wall_thickness;

    translate([nose_poke_width * 0.5 - mount_depth, nose_poke_width * 0.5 - wall_thickness, -mount_depth]) 
    difference () {
        cube([mount_depth, mount_thickness, mount_depth]);
        translate([mount_depth * 0.5, mount_thickness+0.1, mount_depth * 0.5]) rotate([90, 0, 0]) cylinder(h=mount_thickness+0.2, d=support_diameter);
        translate([mount_depth * 0.5, mount_thickness * 0.5, -0.1]) cylinder(h=wall_thickness+0.2, d=tap_size_quarter_inch);
    }
}

module Angle(nose_poke_angle) {
    s = tan(nose_poke_angle);
    angle_matrix = [
        [1, 0, 0, 0],
        [0, 1, s, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1]];
    multmatrix(angle_matrix) {
        children();
    }
}

module CatchBasinOutline(front_offset, nose_poke_depth, nose_poke_width, wall_thickness, port_size, port_x, port_y, back) {
    hull() {
        translate([-nose_poke_width / 2, 0, front_offset]) {
            // front lip
            cube(size=[nose_poke_width, wall_thickness, wall_thickness]);
       
            // side walls
            translate([nose_poke_width-wall_thickness, 0, 0]) 
                cube(size=[wall_thickness, wall_thickness, nose_poke_depth-front_offset]);
            cube(size=[wall_thickness, wall_thickness, nose_poke_depth-front_offset]);
        }
        // rear outlet
        translate([port_x, port_y, nose_poke_depth-wall_thickness]) 
            cylinder(h=wall_thickness, d=port_size);
    }
}

module Drain(nose_poke_depth, nose_poke_width, wall_thickness) {
    od = 12.7;
    id = 12.7 / 2;
    port_x = nose_poke_width / 2 - od / 2;
    port_y = nose_poke_depth / 2 - wall_thickness;
    translate([0, 0, -nose_poke_depth]) 
    difference() {
        CatchBasinOutline(0, nose_poke_depth, nose_poke_width, wall_thickness, od, port_x, port_y, false);
        #CatchBasinOutline(0, nose_poke_depth, nose_poke_width-wall_thickness, wall_thickness/2, id, port_x, port_y, false);
    }  
    difference() {
        union() {
            hull() {
                translate([-nose_poke_width/2, 0, -wall_thickness]) cube(size=[nose_poke_width, wall_thickness, wall_thickness]);
                translate([port_x, port_y, -wall_thickness]) cylinder(h=wall_thickness, d=od);
            }
            translate([port_x, port_y, 0]) cylinder(h=12.7, d1=od*1, d2=od*0.8);
        }
        translate([port_x, port_y, -wall_thickness]) cylinder(h=12.7+wall_thickness, d=id);
    }   
}

// UNITS ARE IN MM
nose_poke_depth = 35;
nose_poke_width = 40;
nose_poke_height = 10;

ir_sensor_depth = 3;
wall_thickness = 6;
lick_spout_od = 8;
lick_spout_id = 3;
lick_spout_depth = 6;
nose_poke_angle = 15;
tap_size_quarter_inch = 5.558; // mm
ir_sensor_width = 3.7;

eps = 0.3;
support_diameter = 12.7 + eps * 2;


Mount(nose_poke_width, support_diameter, wall_thickness, tap_size_quarter_inch);
translate([0, nose_poke_width/2, 0]) rotate([0, 180, 0]) Drain(nose_poke_depth, nose_poke_width, wall_thickness);

difference() {
    difference() {
            difference() {
                union() {
                    MainWall(nose_poke_depth, wall_thickness);
                    translate([0, -nose_poke_height, 0]) Angle(nose_poke_angle) {
                        LickSpout(nose_poke_depth, lick_spout_depth, lick_spout_od, lick_spout_id);
                        hull() {
                            cylinder(h=0.1, d=5);
                            translate([0, 0, -10]) cylinder(h=0.1, d=lick_spout_id+0.7*2);
                        }
                    }
                }
                // This is a second cylinder to ream out additional issues with lick spout
                Angle(nose_poke_angle) translate([0, -nose_poke_height, -20]) cylinder(h=nose_poke_depth+20, d=lick_spout_id);
                }
        }
             
        translate([nose_poke_width/2-0.75, 10-nose_poke_height, -0.1]) {
            rotate([0, 0, 90]) {
                IRSensorHousing(
                    ir_sensor_height=nose_poke_depth-ir_sensor_depth+0.1, width=ir_sensor_width
                );
            }
        }
        translate([-(nose_poke_width/2-0.75), 10-nose_poke_height, -0.1]) {
            rotate([0, 0, -90]) {
                IRSensorHousing(
                    ir_sensor_height=nose_poke_depth-ir_sensor_depth+0.1, width=ir_sensor_width
                );
            }
        }
}

