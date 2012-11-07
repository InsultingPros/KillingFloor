//=============================================================================
// © 2003 Matt 'SquirrelZero' Farber
//=============================================================================
// "UT2k3 Ultimate Flashlight"
// I wrote this using _both_ a dynamic projector and a dynamic light, with the
// dynamic projector as the focal point and lightsource providing general
// ambient illumination.  Either one by itself is pretty dull, but combine the
// two and you've got yourself a really nice effect if done correctly.
//=============================================================================
class Effect_TacLightProjector extends DynamicProjector;

// add a light too, there seems to be a problem with the projector darkening terrain sometimes
var Effect_TacLightGlow TacLightGlow;
var Weapon ValidWeapon;

var Pawn LightPawn;
var bool bHasLight;
var WeaponAttachment AssignedAttach;

var byte LightRot[2];

var KFPlayerController AssignedPC;
var bool bIsAssigned;

var vector WallHitLocation;

var()   float   ProjectorPullbackDist;

replication
{
	// relevant variables needed by the client
	reliable if (Role == ROLE_Authority)
		LightPawn,bHasLight;
	unreliable if( Role == ROLE_Authority && !bNetOwner && bHasLight )
		LightRot;
}

// setup the pawn and controller variables, spawn the dynamic light
simulated function PostBeginPlay()
{
	SetCollision(True, False, False);
	if (Owner != None)
	{
		LightPawn = Pawn(Owner);
		ValidWeapon = LightPawn.Weapon;
	}
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( TacLightGlow==None )
		TacLightGlow = spawn(class'Effect_TacLightGlow');
	if( Class'KFPawn'.Default.bDetailedShadows )
	{
		AssignedPC = KFPlayerController(Level.GetLocalPlayerController());
		if( AssignedPC!=None )
			AddProjecting();
		LightRadius = 1;
	}
}
simulated function AddProjecting()
{
	bIsAssigned = True;
	AssignedPC.LightSources[AssignedPC.LightSources.Length] = Self;
}
simulated function RemoveProjecting()
{
	local int i,l;

	bIsAssigned = False;
	l = AssignedPC.LightSources.Length;
	for( i=0; i<l; i++ )
		if( AssignedPC.LightSources[i]==Self )
		{
			AssignedPC.LightSources.Remove(i,1);
			return;
		}
}
simulated function Destroyed()
{
	Super.Destroyed();
	if( TacLightGlow!=None )
		TacLightGlow.Destroy();
	if( KFWeaponAttachment(AssignedAttach)!=None )
	{
		KFWeaponAttachment(AssignedAttach).TacBeamGone();
		AssignedAttach = None;
	}
	if( bIsAssigned )
	{
		RemoveProjecting();
		AssignedPC = None;
	}
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    local vector StartTrace;
    local coords LightBonePosition;

    LightBonePosition = LightPawn.Weapon.GetBoneCoords('LightBone');
    StartTrace = LightBonePosition.Origin - LightPawn.Weapon.Location;
	StartTrace = StartTrace * 0.2;
	StartTrace = StartTrace + LightBonePosition.XAxis * KFWeapon(LightPawn.Weapon).FirstPersonFlashlightOffset.X + LightBonePosition.YAxis * KFWeapon(LightPawn.Weapon).FirstPersonFlashlightOffset.Y + LightBonePosition.ZAxis * KFWeapon(LightPawn.Weapon).FirstPersonFlashlightOffset.Z;
	StartTrace = LightPawn.Weapon.Location + StartTrace;

	LightPawn.DrawDebugSphere(StartTrace, 10.0, 10, 255, 0, 0);

	LightPawn.DrawDebugSphere(WallHitLocation, TacLightGlow.LightRadius, 10, 255, 255, 0);

	Canvas.DrawText("LIGHT" @ Location @ "Hit="$WallHitLocation);
	YPos += YL;

	Canvas.DrawText("LightRadius: "$TacLightGlow.LightRadius$" LightBrightness: "$TacLightGlow.LightBrightness$" DrawScale = "$DrawScale$" FOV = "$FOV);
	YPos += YL;


}

// updates the taclight projector and dynamic light positions
simulated function Tick(float DeltaTime)
{
	local vector StartTrace,EndTrace,X,HitLocation,HitNormal,AdjustedLocation;
	local float BeamLength;
	local rotator R;
	local coords LightBonePosition;
	local KFWeapon KFWeap;
	local Actor HitActor;

	if( Level.NetMode==NM_DedicatedServer )
	{
		if( LightPawn==none || LightPawn.Weapon==None || LightPawn.Weapon!=ValidWeapon )
		{
			Destroy();
			return;
		}
		SetLocation(LightPawn.Location);
		if( !bHasLight || LightPawn.Controller==None )
			Return;
		LightRot[0] = LightPawn.Controller.Rotation.Yaw/256;
		LightRot[1] = LightPawn.Controller.Rotation.Pitch/256;
		Return;
	}
	if (TacLightGlow == None)
		return;

	if( Level.NetMode!=NM_Client && (LightPawn == none || LightPawn.Weapon==None || LightPawn.Weapon!=ValidWeapon) )
	{
		DetachProjector();
		Destroy();
		return;
	}

	// we're changing its location and rotation, so detach it
	DetachProjector();

	// fallback
	if( LightPawn==None || !bHasLight )
	{
		if (TacLightGlow != None)
			TacLightGlow.bDynamicLight = false;
		if( AssignedAttach!=None )
		{
			if( KFWeaponAttachment(AssignedAttach)!=None )
				KFWeaponAttachment(AssignedAttach).TacBeamGone();
			AssignedAttach = None;
		}
		if( bIsAssigned )
			RemoveProjecting();
		return;
	}

	if( Level.NetMode!=NM_Client || PlayerController(LightPawn.Controller)!=None )
	{
		if( PlayerController(LightPawn.Controller)==None || PlayerController(LightPawn.Controller).bBehindView || LightPawn.Weapon==None )
		{
			if( XPawn(LightPawn)!=None && XPawn(LightPawn).WeaponAttachment!=None )
				StartTrace = XPawn(LightPawn).WeaponAttachment.Location;
			else StartTrace = LightPawn.Location+LightPawn.EyePosition();
		}
		else
        {
            KFWeap = KFWeapon(LightPawn.Weapon);

            LightBonePosition = KFWeap.GetBoneCoords('LightBone');
            StartTrace = LightBonePosition.Origin - KFWeap.Location;
        	StartTrace = StartTrace * 0.2;
        	StartTrace = StartTrace + LightBonePosition.XAxis * KFWeap.FirstPersonFlashlightOffset.X
                + LightBonePosition.YAxis * KFWeap.FirstPersonFlashlightOffset.Y
                + LightBonePosition.ZAxis * KFWeap.FirstPersonFlashlightOffset.Z;
        	StartTrace = KFWeap.Location + StartTrace;
        }

		if ( LightPawn.IsLocallyControlled() && PlayerController(LightPawn.Controller) != none && !PlayerController(LightPawn.Controller).bBehindView )
		{
			X = LightPawn.Weapon.GetBoneCoords('LightBone').XAxis;
			R = rotator(X);
		}
		else if ( XPawn(LightPawn) != none && XPawn(LightPawn).WeaponAttachment != none )
		{
			if ( DualiesAttachment(XPawn(LightPawn).WeaponAttachment) != none )
			{
				if ( DualiesAttachment(XPawn(LightPawn).WeaponAttachment).Mesh == DualiesAttachment(XPawn(LightPawn).WeaponAttachment).BrotherMesh )
				{
					X = DualiesAttachment(XPawn(LightPawn).WeaponAttachment).Brother.GetBoneCoords('FlashLight').XAxis;
					R = rotator(X);
				}
				else
				{
					X = XPawn(LightPawn).WeaponAttachment.GetBoneCoords('FlashLight').XAxis;
					R = rotator(X);
				}
			}
			else
			{
				X = XPawn(LightPawn).WeaponAttachment.GetBoneCoords('FlashLight').XAxis;
				R = rotator(X);
			}
		}
		else
		{
			R = LightPawn.Controller.Rotation;
			X = vector(R);
		}

		if( Level.NetMode!=NM_Client )
		{
			LightRot[0] = R.Yaw/256;
			LightRot[1] = R.Pitch/256;
		}
	}
	else
	{
		if( XPawn(LightPawn)!=None && XPawn(LightPawn).WeaponAttachment!=None && (Level.TimeSeconds-LightPawn.LastRenderTime)<1 )
			StartTrace = XPawn(LightPawn).WeaponAttachment.Location;
		else StartTrace = LightPawn.Location+LightPawn.EyePosition();

		R.Yaw = LightRot[0]*256;
		R.Pitch = LightRot[1]*256;
		X = vector(R);
	}

	// not too far out, we don't want a flashlight that can shine across the map
	EndTrace = StartTrace + 1800*X;

    HitActor = Trace(HitLocation,HitNormal,EndTrace,StartTrace,true);

	if( HitActor == none )
		HitLocation = EndTrace;

	WallHitLocation = HitLocation;

	// find out how far the first hit was
	BeamLength = VSize(StartTrace-HitLocation);

	// this makes a neat focus effect when you get close to a wall
	if (BeamLength <= 90)
		SetDrawScale(FMax(0.02,(BeamLength/90))*Default.DrawScale);
	else SetDrawScale(Default.DrawScale);

	FOV = Lerp((BeamLength / 1800.0),(default.FOV * 0.6),default.FOV);

    // Don't let the projector penetrate the wall
    if (BeamLength <= ProjectorPullbackDist)
    {
        SetLocation(StartTrace - X * (ProjectorPullbackDist - BeamLength));
    }
    else
    {
        SetLocation(StartTrace);
    }

	SetRotation(R);

	// reattach it
	AttachProjector();

	// turns the dynamic light on if it's off
	if (!TacLightGlow.bDynamicLight)
		TacLightGlow.bDynamicLight = True;

	// again, neat focus effect up close, starts earlier than the dynamic projector
	if (BeamLength <= 100)
	{
		TacLightGlow.LightBrightness = TacLightGlow.Default.LightBrightness;
		TacLightGlow.LightRadius = Lerp((BeamLength / 100.0),0.0,(TacLightGlow.Default.LightRadius * 1.25));
	} // else we scale its radius and brightness depending on distance from the material
	else
	{
		// fades the lightsource out as it moves farther away
		TacLightGlow.LightBrightness = TacLightGlow.Default.LightBrightness * (1.0 - (BeamLength / 1800.0));

		// this makes the light act more like a spotlight, resizing depending on distance
		TacLightGlow.LightRadius = FMin((TacLightGlow.Default.LightRadius * 4),Lerp((BeamLength / 900.0),TacLightGlow.Default.LightRadius,TacLightGlow.Default.LightRadius * 4));
	}
	AdjustedLocation = HitLocation;

	// Pull back a bit so the light doesn't go through the terrain
	if( HitActor != none && HitActor.IsA('TerrainInfo') )
	{
	   TacLightGlow.SetLocation(AdjustedLocation - 50 * X );
	}
	else
	{
	   TacLightGlow.SetLocation(AdjustedLocation);
	}

	if( XPawn(LightPawn)!=None && XPawn(LightPawn).WeaponAttachment!=AssignedAttach )
	{
		if( KFWeaponAttachment(AssignedAttach)!=None )
			KFWeaponAttachment(AssignedAttach).TacBeamGone();
		AssignedAttach = XPawn(LightPawn).WeaponAttachment;
	}
	if( KFWeaponAttachment(AssignedAttach)!=None )
		KFWeaponAttachment(AssignedAttach).UpdateTacBeam(BeamLength);
	if( !bIsAssigned && AssignedPC!=None )
		AddProjecting();
}

defaultproperties
{
     ProjectorPullbackDist=25.000000
     MaterialBlendingOp=PB_Modulate
     FrameBufferBlendingOp=PB_Add
     ProjTexture=Texture'KillingFloorWeapons.Dualies.LightCircle'
     FOV=50
     MaxTraceDistance=1600
     bClipBSP=True
     bProjectOnUnlit=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     bNoProjectOnOwner=True
     DrawType=DT_None
     bLightChanged=True
     bHidden=False
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     DrawScale=0.100000
}
