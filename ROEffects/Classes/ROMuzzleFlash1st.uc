//=============================================================================
// ROMuzzleFlash1st
//=============================================================================
// 1st person muzzle flash
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 John Gibson
//=============================================================================

class ROMuzzleFlash1st extends Emitter;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
	Emitters[0].SpawnParticle(1);
}

defaultproperties
{
     bNoDelete=False
     Style=STY_Additive
     bHardAttach=True
     bDirectional=True
}
