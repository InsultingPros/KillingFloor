class BloatKillVolume extends PhysicsVolume;

var() const name NotABloatEvent;

var bool    bShouldTriggerEvents;

simulated event PawnEnteredVolume(Pawn Other)
{
	if ( Role == ROLE_Authority && Other.Health > 0)
    {
        if(bShouldTriggerEvents)
        {
            if(Other.IsA('ZombieBloat'))
            {
                TriggerEvent(Event,self, Other);
            }
            else
            {
                TriggerEvent(NotABloatEvent,self,Other);
            }
        }

        Other.Died(Other.Controller,DamageType,Other.Location);
    }
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    bShouldTriggerEvents = !bShouldTriggerEvents;
}

defaultproperties
{
     bShouldTriggerEvents=True
     bStatic=False
}
