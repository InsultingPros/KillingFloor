// By: Alex
// Major fixes by Marco.
class KFElevator extends Mover;

var() float ElevatorMoveSpeed;
var() name ElevatorFloorTags[8]; // The tag of the desired doors/triggers.
var() name ElevatorCenterTriggerTag; // The tag of the trigger inside elevator.
var sound DummySound;
struct DoorMType
{
	var array<KFElevatorDoorMover> Doors;
};
var DoorMType FloorMovers[ArrayCount(ElevatorFloorTags)];
var KFElevatorTrigger FloorTriggers[ArrayCount(ElevatorFloorTags)],ElevCenterTrigger;
var LiftExit MyExits[ArrayCount(ElevatorFloorTags)]; // Our desired lift exits for AI hint.
var byte GoalKeyFrame,NumberOfFloors;
var bool bElevatorActive;

function PostBeginPlay()
{
	local KFElevatorDoorMover K;
	local KFElevatorTrigger T;
	local byte i;
	local NavigationPoint N;

	Super.PostBeginPlay();
	DummySound = AmbientSound;

	ForEach DynamicActors(class'KFElevatorTrigger',T)
	{
		for( i=0; i<ArrayCount(ElevatorFloorTags); i++ )
		{
			if( ElevatorFloorTags[i]!='' && ElevatorFloorTags[i]==T.Tag )
			{
				FloorTriggers[i] = T;
				T.MyElevator = Self;
				T.MyFloorNum = i;
				NumberOfFloors = i;
				break;
			}
		}
		if( ElevatorCenterTriggerTag!='' && T.Tag==ElevatorCenterTriggerTag )
		{
			ElevCenterTrigger = T;
			T.MyElevator = Self;
			T.SetBase(Self);
			T.MyFloorNum = 255;
		}
	}
	ForEach DynamicActors(class'KFElevatorDoorMover',K)
	{
		for( i=0; i<ArrayCount(ElevatorFloorTags); i++ )
		{
			if( ElevatorFloorTags[i]!='' && ElevatorFloorTags[i]==K.Tag )
			{
				NumberOfFloors = i;
				FloorMovers[i].Doors[FloorMovers[i].Doors.Length] = K;
				if( FloorTriggers[i]!=None )
				{
					FloorTriggers[i].AddDoor(K);
					K.MyTrigger = FloorTriggers[i];
				}
				break;
			}
		}
	}
	for( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
	{
		if( LiftExit(N)!=None && LiftExit(N).MyLift==Self && LiftExit(N).KeyFrame<ArrayCount(ElevatorFloorTags) )
			MyExits[LiftExit(N).KeyFrame] = LiftExit(N);
	}
}


// Handle when the mover finishes closing.
function FinishedClosing()
{
	Super.FinishedClosing();
	AmbientSound = DummySound;
}

// Handle when the mover finishes opening.
function FinishedOpening()
{
	Super.FinishedOpening();
	AmbientSound = DummySound;
}

// Interpolation ended.
simulated event KeyFrameReached()
{
	local Mover M;

	PrevKeyNum = KeyNum;
	PhysAlpha  = 0;
	ClientUpdate--;

	// Finished interpolating.
	NetUpdateTime = Level.TimeSeconds - 1;
	FinishNotify();
	if ( (ClientUpdate == 0) && ((Level.NetMode != NM_Client) || bClientAuthoritative) )
	{
		RealPosition = Location;
		RealRotation = Rotation;
		ForEach BasedActors(class'Mover', M)
			M.BaseFinished(); 
	}
}

function DoOpen()
{
	local byte i;
	local float MT;

	bOpening = true;
	bDelaying = false;
	MT = FMax(VSize(KeyPos[GoalKeyFrame]-Location)/ElevatorMoveSpeed,0.1f);
	InterpolateTo( GoalKeyFrame, MT );
	for( i=0; i<=NumberOfFloors; i++ )
		if( FloorTriggers[i]!=None )
			FloorTriggers[i].NotifyElevatorStarted(MT);
	if( ElevCenterTrigger!=None )
		ElevCenterTrigger.NotifyElevatorStarted(MT);
	MakeNoise(1.0);
	PlaySound( OpeningSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
	AmbientSound = MoveAmbientSound;
	TriggerEvent(OpeningEvent, Self, Instigator);
}

/* Attempt to figure out the AI players desired floor, if fails then do like with players */
function byte GetAIDesiredFloor( Pawn Other )
{
	local int i;
	local byte j;

	for( i=0; i<5; i++ )
		if( LiftExit(Other.Controller.RouteCache[i])!=None )
		{
			for( j=0; j<=NumberOfFloors; j++ )
				if( MyExits[j]==Other.Controller.RouteCache[i] )
				{
					if( j==KeyNum )
						break;
					return j;
				}
		}
	return 255;
}

function GoToFloor( byte FloorNum, Actor Other, Pawn EventInstigator )
{
	Trigger(Other,EventInstigator);
}

//=================================================================
// Other Mover States

// Toggle when triggered.
state() Elevator
{
Ignores Trigger;

	function bool SelfTriggered()
	{
		return false;
	}
	function Reset()
	{
		super.Reset();

		if ( bOpening )
		{
			// Reset instantly
			SetResetStatus( true );
			GotoState(,'Close');
		}
	}
	function GoToFloor( byte FloorNum, Actor Other, Pawn EventInstigator )
	{
		if( KeyNum==FloorNum || bElevatorActive )
			return; // nocando.
		GoalKeyFrame = FloorNum;
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger != None )
			SavedTrigger.BeginEvent();
		bElevatorActive = true;
		GotoState(,'Open');
	}
	function ToggleDoors( byte KeyNums, bool bOpened )
	{
		local int l,i;

		l = FloorMovers[KeyNums].Doors.Length;
		for( i=0; i<l; i++ )
		{
			FloorMovers[KeyNums].Doors[i].Instigator = Instigator;
			if( bOpened )
				FloorMovers[KeyNums].Doors[i].GoToState(,'Open');
			else FloorMovers[KeyNums].Doors[i].GoToState(,'Close');
		}
	}
Begin:
	Sleep(0.01);
	ToggleDoors(KeyNum,True);
	Stop;
Open:
	ToggleDoors(KeyNum,False);
	bClosed = false;
	TriggerEvent(OpeningEvent, Self, Instigator);
	if ( DelayTime > 0 )
	{
		bDelaying = true;
		Sleep(DelayTime);
	}
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	bElevatorActive = false;
	if ( SavedTrigger != None )
		SavedTrigger.EndEvent();
	ToggleDoors(GoalKeyFrame,True);
	Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	SetResetStatus( false );
}

defaultproperties
{
     ElevatorMoveSpeed=500.000000
     MoverEncroachType=ME_IgnoreWhenEncroach
     InitialState="Elevator"
     TransientSoundVolume=100.000000
}
