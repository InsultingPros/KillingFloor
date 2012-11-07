//=============================================================================
// ROObjectiveMsg
//=============================================================================
// Message when objective status changes
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class ROObjectiveMsg extends ROCriticalMessage;

//=============================================================================
// Variables
//=============================================================================

var(Messages) localized string AxisCapture;
var(Messages) localized string AlliesCapture;
var(Messages) localized string AxisTriggeredMessage;
var(Messages) localized string AlliesTriggeredMessage;

var Sound	ObjectiveCompleteSound;
var Sound	ObjectiveFailedSound;

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
	if (ROObjective(OptionalObject) == None)
		return "";

	switch (Switch)
	{
		case 0:
			return default.AxisCapture $ ROObjective(OptionalObject).ObjName;
		case 1:
			return default.AlliesCapture $ ROObjective(OptionalObject).ObjName;
		case 2:
			return default.AxisTriggeredMessage $ ROObjective(OptionalObject).ObjName;
		case 3:
			return default.AlliesTriggeredMessage $ ROObjective(OptionalObject).ObjName;
	}
}

//-----------------------------------------------------------------------------
// ClientReceive
//-----------------------------------------------------------------------------

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (P.PlayerReplicationInfo.Team != None && P.PlayerReplicationInfo.Team.TeamIndex == GetTeam(Switch))
		P.PlayAnnouncement(Default.ObjectiveCompleteSound,1,true);
	else
		P.PlayAnnouncement(Default.ObjectiveFailedSound,1,true);
}

//-----------------------------------------------------------------------------
// GetTeam
//-----------------------------------------------------------------------------

static function int GetTeam(int Switch)
{
	if (Switch == 0 || Switch == 2)
		return 1;

	return 0;
}

static function int getIconID(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject)
{
	switch (Switch)
	{
		case 0:
		case 2:
			return default.iconID;
		case 1:
		case 3:
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
     AxisCapture="The Axis forces have captured "
     AlliesCapture="The Allied forces have captured "
     AxisTriggeredMessage="The Axis forces destroyed "
     AlliesTriggeredMessage="The Allied forces have destroyed "
     iconID=8
     altIconID=9
}
