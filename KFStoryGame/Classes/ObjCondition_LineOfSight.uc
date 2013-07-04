/*
	--------------------------------------------------------------
	Condition_LineOfSight
	--------------------------------------------------------------

    A Condition which is marked complete when a living human player
    looks at / has an unobstructed line of sight to it.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_LineOfSight extends KF_ObjectiveCondition
editinlinenew;

var	()	float		MinDotProduct;
var	()	float		MinDistance;
var ()	bool		bPerformLineCheck;

var     bool        bHasLOS;

function Reset()
{
    Super.Reset();
    bHasLOS = false;
}

function ConditionTick(float DeltaTime)
{
    local Controller C;
    local float Dist;

	for ( C=GetObjOwner().Level.ControllerList; C!=None; C=C.NextController )
	{
	    if(KFPlayerController_Story(C) != none && C.Pawn != none)
	    {
			if(KFPlayerController_Story(C).IsLookingAtLocation(GetLocation(),MinDotProduct) && C.Pawn != none)
			{
				Dist = VSize(C.Pawn.Location - GetLocation());
				if( Dist <= MinDistance)
				{
					bHasLOS = (!bPerformLineCheck || GetObjOwner().FastTrace(PlayerController(C).CalcViewLocation, GetLocation()));	//EyePostion() is returning a funny value sometimes.  Not sure why. C.Pawn./*EyePosition()*/Location
				    if(bHasLOS)
				    {
                        Instigator = C.Pawn;
                        break;
				    }
                }
			}
		}
	}

    Super.ConditionTick(DeltaTime);
}


/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
	return float(bHasLOS) ;
}

defaultproperties
{
     MinDistance=1000.000000
     bPerformLineCheck=True
}
