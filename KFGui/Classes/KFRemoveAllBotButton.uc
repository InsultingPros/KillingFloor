class KFRemoveAllBotButton extends moButton;



function bool InternalOnClick(GUIComponent Sender)
{
    local int PendingBots;
    local KFGameReplicationInfo  KFGRI;
    local String BotName;

    KFGRI = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo);

   if (KFGRI == none)
    return false;


    PendingBots = KFGRI.PendingBots;

   if (PendingBots > 0)
   {
    PlayerOwner().ClientMessage("Number of Bots removed: "$KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).PendingBots );
    KFPlayerController(PlayerOwner()).GRIKillBotCall(PendingBots);
    PendingBots = 0;
   }

    BotName = "";
    
    KFPlayerController(PlayerOwner()).ServerSetGRIPendingBots(PendingBots,BotName);



     //PlayerOwner().ClientMessage("Bot removed from BotList");




}

defaultproperties
{
     ButtonCaption="Clear Bots"
}
