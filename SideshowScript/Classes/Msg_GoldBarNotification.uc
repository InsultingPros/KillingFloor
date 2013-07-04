/*
	--------------------------------------------------------------
	Msg_GoldBarNotification
	--------------------------------------------------------------

    Local Message class for Gold bar objective notifications.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Msg_GoldBarNotification extends WaitingMessage;

var localized string GoldWasPickedUpString;
var localized string GoldWasDroppedString;
var localized string GoldWasRecoveredString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :    // Someone picked up the gold.

        return RelatedPRI_1.PlayerName@default.GoldWasPickedUpString ;

        case 2 :   // Someone dropped the gold.

        return RelatedPRI_1.PlayerName@default.GoldWasDroppedString ;

        case 3 :    // Someone Recovered the gold.

        return RelatedPRI_1.PlayerName@default.GoldWasRecoveredString;
    }
}


static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	OutDrawPivot = default.DrawPivot;
	OutStackMode = default.StackMode;
	OutPosX = default.PosX;
	OutPosY = 0.7;
}

static function float GetLifeTime(int Switch)
{
    return default.LifeTime;
}

static function int GetFontSize(int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer)
{
    return 2;
}

defaultproperties
{
     GoldWasPickedUpString="picked up a piece of gold"
     GoldWasDroppedString="dropped a piece of gold"
     GoldWasRecoveredString="secured a piece of gold"
     Lifetime=4
     DrawColor=(B=75,G=240)
}
