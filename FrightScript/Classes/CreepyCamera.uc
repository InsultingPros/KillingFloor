// a really creepy camera that is always looking in your direction.
// it can be destroyed if you shoot it

// Author: Alex Quick

class CreepyCamera extends Actor
placeable;

var () bool DebugCamera;
// the player this camera is focusing on.
var protected Pawn  CameraTarget;
// the rotation of the camera at level startup
var protected Rotator InitialRotation;
// limits on the rotation of the camera
var () const float PitchLimit,YawLimit;
// effect to spawn when this camera is destroyed
var protected class<Emitter> DestructionEffect;

simulated function PostBeginPlay()
{
    InitialRotation = Rotation;
    DesiredRotation = InitialRotation;
}

simulated function Tick(float DeltaTime)
{
    OrientCameraToLocalPlayer();

    if(DebugCamera)
    {
        PrintDebugLogs();
    }
}

simulated function PrintDebugLogs()
{
    log("======= CAMERA DEBUG ================");
    log(" -->"@Self@" TARGET : "@CameraTarget@"InitialRotation :"@InitialRotation@" DesiredRotation :"@DesiredRotation);
}

// turn the camera so its looking at the local player
simulated function OrientCameraToLocalPlayer()
{
    local rotator NewRotation;
    local byte LockYaw,LockPitch;

    if(CameraTarget == none)
    {
        FindCameraTarget();
    }
    else
    {
        NewRotation = Rotator((CameraTarget.Location + (Vect(0,0,1)* CameraTarget.EyeHeight)) - Location) ;

        // If the desired rotation goes beyond the camera's limit, stop turning it.
        if(CameraTarget.Health <= 0 ||
        CameraTarget.bDeleteMe)
        {
            StopTracking();
            return;
        }

        if(IsOutSideViewFrustrum(CameraTarget,LockYaw,LockPitch))
        {
            StopTracking();
        }
        else
        {
            if(LockPitch == 0)
            {
                DesiredRotation.Pitch = NewRotation.Pitch;
            }

            if(LockYaw == 0)
            {
                DesiredRotation.Yaw = NewRotation.Yaw;
            }
        }
    }
}

simulated function StopTracking()
{
    CameraTarget = none;
    NetUpdateFrequency = 0.1;    // camera isn't really do anything at the moment, so it doesn't need frequent replication updates.
}

simulated function bool IsOutsideViewFrustrum(Pawn TestTarget, optional out byte LockYaw, optional out byte LockPitch)
{
    local Rotator RotExtent,IntendedRotation;

    IntendedRotation = Rotator((TestTarget.Location + (Vect(0,0,1)* TestTarget.EyeHeight)) - Location) ;
    RotExtent = IntendedRotation - InitialRotation;

    RotExtent.Yaw = RotExtent.Yaw & 65535;
    if( RotExtent.Yaw > YawLimit &&
       RotExtent.Yaw < (65535+ (-YawLimit)) )
    {
        LockYaw = 1;
    }

    RotExtent.Pitch = RotExtent.Pitch & 65535;
    if( RotExtent.Pitch > PitchLimit &&
       RotExtent.Pitch < (65535+ (-PitchLimit)) )
    {
        LockPitch = 1;
    }

    return LockPitch == 1 && LockYaw == 1;
}

simulated function FindCameraTarget()
{
    // do this separately on each client so the camera is looking at them.
    if(Level.NetMode == NM_DedicatedServer)
    {
        return;
    }

    if(Level.GetLocalPlayerController().Pawn != none &&
    Level.GetLocalPlayerController().Pawn.Health > 0)
    {
        CameraTarget = Level.GetLocalPlayerController().Pawn;
        NetUpdateTime = Level.TimeSeconds - 1;
        NetUpdateFrequency = default.NetUpdateFrequency;
    }
}


simulated function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    DestroyCamera(EventInstigator);
}

function DestroyCamera(Pawn Killer)
{
    TriggerEvent(Event,self,Killer);
    
    bHidden = true;
    SetCollision(false,false);

	bSkipActorPropertyReplication = false;
	NetUpdateTime = Level.TimeSeconds - 1;

    if(Level.NetMode != NM_DedicatedServer)
    {
        SpawnDestructionEffect();
    }
}

simulated function SpawnDestructionEffect()
{
    Spawn(DestructionEffect);
}

simulated event PostNetReceive()
{
	if ( bHidden )
	{
		SpawnDestructionEffect();
		bNetNotify = false; // finished
	}
}

defaultproperties
{
     PitchLimit=10000.000000
     YawLimit=16000.000000
     DestructionEffect=Class'KFStoryGame.Emitter_BreakerExplosion'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'FrightYard_SM.Camera.Trader_Security_Cam'
     bNoDelete=True
     bAlwaysRelevant=True
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
     Physics=PHYS_Rotating
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=0.100000
     bCanBeDamaged=True
     CollisionRadius=15.000000
     CollisionHeight=15.000000
     bCollideActors=True
     bBlockActors=True
     bUseCylinderCollision=True
     bNetNotify=True
     bRotateToDesired=True
     RotationRate=(Pitch=10000,Yaw=10000)
     bDirectional=True
}
