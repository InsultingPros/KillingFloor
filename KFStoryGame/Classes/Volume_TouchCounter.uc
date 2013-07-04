/*
	--------------------------------------------------------------
	Volume_PawnCounter
	--------------------------------------------------------------

    A Volume that Adds up the number of unique Pawns that touch it.
    When it hits the desired amount it resets.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Volume_TouchCounter extends Volume;

var() int           DesiredNumTouches;

var() bool          DestroyTouchers;

var(Events) name    TouchCompleteEvent;

var array<Actor> TouchList;

simulated event touch(Actor Other)
{
    local int i;
    local bool bExists;

    Super.Touch(Other);

    for(i = 0 ; i < TouchList.length ; i ++)
    {
        if(TouchList[i] == Other)
        {
            bExists = true;
            break;
        }
    }

    if(!bExists)
    {
        TouchList[TouchList.length] = Other;
        TriggerEvent(Event,self,Pawn(other));
    }

    if(DesiredNumTouches > 0 &&
    TouchList.length >= DesiredNumTouches)
    {
        TriggerEvent(TouchCompleteEvent,self,Pawn(Other));
        TouchList.length = 0;
    }

    if(DestroyTouchers && Pawn(Other) != none)
    {
        Pawn(Other).KilledBy(Pawn(Other)) ;
    }
}

defaultproperties
{
     bStatic=False
}
