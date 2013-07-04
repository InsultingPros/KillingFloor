/*
	--------------------------------------------------------------
	Msg_RouletteGeneric
	--------------------------------------------------------------

    Generic Messages related to roulette.

	Author :  Alex Quick

	--------------------------------------------------------------
*/
class Msg_RouletteGeneric extends WaitingMessage;

var localized string LetItRideString;
var localized string BettingClosedString;
var localized string NeedMinBetString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    switch(Switch)
    {
        case 1 :    return default.LetItRideString;
        case 2 :    return default.BettingClosedString;
        case 3 :    return default.NeedMinBetString@class'KF_Roulette_Wheel'.default.MinBet;
    }
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
    return 5;
}

defaultproperties
{
     LetItRideString="You let it ride!"
     BettingClosedString="No More bets!"
     NeedMinBetString="Minimum bet for this table is :"
}
