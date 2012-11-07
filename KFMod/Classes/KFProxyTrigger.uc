class KFProxyTrigger extends Trigger; 

// Instead of activating / deactivation.  When the trigger is toggled by another trigger,
// it will call this trigger's event.

state() OtherTriggerToggles
{
    function Trigger( actor Other, pawn EventInstigator )
    {
        //log("i was triggered!");
        TriggerEvent(Event, self, EventInstigator);
    }
}

defaultproperties
{
}
