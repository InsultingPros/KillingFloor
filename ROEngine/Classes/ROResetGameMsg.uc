//=============================================================================
// ROResetGameMsg
//=============================================================================
// Message when game
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2007 Dayle Flowers
//=============================================================================

class ROResetGameMsg extends ROCriticalMessage;

//=============================================================================
// Variables
//=============================================================================
var(Messages) localized string CountdownLeftSide;
var(Messages) localized string CountdownRightSide;
var(Messages) localized string GameRestarting;

//=============================================================================
// Functions
//=============================================================================
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if( Switch <= 10 )
	    return default.CountdownLeftSide @ Switch @ default.CountdownRightSide;
	else
	    return default.GameRestarting;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     CountdownLeftSide="The game will restart in"
     CountdownRightSide="seconds"
     GameRestarting="The game is now restarting"
     quickFadeTime=0.010000
     Lifetime=1
}
