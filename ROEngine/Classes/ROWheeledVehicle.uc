//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROWheeledVehicle extends ROVehicle
	abstract
	native
	nativereplication;

//#exec OBJ LOAD FILE=..\textures\Old2k4\InterfaceContent.utx
//#exec OBJ LOAD FILE=..\textures\Old2k4\HudContent.utx
//#exec OBJ LOAD FILE=..\textures\InterfaceArt_tex.utx

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// wheel params
var()	float			WheelSoftness;
var()	float			WheelPenScale;
var()	float			WheelPenOffset;
var()	float			WheelRestitution;
var()	float			WheelAdhesion;
var()	float			WheelInertia;
var()	InterpCurve		WheelLongFrictionFunc;
var()	float			WheelLongSlip;
var()	InterpCurve		WheelLatSlipFunc;
var()	float			WheelLongFrictionScale;
var()	float			WheelLatFrictionScale;
var()	float			WheelHandbrakeSlip;
var()	float			WheelHandbrakeFriction;
var()	float			WheelSuspensionTravel;
var()	float			WheelSuspensionOffset;
var()	float			WheelSuspensionMaxRenderTravel;

var()	float			FTScale;
var()	float			ChassisTorqueScale;
var()	float			MinBrakeFriction;

var()	InterpCurve		MaxSteerAngleCurve; // degrees based on velocity
var()	InterpCurve		TorqueCurve; // Engine output torque
var()	float			GearRatios[5]; // 0 is reverse, 1-4 are forward
var()	int				NumForwardGears;
var()	float			TransRatio; // Other (constant) gearing
var()	float			ChangeUpPoint;
var()	float			ChangeDownPoint;
var()	float			LSDFactor;

var()	float			EngineBrakeFactor;
var()	float			EngineBrakeRPMScale;

var()	float			MaxBrakeTorque;
var()	float			SteerSpeed; // degrees per second
var()	float			TurnDamping;

var()	float			StopThreshold;
var()	float			HandbrakeThresh;

var()	float			EngineInertia; // Pre-gear box engine inertia (racing flywheel etc.)

var()	float			IdleRPM;
var()	float			EngineRPMSoundRange;

// steering wheel animation
var()	name			SteerBoneName;
var()	EAxis			SteerBoneAxis;

// steering lever animation
var()	name			LeftLeverBoneName;
var()	EAxis			LeftLeverAxis;
var()	name			RightLeverBoneName;
var()	EAxis			RightLeverAxis;

// Wheel dirt emitter
var     array<VehicleWheelDustEffect> Dust; // FL, FR, RL, RR
var()   float                       DustSlipRate; // Ratio between dust kicked up and amount wheels are slipping
var()   float                       DustSlipThresh;

// Internal
var		float			OutputBrake;
var		float			OutputGas;
var		bool			OutputHandbrake;
var		int				Gear;

var		float			ForwardVel;
var		bool			bIsInverted;
var		bool			bIsDriving;
var		float			NumPoweredWheels;

var		float			TotalSpinVel;
var		float			EngineRPM;
var		float			CarMPH;
var		float			ActualSteering;

// Rev meter
var		material		RevMeterMaterial;
var()	float			RevMeterPosX;
var()	float			RevMeterPosY;
var()	float			RevMeterScale;
var()	float			RevMeterSizeY;

// Brake lights
var()	bool				bMakeBrakeLights;
var()	vector				BrakeLightOffset[2];
// mergeTODO: Replace this with something
//var		ONSBrakelightCorona	BrakeLight[2];
var()	Material			BrakeLightMaterial;

struct native SCarState
{
	var vector				ChassisPosition;
	var Quat				ChassisQuaternion;
	var vector				ChassisLinVel;
	var vector				ChassisAngVel;

	var byte				ServerHandbrake;
	var byte				ServerBrake;
	var byte				ServerGas;
	var byte				ServerGear;
	var	byte				ServerSteering;
	var int                 ServerViewPitch;
	var int                 ServerViewYaw;
};

var		SCarState			CarState, OldCarState;
var		KRigidBodyState		ChassisState;
var		bool				bNewCarState;

var()	bool				bAllowAirControl;

// Air control
var		float				OutputPitch;
var()	float				AirTurnTorque;
var()	float				AirPitchTorque;
var()	float				AirPitchDamping; // This is on even if bAllowAirControl is false.
var()	float				AirRollTorque;
var()	float				AirRollDamping;
var()	float				MinAirControlDamping; // To limit max speed you can spin/flip at.

var     float				FenderBenderSpeed;

// Ro vars
var 	float				LowSpeedBrakeFriction;// The friction amount to use when the vehicle is moving really slow.

// Exhaust effects
var()	class<VehicleExhaustEffect>	ExhaustEffectClass; // Effect class for the exhaust emitter
var()	class<VehicleExhaustEffect>	ExhaustEffectLowClass; // Effect class for the exhaust emitter lower quality
struct native ExhaustPipe
{
	var vector				ExhaustPosition;
	var rotator				ExhaustRotation;
	var VehicleExhaustEffect ExhaustEffect;
};

var()   array<ExhaustPipe> 	ExhaustPipes;		// Exhaust emitter array

var		byte				ThrottleRep; 		// Replicated throttle setting. Used for effects for non owning clients

// Special RO Vehicle vars
var		bool				bHandbrakeIsBrake;	// Handbrake will act like a regular brake. Since ouf vehicles don't need to slide, pressing the handbrake will slow you down like your pressing the brake, regardless of if the throttle is pressed.
var		bool				bSpecialTankTurning;// Do some native calculations that make the vehicle turn more like a tank

var		int					PendingPositionIndex;	// Position index the client is trying to switch to

replication
{
	reliable if (Role == ROLE_Authority)
		CarState;
	reliable if (bNetInitial && Role == ROLE_Authority)
		bAllowAirControl;

	reliable if (bNetDirty && Role == ROLE_Authority)
		ThrottleRep;
}

/*==============================================
// Red Orchestra Functions
/==============================================*/

simulated function int GetTeamNum()
{
	if ( Role == Role_Authority && (Team == 255 || Team == 2) && (Controller != None) )
	   SetTeamNum( Controller.GetTeamNum() );

	return VehicleTeam;
}

// Did an impact hit this point
function bool IsPointShot(vector loc, vector ray, float AdditionalScale, int index, optional float CheckDist)
{
	local coords C;
	local vector HeadLoc, B, M, diff;
	local float t, DotMM, Distance;

	if (VehHitpoints[index].PointBone == '')
		return False;

	C = GetBoneCoords(VehHitpoints[index].PointBone);

	HeadLoc = C.Origin + (VehHitpoints[index].PointHeight * VehHitpoints[index].PointScale * AdditionalScale * C.XAxis);
	//HeadLoc += VehHitpoints[index].PointOffset;
	HeadLoc = HeadLoc + (VehHitpoints[index].PointOffset >> Rotation);

	// Express snipe trace line in terms of B + tM
	B = loc;

	if( CheckDist > 0 )
		M = Normal(ray) * CheckDist;
	else
		M = ray * (2.0 * CollisionHeight + 2.0 * CollisionRadius);

	// Find Point-Line Squared Distance
	diff = HeadLoc - B;
	t = M Dot diff;
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

	Distance = Sqrt(diff dot diff);

/*
// Hitpoint debugging
	if( VehHitpoints[index].HitPointType==HP_Driver )
	{
	    ClearStayingDebugLines();

	    //DrawStayingDebugLine( loc, (loc + (30 * Normal(C.ZAxis))), 255, 0, 0); // SLOW! Use for debugging only!
	    DrawStayingDebugLine( loc, (loc + M), 0, 255, 0); // SLOW! Use for debugging only!
	}
*/

	return (Distance < (VehHitpoints[index].PointRadius * VehHitpoints[index].PointScale * AdditionalScale));
}

// Handle the engine damage
function DamageEngine(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	local int actualDamage;


	if( EngineHealth > 0)
	{
		actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

		EngineHealth -= actualDamage;
	}

	// Disable the throttle and kill all the engine sounds
	if( EngineHealth <= 0)
	{
		bDisableThrottle = true;
		IdleSound=none;
		StartUpSound=none;
		ShutDownSound=none;
		AmbientSound=none;
	}

}

// Returns true if the vehicle is disabled
simulated function bool IsDisabled()
{
	return (EngineHealth <= 0);
}

//
// TakeDamage - overloaded to prevent bayonet and bash attacks from damaging vehicles
//				for Tanks, we'll probably want to prevent bullets from doing damage too
function TakeDamage(int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	local int i;
	local float VehicleDamageMod;
	local int HitPointDamage;
	local int InstigatorTeam;
	local controller InstigatorController;

	// Fix for suicide death messages
	if (DamageType == class'Suicided')
	{
	    DamageType = class'ROSuicided';
	    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	}
	else if (DamageType == class'ROSuicided')
	{
		Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
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
	if (DamageType != none )
	{
		if( bIsApc )
		{
			if(class<ROWeaponDamageType>(DamageType) != none)
			{
				VehicleDamageMod = class<ROWeaponDamageType>(DamageType).default.APCDamageModifier;
			}
			else if(class<ROVehicleDamageType>(DamageType) != none)
			{
				VehicleDamageMod = class<ROVehicleDamageType>(DamageType).default.APCDamageModifier;
			}
		}
		else
		{
			if(class<ROWeaponDamageType>(DamageType) != none)
				VehicleDamageMod = class<ROWeaponDamageType>(DamageType).default.VehicleDamageModifier;
			else if(class<ROVehicleDamageType>(DamageType) != none)
				VehicleDamageMod = class<ROVehicleDamageType>(DamageType).default.VehicleDamageModifier;
	   	}
	}

	for(i=0; i<VehHitpoints.Length; i++)
	{
		HitPointDamage = Damage;

		if ( VehHitpoints[i].HitPointType==HP_Driver )
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

			if ( VehHitpoints[i].HitPointType == HP_Engine )
			{
				DamageEngine(HitPointDamage, instigatedBy, Hitlocation, Momentum, damageType);
			}
		}
	}

	// Add in the Vehicle damage modifier for the actual damage to the vehicle itself
	Damage *= VehicleDamageMod;

	Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}


// Overriden to handle mesh swapping when entering the vehicle
simulated function ClientKDriverEnter(PlayerController PC)
{
	FPCamPos = default.FPCamPos;

	if (!bDontUsePositionMesh)
		Gotostate('EnteringVehicle');

	PendingPositionIndex = InitialPositionIndex;

	super.ClientKDriverEnter(PC);
}

// Overriden to handle mesh swapping when leaving the vehicle
simulated function ClientKDriverLeave(PlayerController PC)
{
	if( !bDontUsePositionMesh )
	{
//    	if (PC != none && ROHud(PC.myHUD) != none)
//	        ROHud(PC.myHUD).FadeToBlack(1.0, false);
		Gotostate('LeavingVehicle');
	}

	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

/*
exec function HOffX(float NewX)
{
	    HUDOverlayOffset.X=NewX;
}

exec function HOffY(float NewY)
{
	    HUDOverlayOffset.Y=NewY;
}

exec function HOffZ(float NewZ)
{
	    HUDOverlayOffset.Z=NewZ;
}

exec function HFov(float NewFOV)
{
	HUDOverlayFOV=NewFOV;
}
*/

simulated state ViewTransition
{
	simulated function HandleTransition()
	{
	     if( Role == ROLE_AutonomousProxy || Level.Netmode == NM_Standalone || Level.Netmode == NM_ListenServer )
	     {
	         if( DriverPositions[DriverPositionIndex].PositionMesh != none && !bDontUsePositionMesh)
	             LinkMesh(DriverPositions[DriverPositionIndex].PositionMesh);
	     }

         //log("HandleTransition!");

		 if( PreviousPositionIndex < DriverPositionIndex && HasAnim(DriverPositions[PreviousPositionIndex].TransitionUpAnim))
		 {
		 	 //log("HandleTransition Player Transition Up!");
			 PlayAnim(DriverPositions[PreviousPositionIndex].TransitionUpAnim);
		 }
		 else if ( HasAnim(DriverPositions[PreviousPositionIndex].TransitionDownAnim) )
		 {
		 	 //log("HandleTransition Player Transition Down!");
			 PlayAnim(DriverPositions[PreviousPositionIndex].TransitionDownAnim);
		 }

	     if(Driver != none && Driver.HasAnim(DriverPositions[DriverPositionIndex].DriverTransitionAnim))
	         Driver.PlayAnim(DriverPositions[DriverPositionIndex].DriverTransitionAnim);
	}

	simulated function AnimEnd(int channel)
	{
		GotoState('');
	}

	simulated function EndState()
	{
		if( PlayerController(Controller) != none )
		{
			PlayerController(Controller).SetFOV( DriverPositions[DriverPositionIndex].ViewFOV );
			PlayerController(Controller).SetRotation( rot(0, 0, 0) );
		}
	}

Begin:
	//log("ViewTransition Begin!");
	HandleTransition();
	Sleep(0.2);
}

simulated state EnteringVehicle
{
	simulated function HandleEnter()
	{
		if( DriverPositions[0].PositionMesh != none)
	 		LinkMesh(DriverPositions[0].PositionMesh);

		if( PlayerController(Controller) != none )
			PlayerController(Controller).SetFOV( DriverPositions[InitialPositionIndex].ViewFOV );
	}

Begin:
	HandleEnter();
	Sleep(0.2);
	GotoState('');
}

simulated state LeavingVehicle
{
	simulated function HandleExit()
	{
		LinkMesh(Default.Mesh);
	}

	// Don't switch viewpoints if we are leaving the vehicle
	simulated function NextViewPoint() {}

Begin:
	HandleExit();
	Sleep(0.2);
	GotoState('');
}

function KDriverEnter(Pawn P)
{
	super.KDriverEnter(P);
	DriverPositionIndex=InitialPositionIndex;
	PreviousPositionIndex=InitialPositionIndex;
}


function bool KDriverLeave(bool bForceLeave)
{
	local bool bSuperDriverLeave;

	DriverPositionIndex=InitialPositionIndex;
	PreviousPositionIndex=InitialPositionIndex;

	bSuperDriverLeave = super.KDriverLeave(bForceLeave);

	MaybeDestroyVehicle();
	return bSuperDriverLeave;
}

function DriverDied()
{
	DriverPositionIndex=0;
	super.DriverDied();
	MaybeDestroyVehicle();
}

// Check to see if vehicle should destroy itself
function MaybeDestroyVehicle()
{
	if ( IsDisabled() && IsVehicleEmpty())
	{
		bSpikedVehicle = true;
		SetTimer(VehicleSpikeTime, false);
	}
}

// Overriden so that we don't damage our own players when they spike a vehicle
function VehicleExplosion(vector MomentumNormal, float PercentMomentum)
{
	local vector LinearImpulse, AngularImpulse;

	// Don't hurt us when we are destroying our own vehicle
	if( !bSpikedVehicle )
		HurtRadius(ExplosionDamage, ExplosionRadius, ExplosionDamageType, ExplosionMomentum, Location);

	if (!bDisintegrateVehicle)
	{
		ExplosionCount++;

		if (Level.NetMode != NM_DedicatedServer)
			ClientVehicleExplosion(False);

		LinearImpulse = PercentMomentum * RandRange(DestructionLinearMomentum.Min, DestructionLinearMomentum.Max) * MomentumNormal;
		AngularImpulse = PercentMomentum * RandRange(DestructionAngularMomentum.Min, DestructionAngularMomentum.Max) * VRand();

//        log(" ");
//        log(self$" Explosion");
//        log("LinearImpulse: "$LinearImpulse$"("$VSize(LinearImpulse)$")");
//        log("AngularImpulse: "$AngularImpulse$"("$VSize(AngularImpulse)$")");
//        log(" ");

		NetUpdateTime = Level.TimeSeconds - 1;
		KAddImpulse(LinearImpulse, vect(0,0,0));
		KAddAngularImpulse(AngularImpulse);
	}
}

/* =================================================================================== *
* NextViewPoint()
* Handles switching to the next view point in the list of available viewpoints
* for the driver.
*
* created by: Ramm 10/08/04
* =================================================================================== */
simulated function NextViewPoint()
{
	 GotoState('ViewTransition');
}

function ServerChangeViewPoint(bool bForward)
{
	if (bForward)
	{
		if ( DriverPositionIndex < (DriverPositions.Length - 1) )
		{
			PreviousPositionIndex = DriverPositionIndex;
			DriverPositionIndex++;

			if(  Level.Netmode == NM_Standalone  || Level.NetMode == NM_ListenServer )
			{
				NextViewPoint();
			}
		}
	}
	else
	{
		if ( DriverPositionIndex > 0 )
		{
			PreviousPositionIndex = DriverPositionIndex;
			DriverPositionIndex--;

			if(  Level.Netmode == NM_Standalone  || Level.NetMode == NM_ListenServer )
			{
				NextViewPoint();
			}
		}
	}
}

simulated function PostNetReceive()
{
	super.PostNetReceive();

	if ( DriverPositionIndex != SavedPositionIndex )
	{
		PreviousPositionIndex = SavedPositionIndex;
		SavedPositionIndex = DriverPositionIndex;
		NextViewPoint();
	}

	// Kill the engine sounds if the engine is dead
	if( EngineHealth <= 0 )
	{
		if( IdleSound != none )
			IdleSound=none;

		if( StartUpSound != none )
			StartUpSound=none;

		if( ShutDownSound != none )
			ShutDownSound=none;

		if( AmbientSound != none )
			AmbientSound=none;
	}
}

simulated function NextWeapon()
{
	if( !bMultiPosition || IsInState('ViewTransition') || DriverPositionIndex != PendingPositionIndex)
		return;

	// Make sure the client doesn't switch positions while the server is changing position indexes
	if ( DriverPositionIndex < (DriverPositions.Length - 1) )
	{
		PendingPositionIndex = DriverPositionIndex + 1;
	}

	ServerChangeViewPoint(true);
}

// Overriden to switch viewpoints while driving
simulated function PrevWeapon()
{
	if( !bMultiPosition || IsInState('ViewTransition') || DriverPositionIndex != PendingPositionIndex)
		return;

    // Make sure the client doesn't switch positions while the server is changing position indexes
	if ( DriverPositionIndex > 0 )
	{
		PendingPositionIndex = DriverPositionIndex - 1;
	}

	ServerChangeViewPoint(false);
}

// Subclassed to remove onslaught functionality we don't need. This actually never happens in our game yet.
simulated event TeamChanged()
{
/*    local int i;

	// MergeTODO: Don't think we need any of this
	for (i = 0; i < Weapons.Length; i++)
		Weapons[i].SetTeam(Team); */
}

// Allow behindview for debugging
exec function ToggleViewLimit()
{
    local int i;

	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() || Level.NetMode != NM_Standalone  )
		return;

	if( bAllowViewChange )
	{
		bAllowViewChange=false;
		bDontUsePositionMesh = false;
		bLimitYaw = true;
		bLimitPitch = true;

		for (i = 0; i < DriverPositions.length; i++)
		{
	         DriverPositions[i].PositionMesh = default.DriverPositions[i].PositionMesh;
   		}

   		LinkMesh(DriverPositions[DriverPositionIndex].PositionMesh);
	}
	else
	{
		bAllowViewChange=true;
		bDontUsePositionMesh = true;
		bLimitYaw = false;
		bLimitPitch = false;

		for (i = 0; i < DriverPositions.length; i++)
		{
	         DriverPositions[i].PositionMesh = default.Mesh;
   		}

   		LinkMesh(default.Mesh);
	}
}

// Check to see if the vehicle can leave yet/if it has a crew
function Timer()
{
	// Check to see if we need to blow the vehicle
	if ( bSpikedVehicle )
	{
		if( IsVehicleEmpty() )
		{
			KilledBy(self);
		}
		else
		{
			bSpikedVehicle=false;
		}

		return;
	}

	// no controller
	if( Controller == none )
	{
	   SetTimer(1.0, false);
	}
	// human in SP
   	else if ( Level.NetMode == NM_Standalone && IsHumanControlled() )
   	{
	   bDisableThrottle = false;
	   bDriverAlreadyEntered = true;
	   return;
	}
	// human in MP
	else if( bDriverAlreadyEntered && ((Level.TimeSeconds - DriverEnterTime) > 13.0 || !CheckForNearbyPlayers(1500.0) && IsHumanControlled()))
	{
	   bDisableThrottle = false;
	   bDriverAlreadyEntered = true;
	}
/*
	else if( !CheckForCrew() && AIController(Controller) != none)
	{
	   bDisableThrottle = true;
	   if ( !bDriverAlreadyEntered )
	   {
			DriverEnterTime =  Level.TimeSeconds;
	   }
	   bDriverAlreadyEntered = true;
	   SetTimer(0.5, false);
	}  */
	else if( CheckForCrew() )
	{
	   bDisableThrottle = false;
	   bDriverAlreadyEntered = true;
	}
	// bots, or human just entered
	else
	{
		if ( !bDriverAlreadyEntered )
		{
			DriverEnterTime =  Level.TimeSeconds;
			bDriverAlreadyEntered = true;
		}
		// only humans wait
		if( IsHumanControlled() )
		{
			PlayerController(Controller).ReceiveLocalizedMessage(class'ROVehicleWaitingMsg', 0);
			SetTimer(0.5, false);
		}
		// enable throttle for bots
		else
			bDisableThrottle = false;
	}

}

// See if the vehicle has a crew large enough to man it
function bool CheckForCrew()
{
   if( NumPassengers() > 1 )
	   return true;
	if (Controller != none && Bot(Controller) != none && Bot(Controller).Squad.Size < 2)
		return true;
   return false;
}

// Overridden due to the Onslaught team lock not working in RO
function bool TryToDrive(Pawn P)
{
	local int x;

	//don't allow vehicle to be stolen when somebody is in a turret
	if (!bTeamLocked && P.GetTeamNum() != VehicleTeam)
	{
		for (x = 0; x < WeaponPawns.length; x++)
			if (WeaponPawns[x].Driver != None)
			{
				DenyEntry( P, 2 );
				return false;
			}
	}

	if ( P.bIsCrouched ||  bNonHumanControl || (P.Controller == None) || (Driver != None) || (P.DrivenVehicle != None) || !P.Controller.bIsPlayer
	     || P.IsA('Vehicle') || Health <= 0 || (P.Weapon != none && P.Weapon.IsInState('Reloading')) )
		return false;

	if( !Level.Game.CanEnterVehicle(self, P) )
		return false;

	// Check vehicle Locking....
	if ( bTeamLocked && ( P.GetTeamNum() != VehicleTeam ))
	{
		DenyEntry( P, 1 );
		return false;
	}
	else if( bMustBeTankCommander && !ROPlayerReplicationInfo(P.Controller.PlayerReplicationInfo).RoleInfo.bCanBeTankCrew && P.IsHumanControlled())
	{
	   DenyEntry( P, 0 );
	   return false;
	}
	else
	{
		if ( bEnterringUnlocks && bTeamLocked )
			bTeamLocked = false;

		KDriverEnter( P );
		return true;
	}
}

// Send a message on why they can't get in the vehicle
function DenyEntry( Pawn P, int MessageNum )
{
	P.ReceiveLocalizedMessage(class'ROVehicleMessage', MessageNum);
}

/* PointOfView()
We don't ever want to allow behindview. It doesn't work with our system - Ramm
*/
simulated function bool PointOfView()
{
	return false;
}

//Vehicle has been in the middle of nowhere with no driver for a while, so consider resetting it
//	called after ResetTime has passed since driver left
// Overriden so we can control the time it takes for the vehicle to disappear - Ramm
event CheckReset()
{
	local Pawn P;

	if ( bKeyVehicle && IsVehicleEmpty() )
	{
		Died(None, class'DamageType', Location);
		return;
	}

	if ( !IsVehicleEmpty() )
	{
		ResetTime = Level.TimeSeconds + IdleTimeBeforeReset;
		return;
	}

	foreach CollidingActors(class 'Pawn', P, 4000.0)
	{
		if (P != self && P.Controller != none && P.GetTeamNum() == GetTeamNum())
		{
			if(ROPawn(P) != none && (VSize(P.Location - Location) < 2000))
			{
				ResetTime = Level.TimeSeconds + IdleTimeBeforeReset;
				return;
			}
			else if ( FastTrace(P.Location + P.CollisionHeight * vect(0,0,1), Location + CollisionHeight * vect(0,0,1)))
			{
				ResetTime = Level.TimeSeconds + IdleTimeBeforeReset;
				return;
			}
		}
	}

	//if factory is active, we want it to spawn new vehicle NOW
	if ( ParentFactory != None )
	{
		ParentFactory.VehicleDestroyed(self);
		ParentFactory.Timer();
		ParentFactory = None; //so doesn't call ParentFactory.VehicleDestroyed() again in Destroyed()
	}

	Destroy();
}

// Overridded to force emitter effects to not be destroyed before vehicle is.
simulated event ClientVehicleExplosion(bool bFinal)
{
	local int SoundNum;
	local PlayerController PC;
	local float Dist, Scale;

	//viewshake
	if (Level.NetMode != NM_DedicatedServer)
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget != None)
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if (Dist < ExplosionRadius * 2.5)
			{
				if (Dist < ExplosionRadius)
					scale = 1.0;
				else
					scale = (ExplosionRadius*2.5 - Dist) / (ExplosionRadius);
				PC.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
			}
		}
	}

	// Explosion effect
	if(ExplosionSounds.Length > 0)
	{
		SoundNum = Rand(ExplosionSounds.Length);
		PlaySound(ExplosionSounds[SoundNum], SLOT_None, ExplosionSoundVolume*TransientSoundVolume,, ExplosionSoundRadius);
	}

	if (bFinal)
	{
		if (Level.NetMode != NM_DedicatedServer)
        {
			if( Level.bDropDetail || Level.DetailMode == DM_Low )
				DestructionEffect = spawn(DisintegrationEffectLowClass,,, Location, Rotation);
			else
				DestructionEffect = spawn(DisintegrationEffectClass,,, Location, Rotation);

			DestructionEffect.LifeSpan = TimeTilDissapear;
      		DestructionEffect.SetBase(self);
        }
	}
	else
	{
		if (Level.NetMode != NM_DedicatedServer)
		{
     	    if( Level.bDropDetail || Level.DetailMode == DM_Low )
				DestructionEffect = spawn(DestructionEffectLowClass, self);
			else
				DestructionEffect = spawn(DestructionEffectClass, self);

			DestructionEffect.LifeSpan = TimeTilDissapear;
			DestructionEffect.SetBase(self);
		}
	}
}

// Overriden because we don't want our vehicles to disappear instantly
state VehicleDestroyed
{
ignores Tick;

	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
	{
	}

Begin:
	DestroyAppearance();
	VehicleExplosion(vect(0,0,1), 1.0);
	sleep(TimeTilDissapear);
	CallDestroy();
}

// clean these up at some point. The super call is precaching stuff we don't need. - Ramm
static function StaticPrecache(LevelInfo L)
{
	Super.StaticPrecache(L);

/*	L.AddPrecacheMaterial(Material'Effects_Tex.explosions.DSmoke_1');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.fire_16frame');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.LSmoke3');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.DSmoke_2');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.impact_2frame');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.explosion_1frame');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.shrapnel3');
    L.AddPrecacheMaterial(Material'Effects_Tex.Vehicles.DustCloud');
    L.AddPrecacheMaterial(Material'Effects_Tex.Vehicles.Dust_KickUp');
    L.AddPrecacheMaterial(Material'Effects_Tex.explosions.fire_16frame');
    L.AddPrecacheMaterial(Material'Effects_Tex.Vehicles.vehiclesparkhead');
*/
}

simulated function UpdatePrecacheStaticMeshes()
{
	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    // Put in super, this is for all vehicle explosions
/*	Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.DSmoke_1');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.fire_16frame');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.LSmoke3');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.DSmoke_2');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.impact_2frame');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.explosion_1frame');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.shrapnel3');
    Level.AddPrecacheMaterial(Material'Effects_Tex.Vehicles.DustCloud');
    Level.AddPrecacheMaterial(Material'Effects_Tex.Vehicles.Dust_KickUp');
    Level.AddPrecacheMaterial(Material'Effects_Tex.explosions.fire_16frame');
    Level.AddPrecacheMaterial(Material'Effects_Tex.Vehicles.vehiclesparkhead');
*/
	Super.UpdatePrecacheMaterials();
}

simulated function DrawVehicle(Canvas Canvas)
{
	if (PlayerController(Controller) != none && ROHud(PlayerController(Controller).myHUD) != none)
		ROHud(PlayerController(Controller).myHUD).DrawVehicleIcon(Canvas, self);
	return;

	/*
	if( PlayerController(Controller) != none &&  PlayerController(Controller).myHUD.bHideHUD )
	{
		return;
	}

	//scale = Canvas.SizeX / 1600.0;
	scale = Canvas.SizeY / 1200.0;

	MapX = VehicleIconX * Canvas.ClipX + VehicleIconAbsOffsetX * scale * VehicleHudScale;
	MapY = VehicleIconY * Canvas.ClipY + VehicleIconAbsOffsetY * scale * VehicleHudScale;

	SavedColor = Canvas.DrawColor;
	WhiteColor =  class'Canvas'.Static.MakeColor(255,255,255);

	// Set health color for vehicle
	if( Health/HealthMax > 0.75 )
	{
		VehicleColor = class'Canvas'.Static.MakeColor(255,255,255);
	}
	else if ( Health/HealthMax > 0.35 )
	{
		VehicleColor = class'Canvas'.Static.MakeColor(255,222,0);
	}
	else
	{
		VehicleColor = class'Canvas'.Static.MakeColor(154,0,0);
	}

	Canvas.DrawColor = VehicleColor;


	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.SetPos(MapX, MapY);

	Canvas.DrawTileScaled(VehicleHudIcon, scale * VehicleHudScale, scale *  VehicleHudScale);

	// Set health color for engine
	if( EngineHealth/Default.EngineHealth > 0.95 )
	{
		//VehicleColor = class'Canvas'.Static.MakeColor(255,255,255);
		return;
	}
	else if ( EngineHealth/Default.EngineHealth > 0.35 )
	{
		VehicleColor = class'Canvas'.Static.MakeColor(255,222,0);
	}
	else
	{
		if( bFlashIconOn && Level.TimeSeconds-IconFlashTime > 0.25)
		{
			IconFlashTime=Level.TimeSeconds;
			bFlashIconOn=false;
		}
		else if ( !bFlashIconOn && Level.TimeSeconds-IconFlashTime > 0.25 )
		{
			IconFlashTime=Level.TimeSeconds;
			bFlashIconOn=true;
		}
		else if( !bFlashIconOn )
		{
			return;
		}

		VehicleColor = class'Canvas'.Static.MakeColor(154,0,0);
	}

	MapX = EngineIconX * Canvas.ClipX;
	MapY = EngineIconY * Canvas.ClipY;

	Canvas.SetPos(MapX, MapY);
	Canvas.DrawColor = VehicleColor;

	Canvas.DrawTileScaled(EngineIcon, scale * VehicleHudScale, scale *  VehicleHudScale);
	*/
}

simulated function DrawPassengers(Canvas Canvas)
{
	/*
	local float X, Y, XL, YL;
	local int i;
	local float scalar;
	local color WhiteColor, SavedColor;

	SavedColor = Canvas.DrawColor;
	WhiteColor =  class'Canvas'.Static.MakeColor(255,255,255,175);
	Canvas.DrawColor = WhiteColor;

	Canvas.Style = ERenderStyle.STY_Normal;
	X = PassengerListX * Canvas.ClipX;
	Y = PassengerListY * Canvas.ClipY;
	Canvas.SetPos(X , Y );
	Canvas.Font = class'ROHUD'.Static.GetConsoleFont(Canvas);

	for (i = 0; i < WeaponPawns.length; i++)
	{
		if( WeaponPawns[i].PlayerReplicationInfo != none)
		{
			Canvas.StrLen(ROVehicleWeaponPawn(WeaponPawns[i]).HudName$": "$WeaponPawns[i].PlayerReplicationInfo.PlayerName, XL, YL);
			Canvas.DrawTextJustified(ROVehicleWeaponPawn(WeaponPawns[i]).HudName$": "$WeaponPawns[i].PlayerReplicationInfo.PlayerName, 2, X, Y, X + XL, Y+YL);
			scalar -= 0.025;
			X = PassengerListX * Canvas.ClipX;
			Y = (PassengerListY + scalar) * Canvas.ClipY;
			Canvas.SetPos(X , Y );
 		}
	}

	 Canvas.DrawColor = SavedColor;
	 */
}

function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIndex)
{
	//local vector BloodOffset, Mo, HitNormal;
	//local class<Effects> DesiredEffect;
	//local class<Emitter> DesiredEmitter;
	local PlayerController Hearer;
	local int i;

	if ( DamageType == None )
		return;
	if ( (Damage <= 0) && ((Controller == None) || !Controller.bGodMode) )
		return;

	// Instead, lets not spawn blood for vehicles - Ramm
	// TODO - adapt this to correclty play hit effects for vehicles
/*	if (Damage > DamageType.Default.DamageThreshold) //spawn some blood
	{

		HitNormal = Normal(HitLocation - Location);

		// Play any set effect
		if ( EffectIsRelevant(Location,true) )
		{
			DesiredEffect = DamageType.static.GetPawnDamageEffect(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));

			if ( DesiredEffect != None )
			{
				BloodOffset = 0.2 * CollisionRadius * HitNormal;
				BloodOffset.Z = BloodOffset.Z * 0.5;

				Mo = Momentum;
				if ( Mo.Z > 0 )
					Mo.Z *= 0.5;
				spawn(DesiredEffect,self,,HitLocation + BloodOffset, rotator(Mo));
			}

			// Spawn any preset emitter

			DesiredEmitter = DamageType.Static.GetPawnDamageEmitter(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));
			if (DesiredEmitter != None)
				spawn(DesiredEmitter,,,HitLocation+HitNormal, Rotator(HitNormal));
		}
	} */
	if ( Health <= 0 )
	{
		if ( PhysicsVolume.bDestructive && (PhysicsVolume.ExitActor != None) )
			Spawn(PhysicsVolume.ExitActor);
		return;
	}

	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		if ( InstigatedBy != None && (DamageType != None) && DamageType.default.bDirectDamage )
			Hearer = PlayerController(InstigatedBy.Controller);
		if ( Hearer != None )
			Hearer.bAcuteHearing = true;
		PlayTakeHit(HitLocation,Damage,damageType);
		if ( Hearer != None )
			Hearer.bAcuteHearing = false;
		LastPainTime = Level.TimeSeconds;
	}

	for (i = 0; i < WeaponPawns.length; i++)
		if (!WeaponPawns[i].bHasOwnHealth && WeaponPawns[i].Controller != None)
			WeaponPawns[i].Controller.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);
}



//---------------------- Onslaught Overrides -----------------------------------

event NotifyEnemyLockedOn() {}
event NotifyEnemyLostLock() {}

// Spawn FX
function PlayTeleportEffect( bool bOut, bool bSound) {}
//------------------------------------------------------------------------------

/*==============================================
// End Red Orchestra Functions
/==============================================*/


///////////////////////////////////////////
/////////////// CREATION //////////////////
///////////////////////////////////////////

// Overridden to play the correct idle animation for the vehicle
simulated function PostBeginPlay()
{
	// RO functionality
	if( HasAnim(BeginningIdleAnim))
	{
	    LoopAnim(BeginningIdleAnim);
	}

	SetTimer(1.0, false);
	// End RO functionality

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local int i;

	// Count the number of powered wheels on the car
	NumPoweredWheels = 0.0;
	for(i=0; i<Wheels.Length; i++)
	{
		NumPoweredWheels += 1.0;
	}

	Super.PostNetBeginPlay();
}

simulated function PrecacheAnnouncer(AnnouncerVoice V, bool bRewardSounds)
{
	// We don't use the announcer

/*	if (bRewardSounds && !bSoundsPrecached)
		V.PrecacheSound('fender_bender');

	Super.PrecacheAnnouncer(V, bRewardSounds); */
}

simulated function Destroyed()
{
	local int i;

	if(Level.NetMode != NM_DedicatedServer)
	{
		for(i=0; i<Dust.Length; i++)
			Dust[i].Destroy();

		for(i=0; i<ExhaustPipes.Length; i++)
			if (ExhaustPipes[i].ExhaustEffect != None)
			{
				// Create exhaust emitters.
				ExhaustPipes[i].ExhaustEffect.Destroy();
			}

			// MergeTODO: Put this back in
/*	   if(bMakeBrakeLights)
	   {
			if (BrakeLight[0] != None)
				BrakeLight[0].Destroy();

			if (BrakeLight[1] != None)
				BrakeLight[1].Destroy();
	   }*/
	}

	Super.Destroyed();
}

///////////////////////////////////////////
/////////////// NETWORKING ////////////////
///////////////////////////////////////////


simulated event bool KUpdateState(out KRigidBodyState newState)
{
	// This should never get called on the server - but just in case!
	if(Role == ROLE_Authority || !bNewCarState)
		return false;

	newState = ChassisState;
	bNewCarState = false;

	return true;
	//return false;
}

///////////////////////////////////////////
////////////////// OTHER //////////////////
///////////////////////////////////////////

simulated event SVehicleUpdateParams()
{
	local int i;

	Super.SVehicleUpdateParams();

	for(i=0; i<Wheels.Length; i++)
	{
		Wheels[i].Softness = WheelSoftness;
		Wheels[i].PenScale = WheelPenScale;
		Wheels[i].PenOffset = WheelPenOffset;
		Wheels[i].LongSlip = WheelLongSlip;
		Wheels[i].LatSlipFunc = WheelLatSlipFunc;
		Wheels[i].Restitution = WheelRestitution;
		Wheels[i].Adhesion = WheelAdhesion;
		Wheels[i].WheelInertia = WheelInertia;
		Wheels[i].LongFrictionFunc = WheelLongFrictionFunc;
		Wheels[i].HandbrakeFrictionFactor = WheelHandbrakeFriction;
		Wheels[i].HandbrakeSlipFactor = WheelHandbrakeSlip;
		Wheels[i].SuspensionTravel = WheelSuspensionTravel;
		Wheels[i].SuspensionOffset = WheelSuspensionOffset;
		Wheels[i].SuspensionMaxRenderTravel = WheelSuspensionMaxRenderTravel;
	}

	if(Level.NetMode != NM_DedicatedServer && bMakeBrakeLights)
	{
	// MergeTODO: Put this back in
/*		for(i=0; i<2; i++)
		{
			if (BrakeLight[i] != None)
			{
				BrakeLight[i].SetBase(None);
				BrakeLight[i].SetLocation( Location + (BrakelightOffset[i] >> Rotation) );
				BrakeLight[i].SetBase(self);
				BrakeLight[i].SetRelativeRotation( rot(0,32768,0) );
				BrakeLight[i].Skins[0] = BrakeLightMaterial;
			}
		} */
	}
}

simulated event DrivingStatusChanged()
{
	local int i;
	local Coords WheelCoords;

	Super.DrivingStatusChanged();

	if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
		Dust.length = Wheels.length;
		for(i=0; i<Wheels.Length; i++)
			if (Dust[i] == None)
			{
				// Create wheel dust emitters.
				WheelCoords = GetBoneCoords(Wheels[i].BoneName);
				Dust[i] = spawn(class'VehicleWheelDustEffect', self,, WheelCoords.Origin + ((vect(0,0,-1) * Wheels[i].WheelRadius) >> Rotation));
				if( Level.bDropDetail || Level.DetailMode == DM_Low )
				{
				 	Dust[i].MaxSpritePPS=3;
				 	Dust[i].MaxMeshPPS=3;
				}

				Dust[i].SetBase(self);
			    Dust[i].SetDirtColor( Level.DustColor );
			}

		 for(i=0; i<ExhaustPipes.Length; i++)
			if (ExhaustPipes[i].ExhaustEffect == None)
			{
				// Create exhaust emitters.
	    	    if( Level.bDropDetail || Level.DetailMode == DM_Low )
					ExhaustPipes[i].ExhaustEffect = spawn(ExhaustEffectLowClass, self,, Location + (ExhaustPipes[i].ExhaustPosition >> Rotation), ExhaustPipes[i].ExhaustRotation + Rotation);
				else
					ExhaustPipes[i].ExhaustEffect = spawn(ExhaustEffectClass, self,, Location + (ExhaustPipes[i].ExhaustPosition >> Rotation), ExhaustPipes[i].ExhaustRotation + Rotation);

				ExhaustPipes[i].ExhaustEffect.SetBase(self);
			}


	   /*
		if(bMakeBrakeLights)
		{
			for(i=0; i<2; i++)
				if (BrakeLight[i] == None)
				{
					BrakeLight[i] = spawn(class'ONSBrakelightCorona', self,, Location + (BrakeLightOffset[i] >> Rotation) );
					BrakeLight[i].SetBase(self);
					BrakeLight[i].SetRelativeRotation( rot(0,32768,0) ); // Point lights backwards.
					BrakeLight[i].Skins[0] = BrakeLightMaterial;
				}
		} */
	}
	else
	{
		if (Level.NetMode != NM_DedicatedServer)
		{
			for(i=0; i<Dust.Length; i++)
			{
				if( Dust[i] != none )
					Dust[i].Kill();
			}

			Dust.Length = 0;

			for(i=0; i<ExhaustPipes.Length; i++)
			{
			    if (ExhaustPipes[i].ExhaustEffect != None)
			    {
					ExhaustPipes[i].ExhaustEffect.Kill();
				}
			}

			// MergeTOD: Put this back in
/*
			if(bMakeBrakeLights)
			{
				for(i=0; i<2; i++)
					if (BrakeLight[i] != None)
						BrakeLight[i].Destroy();
			}  */
		}

		TurnDamping = 0.0;
	}
}

// Overridden to add steering wheel code that actually works - Ramm
// MergeTODO: Move my steering code to the native and AXE epics steering code
simulated function Tick(float dt)
{
	local int i;
	local bool lostTraction;
	local float ThrottlePosition;

	Super.Tick(dt);

	// Pack the throttle setting into a byte to replicate it
	if( Role == ROLE_Authority )
	{
		if( Throttle < 0 )
		{
			ThrottleRep = (100 * Abs(Throttle));
		}
		else
		{
			ThrottleRep = 101 + (100 * Throttle);
		}
	}

 	// Dont bother doing effects on dedicated server.
	if(Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
		lostTraction = true;

		// MergeTODO: Put this stuff back in

   		// Update dust kicked up by wheels.
   		for(i=0; i<Dust.Length; i++)
	   	   Dust[i].UpdateDust(Wheels[i], DustSlipRate, DustSlipThresh);

		// Unpack the replicated throttle byte
		if( ThrottleRep < 101 )
		{
			ThrottlePosition = (ThrottleRep * 1.0)/100;
		}
		else if ( ThrottleRep == 101 )
		{
			ThrottlePosition = 0;
		}
		else
		{
			ThrottlePosition = (ThrottleRep - 101)/100;
		}

		for(i=0; i<ExhaustPipes.Length; i++)
		{
		    if (ExhaustPipes[i].ExhaustEffect != None)
		    {
				ExhaustPipes[i].ExhaustEffect.UpdateExhaust(ThrottlePosition);
			}
		}

		/*
		if(bMakeBrakeLights)
		{
			for(i=0; i<2; i++)
				if (BrakeLight[i] != None)
					BrakeLight[i].bCorona = True;

			for(i=0; i<2; i++)
				if (BrakeLight[i] != None)
					BrakeLight[i].UpdateBrakelightState(OutputBrake, Gear);
		}  */
	}

	TurnDamping = default.TurnDamping;

	// RO Functionality
	// Lets make the vehicle not slide when its parked
	if( Abs(ForwardVel) < 50 )
	{
		MinBrakeFriction = LowSpeedBrakeFriction;
	}
	else
	{
		MinBrakeFriction=Default.MinBrakeFriction;
	}
}

function float ImpactDamageModifier()
{
	local float Multiplier;
	local vector X, Y, Z;

	GetAxes(Rotation, X, Y, Z);
	if (ImpactInfo.ImpactNorm Dot Z > 0)
		Multiplier = 1-(ImpactInfo.ImpactNorm Dot Z);
	else
		Multiplier = 1.0;

	return Super.ImpactDamageModifier() * Multiplier;
}

//function bool Dodge(eDoubleClickDir DoubleClickMove)
//{
//	if (bAllowChargingJump)
//	{
//		Rise = -1;
//		return true;
//	}
//
//	return false;
//}

/*
simulated event KImpact(Actor Other, vector Pos, vector ImpactVel, vector ImpactNorm)
{
	Super.KImpact(Other, Pos, ImpactVel, ImpactNorm);

	// MergeTODO: Put this back in with RO functionality

	if ( ROWheeledVehicle(Other) != None && ROWheeledVehicle(Other).bDriving && PlayerController(Controller) != None
	     && ROWheeledVehicle(Other).GetTeamNum() != Controller.GetTeamNum()
	     && VSize(ImpactVel) > FenderBenderSpeed && (vector(Rotation) Dot vector(Other.Rotation)) < 0 )
		PlayerController(Controller).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 7);
} */

// Added functionality for debugging vehicle speeds
simulated function DrawHUD(Canvas C)
{
// for debugging speed - Ramm
//	local float XL, YL;
//	local float MySpeed;
//	local float DisplayThrottle;

	Super.DrawHUD(C);

	DrawVehicle(C);
	DrawPassengers(C);

/*	if( !bDrawSpeedDebug && PlayerController(Controller) != none && PlayerController(Controller).myHUD.bHideHUD )
	{
		return;
	}

	//     Debugging code to show speed. Comment out when not testing

	C.Style = ERenderStyle.STY_Normal;
	C.StrLen("KM/H", XL, YL);
	C.SetPos( MPHMeterPosX * C.ClipX, (MPHMeterSizeY + MPHMeterPosY) * C.ClipY + YL );
	C.Font = class'ROHUD'.Static.GetLargeMenuFont(C);//GetConsoleFont(Canvas);
	MySpeed = VSize(Velocity);
	MySpeed = (((MySpeed * 3600)/60.35)/1000);

	DisplayThrottle=Throttle*100;

	C.DrawColor = class'Canvas'.Static.MakeColor(255,255,255,150);
	C.DrawTextClipped("Throttle: "$DisplayThrottle$"% KM/H "$MySpeed$" EngineRPM "$EngineRPM);
	// End debugging code
 */
}

function int LimitPitch(int pitch, optional float DeltaTime)
{
	if (bAllowAirControl && !bVehicleOnGround)
		return pitch;

	return Super.LimitPitch(pitch);
}

// Let the player know they can get in this vehicle
simulated event NotifySelected( Pawn user )
{
	if( User.PlayerReplicationInfo.Team.TeamIndex != GetTeamNum() )
		return;

	if( user.IsHumanControlled() && (( Level.TimeSeconds - LastNotifyTime ) >= TouchMessageClass.default.LifeTime))
	{
		PlayerController(User.Controller).ReceiveLocalizedMessage(TouchMessageClass,0,,,self.class);

        LastNotifyTime = Level.TimeSeconds;
	}
}

defaultproperties
{
     NumForwardGears=4
     DustSlipRate=2.800000
     DustSlipThresh=50.000000
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     MinAirControlDamping=0.100000
     FenderBenderSpeed=10000000.000000
     LowSpeedBrakeFriction=40.000000
     bHandbrakeIsBrake=True
     bHasAltFire=False
     DestructionEffectClass=Class'ROEffects.ROVehicleDestroyedEmitter'
     DisintegrationEffectClass=Class'ROEffects.ROVehicleObliteratedEmitter'
     DestructionEffectLowClass=Class'ROEffects.ROVehicleDestroyedEmitter_simple'
     DisintegrationEffectLowClass=Class'ROEffects.ROVehicleObliteratedEmitter_simple'
     bLimitYaw=True
     CurrentCapArea=255
     TimeTilDissapear=60.000000
     IdleTimeBeforeReset=10.000000
     bDisableThrottle=True
     BeginningIdleAnim="idle_open"
     MPHMeterMaterial=Texture'InterfaceArt_tex.Menu.RODisplay'
     MPHMeterPosX=0.250000
     MPHMeterPosY=0.750000
     MPHMeterScale=70.000000
     MPHMeterSizeY=0.050000
     DriverPositions(0)=(ViewFOV=85.000000)
     DriverPositions(1)=(ViewFOV=85.000000)
     DriverHitCheckDist=30.000000
     VehicleSpikeTime=3.000000
     VehHitpoints(0)=(PointRadius=9.000000,PointScale=1.000000,PointBone="driver_player",bPenetrationPoint=True,HitPointType=HP_Driver)
     VehHitpoints(1)=(PointRadius=25.000000,PointScale=1.000000,PointBone="body",HitPointType=HP_Engine)
     EngineHealth=100
     bMultiPosition=True
     bDrawDriverInTP=True
     bDrawMeshInFP=True
     bEnterringUnlocks=False
     bCanFlip=True
     bAllowViewChange=False
     bDesiredBehindView=False
     bDriverHoldsFlag=False
     DriveAnim="VPanzer4_driver_idle_close"
     CenterSpringRangePitch=5000
     CenterSpringRangeRoll=5000
     DriverDamageMult=0.800000
     NoEntryTexture=None
     TeamBeaconBorderMaterial=None
     RanOverDamageType=Class'Engine.DamRanOver'
     CrushedDamageType=Class'Engine.Crushed'
     StolenAnnouncement="'"
     AmbientSoundScaling=1.250000
     bReplicateAnimations=True
     bNetNotify=True
}
