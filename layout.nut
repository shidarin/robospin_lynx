//
// Attract-Mode Front-End - "Robospin Lynx" layout
//
class UserConfig {
   </ label="SpinWheel", help="The artwork to spin", options="marquee,flyer,wheel" />
   orbit_art="wheel";
   </ label="Bloom Effect", help="Enable Bloom Effect (requires shader support)", options="Yes,No" />
   enable_bloom="Yes";
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

fe.layout.width=1920;
fe.layout.height=1080;
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

// Image shadow/outline thickness
local offset = 4;

//Image of lynx overlay guide with green for help positioning the artwork
//fe.add_image( "overlay_guide.png", 0, 0, flw, flh );


//video
local snap = fe.add_artwork( "snap", flx*0.049, fly*0.217, 160*4.1, 102*3.74 );
snap.pinch_x = -10;
snap.pinch_y = 13;
snap.skew_x = 110;
snap.skew_y = 15;
snap.rotation = -12.6;
snap.preserve_aspect_ratio = false;
//helps with placement
//snap.alpha = 200;

//scanlines
local scanlines = fe.add_image( "scan-lights.png", snap.x, snap.y, snap.width, snap.height );
scanlines.pinch_x = snap.pinch_x;
scanlines.pinch_y = snap.pinch_y;
scanlines.skew_x = snap.skew_x;
scanlines.skew_y = snap.skew_y;
scanlines.rotation = snap.rotation;
scanlines.preserve_aspect_ratio = false;

//Image of lynx overlay
fe.add_image( "screen_overlay.png", 0, 0, flw, flh );

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
  //emulator.set_rgb (red,green,blue);
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

