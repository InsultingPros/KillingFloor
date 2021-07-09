//=============================================================================
// NailGunAttachment
//=============================================================================
// NailGun attachment class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - Dan Hollinger
//=============================================================================
class NailGunAttachment extends KFWeaponAttachment;

var Actor   TacShine;
var Effects TacShineCorona;
var bool    bBeamEnabled;

// Prevents tracers from spawning if player is using the flashlight function of the 9mm
simulated event ThirdPersonEffects()
{
	if( FiringMode==1 )
    {
		return;
    }

	Super.ThirdPersonEffects();
}

simulated function Destroyed()
{
	if( TacShineCorona != None )
    {
		TacShineCorona.Destroy();
    }

	if( TacShine != None )
    {
		TacShine.Destroy();
    }

	Super.Destroyed();
}

simulated function UpdateTacBeam( float Dist )
{
	local vector Sc;

	if( !bBeamEnabled )
	{
		if( TacShine == none )
		{
			TacShine = Spawn(Class'Single'.Default.TacShineClass,Owner,,,);
			AttachToBone(TacShine,'FlashLight');
			TacShine.RemoteRole = ROLE_None;
		}
		else 
        {
            TacShine.bHidden = False;
        }

		if( TacShineCorona == none )
		{
			TacShineCorona = Spawn(class 'KFTacLightCorona',Owner,,,);
			AttachToBone(TacShineCorona,'FlashLight');
			TacShineCorona.RemoteRole = ROLE_None;
		}

		TacShineCorona.bHidden = False;
		bBeamEnabled = True;
	}

	Sc = TacShine.DrawScale3D;
	Sc.Y = FClamp(Dist/90.f,0.02,1.f);
	if( TacShine.DrawScale3D != Sc )
    {
		TacShine.SetDrawScale3D(Sc);
    }
}

simulated function TacBeamGone()
{
	if( bBeamEnabled )
	{
		if( TacShine!=none )
        {
			TacShine.bHidden = True;
        }
		if( TacShineCorona!=none )
        {
			TacShineCorona.bHidden = True;
        }
        
		bBeamEnabled = False;
	}
}

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdNailGun'
     TurnLeftAnim="TurnL_Bullpup"
     TurnRightAnim="TurnR_Bullpup"
     WalkAnims(0)="WalkF_Bullpup"
     WalkAnims(1)="WalkB_Bullpup"
     WalkAnims(2)="WalkL_Bullpup"
     WalkAnims(3)="WalkR_Bullpup"
     CrouchTurnRightAnim="CH_TurnR_Bullpup"
     CrouchTurnLeftAnim="CH_TurnL_Bullpup"
     MeshRef="KF_Weapons3rd5_Trip.Vlad9000_3rd"
}
