$fa = 0.1;
$fs = 0.1;

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
                translate([0, -wall_thickness, wall_thickness]) {
                    cube(size=[nose_poke_width-wall_thickness*2, nose_poke_width, nose_poke_depth], center=true);
                }
                translate([.1, -nose_poke_width/2+wall_thickness, wall_thickness]) {
                    cube(size=[nose_poke_width+.4, nose_poke_width/2, nose_poke_depth], center=true);
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

module AnglePoke(nose_poke_angle) {
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


nose_poke_depth = 35;
nose_poke_width = 35;
ir_sensor_depth = 3.7;
wall_thickness = 6;
lick_spout_od = 6;
lick_spout_id = 1.5;
lick_spout_depth = 10;
nose_poke_angle = 15;
tap_size_quarter_inch = 5.558; // mm
ir_sensor_width = 3.7;


difference() {
    difference() {
        AnglePoke(nose_poke_angle) {
            difference() {
                union() {
                    MainWall(nose_poke_depth, wall_thickness);
                    LickSpout(nose_poke_depth, lick_spout_depth, lick_spout_od, lick_spout_id);
                    translate([0, nose_poke_width/2+wall_thickness, 0]) {
                        hull() {
                            translate([-7.5, -7.5, 0]) {
                                cube([15, 15, 0.1]);
                            }
                            translate([-2.5, -10, nose_poke_depth-.1]) {
                                cube([5, 5, 0.1]);
                            }
                        }
                    }
                    hull() {
                          cylinder(h=0.1, d=5);
                        translate([0, 0, -10]) {
                            cylinder(h=0.1, d=lick_spout_id+0.7*2);
                        }
                    }
                }
                translate([0, 0, -20]) {
                    cylinder(h=nose_poke_depth+20, d=lick_spout_id);
                }
            }
        }
        
        translate([nose_poke_width/4, -7.5, -0.1]) {
           cylinder(h=wall_thickness+0.2, d=tap_size_quarter_inch);
        }
        
        translate([-nose_poke_width/4, -7.5, -0.1]) {
           cylinder(h=wall_thickness+0.2, d=tap_size_quarter_inch);
        }
        
        translate([nose_poke_width/2-0.75, 10, -0.1]) {
            rotate([0, 0, 90]) {
                IRSensorHousing(
                    ir_sensor_height=nose_poke_depth-ir_sensor_depth+0.1, width=ir_sensor_width
                );
            }
        }
        translate([-(nose_poke_width/2-0.75), 10, -0.1]) {
            rotate([0, 0, -90]) {
                IRSensorHousing(
                    ir_sensor_height=nose_poke_depth-ir_sensor_depth+0.1, width=ir_sensor_width
                );
            }
        }
        
        // make the cut-out for the drain
        translate([0, nose_poke_width/2+wall_thickness, -0.1]) {
            hull() {
                cylinder(h=0.1, d=10);
                translate([0, -8.5, nose_poke_depth-lick_spout_depth*0.25]) {
                    cylinder(h=0.1, d=6.5);
                }
            }
        }
        
        translate([0, 20, 17.5]) {
            rotate([90, 0, 0]) {
                scale([1, 2, 1]) {
                    cylinder(h=7, d=7.5);
                }
            }
        }
    }
}