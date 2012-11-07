class KFShotgunFire extends BaseProjectileFire;

var float LastClickTime;

var() Name EmptyAnim;
var() float EmptyAnimRate;

var() float MaxAccuracyBonus,CrouchedAccuracyBonus;  // Lower number = higher bonus .  1.0  =  no bonus  ,   0.1   =  90% bonus.

var() float EffectiveRange;

var() vector KickMomentum;
var() bool bFiringDoesntAffectMovement;

var(Recoil)		float			RecoilRate;					// Time in seconds each recoil should take to be applied. Must be less than the fire rate or the full recoil wont be applied
var(Recoil) 	int 			maxVerticalRecoilAngle;    	// max vertical angle a weapon muzzle can climb from recoil
var(Recoil) 	int 			maxHorizontalRecoilAngle;  	// max horizontal angle a weapon muzzle can move from recoil

var()   name    FireAimedAnim;
var()   name    FireLoopAimedAnim;

var             KFWeapon        KFWeap; // To avoid casting, store the owning KFWeapon

// Steroe Fire Sound support
var()           sound           StereoFireSound;            // A stereo version of the fire sound
var()           bool            bRandomPitchFireSound;      // Fire sound randomly change pitch (use this instead of lots of multiple sounds to save memory)
var()           float           RandomPitchAdjustAmt;       // How much to randomly adjust the pitch for firing sounds

var				string			FireSoundRef;
var				string			StereoFireSoundRef;
var				string			NoAmmoSoundRef;

static function PreloadAssets(LevelInfo LevelInfo, optional KFShotgunFire Spawned)
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

// Begin code from FlakFire
function InitEffects()
{
    Super.InitEffects();
    if ( FlashEmitter != None )
		Weapon.AttachToBone(FlashEmitter, 'tip');
}
// End code from FlakFire

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
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() && !KFWeap.bAimingRifle )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

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

	if (Instigator != none && Instigator.Physics != PHYS_Falling)
		Instigator.AddVelocity(KickMomentum >> Instigator.GetViewRotation());
}

function float GetFireSpeed()
{
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		return KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetFireSpeedMod(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), Weapon);
	}

	return 1;
}

event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	Spread = Default.Spread;

	Rec = GetFireSpeed();
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	Rec = 1;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	if( !bFiringDoesntAffectMovement )
	{
		if (FireRate > 0.25)
		{
			Instigator.Velocity.x *= 0.1;
			Instigator.Velocity.y *= 0.1;
		}
		else
		{
			Instigator.Velocity.x *= 0.5;
			Instigator.Velocity.y *= 0.5;
		}
	}

	Super.ModeDoFire();

    // client
    if (Instigator.IsLocallyControlled())
    {
        HandleRecoil(Rec);
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
    	if( Weapon.GetFireMode(0).bIsFiring )
    	{
          	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
         	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

          	if( Rand( 2 ) == 1 )
             	NewRecoilRotation.Yaw *= -1;

    	    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* 3);
    	    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* 3);
    	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
    	    NewRecoilRotation *= Rec;

 		    KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
    	}
 	}
}

// Overridden to support interrupting the reload
simulated function bool AllowFire()
{
	if( KFWeapon(Weapon).bIsReloading && KFWeapon(Weapon).MagAmmoRemaining < 2)
		return false;

	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if( KFPawn(Instigator).bThrowingNade )
		return false;

	if( Level.TimeSeconds - LastClickTime>FireRate )
	{
		LastClickTime = Level.TimeSeconds;
	}

	if( KFWeaponShotgun(Weapon).MagAmmoRemaining<1 )
	{
    		return false;
	}

	return super(WeaponFire).AllowFire();
}

// TODO: Maybe provide more control? So there's a 'if you're desparate, you MIGHT
//       do something at this range, but here's the recommended dist
//       Currently, bots won't fire past this recommendation no matter what
//       We'll see if desperation long-range fire is needed

//TODO: Also, check the effectiverange for all subclasses to make sure it is
//      appropriate
function float MaxRange()
{
	if (Instigator.Region.Zone.bDistanceFog)
		return FClamp(Instigator.Region.Zone.DistanceFogEnd, 1500, EffectiveRange);
	else return 1500;
}

// Accuracy update based on pawn velocity
simulated function AccuracyUpdate(float Velocity)
{
    local float MovementScale, ShakeScaler;
	if (KFWeapon(Weapon).bSteadyAim)
		return;

	if (Pawn(Weapon.Owner).bIsCrouched)
		Velocity *= CrouchedAccuracyBonus;

	Spread = (default.Spread + (Velocity * 10 ));

    // Add up to 20% more shake depending on how fast the player is moving
    MovementScale= Velocity/Instigator.default.GroundSpeed;
    ShakeScaler = 1.0 + (0.2 * MovementScale);

	ShakeRotMag.x = (default.ShakeRotMag.x * ShakeScaler);
	ShakeRotMag.y = (default.ShakeRotMag.y * ShakeScaler);
	ShakeRotMag.z = (default.ShakeRotMag.z * ShakeScaler);
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

defaultproperties
{
     CrouchedAccuracyBonus=0.600000
     EffectiveRange=700.000000
     RecoilRate=0.050000
     bRandomPitchFireSound=True
     RandomPitchAdjustAmt=0.050000
     ProjPerFire=9
     ProjSpawnOffset=(X=25.000000,Y=5.000000,Z=-6.000000)
     FireEndAnim=
     FireForce="FlakCannonFire"
     FireRate=0.894700
     AmmoPerFire=1
     ProjectileClass=Class'Old2k4.FlakChunk'
     BotRefireRate=0.700000
     Spread=2250.000000
     SpreadStyle=SS_Random
}
