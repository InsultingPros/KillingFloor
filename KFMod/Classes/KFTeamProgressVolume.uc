// Ok, what this does is it basically checks to see if
// every player on the server is in a certain area, and if 
// that is satisfied, it calls the volume's event.
// This is useful for story based missions where you need to 
// gather your whole team before you can progress.

// Alex
class KFTeamProgressVolume extends PhysicsVolume;

var int NumTouching; 
var() bool bOff; // Whatever if the volume should start disabled.

// Configurable Variables

var() bool bDisableAfterTriggered;   // default true.  Changes this if you'd like to the volume to continue checking player counts.
var() bool bTimeOut;   // default false.  If true, the volume's event will fire even if not all players are inside.
var() int TimeOutSeconds;  // Number of seconds before timeout is called
var() float PlayerThreshold;  // Min percent of total players who HAVE to be in the volume before the timeout can go through.
var() bool bTeleportWhenAbsent; // Teleport all players here that are not inside the volume (to in volume playerstarts).
var() bool bRepawnDeadPlayers; // All fallen players will respawn here (to in volume playerstarts).
var() enum EVolTriggerAct
{
	VTR_ToggleDisabled,
	VTR_Untrigger,
	VTR_TurnOff,
	VTR_TurnOn,
	VTR_FinishEvent
} VolumeTriggerAction;
var array<PlayerStart> PSList;

simulated function PostBeginPlay()
{
	local NavigationPoint N;
	local PlayerStart PS;
	local int i;

	Super.PostBeginPlay();
	if( Level.NetMode==NM_Client )
		return;
	For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		PS = PlayerStart(N);
		if( PS!=None && PS.PhysicsVolume==Self )
		{
			PS.bEnabled = False;
			PSList.Length = i+1;
			PSList[i] = PS;
			i++;
		}
	}
}
function PlayerStart PickRandomSpawnPoint()
{
	Return PSList[Rand(PSList.Length)];
}
function int CountAlivePlayers()
{
	local Controller C;
	local int i;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( PlayerController(C)!=None && C.Pawn!=None && C.Pawn.Health>0 )
			i++;
	}
	Return i;
}

simulated event PawnEnteredVolume(Pawn Other)
{
	local vector HitLocation,HitNormal;
	local Actor SpawnedEntryActor;

	if ( bWaterVolume && (Level.TimeSeconds - Other.SplashTime > 0.3) && (PawnEntryActor != None) && !Level.bDropDetail && (Level.DetailMode != DM_Low) && EffectIsRelevant(Other.Location,false) )
	{
		if ( !TraceThisActor(HitLocation, HitNormal, Other.Location - Other.CollisionHeight*vect(0,0,1), Other.Location + Other.CollisionHeight*vect(0,0,1)) )	
		{
			SpawnedEntryActor = Spawn(PawnEntryActor,Other,,HitLocation,rot(16384,0,0));
			if( SpawnedEntryActor!=None )
				SpawnedEntryActor.RemoteRole = ROLE_None;
		}
	}
	if( bOff || Level.NetMode==NM_Client || PlayerController(Other.Controller)==None )
		return;
	NumTouching++;
	CheckActivity();
}

function CheckActivity()
{
	local int i;

	i = CountAlivePlayers();

	if( i>=NumTouching )
	{
		if( IsInState('TimingOut') )
			GoToState('');
		FinishedEvent();
	}
	else if( NumTouching>0 && bTimeOut && (float(i)/float(NumTouching))>=PlayerThreshold )
	{
		SetTimer(2,True);
		if( !IsInState('TimingOut') )
			GoToState('TimingOut');
	}
	else
	{
		if( IsInState('TimingOut') )
			GoToState('');
		if( NumTouching<=0 )
			SetTimer(0,False);
		else SetTimer(2,True);
	}
}

function Timer()
{
	CheckActivity();
}

State TimingOut
{
Begin:
	Sleep(TimeOutSeconds);
	FinishedEvent();
}

function FinishedEvent()
{
	local Controller C;
	local PlayerStart P;

	if( bOff )
		Return;
	if( PSList.Length>0 && KFSPGameType(Level.Game)!=None )
		KFSPGameType(Level.Game).SpawnVolume = Self;
	if( bTeleportWhenAbsent )
	{
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( PlayerController(C)!=None && C.Pawn!=None && C.Pawn.Health>0 && C.Pawn.PhysicsVolume!=Self )
			{
				P = PickRandomSpawnPoint();
				if( P==None )
					Continue;
				C.Pawn.PlayTeleportEffect(True,False);
				C.Pawn.SetLocation(P.Location);
				C.ClientSetRotation(P.Rotation);
				C.Pawn.PlayTeleportEffect(False,True);
			}
		}
	}
	if( bRepawnDeadPlayers )
	{
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( PlayerController(C)!=None && (C.Pawn==None || C.Pawn.Health<=0) && !C.PlayerReplicationInfo.bOnlySpectator )
			{
				C.GotoState('PlayerWaiting');
				C.PlayerReplicationInfo.bOutOfLives = false;
				C.PlayerReplicationInfo.NumLives = 0;
				C.ServerReStartPlayer();
				PlayerController(C).ClientSetViewTarget(C.Pawn);
				PlayerController(C).SetViewTarget(C.Pawn);
			}
		}
	}
	TriggerEvent(Event,self,None);
	if(bDisableAfterTriggered)
	{
		SetTimer(0,False);
		bOff = true;
	}
}

simulated event PawnLeavingVolume(Pawn P)
{
	if( bOff || Level.NetMode==NM_Client || PlayerController(P.Controller)==None )
		return;
	NumTouching--;
	CheckActivity();
}

function PlayerPawnDiedInVolume(Pawn Other)
{
	if( bOff || Level.NetMode==NM_Client || PlayerController(Other.Controller)==None )
		return;
	NumTouching --;
	CheckActivity();
}

function Trigger( actor Other, pawn EventInstigator )
{
	Switch( VolumeTriggerAction )
	{
		Case VTR_ToggleDisabled:
			bOff = !bOff;
			Return;
		Case VTR_Untrigger:
			if( NumTouching>0 )
				UntriggerEvent(Event,self, EventInstigator );
			Return;
		Case VTR_TurnOff:
			bOff = True;
			Return;
		Case VTR_TurnOn:
			bOff = False;
			Return;
		Case VTR_FinishEvent:
			bOff = False;
			FinishedEvent();
			Return;
	}
}

defaultproperties
{
     bDisableAfterTriggered=True
     TimeOutSeconds=60
     PlayerThreshold=0.750000
     bStatic=False
     RemoteRole=ROLE_None
}
