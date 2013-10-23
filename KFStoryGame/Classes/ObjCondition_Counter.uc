/*
	--------------------------------------------------------------
	Condition_Counter
	--------------------------------------------------------------

    A Condition which increments each time its owning Objective is
    triggered.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_Counter extends KF_ObjectiveCondition
editinlinenew;

enum ECounterType
{
	CT_Default,         	// default setting - NumToCount is user defined and NumCounted represents the number of times this objective has been triggered .
	CT_Cash,				// NumCounted becomes the total cash sum accrued by all players. NumToCount is whatever sum of cash you expect them to accumulate.
	CT_PlayerCount,        // NumCounted becomes the number of unique players who triggered this Objective.  NumToCount is the total number of active players in the match.
};


var	()	 ECounterType											CountType;

var ()	             int										NumToCount;

var                  int                                        NumCounted,SavedNumCounted;

/* if SuccessCondition is set to OBJ_Counter and CountType is CT_PlayerCount, this array will store unique player IDs for each
played who has been 'counted' so far. */
var											array<int>			CountedPlayerIDs;


function SaveState()
{
    Super.SaveState();
    SavedNumCounted = NumCounted;
}

function Reset()
{
    Super.Reset();
    NumCounted = SavedNumCounted;
    CountedPlayerIDs.length = 0;
}



/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
    local float Numerator;
    local float Denominator;

    switch(CountType)
    {
        case CT_Default 			:	break;
		case CT_Cash 				:	NumCounted = GetObjOwner().StoryGI.GetTotalCashSum();						break;
		case CT_PlayerCount		    :	NumToCount = Max(GetObjOwner().StoryGI.GetTotalActivePlayers(),1);	 	    break;
    }

    Numerator = float(NumCounted);
    // Take the floor of the modified amount to ensure accuracy. Also, there's no floor function available.
    Denominator = float(int(float(NumToCount) * GetTotalDifficultyModifier()));
    return FClamp(Numerator/Denominator,0.f,1.f) ;
}


function Trigger( actor Other, pawn EventInstigator)
{
    Super.Trigger(Other,EventInstigator);

	/* each trigger increments the 'counter' for objectives of that type */
	if(ConditionIsActive() && ValidForCounting(EventInstigator))
	{
        SetTargetActor(InstigatorName,EventInstigator);
		NumCounted = Min(NumCounted + 1,Round(NumToCount * GetTotalDifficultyModifier())) ;
	}
}

/* 	Relevant if this Objective is configured to count players -
	returns true if this is the first time the supplied pawn has triggered us
*/

function bool		ValidForCounting(Pawn	CountedPawn)
{
	local int i;

	if(CountType == CT_PlayerCount &&
    CountedPawn.PlayerReplicationInfo != none)
	{
		for( i = 0 ; i < CountedPlayerIDs.length ; i ++)
		{
			/* this guy has already been counted.  ignore him */
			if(CountedPlayerIDs[i] == CountedPawn.PlayerReplicationInfo.PlayerID)
			{
				return false;
			}
		}

		/* If we got this far CountedPawn is unique - add his ID to the array */
		CountedPlayerIDs[CountedPlayerIDs.length] = CountedPawn.PlayerReplicationInfo.PlayerID ;
	}

	return true;
}

function        string      GetDataString()
{
    if(HUD_Screen.Screen_CountStyle < 1)
    {
       return NumCounted$"/"$int(NumToCount * GetTotalDifficultyModifier()) ;
    }

    return string(Max((int(NumToCount * GetTotalDifficultyModifier()))-NumCounted,0)) ;
}

defaultproperties
{
     NumToCount=1
}
