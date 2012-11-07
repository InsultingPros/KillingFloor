//===================================================================
// CustomSoundNotify
// Copyright (C) 2005 Tripwire Interactive LLC
// John "Ramm-Jaeger"  Gibson
//
// Custom sound notify class. Had to add this because the
// stock UT ones don't play correctly when your standing on BSP
//===================================================================

class CustomSoundNotify extends AnimNotify
	native
	abstract;

var() sound Sound;
var() float Volume;
var() int Radius;
var() bool bAttenuate;

event Notify( Actor Owner );

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
     Volume=1.000000
}
