//
// Attract-Mode Front-End - "Robospin Lynx" layout
//
// Based off the "Robospin" layout by omegaman, verion and raygun
// http://forum.attractmode.org/index.php?topic=198.0
// Atari Lynx version by Sean 'shidarin' Wallitsch
// https://github.com/shidarin/robospin_lynx
//
// The MIT License (MIT)
// 
// Copyright (c) 2015 omegaman, verion, raygun, Sean Wallitsch
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

class UserConfig {
    </
        label="SpinWheel",
        help="The artwork to spin",
        options="marquee,flyer,wheel"
    /> orbit_art="wheel";
    </ 
        label="Mask",
        help="Make background darker.",
        options="Yes,No" 
    /> enable_Mask="Yes";
    </
        label="Dusty Screen",
        help="Integrates screen with dust and grain.",
        options="Yes,No"
    /> enable_dust="Yes";
    </
        label="Transition Time",
        help="Time in milliseconds for wheel spin."
    /> transition_ms="25";
}

local my_config = fe.get_config();
local no_shader = fe.add_shader( Shader.Empty );

fe.layout.width=1920;
fe.layout.height=1080;

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
fe.add_image( "bkg.png", 0, 0, flw, flh );

// Mask behind wheel
if ( my_config["enable_Mask"] == "Yes" )
{
local mask = fe.add_image( "mask.png", 0, 0, flw, flx );
}

//Image of screen overlay guide with green for help positioning the artwork
//fe.add_image( "overlay_guide.png", 0, 0, flw, flh );

//box art
local box = fe.add_artwork(
    "flyer", flx*0.05, fly*0.65, flw*0.15625, flh*0.277
);
box.preserve_aspect_ratio = true;

//cart art
local cart = fe.add_artwork(
    "cart", flx*0.23, fly*0.72, flw*0.078125, flh*0.1389
);
cart.preserve_aspect_ratio = true;

//video
local snap = fe.add_artwork( "snap", flx*0.049, fly*0.217, 160*4.1, 102*3.70 );
snap.pinch_x = -11;
snap.pinch_y = 8;
snap.skew_x = 110;
snap.skew_y = -10;
snap.rotation = -10.75;
snap.preserve_aspect_ratio = false;
//Decrease opacity to help with placement
//snap.alpha = 200;

local overlay;
if ( my_config["enable_dust"] == "Yes" )
{
   overlay = "screen_overlay_dusty.png";
}
else
{
   overlay = "screen_overlay.png";
}

//Lynx overlay image
local overlay_image = fe.add_image( overlay, 0, 0, flw, flh );
//Turn off overlay entirely to help with placement
//overlay_image.alpha = 0;

//Wheel settings
fe.load_module( "conveyor" );

local wheel_x = [
    flx*0.80, flx*0.795, flx*0.756, flx*0.725, flx*0.70, flx*0.68, flx*0.5,     
    flx*0.68, flx*0.70, flx*0.725, flx*0.756, flx*0.76,
]; 
local wheel_y = [
    -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.4, 
    fly*0.61, fly*0.72 fly*0.83, fly*0.935, fly*0.99,
];
local wheel_w = [
    flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.35, 
    flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18,
];
local wheel_a = [ 80, 80, 80, 80, 80, 80, 255, 80, 80, 80, 80, 80, ];
local wheel_h = [
    flh*0.11, flh*0.11, flh*0.11, flh*0.11, flh*0.11,  flh*0.11, 
    flh*0.196875, flh*0.11, flh*0.11, flh*0.11, flh*0.11, flh*0.11,
];
local wheel_r = [ 30, 25, 20, 15, 10, 5, 0, -10, -15, -20, -25, -30, ];
local num_arts = 10;

class WheelEntry extends ConveyorSlot
{
    constructor()
    {
        base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
    }

    function on_progress( progress, var )
    {
        local p = progress / 0.1;
        local slot = p.tointeger();
        p -= slot;
        slot++;

        if ( slot < 0 ) slot=0;
        if ( slot >= 10 ) slot=10;

        m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
        m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
        m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
        m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
        m_obj.rotation = wheel_r[slot] + p * (
            wheel_r[slot+1] - wheel_r[slot] 
        );
        m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
        m_obj.preserve_aspect_ratio = true;
    }
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
    wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheel entry created
// is the middle one showing the current selection
// (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
    wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try {
    conveyor.transition_ms = my_config["transition_ms"].tointeger(); 
}
catch ( e ) { }
