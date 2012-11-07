class KFAccessControl extends AccessControl;


function bool IsLateJoiner(PlayerController C)
{

    if( C!= none && C.Player !=none && (Level.NetMode != NM_Standalone)&&
     !C.PlayerReplicationInfo.bAdmin &&
     KFGameType(Level.Game).bNoLateJoiners &&
     Level.Game.GameReplicationInfo.bMatchHasBegun )
    {
        // TODO implement a way for admins to specify the reason
        C.ClientNetworkMessage("FC_NoLateJoiners",DefaultKickReason);
        if (C.Pawn != None)
            C.Pawn.Destroy();
        if (C != None)
            C.Destroy();
        return true;
    }
    return false;
}

defaultproperties
{
}
