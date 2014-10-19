/*
	--------------------------------------------------------------
	Msg_NitroglycerinNotification
	--------------------------------------------------------------

    Local Message class for the Nitroglycerin

	--------------------------------------------------------------
*/

class Msg_NitroglycerinNotification extends WaitingMessage;

var localized string NitroglycerinPickedUpString;
var localized string NitroglycerinDroppedString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :    // Someone picked up the Nitroglycerin

        return RelatedPRI_1.PlayerName@default.NitroglycerinPickedUpString ;

        case 2 :   // Someone dropped the Nitroglycerin

        return RelatedPRI_1.PlayerName@default.NitroglycerinDroppedString ;
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
     NitroglycerinPickedUpString="picked up the Nitroglycerin"
     NitroglycerinDroppedString="dropped the Nitroglycerin"
     Lifetime=4
     DrawColor=(B=25,G=25)
}
