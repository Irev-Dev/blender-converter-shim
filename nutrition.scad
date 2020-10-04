use <lib/Round-Anything/polyround.scad>
use <lib/scad-utils/transformations.scad>
use <lib/list-comprehension-demos/skin.scad>

// use the includes below if you aren't using git and submodules and instead have included the three libraries in your library folder
// use <Round-Anything/polyround.scad>
// use <scad-utils/transformations.scad>
// use <list-comprehension-demos/skin.scad>

$fn=150;
polyRoundFn=10;
ID = 96.3;
OD = 98.7;
maxODinsideBlenderCup = 101.2;
necking = 1.8;
lip1Depth = 13;
lip2Depth = 16;
lip2DepthEnd = 19;
lip2OD = 104;
internalLipR=3; // as big as possible

bladeCupToothWidth = 2.2;
bladeCupToothHeight = 2;
toothTurns = 3.1;

jarToothWidth = 4;
jarToothHeight = 1.4;

difference() {
    union() {
        body();
    }
    bladeCupThreadNegative();
    translate([0,0,8])jarThreadNegative();
    taperNegative();
    // translate([0,-250,0])cube([500,500,500], center=true);
}

module taperNegative() {
    rotate_extrude(angle=360, convexity=10)polygon([
        [100,                               0],
        [maxODinsideBlenderCup/2-0.7,       0],
        [maxODinsideBlenderCup/2,           lip2Depth],
        [100,                               lip2Depth]
    ]);
}

module jarThreadNegative() {
    jarThreadProfile = polyRound(mirrorPoints([
        [-0.1,              -jarToothWidth/2-0.5,   0],
        [0,                 -jarToothWidth/2-0.5,   0],
        [0,                 -jarToothWidth/2,       0.2],
        [jarToothHeight,    0,                      0.5]
    ],0,[0,1]),polyRoundFn);
    helixCount = 6;
    for(rotIndex=[0:helixCount-1]) {
        rotate([0,0,rotIndex*360/helixCount])straight_thread(
            section_profile = jarThreadProfile,
            higbee_arc = 0,
            r     = ID/2,
            turns = 1/5,
            pitch = 33, // part of the reason that the pitch is so big is because there are six of them around the jar (most threads are a single helix)
            fn    = $fn
        );
    }
}

module body() {
    // This is basically a shap that would fill the void between the jar and the blade cap if there were no threads
    // We'll cut our threads into this shape on both sides to try and leave as much material on this part as possible
    function bodyWallProfile(extension=0) = [
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
    rotate_extrude(angle = 360, convexity = 10)polygon(polyRound(bodyWallProfile(),polyRoundFn));
    for(rotIndex=[0:2])rotate([0,0,360/3*rotIndex])rotate_extrude(angle = 6, convexity = 10)polygon(polyRound(bodyWallProfile(4),polyRoundFn));
}

module bladeCupThreadNegative() {
    bladeCupThreadProfile = polyRound(mirrorPoints([
        [0.2,                   2,                          0],
        [0,                     2,                          0],
        [0,                     bladeCupToothWidth/2+0.3,   0.3],
        [-bladeCupToothHeight,  bladeCupToothWidth/2,       0.4],
    ],0,[0,0]),polyRoundFn);
    translate([0,0,-2.5])straight_thread(
        section_profile = bladeCupThreadProfile,
        higbee_arc = 20,
        r     = OD/2+bladeCupToothHeight,
        turns = toothTurns,
        pitch = 5,
        fn    = $fn
    );
}

// All the code below this point is from Helge's excellent hackaday post
// https://hackaday.io/page/5252-generating-nice-threads-in-openscad
// I found most other thread libries to be too highlevel and wanted to help you generate standardised threads
// instead of something more bespoke.
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

function lilo_taper(x,N,tapered_fraction) =     min( min( 1, (1.0/tapered_fraction)*(x/N) ), (1/tapered_fraction)*(1-x/N) );
