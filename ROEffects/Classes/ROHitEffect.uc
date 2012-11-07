//=============================================================================
// ROHitEffect
//=============================================================================
// The base class for hit effects
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================
// $Id: ROHitEffect.uc,v 1.8 2004/10/17 02:15:39 ramm Exp $:
//------------------------------------------------------------------------------
class ROHitEffect extends Effects
	abstract;

//#exec OBJ LOAD FILE=ProjectileSounds.uax

//=============================================================================
// Variables
//=============================================================================

struct HitEffectData
{
	var	class<ProjectedDecal>		HitDecal;
	var	class<Emitter>		HitEffect;
	var	sound				HitSound;
};

var()	HitEffectData		HitEffects[20];

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// PostNetBeginPlay
//-----------------------------------------------------------------------------
simulated function PostNetBeginPlay()
{
	local ESurfaceTypes ST;
	local vector HitLoc, HitNormal;
	local Material HitMat;

	if (Level.NetMode == NM_DedicatedServer)
		return;
    //Velocity
	Trace(HitLoc, HitNormal, Location + Vector(Rotation) * 16, Location, false,, HitMat);

	//Level.Game.Broadcast(self, "HitMat = " $HitMat.SurfaceType$" Effect = "$HitEffects[ST].Effect$" Particle Effect = "$HitEffects[ST].ParticleEffect$" TempEffect = "$HitEffects[ST].TempEffect);
	//log("

	if (HitMat == None)
		ST = EST_Default;
	else
		ST = ESurfaceTypes(HitMat.SurfaceType);

//	Level.Game.Broadcast(self, "HitMat = " $HitMat.SurfaceType$" Effect = "$HitEffects[ST].Effect$" Particle Effect = "$HitEffects[ST].ParticleEffect$" TempEffect = "$HitEffects[ST].TempEffect);

	if (HitEffects[ST].HitDecal != None)
		Spawn(HitEffects[ST].HitDecal, self,, Location, Rotation);

	if (HitEffects[ST].HitSound != None)
		PlaySound(HitEffects[ST].HitSound, SLOT_None, 1.0, false, 100.0);

    if( HitLoc != vect(0,0,0) )
    {
    	if (HitEffects[ST].HitEffect != None)
    		Spawn(HitEffects[ST].HitEffect,,, HitLoc, rotator(HitNormal));
	}
	else
	{
    	if (HitEffects[ST].HitEffect != None)
    		Spawn(HitEffects[ST].HitEffect,,, Location, Rotation);
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DrawType=DT_None
     LifeSpan=0.500000
}
