class KFFire extends InstantFire
    abstract;

var()   name    FireAimedAnim;
var()   name    FireEndAimedAnim;
var()   name    FireLoopAimedAnim;

var float LastClickTime;
var float LastFireTime;

var() name EmptyAnim;
var() float EmptyAnimRate;
var() Name EmptyFireAnim;
var() float EmptyFireAnimRate;
var bool Empty;
var () bool bFiringDoesntAffectMovement;

var int UpKick;

var(Recoil)		float			RecoilRate;					// Time in seconds each recoil should take to be applied. Must be less than the fire rate or the full recoil wont be applied
var(Recoil) 	int 			maxVerticalRecoilAngle;    	// max vertical angle a weapon muzzle can climb from recoil
var(Recoil) 	int 			maxHorizontalRecoilAngle;  	// max horizontal angle a weapon muzzle can move from recoil
var(Recoil)     float           RecoilVelocityScale;        // How much to scale the recoil by based on how fast the player is moving
var(Recoil)     bool            bRecoilRightOnly;           // Only recoil the weapon's yaw to the right, not just randomly right and left

var             KFWeapon        KFWeap; // To avoid casting, store the owning KFWeapon
var()           bool            bDoClientRagdollShotFX;     // Do traces on clients when the player is in slomo shooting a dieing enemy so there will be blood puffs

var()           class<Emitter>  ShellEjectClass;            // class of the shell eject emitter
var()           Emitter         ShellEjectEmitter;          // The shell eject emitter
var()           name            ShellEjectBoneName;         // name of the shell eject bone

// Accuracy vars
var()           float           MaxSpread;                  // The maximum spread this weapon will ever have (like when firing in long bursts, etc)
var             int             NumShotsInBurst;            // How many shots fired recently
var()           bool            bAccuracyBonusForSemiAuto;  // Give an accuracy bonus for semi auto fire

// Steroe Fire Sound support
var()           sound           StereoFireSound;            // A stereo version of the fire sound
var()           bool            bRandomPitchFireSound;      // Fire sound randomly change pitch (use this instead of lots of multiple sounds to save memory)
var()           float           RandomPitchAdjustAmt;       // How much to randomly adjust the pitch for firing sounds

var				string			FireSoundRef;
var				string			StereoFireSoundRef;
var				string			NoAmmoSoundRef;

static function PreloadAssets(LevelInfo LevelInfo, optional KFFire Spawned)
{
	if ( default.FireSoundRef != "" )
	{
		default.FireSound = sound(DynamicLoadObject(default.FireSoundRef, class'Sound', true));
	}

	if ( LevelInfo.bLowSoundDetail || (default.StereoFireSoundRef == "" && default.StereoFireSound == none) )
	{
		default.StereoFireSound = default.FireSound;
	}
	else
	{
		default.StereoFireSound = sound(DynamicLoadObject(default.StereoFireSoundRef, class'Sound', true));
	}

	if ( default.NoAmmoSoundRef != "" )
	{
		default.NoAmmoSound = sound(DynamicLoadObject(default.NoAmmoSoundRef, class'Sound', true));
	}

	if ( Spawned != none )
	{
		Spawned.FireSound = default.FireSound;
		Spawned.StereoFireSound = default.StereoFireSound;
		Spawned.NoAmmoSound = default.NoAmmoSound;
	}
}

static function bool UnloadAssets()
{
	default.FireSound = none;
	default.StereoFireSound = none;
	default.NoAmmoSound = none;

	return true;
}

simulated function PostBeginPlay()
{
	if ( FireSound == none )
	{
		PreloadAssets(Level, self);
	}

    super.PostBeginPlay();

    if( KFWeapon(Owner) != none )
    {
        KFWeap = KFWeapon(Owner);
    }
}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (ShellEjectEmitter != None)
        ShellEjectEmitter.Destroy();
}

simulated function InitEffects()
{
    super.InitEffects();

    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
    if ( (ShellEjectClass != None) && ((ShellEjectEmitter == None) || ShellEjectEmitter.bDeleteMe) )
    {
        ShellEjectEmitter = Weapon.Spawn(ShellEjectClass);
        Weapon.AttachToBone(ShellEjectEmitter, ShellEjectBoneName);
    }

    if ( FlashEmitter != None )
        Weapon.AttachToBone(FlashEmitter, KFWeapon(Weapon).FlashBoneName);
}

function DrawMuzzleFlash(Canvas Canvas)
{
    super.DrawMuzzleFlash(Canvas);
    // Draw smoke first
    if (ShellEjectEmitter != None )
    {
        Canvas.DrawActor( ShellEjectEmitter, false, false, Weapon.DisplayFOV );
    }
}

function FlashMuzzleFlash()
{
    super.FlashMuzzleFlash();

    if (ShellEjectEmitter != None)
    {
        //ShellEjectEmitter.SpawnParticle(1);//Trigger(Weapon, Instigator);
        ShellEjectEmitter.Trigger(Weapon, Instigator);
    }
}

function float GetFireSpeed()
{
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		return KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetFireSpeedMod(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), Weapon);
	}

	return 1;
}

function PlayFiring()
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

function PlayFireEnd()
{
    if ( Weapon.Mesh != none )
    {
        if( KFWeap.bAimingRifle )
		{
            if( Weapon.HasAnim(FireEndAimedAnim) )
			{
                Weapon.PlayAnim(FireEndAimedAnim, FireEndAnimRate, TweenTime);
			}
			else if(Weapon.HasAnim(FireEndAnim))
			{
                Weapon.PlayAnim(FireEndAnim, FireEndAnimRate, TweenTime);
			}
		}
		else if(Weapon.HasAnim(FireEndAnim))
		{
            Weapon.PlayAnim(FireEndAnim, FireEndAnimRate, TweenTime);
		}
	}
}

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

	return Super.AllowFire();
}

function StartBerserk();

function StopBerserk();

// Calculate modifications to spread
simulated function float GetSpread()
{
    local float NewSpread;
    local float AccuracyMod;

    AccuracyMod = 1.0;

    // Spread bonus for firing aiming
    if( KFWeap.bAimingRifle )
    {
        AccuracyMod *= 0.5;
    }

    // Small spread bonus for firing crouched
    if( Instigator != none && Instigator.bIsCrouched )
    {
        AccuracyMod *= 0.85;
    }

    // Small spread bonus for firing in semi auto mode
    if( bAccuracyBonusForSemiAuto && bWaitForRelease )
    {
        AccuracyMod *= 0.85;
    }

    NumShotsInBurst += 1;

	if ( Level.TimeSeconds - LastFireTime > 0.5 )
	{
		NewSpread = Default.Spread;
		NumShotsInBurst=0;
	}
	else
    {
        // Decrease accuracy up to MaxSpread by the number of recent shots up to a max of six
        NewSpread = FMin(Default.Spread + (NumShotsInBurst * (MaxSpread/6.0)),MaxSpread);
    }

    NewSpread *= AccuracyMod;

    return NewSpread;
}

event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	if( Instigator==None || Instigator.Controller==none )
		return;

    Spread = GetSpread();

	Rec = GetFireSpeed();
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	ReloadAnimRate = default.ReloadAnimRate*Rec;
	Rec = 1;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	LastFireTime = Level.TimeSeconds;

	if (Weapon.Owner != none && AllowFire() && !bFiringDoesntAffectMovement && Weapon.Owner.Physics != PHYS_Falling )
	{
		if (FireRate > 0.25)
		{
			Weapon.Owner.Velocity.x *= 0.1;
			Weapon.Owner.Velocity.y *= 0.1;
		}
		else
		{
			Weapon.Owner.Velocity.x *= 0.5;
			Weapon.Owner.Velocity.y *= 0.5;
		}
	}

	Super.ModeDoFire();

    // client
    if (Instigator.IsLocallyControlled())
    {
        if( bDoClientRagdollShotFX && Weapon.Level.NetMode == NM_Client )
        {
            DoClientOnlyFireEffect();
        }
        HandleRecoil(Rec);
    }
}

// do a fire effect on clients only, used for causing blood puffs, etc on ragdolls during slomo deaths
simulated function DoClientOnlyFireEffect()
{
    local Vector StartTrace;
    local Rotator R, Aim;

    // the to-hit trace always starts right in front of the eye
    StartTrace = Instigator.Location + Instigator.EyePosition();
    Aim = AdjustAim(StartTrace, AimError);
	R = rotator(vector(Aim) + VRand()*FRand()*Spread);
    DoClientOnlyEffectTrace(StartTrace, R);
}

// Do a effect trace on clients only, used for causing blood puffs, etc on ragdolls during slomo deaths
simulated function DoClientOnlyEffectTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;

	MaxRange();

	Weapon.GetViewAxes(X, Y, Z);
	if ( Weapon.WeaponCentered() )
		ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
	else ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X + Weapon.Hand * Weapon.EffectOffset.Y * Y +
		 Weapon.EffectOffset.Z * Z);

	X = Vector(Dir);
	End = Start + TraceRange * X;
	Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

	if ( Other != None && (Other != Instigator) && Pawn(Other) != none && Pawn(Other).bTearOff )
	{
        Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum*X, DamageType);
	}
}


// Handle setting the recoil amount
simulated function HandleRecoil(float Rec)
{
	local rotator NewRecoilRotation;
	local KFPlayerController KFPC;
	local KFPawn KFPwn;
	local vector AdjustedVelocity;
	local float AdjustedSpeed;

    if( Instigator != none )
    {
		KFPC = KFPlayerController(Instigator.Controller);
		KFPwn = KFPawn(Instigator);
	}

    if( KFPC == none || KFPwn == none )
    	return;

	if( !KFPC.bFreeCamera )
	{
    	if( Weapon.GetFireMode(0).bIsFiring || (DeagleAltFire(Weapon.GetFireMode(1))!=none
    	 && DeagleAltFire(Weapon.GetFireMode(1)).bIsFiring) )
    	{
          	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
         	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

          	if( !bRecoilRightOnly )
          	{
                if( Rand( 2 ) == 1 )
                 	NewRecoilRotation.Yaw *= -1;
            }

    	    if( RecoilVelocityScale > 0 )
    	    {
                if( Weapon.Owner != none && Weapon.Owner.Physics == PHYS_Falling &&
                    Weapon.Owner.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z )
                {
                    AdjustedVelocity = Weapon.Owner.Velocity;
                    // Ignore Z velocity in low grav so we don't get massive recoil
                    AdjustedVelocity.Z = 0;
                    AdjustedSpeed = VSize(AdjustedVelocity);
                    //log("AdjustedSpeed = "$AdjustedSpeed$" scale = "$(AdjustedSpeed* RecoilVelocityScale * 0.5));

                    // Reduce the falling recoil in low grav
                    NewRecoilRotation.Pitch += (AdjustedSpeed* RecoilVelocityScale * 0.5);
            	    NewRecoilRotation.Yaw += (AdjustedSpeed* RecoilVelocityScale * 0.5);
        	    }
        	    else
        	    {
                    //log("Velocity = "$VSize(Weapon.Owner.Velocity)$" scale = "$(VSize(Weapon.Owner.Velocity)* RecoilVelocityScale));
                    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* RecoilVelocityScale);
            	    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* RecoilVelocityScale);
        	    }
    	    }
    	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation *= Rec;

 		    KFPC.SetRecoil(NewRecoilRotation,RecoilRate / (default.FireRate/FireRate));
    	}
 	}
}

function float MaxRange()
{
	if (Instigator.Region.Zone.bDistanceFog)
		TraceRange = FClamp(Instigator.Region.Zone.DistanceFogEnd, 8000, default.TraceRange);
	else TraceRange = default.TraceRange;
	return TraceRange;
}

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local KFWeaponAttachment WeapAttach;
	local array<int>	HitPoints;
	local KFPawn HitPawn;

	MaxRange();

	Weapon.GetViewAxes(X, Y, Z);
	if ( Weapon.WeaponCentered() )
		ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
	else ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X + Weapon.Hand * Weapon.EffectOffset.Y * Y +
		 Weapon.EffectOffset.Z * Z);

	X = Vector(Dir);
	End = Start + TraceRange * X;
	Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);

	if ( Other != None && Other != Instigator && Other.Base != Instigator )
	{
        WeapAttach = KFWeaponAttachment(Weapon.ThirdPersonActor);

		if ( !Other.bWorldGeometry )
		{
			// Update hit effect except for pawns
			if ( !Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume') &&
                !Other.IsA('ExtendedZCollision') )
			{
				if( WeapAttach!=None )
				{
                    WeapAttach.UpdateHit(Other, HitLocation, HitNormal);
                }
			}

			HitPawn = KFPawn(Other);

	    	if ( HitPawn != none )
	    	{
                 // Hit detection debugging
				 /*log("PreLaunchTrace hit "$HitPawn.PlayerReplicationInfo.PlayerName);
				 HitPawn.HitStart = Start;
				 HitPawn.HitEnd = End;*/
                 if(!HitPawn.bDeleteMe)
				 	HitPawn.ProcessLocationalDamage(DamageMax, Instigator, HitLocation, Momentum*X,DamageType,HitPoints);

                 // Hit detection debugging
				 /*if( Level.NetMode == NM_Standalone)
				 	  HitPawn.DrawBoneLocation();*/
	    	}
	    	else
	    	{
				Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum*X,DamageType);
			}
		}
		else
		{
			HitLocation = HitLocation + 2.0 * HitNormal;
            if ( WeapAttach != None )
			{
				WeapAttach.UpdateHit(Other,HitLocation,HitNormal);
			}
		}
	}
	else
	{
		HitLocation = End;
		HitNormal = Normal(Start - End);
	}
}

// Accuracy update based on pawn velocity

simulated function AccuracyUpdate(float Velocity)
{
	if (KFWeapon(Weapon).bSteadyAim)
		return;

	if (Pawn(Weapon.Owner).bIsCrouched)
		Velocity *= 0.6;

	AimError = ((default.AimError * 0.75) + (Velocity * 4 ));   //2
	Spread = ((default.Spread * 0.75) + (Velocity * 0.0010 ));   //.0005
}

defaultproperties
{
     EmptyAnim="empty"
     EmptyAnimRate=1.000000
     EmptyFireAnim="EmptyFire"
     EmptyFireAnimRate=1.000000
     RecoilRate=0.090000
     RecoilVelocityScale=3.000000
     bDoClientRagdollShotFX=True
     MaxSpread=0.120000
     bRandomPitchFireSound=True
     RandomPitchAdjustAmt=0.050000
}
