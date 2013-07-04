/*
	--------------------------------------------------------------
	ACTION_TriggerRandomEvents
	--------------------------------------------------------------

	Functions like 'ACTION_TriggerEvent' except that it supports
	multiple different events being fired off at once. It will pick
	up to 'NumToTrigger' events from the 'PossibleEvents' array
	in order to do this.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ACTION_TriggerRandomEvents extends ScriptedAction;

var(Action) array<name> PossibleEvents;

var(Action) int         NumToTrigger;

function bool InitActionFor(ScriptedController C)
{
    local array<name> EventList,PendingEvents;
    local int RandIdx;
    local int i;

    EventList = PossibleEvents;

    /* Always check that we're not trying to trigger more events than are in the array */
    NumToTrigger = Min(NumToTrigger,EventList.length);

    for(i = 0 ; i < NumToTrigger; i ++)
    {
        RandIdx = RandRange(0,EventList.length-1);
        PendingEvents.length = PendingEvents.length + 1;
        PendingEvents[PendingEvents.length - 1] = EventList[RandIdx];

        /* remove it from the list so it can't be used twice */
        EventList.Remove(RandIdx,1);
    }

    for(i = 0 ; i < PendingEvents.length ; i ++)
    {
    	C.TriggerEvent(PendingEvents[i],C.SequenceScript,C.GetInstigator());
    }

	return false;
}

function GetActionEvents(out array<name> TriggeredEvents,  out array<name>  ReceivedEvents)
{
    local int i;

    for( i = 0 ; i < PossibleEvents.length ; i ++)
    {
        if(PossibleEvents[i] != '')
        {
            TriggeredEvents[TriggeredEvents.length] = PossibleEvents[i];
        }
    }
}

defaultproperties
{
}
