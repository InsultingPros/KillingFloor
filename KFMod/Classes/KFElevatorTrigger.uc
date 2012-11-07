//=============================================================================
// KF Use Trigger. Now with bigger messages, and Refire delays for human users.
//
// By: Alex
// Major fixes by Marco (16.1.2009).
//=============================================================================
class KFElevatorTrigger extends KFUseTrigger;

var() float ReUseDelay;
var transient float NextAttemptTime;
var() Sound ActivateSound; // Beep Beep TOOT TOOT! wizzzzPOW!
var KFElevator MyElevator;
var byte MyFloorNum; // 255 - Elevator itself.

function bool SelfTriggered()
{
	return true;
}
function NotifyElevatorStarted( float MoveTimer )
{
	NextAttemptTime = Level.TimeSeconds+MoveTimer+ReUseDelay;
	SetTimer(MoveTimer+ReUseDelay+1,false);
}
function UsedBy( Pawn user )
{
	local byte k;

	if( Level.TimeSeconds>NextAttemptTime )
	{
		if( MyFloorNum==255 )
		{
			if( AIController(user.Controller)!=None )
				k = MyElevator.GetAIDesiredFloor(user);
			else k = 255;
			if( k==255 )
			{
				if( MyElevator.KeyNum>=MyElevator.NumberOfFloors )
					k = 0;
				else k = MyElevator.KeyNum+1;
			}
		}
		else k = MyFloorNum;
		NextAttemptTime = Level.TimeSeconds+0.5+MyElevator.DelayTime;
		MyElevator.GoToFloor(k,Self,user);
		PlaySound(ActivateSound,SLOT_None, 255, false,200,,true);
	}
}
function Reset()
{
	NextAttemptTime = -1;
}
function Timer()
{
	local Pawn P;

	foreach TouchingActors(Class'Pawn',P)
		Touch(P);
}
function Touch( Actor Other )
{
	Super(UseTrigger).Touch(Other);
}

defaultproperties
{
     ReUseDelay=2.000000
}
