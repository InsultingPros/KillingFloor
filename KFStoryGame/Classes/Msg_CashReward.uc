class Msg_CashReward extends LocalMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    if(Switch > 0)
    {
        return "+ £"@Switch ;
    }
    else
    {
        return "- £"@Switch ;
    }
}

defaultproperties
{
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=100,R=100)
     StackMode=SM_Up
     PosX=0.920000
     PosY=0.820000
     FontSize=2
}
