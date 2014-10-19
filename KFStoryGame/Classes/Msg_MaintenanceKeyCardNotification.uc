/*
	--------------------------------------------------------------
	Msg_MaintenanceKeyCardNotification
	--------------------------------------------------------------

    Local Message class for the Subway Maintenance keycard

	--------------------------------------------------------------
*/

class Msg_MaintenanceKeyCardNotification extends WaitingMessage;

var localized string KeyCardPickedUpString;
var localized string KeyCardDroppedString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :    // Someone picked up the keycard.

        return RelatedPRI_1.PlayerName@default.KeyCardPickedUpString ;

        case 2 :   // Someone dropped the keycard.

        return RelatedPRI_1.PlayerName@default.KeyCardDroppedString ;
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
     KeyCardPickedUpString="picked up the Maintenance Keycard"
     KeyCardDroppedString="dropped the Maintenance KeyCard"
     Lifetime=4
     DrawColor=(B=25,G=25)
}
