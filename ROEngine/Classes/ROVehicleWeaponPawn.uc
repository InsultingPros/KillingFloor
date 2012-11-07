//===================================================================
// ROVehicleWeaponPawn
//
// Copyright (C) 2004 John "Ramm-Jaeger"  Gibson
//
// Base class for RO vehicle weapon pawns
//===================================================================

class ROVehicleWeaponPawn extends VehicleWeaponPawn
       abstract;


var			byte			CurrentCapArea;
var			byte			CurrentCapProgress;
var         byte            CurrentCapAxisCappers;
var         byte            CurrentCapAlliesCappers;
var()          float       	WeaponFov;
var			localized string		HudName;
var         localized string        DriverHudName;

// For hud
var     bool                bIsMountedTankMG;
var()   texture             AmmoShellTexture;
var()   texture             AmmoShellReloadTexture;


// Driver position vars
struct PositionInfo
{
	var()   vector           ViewLocation;           	// The position the players first person view will be placed
	//var()   vector           ViewOffset;           	// The offset position the players first person view will be placed // depractated
	var()   float            ViewFOV;	               //
	var     mesh             PositionMesh;           	// The mesh to swap to when the player is in this position
	var     name             TransitionUpAnim;         	// The animation for the vehicle to play when transitioning up to this position
	var     name             TransitionDownAnim;       	// The animation for the vehicle to play when transitioning down to this position
	var     name             DriverTransitionAnim;   	// The animation for the pawn to play when transitioning to this position
	var()   int              ViewPitchUpLimit;       	// The max amount to allow the player's view to pitch up
	var()   int              ViewPitchDownLimit;     	// The max amount to allow the player's view to down up
	var()   int              ViewPositiveYawLimit;   	// The max amount to allow the player's view to yaw right
	var()   int              ViewNegativeYawLimit;   	// The max amount to allow the player's view to yaw left
	var     bool             bDrawOverlays;
	var     bool             bExposed;               	// The driver is vulnerable to enemy fire
};

var()   array<PositionInfo> DriverPositions;     	// List of positions the driver can switch between and the properties for each
var     int                 DriverPositionIndex;    // Currently selected driver position
var     int                 SavedPositionIndex;    	// Currently selected driver position
var	   	int					LastPositionIndex;      // Index of the last position we were in
var		int					PendingPositionIndex;	// Position index the client is trying to switch to

var 	   	bool				bMultiPosition;		// This weaponpawn can use multiple positions
var	   		bool				bInitializedVehicleBase; // Already done the postnetreceive to find vehicle base. Needed becase we override postnetreceive from ONSWeaponPawn
var	   		bool				bInitializedVehicleGun;  // Already done postnetrecieve initialization of needed client side vehiclegun settings.
var	   		bool				bMustBeTankCrew;		// Have to be a tank crewmember to use this vehicle
var 	   	bool				bSinglePositionExposed; // The driver is vulnerable to enemy fire for single position weapon pawns

//=============================================================================
// replication
//=============================================================================
replication
{
	reliable if (bNetOwner && Role == ROLE_Authority)
		CurrentCapArea, CurrentCapProgress, CurrentCapAxisCappers, CurrentCapAlliesCappers;

    // Server to client
	reliable if (bNetDirty && Role == ROLE_Authority)
		DriverPositionIndex, LastPositionIndex;

    // Server to client
	reliable if (bNetInitial && Role == ROLE_Authority)
		bMultiPosition, bMustBeTankCrew;

	// replicated functions sent to server by owning client
	reliable if( Role<ROLE_Authority )
		ServerChangeViewPoint;
}

// overloaded to support head-bob
simulated function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	UpdateHeadbob(deltaTime);
}

// Overriden for locking the player to the camerabone
simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector VehicleZ, CamViewOffsetWorld, x, y, z;
	local float CamViewOffsetZAmount;
	local quat AQuat, BQuat, CQuat;

	GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;

    //__________________________________________
    // Camera ROTATION -------------------------

   	if( IsInState('ViewTransition') )
		CameraRotation = GetBoneRotation( 'Camera_driver' );
	else if ( bPCRelativeFPRotation )
 	    CameraRotation = Rotation;
    else
        CameraRotation = rotator(vect(0,0,0));

    //__________________________________________
    // Camera LOCATION -------------------------
    CameraLocation = GetBoneCoords('Camera_driver').Origin;
	// Camera position is locked to car
	CamViewOffsetWorld = FPCamViewOffset >> CameraRotation;
	if(bFPNoZFromCameraPitch)
	{
		VehicleZ = vect(0,0,1) >> Rotation;
		CamViewOffsetZAmount = CamViewOffsetWorld dot VehicleZ;
		CameraLocation -= CamViewOffsetZAmount * VehicleZ;
	}

    //__________________________________________
    // (Almost) Finalize the camera ------------
   	CameraRotation = Normalize(CameraRotation + PC.ShakeRot);
	CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;

    //__________________________________________
    // Are we in an animation? If so, don't
    // allow additional camera rotation to the
    // animation's movement --------------------
    if ( !IsInState('ViewTransition') )
    {
        //__________________________________________
        // To headbob, or not To headbob -----------
        if ( !DriverPositions[DriverPositionIndex].bDrawOverlays )
        {
            //__________________________________________
            // Tricky Quat stuff to get rotation to work
            // when the player faces backwards in a
            // vehicle. Quats are not communitive like
            // rotators (aparently) which is why I am
            // using them. -----------------------------
            //__________________________________________
            // First, Rotate the headbob by the player
            // controllers rotation (looking around) ---
            AQuat = QuatFromRotator(PC.Rotation);
            BQuat = QuatFromRotator(HeadRotationOffset - ShiftHalf);
            CQuat = QuatProduct(AQuat,BQuat);
            //__________________________________________
            // Then, rotate that by the vehicles rotation
            // to get the final rotation ---------------
            AQuat = QuatFromRotator(CameraRotation);
            BQuat = QuatProduct(CQuat,AQuat);
            //__________________________________________
            // Make it back into a rotator!
            CameraRotation = QuatToRotator(BQuat);
	    }
    	else
	        CameraRotation += PC.Rotation;
    }
}

// Allow behindview for debugging
exec function ToggleViewLimit()
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() || Level.NetMode != NM_Standalone  )
		return;

    if( bAllowViewChange )
    {
        bAllowViewChange=false;
    }
    else
    {
        bAllowViewChange=true;
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
			if (VehicleBase.Driver == None)
				return VehicleBase.TryToDrive(P);

			VehicleLocked(P);
			return false;
		}
	}

	if( bMustBeTankCrew && !ROPlayerReplicationInfo(P.Controller.PlayerReplicationInfo).RoleInfo.bCanBeTankCrew && P.IsHumanControlled())
	{
	   DenyEntry( P, 0 );
	   return false;
	}

	return Super.TryToDrive(P);
}

// Send a message on why they can't get in the vehicle
function DenyEntry( Pawn P, int MessageNum )
{
	P.ReceiveLocalizedMessage(class'ROVehicleMessage', MessageNum);
}


simulated function vector GetViewLocation()
{
	return Gun.GetBoneCoords('Camera_com').Origin;
}

// Non Authoritative clients can have the status get stuck in the Leaving Vehicle state. This
// checks for that and fixes it.
simulated event DrivingStatusChanged()
{
    Super.DrivingStatusChanged();

    if (bDriving)
    {
       if(Role < ROLE_Authority && IsInState('LeavingVehicle'))
       {
            GotoState('');
       }
    }
}

// Overriden to handle mesh swapping when entering the vehicle
simulated function ClientKDriverEnter(PlayerController PC)
{
    if ( bMultiPosition )
	    Gotostate('EnteringVehicle');

	PendingPositionIndex = 0;
	StoredVehicleRotation = VehicleBase.Rotation;

	super.ClientKDriverEnter(PC);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
 	if ( bMultiPosition )
	 	Gotostate('LeavingVehicle');

	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

function bool KDriverLeave(bool bForceLeave)
{
	local bool bSuperDriverLeave;

	DriverPositionIndex=0;
	bSuperDriverLeave = super.KDriverLeave(bForceLeave);

	ROVehicle(GetVehicleBase()).MaybeDestroyVehicle();
	return bSuperDriverLeave;
}

function DriverDied()
{
	DriverPositionIndex=0;
	super.DriverDied();
	ROVehicle(GetVehicleBase()).MaybeDestroyVehicle();

	// Kill the rotation sound if the driver dies but the vehicle doesnt
    if ( GetVehicleBase().Health > 0 )
		SetRotatingStatus(0);
}


simulated state ViewTransition
{
	simulated function HandleTransition()
	{
	    StoredVehicleRotation = VehicleBase.Rotation;

		if( Role == ROLE_AutonomousProxy || Level.Netmode == NM_Standalone  || Level.NetMode == NM_ListenServer )
		{
 			if( DriverPositions[DriverPositionIndex].PositionMesh != none && Gun != none)
				Gun.LinkMesh(DriverPositions[DriverPositionIndex].PositionMesh);
		}

         // bDrawDriverinTP=true;//Driver.HasAnim(DriverPositions[DriverPositionIndex].DriverTransitionAnim);

		if(Driver != none && Driver.HasAnim(DriverPositions[DriverPositionIndex].DriverTransitionAnim)
			&& Driver.HasAnim(DriverPositions[LastPositionIndex].DriverTransitionAnim))
		{
			Driver.PlayAnim(DriverPositions[DriverPositionIndex].DriverTransitionAnim);
		}

        WeaponFOV = DriverPositions[DriverPositionIndex].ViewFOV;

		FPCamPos = DriverPositions[DriverPositionIndex].ViewLocation;
		//FPCamViewOffset = DriverPositions[DriverPositionIndex].ViewOffset; // depractated

		if( DriverPositionIndex != 0 )
		{
			if( DriverPositions[DriverPositionIndex].bDrawOverlays )
				PlayerController(Controller).SetFOV( WeaponFOV );
			else
				PlayerController(Controller).DesiredFOV = WeaponFOV;
		}

		if( LastPositionIndex < DriverPositionIndex)
		{
			if( Gun.HasAnim(DriverPositions[LastPositionIndex].TransitionUpAnim) )
			{
				Gun.PlayAnim(DriverPositions[LastPositionIndex].TransitionUpAnim);
				SetTimer(Gun.GetAnimDuration(DriverPositions[LastPositionIndex].TransitionUpAnim, 1.0),false);
			}
			else
				GotoState('');
		}
		else if ( Gun.HasAnim(DriverPositions[LastPositionIndex].TransitionDownAnim) )
		{
			Gun.PlayAnim(DriverPositions[LastPositionIndex].TransitionDownAnim);
			SetTimer(Gun.GetAnimDuration(DriverPositions[LastPositionIndex].TransitionDownAnim, 1.0),false);
		}
		else
		{
			GotoState('');
		}
	}

	simulated function Timer()
	{
		GotoState('');
	}

	simulated function EndState()
	{
		if( PlayerController(Controller) != none )
		{
			PlayerController(Controller).SetFOV( DriverPositions[DriverPositionIndex].ViewFOV );
			//PlayerController(Controller).SetRotation( Gun.GetBoneRotation( 'Camera_com' ));
		}
	}

	simulated function AnimEnd(int channel)
	{
		GotoState('');
	}

Begin:
	HandleTransition();
	Sleep(0.2);
}

simulated function AnimateTransition()
{
	if(Driver != none && Driver.HasAnim(DriverPositions[DriverPositionIndex].DriverTransitionAnim)
		&& Driver.HasAnim(DriverPositions[LastPositionIndex].DriverTransitionAnim))
	{
		Driver.PlayAnim(DriverPositions[DriverPositionIndex].DriverTransitionAnim);
	}

	if( LastPositionIndex < DriverPositionIndex)
	{
		 if( Gun.HasAnim(DriverPositions[LastPositionIndex].TransitionUpAnim) )
		 	Gun.PlayAnim(DriverPositions[LastPositionIndex].TransitionUpAnim);
	}
	else if ( Gun.HasAnim(DriverPositions[LastPositionIndex].TransitionDownAnim) )
	{
		Gun.PlayAnim(DriverPositions[LastPositionIndex].TransitionDownAnim);
	}
}


simulated state EnteringVehicle
{
	simulated function HandleEnter()
	{
    		//if( DriverPositions[0].PositionMesh != none)
         	//	LinkMesh(DriverPositions[0].PositionMesh);
		if( Role == ROLE_AutonomousProxy || Level.Netmode == NM_Standalone ||  Level.Netmode == NM_ListenServer)
		{
 			if( DriverPositions[0].PositionMesh != none && Gun != none)
 			{
				Gun.LinkMesh(DriverPositions[0].PositionMesh);
			}
		}

		if( Gun.HasAnim(Gun.BeginningIdleAnim))
		{
		    Gun.PlayAnim(Gun.BeginningIdleAnim);
	    }

		WeaponFOV = DriverPositions[0].ViewFOV;
		PlayerController(Controller).SetFOV( WeaponFOV );

		FPCamPos = DriverPositions[0].ViewLocation;
		// depractated
		//FPCamViewOffset = DriverPositions[0].ViewOffset;
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
		//SwitchToExteriorMesh();
	    if( Gun != none && ( Role == ROLE_AutonomousProxy || Level.Netmode == NM_Standalone  || Level.NetMode == NM_ListenServer ) )
	    {
            Gun.LinkMesh(Gun.Default.Mesh);
        }

	    if( Gun.HasAnim(Gun.BeginningIdleAnim))
	    {
            Gun.PlayAnim(Gun.BeginningIdleAnim);
        }
	}

	// Don't switch viewpoints if we're in this state
	simulated function NextViewPoint() {}

	simulated function BeginState()
	{
		HandleExit();
	}

Begin:
	Sleep(0.2);
	GotoState('');
}

simulated function SwitchToExteriorMesh()
{
	if( Gun != none && ( Role == ROLE_AutonomousProxy || Level.Netmode == NM_Standalone  || Level.NetMode == NM_ListenServer ) )
	{
        Gun.LinkMesh(Gun.Default.Mesh);
    }
}

simulated function PostNetReceive()
{
	local int i;

	if ( Gun != none && bMultiPosition && DriverPositionIndex != SavedPositionIndex )
	{
		if( Level.NetMode == NM_Client && !IsLocallyControlled() && Driver == none && DriverPositionIndex > 0)
		{
		// do nothing
		}
		else
		{
			LastPositionIndex = SavedPositionIndex;
			SavedPositionIndex = DriverPositionIndex;
			NextViewPoint();
		}
	}

    // On the client, this actor can be destroyed when it becomes irrelevant. When it respawns, these values need to be set again as the values will be unset and cause a bunch of errors.
    if( !bInitializedVehicleGun && Gun != none )
    {
        bInitializedVehicleGun= true;
        Gun.SetOwner(self);
		Gun.Instigator = self;
    }

	// Overridden from the Super because we need to use this PostNetReceive, not turn off bNetNotify
	if (!bInitializedVehicleBase && VehicleBase != none)
	{
		bInitializedVehicleBase = true;

		// On the client, this actor can be destroyed when it becomes irrelevant. When it respawns, these weaponpawns array needs filled again, as it will be empty and cause lots of errors.
        if( VehicleBase.WeaponPawns.Length > 0 && VehicleBase.WeaponPawns.Length > PositionInArray &&
            (VehicleBase.WeaponPawns[PositionInArray] == none || VehicleBase.WeaponPawns[PositionInArray].default.Class == none) )
		{
		     VehicleBase.WeaponPawns[PositionInArray] = self;
		     return;
		}

		for (i = 0; i < VehicleBase.WeaponPawns.Length; i++)
		{
            if (VehicleBase.WeaponPawns[i] != none && (VehicleBase.WeaponPawns[i] == self || VehicleBase.WeaponPawns[i].Class == class))
			{
            	return;
			}
		}

		VehicleBase.WeaponPawns[PositionInArray] = self;
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

/* =================================================================================== *
* NextViewPoint()
* Handles switching to the next view point in the list of available viewpoints
* for the driver.
*
* created by: Ramm 10/08/04
* =================================================================================== */
simulated function NextViewPoint()
{
	if( Level.NetMode == NM_Client && !IsLocallyControlled())
	{
        AnimateTransition();
	}
	else
	{
        GotoState('ViewTransition');
	}
}

function ServerChangeViewPoint(bool bForward)
{
    if (bForward)
	{
		if ( DriverPositionIndex < (DriverPositions.Length - 1) )
		{
			LastPositionIndex = DriverPositionIndex;
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
			LastPositionIndex = DriverPositionIndex;
			DriverPositionIndex--;

			if(  Level.Netmode == NM_Standalone || Level.Netmode == NM_ListenServer )
			{
				NextViewPoint();
			}
		}
     }
}

function BeginPlay()
{
        Gun = spawn(GunClass, self,, Location);
        // decouple this because it doesn't actually work right. Getting some strange Gimble Lock or something - Ramm
        /*if (Gun != None)
        {
        	PitchUpLimit = Gun.PitchUpLimit;
        	PitchDownLimit = Gun.PitchDownLimit;
        }*/
}

function int LocalLimitPitch(int pitch)
{
	pitch = pitch & 65535;

    //log("LocalLimitPitch Pitch = "$Pitch$" PitchUpLimit = "$PitchUpLimit$" PitchDownLimit = "$PitchDownLimit);

    if ( bMultiPosition )
    {

	    if (pitch > DriverPositions[DriverPositionIndex].ViewPitchUpLimit && pitch < DriverPositions[DriverPositionIndex].ViewPitchDownLimit)
	    {
	        if (pitch - DriverPositions[DriverPositionIndex].ViewPitchUpLimit < PitchDownLimit - pitch)
	            pitch = DriverPositions[DriverPositionIndex].ViewPitchUpLimit;
	        else
	            pitch = DriverPositions[DriverPositionIndex].ViewPitchDownLimit;
	    }
    }
    else
    {
	    if (pitch > PitchUpLimit && pitch < PitchDownLimit)
	    {
	        if (pitch - PitchUpLimit < PitchDownLimit - pitch)
	            pitch = PitchUpLimit;
	        else
	            pitch = PitchDownLimit;
	    }
    }
    return pitch;
}

function int LimitPitch(int pitch, optional float DeltaTime)
{
    return LocalLimitPitch(pitch);
}

// The the info for the other poeple in your vehicle
simulated function DrawPassengers(Canvas Canvas)
{
/*	local float X, Y, XL, YL;
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
	// ROUT2k4merge Had do swap this out - Ramm
	Canvas.Font = class'HUD'.Static.GetConsoleFont(Canvas);//class'ROHUD'.Static.GetConsoleFont(Canvas);


	if(GetVehicleBase().PlayerReplicationInfo != none)
	{
		Canvas.StrLen("Driver: "$GetVehicleBase().PlayerReplicationInfo.PlayerName, XL, YL);
		Canvas.DrawTextJustified("Driver: "$GetVehicleBase().PlayerReplicationInfo.PlayerName, 2, X, Y, X + XL, Y+YL);
		scalar -= 0.025;
		X = PassengerListX * Canvas.ClipX;
		Y = (PassengerListY + scalar) * Canvas.ClipY;
		Canvas.SetPos(X , Y );
     }

	for (i = 0; i < ROVehicle(GetVehicleBase()).WeaponPawns.length; i++)
	{
		if( ROVehicle(GetVehicleBase()).WeaponPawns[i].PlayerReplicationInfo != none && ROVehicle(GetVehicleBase()).WeaponPawns[i] != self)
		{
			Canvas.StrLen(ROVehicleWeaponPawn(ROVehicle(GetVehicleBase()).WeaponPawns[i]).HudName$": "$ROVehicle(GetVehicleBase()).WeaponPawns[i].PlayerReplicationInfo.PlayerName, XL, YL);
			Canvas.DrawTextJustified(ROVehicleWeaponPawn(ROVehicle(GetVehicleBase()).WeaponPawns[i]).HudName$": "$ROVehicle(GetVehicleBase()).WeaponPawns[i].PlayerReplicationInfo.PlayerName, 2, X, Y, X + XL, Y+YL);

			scalar -= 0.025;
			X = PassengerListX * Canvas.ClipX;
			Y = (PassengerListY + scalar) * Canvas.ClipY;
			Canvas.SetPos(X , Y );
 		}
	}

     Canvas.DrawColor = SavedColor;
*/
}

// 1.0 = 0% reloaded, 0.0 = 100% reloaded (e.g. finished reloading)
function float getAmmoReloadState()
{
    local ROTankCannon cannon;

    cannon = ROTankCannon(gun);

    if (cannon == none)
        return 0.0;

    switch (cannon.CannonReloadState)
    {
        case CR_ReadyToFire:    return 0.00;
        case CR_Waiting:
        case CR_Empty:
        case CR_ReloadedPart1:  return 1.00;
        case CR_ReloadedPart2:  return 0.75;
        case CR_ReloadedPart3:  return 0.50;
        case CR_ReloadedPart4:  return 0.25;
    }

    return 0.0;
}

// Only do the driver radius damage if the player is exposed
function DriverRadiusDamage(float DamageAmount, float DamageRadius, Controller EventInstigator, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	if ( Driver != none && ((bMultiPosition && DriverPositions[DriverPositionIndex].bExposed) || bSinglePositionExposed))
    {
	   Super.DriverRadiusDamage(DamageAmount, DamageRadius, EventInstigator, DamageType, Momentum, HitLocation);
	}
}

// Overridden to support player's obliterating whence they are
// ejected from the dieing weaponpawn.
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

		if ( Driver != none )
 		{
            if ( !bRemoteControlled && !bEjectDriver )
	        {
	            if (!bDrawDriverInTP && PlaceExitingDriver())
	        	{
	                Driver.StopDriving(self);
	                Driver.DrivenVehicle = self;
		        }
 		        Driver.SetTearOffMomemtum(Velocity * 0.25);
			    Driver.Died(Controller, class'RODiedInTankDamType', Driver.Location);
            }
            else
            {
                    if ( bEjectDriver )
						EjectDriver();
					else
						KDriverLeave( false );
            }
        }
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

defaultproperties
{
     CurrentCapArea=255
     WeaponFov=85.000000
     DriverHudName="Driver"
     bZeroPCRotOnEntry=True
     bAdjustDriversHead=False
}
