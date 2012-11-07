//=============================================================================
// SavedMove is used during network play to buffer recent client moves,
// for use when the server modifies the clients actual position, etc.
// This is a built-in Unreal class and it shouldn't be modified.
//
// Aren't we rebels - modified to support Red Orchestra movement - Ramm 7/13/05
//=============================================================================
class SavedMove extends Info;

// also stores info in Acceleration attribute
var SavedMove NextMove;		// Next move in linked list.
var float TimeStamp;		// Time of this move.
var float Delta;			// amount of time for this move
var bool	bRun;
var bool	bDuck;
var bool	bPressedJump;
var bool	bSprint;
var bool	bCrawl;
var EDoubleClickDir DoubleClickMove;	// Double click info.
var EPhysics SavedPhysics;
var vector StartLocation, StartRelativeLocation, StartVelocity, StartFloor, SavedLocation, SavedVelocity, SavedRelativeLocation;
var Actor StartBase, EndBase;
var rotator WeaponBufferRotation;

final function Clear()
{
	TimeStamp = 0;
	Delta = 0;
	DoubleClickMove = DCLICK_None;
	Acceleration = vect(0,0,0);
	StartVelocity = vect(0,0,0);
	bRun = false;
	bDuck = false;
	bPressedJump = false;
	bSprint = false;
	bCrawl = false;
}

final function PostUpdate(PlayerController P)
{
	if ( P.Pawn != None )
	{
		SavedLocation = P.Pawn.Location;
		SavedVelocity = P.Pawn.Velocity;
		EndBase = P.Pawn.Base;
		if ( (EndBase != None) && !EndBase.bWorldGeometry )
			SavedRelativeLocation = P.Pawn.Location - EndBase.Location;
	}
	SetRotation(P.Rotation);
	WeaponBufferRotation = P.WeaponBufferRotation;
}

final function bool IsJumpMove()
{
  return ( bPressedJump || ((DoubleClickMove != DCLICK_None) && (DoubleClickMove != DCLICK_Active) && (DoubleClickMove != DCLICK_Done)) );
}

function vector GetStartLocation()
{
	if ( (Vehicle(StartBase) != None) || (Mover(StartBase) != None) )
		return StartBase.Location + StartRelativeLocation;

	return StartLocation;

}
final function SetInitialPosition(Pawn P)
{
	SavedPhysics = P.Physics;
	StartLocation = P.Location;
	StartVelocity = P.Velocity;
	StartBase = P.Base;
	StartFloor = P.Floor;
	if ( (StartBase != None) && !StartBase.bWorldGeometry )
		StartRelativeLocation = P.Location - StartBase.Location;
}

final function SetMoveFor(PlayerController P, float DeltaTime, vector NewAccel, EDoubleClickDir InDoubleClick)
{
	Delta = DeltaTime;
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	if ( P.Pawn != None )
		SetInitialPosition(P.Pawn);
	Acceleration = NewAccel;
	DoubleClickMove = InDoubleClick;
	bRun = (P.bRun > 0);
	bDuck = (P.bDuck > 0);
	bPressedJump = P.bPressedJump;
	bSprint = (P.bSprint > 0);
	bCrawl = (P.bCrawl > 0);
	TimeStamp = Level.TimeSeconds;
}

defaultproperties
{
}
