// VoiceOver actor for Killing FLoor SinglePlay

class KFVoiceOver extends Trigger;

var () Sound VoiceOverSound;

function Touch( actor Other )
{
    local int i;

    if( IsRelevant( Other ) )
    {
        Other = FindInstigator( Other );

        if ( ReTriggerDelay > 0 )
        {
            if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
                return;
            TriggerTime = Level.TimeSeconds;
        }
        // Broadcast the Trigger message to all matching actors.
        TriggerEvent(Event, self, Other.Instigator);

        if ( (Pawn(Other) != None) && (Pawn(Other).Controller != None) )
        {

           // Play Voice over from Touching Pawn

           PlayOwnedSound(VoiceOverSound, SLOT_Talk,TransientSoundVolume,,TransientSoundRadius,,false);

            for ( i=0;i<4;i++ )
                if ( Pawn(Other).Controller.GoalList[i] == self )
                {
                    Pawn(Other).Controller.GoalList[i] = None;
                    break;
                }
        }

        if( (Message != "") && (Other.Instigator != None) )
            // Send a string message to the toucher.

            Other.Instigator.ClientMessage( Message );

        if( bTriggerOnceOnly )
            // Ignore future touches.
            SetCollision(False);
        else if ( RepeatTriggerTime > 0 )
            SetTimer(RepeatTriggerTime, false);
    }
}



function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType, optional int HitIndex)
{
    if ( bInitiallyActive && (TriggerType == TT_Shoot) && (Damage >= DamageThreshold) && (instigatedBy != None) )
    {
        if ( ReTriggerDelay > 0 )
        {
            if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
                return;
            TriggerTime = Level.TimeSeconds;
        }
        // Broadcast the Trigger message to all matching actors.
        TriggerEvent(Event, self, instigatedBy);

        if( Message != "" )
            // Send a string message to the toucher.
            instigatedBy.Instigator.ClientMessage( Message );

         // Play Voice over from Touching Pawn

           PlayOwnedSound(VoiceOverSound, SLOT_Talk,TransientSoundVolume,,TransientSoundRadius,,false);


        if( bTriggerOnceOnly )
            // Ignore future touches.
            SetCollision(False);

        if ( (AIController(instigatedBy.Controller) != None) && (instigatedBy.Controller.Target == self) )
            instigatedBy.Controller.StopFiring();
    }
}

defaultproperties
{
     bFullVolume=True
     SoundVolume=255
     SoundRadius=2000.000000
     TransientSoundVolume=255.000000
     TransientSoundRadius=2000.000000
}
