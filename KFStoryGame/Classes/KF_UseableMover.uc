/*
	--------------------------------------------------------------
	KF_UseableMover
	--------------------------------------------------------------

    A Type of mover that is triggered by 'Use Objectives' in KF Story missions
    It interpolates while the player is holding the Use key and resets to
    its original position if the player lets go of the key.  (unless the Objective
    condition is set to keep use progress, in which case it will just freeze
    where it was at).

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_UseableMover extends Mover;

/* reference to the Use condition which controls this mover's interpolation */
var  ObjCondition_Use     ControllingCondition;

var  float                InitialMoveTime;

/* Interaction stubs -  Called by the Controlling Condition */
function Startedusing();
function StoppedUsing();


/* Called when a use condition 'possesses' this Mover */
function Notify_Controlled(ObjCondition_Use NewController)
{
    if(NewController != none)
    {
        ControllingCondition = NewController;
        InitialMoveTime = ControllingCondition.GetRemainingUseTime() ;
        MoveTime = InitialMoveTime;

        InitialState = 'UseControlled' ;
        Backup_InitialState = InitialState;
        GoToState('UseControlled');
    }
}

/* state the mover enters when it is being controlled by a player */
state UseControlled
{
    function StartedUsing()
    {
        InitialMoveTime = ControllingCondition.GetRemainingUseTime() ;
        MoveTime = InitialMoveTime;
        GoToState('UseControlled','Open');
    }

    function StoppedUsing()
    {
        if(ControllingCondition.bKeepUseProgress)
        {
            GoToState('UseControlled','Freeze');
        }
        else
        {
            InitialMoveTime = ControllingCondition.GetRemainingUseTime() * 0.1 ;
            MoveTime = InitialMoveTime;
            GoToState('UseControlled','Close');
        }
    }

Open:
	bClosed = false;
	DoOpen();
	FinishInterpolation();
	FinishedOpening();
	Stop;
Close:
	DoClose();
	FinishInterpolation();
	FinishedClosing();
	SetResetStatus( false );
Freeze:
	bInterpolating   = false;
    FinishInterpolation();
}

defaultproperties
{
}
