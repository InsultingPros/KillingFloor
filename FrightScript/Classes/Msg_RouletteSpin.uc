/*
	--------------------------------------------------------------
	Msg_RouletteSpin
	--------------------------------------------------------------

    local message that lets players know which number the last spin landed on

	Author :  Alex Quick

	--------------------------------------------------------------
*/
class Msg_RouletteSpin extends WaitingMessage;

var localized string LetItRideString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return "The Ball landed on :"@Switch@class'KF_Roulette_Wheel'.static.GetPocketClr(Switch)@"!" ;
}

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	super(CriticalEventPlus).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

static function float GetLifeTime(int Switch)
{
    return 5;
}

static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	OutDrawPivot = default.DrawPivot;
	OutStackMode = default.StackMode;
	OutPosX = default.PosX;
	OutPosY = 0.7;
}

static function int GetFontSize(int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer)
{
    return 4;
}

defaultproperties
{
}
