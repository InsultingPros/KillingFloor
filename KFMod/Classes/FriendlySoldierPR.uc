class FriendlySoldierPR extends TeamPlayerReplicationInfo;

event PostBeginPlay()
{
    if ( Role < ROLE_Authority )
        return;
    if (AIController(Owner) != None)
        bBot = true;
    StartTime = Level.Game.GameReplicationInfo.ElapsedTime;
    Timer();
    SetTimer(1.5 + FRand(), true);

}

simulated event PostNetBeginPlay(){}

defaultproperties
{
     bNoTeam=True
}
