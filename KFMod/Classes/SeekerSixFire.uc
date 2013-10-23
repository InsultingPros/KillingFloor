//=============================================================================
// SeekerSixFire
//=============================================================================
// Primary fire class for the SeekerSix mini rocket launcher
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SeekerSixFire extends KFShotgunFire;

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
    	if( Level.TimeSeconds - LastClickTime>FireRate )
    	{
    		LastClickTime = Level.TimeSeconds;
    	}

		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

    //log("Spread = "$Spread);

	return super(WeaponFire).AllowFire();
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    p = SeekerSixRocketLauncher(Weapon).SpawnProjectile(Start, Dir);
    PostSpawnProjectile(P);
    return p;
}

function float MaxRange()
{
    return 2500;
}

defaultproperties
{
     EffectiveRange=2500.000000
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=50
     FireAimedAnim="Iron_Fire"
     FireSoundRef="KF_FY_SeekerSixSND.Fire.WEP_Seeker_Fire_M"
     StereoFireSoundRef="KF_FY_SeekerSixSND.Fire.WEP_Seeker_Fire"
     NoAmmoSoundRef="KF_M79Snd.M79_DryFire"
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=10.000000,Z=-12.000000)
     bWaitForRelease=True
     TransientSoundVolume=1.800000
     FireForce="AssaultRifleFire"
     FireRate=0.330000
     AmmoClass=Class'KFMod.SeekerSixAmmo'
     ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
     ProjectileClass=Class'KFMod.SeekerSixRocketProjectile'
     BotRefireRate=1.800000
     FlashEmitterClass=Class'KFMod.SeekerSixPrimaryMuzzleFlash1P'
     aimerror=42.000000
     Spread=0.015000
}
