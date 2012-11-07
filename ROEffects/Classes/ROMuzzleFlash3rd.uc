//=============================================================================
// ROMuzzleFlash3rd
//=============================================================================
// 3rd person muzzle flash
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 John Gibson
//=============================================================================

class ROMuzzleFlash3rd extends Emitter;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
	Emitters[0].SpawnParticle(1);
}

defaultproperties
{
     CullDistance=20000.000000
     bNoDelete=False
     Style=STY_Additive
     bUnlit=False
     bHardAttach=True
}
