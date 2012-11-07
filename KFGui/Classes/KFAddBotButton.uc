class KFAddBotButton extends moButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local KFGameReplicationInfo KFGRI;

	Super.InitComponent(MyController, MyOwner);
	
	KFGRI = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo);
	
	if ( KFGRI == none || KFGRI.TempBotName=="" )
	{
		DisableMe();
	}
}
function bool InternalOnClick(GUIComponent Sender)
{
	local int PendingBots;
	local KFGameReplicationInfo  KFGRI;
	local String BotName;

	KFGRI = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo);

	if (KFGRI == none)
		return false;

	PendingBots = KFGRI.PendingBots;
	if (KFGRI.TempBotName != "")
		BotName = KFGRI.TempBotName;

	if(BotName != "")
	{
		if ((PlayerOwner().GameReplicationInfo.PRIArray.length  + PendingBots) < 6)
		{
			PendingBots ++;
			KFPlayerController(PlayerOwner()).ServerSetGRIPendingBots(PendingBots,BotName);
			PlayerOwner().ClientMessage("Bot "$KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).LastBotName[PendingBots]$" added to BotList");
			PlayerOwner().ClientMessage("Number of Bots to spawn: "$KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).PendingBots);
		}
		else Warn("No Valid KF Bot selected");
	}
}

defaultproperties
{
     ButtonCaption="Add Bot"
}
