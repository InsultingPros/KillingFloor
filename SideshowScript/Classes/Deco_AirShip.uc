class Deco_AirShip extends Decoration;

#exec OBJ LOAD FILE=Pier_anim.ukx

var KFEventListener PlayLandEvent;
var KFEventListener PlayTakeOffEvent;

var name ClientAnim;

var() name LandEventName, TakeOffEventName;

struct AnimRepInfo
{
	var name    AnimName;	// The name of the animation to play
	var float	StartTime;	// The in game time that the animation first began playing
};

var AnimRepInfo AnimInfo;

replication
{
	reliable if( Role == ROLE_Authority )
		AnimInfo;
}

simulated function PostBeginPlay()
{
	// Starts the airship in the sky
	PlayAnim( 'Land', 1.0f );
	StopAnimating();
	SetUpListeners();
}

// Create actors to tell us when an event is called
function SetUpListeners()
{
	PlayLandEvent = Spawn( class 'KFEventListener' );
	PlayTakeOffEvent = Spawn( class 'KFEventListener' );

	PlayLandEvent.SetEventListenerInfo( self, LandEventName );
	PlayTakeOffEvent.SetEventListenerInfo( self, TakeOffEventName );
}

// Called when an event listener's tag is called on the server
function ReceivedEvent( name EventName )
{
	local AnimRepInfo TempRepInfo;
	local KFGameType KFGame;

	if ( EventName == LandEventName )
	{
		TempRepInfo.AnimName = 'Land';
	}
	else if ( EventName == TakeOffEventName )
	{
		TempRepInfo.AnimName = 'TakeOff';
	}

   	KFGame = KFGameType(Level.Game);

   	if ( KFGame != none )
   	{
   		// Get the elapsed time that the airship animation began playing
		TempRepInfo.StartTime = float( KFGame.ElapsedTime );
	}

	AnimInfo = TempRepInfo;	// Replicates AnimInfo To the client

	// Play animations if offline
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ClientPlayAnim( AnimInfo.AnimName, 0 );
	}
}

simulated function PostNetReceive()
{
	local float CurrentAnimTime;
	local PlayerController PC;
	local GameReplicationInfo GRI;

   	if ( ClientAnim != AnimInfo.AnimName )
   	{
	   	ClientAnim = AnimInfo.AnimName;

   		PC = Level.GetLocalPlayerController();

   		if ( PC != none )
   		{
   			GRI = PC.GameReplicationInfo;

	   		if ( GRI != none )
	   		{
   		   		// Get the time elapsed upon receiving the newest animation
				//( This is done to play an animation part in synch with everyone else, if a player joins late )
		   		CurrentAnimTime = float( GRI.ElapsedTime ) - AnimInfo.StartTime;
	   		}
   		}

		ClientPlayAnim( AnimInfo.AnimName, CurrentAnimTime );
 	}
}

simulated function ClientPlayAnim( name AnimName, float CurrentAnimTime )
{
	local float CurrentAnimProgress; // Value from 0.0-1.0

	CurrentAnimProgress = CurrentAnimTime / GetAnimDuration( AnimName, 1.0f );

	PlayAnim( AnimName, 1.0f );
	SetAnimFrame( CurrentAnimProgress );
}

defaultproperties
{
     LandEventName="AirshipLandEvent"
     TakeOffEventName="AirshipTakeOffEvent"
     bStatic=False
     bNoDelete=True
     bStasis=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=1.000000
     Mesh=SkeletalMesh'Pier_anim.AirShip_Main'
     bNetNotify=True
}
