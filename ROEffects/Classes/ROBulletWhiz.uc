//=============================================================================
// ROBulletWhiz
//=============================================================================
// A bullet whiz sound effect
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//============================================================================

class ROBulletWhiz extends Effects;

#exec OBJ LOAD FILE=ProjectileSounds.uax

//=============================================================================
// Variables
//=============================================================================

var 	sound			WhizSound;   	// This should be the a sound group of bullet whizzes

//=============================================================================
// Functions
//=============================================================================

simulated function PostBeginPlay()
{
	PlayOwnedSound( WhizSound, SLOT_None, 3.0, false, 300.0, 1.0, true);
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     WhizSound=SoundGroup'ProjectileSounds.Bullets.Bullet_Whiz'
     DrawType=DT_None
     LifeSpan=0.500000
}
