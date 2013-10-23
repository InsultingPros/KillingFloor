/*
	--------------------------------------------------------------
	Msg_RemoteControlNotification
	--------------------------------------------------------------

    Local Message class for Remote Control / Container Crate objective notifications.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Msg_GasCanNotification extends WaitingMessage;

var localized string GasWasPickedUpString;
var localized string GasWasDroppedString;
var localized string GasWasPlacedString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :    // Someone picked up the gas.

        return RelatedPRI_1.PlayerName@default.GasWasPickedUpString ;

        case 2 :   // Someone dropped the gas.

        return RelatedPRI_1.PlayerName@default.GasWasDroppedString ;

        case 3 :    // Someone placed the gas in the boat.

        return RelatedPRI_1.PlayerName@default.GasWasPlacedString;
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
     GasWasPickedUpString="picked up a can of gas!"
     GasWasDroppedString="dropped a can of gas!"
     GasWasPlacedString="fueled up a boat"
     Lifetime=4
     DrawColor=(B=50,G=50)
}
