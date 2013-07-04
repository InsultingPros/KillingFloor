class LobbyFooter_Story extends LobbyFooter;

/* Set ready up on the server for late joining players */
function bool OnFooterClick(GUIComponent Sender)
{
	local PlayerController PC;
    /*
    if(Sender == b_Ready)
    {
    	PC = PlayerOwner();
		if ( PC.PlayerReplicationInfo.Team != none &&
        !PC.PlayerReplicationInfo.bReadyToPlay)
		{
            if(KFPlayerController_Story(PC) != none)
            {
                KFPlayerController_Story(PC).ServerReadyLateJoiner();
            }
		}
    }
    */
    return Super.OnFooterClick(Sender);
}

defaultproperties
{
}
