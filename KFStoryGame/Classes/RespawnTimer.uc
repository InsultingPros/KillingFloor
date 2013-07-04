/*
	--------------------------------------------------------------
	RespawnTimer
	--------------------------------------------------------------

	Modified volumeTimer for use with KF_StoryCheckPointVolume actors.
	Author :  Alex Quick

	--------------------------------------------------------------
*/

class RespawnTimer extends info;

var 		KF_StoryCheckPointVolume		CheckPoint;
var 		float							TimerFrequency;
var			bool							bInitialised;


function PostBeginPlay()
{
	super.PostBeginPlay();
	CheckPoint = KF_StoryCheckPointVolume(Owner);
	SetTimer(1.0, false);
}

function Timer()
{
	if(!bInitialised)
	{
		bInitialised = true;
		SetTimer(TimerFrequency, false);
	}
	else
	{
		CheckPoint.RespawnTimerPop();
	}
}

function Reset()
{
	bInitialised = false;
	Timer();
}

defaultproperties
{
     TimerFrequency=2.000000
}
