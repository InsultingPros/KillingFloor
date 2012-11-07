// I'd like this to be a sort of multi-purpose actor for the chopper.
// It can be set up to use any combination of pre-made take-off / landing anims.
class ChopperProp extends Decoration;

var() enum NameEn
{
	Land_London,
	Leave_London,
	Leave_Manor,
	Crash_Manor,
	StrafingRun_Land,
	Do_Nothing
} ChopperAnim,ChopperTriggeredAnim;

var bool bTriggered,bClientTriggered; // Only Trigger Once.

// shadow variables
var Projector Shadow;
var ShadowProjector PlayerShadow;
var globalconfig bool bBlobShadow;
var Effect_ShadowController RealtimeShadow;

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		bTriggered;
}

simulated function PostBeginPlay()
{
	if( Level.NetMode==NM_DedicatedServer )
		Return;

	// decide which type of shadow to spawn
	if( !Class'KFPawn'.Default.bRealtimeShadows )
	{
		PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
		PlayerShadow.ShadowActor = self;
		PlayerShadow.bBlobShadow = bBlobShadow;
		PlayerShadow.LightDirection = Normal(vect(1,1,3));
		PlayerShadow.LightDistance = 320;
		PlayerShadow.MaxTraceDistance = 350;
		PlayerShadow.InitShadow();
	}
	else
	{
		RealtimeShadow = Spawn(class'Effect_ShadowController',self,'',Location);
		RealtimeShadow.Initialize();
	}
}

simulated function PostNetBeginPlay()
{
	if( bTriggered )
		PlayChopperAnim(ChopperTriggeredAnim);
	else PlayChopperAnim(ChopperAnim);
	bClientTriggered = bTriggered;
	bNetNotify = True;
}

simulated function PostNetReceive()
{
	if( bClientTriggered==bTriggered )
		Return;
	if( bTriggered )
		PlayChopperAnim(ChopperTriggeredAnim);
	else PlayChopperAnim(ChopperAnim);
	bClientTriggered = bTriggered;
}

simulated function PlayChopperAnim( NameEn ChAnim )
{
	if( Level.NetMode==NM_DedicatedServer )
		Return;

	// Starting Anim.
	Switch( ChAnim )
	{
		Case Land_London:
			PlayAnim('Land_London');
			Break;
		Case Leave_London:
			PlayAnim('Leave_London');
			Break;
		Case Crash_Manor:
			PlayAnim('Crash_Manor');
			Break;
		Case StrafingRun_Land:
			PlayAnim('StrafingRun_Land');
			Break;
	}
}

function FireRockets() // And the point of this function is (it isnt even in sync with the mesh)?
{
	local vector Start;
	local rotator Dir;
	local Projectile P;

	Start = Location;
	Dir = Rotation;

	P = Spawn(class'KFMod.LawProj',,, Start, Dir);
}

function RemoveChopper()
{
	bHidden = true;
} 

// Triggered / Secondary Anim
function Trigger( actor Other, pawn EventInstigator )
{
	if (bTriggered)
		return;

	NetUpdateTime = Level.TimeSeconds - 1;
	PlayChopperAnim(ChopperTriggeredAnim);
	bTriggered = true;
}

simulated function Destroyed()
{
	if( PlayerShadow != None )
		PlayerShadow.Destroy();
	if(RealtimeShadow !=none)
		RealtimeShadow.Destroy();
	Super.Destroyed();
}

function Reset()
{
	bTriggered = False;
	NetUpdateTime = Level.TimeSeconds - 1;
	PlayChopperAnim(ChopperAnim);
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     bStasis=False
     bAlwaysRelevant=True
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=0.500000
     Mesh=SkeletalMesh'KFMapObjects.Chopper'
     DrawScale=2.500000
}
