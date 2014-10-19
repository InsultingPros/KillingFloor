/*
	--------------------------------------------------------------
	Msg_ThermiteNotification
	--------------------------------------------------------------

    Local Message class for the Thermite pickup

	--------------------------------------------------------------
*/

class Msg_ThermiteNotification extends WaitingMessage;

var localized string ThermitePickedUpString;
var localized string ThermiteDroppedString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :    // Someone picked up the Thermite

        return RelatedPRI_1.PlayerName@default.ThermitePickedUpString ;

        case 2 :   // Someone dropped the Thermite

        return RelatedPRI_1.PlayerName@default.ThermiteDroppedString ;
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
     ThermitePickedUpString="picked up the Thermite"
     ThermiteDroppedString="dropped the Thermite"
     Lifetime=4
     DrawColor=(B=25,G=25)
}
