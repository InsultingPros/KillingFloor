//===================================================================
// ROVehicleWeapon
//
// Copyright (C) 2004 John "Ramm-Jaeger"  Gibson
//
// Base class for Red Orchestra vehicle mounted weapons
// TODO: Actually flesh this out
//===================================================================

class ROVehicleWeapon extends VehicleWeapon
	abstract;

// Tracers
var() class<Projectile> 	DummyTracerClass; 	// class for the dummy tracer for this weapon (does no damage)
var() 	float				mTracerInterval;
var 	float           	mLastTracerTime;
var()	bool				bUsesTracers;
var()	bool				bAltFireTracersOnly;

// Information for each specific hit area
struct Hitpoint
{
	var() float           	PointRadius;     	// Squared radius of the head of the pawn that is vulnerable to headshots
	var() float           	PointHeight;     	// Distance from base of neck to center of head - used for headshot calculation
	var() float				PointScale;
	var() name				PointBone;
	var() vector			PointOffset;		// Amount to offset the hitpoint from the bone
};

var() 	array<Hitpoint>		VehHitpoints; 	 // An array of possible small points that can be hit. Index zero is always the driver

// For HUD
var bool                    bIsMountedTankMG;   // Easier than making ROMountedTankMG accessible from ROEngine
var Material                hudAltAmmoIcon;     // Icon used with alternate amom type (alt fire), also used
                                                // for displaying icon for ROMountedTankMG

//
// TakeDamage - overloaded to prevent bayonet and bash attacks from damaging vehicles
//				for Tanks, we'll probably want to prevent bullets from doing damage too
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	// Fix for suicide death messages
    if (DamageType == class'Suicided')
    {
	    DamageType = class'ROSuicided';
	    ROVehicleWeaponPawn(Owner).TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	}
	else if (DamageType == class'ROSuicided')
	{
		ROVehicleWeaponPawn(Owner).TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	}

	if( HitDriver(Hitlocation, Momentum) )
	{
 		ROVehicleWeaponPawn(Owner).TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	}

}

// Returns true if the bullet hits below the angle that would hit the commander
simulated function bool BelowDriverAngle(vector loc, vector ray)
{
	return false;
}

// Trace along this vector will hit the driver
simulated function bool HitDriver(Vector Hitlocation, Vector Momentum)
{
	local ROVehicleWeaponPawn PwningPawn;

    PwningPawn = ROVehicleWeaponPawn(Owner);

    if( PwningPawn != none && PwningPawn.DriverPositions[PwningPawn.DriverPositionIndex].bExposed && HitDriverArea(Hitlocation, Momentum))
    {
    	return true;
    }

    return false;
}

// Trace along this vector will hit the driver area
simulated function bool HitDriverArea(Vector Hitlocation, Vector Momentum)
{
	local int i;

	if( !BelowDriverAngle(Hitlocation, Momentum) )
	{
		for(i=0; i<VehHitpoints.Length; i++)
		{
			if ( i < 2 )
			{
				if (  IsPointShot(Hitlocation,Normal(Momentum), 1.0, i))
				{
					//Level.Game.Broadcast(self, "Scored a hit on the driver");
					return true;
				}
			}
			else
			{
				break;
			}
		}
	}

	return false;
}

// Check to see if something hit a certain Hitpoint
function bool IsPointShot(vector loc, vector ray, float AdditionalScale, int index)
{
    local coords C;
    local vector HeadLoc, B, M, diff;
    local float t, DotMM, Distance;

    if (VehHitpoints[index].PointBone == '')
        return False;

    C = GetBoneCoords(VehHitpoints[index].PointBone);

    HeadLoc = C.Origin + (VehHitpoints[index].PointHeight * VehHitpoints[index].PointScale * AdditionalScale * C.XAxis);

	HeadLoc = HeadLoc + (VehHitpoints[index].PointOffset >> Rotator(C.Xaxis));

    // Express snipe trace line in terms of B + tM
    B = loc;
    M = ray * 150/*(2.0 * CollisionHeight + 2.0 * CollisionRadius)*/;

    // Find Point-Line Squared Distance
    diff = HeadLoc - B;
    t = M dot diff;
    if (t > 0)
    {
        DotMM = M dot M;
        if (t < DotMM)
        {
            t = t / DotMM;
            diff = diff - (t * M);
        }
        else
        {
            t = 1;
            diff -= M;
        }
    }
    else
        t = 0;

    Distance = Sqrt(diff Dot diff);

    return (Distance < (VehHitpoints[index].PointRadius * VehHitpoints[index].PointScale * AdditionalScale));
}

// Limit the left and right movement of the turret
simulated function int LimitYaw(int yaw)
{
    local int NewYaw;

    if ( !bLimitYaw )
    {
        return yaw;
    }

    NewYaw = yaw;

   	if( yaw > MaxPositiveYaw )
   	{
   		NewYaw = MaxPositiveYaw;
   	}
   	else if( yaw < MaxNegativeYaw )
   	{
   		NewYaw = MaxNegativeYaw;
  	}

  	return NewYaw;
}

function tick(float DeltaTime)
{
}

// Overridden so we can get animend calls
state InstantFireMode
{
    function Fire(Controller C)
    {
        FlashMuzzleFlash(false);

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

    function AltFire(Controller C)
    {
    }

    simulated event ClientSpawnHitEffects()
    {
    	local vector HitLocation, HitNormal, Offset;
    	local actor HitActor;

    	// if standalone, already have valid HitActor and HitNormal
    	if ( Level.NetMode == NM_Standalone )
    		return;
    	Offset = 20 * Normal(WeaponFireLocation - LastHitLocation);
    	HitActor = Trace(HitLocation, HitNormal, LastHitLocation - Offset, LastHitLocation + Offset, False);
    	SpawnHitEffects(HitActor, LastHitLocation, HitNormal);
    }

    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
    {
		local PlayerController PC;

		PC = Level.GetLocalPlayerController();
		if (PC != None && ((Instigator != None && Instigator.Controller == PC) || VSize(PC.ViewTarget.Location - HitLocation) < 5000))
		{
			// MergeTODO: Fix this
			//Spawn(class'HitEffect'.static.GetHitEffect(HitActor, HitLocation, HitNormal),,, HitLocation, Rotator(HitNormal));
			if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) )
			{
				// check for splash
				if ( Base != None )
				{
					Base.bTraceWater = true;
					HitActor = Base.Trace(HitLocation,HitNormal,HitLocation,Location + 200 * Normal(HitLocation - Location),true);
					Base.bTraceWater = false;
				}
				else
				{
					bTraceWater = true;
					HitActor = Trace(HitLocation,HitNormal,HitLocation,Location + 200 * Normal(HitLocation - Location),true);
					bTraceWater = false;
				}

				if ( (FluidSurfaceInfo(HitActor) != None) || ((PhysicsVolume(HitActor) != None) && PhysicsVolume(HitActor).bWaterVolume) )
					Spawn(class'BulletSplashEmitter',,,HitLocation,rot(16384,0,0));
			}
		}
    }

	// Notify the owning pawn that our animation ended
	simulated function AnimEnd(int channel)
	{
		if ( ROVehicleWeaponPawn(Owner) != none )
		{
			 ROVehicleWeaponPawn(Owner).AnimEnd(channel);
		}
	}
}

// Overridden so we can get animend calls
state ProjectileFireMode
{
	function Fire(Controller C)
	{
		SpawnProjectile(ProjectileClass, False);
	}

	function AltFire(Controller C)
	{
		if (AltFireProjectileClass == None)
		  	Fire(C);
		else
		  	SpawnProjectile(AltFireProjectileClass, True);
	}
}

// Added below for Tank reload sounds. Hacked in Now - clean up - Ramm
//do effects (muzzle flash, force feedback, etc) immediately for the weapon's owner (don't wait for replication)
simulated event OwnerEffects()
{
	local VehicleWeaponPawn WeaponPawn;

	// Stop the firing effects if we shouldn't be able to fire
	if( (Role < ROLE_Authority) && !ReadyToFire(bIsAltFire) )
	{
		VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bIsAltFire);
		return;
	}

    if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    ShakeView(bIsAltFire);

	if( Level.NetMode == NM_Standalone )
	{
		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);
	}

	if (Role < ROLE_Authority)
	{
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash(bIsAltFire);

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

        // Play firing noise
        if (!bAmbientFireSound)
        {
            WeaponPawn = VehicleWeaponPawn(Owner);


            if (bIsAltFire)
                PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            else
            {
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
            }
        }
		else if ( bIsAltFire && bAmbientAltFireSound )
		{
		    SoundVolume = AltFireSoundVolume;
            SoundRadius = AltFireSoundRadius;
			AmbientSoundScaling = AltFireSoundScaling;
		}
	}
}

simulated function FlashMuzzleFlash(bool bWasAltFire)
{
	Super.FlashMuzzleFlash(bWasAltFire);

    if (bUsesTracers && (!bWasAltFire && !bAltFireTracersOnly || bWasAltFire))
		UpdateTracer();
}

simulated function UpdateTracer()
{
	local rotator SpawnDir;

	if (Level.NetMode == NM_DedicatedServer || !bUsesTracers)
		return;

	if (Level.TimeSeconds > mLastTracerTime + mTracerInterval)
	{
		if (Instigator != None && Instigator.IsLocallyControlled())
			SpawnDir = WeaponFireRotation;
		else
			SpawnDir = GetBoneRotation(WeaponFireAttachmentBone);

        Spawn(DummyTracerClass,,, WeaponFireLocation, SpawnDir);

		mLastTracerTime = Level.TimeSeconds;
	}
}

simulated function int getNumMags()
{
    return -1;
}

defaultproperties
{
     bDramaticLighting=True
     AmbientGlow=5
}
