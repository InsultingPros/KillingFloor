//===================================================================
// ROTreadCraft
//
// Copyright (C) 2004 John "Ramm-Jaeger"  Gibson
//
// Base Class for all Red Orchestra tread driven vehicles
//===================================================================
Class ROTreadCraft extends ROWheeledVehicle
	abstract;

//=============================================================================
// Variables
//=============================================================================

var()   float                 MaxPitchSpeed;
var     VariableTexPanner     LeftTreadPanner, RightTreadPanner;
var()   float                 TreadVelocityScale;

// sound attachment actor variables
//var()   sound               EngineSound;
var()   	sound               LeftTreadSound;    // Sound for the left tread squeaking
var()   	sound               RightTreadSound;   // Sound for the right tread squeaking
var()   	Sound               RumbleSound;       // Interior rumble sound
var     	bool                bPlayTreadSound;
var     	float               TreadSoundVolume;
//var     ROSoundAttachment   EngineSoundAttach;
var     	ROSoundAttachment   LeftTreadSoundAttach;
var     	ROSoundAttachment   RightTreadSoundAttach;
var     	ROSoundAttachment   InteriorRumbleSoundAttach;
var     	float               MotionSoundVolume;
var()   	name                LeftTrackSoundBone;
var()   	name                RightTrackSoundBone;
var()   	name                RumbleSoundBone;
var()   	sound               TrackDamagedSound; // sound to play when the track is damaged

// Tank hud vars
var     	ROTankCannon        CannonTurret;        // A pointer to this tank's turret weapon
var     	VehicleWeapon       HullMG;              // A pointer to this tank's hull mg weapon
var     	TexRotator          TurretRot;

// Tank hud icons
var         TexRotator          VehicleHudTurret;
var         TexRotator          VehicleHudTurretLook;
var         float               VehicleHudThreadsPosX[2]; // 0 = left thread, 1 = right thread
var         float               VehicleHudThreadsPosY; // both threads always draw at same Y pos
var         float               VehicleHudThreadsScale; // both threads always draw with same scale


var			Material			TankIcon;
var			Material			RedDot;
var			Material			GrayDot;
var			Material			TreadIcon;
var()   	float               DriverDotX;
var()   	float               DriverDotY;
var()   	float               CannonDotX;
var()   	float               CannonDotY;
var()   	float               HullMGDotX;
var()   	float               HullMGDotY;
var()   	float               LeftTreadX;
var()   	float               LeftTreadY;
var()   	float               RightTreadX;
var()   	float               RightTreadY;

// Vehicle animation variables
var     name                  IdleHatchOpenAnim;
var     name                  IdleHatchClosedAnim;
var     name                  HatchOpenAnim;
var     name                  HatchCloseAnim;

var()	InterpCurve		AddedLatFriction;

// Wheel animation
var() 	array<name>		LeftWheelBones; 	// for animation only - the bone names for the wheels on the left side
var() 	array<name>		RightWheelBones; 	// for animation only - the bone names for the wheels on the right side

var 		rotator 			LeftWheelRot;       // Keep track of the left wheels rotational speed for animation
var 		rotator 			RightWheelRot;      // Keep track of the right wheels rotational speed for animation
var()		int					WheelRotationScale;
// Armor values
var		int			FrontArmorFactor;
var		int			RearArmorFactor;
var		int			SideArmorFactor;
var     bool        bHasAddedSideArmor; // This tank has special added side armor skirts (Schurzen)

var 	float		TreadHitMinAngle;	// Any hits bigger than this angle are considered tread hits
var     bool		bLeftTrackDamaged;  // The left track has been damaged
var     bool		bRightTrackDamaged; // The left track has been damaged
var		float		IntendedThrottle;	// Revving the engine up when you can't move
var 	bool		bWantsToThrottle;	// Trying to throttle, but can't move

var float LinTurnSpeed;

var bool  bDebugPenetration;            // Display penetration debugging info
var() float FrontLeftAngle, FrontRightAngle, RearRightAngle, RearLeftAngle; // Used by the hit detection system to determin which side the tank was hit on
//=============================================================================
// replication
//=============================================================================

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority && bDisableThrottle )
        	bWantsToThrottle;//IntendedThrottle;

	reliable if( bNetDirty && Role==ROLE_Authority /*&& bDisableThrottle*/ )
        	bRightTrackDamaged, bLeftTrackDamaged;
}

// Temp code to get the bots using tanks better
//function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
//{
//	local Bot B;
//	local SquadAI Squad;
//	local int Num;
//
//	//if ( Level.Game.JustStarted(20) && !Level.Game.IsA('ASGameInfo') )
//	//	return Super.BotDesireability(S, TeamIndex, Objective);
//
//	Squad = SquadAI(S);
//
//	if (Squad.Size == 1)
//	{
//		//if ( (Squad.Team != None) && (Squad.Team.Size == 1) && Level.Game.IsA('ASGameInfo') )
//		//	return Super.BotDesireability(S, TeamIndex, Objective);
//		return 0;
//	}
//
//	for (B = Squad.SquadMembers; B != None; B = B.NextSquadMember)
//		if (Vehicle(B.Pawn) == None && (B.RouteGoal == self || B.Pawn == None || VSize(B.Pawn.Location - Location) < Squad.MaxVehicleDist(B.Pawn)))
//			Num++;
//
//	if ( Num < 2 )
//		return 0;
//
	//	return Super.BotDesireability(S, TeamIndex, Objective);
//}

// Temp code to get the bots using tanks better
function Vehicle FindEntryVehicle(Pawn P)
{
	local Bot B;
	local int i;

	//if ( Level.Game.JustStarted(20) )
	//	return Super.FindEntryVehicle(P);

	B = Bot(P.Controller);
	if (B == None || WeaponPawns.length == 0 || !IsVehicleEmpty()  /*||((B.PlayerReplicationInfo.Team != None) && (B.PlayerReplicationInfo.Team.Size == 1) && Level.Game.IsA('ASGameInfo'))*/ )
		return Super.FindEntryVehicle(P);

	for (i = WeaponPawns.length - 1; i >= 0; i--)
		if (WeaponPawns[i].Driver == None)
			return WeaponPawns[i];

	return Super.FindEntryVehicle(P);
}

simulated function bool HitPenetrationPoint(vector HitLocation, vector HitRay)
{
	local bool bHitAPoint;
	local int i;

	for(i=0; i<VehHitpoints.Length; i++)
	{
		if ( VehHitpoints[i].bPenetrationPoint && IsPointShot(Hitlocation,300 * HitRay, 1.0, i) )
		{
			if( VehHitpoints[i].HitPointType == HP_Driver )
			{
			    if ( Driver != none && !DriverPositions[DriverPositionIndex].bExposed )
	  			continue;
			}

			bHitAPoint = true;
			break;
		}
	}

	if (bHitAPoint)
		return true;
	else
	 	return false;
}

// Returns true if this tank is disabled
simulated function bool IsDisabled()
{
	return ((EngineHealth <= 0) || bLeftTrackDamaged || bRightTrackDamaged);
}

//=============================================================================
// Functions
//=============================================================================

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

//	if( Level.NetMode != NM_Client && ROTeamGame(Level.Game).LevelInfo != none )
//	{
//		if( GetTeamNum() == 0 && ROTeamGame(Level.Game).LevelInfo.DefendingSide == SIDE_Axis )
//		{
//			if( FRand() > 0.5 )
//			{
//				bDefensive = true;
//			}
//		}
//		else if( GetTeamNum() == 1 && ROTeamGame(Level.Game).LevelInfo.DefendingSide == SIDE_Allies )
//		{
//			if( FRand() > 0.5 )
//			{
//				bDefensive = true;
//			}
//		}
//	}


	if ( Level.NetMode != NM_DedicatedServer )
	{
		SetupTreads();


 /*  	//add this back in if we add engine sound attachment points
        EngineSoundAttach = Spawn(class 'ROSoundAttachment');
        EngineSoundAttach.AmbientSound = IdleSound;
        //EngineSoundAttach.SoundVolume = default.SoundVolume;
        AttachToBone(LeftTreadSoundAttach, 'T34_Body');*/

        if (  LeftTreadSoundAttach == none )
        {
   	         LeftTreadSoundAttach = Spawn(class 'ROSoundAttachment');
             LeftTreadSoundAttach.AmbientSound = LeftTreadSound;
             AttachToBone(LeftTreadSoundAttach, LeftTrackSoundBone);
        }

        if (  RightTreadSoundAttach == none )
        {
             RightTreadSoundAttach = Spawn(class 'ROSoundAttachment');
             RightTreadSoundAttach.AmbientSound = RightTreadSound;
             AttachToBone(RightTreadSoundAttach, RightTrackSoundBone );
        }

        if (  InteriorRumbleSoundAttach == none )
        {
             InteriorRumbleSoundAttach = Spawn(class 'ROSoundAttachment');
             InteriorRumbleSoundAttach.AmbientSound = RumbleSound;
             AttachToBone(InteriorRumbleSoundAttach, RumbleSoundBone );
        }
	}
}

simulated function PostNetBeginPlay()
{
    local int x;
    super.PostNetBeginPlay();

    for (x = 0; x < Weapons.length; x++)
    {
        if( ROTankCannon(Weapons[x]) != none )
        {
           CannonTurret= ROTankCannon(Weapons[x]);
           break;
        }
    }
}

simulated function UpdatePrecacheMaterials()
{
/*    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.sparkfinal2');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.radialexplosion_1frame');
    Level.AddPrecacheMaterial(Material'Effects_Tex.Weapons.muzzle_4frame3rd');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.shrapnel1');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.concrete_chunks');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowfinal2');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowchunksfinal');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.waterring_2frame');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersplashcloud');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersplatter2');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersmoke');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.woodchunksfinal');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_dirt');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_snow');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.glowfinal');
    Level.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtchunks');

    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_snow');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_snow');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_snow');
*/
	Super.UpdatePrecacheMaterials();
}

static function StaticPrecache(LevelInfo L)
{
	Super.StaticPrecache(L);
/*
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.sparkfinal2');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.radialexplosion_1frame');
    L.AddPrecacheMaterial(Material'Effects_Tex.Weapons.muzzle_4frame3rd');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.shrapnel1');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.concrete_chunks');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowfinal2');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.snowchunksfinal');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.waterring_2frame');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersplashcloud');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersplatter2');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.watersmoke');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.woodchunksfinal');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_dirt');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_snow');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.glowfinal');
    L.AddPrecacheMaterial(Material'Effects_Tex.BulletHits.dirtchunks');

    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_snow');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_snow');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.aptankmark_snow');
*/
}

// DriverLeft() called by KDriverLeave()
function DriverLeft()
{
 /*   if ( EngineSoundAttach != None )
        EngineSoundAttach.SoundVolume = 0;
 */
    // Not moving, so no motion sound
    MotionSoundVolume=0.0;
    UpdateMovementSound();

    Super.DriverLeft();
}

simulated event DrivingStatusChanged()
{
    Super.DrivingStatusChanged();

    if (!bDriving)
    {
        if ( LeftTreadPanner != None )
            LeftTreadPanner.PanRate = 0.0;

        if ( RightTreadPanner != None )
            RightTreadPanner.PanRate = 0.0;

        // Not moving, so no motion sound
        MotionSoundVolume=0.0;
        UpdateMovementSound();
    }
}

simulated function UpdateMovementSound()
{
    if (  LeftTreadSoundAttach != none && !bLeftTrackDamaged)
    {
       LeftTreadSoundAttach.SoundVolume= MotionSoundVolume * 0.75;
    }

    if (  RightTreadSoundAttach != none && !bRightTrackDamaged)
    {
       RightTreadSoundAttach.SoundVolume= MotionSoundVolume * 0.75;
    }

    if (  InteriorRumbleSoundAttach != none)
    {
       InteriorRumbleSoundAttach.SoundVolume= MotionSoundVolume;
    }
}

simulated function Destroyed()
{
	DestroyTreads();
	if( LeftTreadSoundAttach != none )
	    LeftTreadSoundAttach.Destroy();
    if( RightTreadSoundAttach != none )
	    RightTreadSoundAttach.Destroy();
    if( InteriorRumbleSoundAttach != none )
	    InteriorRumbleSoundAttach.Destroy();

	super.Destroyed();
}

simulated function SetupTreads()
{
	LeftTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( LeftTreadPanner != None )
	{
		LeftTreadPanner.Material = Skins[2];
		LeftTreadPanner.PanDirection = rot(0, 0, 16384);
		LeftTreadPanner.PanRate = 0.0;
		Skins[2] = LeftTreadPanner;
	}
	RightTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( RightTreadPanner != None )
	{
		RightTreadPanner.Material = Skins[3];
		RightTreadPanner.PanDirection = rot(0, 0, 16384);
		RightTreadPanner.PanRate = 0.0;
		Skins[3] = RightTreadPanner;
	}
}

simulated function DestroyTreads()
{
	if ( LeftTreadPanner != None )
	{
		Level.ObjectPool.FreeObject(LeftTreadPanner);
		LeftTreadPanner = None;
	}
	if ( RightTreadPanner != None )
	{
		Level.ObjectPool.FreeObject(RightTreadPanner);
		RightTreadPanner = None;
	}
}

simulated function Tick(float DeltaTime)
{
	local float MotionSoundTemp;
	local KRigidBodyState BodyState;
	local float MySpeed;
	local int i;

	KGetRigidBodyState(BodyState);
	LinTurnSpeed = 0.5 * BodyState.AngVel.Z;

	// Only need these effects client side
	if( Level.Netmode != NM_DedicatedServer )
	{
		if( bDisableThrottle)
		{
			if(bWantsToThrottle)
			{
				IntendedThrottle=1.0;
			}
			else if( IntendedThrottle > 0)
			{
				IntendedThrottle -= (DeltaTime * 0.5);
			}
			else
			{
				IntendedThrottle=0;
			}

			if( bLeftTrackDamaged )
			{
				 if( LeftTreadSoundAttach.AmbientSound != TrackDamagedSound)
				 	LeftTreadSoundAttach.AmbientSound = TrackDamagedSound;
			     LeftTreadSoundAttach.SoundVolume= IntendedThrottle * 255;
			}

			if( bRightTrackDamaged )
			{
				 if( RightTreadSoundAttach.AmbientSound != TrackDamagedSound)
				 	RightTreadSoundAttach.AmbientSound = TrackDamagedSound;
				 RightTreadSoundAttach.SoundVolume= IntendedThrottle * 255;
			}

			SoundVolume = FMax(255 * 0.3,IntendedThrottle * 255);
		}
		else
		{
			if (SoundVolume != default.SoundVolume)
			{
				SoundVolume = default.SoundVolume;
			}
			//LeftTreadSoundAttach.SoundVolume=MotionSoundVolume;
			//RightTreadSoundAttach.SoundVolume=MotionSoundVolume;
		}


		// Shame on you Psyonix, for calling VSize() 3 times every tick, when it only needed to be called once.
		// VSize() is very CPU intensive - Ramm
		MySpeed = VSize(Velocity);

		// Setup sounds that are dependent on velocity
		MotionSoundTemp =  MySpeed/MaxPitchSpeed * 255;
		if ( MySpeed > 0.1 )
		{
		  	MotionSoundVolume =  FClamp(MotionSoundTemp, 0, 255);
		}
		else
		{
		  	MotionSoundVolume=0;
		}
		UpdateMovementSound();

//		KGetRigidBodyState(BodyState);
//		LinTurnSpeed = 0.5 * BodyState.AngVel.Z;

		if ( LeftTreadPanner != None )
		{
			LeftTreadPanner.PanRate = MySpeed / TreadVelocityScale;
			if (Velocity dot Vector(Rotation) < 0)
				LeftTreadPanner.PanRate = -1 * LeftTreadPanner.PanRate;
			LeftTreadPanner.PanRate += LinTurnSpeed;
		}

		if ( RightTreadPanner != None )
		{
			RightTreadPanner.PanRate = MySpeed / TreadVelocityScale;
			if (Velocity Dot Vector(Rotation) < 0)
				RightTreadPanner.PanRate = -1 * RightTreadPanner.PanRate;
			RightTreadPanner.PanRate -= LinTurnSpeed;
		}

		// Animate the tank wheels
		LeftWheelRot.pitch += LeftTreadPanner.PanRate * WheelRotationScale;
		RightWheelRot.pitch += RightTreadPanner.PanRate * WheelRotationScale;

		for(i=0; i<LeftWheelBones.Length; i++)
		{
			  SetBoneRotation(LeftWheelBones[i], LeftWheelRot);
		}

		for(i=0; i<RightWheelBones.Length; i++)
		{
			  SetBoneRotation(RightWheelBones[i], RightWheelRot);
		}
	}

	// This will slow the tank way down when it tries to turn at high speeds
	if( ForwardVel > 0.0)
     	WheelLatFrictionScale = InterpCurveEval(AddedLatFriction, ForwardVel);
     else
     	WheelLatFrictionScale = default.WheelLatFrictionScale;


	Super.Tick( DeltaTime );
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function DriverRadiusDamage(float DamageAmount, float DamageRadius, Controller EventInstigator, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local int i;
	local float damageScale, dist;
	local vector dir;

	//log("DriverRadiusDamage is screwing us");
	//return;

	//if driver has collision, whatever is causing the radius damage will hit the driver by itself
	if (EventInstigator == None || Driver == None || Driver.bCollideActors || bRemoteControlled)
		return;

       //log("Driver ="$Driver$" bExposed "$DriverPositions[DriverPositionIndex].bExposed);

	dir = Driver.Location - HitLocation;
	dist = FMax(1, VSize(dir));
	dir = dir/dist;
	damageScale = 1 - FMax(0,(dist - Driver.CollisionRadius)/DamageRadius);
	if (damageScale <= 0)
		return;

	if ( Driver != none && DriverPositions[DriverPositionIndex].bExposed )
    {
    	Driver.SetDelayedDamageInstigatorController(EventInstigator);
    	Driver.TakeDamage( damageScale * DamageAmount, EventInstigator.Pawn, Driver.Location - 0.5 * (Driver.CollisionHeight + Driver.CollisionRadius) * dir,
    			   damageScale * Momentum * dir, DamageType );
	}

	for (i = 0; i < WeaponPawns.length; i++)
		if (!WeaponPawns[i].bCollideActors)
			WeaponPawns[i].DriverRadiusDamage(DamageAmount, DamageRadius, EventInstigator, DamageType, Momentum, HitLocation);
}

function DamageTrack(bool bLeftTrack)
{
	if(bLeftTrack)
	{
		bDisableThrottle=true;
        bLeftTrackDamaged=true;
	}
	else
	{
		bDisableThrottle=true;
        bRightTrackDamaged=true;
	}
}

function bool StronglyRecommended(Actor S, int TeamIndex, Actor Objective)
{
	return True;
}

//
// TakeDamage - overloaded to prevent bayonet and bash attacks from damaging vehicles
//				for Tanks, we'll probably want to prevent bullets from doing damage too
function TakeDamage(int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	local vector LocDir, HitDir;
	local float HitAngle,Side, InAngle;
    local vector X,Y,Z;
    local int i;
    local float VehicleDamageMod;
    local int HitPointDamage;
	local int InstigatorTeam;
	local controller InstigatorController;

	// Fix for suicide death messages
    if (DamageType == class'Suicided')
    {
	    DamageType = Class'ROSuicided';
	    Super(ROVehicle).TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	}
	else if (DamageType == class'ROSuicided')
	{
		super(ROVehicle).TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	}


	// Quick fix for the thing giving itself impact damage
	if(instigatedBy == self)
		return;

	// Don't allow your own teammates to destroy vehicles in spawns (and you know some jerks would get off on doing that to thier team :) )
	if( !bDriverAlreadyEntered )
	{
		if ( InstigatedBy != None )
			InstigatorController = instigatedBy.Controller;

		if ( InstigatorController == None )
		{
			if ( DamageType.default.bDelayedDamage )
				InstigatorController = DelayedDamageInstigatorController;
		}

		if ( InstigatorController != None )
		{
			InstigatorTeam = InstigatorController.GetTeamNum();

			if ( (GetTeamNum() != 255) && (InstigatorTeam != 255) )
			{
				if ( GetTeamNum() == InstigatorTeam )
				{
					return;
				}
			}
		}
	}

    // Modify the damage based on what it should do to the vehicle
	if (DamageType != none)
	{
	   if(class<ROWeaponDamageType>(DamageType) != none)
       		VehicleDamageMod = class<ROWeaponDamageType>(DamageType).default.TankDamageModifier;
       else if(class<ROVehicleDamageType>(DamageType) != none)
	   		VehicleDamageMod = class<ROVehicleDamageType>(DamageType).default.TankDamageModifier;
    }

	for(i=0; i<VehHitpoints.Length; i++)
	{
    	HitPointDamage=Damage;

		if ( VehHitpoints[i].HitPointType == HP_Driver )
		{
			// Damage for large weapons
			if(	class<ROWeaponDamageType>(DamageType) != none && class<ROWeaponDamageType>(DamageType).default.VehicleDamageModifier > 0.25 )
			{
				if ( Driver != none && DriverPositions[DriverPositionIndex].bExposed && IsPointShot(Hitlocation,Momentum, 1.0, i))
				{
					//Level.Game.Broadcast(self, "HitDriver");
					Driver.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
				}
			}
			// Damage for small (non penetrating) arms
			else
			{
				if ( Driver != none && DriverPositions[DriverPositionIndex].bExposed && IsPointShot(Hitlocation,Momentum, 1.0, i, DriverHitCheckDist))
				{
					//Level.Game.Broadcast(self, "HitDriver");
					Driver.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
				}
			}
		}
		else if ( IsPointShot(Hitlocation,Momentum, 1.0, i))
		{
			HitPointDamage *= VehHitpoints[i].DamageMultiplier;
			HitPointDamage *= VehicleDamageMod;

            //log("We hit "$GetEnum(enum'EPawnHitPointType',VehHitpoints[i].HitPointType));

			if ( VehHitpoints[i].HitPointType == HP_Engine )
			{
				DamageEngine(HitPointDamage, instigatedBy, Hitlocation, Momentum, damageType);
			}
			else if ( VehHitpoints[i].HitPointType == HP_AmmoStore )
			{
				Damage *= VehHitpoints[i].DamageMultiplier;
				break;
			}
		}
	}

    LocDir = vector(Rotation);

    LocDir.Z = 0;
    HitDir =  Hitlocation - Location;
    HitDir.Z = 0;
    HitAngle = Acos( Normal(LocDir) dot Normal(HitDir));

	// Convert the angle into degrees from radians
    HitAngle*=57.2957795131;

    GetAxes(Rotation,X,Y,Z);
    Side = Y dot HitDir;

    if( side >= 0)
    {
       HitAngle = 360 + (HitAngle* -1);
    }

	// We are only concerned with side hits for now to calculate track hits.
	// Leave this here though in case we need to calculate front or side hits
	// here later.
/*    if ( HitAngle >= 335 || Hitangle < 25 )
    {
       log ("We hit the front of the vehicle!!!!");

    }
    else*/ if ( HitAngle >= FrontRightAngle && Hitangle < RearRightAngle )
    {
	    HitDir = Hitlocation - Location;

	    InAngle= Acos(Normal(HitDir) dot Normal(Z));

		if( InAngle > TreadHitMinAngle)
		{
			if (DamageType != none && class<ROWeaponDamageType>(DamageType) != none &&
				class<ROWeaponDamageType>(DamageType).default.TreadDamageModifier >= 1.0)
			{
				DamageTrack(true);
				return;
			}
		}


       //log ("We hit the left side of the vehicle!!!!");
    }
/*    else if ( HitAngle >= 137 && Hitangle < 223 )
    {
       log ("We hit the back of the vehicle!!!!");
       Damage *= 2.0;
    }*/
    else if ( HitAngle >= RearLeftAngle && Hitangle < FrontLeftAngle )
    {
	    HitDir = Hitlocation - Location;

	    InAngle= Acos(Normal(HitDir) dot Normal(Z));

		if( InAngle > TreadHitMinAngle)
		{
			if (DamageType != none && class<ROWeaponDamageType>(DamageType) != none &&
				class<ROWeaponDamageType>(DamageType).default.TreadDamageModifier >= 1.0)
			{
				DamageTrack(false);
				return;
			}
		}
    }
/*    else
    {
       log ("We shoulda hit something!!!!");
    }*/


    // Add in the Vehicle damage modifier for the actual damage to the vehicle itself
    Damage *= VehicleDamageMod;

    super(ROVehicle).TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

simulated function float GetPenetrationProbability( float AOI )
{
    local float index;
//     if( AOI > 70 )
//     {
//         // Calculate the amount of armor the round has to penetrate
//         return FMax(Sin(AOI * 0.01745329252),0);
//
//     }
//     else
//     {
//         // Calculate the amount of armor the round has to penetrate, minus the deflection factor
//         log("Pen %"$(100 * Sin(AOI * 0.01745329252))$" deflection "$((70-AOI)*0.6));
//
//         return FMax(((100 * Sin(AOI * 0.01745329252)) - ((70-AOI)*0.6))/100,0);
//     }

     // convert the incoming angle to radians
     //AOI = AOI * 0.01745329252;

     // Preliminary work on new penetration probability
     // Calculate the amount of armor the round has to penetrate, minus the deflection factor
     //return FMax(((100 * Sin(AOI)) - (20 * Cos(AOI)))/100,0);

    index = (AOI/90)*12;

	if( index <= 1)			return 0.0;
	else if ( index <= 2)	return 0.01;
	else if ( index <= 3)	return 0.03;
	else if ( index <= 4)	return 0.08;
	else if ( index <= 5)	return 0.17;
	else if ( index <= 6)	return 0.28;
	else if ( index <= 7)	return 0.42;
	else if ( index <= 8)	return 0.58;
	else if ( index <= 9)	return 0.72;
	else if ( index <= 10)	return 0.83;
	else if ( index <= 11)	return 0.92;
	else 					return 1.0;
}

simulated function bool ShouldPenetrate(vector HitLocation, vector HitRotation, int PenetrationNumber, optional class<DamageType> DamageType)
{
	local vector LocDir, HitDir;
	local float HitAngle,Side,InAngle;
    local vector X,Y,Z;
    local float InAngleDegrees;
    local rotator AimRot;

	if (HitPenetrationPoint(HitLocation, HitRotation))
	{
		return true;
	}

	// Figure out which side we hit
    LocDir = vector(Rotation);
    LocDir.Z = 0;
    HitDir =  Hitlocation - Location;
    HitDir.Z = 0;
    HitAngle = Acos( Normal(LocDir) dot Normal(HitDir));

	//  Penetration Debugging
    if( bDebugPenetration )
    {
        log("Raw hitangle = "$HitAngle$" Converted hitangle = "$(57.2957795131 * HitAngle));
    }

	// Convert the angle into degrees from radians
    HitAngle*=57.2957795131;
    GetAxes(Rotation,X,Y,Z);
    Side = Y dot HitDir;

    //  Penetration Debugging
    if( bDebugPenetration )
    {
        ClearStayingDebugLines();
        AimRot = Rotation;
        AimRot.Yaw += (FrontLeftAngle/360.0)*65536;
        DrawStayingDebugLine( Location, Location + 2000*vector(AimRot),0, 255, 0);
        AimRot = Rotation;
        AimRot.Yaw += (FrontRightAngle/360.0)*65536;
        DrawStayingDebugLine( Location, Location + 2000*vector(AimRot),255, 255, 0);
        AimRot = Rotation;
        AimRot.Yaw += (RearRightAngle/360.0)*65536;
        DrawStayingDebugLine( Location, Location + 2000*vector(AimRot),0, 0, 255);
        AimRot = Rotation;
        AimRot.Yaw += (RearLeftAngle/360.0)*65536;
        DrawStayingDebugLine( Location, Location + 2000*vector(AimRot),0, 0, 0);
    }

    if( side >= 0)
    {
       HitAngle = 360 + (HitAngle* -1);
    }

    if ( HitAngle >= FrontLeftAngle || Hitangle < FrontRightAngle )
    {
	   InAngle= Acos(Normal(-HitRotation) dot Normal(X));
       InAngleDegrees = 90-(InAngle * 57.2957795131);

        //  Penetration Debugging
        if( bDebugPenetration )
        {
            //ClearStayingDebugLines();
            DrawStayingDebugLine( HitLocation, HitLocation + 2000*Normal(X),0, 255, 0);
            DrawStayingDebugLine( HitLocation, HitLocation + 2000*Normal(-HitRotation),255, 255, 0);
            Spawn(class 'ROEngine.RODebugTracer',self,,HitLocation,rotator(HitRotation));
       		log ("We hit the front of the vehicle!!!!");
       		log("InAngle = "$InAngle$" degrees "$InAngleDegrees);
        	log("PenetrationNumber = "$PenetrationNumber);
        	log("FrontArmorFactor = "$FrontArmorFactor);
        	log("Probability % = "$GetPenetrationProbability(InAngleDegrees));
        	log("Total Power = "$(PenetrationNumber * GetPenetrationProbability(InAngleDegrees)));
        	log("Final Calc = "$(FrontArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees)))$" Penetrated = "$!( (FrontArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees))) >= 0.01 ));
        }

		if( (FrontArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees))) >= 0.01 )
			return false;
		else
		    return true;
    }
    else if ( HitAngle >= FrontRightAngle && Hitangle < RearRightAngle )
    {
        // Don't penetrate with fausts if there is added side armor
        if( bHasAddedSideArmor && DamageType != none && DamageType.default.bArmorStops )
        {
            return false;
        }

	    HitDir = Hitlocation - Location;

	    InAngle= Acos(Normal(HitDir) dot Normal(Z));

		if( InAngle > TreadHitMinAngle)
		{
			return true;
		}

	   	InAngle= Acos(Normal(-HitRotation) dot Normal(-Y));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//  Penetration Debugging
        if( bDebugPenetration )
        {
            //ClearStayingDebugLines();
            DrawStayingDebugLine( HitLocation, HitLocation + 2000*Normal(-Y),0, 255, 0);
            DrawStayingDebugLine( HitLocation, HitLocation + 2000*Normal(-HitRotation),255, 255, 0);
            Spawn(class 'ROEngine.RODebugTracer',self,,HitLocation,rotator(HitRotation));
           	log ("We hit the left side of the vehicle!!!!");
       		log("InAngle = "$InAngle$" degrees "$InAngleDegrees);
        	log("PenetrationNumber = "$PenetrationNumber);
        	log("SideArmorFactor = "$SideArmorFactor);
        	log("Probability % = "$GetPenetrationProbability(InAngleDegrees));
        	log("Total Power = "$(PenetrationNumber * GetPenetrationProbability(InAngleDegrees)));
        	log("Final Calc = "$(SideArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees)))$" Penetrated = "$!( (FrontArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees))) >= 0.01 ));
        }

		if( (SideArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees))) >= 0.01 )
			return false;
		else
		    return true;
    }
    else if ( HitAngle >= RearRightAngle && Hitangle < RearLeftAngle )
    {
		InAngle= Acos(Normal(-HitRotation) dot Normal(-X));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//  Penetration Debugging
		if( bDebugPenetration )
        {
            //ClearStayingDebugLines();
            DrawStayingDebugLine( HitLocation, HitLocation + 2000*Normal(-X),0, 255, 0);
            DrawStayingDebugLine( HitLocation, HitLocation + 2000*Normal(-HitRotation),255, 255, 0);
            Spawn(class 'ROEngine.RODebugTracer',self,,HitLocation,rotator(HitRotation));
    		log ("We hit the back of the vehicle!!!!");
       		log("InAngle = "$InAngle$" degrees "$InAngleDegrees);
        	log("PenetrationNumber = "$PenetrationNumber);
        	log("RearArmorFactor = "$RearArmorFactor);
        	log("Probability % = "$GetPenetrationProbability(InAngleDegrees));
        	log("Total Power = "$(PenetrationNumber * GetPenetrationProbability(InAngleDegrees)));
        	log("Final Calc = "$(RearArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees)))$" Penetrated = "$!( (FrontArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees))) >= 0.01 ));
        }

		if( (RearArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees))) >= 0.01 )
			return false;
		else
		    return true;
    }
    else if ( HitAngle >= RearLeftAngle && Hitangle < FrontLeftAngle )
    {
        // Don't penetrate with fausts if there is added side armor
        if( bHasAddedSideArmor && DamageType != none && DamageType.default.bArmorStops )
        {
            return false;
        }

	    HitDir = Hitlocation - Location;

	    InAngle= Acos(Normal(HitDir) dot Normal(Z));

		if( InAngle > TreadHitMinAngle)
		{
			return true;
		}

	   	InAngle= Acos(Normal(-HitRotation) dot Normal(Y));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//  Penetration Debugging
		if( bDebugPenetration )
        {
            //ClearStayingDebugLines();
            DrawStayingDebugLine( HitLocation, HitLocation + 2000*Normal(Y),0, 255, 0);
            DrawStayingDebugLine( HitLocation, HitLocation + 2000*Normal(-HitRotation),255, 255, 0);
            Spawn(class 'ROEngine.RODebugTracer',self,,HitLocation,rotator(HitRotation));
           	log ("We hit the right side of the vehicle!!!!");
       		log("InAngle = "$InAngle$" degrees "$InAngleDegrees);
        	log("PenetrationNumber = "$PenetrationNumber);
        	log("SideArmorFactor = "$SideArmorFactor);
        	log("Probability % = "$GetPenetrationProbability(InAngleDegrees));
        	log("Total Power = "$(PenetrationNumber * GetPenetrationProbability(InAngleDegrees)));
        	log("Final Calc = "$(SideArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees)))$" Penetrated = "$!( (FrontArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees))) >= 0.01 ));
        }

		if( (SideArmorFactor - (PenetrationNumber * GetPenetrationProbability(InAngleDegrees))) >= 0.01 )
			return false;
		else
		    return true;
    }
    else
    {
       log ("We shoulda hit something!!!!");
       return false;
    }
}

function float ModifyThreat(float current, Pawn Threat)
{
	local vector to, t;
	local float r;

	if (Vehicle(Threat) != None)
	{
		current += 0.2;
		if (ROTreadCraft(Threat) != None)
		{
			current += 0.2;
			// big bonus points for perpendicular tank targets
			to = Normal(Threat.Location - Location);
			to.z = 0;
			t = Normal(vector(Threat.Rotation));
			t.z = 0;
			r = to dot t;
			if ( (r >= 0.90630 && r < -0.73135) || (r >= -0.73135 && r < 0.90630) )
				current += 0.3;
		}
		else if (ROWheeledVehicle(Threat) != None && ROWheeledVehicle(Threat).bIsAPC)
			current += 0.1;
	}
	else
		current += 0.25;
	return current;
}

simulated function UpdateTurretReferences()
{
    local int i;

    if (CannonTurret == none)
    {
    	for (i = 0; i < WeaponPawns.length; i++)
    	{
    		if (WeaponPawns[i].Gun.IsA('ROTankCannon'))
    		{
    		    CannonTurret = ROTankCannon(WeaponPawns[i].Gun);
    		    break;
    		}
   		}
    }

    if (HullMG == none)
    {
		for (i = 0; i < WeaponPawns.length; i++)
		{
			if (WeaponPawns[i].Gun.IsA('ROMountedTankMG'))
			{
			    HullMG = WeaponPawns[i].Gun;
			    break;
			}
   		}
    }
}

// test0r
function exec DamageTank()
{
    Health /= 2;
    EngineHealth /= 2;
    bLeftTrackDamaged = true;
    bRightTrackDamaged = true;
}

defaultproperties
{
     TreadVelocityScale=450.000000
     VehicleHudThreadsPosX(0)=0.350000
     VehicleHudThreadsPosX(1)=0.650000
     VehicleHudThreadsPosY=0.500000
     VehicleHudThreadsScale=0.650000
     AddedLatFriction=(Points=((OutVal=1.000000),(InVal=250.000000,OutVal=1.000000),(InVal=300.000000,OutVal=3.000000),(InVal=10000000000.000000,OutVal=3.000000)))
     WheelRotationScale=500
     FrontArmorFactor=6
     RearArmorFactor=2
     SideArmorFactor=3
     TreadHitMinAngle=2.000000
     FrontLeftAngle=333.000000
     FrontRightAngle=28.000000
     RearRightAngle=152.000000
     RearLeftAngle=207.000000
     WheelSoftness=0.025000
     WheelPenScale=2.000000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.500000
     WheelLatFrictionScale=3.000000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=15.000000
     WheelSuspensionMaxRenderTravel=15.000000
     FTScale=0.030000
     ChassisTorqueScale=0.250000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=35.000000),(InVal=1500.000000,OutVal=20.000000),(InVal=1000000000.000000,OutVal=15.000000)))
     TorqueCurve=(Points=((OutVal=12.000000),(InVal=200.000000,OutVal=3.000000),(InVal=1500.000000,OutVal=4.000000),(InVal=2200.000000)))
     GearRatios(0)=-0.200000
     GearRatios(1)=0.200000
     GearRatios(2)=0.350000
     GearRatios(3)=0.550000
     GearRatios(4)=0.600000
     TransRatio=0.120000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=160.000000
     TurnDamping=50.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.100000
     IdleRPM=500.000000
     EngineRPMSoundRange=5000.000000
     RevMeterScale=4000.000000
     bSpecialTankTurning=True
     StartUpForce="TankStartUp"
     ShutDownForce="TankShutDown"
     ViewShakeRadius=600.000000
     ViewShakeOffsetMag=(X=0.500000,Z=2.000000)
     ViewShakeOffsetFreq=7.000000
     DisintegrationHealth=-10000.000000
     DestructionLinearMomentum=(Min=100.000000,Max=350.000000)
     DestructionAngularMomentum=(Max=150.000000)
     DamagedEffectOffset=(X=-40.000000,Y=10.000000,Z=10.000000)
     ImpactDamageMult=0.001000
     bMustBeTankCommander=True
     EngineHealth=325
     VehicleMass=12.500000
     bHasHandbrake=True
     DrivePos=(X=30.000000,Y=-20.000000,Z=55.000000)
     ExitPositions(0)=(Y=-165.000000,Z=40.000000)
     ExitPositions(1)=(Y=165.000000,Z=40.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-40.000000)
     ExitPositions(3)=(Y=165.000000,Z=-40.000000)
     EntryRadius=160.000000
     FPCamPos=(X=29.000000,Y=-25.000000,Z=46.000000)
     TPCamDistance=375.000000
     CenterSpringForce="SpringONSSRV"
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     VehiclePositionString="in a Tank"
     VehicleNameString="Tank"
     MaxDesireability=1.400000
     ObjectiveGetOutDist=1500.000000
     GroundSpeed=325.000000
     HealthMax=300.000000
     Health=300
     CollisionRadius=100.000000
     CollisionHeight=400.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(Z=-0.500000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KMaxAngularSpeed=1.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'ROEngine.ROTreadCraft.KParams0'

}
