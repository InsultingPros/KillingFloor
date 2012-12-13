class DualFlareRevolverFire extends KFShotgunFire;

var() Emitter Flash2Emitter;

var()           Emitter         ShellEject2Emitter;          // The shell eject emitter
var()           name            ShellEject2BoneName;         // name of the shell eject bone

var name FireAnim2, FireAimedAnim2;
var name fa;
var float TraceRange;

var() vector SightedProjSpawnOffset;

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

simulated function InitEffects()
{
    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
        return;
    if ( (FlashEmitterClass != None) && ((FlashEmitter == None) || FlashEmitter.bDeleteMe) )
    {
        FlashEmitter = Weapon.Spawn(FlashEmitterClass);
        Weapon.AttachToBone(FlashEmitter, KFWeapon(Weapon).default.FlashBoneName);
    }
    if ( (FlashEmitterClass != None) && ((Flash2Emitter == None) || Flash2Emitter.bDeleteMe) )
    {
        Flash2Emitter = Weapon.Spawn(FlashEmitterClass);
        Weapon.AttachToBone(Flash2Emitter, DualFlareRevolver(Weapon).default.altFlashBoneName);
    }

    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
    {
        SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
    }

}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (ShellEject2Emitter != None)
        ShellEject2Emitter.Destroy();

    if (Flash2Emitter != None)
        Flash2Emitter.Destroy();
}

function DrawMuzzleFlash(Canvas Canvas)
{
    super.DrawMuzzleFlash(Canvas);

    if (ShellEject2Emitter != None )
    {
        Canvas.DrawActor( ShellEject2Emitter, false, false, Weapon.DisplayFOV );
    }
}

function FlashMuzzleFlash()
{
    if (Flash2Emitter == none || FlashEmitter == none)
        return;

    if( KFWeap.bAimingRifle )
    {
        if( FireAimedAnim == 'FireLeft_Iron' )
        {
            Flash2Emitter.Trigger(Weapon, Instigator);

           // bFlashLeft = true;
        }
        else
        {
            FlashEmitter.Trigger(Weapon, Instigator);

          // bFlashLeft = false;
        }
	}
	else
	{
        if(FireAnim == 'FireLeft')
        {
            Flash2Emitter.Trigger(Weapon, Instigator);

           // bFlashLeft = true;
        }
        else
        {
            FlashEmitter.Trigger(Weapon, Instigator);

          // bFlashLeft = false;
        }
	}
}

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;

    if( KFWeap.bAimingRifle )
    {
        StartProj = StartTrace + X*SightedProjSpawnOffset.X;

        if( FireAimedAnim == 'FireLeft_Iron')
        {
            StartProj = StartProj + -1 * Y*SightedProjSpawnOffset.Y + Z*SightedProjSpawnOffset.Z;
        }
        else
        {
            StartProj = StartProj + Weapon.Hand * Y*SightedProjSpawnOffset.Y + Z*SightedProjSpawnOffset.Z;
        }
	}
	else
	{
        StartProj = StartTrace + X*ProjSpawnOffset.X;

        if(FireAnim == 'FireLeft')
        {
            StartProj = StartProj + -1 * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
        }
        else
        {
            StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
        }
	}

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

// Collision attachment debugging
 /*   if( Other.IsA('ROCollisionAttachment'))
    {
    	log(self$"'s trace hit "$Other.Base$" Collision attachment");
    }*/

    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
    }

	if (Instigator != none )
	{
        if( Instigator.Physics != PHYS_Falling  )
        {
            Instigator.AddVelocity(KickMomentum >> Instigator.GetViewRotation());
		}
		// Really boost the momentum for low grav
        else if( Instigator.Physics == PHYS_Falling
            && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)
        {
            Instigator.AddVelocity((KickMomentum * 10.0) >> Instigator.GetViewRotation());
        }
	}
}

event ModeDoFire()
{
	local name bn;

	bn = Dualies(Weapon).altFlashBoneName;
	DualFlareRevolver(Weapon).altFlashBoneName = DualFlareRevolver(Weapon).FlashBoneName;
	DualFlareRevolver(Weapon).FlashBoneName = bn;

	Super.ModeDoFire();

    if( KFWeap.bAimingRifle )
    {
    	fa = FireAimedAnim2;
    	FireAimedAnim2 = FireAimedAnim;
    	FireAimedAnim = fa;
	}
	else
	{
    	fa = FireAnim2;
    	FireAnim2 = FireAnim;
    	FireAnim = fa;
	}
	InitEffects();
}

defaultproperties
{
     FireAnim2="FireLeft"
     FireAimedAnim2="FireLeft_Iron"
     TraceRange=10000.000000
     SightedProjSpawnOffset=(X=50.000000,Y=10.000000)
     RecoilRate=0.070000
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=250
     FireAimedAnim="FireRight_Iron"
     FireSoundRef="KF_IJC_HalloweenSnd.FlarePistol_Fire_M"
     StereoFireSoundRef="KF_IJC_HalloweenSnd.FlarePistol_Fire_S"
     NoAmmoSoundRef="KF_HandcannonSnd.50AE_DryFire"
     ProjPerFire=1
     ProjSpawnOffset=(X=50.000000,Y=10.000000,Z=-5.000000)
     bWaitForRelease=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireAnim="FireRight"
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.200000
     AmmoClass=Class'KFMod.FlareRevolverAmmo'
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=10000.000000)
     ShakeRotTime=3.500000
     ShakeOffsetMag=(X=6.000000,Y=1.000000,Z=8.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.500000
     ProjectileClass=Class'KFMod.FlareRevolverProjectile'
     BotRefireRate=0.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stFlareRevolver'
     aimerror=42.000000
     Spread=0.017500
}
