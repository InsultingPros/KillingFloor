//===================================================================
// ROTankCannon
//
// Copyright (C) 2004 John "Ramm-Jaeger"  Gibson
//
// Base class for RO tank cannons
//===================================================================
class ROTankCannon extends ROVehicleWeapon
      abstract;

// fixme - add proper MaxDriverHitAngles for each specific tank cannon

//#exec OBJ LOAD FILE=..\Sounds\Vehicle_Engines.uax
//#exec OBJ LOAD File=..\Textures\Weapons3rd_tex.utx

// Reloading stuff
var()   		sound               ReloadSoundOne; // THe reload sound - used to tank cannons right now
var()   		sound               ReloadSoundTwo; // THe reload sound - used to tank cannons right now
var()   		sound               ReloadSoundThree; // THe reload sound - used to tank cannons right now
var()   		sound               ReloadSoundFour; // THe reload sound - used to tank cannons right now

var()			sound				CannonFireSound[3]; // CannonFireSounds

var				enum				ECannonReloadState
{
    CR_Waiting,
	CR_Empty,
	CR_ReloadedPart1,
	CR_ReloadedPart2,
	CR_ReloadedPart3,
	CR_ReloadedPart4,
	CR_ReadyToFire,
}   CannonReloadState;

var             bool                bClientCanFireCannon; // Flag that is set on the server and replicated to the client that determines if the tank cannon can fire

var 			name 				TankShootClosedAnim;
var 			name 				TankShootOpenAnim;

var() 			float 				MaxDriverHitAngle;	// The lowest angle that we will allow a hit to count as a commander hit

// Projectiles
var     localized array<string>    ProjectileDescriptions;

var()   class<Emitter>				CannonDustEmitterClass; // Emitter for dust kicked up by the tank cannon firing
var     Emitter						CannonDustEmitter;

// Aiming
var() 	array<int>			RangeSettings; 		// The range settings this cannon has
var()	int					AddedPitch;			// Used for making adjustments to the tank cannon aiming
// Debugging
var		bool				bCannonShellDebugging;
var		vector				TraceHitLocation;

var()	sound ReloadSound; // sound of this MG reloading
var		int	  NumAltMags;  // Number of mags carried for the Coax MG;

var()   class<Projectile>   PendingProjectileClass;   // Secondary ProjectileClass that this weapon fires

//=============================================================================
// Replication
//=============================================================================

replication
{
    reliable if (bNetDirty && bNetOwner && Role == ROLE_Authority)
        NumAltMags, PendingProjectileClass;

    reliable if (bNetDirty && Role == ROLE_Authority)
        bClientCanFireCannon;

	// Functions the server calls on the client side.
	reliable if( Role == ROLE_Authority )
		ClientDoReload, ClientSetReloadState;

	// Functions the client calls on the server side.
	reliable if ( Role < ROLE_Authority )
	    ServerManualReload;
}

function CeaseFire(Controller C, bool bWasAltFire)
{
	super.CeaseFire(C, bWasAltFire);

	if( bWasAltFire && !HasAmmo(2) )
		HandleReload();
}

function HandleReload()
{
	if( NumAltMags > 0 )
	{
		NumAltMags--;
		AltAmmoCharge=InitialAltAmmo;
		ClientDoReload();
		NetUpdateTime = Level.TimeSeconds - 1;

		FireCountdown = GetSoundDuration( ReloadSound );
		PlaySound(ReloadSound, SLOT_None,1.5,, 25, ,true);
	}
}

// Set the fire countdown client side
simulated function ClientDoReload()
{
	FireCountdown = GetSoundDuration( ReloadSound );
	VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(true);
}

function bool GiveInitialAmmo()
{
	local bool bDidResupply;

	// If we don't need any ammo return false
	if( MainAmmoCharge[0] != InitialPrimaryAmmo || MainAmmoCharge[1] != InitialSecondaryAmmo
		|| NumAltMags != default.NumAltMags )
	{
		bDidResupply = true;
	}

	MainAmmoCharge[0] = InitialPrimaryAmmo;
	MainAmmoCharge[1] = InitialSecondaryAmmo;
	AltAmmoCharge = InitialAltAmmo;
	NumAltMags = default.NumAltMags;

	return bDidResupply;
}

// Return the current range setting (in meters) for this cannon
simulated function int GetRange()
{
	return RangeSettings[CurrentRangeIndex];
}

function IncrementRange()
{
	if( CurrentRangeIndex < RangeSettings.Length - 1 )
	{
		if( Instigator != none && Instigator.Controller != none && ROPlayer(Instigator.Controller) != none )
			ROPlayer(Instigator.Controller).ClientPlaySound(sound'ROMenuSounds.msfxMouseClick',false,,SLOT_Interface);

		CurrentRangeIndex++;
	}
}

function DecrementRange()
{
	if( CurrentRangeIndex > 0 )
	{
		if( Instigator != none && Instigator.Controller != none && ROPlayer(Instigator.Controller) != none )
			ROPlayer(Instigator.Controller).ClientPlaySound(sound'ROMenuSounds.msfxMouseClick',false,,SLOT_Interface);

		CurrentRangeIndex --;
	}
}

// Returns the name of the various round types as well as a 0-based int
// specifying which type is the active one
simulated function int GetRoundsDescription(out array<string> descriptions)
{
    local int i;
    descriptions.length = 0;
    for (i = 0; i < ProjectileDescriptions.length; i++)
        descriptions[i] = ProjectileDescriptions[i];

    if (ProjectileClass == PrimaryProjectileClass)
        return 0;
    else if (ProjectileClass == SecondaryProjectileClass)
        return 1;
    else
        return 2;
}

// Returns a 0-based int specifying which round type is the pending round
simulated function int GetPendingRoundIndex()
{
    if( PendingProjectileClass == none )
    {
	    if (ProjectileClass == PrimaryProjectileClass)
	        return 0;
	    else if (ProjectileClass == SecondaryProjectileClass)
	        return 1;
	    else
	        return 2;
    }
    else
    {
		if (PendingProjectileClass == PrimaryProjectileClass)
		    return 0;
		else if (PendingProjectileClass == SecondaryProjectileClass)
		    return 1;
		else
		    return 2;
    }
}

function ToggleRoundType()
{
	if( PendingProjectileClass == PrimaryProjectileClass || PendingProjectileClass == none )
	{
		if( !HasAmmo(1) )
			return;

		PendingProjectileClass = SecondaryProjectileClass;
	}
	else
	{
		if( !HasAmmo(0) )
			return;

	   	PendingProjectileClass = PrimaryProjectileClass;
	}
}

// Returns true if the bullet hits below the angle that would hit the commander
simulated function bool BelowDriverAngle(vector loc, vector ray)
{
	local float InAngle;
    local vector X,Y,Z;
	local vector HitDir;
	local coords C;
    local vector HeadLoc;

    GetAxes(Rotation,X,Y,Z);

    C = GetBoneCoords(VehHitpoints[0].PointBone);
    HeadLoc = C.Origin + (VehHitpoints[0].PointHeight * VehHitpoints[0].PointScale * C.XAxis);
	HeadLoc = HeadLoc + (VehHitpoints[0].PointOffset >> Rotator(C.Xaxis));

    HitDir = loc - HeadLoc;

    InAngle= Acos(Normal(HitDir) dot Normal(C.ZAxis));

	// Hitangle debugging
	/*
	log("Inangle = "$InAngle$" MaxDriverHitAngle = "$MaxDriverHitAngle);
	Level.Game.Broadcast(self, "Inangle = "$InAngle$" MaxDriverHitAngle = "$MaxDriverHitAngle);

    ClearStayingDebugLines();

    DrawStayingDebugLine( HeadLoc, (HeadLoc + (30 * Normal(C.ZAxis))), 255, 0, 0); // SLOW! Use for debugging only!
    DrawStayingDebugLine( loc, (loc + (45 * Normal(ray))), 0, 255, 0); // SLOW! Use for debugging only!
	*/


    if( InAngle > MaxDriverHitAngle )
    {
    	//Level.Game.Broadcast(self, "Angle is too low");
		return true;
    }

	return false;
}

simulated function Timer()
{
   if ( VehicleWeaponPawn(Owner) == none || VehicleWeaponPawn(Owner).Controller == none )
   {
      //log(" Returning because there is no controller");
      SetTimer(0.05,true);
   }
   else if ( CannonReloadState == CR_Empty )
   {
         if (Role == ROLE_Authority)
	     {
              PlayOwnedSound(ReloadSoundOne, SLOT_Misc, FireSoundVolume/255.0,, 150,, false);
         }
         else
         {
              PlaySound(ReloadSoundOne, SLOT_Misc, FireSoundVolume/255.0,, 150,, false);
         }
         CannonReloadState = CR_ReloadedPart1;
         GetSoundDuration(ReloadSoundThree) + GetSoundDuration(ReloadSoundFour);
         SetTimer(GetSoundDuration(ReloadSoundOne),false);
   }
   else if ( CannonReloadState == CR_ReloadedPart1 )
   {
         if (Role == ROLE_Authority)
	     {
              PlayOwnedSound(ReloadSoundTwo, SLOT_Misc, FireSoundVolume/255.0,, 150,, false);
         }
         else
         {
              PlaySound(ReloadSoundTwo, SLOT_Misc, FireSoundVolume/255.0,, 150,, false);
         }

         CannonReloadState = CR_ReloadedPart2;
         GetSoundDuration(ReloadSoundFour);
         SetTimer(GetSoundDuration(ReloadSoundTwo),false);
   }
   else if ( CannonReloadState == CR_ReloadedPart2 )
   {
         if (Role == ROLE_Authority)
	     {
              PlayOwnedSound(ReloadSoundThree, SLOT_Misc, FireSoundVolume/255.0,, 150,, false);
         }
         else
         {
              PlaySound(ReloadSoundThree, SLOT_Misc, FireSoundVolume/255.0,, 150,, false);
         }

         CannonReloadState = CR_ReloadedPart3;
         SetTimer(GetSoundDuration(ReloadSoundThree),false);
   }
   else if ( CannonReloadState == CR_ReloadedPart3 )
   {
         if (Role == ROLE_Authority)
	     {
              PlayOwnedSound(ReloadSoundFour, SLOT_Misc, FireSoundVolume/255.0,, 150,, false);
         }
         else
         {
              PlaySound(ReloadSoundFour, SLOT_Misc, FireSoundVolume/255.0,, 150,, false);
         }

         CannonReloadState = CR_ReloadedPart4;
         SetTimer(GetSoundDuration(ReloadSoundFour),false);
   }
   else if ( CannonReloadState == CR_ReloadedPart4 )
   {
		if(Role == ROLE_Authority)
		{
			bClientCanFireCannon = true;
		}
		CannonReloadState = CR_ReadyToFire;
		SetTimer(0.0,false);
   }
}

simulated event OwnerEffects()
{
	// Stop the firing effects it we shouldn't be able to fire
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

	if( Level.NetMode == NM_Standalone && bIsAltFire)
	{
		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);
	}

	if (Role < ROLE_Authority)
	{
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		/*else
			FireCountdown = FireInterval;*/
		

		if( !bIsAltFire )
		{
			if( Instigator != none && Instigator.Controller != none && ROPlayer(Instigator.Controller) != none &&
                ROPlayer(Instigator.Controller).bManualTankShellReloading == true )
            {
			    CannonReloadState = CR_Waiting;
			}
			else
			{
	            CannonReloadState = CR_Empty;
	            SetTimer(0.01, false);
	        }

			bClientCanFireCannon = false;
		}

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash(bIsAltFire);

		if (AmbientEffectEmitter != None && bIsAltFire)
			AmbientEffectEmitter.SetEmitterStatus(true);

        if (bIsAltFire)
		{
            if( !bAmbientAltFireSound )
		    	PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
		    else
		    {
			    SoundVolume = AltFireSoundVolume;
	            SoundRadius = AltFireSoundRadius;
				AmbientSoundScaling = AltFireSoundScaling;
		    }
        }
		else if (!bAmbientFireSound)
        {
            PlaySound(CannonFireSound[Rand(3)], SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local VehicleWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent;
    local rotator FireRot;

	FireRot = WeaponFireRotation;

	// used only for Human players. Lets cannons with non centered aim points have a different aiming location
	if( Instigator != none && Instigator.IsHumanControlled() )
	{
  		FireRot.Pitch += AddedPitch;
	}

	if( !bAltFire )
		FireRot.Pitch += ProjClass.static.GetPitchForRange(RangeSettings[CurrentRangeIndex]);

    if( bCannonShellDebugging )
		log("GetPitchForRange for "$CurrentRangeIndex$" = "$ProjClass.static.GetPitchForRange(RangeSettings[CurrentRangeIndex]));

    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
       	WeaponPawn = VehicleWeaponPawn(Owner);
    	if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    	{
    		if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
	else
	{
		if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
    }
    else
    	StartLocation = WeaponFireLocation;

	if( bCannonShellDebugging )
		Trace(TraceHitLocation, HitNormal, WeaponFireLocation + 65355 * Vector(WeaponFireRotation), WeaponFireLocation, false);

    P = spawn(ProjClass, none, , StartLocation, FireRot); //self

   //swap to the next round type after firing
    if( PendingProjectileClass != none && ProjClass == ProjectileClass && ProjectileClass != PendingProjectileClass )
	{
		ProjectileClass = PendingProjectileClass;
	}
    //log("WeaponFireRotation = "$WeaponFireRotation);

    if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash(bAltFire);

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
            {
                AmbientSound = AltFireSoundClass;
                SoundVolume = AltFireSoundVolume;
                SoundRadius = AltFireSoundRadius;
                AmbientSoundScaling = AltFireSoundScaling;
            }
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
            {
                PlayOwnedSound(CannonFireSound[Rand(3)], SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
            }
        }
    }

    return P;
}

simulated function HandleShellDebug(vector RealHitLocation)
{
	if( bCannonShellDebugging )
		log("BulletDrop = "$(((TraceHitLocation.Z - RealHitLocation.Z) / 18.4) * 12));
}

//ClientStartFire() and ClientStopFire() are only called for the client that owns the weapon (and not at all for bots)
simulated function ClientStartFire(Controller C, bool bAltFire)
{
    bIsAltFire = bAltFire;

	if((!bIsAltFire && CannonReloadState == CR_ReadyToFire && bClientCanFireCannon) || ( bIsAltFire && FireCountdown <= 0))
	{
        if (bIsRepeatingFF)
		{
			if (bIsAltFire)
				ClientPlayForceFeedback( AltFireForce );
			else
				ClientPlayForceFeedback( FireForce );
		}
		OwnerEffects();
	}
}

// Returns true if this weapon is ready to fire
simulated function bool ReadyToFire(bool bAltFire)
{
	local int Mode;

	if(	bAltFire )
		Mode = 2;
	else if (ProjectileClass == PrimaryProjectileClass)
		Mode = 0;
	else if (ProjectileClass == SecondaryProjectileClass)
		Mode = 1;

    if( !bAltFire && (CannonReloadState != CR_ReadyToFire || !bClientCanFireCannon))
    	return false;

	if( HasAmmo(Mode) )
		return true;

	return false;
}

function ServerManualReload()
{
    if(Role != ROLE_Authority)
        return;

    if( CannonReloadState == CR_Waiting )
    {
        //If the user wants a different ammo type, switch on reload
        if( PendingProjectileClass != none && ProjectileClass != PendingProjectileClass )
	   	    ProjectileClass = PendingProjectileClass;

	   	//Tell the client to start reloading
	   	ClientSetReloadState(CR_Empty);

	    //Start the reloading process
        CannonReloadState = CR_Empty;
        SetTimer(0.01, false);
    }
}

simulated function ClientSetReloadState( ECannonReloadState NewState )
{
    CannonReloadState = NewState;
    SetTimer(0.01, false);
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if ( (!bAltFire && CannonReloadState == CR_ReadyToFire && bClientCanFireCannon) || (bAltFire && FireCountdown <= 0))
	{
		CalcWeaponFire(bAltFire);
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if( bAltFire )
		{
			if( AltFireSpread > 0 )
				WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*AltFireSpread);
		}
		else if (Spread > 0)
		{
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);
		}

        DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			if( !ConsumeAmmo(2) )
			{
				VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
				HandleReload();
				return false;
			}

			FireCountdown = AltFireInterval;
			AltFire(C);

			if( AltAmmoCharge < 1 )
				HandleReload();
		}
		else
		{
		    //FireCountdown = FireInterval;
			if( bMultipleRoundTypes )
			{
				if (ProjectileClass == PrimaryProjectileClass)
				{
					if( !ConsumeAmmo(0) )
					{
						VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
						return false;
					}
					else
					{
						if( !HasAmmo(0) && HasAmmo(1) )
						{
							ToggleRoundType();
						}
					}
			    }
			    else if (ProjectileClass == SecondaryProjectileClass)
			    {
					if( !ConsumeAmmo(1) )
					{
						VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
						return false;
					}
					else
					{
						if( !HasAmmo(1) && HasAmmo(0) )
						{
							ToggleRoundType();
						}
					}
			    }
			}
			else if( !ConsumeAmmo(0) )
			{
				VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
				return false;
			}

			if( Instigator != none && Instigator.Controller != none && ROPlayer(Instigator.Controller) != none &&
                ROPlayer(Instigator.Controller).bManualTankShellReloading == true )
            {
			    CannonReloadState = CR_Waiting;
			}
			else
			{
	            CannonReloadState = CR_Empty;
	            SetTimer(0.01, false);
	        }

	        bClientCanFireCannon = false;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}
static function StaticPrecache(LevelInfo L)
{
//	L.AddPrecacheMaterial(Material'Weapons3rd_tex.tank_shells.shell_122mm');
//	L.AddPrecacheMaterial(Material'Weapons3rd_tex.tank_shells.shell_76mm');
//	L.AddPrecacheMaterial(Material'Weapons3rd_tex.tank_shells.shell_85mm');
    L.AddPrecacheMaterial(Material'Effects_Tex.fire_quad');
    L.AddPrecacheMaterial(Material'ROEffects.SmokeAlphab_t');
}

simulated function UpdatePrecacheMaterials()
{
//	Level.AddPrecacheMaterial(Material'Weapons3rd_tex.tank_shells.shell_122mm');
//	Level.AddPrecacheMaterial(Material'Weapons3rd_tex.tank_shells.shell_76mm');
//	Level.AddPrecacheMaterial(Material'Weapons3rd_tex.tank_shells.shell_85mm');
    Level.AddPrecacheMaterial(Material'Effects_Tex.fire_quad');
    Level.AddPrecacheMaterial(Material'ROEffects.SmokeAlphab_t');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	if( PrimaryProjectileClass != none )
        Level.AddPrecacheStaticMesh(PrimaryProjectileClass.default.StaticMesh);
	if( SecondaryProjectileClass != none )
        Level.AddPrecacheStaticMesh(SecondaryProjectileClass.default.StaticMesh);
	Super.UpdatePrecacheStaticMeshes();
}

function byte BestMode()
{
	if (Vehicle(Instigator.Controller.Target) != None)
		return 0;

	return 2;
}

// Overridden so we can get animend calls
state ProjectileFireMode
{
	// Notify the owning pawn that our animation ended
	simulated function AnimEnd(int channel)
	{
		//log("Animend got called VehicleWeapon ROVehicleWeaponPawn(Owner) ="$ROVehicleWeaponPawn(Owner));

		if ( ROVehicleWeaponPawn(Owner) != none )
		{
			 ROVehicleWeaponPawn(Owner).AnimEnd(channel);
		}
	}
}

simulated event FlashMuzzleFlash(bool bWasAltFire)
{
 	local ROVehicleWeaponPawn OwningPawn;

    if (Role == ROLE_Authority)
    {
        if (bWasAltFire)
            FiringMode = 1;
        else
            FiringMode = 0;
    	FlashCount++;
    	NetUpdateTime = Level.TimeSeconds - 1;
    }
    else
        CalcWeaponFire(bWasAltFire);

    if (bUsesTracers && (!bWasAltFire && !bAltFireTracersOnly || bWasAltFire))
		UpdateTracer();

	if( bWasAltFire )
		return;

    if (FlashEmitter != None)
        FlashEmitter.Trigger(Self, Instigator);

    if ( (EffectEmitterClass != None) && EffectIsRelevant(Location,false) )
        EffectEmitter = spawn(EffectEmitterClass, self,, WeaponFireLocation, WeaponFireRotation);

    if ( (CannonDustEmitterClass != None) && EffectIsRelevant(Location,false) )
        CannonDustEmitter = spawn(CannonDustEmitterClass, self,, Base.Location, Base.Rotation);

	OwningPawn = ROVehicleWeaponPawn(Instigator);

	if( OwningPawn != none && OwningPawn.DriverPositions[OwningPawn.DriverPositionIndex].bExposed)
	{
		if( HasAnim(TankShootOpenAnim))
			PlayAnim(TankShootOpenAnim);
	}
	else if( HasAnim(TankShootClosedAnim))
	{
		PlayAnim(TankShootClosedAnim);
	}
}

simulated function DestroyEffects()
{
	super.DestroyEffects();

    if (CannonDustEmitter != None)
    	CannonDustEmitter.Destroy();
}

simulated function int getNumMags()
{
    return NumAltMags;
}

defaultproperties
{
     CannonReloadState=CR_ReadyToFire
     bClientCanFireCannon=True
     TankShootClosedAnim="shoot_close"
     TankShootOpenAnim="shoot_open"
     MaxDriverHitAngle=2.500000
     ProjectileDescriptions(0)="AP"
     ProjectileDescriptions(1)="HE"
     CannonDustEmitterClass=Class'ROEffects.TankCannonDust'
     hudAltAmmoIcon=Texture'InterfaceArt_tex.HUD.dp27_ammo'
     bShowAimCrosshair=False
     AltFireSpread=0.015000
     FireSoundRadius=4000.000000
     RotateSoundThreshold=750.000000
     AIInfo(0)=(aimerror=0.000000,RefireRate=5.000000)
     bRotateSoundFromPawn=True
     bUseTankTurretRotation=True
     bMultipleRoundTypes=True
     bPrimaryIgnoreFireCountdown=True
     bCollideActors=True
     bBlockActors=True
     bProjTarget=True
     bBlockZeroExtentTraces=True
     bBlockNonZeroExtentTraces=True
}
