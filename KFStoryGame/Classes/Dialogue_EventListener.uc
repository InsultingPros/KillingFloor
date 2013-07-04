/*
	--------------------------------------------------------------
	Dialogue_EventListener
	--------------------------------------------------------------

	Simple event listener actor spawned by KF_DialogueSpots.
	Notifies the dialogue spot that it can continue the dialogue chain

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Dialogue_EventListener extends Actor;

var		KF_DialogueSpot			DlgOwner;

var		int						AssociatedIndex;

function PostBeginPlay()
{
	DlgOwner = KF_DialogueSpot(Owner);
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(DlgOwner != none )
	{
		if(DlgOwner.bDebugDialogue)
		{
			log("----- DIALOGUE DEBUG ------  DialogueListener was triggered for Index "@AssociatedIndex@"Received event : "@DlgOwner.Dialogues[AssociatedIndex].Events.RequiredEvent@",triggered by : "@Other@" .. Proceeding ", 'Story_Debug');
		}

		if(!DlgOwner.Dialogues[AssociatedIndex].bWasTriggered )
		{
            if(DlgOwner.bFinished)
            {
                DlgOwner.bFinished = false;
            }

			DlgOwner.Dialogues[AssociatedIndex].bWasTriggered  = true ;
			DlgOwner.CurrentMsgIdx = AssociatedIndex;
            DlgOwner.TraverseDialogue();
		}
	}
}

function Timer()
{
    if(DlgOwner != none)
    {
        DlgOwner.OnDialogueDisplayComplete(AssociatedIndex);
    }
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
