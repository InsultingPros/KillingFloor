/*
	--------------------------------------------------------------
	ACTION_ChangeViewTarget
	--------------------------------------------------------------

    Scripted Action used to switch players viewtarget to a specific actor.
    Used in story mode for the Patriarch 'Grand Entrance' sequence.

	Author :  Alex Quick

	--------------------------------------------------------------
*/
class ACTION_ChangeViewTarget extends ScriptedAction;

var() name ViewActorTag;
var   Actor ViewActor;
var   bool bViewingActor;


/* Initialises this action ** NOTE :   returning TRUE out of this function will pause
all subsequent actions.  you must return false if you want the scripted actions to proceed*/

function bool InitActionFor(ScriptedController C)
{
    local Controller CC;
    local PlayerController PC;

    if(ViewActorTag != '')
    {
        foreach AllObjects(class 'Actor', ViewActor)
        {
            if(ViewActor.Tag == ViewActorTag)
            {
                break;
            }
        }
    }

    bViewingActor = ViewActor != none  ;
    for ( CC = C.Level.ControllerList; CC != None; CC = CC.NextController )
	{
        PC = PlayerController(CC);
        if( PC !=None )
        {
            if(ViewActorTag != '')
		    {
                log("! Change View Target to : "@ViewActor,'Story_Debug');
                ViewActor.bAlwaysRelevant = True;
	            PC.SetViewTarget(ViewActor);
				PC.ClientSetViewTarget(ViewActor);
				PC.bBehindView = True;
				PC.ClientSetBehindView(True);

				if(KFMonster(ViewActor) != none)
				{
				    KFMonster(ViewActor).MakeGrandEntry();
				}
			}
			else
			{
                log("! Change View Target to : "@PC.Pawn,'Story_Debug');
				if( PC.Pawn!=None )
				{
					PC.SetViewTarget(PC.Pawn);
					PC.ClientSetViewTarget(PC.Pawn);
				}
				else
				{
			   	    PC.SetViewTarget(PC);
					PC.ClientSetViewTarget(PC);
				}

				PC.bBehindView = False;
				PC.ClientSetBehindView(False);
            }
        }
    }

    return false;
}

defaultproperties
{
}
