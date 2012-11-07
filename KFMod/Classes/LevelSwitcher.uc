// Custom Trigger to switch maps , in Killing Floor Single Play

class LevelSwitcher extends Trigger;

var() name NextMapName;

function Touch( actor Other )
{
    if( IsRelevant( Other ) )
    {
        Other = FindInstigator( Other );

        if ( ReTriggerDelay > 0 )
        {
            if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
                return;
            TriggerTime = Level.TimeSeconds;
        }

        TriggerEvent(Event, self, Other.Instigator);

        // Switch to new map

        if ( (Pawn(Other) != None) && (Pawn(Other).Controller != None) )
        {
            Pawn(Other).Controller.ConsoleCommand("OPEN KFS-04");





        }

    }
}

defaultproperties
{
}
