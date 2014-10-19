/*
	--------------------------------------------------------------
	Msg_EyeBallNotification
	--------------------------------------------------------------

    Local Message class for Patriarch's Eyeball

	--------------------------------------------------------------
*/

class Msg_EyeBallNotification extends WaitingMessage;

var localized string EyeWasPickedUpString;
var localized string EyeWasDroppedString;
var localized string EyeWasScannedString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :    // Someone picked up the eye

        return RelatedPRI_1.PlayerName@default.EyeWasPickedUpString ;

        case 2 :   // Someone dropped the eye

        return RelatedPRI_1.PlayerName@default.EyeWasDroppedString ;

        case 3 :    // Someone used the eye on the retinal scanner.

        return RelatedPRI_1.PlayerName@default.EyeWasScannedString;
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
     EyeWasPickedUpString="picked up the Patriarch's eyeball"
     EyeWasDroppedString="dropped the Patriarch's eyeball"
     EyeWasScannedString="used the Patriarch's eyeball on the retinal scanner."
     Lifetime=4
     DrawColor=(B=25,G=25)
}
