include <lib/round-anything/polyround.scad>
use <scad-utils/transformations.scad>
use <list-comprehension-demos/skin.scad>



$fn=150;
pfn=10;
ID = 96.3;
OD = 98.7;
maxODinsideBlenderCup = 101.2;
necking = 1.8;
lip1Depth = 13;
lip2Depth = 16;
lip2DepthEnd = 19;
lip2OD = 104;
internalLipR=3; // as big as possible

toothWidth = 2.2;
toothHeight = 2;
toothTurns = 3.1;

insideToothWidth = 4;
insideToothHeight = 1.4;
insideToothTurns = 2.5;

difference() {
    union() {
        body();
    }
    outsideThreadNegative();
    translate([0,0,8])insideThreadNegative();
    // translate([0,-250,0])cube([500,500,500], center=true);
}


module insideThreadNegative() {
    insideToothProfile = polyRound(mirrorPoints([
        [-0.1,insideToothWidth/2-2,0],
        [0,-insideToothWidth/2-2,0],
        [0,-insideToothWidth/2,0.2],
        [insideToothHeight, 0, 0.5]
    ],0,[0,1]),pfn);
    for(rotIndex=[0:5]) {
        rotate([0,0,rotIndex*60])straight_thread(
            section_profile = insideToothProfile,
            higbee_arc = 0,
            r     = ID/2,
            turns = 1/5,
            pitch = 33,
            fn    = $fn
        );
    }
}


module body() {
    rotate_extrude(angle = 360, convexity = 10)polygon(polyRound(sick(),pfn));
    for(rotIndex=[0:2])rotate([0,0,360/3*rotIndex])rotate_extrude(angle = 6, convexity = 10)polygon(polyRound(sick(4),pfn));

}

function sick(extension=0) = [
    [maxODinsideBlenderCup/2,       0,                  0],
    [maxODinsideBlenderCup/2,       lip2Depth,          0],
    [lip2OD/2+extension,            lip2Depth,          0],
    [lip2OD/2+extension,            lip2DepthEnd,       3],
    [lip2OD/2+7+extension,          lip2DepthEnd+10,    extension/2],
    [lip2OD/2+4,                    lip2DepthEnd+10,    extension],
    [ID/2+necking,                  lip2DepthEnd,       4],
    [ID/2+necking,                  lip1Depth,          internalLipR],
    [ID/2,                          lip1Depth,          0],
    [ID/2,                          0,                  0],
];

module outsideThreadNegative() {
    toothProfile = polyRound(mirrorPoints([
        [0.2,           2,                  0],
        [0,             2,                  0],
        [0,             toothWidth/2+0.3,   0.3],
        [-toothHeight,  toothWidth/2,       0.4],
    ],0,[0,0]),pfn);
    difference() {
        translate([0,0,-2.5])straight_thread(
            section_profile = toothProfile,
            higbee_arc = 20,
            r     = OD/2+toothHeight,
            turns = toothTurns,
            pitch = 5,
            fn    = $fn
        );
        translate([0,0,-5])cube([100,100,10], center=true);
    }

}







module straight_thread(section_profile, pitch = 4, turns = 3, r=10, higbee_arc=45, fn=120)
{
	$fn = fn;
	steps = turns*$fn;
	thing =  [ for (i=[0:steps])
		transform(
			rotation([0, 0, 360*i/$fn - 90])*
			translation([0, r, pitch*i/$fn])*
			rotation([90,0,0])*
			rotation([0,90,0])*
			scaling([0.01+0.99*
			lilo_taper(i/turns,steps/turns,(higbee_arc/360)/turns),1,1]),
			section_profile
			)
		];
	skin(thing);
}
// radial scaling function for tapered lead-in and lead-out
function lilo_taper(x,N,tapered_fraction) =     min( min( 1, (1.0/tapered_fraction)*(x/N) ), (1/tapered_fraction)*(1-x/N) )
;
