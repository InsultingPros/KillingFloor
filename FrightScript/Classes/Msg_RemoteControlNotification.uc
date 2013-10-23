/*
	--------------------------------------------------------------
	Msg_RemoteControlNotification
	--------------------------------------------------------------

    Local Message class for Remote Control / Container Crate objective notifications.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Msg_RemoteControlNotification extends WaitingMessage;

var localized string RemoteWasPickedUpString;
var localized string RemoteWasDroppedString;
var localized string RemoteWasPlacedString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :    // Someone picked up the remote control piece.

        return RelatedPRI_1.PlayerName@default.RemoteWasPickedUpString ;

        case 2 :   // Someone dropped the remote control piece.

        return RelatedPRI_1.PlayerName@default.RemoteWasDroppedString ;

        case 3 :    // Someone placed the remote control piece.

        return RelatedPRI_1.PlayerName@default.RemoteWasPlacedString;
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
     RemoteWasPickedUpString="picked up a piece of the remote control!"
     RemoteWasDroppedString="dropped a piece of the remote control!"
     RemoteWasPlacedString="placed a piece of the remote control"
     Lifetime=4
     DrawColor=(B=50,G=50)
}
