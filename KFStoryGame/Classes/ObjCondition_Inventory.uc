/*
	--------------------------------------------------------------
	Condition_Inventory
	--------------------------------------------------------------

    A Condition which is marked complete when a player is carrying
    an inventory item of the specified class.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_Inventory extends KF_ObjectiveCondition
editinlinenew;

/* The type of inventory item to search for */
var() class<Inventory>      DesiredItemClass;

var bool                    bHeld;

var() name                  DesiredItemTag;


function Reset()
{
    Super.Reset();
    bHeld = false;
}


/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
    return float(bHeld && AllowCompletion());
}

function        ConditionTick(float DeltaTime)
{
    local Controller C;
    local Inventory Inv;

    Super.ConditionTick(DeltaTime);

    bHeld = false;

    for ( C=GetObjOwner().Level.ControllerList; C!=None; C=C.NextController )
	{
	    if(PlayerController(C) != none && C.Pawn != none)
	    {
            for( Inv = C.Pawn.Inventory; Inv != None ; Inv = Inv.Inventory )
            {
                if(ClassIsChildOf(Inv.class,DesiredItemClass) && (DesiredItemTag == '' ||
                Inv.tag == DesiredItemTag))
                {
                    bHeld = true;
                    SetTargetActor(InstigatorName,C.Pawn);
                    break;
                }
            }
	    }
	}
}

defaultproperties
{
     HUD_Screen=(Screen_ProgressStyle=HDS_TextOnly)
}
