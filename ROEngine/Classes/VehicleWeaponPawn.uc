//-----------------------------------------------------------
//
//-----------------------------------------------------------
class VehicleWeaponPawn extends Vehicle
	native
	nativereplication;

var()   vector      GunnerPos;
var()   rotator     GunnerRot;

var()   vector      FireImpulse;
var()   vector      AltFireImpulse;

var VehicleWeapon           Gun;
var class<VehicleWeapon>    GunClass;

var ROVehicle          VehicleBase;

// Effect spawned when weapon is destroyed
var ()  class<Actor>    DestroyEffectClass;

const                       FilterFrames = 5;
var                 vector  CameraHistory[FilterFrames];
var                 int     NextHistorySlot;
var                 bool    bHistoryWarmup;
var                 bool    bHasFireImpulse;
var                 bool    bHasAltFireImpulse;
var                 bool    bCustomAiming;     // If true, the weapon aiming will be controlled by setting CustomAim.
var                 Rotator CustomAim;
var                 int     PositionInArray; // Used to get proper position in the WeaponPawns array (since variables arn't all received in same order that they were replicated in)

// Movement
var float		YawAccel, PitchAccel;

var string      DebugInfo;

var bool bHasOwnHealth;	// If false, damage to this pawn is done to Driver instead
var bool bHasAltFire;

var() name		CameraBone; // Lets you make the camera relative to a bone on this actor instead of the actor itself.

//#if _RO_
// HEADBOB
var rotator    HeadRotationOffset;
var vector     HeadRotationSnapRates;
//
var rotator    StoredVehicleRotation;
// helper...
var rotator    ShiftHalf;
//#endif // _RO_

// Correct aim indicator
var config color CrosshairColor;
var config float CrosshairX, CrosshairY;
var config Texture CrosshairTexture;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// if _RO_
// Special tank turret rotation sound logic. Need this because you can't play two ambient sounds at once,
// and tank cannons need to be able to play Ambient Coaxial MG sounds while also rotating
var() 	bool			bSpecialRotateSounds;	// Use special rotate sound logic for this weapon. Used to for tank cannon turrets
var()   sound           RotateSound;
var()   sound           PitchSound;             // sound of this weapon pitching up or down
var()   sound           RotateAndPitchSound;    // Sound for this weapon pitching and rotating simultaneously
var()	float			MinRotateThreshold;     // Used by the native code for special turret rotation. A button press for less than this amount of time will result in the slower rotation speed
var()	float			MaxRotateThreshold;     // Used by the native code for special turret rotation. Rotation speed is interpolated up to full speed between min and max button press times
// spectating
enum ERotationSoundType
{
	RST_None,
	RST_Rotating,
	RST_Pitching,
	RST_RotAndPitch,
};
var		ERotationSoundType	RotationSoundType;	// What type of rotation sound this weapon should currently be playing

// Internal
var		float			LastYawTime;
var		float			LastPitchTime;
var 	rotator			LocalWeaponAim;

// For passenger only weapon pawns
var		bool			bPassengerOnly;			// This weapon pawn has no gun, its a passenger only. Set this to true to keep passenger only pawns net relevevant

var     bool            bPendingCeaseFire;    // CeaseFire was called, but we're waiting until after the shot has been fired to stop firing
// end _RO_

replication
{
    unreliable if (Role == ROLE_Authority)
        VehicleBase, Gun;
    reliable if (Role < ROLE_Authority)
    	ServerChangeDriverPosition, ServerSetRotatingStatus;
}

// If _RO_
simulated native function UpdateHeadbob(float deltaTime);
simulated native function UpdateTurretRotation(float DeltaTime, float YawChange, float PitchChange);
simulated native function UpdateSpecialCustomAim(float DeltaTime, float YawChange, float PitchChange); // Used to natively set the custom aim for vehicle mounted non-tank turret weapons
simulated event SetRotatingStatus(byte NewRotationStatus)
{
	Switch(NewRotationStatus)
	{
		case 0:
			RotationSoundType = RST_None;
			Break;
		case 1:
			RotationSoundType = RST_Rotating;
			Break;
		case 2:
			RotationSoundType = RST_Pitching;
			Break;
		case 3:
			RotationSoundType = RST_RotAndPitch;
			Break;
		default:
			RotationSoundType = RST_None;
	}

	if (Role < ROLE_Authority)
		ServerSetRotatingStatus(NewRotationStatus);
}

// for tank cannon aiming. Increment the range settings for tank cannons
function IncrementRange()
{
	if( Gun != none )
		Gun.IncrementRange();
}
function DecrementRange()
{
	if( Gun != none )
		Gun.DecrementRange();
}

simulated function int GetTeamNum()
{
	if( GetVehicleBase() != none )
		return GetVehicleBase().GetTeamNum();
}

simulated function ServerSetRotatingStatus(byte NewRotatingStatus)
{
	Switch(NewRotatingStatus)
	{
		case 0:
			RotationSoundType = RST_None;
			Break;
		case 1:
			RotationSoundType = RST_Rotating;
			Break;
		case 2:
			RotationSoundType = RST_Pitching;
			Break;
		case 3:
			RotationSoundType = RST_RotAndPitch;
			Break;
		default:
			RotationSoundType = RST_None;
	}
}

// Ammo Interface

// Returns true if the weapon was resupplied
function bool ResupplyAmmo()
{
	if( Gun != none && Gun.GiveInitialAmmo() )
		return true;

	return false;
}

// end _RO_

// Temp way of getting the bots to use the turrets better
function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local bool bSameTeam;

	bSameTeam = ( GetTeamNum() == TeamIndex );
	if ( bSameTeam )
	{
		if( GetVehicleBase().Occupied()	&& !Occupied() && Health >= 0)
		{
			return 100;
		}
	}

	return super.BotDesireability(S, TeamIndex, Objective);
}


function AttachFlag(Actor FlagActor)
{
	if ( VehicleBase != None )
		VehicleBase.AttachFlag(FlagActor);
	else
		Super.AttachFlag(FlagActor);
}

function Vehicle GetMoveTargetFor(Pawn P)
{
	if ( VehicleBase != None )
		return VehicleBase;
	return self;
}

function bool HasWeapon()
{
	return (Gun != None);
}

function Pawn GetAimTarget()
{
	if ( VehicleBase != None )
		return VehicleBase;
	return self;
}

function bool CanAttack(Actor Other)
{
	if (Gun != None)
		return Gun.CanAttack(Other);

	return false;
}

function bool TooCloseToAttack(Actor Other)
{
	local int NeededPitch;

	if (Gun == None || VSize(Location - Other.Location) > 2500)
		return false;

	if(Gun.FiringMode == 0 )
	{
		Gun.CalcWeaponFire(false);
	}
	else
	{
		Gun.CalcWeaponFire(true);
	}

	NeededPitch = rotator(Other.Location - Gun.WeaponFireLocation).Pitch;
	NeededPitch = NeededPitch & 65535;
	return (LimitPitch(NeededPitch) == NeededPitch);
}

function ChooseFireAt(Actor A)
{
	if (!bHasAltFire)
		Fire(0);
	else if (Gun != None)
	{
		if (Gun.BestMode() == 0)
			Fire(0);
		else
			AltFire(0);
	}
}

function float RefireRate()
{
	if (Gun != None)
	{
		if (bWeaponisAltFiring && bHasAltFire)
			return Gun.AIInfo[1].RefireRate;
		else
			return Gun.AIInfo[0].RefireRate;
	}

	return 0;
}

function bool IsFiring()
{
	return (Gun != None && (bWeaponisFiring || (bWeaponisAltFiring && bHasAltFire)));
}

function bool NeedToTurn(vector targ)
{
	return !(Gun != None && Gun.bCorrectAim);
}

function bool FireOnRelease()
{
	if (Gun != None)
	{
		if (bWeaponisAltFiring && bHasAltFire)
			return Gun.AIInfo[1].bFireOnRelease;
		else
			return Gun.AIInfo[0].bFireOnRelease;
	}

	return false;
}

simulated function bool IndependentVehicle()
{
	return false;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,0,0);
	Canvas.DrawText(DebugInfo);
	YPos += YL;

	YPos += YL;
	Canvas.SetPos(0, YPos);
	Canvas.SetDrawColor(0,0,255);
	Canvas.DrawText("-- Gun: "$Gun);
	YPos += YL;
	Canvas.SetPos(4, YPos);
	Gun.DisplayDebug( Canvas, YL, YPos );

	Canvas.SetPos(4,YPos);
	DebugInfo = "";
}

function BeginPlay()
{
	Super.BeginPlay();

        Gun = spawn(GunClass, self,, Location);
        if (Gun != None)
        {
        	PitchUpLimit = Gun.PitchUpLimit;
        	PitchDownLimit = Gun.PitchDownLimit;
        }
}

simulated function PostNetBeginPlay()
{
    local bool OldCollideActors, OldBlockActors;

    Super.PostNetBeginPlay();

    // We need to do this to properly initiate our skeletal mesh to collide with Karma objects
    if (bCollideActors)
    {
        OldCollideActors = bCollideActors;
        OldBlockActors = bBlockActors;

        GetBoneCoords('');
        SetCollision(False, False);
        SetCollision(OldCollideActors, OldBlockActors);
    }

    TeamChanged();
}

simulated function TeamChanged()
{
	Super.TeamChanged();

/*	if (Gun != None)
		Gun.SetTeam(Team);*/
}

function Vehicle GetVehicleBase()
{
	return VehicleBase;
}

function AttachToVehicle(ROVehicle VehiclePawn, name WeaponBone)
{
    if (Level.NetMode != NM_Client)
    {
        VehicleBase = VehiclePawn;
        VehicleBase.AttachToBone(Gun, WeaponBone);
    }
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector x, y, z;
	local vector VehicleZ, CamViewOffsetWorld;
	local float CamViewOffsetZAmount;
	local coords CamBoneCoords;

    GetAxes(CameraRotation, x, y, z);
	ViewActor = self;

	CamViewOffsetWorld = FPCamViewOffset >> CameraRotation;

	if(CameraBone != '' && Gun != None)
	{
		CamBoneCoords = Gun.GetBoneCoords(CameraBone);
		CameraLocation = CamBoneCoords.Origin + (FPCamPos >> Rotation) + CamViewOffsetWorld;

		if(bFPNoZFromCameraPitch)
		{
			VehicleZ = vect(0,0,1) >> Rotation;
			CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
			CameraLocation -= CamViewOffsetZAmount * VehicleZ;
		}
	}
	else
	{
		CameraLocation = GetCameraLocationStart() + (FPCamPos >> Rotation) + CamViewOffsetWorld;

		if(bFPNoZFromCameraPitch)
		{
			VehicleZ = vect(0,0,1) >> Rotation;
			CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
			CameraLocation -= CamViewOffsetZAmount * VehicleZ;
		}
	}

    CameraRotation = Normalize(CameraRotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

simulated function vector GetCameraLocationStart()
{
	if (VehicleBase != None && Gun != None)
		return VehicleBase.GetBoneCoords(Gun.AttachmentBone).Origin;
	else
		return Super.GetCameraLocationStart();
}

simulated function Destroyed()
{
    if (Level.NetMode != NM_Client && Gun != None)
        Gun.Destroy();

    Super.Destroyed();
}

event EncroachedBy( actor Other )
{
}

// Keeps pawn from setting PHYS_Falling
singular event BaseChange() {}

function Fire(optional float F)
{
	if( Gun != none && !Gun.ReadyToFire(false) )
	{
		return;
	}
	Super.Fire(F);

	if (Gun != None && PlayerController(Controller) != None)
		Gun.ClientStartFire(Controller, false);
}

function AltFire(optional float F)
{
	if( Gun != none && !Gun.ReadyToFire(true) )
	{
		return;
	}

	Super.AltFire(F);

	if (!bWeaponIsFiring && Gun != None && PlayerController(Controller) != None)
		Gun.ClientStartFire(Controller, true);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	Super.ClientVehicleCeaseFire(bWasAltFire);

	if (Gun != None)
	{
		Gun.ClientStopFire(Controller, bWasAltFire);
		if (!bWasAltFire && bWeaponIsAltFiring)
            Gun.ClientStartFire(Controller, true);
    }
}

// Called by the native code after a cannon shot has been attempted to be fired
event FiredPendingPrimary()
{
    Gun.bFiredPendingPrimary = true;

	if( bPendingCeaseFire )
	{
        bPendingCeaseFire=false;

        VehicleCeaseFire(false);
    }
}

// Overriden to fix the blank firing bug
function VehicleFire(bool bWasAltFire)
{
	if (Gun != none && Gun.bPrimaryIgnoreFireCountdown)
	{
        Gun.bFiredPendingPrimary = false;
    }

	Super.VehicleFire(bWasAltFire);
}

function VehicleCeaseFire(bool bWasAltFire)
{
    // Sometimes the VehicleCeaseFire function call can arrive from a client before the the shot
    // was actually fired. This isn't to bad for an MG, but is devastating if the shot was a tank cannon.
    // This is part of the functionality that will ensure that the shot will always at least be
    // attempted to be fired before ceasing fire for tank cannons
	if (!bWasAltFire && Gun != none && Gun.bPrimaryIgnoreFireCountdown && !Gun.bFiredPendingPrimary)
	{
        bPendingCeaseFire = true;
        return;
	}

	Super.VehicleCeaseFire(bWasAltFire);
	if (Gun != None)
	{
		Gun.CeaseFire(Controller,bWasAltFire);
	}
}

function bool TryToDrive(Pawn P)
{
	if (VehicleBase != None)
	{
		if (VehicleBase.NeedsFlip())
		{
			VehicleBase.Flip(vector(P.Rotation), 1);
			return false;
		}

		if (P.GetTeamNum() != Team)
		{
			VehicleLocked(P);
			return false;
		}
	}

	if (VehicleBase.Driver == none && !P.IsHumanControlled() )
		return VehicleBase.TryToDrive(P);

	return Super.TryToDrive(P);
}

function KDriverEnter(Pawn P)
{
	local rotator NewRotation;

	Super.KDriverEnter(P);

	if (VehicleBase != None && VehicleBase.bTeamLocked && VehicleBase.bEnterringUnlocks)
		VehicleBase.bTeamLocked = false;

	Gun.bActive = True;
	if (!bHasOwnHealth && VehicleBase == None)
	{
		Health = Driver.Health;
		HealthMax = Driver.HealthMax;
	}

	NewRotation = Controller.Rotation;
	NewRotation.Pitch = LimitPitch(NewRotation.Pitch);
	SetRotation(NewRotation);
	Driver.bSetPCRotOnPossess = false; //so when driver gets out he'll be facing the same direction as he was inside the vehicle

	if (Gun != None)
	{
		Gun.NetPriority = 2.0;
		Gun.NetUpdateFrequency = 10;
	}
}

function PossessedBy(Controller C)
{
	Super.PossessedBy(C);
	NetPriority = 1.0;
}

function bool KDriverLeave( bool bForceLeave )
{
    local Controller C;

    // We need to get the controller here since Super.KDriverLeave() messes with it.
    C = Controller;
    if (Super.KDriverLeave(bForceLeave) || bForceLeave)
    {
        bWeaponIsFiring = False;

		if (!bHasOwnHealth && VehicleBase == None)
		{
			HealthMax = default.HealthMax;
			Health = HealthMax;
		}

		if (C != None)
		{
			if (Gun != None && xPawn(C.Pawn) != None && C.Pawn.HasUDamage())
				Gun.SetOverlayMaterial(xPawn(C.Pawn).UDamageWeaponMaterial, 0, false);

			C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;

			if (Bot(C) != None)
				Bot(C).ClearTemporaryOrders();
		}

		if (Gun != None)
		{
			Gun.bActive = False;
			Gun.FlashCount = 0;
			Gun.NetUpdateFrequency = Gun.default.NetUpdateFrequency;
			Gun.NetPriority = Gun.default.NetPriority;
		}

		// The the turret stop playing the rotating sound when you get out
		SetRotatingStatus(0);

        return True;
    }
    else
    {
		if ( (Bot(Controller) != None) && (VehicleBase.Driver == None) )
			ServerChangeDriverPosition(1);
        //Log("Cannot leave "$self);
        return False;
    }
}

function DriverDied()
{
    	Super.DriverDied();
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	local rotator NewRotation;

	Super.ClientKDriverEnter(PC);

	NewRotation = PC.Rotation;
	NewRotation.Pitch = LimitPitch(NewRotation.Pitch);
	SetRotation(NewRotation);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	if (Gun != None)
	{
		if (bWeaponisFiring)
			Gun.ClientStopFire(PC, false);
		if (bWeaponisAltFiring)
			Gun.ClientStopFire(PC, true);
	}

	Super.ClientKDriverLeave(PC);
}

function bool PlaceExitingDriver()
{
	local int i;
	local vector tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,0.5);

	//avoid running driver over by placing in direction perpendicular to velocity
	if (VehicleBase != None && VSize(VehicleBase.Velocity) > 100)
	{
		tryPlace = Normal(VehicleBase.Velocity cross vect(0,0,1)) * (VehicleBase.CollisionRadius * 1.25);
		if (FRand() < 0.5)
			tryPlace *= -1; //randomly prefer other side
		if ( (VehicleBase.Trace(HitLocation, HitNormal, VehicleBase.Location + tryPlace + ZOffset, VehicleBase.Location + ZOffset, false, Extent) == None && Driver.SetLocation(VehicleBase.Location + tryPlace + ZOffset))
		     || (VehicleBase.Trace(HitLocation, HitNormal, VehicleBase.Location - tryPlace + ZOffset, VehicleBase.Location + ZOffset, false, Extent) == None && Driver.SetLocation(VehicleBase.Location - tryPlace + ZOffset)) )
			return true;
	}

	for(i=0; i<ExitPositions.Length; i++)
	{
		if ( bRelativeExitPos )
		{
		    if (VehicleBase != None)
		    	tryPlace = VehicleBase.Location + (ExitPositions[i] >> VehicleBase.Rotation) + ZOffset;
        	    else if (Gun != None)
                	tryPlace = Gun.Location + (ExitPositions[i] >> Gun.Rotation) + ZOffset;
	            else
        	        tryPlace = Location + (ExitPositions[i] >> Rotation);
	        }
		else
			tryPlace = ExitPositions[i];

		// First, do a line check (stops us passing through things on exit).
		if ( bRelativeExitPos )
		{
			if (VehicleBase != None)
			{
				if (VehicleBase.Trace(HitLocation, HitNormal, tryPlace, VehicleBase.Location + ZOffset, false, Extent) != None)
					continue;
			}
			else
				if (Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None)
					continue;
		}

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}

simulated function AttachDriver(Pawn P)
{
    local coords GunnerAttachmentBoneCoords;

    if (Gun == None)
    	return;

    P.bHardAttach = True;

    GunnerAttachmentBoneCoords = Gun.GetBoneCoords(Gun.GunnerAttachmentBone);
    P.SetLocation(GunnerAttachmentBoneCoords.Origin);

    P.SetPhysics(PHYS_None);

    Gun.AttachToBone(P, Gun.GunnerAttachmentBone);
    P.SetRelativeLocation(DrivePos + P.default.PrePivot);
	P.SetRelativeRotation( DriveRot );

	P.PrePivot=vect(0,0,0);
}

simulated function DetachDriver(Pawn P)
{
	P.PrePivot=P.default.PrePivot;

    if (Gun != None && P.AttachmentBone != '')
        Gun.DetachFromBone(P);
}

function UpdateRocketAcceleration(float deltaTime, float YawChange, float PitchChange)
{
	local rotator NewRotation;

	NewRotation = Rotation;
	NewRotation.Yaw += 32.0 * deltaTime * YawChange;
	NewRotation.Pitch += 32.0 * deltaTime * PitchChange;
	NewRotation.Pitch = LimitPitch(NewRotation.Pitch);

	SetRotation(NewRotation);
}

simulated function float ChargeBar()
{
	if (Gun != None)
		return Gun.ChargeBar();

	return 0;
}

function SetTeamNum(byte T)
{
	local byte Temp;

	Temp = Team;
	PrevTeam = T;
	Team = T;

	if (Temp != T)
		TeamChanged();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local PlayerController PC;
	local Controller C;

	if ( bDeleteMe || Level.bLevelChange )
		return; // already destroyed, or level is being cleaned up

	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);

	if ( Controller != None )
	{
		C = Controller;
		C.WasKilledBy(Killer);
		Level.Game.Killed(Killer, C, self, damageType);
		if( C.bIsPlayer )
		{
			PC = PlayerController(C);
			if ( PC != None )
				ClientKDriverLeave(PC); // Just to reset HUD etc.
			else
                ClientClearController();
			if ( (bRemoteControlled || bEjectDriver) && (Driver != None) && (Driver.Health > 0) )
			{
				C.Unpossess();
				C.Possess(Driver);
				if ( bEjectDriver )
					EjectDriver();
				Driver = None;
			}
			else
			{
                		if (PC != None && VehicleBase != None)
		                {
                		    PC.SetViewTarget(VehicleBase);
		                    PC.ClientSetViewTarget(VehicleBase);
                		}
				C.PawnDied(self);
			}
		}
		else
			C.Destroy();
	}
	else
		Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	Destroy();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    if (bHasOwnHealth)
    	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
    else if (Driver != None)
    {
        Driver.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
        if (VehicleBase == None)
	        Health = Driver.Health;
    }
}

simulated function SwitchWeapon(byte F)
{
	if (VehicleBase != None)
		ServerChangeDriverPosition(F);
}

function ServerChangeDriverPosition(byte F)
{
	local Pawn OldDriver, Bot;

	if (Driver == None || VehicleBase == None)
		return;

	if (F == 1 && (VehicleBase.Driver == None || AIController(VehicleBase.Controller) != None))
	{
		OldDriver = Driver;
		//if human player wants a bot's seat, bot swaps with him
		if (AIController(VehicleBase.Controller) != None)
		{
			Bot = VehicleBase.Driver;
			VehicleBase.KDriverLeave(true);
		}
		KDriverLeave(true);
		if (!VehicleBase.TryToDrive(OldDriver))
		{
			KDriverEnter(OldDriver);
			if (Bot != None)
				VehicleBase.KDriverEnter(Bot);
		}
		else if (Bot != None)
			TryToDrive(Bot);
		return;
	}

	F -= 2;
	if (F < VehicleBase.WeaponPawns.length && (VehicleBase.WeaponPawns[F].Driver == None || AIController(VehicleBase.WeaponPawns[F].Controller) != None))
	{
		OldDriver = Driver;
		//if human player wants a bot's seat, bot swaps with him
		if (AIController(VehicleBase.WeaponPawns[F].Controller) != None)
		{
			Bot = VehicleBase.WeaponPawns[F].Driver;
			VehicleBase.WeaponPawns[F].KDriverLeave(true);
		}
		KDriverLeave(true);
		if (!VehicleBase.WeaponPawns[F].TryToDrive(OldDriver))
		{
			KDriverEnter(OldDriver);
			if (Bot != None)
				VehicleBase.WeaponPawns[F].KDriverEnter(Bot);
		}
		if (Bot != None)
			TryToDrive(Bot);
	}
}

function int LimitPitch(int pitch, optional float DeltaTime)
{
	if (VehicleBase == None || Gun == None)
		return Super.LimitPitch(pitch);

	return Gun.LimitPitch(pitch, VehicleBase.Rotation);
}

function bool TeamLink(int TeamNum)
{
	if (VehicleBase != None && !bHasOwnHealth)
		return VehicleBase.TeamLink(TeamNum);

	return Super.TeamLink(TeamNum);
}

simulated function DrawHUD(Canvas Canvas)
{
    local PlayerController PC;
    local vector CameraLocation;
    local rotator CameraRotation;
    local Actor ViewActor;

	if (IsLocallyControlled() && Gun != None && Gun.bCorrectAim)
	{
		Canvas.DrawColor = CrosshairColor;
		Canvas.DrawColor.A = 255;
		Canvas.Style = ERenderStyle.STY_Alpha;

		Canvas.SetPos(Canvas.SizeX*0.5-CrosshairX, Canvas.SizeY*0.5-CrosshairY);
		Canvas.DrawTile(CrosshairTexture, CrosshairX*2.0+1, CrosshairY*2.0+1, 0.0, 0.0, CrosshairTexture.USize, CrosshairTexture.VSize);

	}

    PC = PlayerController(Controller);
	if (PC != None && !PC.bBehindView && HUDOverlay != None)
	{
        if (!Level.IsSoftwareRendering())
        {
    		CameraRotation = PC.Rotation;
    		SpecialCalcFirstPersonView(PC, ViewActor, CameraLocation, CameraRotation);
    		HUDOverlay.SetLocation(CameraLocation + (HUDOverlayOffset >> CameraRotation));
    		HUDOverlay.SetRotation(CameraRotation);
    		Canvas.DrawActor(HUDOverlay, false, false, FClamp(HUDOverlayFOV * (PC.DesiredFOV / PC.DefaultFOV), 1, 170));
    	}
	}
	else
        ActivateOverlay(False);
}

simulated function PostNetReceive()
{
	local int i;

	if (VehicleBase != None)
	{
		bNetNotify = false;
		for (i = 0; i < VehicleBase.WeaponPawns.Length; i++)
			if (VehicleBase.WeaponPawns[i] == self)
				return;
		VehicleBase.WeaponPawns[VehicleBase.WeaponPawns.length] = self;
	}
}

event ApplyFireImpulse(bool bAlt)
{
    if (!bAlt)
        VehicleBase.KAddImpulse(FireImpulse >> Gun.WeaponFireRotation, Gun.WeaponFireLocation);
    else
        VehicleBase.KAddImpulse(AltFireImpulse >> Gun.WeaponFireRotation, Gun.WeaponFireLocation);
}

static function StaticPrecache(LevelInfo L)
{
    Default.GunClass.static.StaticPrecache(L);
}

simulated function ProjectilePostRender2D(Projectile P, Canvas C, float ScreenLocX, float ScreenLocY);

defaultproperties
{
     bHistoryWarmup=True
     bHasAltFire=True
     HeadRotationOffset=(Pitch=32768,Yaw=32768,Roll=32768)
     HeadRotationSnapRates=(X=3.000000,Y=3.000000,Z=3.000000)
     ShiftHalf=(Pitch=32768,Yaw=32768,Roll=32768)
     MinRotateThreshold=0.100000
     MaxRotateThreshold=1.000000
     bDrawVehicleShadow=False
     bDrawDriverInTP=True
     bTurnInPlace=True
     bFollowLookDir=True
     bDrawMeshInFP=True
     bZeroPCRotOnEntry=False
     bPCRelativeFPRotation=False
     EntryRadius=50.000000
     bCrawler=True
     bIgnoreForces=True
     bStationary=True
     bSpecialHUD=True
     bSpecialCalcView=True
     bSetPCRotOnPossess=False
     LandMovementState="PlayerTurreting"
     DrawType=DT_None
     bAcceptsProjectors=False
     bIgnoreEncroachers=True
     bNetInitialRotation=True
     NetPriority=0.500000
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bProjTarget=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bNetNotify=True
}
