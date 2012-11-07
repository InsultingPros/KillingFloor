//=============================================================================
// ROLastObjectiveMsg
//=============================================================================
// Message indicating that game is down to last objective
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROLastObjectiveMsg extends ROCriticalMessage;

//=============================================================================
// Variables
//=============================================================================

var(Messages) localized string AboutToWin;
var(Messages) localized string AboutToLose;

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// GetString
//-----------------------------------------------------------------------------

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0: // axis about to win
        case 2: // allies about to win
			return default.AboutToWin;
		case 1: // axis about to win (player is therefore allies)
        case 3: // allies about to win (player is therefore axis)
			return default.AboutToLose;
		default:
			return "INVALID MESSAGE TYPE: " $ switch;
	}

}

static function int getIconID(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject)
{
	switch (Switch)
	{
		case 0: // axis about to win
		case 1: // axis about to win (player is therefore allies)
			return default.iconID;
        case 2: // allies about to win
        case 3: // allies about to win (player is therefore axis)
			return default.altIconID;
		default:
			return default.errorIconID;
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     AboutToWin="Last objective -- we have almost won the battle!"
     AboutToLose="Last objective -- we have almost lost the battle!"
     iconID=12
     altIconID=13
}
