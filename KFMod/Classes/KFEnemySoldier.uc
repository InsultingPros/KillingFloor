class KFEnemySoldier extends Bot;
 
 simulated function int GetTeamNum()
{
    if ( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) )
        return 0;

    return PlayerReplicationInfo.Team.TeamIndex;
}

defaultproperties
{
     Aggressiveness=-1.000000
     BaseAlertness=1.000000
     Accuracy=0.500000
     CombatStyle=-1.000000
     ReactionTime=1.000000
     FovAngle=360.000000
     bAdrenalineEnabled=False
     PawnClass=Class'KFMod.KFHumanPawnEnemy'
}
