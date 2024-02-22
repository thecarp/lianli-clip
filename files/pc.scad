PC_THICK=1.5;
PC_W=14.5;
PC_D=9.5;
PC_H=13;

PLAY=0.1;

PLUG_H=13;
PLUG_R=2;
PLUG_THICK=1.5;

BAR_W=4;
BAR_H=1;

OVAL_W=5.5;
OVAL_H=9;
OVAL_D=6;
OVAL_CHOP=0.8;
HOLE_R=1;

FOOT_W=13;
FOOT_H=3;
FOOT_D=11;
FOOT_SHIFT=2.5;

LEG_W=3.5;
LEG_H=20;
LEG_HOLE_W=1.5;

PLUG_PIN_DELTA=15;

WING_W=FOOT_W-FOOT_SHIFT;
WING_D=2;

CLIP_W=7;

PRINT="both"; // [pin, plug, both]

/* [Render Options] */
render_fs=.4;
render_fn=0;
render_fa=.4;

// Set Render Options
$fs= ($preview) ? $fs : render_fs;
$fn= ($preview) ? 16 : render_fn;
$fa= ($preview) ? $fa : render_fa;

module plug_body(r,d) {
    translate([0,0,-d/2])
    minkowski() {
        cube([PC_W-r, PLUG_H-r, PC_D+d-.01]);
        cylinder(r=r, h=0.01);
    }

}

module plug_edge() {
    translate([-PC_W/2,-PC_W+PC_THICK+PC_H,0])
    difference() {
        plug_body(PLUG_R,0);
        translate([-PLUG_THICK,-PLUG_THICK,0])
            plug_body(PLUG_R-1,1);
        translate([0,-100,-50])
            cube([100,100,100]);
    }
}

module plug_side() {
    translate([0,BAR_H,-PC_D/2])
    difference() {
        union() {
            plug_edge();
            bar();
            clip1();
            oval_edge();
        }
        translate([-100,-50,-50])
            cube([100,100,100]);
    }
}

module bar() {
    translate([PC_W/2-PLUG_THICK,-1,0])
        cube([BAR_W,BAR_H,PC_D]);
}

module clip1() {
    translate([PC_W/2,PC_THICK,0])
    linear_extrude(height=PC_D)
    polygon(points=[[0,0],[1.5,0],[1.5,2],[0,4]]);
}

module oval_shape(d,d2) {
    translate([0,0,-d2/2])
    scale([1,(OVAL_H+2*d)/(OVAL_W+2*d),1])
        cylinder(r=(OVAL_W+2*d)/2,h=PC_D+d2);
}

module oval() {
    translate([0,-OVAL_H/2+PLUG_H,0])
    difference() {
    	translate([0,0,-OVAL_D/2]) intersection() {
            oval_shape(0,0);
            cube([OVAL_W,OVAL_H-2*OVAL_CHOP,2*OVAL_D], center=true);
        }
        cylinder(r=HOLE_R,h=OVAL_D+.01, center=true);
    }
}

module oval_edge() {
    translate([0,-OVAL_H/2+PLUG_H-PLUG_THICK,0]) {
        intersection() {
            difference() {
                oval_shape(PLUG_THICK,0);
                oval_shape(PLAY,0.1);
            }
            translate([-50,0,0])
            cube([100,100,100]);
        }
    }
    translate([OVAL_W/2+PLUG_THICK,PLUG_H-PLUG_THICK-OVAL_H+1,0]) {
        intersection() {
            cylinder(r=2.6, h=PC_D);
            translate([-100,-50,0])
                cube([100,100,100]);
        }
        translate([-PLUG_THICK,0,0])
            cube([PLUG_THICK,4.5,PC_D]);
    }
}

module plug() {
    plug_side();
    translate([0.01,0,0])
    mirror([1,0,0])
        plug_side();
}

module pin() {
    translate([-FOOT_W/2-FOOT_SHIFT/2,0,-FOOT_D/2])
        cube([FOOT_W,FOOT_H,FOOT_D]);
    
    translate([0,PLUG_PIN_DELTA,0])
        oval();
    
    difference() {
        translate([0,LEG_H/2,0])
            cube([LEG_W,LEG_H,OVAL_D],center=true);
        translate([0,LEG_H/2, 0])
            cube([LEG_HOLE_W,LEG_H,OVAL_D+.02],center=true);
    }

    translate([0,0,-WING_D/2])
        linear_extrude(height=WING_D)
        polygon(points=[[-WING_W/2,FOOT_H],[WING_W/2,FOOT_H],[LEG_W/2,LEG_H],[-LEG_W/2,LEG_H]]);

    translate([FOOT_W/2-FOOT_SHIFT/2,0,-WING_D/2])
    linear_extrude(height=WING_D)
    polygon(points=[[0,FOOT_H/2],[0,FOOT_H],[CLIP_W,FOOT_H],[CLIP_W,FOOT_H/2],[CLIP_W-FOOT_H,0],[CLIP_W-FOOT_H,FOOT_H/2]]);
}

if (PRINT == "both") translate([0,PLUG_PIN_DELTA*2,0]) plug();
if (PRINT == "plug") plug();
if (PRINT == "pin" || PRINT == "both") pin();

