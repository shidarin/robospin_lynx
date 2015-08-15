//
// Attract-Mode Front-End - "Robospin" layout
//
class UserConfig {
   </ label="SpinWheel", help="The artwork to spin", options="marquee,flyer,wheel" />
   orbit_art="wheel";
   </ label="Bloom Effect", help="Enable Bloom Effect (requires shader support)", options="Yes,No" />
   enable_bloom="Yes";
   </ label="Display Flyer", help="Display the flyer/game box in background.", options="Yes,No" /> enable_flyer="No";
   </ label="BlackBG", help="Change color of background.", options="Yes,No" /> enable_BlackBG="No";
   </ label="Mask", help="Make background darker.", options="Yes,No" /> enable_Mask="Yes";
   </ label="Transition Time", help="Time in milliseconds for wheel spin." /> transition_ms="25";
}

local my_config = fe.get_config();
local no_shader = fe.add_shader( Shader.Empty );
local yes_shader;
if ( my_config["enable_bloom"] == "Yes" )
{
   yes_shader = fe.add_shader( Shader.Fragment, "bloom_shader.frag" );
  yes_shader.set_texture_param("bgl_RenderedTexture");
}
else
{
   yes_shader = no_shader;
}

fe.layout.width=1360;
fe.layout.height=768;
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
//fe.layout.font="Roboto-Bold";
fe.add_image( "bkg.png", 0, 0, flw, flh );

//mask
if ( my_config["enable_Mask"] == "Yes" )

{

local mask = fe.add_image( "mask.png", 0, 0, flw, flx );

}


if ( my_config["enable_BlackBG"] == "Yes" )

{

local yes_BlackBG = fe.add_image( "bkg1.png" 0, 0, flw, flh);

}



// Flyer 
if ( my_config["enable_flyer"] == "Yes") 

{
 local flyer = fe.add_artwork( "flyer", 0, 0, flw, flh);
 flyer.preserve_aspect_ratio = false;
}

// Image shadow/outline thickness
local offset = 4;


//Image of robotron cab with green templates for positioning artwork
//fe.add_image( "robo-green.png", 0, 0, flw, flh );

//marquee 
local marquee = fe.add_artwork( "marquee", flx*0.080, fly*0.075, flw*0.2625, flh*0.143 );
marquee.skew_x = 15;
marquee.pinch_y = 4.2;
marquee.rotation = -1.9;
marquee.subimg_width=-marquee.texture_width;
marquee.preserve_aspect_ratio = false;


//video
local snap = fe.add_artwork( "snap", flx*0.067, fly*0.364, flw*0.175, flh*0.273 );
snap.pinch_y = 12;
snap.skew_x = 10;
snap.rotation = -5.6;
snap.preserve_aspect_ratio = false;

//Image of robotron cab
fe.add_image( "robo.png", 0, 0, flw, flh );

//Pointer
local frame = fe.add_image( "point.png", flx*0.90, fly*0.42, flw*0.10, flh*0.17 );


//frame to make text standout on cab
local frame = fe.add_image( "frame.png", flx*0.02, fly*0.86, flw*0.59, flh*0.13 );
//frame.rotation = -9;
//frame.skew_x = -10;


//text 
local title = fe.add_text( "[Title]", flx*0.03, fly*0.88, flw*0.6, flh*0.03 );
title.set_rgb( 255, 255, 255 );
title.align = Align.Left;
//title.rotation = -8;

local man = fe.add_text( " [Year] [Manufacturer] ", flx*0.025, fly*0.91, flw*0.6, flh*0.03 );
man.set_rgb( 255, 255, 255 );
man.align = Align.Left;
//man.rotation = -8;

local filter = fe.add_text( "[ListFilterName] [ListEntry]/[ListSize]", flx*0.03, fly*0.94, flw*0.3, flh*0.03 );
filter.set_rgb( 255, 255, 255 );
filter.align = Align.Left;
//filter.rotation = -8;

//wheel settings
fe.load_module( "conveyor" );

local wheel_x = [ flx*0.80, flx*0.795, flx*0.756, flx*0.725, flx*0.70, flx*0.68, flx*0.5, flx*0.68, flx*0.70, flx*0.725, flx*0.756, flx*0.76, ]; 
local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.4, fly*0.61, fly*0.72 fly*0.83, fly*0.935, fly*0.99, ];
local wheel_w = [ flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.35, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, ];
local wheel_a = [  80,  80,  80,  80,  80,  80, 255,  80,  80,  80,  80,  80, ];
local wheel_h = [  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, flh*0.196875,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11,  flh*0.11, ];
//local wheel_r = [  31,  26,  21,  16,  11,   6,   0, -11, -16, -21, -26, -31, ];
local wheel_r = [  30,  25,  20,  15,  10,   5,   0, -10, -15, -20, -25, -30, ];
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
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }

//fe.add_image( "art2.png", -115, 0, 1024, 768 );

local message = fe.add_text("Launching...",0,300,fe.layout.width,80);
message.alpha = 0;
message.style = Style.Bold;

// Gives us a nice high random number for the RGB levels
function brightrand() {
 return 255-(rand()/255);
}

local red = 255;
local green = 255;
local blue = 255;

// Transitions
fe.add_transition_callback( "fancy_transitions" );

function fancy_transitions( ttype, var, ttime ) {
 switch ( ttype )
 {
 case Transition.StartLayout:
 case Transition.ToNewList:
 case Transition.ToNewSelection:
 case Transition.EndLayout:
  red = 255;
  green = 255;
  blue = 255;
  filter.set_rgb (red,green,blue);
  //emulator.set_rgb (red,green,blue);
  man.set_rgb (red,green,blue);
  title.set_rgb (red,green,blue);
  message.set_rgb (red,green,blue);
  break;

 case Transition.FromGame:
  if ( ttime < 255 )
  {
   foreach (o in fe.obj)
    o.alpha = ttime;
    message.alpha = 0;     
     return true;
  }
  else
  {
   foreach (o in fe.obj)
    o.alpha = 255;
   message.alpha = 0;
     break;
  }
  case Transition.EndLayout:
  if ( ttime < 255 )
  {
   foreach (o in fe.obj)
    o.alpha = 255 - ttime;
   message.alpha = 0; 
     return true;
  }
  else
  {
   foreach (o in fe.obj)
     o.alpha = 255;
    message.alpha = 0;
  }
  break;
     
 case Transition.ToGame:
  if ( ttime < 255 )
  {
   foreach (o in fe.obj)
    o.alpha = 255 - ttime;
    message.alpha = ttime;
    return true;
  }   
  break; 
 }
 return false;
}

