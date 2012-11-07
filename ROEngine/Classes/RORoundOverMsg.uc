//=============================================================================
// RORoundOverMsg
//=============================================================================
// End of round message
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class RORoundOverMsg extends LocalMessage;

//=============================================================================
// Variables
//=============================================================================

var(Messages) localized string AxisWins;
var(Messages) localized string AlliesWins;
var(Messages) localized string NoDecisiveOutcome;

var Sound	AxisWinsSound;
var Sound	AxisLosesSound;
var Sound	AlliesWinsSound;
var Sound	AlliesLosesSound;

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
		case 0:
			return default.AxisWins;
		case 1:
			return default.AlliesWins;
		default:
			return default.NoDecisiveOutcome;
	}

}

//-----------------------------------------------------------------------------
// ClientReceive
//-----------------------------------------------------------------------------
// had to modify this because merca, in his infinite wisdom, removed the lose sounds
//	without telling us ahead of time.
static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (P.PlayerReplicationInfo.Team != None && Switch == 1)
	{
		if (P.PlayerReplicationInfo.Team.TeamIndex == 0)
			//P.PlayAnnouncement(Default.AxisLosesSound,1,true);
			P.PlayAnnouncement(Default.AlliesWinsSound,1,true);
		else
			P.PlayAnnouncement(Default.AlliesWinsSound,1,true);
	}
	else if (P.PlayerReplicationInfo.Team != None)
	{
		if (P.PlayerReplicationInfo.Team.TeamIndex == 1)
			//P.PlayAnnouncement(Default.AlliesLosesSound,1,true);
			P.PlayAnnouncement(Default.AxisWinsSound,1,true);
		else
			P.PlayAnnouncement(Default.AxisWinsSound,1,true);
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     AxisWins="The Axis Forces Win The Battle!"
     AlliesWins="The Allied Forces Win The Battle!"
     NoDecisiveOutcome="No Decisive Victory"
     Lifetime=5
     PosY=0.500000
     FontSize=1
}
