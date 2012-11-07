//=============================================================================
// DualMK23Fire
//=============================================================================
// Dual Mark 23 Pistol primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson, and IJC Development
//=============================================================================
class DualMK23Fire extends DualiesFire;

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local byte HitCount,HCounter;
	local float HitDamage;
	local array<int>	HitPoints;
	local KFPawn HitPawn;
	local array<Actor>	IgnoreActors;
	local Actor DamageActor;
	local int i;

	MaxRange();

	Weapon.GetViewAxes(X, Y, Z);
	if ( Weapon.WeaponCentered() )
	{
		ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
	}
	else
    {
        ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X +
		 Weapon.Hand * Weapon.EffectOffset.Y * Y + Weapon.EffectOffset.Z * Z);
    }

	X = Vector(Dir);
	End = Start + TraceRange * X;
	HitDamage = DamageMax;
	While( (HitCount++)<3 )
	{
        DamageActor = none;

		Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);
		if( Other==None )
		{
			Break;
		}
		else if( Other==Instigator || Other.Base == Instigator )
		{
			IgnoreActors[IgnoreActors.Length] = Other;
			Other.SetCollision(false);
			Start = HitLocation;
			Continue;
		}

		if( ExtendedZCollision(Other)!=None && Other.Owner!=None )
		{
            IgnoreActors[IgnoreActors.Length] = Other;
            IgnoreActors[IgnoreActors.Length] = Other.Owner;
			Other.SetCollision(false);
			Other.Owner.SetCollision(false);
			DamageActor = Pawn(Other.Owner);
		}

		if ( !Other.bWorldGeometry && Other!=Level )
		{
			HitPawn = KFPawn(Other);

	    	if ( HitPawn != none )
	    	{
                 // Hit detection debugging
				 /*log("PreLaunchTrace hit "$HitPawn.PlayerReplicationInfo.PlayerName);
				 HitPawn.HitStart = Start;
				 HitPawn.HitEnd = End;*/
                 if(!HitPawn.bDeleteMe)
				 	HitPawn.ProcessLocationalDamage(int(HitDamage), Instigator, HitLocation, Momentum*X,DamageType,HitPoints);

                 // Hit detection debugging
				 /*if( Level.NetMode == NM_Standalone)
				 	  HitPawn.DrawBoneLocation();*/

                IgnoreActors[IgnoreActors.Length] = Other;
                IgnoreActors[IgnoreActors.Length] = HitPawn.AuxCollisionCylinder;
    			Other.SetCollision(false);
    			HitPawn.AuxCollisionCylinder.SetCollision(false);
    			DamageActor = Other;
			}
            else
            {
    			if( KFMonster(Other)!=None )
    			{
                    IgnoreActors[IgnoreActors.Length] = Other;
        			Other.SetCollision(false);
        			DamageActor = Other;
    			}
    			else if( DamageActor == none )
    			{
                    DamageActor = Other;
    			}
    			Other.TakeDamage(int(HitDamage), Instigator, HitLocation, Momentum*X, DamageType);
			}
			if( (HCounter++)>=4 || Pawn(DamageActor)==None )
			{
				Break;
			}
			HitDamage/=2;
			Start = HitLocation;
		}
		else if ( HitScanBlockingVolume(Other)==None )
		{
			if( KFWeaponAttachment(Weapon.ThirdPersonActor)!=None )
		      KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
			Break;
		}
	}

    // Turn the collision back on for any actors we turned it off
	if ( IgnoreActors.Length > 0 )
	{
		for (i=0; i<IgnoreActors.Length; i++)
		{
            IgnoreActors[i].SetCollision(true);
		}
	}
}

defaultproperties
{
     maxVerticalRecoilAngle=500
     maxHorizontalRecoilAngle=100
     ShellEjectClass=Class'KFMod.MK23Shell'
     FireSoundRef="KF_MK23Snd.MK23_Fire_M"
     StereoFireSoundRef="KF_MK23Snd.MK23_Fire_S"
     NoAmmoSoundRef="KF_HandcannonSnd.50AE_DryFire"
     DamageType=Class'KFMod.DamTypeDualMK23Pistol'
     DamageMin=80
     DamageMax=82
     Momentum=18000.000000
     FireSound=None
     NoAmmoSound=None
     FireRate=0.120000
     AmmoClass=Class'KFMod.MK23Ammo'
     ShakeRotMag=(Z=290.000000)
     ShakeRotRate=(X=10080.000000,Y=10080.000000)
     ShakeRotTime=3.500000
     ShakeOffsetMag=(Y=1.000000,Z=8.000000)
     ShakeOffsetTime=2.500000
     FlashEmitterClass=Class'KFMod.MuzzleFlashMK'
     aimerror=40.000000
     Spread=0.010000
}
