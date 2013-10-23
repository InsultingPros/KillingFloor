/*
	--------------------------------------------------------------
	KF_DialogueSpot
	--------------------------------------------------------------

    Displays dialogue on the screen with a header and image.
    Optionally plays voicover audio.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KF_DialogueSpot	extends Info
dependson(KFStoryGameInfo)
placeable;

var				int                                             CurrentMsgIdx;

var				Controller                                      DialogueInstigator;

var()			array<KFStoryGameInfo.SDialogueEntry>           Dialogues;

/* true if this dialogue spot should display its text when a player touches the dialogue actor's collision cylinder */
var			    bool						                    bTouchTriggered;


/* true if this dialogue can be 'skipped'  by moving out of range of the speaker*/
var			    bool						                    bCanSkipDlg;

/* the range at which dialogue will be skipped if bCanSkipDlg*/
var 			float						                    SkipDlgRange;

/* if true, the dialogue will play randomly each time it is triggered rather than in order */
var()			bool						                    bRandomize;

// if true, this dialogue can be played multiple times.  If not, only allow one play of each dialogue
var()           bool                                            bAllowRepeatDialogue;

var				bool						                    bDebugDialogue;

var				bool						                    bTraversing;

var				bool						                    bFinished;

var             bool                                            bSingleTouchOnly;

var             bool                                            bTouched;


function Reset()
{
	local int i, SavedIdx;
	local array<byte>	SavedTriggerStates;

	Super.Reset();

	/* Partial reset using saved positions*/

	bTraversing = false;

	if(!bFinished)
	{
		SavedIdx = KFStoryGameInfo(Level.Game).CurrentCheckPoint.GetSavedDialogueIndexFor(self,SavedTriggerStates) ;
		CurrentMsgIdx =  SavedIdx;

		if(bDebugDialogue)
		{
			log("----- DIALOGUE DEBUG ------   Resetting "@self@". Dialogue will play back from Index : "@SavedIdx, 'Story_Debug');
		}

		for(i = 0 ; i < Dialogues.length ; i ++)
		{
			Dialogues[i].bWasTriggered = bool(SavedTriggerStates[i]);
		}
	}
	else	/* Full reset from the start. */
	{
 		for(i = 0 ; i < Dialogues.length ; i ++)
		{
			Dialogues[i].bWasTriggered = false;
		}

		CurrentMsgIdx = 0;
		bFinished = false;
	}
}

function Destroyed()
{
	local int i;

	/* Perform cleanup on any event listeners */
	for(i = 0 ; i < Dialogues.length ; i ++)
	{
		if(Dialogues[i].EventListener != none)
		{
			Dialogues[i].EventListener.Destroy();
		}
	}
}

/* Dialogue callback - timing is handled in the event listener */
function OnDialogueDisplayComplete(int Index)
{
//    log("Dialogue - Triggering Displayed Event : "@Dialogues[Index].Events.DisplayedEvent);
    if(Dialogues[Index].Events.DisplayedEvent != '')
    {
	   TriggerEvent(Dialogues[Index].Events.DisplayedEvent,self,DialogueInstigator.Pawn);
    }

    Dialogues[Index].bWasTriggered = false;
}

function PostBeginPlay()
{
	local int i;
	local Dialogue_EventListener		NewListener;

    /* No KFO Gametype, no Initialization */
	if(KFStoryGameinfo(Level.Game) == none)
	{
        return;
	}

	// Spawn Event listeners for Dialogue entries which require them.
	for(i = 0 ; i < Dialogues.length ; i ++)
	{
		NewListener = Spawn(class 'Dialogue_EventListener',self,Dialogues[i].Events.RequiredEvent);
		NewListener.AssociatedIndex = i ;
		Dialogues[i].EventListener = NewListener;
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(EventInstigator != none &&
	EventInstigator.Controller != none)
	{
		DialogueInstigator = EventInstigator.Controller;
	}

	TraverseDialogue();
}

function bool SelfTriggered()
{
	return bTouchTriggered;
}

function Touch( Actor Other )
{
	if ( Pawn(Other) != None &&
    PlayerController(Pawn(Other).Controller) != none &&
     SelfTriggered() &&
     (!bSingleTouchOnly || !bTouched))
	{
		bTouched = true;
		Trigger(self,Pawn(Other));
	}
}

function 	int		GetIndexFor(KFstoryGameInfo.SDialogueEntry  TestDlg)
{
	local int i;

	for(i = 0 ; i < Dialogues.length ; i ++)
	{
		if(Dialogues[i] == TestDlg)
		{
			return i;
		}
	}

	return - 1 ;
}


/* 	Retrieves the index of the next dialogue entry in a DialogueSpot actor with a 'required event'.
	Necessary in cases where the game is restarting from an objective in a non-linear fashion and
	certain intermediate dialogue needs to be skipped
*/

function		int			GetNextDlgRequiredEventIdx(int 	TestIndex)
{
	local int i;

	for( i = TestIndex + 1 ; i < Dialogues.length ; i ++)
	{
		if(Dialogues[i].Events.RequiredEvent != '')
		{
			return i ;
		}
	}

	return -1;
}


function TraverseDialogue()
{
	local bool bWaitingForEvent ;

	/* Hit the end. early out */
	if( Dialogues.length <= CurrentMsgIdx  || bTraversing || (bFinished && !bAllowRepeatDialogue))
	{
		return;
	}

	if(bRandomize)
	{
		CurrentMsgIdx = RandRange(0,Dialogues.length) ;
	}

	/* If the next index after this one is event-triggered,  don't set the timer */
	if(Dialogues[CurrentMsgIdx].Events.RequiredEvent != '' &&
	!Dialogues[CurrentMsgIdx].bLooping)
	{
		bWaitingForEvent = !Dialogues[CurrentMsgIdx].bWasTriggered;
	}

	if(!bWaitingForEvent)
	{
		if(bDebugDialogue)
		{
			log("----- DIALOGUE DEBUG ------  Showing Dialogue at index .. "@CurrentMsgIdx, 'Story_Debug');
		}

		ShowDialogue(CurrentMsgIdx);
		if(CurrentMsgIdx + 1 < Dialogues.length )
		{
			bTraversing = true;

			if(GetCurrentDisplayDur() > 0)
			{
                SetTimer(GetCurrentDisplayDur(),false);
            }
            else
            {
                Timer();
            }
        }
		else
		{
			/* we're finished. Reset the actor */
			OnDialogueCompleted();
		}
	}
	else
	{
		if(bDebugDialogue)
		{
			log("----- DIALOGUE DEBUG ------  Freezing dialogue at index :"@CurrentMsgIdx@"for event : "@Dialogues[CurrentMsgIdx].Events.RequiredEvent, 'Story_Debug');
		}
	}
}

function OnDialogueCompleted()
{
	bFinished = true;
}

function Timer()
{
	if(bTraversing)
	{
		bTraversing = false;

		if(CurrentMsgIdx + 1 < Dialogues.length && !bRandomize)
		{
			if(!Dialogues[CurrentMsgIdx].bLooping)
			{
				CurrentMsgIdx ++ ;
				if(bDebugDialogue)
				{
					log("----- DIALOGUE DEBUG ------  Incrementing Dialogue Index .. ", 'Story_Debug');
				}

				TraverseDialogue();
			}
		}
	}
}

/* Helper function - calculates the amount of time a string should
be displayed for based on its word length  */

function float CalcDisplayTime(string InString)
{
    local float TimePerWord;
    local array<string> Words;

    TimePerWord = 0.5f;
    Split(InString," ",Words);

    return FMax(Words.length * TimePerWord,3.f);
}

function ShowDialogue(int DlgIndex)
{
	local Controller C;
	local KFPlayerController_Story 	StoryPC;
	local string SpeakerName;
	local actor VoiceOverSource;
	local Material Portrait;
    local Pawn MyInstigator;

	/* nothing to show, nothing to play ... early out */
	if(Dialogues[DlgIndex].Display.Dialogue_Text == "" &&
	Dialogues[DlgIndex].VoiceOver.VoiceOverSound == none)
	{
		return;
	}

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		StoryPC = KFPlayerController_Story(C);
		if(StoryPC != none &&
		(Dialogues[DlgIndex].BroadcastScope != InstigatorOnly ||
        (DialogueInstigator != none && DialogueInstigator == C) ))
		{
			SpeakerName  = Dialogues[DlgIndex].Display.Dialogue_Header ;
			Portrait     = Dialogues[DlgIndex].Display.Portrait_Material ;

			if(SpeakerName == "self")
			{
				SpeakerName = StoryPC.PlayerReplicationinfo.PlayerName ;
				Portrait    = xPlayerReplicationInfo(StoryPC.PlayerReplicationInfo).Rec.Portrait;
			}

            if(GetCurrentDisplayDur() > 0)
            {
                Dialogues[DlgIndex].EventListener.SetTimer(GetCurrentDisplayDur(),false);
            }
            else
            {
                OnDialogueDisplayComplete(DlgIndex);
            }

            if(!SkipDialogue())
            {
                StoryPC.ClientShowStoryDialogue(name ,DlgIndex,GetCurrentDisplayDur());
            }

			if ( !SkipDialogue() && Dialogues[DlgIndex].VoiceOver.VoiceOverSound != None )
			{
				/* attempt to play a spatialised sound from the source actor (if there is one) */
			    VoiceOverSource = Dialogues[DlgIndex].VoiceOver.SourceActor ;
				if(VoiceOverSource != none)
				{
					VoiceOverSource.PlaySound(Dialogues[DlgIndex].VoiceOver.VoiceOverSound,SLOT_Talk,VoiceOverSource.SoundVolume,,VoiceOverSource.SoundRadius,VoiceOverSource.SoundPitch,VoiceOverSource.bFullVolume);
				}
				else	/*otherwise just play a ClientSound */
				{
					StoryPC.ClientPlayStorySound(Dialogues[DlgIndex].VoiceOver.VoiceOverSound, 2.0, false );
				}
			}

            if(Dialogues[DlgIndex].Events.DisplayingEvent != '')
            {
                MyInstigator = DialogueInstigator.Pawn;
                TriggerEvent(Dialogues[DlgIndex].Events.DisplayingEvent,self,MyInstigator);
            }
        }
	}
}

function bool SkipDialogue()
{
    return KFStoryGameInfo(Level.Game) != none && KFStoryGameInfo(Level.Game).bSkipDialogue;
}

function float GetCurrentDisplayDur()
{
    local float Duration,VODuration;

    if( SkipDialogue())
    {
        return 0.f;
    }

    Duration = CalcDisplayTime(Dialogues[CurrentMsgIdx].Display.Dialogue_Text);

    /* Always make sure the text sticks around for at least as long as the VO */
    if(Dialogues[CurrentMsgIdx].VoiceOver.VoiceOverSound != none)
    {
        VODuration = Dialogues[CurrentMsgIdx].VoiceOver.VoiceOverSound.Duration;
        Duration   = VODuration * 1.15; // Gamespeed is 1.1 so you always have to multiplay sound durations by 1.1. Adding a bit more buffer just in case - Ramm
    }

    return Duration;
}

function GetRequiredEvents( out array<Name> AllRequiredEvents)
{
    local int i;

    for(i = 0 ; i < Dialogues.length ; i ++)
    {
        if(Dialogues[i].Events.RequiredEvent != '')
        {
            AllRequiredEvents[AllRequiredEvents.length] = Dialogues[i].Events.RequiredEvent;
        }
    }
}



function GetDisplayEvents( out array<Name> AllDisplayEvents)
{
    local int i;

    for(i = 0 ; i < Dialogues.length ; i ++)
    {
        if(Dialogues[i].Events.DisplayedEvent != '')
        {
            AllDisplayEvents[AllDisplayEvents.length] = Dialogues[i].Events.DisplayedEvent;
        }

        if(Dialogues[i].Events.DisplayingEvent != '')
        {
            AllDisplayEvents[AllDisplayEvents.length] = Dialogues[i].Events.DisplayingEvent;
        }
    }
}

function GetEvents(out array<name> TriggeredEvents,  out array<name>  ReceivedEvents)
{
    local int i;

    Super.GetEvents(TriggeredEvents,ReceivedEvents);

    for(i = 0 ; i < Dialogues.length ; i ++)
    {
        /* Things I trigger */
        if(Dialogues[i].Events.DisplayedEvent != '')
        {
            TriggeredEvents[TriggeredEvents.length] = Dialogues[i].Events.DisplayedEvent;
        }
        if(Dialogues[i].Events.DisplayingEvent != '')
        {
            TriggeredEvents[TriggeredEvents.length] = Dialogues[i].Events.DisplayingEvent;
        }
        /* Things that trigger me*/
        if(Dialogues[i].Events.RequiredEvent != '')
        {
            ReceivedEvents[ReceivedEvents.length] = Dialogues[i].Events.RequiredEvent;
        }
    }
}

defaultproperties
{
     SkipDlgRange=250.000000
     bDebugDialogue=True
     bNoDelete=True
     Texture=Texture'KFStoryGame_Tex.Editor.KF_Dlgspot_Ico'
     DrawScale=0.500000
     bCollideActors=True
}
