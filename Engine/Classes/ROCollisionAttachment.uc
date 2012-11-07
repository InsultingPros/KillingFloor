//=============================================================================
// ROCollisionAttachment
//=============================================================================
// An additional collision cylinder to assist in detecting special traces
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//=============================================================================

class ROCollisionAttachment extends Actor
	native;

defaultproperties
{
     DrawType=DT_None
     bIgnoreEncroachers=True
     CollisionRadius=28.000000
     CollisionHeight=15.000000
     bCollideActors=True
     bProjTarget=True
     bUseCylinderCollision=True
}
