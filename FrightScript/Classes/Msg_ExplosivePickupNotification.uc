/*
	--------------------------------------------------------------
	Msg_ExplosivePickupNotification
	--------------------------------------------------------------

    Local Message class for the explosives that destroy halliday's yacth

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class Msg_ExplosivePickupNotification extends WaitingMessage;

var localized string ExplosivesPickedUpString;
var localized string ExplosivesDroppedString;
var localized string ExplosivesPlacedString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :

        return RelatedPRI_1.PlayerName@default.ExplosivesPickedUpString ;

        case 2 :

        return RelatedPRI_1.PlayerName@default.ExplosivesDroppedString ;

        case 3 :

        return RelatedPRI_1.PlayerName@default.ExplosivesPlacedString;
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
     ExplosivesPickedUpString="picked up a crate of explosives"
     ExplosivesDroppedString="dropped a crate of explosives!"
     ExplosivesPlacedString="placed the explosives in the boat"
     Lifetime=4
     DrawColor=(B=50,G=50)
}
