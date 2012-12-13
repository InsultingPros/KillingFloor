//=============================================================================
// ZEDGunAltFire
//=============================================================================
// ZEDGun secondary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class ZEDGunAltFire extends KFFire;

// Zed Beam Firing Vars
var ZEDBeamEffect			Beam;
var class<ZEDBeamEffect>	BeamEffectClass;
var float	UpTime;
var float   ChargeUpTime;
var		bool bDoHit;
var		bool bStartFire;
var() Vector ProjSpawnOffset; // +x forward, +y right, +z up

// sound
var 	sound                  AmbientChargeUpSound;           // The charging up of the weapon
var 	float                  AmbientFireSoundRadius;         // The sound radius for the ambient fire sound
var		sound                  AmbientFireSound;               // How loud to play the looping ambient fire sound
var		byte                   AmbientFireVolume;              // The ambient fire sound

var		string                 AmbientChargeUpSoundRef;
var		string                 AmbientFireSoundRef;

var()   float                  MaxChargeTime;                   // The maximum amount of time for a full charged shot
var()   float                  MaxZedSphereChargeTime;          // The maximum amount of time to fully charge the zap sphere

var() class<Emitter> ChargeEmitterClass;
var() Emitter ChargeEmitter;

static function PreloadAssets(LevelInfo LevelInfo, optional KFFire Spawned)
{
	super.PreloadAssets(LevelInfo, Spawned);

	if ( default.AmbientChargeUpSoundRef != "" )
	{
		default.AmbientChargeUpSound = sound(DynamicLoadObject(default.AmbientChargeUpSoundRef, class'sound', true));
	}

	if ( default.AmbientFireSoundRef != "" )
	{
		default.AmbientFireSound = sound(DynamicLoadObject(default.AmbientFireSoundRef, class'sound', true));
	}

	if ( ZEDGunAltFire(Spawned) != none )
	{
		ZEDGunAltFire(Spawned).AmbientChargeUpSound = default.AmbientChargeUpSound;
		ZEDGunAltFire(Spawned).AmbientFireSound = default.AmbientFireSound;
	}
}

static function bool UnloadAssets()
{
	super.UnloadAssets();

	default.AmbientChargeUpSound = none;
	default.AmbientFireSound = none;

	return true;
}

function float MaxRange()
{
    return 2500;
}

function PlayPreFire()
{
	Weapon.PlayAnim('Charge', 1.0, 0.1);
}

simulated function ModeTick(float dt)
{
	local Vector StartTrace, EndTrace, X, Y, Z;
	local Vector HitLocation, HitNormal, EndEffect;
	local Actor Other;
	local Rotator Aim;
	local ZEDGun ZEDGun;
	local ZEDBeamEffect LB;
	local KFMonster KFM;
	local float ChargeScale;

    if ( !bIsFiring )
    {
        return;
    }

    ZEDGun = ZEDGun(Weapon);

    // Handle the beam firing
    if ( AllowFire() && ((UpTime > 0.0) || (Instigator.Role < ROLE_Authority)) )
    {
        UpTime -= dt;
        if( ChargeUpTime == 0 )
        {
            // Play the chargeup sound
            PlayAmbientSound(AmbientChargeUpSound);
            InitChargeEffect();
            SetTimer(0.15, true);
            PlayPreFire();
        }

        ChargeUpTime += dt;

		// the to-hit trace starts at the spawn offset to it looks like it is coming from the barrel
		ZEDGun.GetViewAxes(X, Y, Z);
		StartTrace = GetFireStart( X, Y, Z);

		StartTrace = StartTrace + X*ProjSpawnOffset.X;
	    StartTrace = StartTrace + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

        // Find the beam on the client
        if ( Instigator.Role < ROLE_Authority )
        {
			if ( Beam == None )
			{
				ForEach Weapon.DynamicActors(class'ZEDBeamEffect', LB )
					if ( !LB.bDeleteMe && (LB.Instigator != None) && (LB.Instigator == Instigator) )
					{
						Beam = LB;
						break;
					}
			}
		}

        // Consume the ammo on the server
        if ( Instigator.Role == ROLE_Authority )
		{
		    if ( bDoHit )
		    {
			    Weapon.ConsumeAmmo(0, AmmoPerFire);
			}
		}

        // client
        if ( bDoHit && Instigator.IsLocallyControlled() )
        {
            HandleRecoil(1.0);
        }

        // Set the end point of the beam
        Aim = AdjustAim(StartTrace, AimError);
        X = Vector(Aim);
        EndTrace = StartTrace + TraceRange * X;

        Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if ( Other != None && Other != Instigator )
			EndEffect = HitLocation;
		else
			EndEffect = EndTrace;

		if ( Beam != None )
			Beam.EndEffect = EndEffect;

		// Everything else here needs to happen on the server only
        if ( Instigator.Role < ROLE_Authority )
		{
			return;
		}

        if ( Other != None && Other != Instigator )
        {
            if( KFMonster(Other) != none && KFMonster(Other).Health > 0 )
            {
                KFMonster(Other).SetZapped(dt, Instigator);
            }
            else if( ExtendedZCollision(Other)!=None && Other.Base != none
                && KFMonster(Other.Base) != none && KFMonster(Other.Base).Health > 0 )
            {
                KFMonster(Other.Base).SetZapped(dt, Instigator);
            }

            // Make noise every time we "fire"
            if ( bDoHit )
            {
                Instigator.MakeNoise(1.0);
			}
		}

        if( ChargeUpTime < MaxZedSphereChargeTime )
        {
            ChargeScale = ChargeUpTime/MaxZedSphereChargeTime;
        }
        else
        {
            ChargeScale = 1.0;
        }

		if ( Beam != None )
			Beam.SphereCharge = ChargeScale;

        //Weapon.DrawDebugSphere( EndEffect, 250 * ChargeScale, 12, 0, 255, 0);

        if ( bDoHit && Other != None && Other != Instigator )
        {
    		foreach Weapon.VisibleCollidingActors( class 'KFMonster', KFM, 250 * ChargeScale, EndEffect )
    		{
                if( KFM != none && KFM != Other )
                {
                    if( KFM.Health > 0 )
                    {
                        KFM.SetZapped(FireRate * 0.75, Instigator);
                    }
                }
    		}
		}

		// beam effect is created and destroyed when firing starts and stops
		if ( (Beam == None) && bIsFiring )
		{
			Beam = Weapon.Spawn( BeamEffectClass, Instigator );
		}

		if ( Beam != None )
		{
			Beam.bHitSomething = (Other != None);
			Beam.EndEffect = EndEffect;
		}
    }
    else
        StopFiring();

    bStartFire = false;
    bDoHit = false;
}

// Overriden to share the same ammo as the primary fire
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

	return ( Weapon.AmmoAmount(0) >= AmmoPerFire);
}

// Do nothing
function ModeHoldFire(){}

// Handles toggling the weapon attachment's ambient sound on and off
function PlayAmbientSound(Sound aSound)
{
	local WeaponAttachment WA;

	WA = WeaponAttachment(Weapon.ThirdPersonActor);

    if ( Weapon == none || (WA == none))
        return;

	if(aSound == None)
	{
		WA.SoundVolume = WA.default.SoundVolume;
		WA.SoundRadius = WA.default.SoundRadius;
	}
	else
	{
		WA.SoundVolume = AmbientFireVolume;
		WA.SoundRadius = AmbientFireSoundRadius;
	}

    WA.AmbientSound = aSound;
}

// Handle the Zed gun charge sounds and effects
function Timer()
{
    local float ChargeScale;
	local ZEDGunAttachment WA;

	WA = ZEDGunAttachment(Weapon.ThirdPersonActor);

    if (ChargeUpTime > 0.0 && bIsFiring)
    {
        if( ChargeUpTime < MaxChargeTime )
        {
            PlayAmbientSound(AmbientChargeUpSound);
            ChargeScale = ChargeUpTime/MaxChargeTime;
            WA.ZedGunCharge = ChargeScale * 255;
            WA.UpdateZedGunCharge();
            if( ChargeEmitter != none )
            {
                ChargeEmitter.Emitters[0].SizeScale[1].RelativeSize = Lerp( ChargeScale, 4, 10 );
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Min = Lerp( ChargeScale, 50, 300 );
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Max = Lerp( ChargeScale, 50, 300 );
                ChargeEmitter.Emitters[1].SizeScale[0].RelativeSize = Lerp( ChargeScale, 2, 6 );
            }
        }
        else
        {
            PlayAmbientSound(AmbientFireSound);
            WA.ZedGunCharge = 255;
            WA.UpdateZedGunCharge();

            if( ChargeEmitter != none )
            {
                ChargeEmitter.Emitters[0].SizeScale[1].RelativeSize = 10;
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Min = 300;
                ChargeEmitter.Emitters[1].StartVelocityRadialRange.Max = 300;
                ChargeEmitter.Emitters[1].SizeScale[0].RelativeSize = 6;
            }
        }
    }
    else
    {
        PlayAmbientSound(none);
        DestroyChargeEffect();
        WA.ZedGunCharge = 0;
        WA.UpdateZedGunCharge();
        PlayFireEnd();
        Weapon.StopFire(ThisModeNum);

        SetTimer(0, false);
    }
}

// Handle setting new recoil
simulated function HandleRecoil(float Rec)
{
	local rotator NewRecoilRotation;
	local KFPlayerController KFPC;
	local KFPawn KFPwn;

    if( Instigator != none )
    {
		KFPC = KFPlayerController(Instigator.Controller);
		KFPwn = KFPawn(Instigator);
	}

    if( KFPC == none || KFPwn == none )
    	return;

	if( !KFPC.bFreeCamera )
	{
      	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
     	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

      	if( Rand( 2 ) == 1 )
         	NewRecoilRotation.Yaw *= -1;

	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
	    NewRecoilRotation *= Rec;

	    KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
 	}
}

// Handle the beam having stopped firing
function StopFiring()
{
    if (Beam != None)
    {
        Beam.Destroy();
        Beam = None;
    }
    bStartFire = true;

    ChargeUpTime = 0;
}

event ModeDoFire()
{
    Load = 0; //don't use ammo here - it will be consumed in ModeTick() where it's sync'ed with damage dealing

	if (!AllowFire())
		return;

    if (!AllowFire())
        return;

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        DoFireEffect();
		HoldTime = 0;	// if bot decides to stop firing, HoldTime must be reset first
        if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

        if ( AIController(Instigator.Controller) != None )
            AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

        Instigator.DeactivateSpawnProtection();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        ShakeView();
    }

    Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if (bIsFiring)
            NextFireTime += MaxHoldTime + FireRate;
        else
            NextFireTime = Level.TimeSeconds + FireRate;
    }
    else
    {
        NextFireTime += FireRate;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }

    Load = AmmoPerFire;
    HoldTime = 0;

    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        bIsFiring = false;
        Weapon.PutDown();
    }
}

// Overridden to play different anims/sounds for the power down of this weapon
function PlayFireEnd()
{
    local float RandPitch;

	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if( KFWeap.bAimingRifle )
			{
                if ( Weapon.HasAnim(FireLoopAimedAnim) )
    			{
    				Weapon.PlayAnim(FireLoopAimedAnim, FireLoopAnimRate, 0.0);
    			}
    			else if( Weapon.HasAnim(FireAimedAnim) )
    			{
    				Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
    			}
    			else
    			{
                    Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    			}
			}
			else
			{
                if ( Weapon.HasAnim(FireLoopAnim) )
    			{
    				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
    			}
    			else
    			{
    				Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    			}
			}
		}
		else
		{
            if( KFWeap.bAimingRifle )
			{
                if( Weapon.HasAnim(FireAimedAnim) )
    			{
                    Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
    			}
    			else
    			{
                    Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    			}
			}
			else
			{
                Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
			}
		}
	}


	if( Weapon.Instigator != none && Weapon.Instigator.IsLocallyControlled() &&
	   Weapon.Instigator.IsFirstPerson() && StereoFireSound != none )
	{
        if( bRandomPitchFireSound )
        {
            RandPitch = FRand() * RandomPitchAdjustAmt;

            if( FRand() < 0.5 )
            {
                RandPitch *= -1.0;
            }
        }

        Weapon.PlayOwnedSound(StereoFireSound,SLOT_Interact,TransientSoundVolume * 0.85,,TransientSoundRadius,(1.0 + RandPitch),false);
    }
    else
    {
        if( bRandomPitchFireSound )
        {
            RandPitch = FRand() * RandomPitchAdjustAmt;

            if( FRand() < 0.5 )
            {
                RandPitch *= -1.0;
            }
        }

        Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,(1.0 + RandPitch),false);
    }
    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
}

// Don't do any fire effect, its all done in the mode tick and this fire mode doesn't do normal damage
function DoFireEffect()
{
    bDoHit = true;
    UpTime = FireRate+0.1;
}

// Don't do any fire effect, its all done in the mode tick and this fire mode doesn't do normal damage
simulated function DoClientOnlyEffectTrace(Vector Start, Rotator Dir){}

simulated function InitChargeEffect()
{
    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;

    if ( (ChargeEmitterClass != None) && ((ChargeEmitter == None) || ChargeEmitter.bDeleteMe) )
    {
        ChargeEmitter = Weapon.Spawn(ChargeEmitterClass);
        if ( ChargeEmitter != None )
    		Weapon.AttachToBone(ChargeEmitter, 'tip');
    }
}

simulated function DestroyChargeEffect()
{
    if (ChargeEmitter != None)
        ChargeEmitter.Destroy();
}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    DestroyChargeEffect();

    if ( Level.NetMode != NM_Client )
    {
        if ( Beam != None )
            Beam.Destroy();
    }
}

defaultproperties
{
     BeamEffectClass=Class'KFMod.ZEDBeamEffect'
     ProjSpawnOffset=(X=25.000000,Y=18.000000,Z=-14.500000)
     AmbientFireSoundRadius=500.000000
     AmbientFireVolume=255
     AmbientChargeUpSoundRef="KF_ZEDGunSnd.ZedGunChargeUp"
     AmbientFireSoundRef="KF_ZEDGunSnd.ZedGunChargeLoop"
     MaxChargeTime=1.000000
     MaxZedSphereChargeTime=3.000000
     ChargeEmitterClass=Class'ROEffects.ChargeUp1stZEDGun'
     FireAimedAnim="ChargeDown"
     RecoilRate=0.070000
     maxVerticalRecoilAngle=100
     maxHorizontalRecoilAngle=150
     bRandomPitchFireSound=False
     FireSoundRef="KF_ZEDGunSnd.KF_WEP_ZED_Secondary_SpinDown_M"
     StereoFireSoundRef="KF_ZEDGunSnd.KF_WEP_ZED_Secondary_SpinDown_S"
     NoAmmoSoundRef="KF_ZEDGunSnd.KF_WEP_ZED_Dryfire"
     TraceRange=2500.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireAnim="ChargeDown"
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.120000
     AmmoClass=Class'KFMod.ZEDGunAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=25.000000,Y=25.000000,Z=100.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=3.000000,Y=1.000000,Z=3.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     BotRefireRate=0.150000
     FlashEmitterClass=Class'ROEffects.ZEDGunChargeDown'
     aimerror=42.000000
     Spread=0.015000
     SpreadStyle=SS_Random
}
