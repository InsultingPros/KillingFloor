/*
	--------------------------------------------------------------
	Condition_Timed
	--------------------------------------------------------------

    A Condition which is marked complete after a specified amount of
    time expires.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_Timed extends KF_ObjectiveCondition
editinlinenew;

var                        bool                       bTraderTime;

var ()                     float                      Duration;

var                        float                      RemainingSeconds;

var                        float                      StartTime;

function AdjustToDifficulty(float Difficulty)
{
    Duration /= FMax(Difficulty-2,1);
}

function Reset()
{
    Super.Reset();
    StartTime = 0.f;
    RemainingSeconds = Duration;
}

function ConditionActivated(pawn ActivatingPlayer)
{
    Super.ConditionActivated(ActivatingPlayer);
//    log("======================"@self@"was just activated by : "@ActivatingPlayer,'Story_Debug');
    RemainingSeconds = Duration ;
    StartTime = GetObjOwner().Level.TimeSeconds ;
}

/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
     return    FClamp(1.f- (RemainingSeconds / Duration),0.f,1.f);
}

function ConditionTick(float DeltaTime)
{
    local float NewTimeRemaining;

    if(RemainingSeconds > 0)
    {
        NewTimeRemaining = FMax(Duration - int(GetObjOwner().Level.TimeSeconds - StartTime),0) ;
        RemainingSeconds = NewTimeRemaining;
    }

    Super.ConditionTick(DeltaTime);
}

function        string      GetDataString()
{
     if(HUD_Screen.Screen_CountStyle == Count_Down)
     {
        return FormatTime(RemainingSeconds) ;
     }
     else
     {
        return FormatTime(GetObjOwner().Level.TimeSeconds - StartTime) ;
     }
}

defaultproperties
{
     Duration=60.000000
     HUD_Screen=(Screen_Hint="Time Left :",Screen_CountStyle=Count_Down,Screen_ProgressStyle=HDS_TextOnly)
}
