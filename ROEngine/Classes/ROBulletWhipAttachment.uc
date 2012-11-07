//=============================================================================
// ROBulletWhipAttachment
//=============================================================================
// An additional collision cylinder for detecting precision hit traces or
// projectiles as well as detecting bullets passing by which allows for the
// creation of bullet whip sound effects.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//=============================================================================

class ROBulletWhipAttachment extends ROCollisionAttachment;

// Don't damage anything when this is hit, it is for sounds only
function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	return;
}

// Don't do anything
function SetDelayedDamageInstigatorController(Controller C)
{
	return;
}

defaultproperties
{
     CollisionRadius=150.000000
     CollisionHeight=150.000000
}
