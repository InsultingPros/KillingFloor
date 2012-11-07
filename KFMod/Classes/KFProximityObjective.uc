class KFProximityObjective extends ProximityObjective;

function bool IsRelevant( Pawn P, bool bAliveCheck )
{
	return true;
}

function DisableObjective(Pawn Instigator)
{
    local PlayerReplicationInfo PRI;

    if ( !IsActive() )
        return;

    NetUpdateTime = Level.TimeSeconds - 1;

    if ( bClearInstigator )
    {
        Instigator = None;
    }
    else
    {
        if ( Instigator != None )
        {
            if ( Instigator.PlayerReplicationInfo != None )
                PRI = Instigator.PlayerReplicationInfo;
            else if ( Instigator.Controller != None && Instigator.Controller.PlayerReplicationInfo != None )
                PRI = Instigator.Controller.PlayerReplicationInfo;
        }

        if ( DelayedDamageInstigatorController != None )
        {
            if ( Instigator == None )
                Instigator = DelayedDamageInstigatorController.Pawn;

            if ( PRI == None && DelayedDamageInstigatorController.PlayerReplicationInfo != None )
                PRI = DelayedDamageInstigatorController.PlayerReplicationInfo;
        }

        if ( !bBotOnlyObjective && DestructionMessage != "" )
            PlayDestructionMessage();
    }


        bDisabled   = true;
        SetActive( false );

    SetCriticalStatus( false );
    DisabledBy  = PRI;

    if ( MyBaseVolume != None && MyBaseVolume.IsA('ASCriticalObjectiveVolume') )
        MyBaseVolume.GotoState('ObjectiveDisabled');

    if ( bAccruePoints )
        Level.Game.ScoreObjective( PRI, 0 );
    else
        Level.Game.ScoreObjective( PRI, Score );

    if ( !bBotOnlyObjective )
        UnrealMPGameInfo(Level.Game).ObjectiveDisabled( Self );

    TriggerEvent(Event, self, Instigator);

    UnrealMPGameInfo(Level.Game).FindNewObjectives( Self );
}

defaultproperties
{
}
