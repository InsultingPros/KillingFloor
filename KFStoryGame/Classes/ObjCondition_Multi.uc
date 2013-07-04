/*
	--------------------------------------------------------------
	Condition_Multi
	--------------------------------------------------------------

    Multi Conditions are marked complete only when all 'child'
    conditions are also Complete

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class ObjCondition_Multi extends KF_ObjectiveCondition
editinlinenew;

var () array<KF_ObjectiveCondition>    ChildConditions;

var    array<byte>                     CompleteConditions;

var int NumCompleted,NumConditions;

function ConditionTick(float DeltaTime)
{
    local int i;
    local array<KF_ObjectiveCondition>    ValidConditions;

    NumConditions = 0;

    for(i = 0 ; i < ChildConditions.length ; i ++)
    {
        if(ChildConditions[i].ConditionIsRelevant())
        {
            ValidConditions[ValidConditions.length] = ChildConditions[i];
        }
    }

    NumConditions = ValidConditions.length;
    CompleteConditions.length = ValidConditions.length;

    for(i = 0 ; i < ValidConditions.length ; i ++)
    {
        if(ValidConditions[i].bComplete)
        {
            CompleteConditions[i] = 1 ;
        }
        else
        {
            CompleteConditions[i] = 0;
        }
    }

    NumCompleted  = 0;
    for(i = 0 ; i < NumConditions ; i ++)
    {
        if(CompleteConditions[i] == 1)
        {
            NumCompleted ++ ;
        }
    }

    Super.ConditionTick(DeltaTime);
}

/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
    return float(NumCompleted) / float(NumConditions) ;
}

function        string      GetDataString()
{
    if(HUD_Screen.Screen_CountStyle < 1)
    {
       return NumCompleted$"/"$NumConditions ;
    }

    return string(Max(NumConditions-NumCompleted,0)) ;
}

defaultproperties
{
}
