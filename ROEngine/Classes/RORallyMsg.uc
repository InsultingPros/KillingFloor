//=============================================================================
// RORallyMsg
//=============================================================================
// Rally point messages
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2004 John "Ramm-Jaeger" Gibson
//=============================================================================

class RORallyMsg extends ROCriticalMessage;

//=============================================================================
// Variables
//=============================================================================

var(Messages) localized string SavedPosition;
var(Messages) localized string CheckObjectives;
var(Messages) localized string RallySpam;

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
			return default.SavedPosition;
		case 1:
			return default.CheckObjectives;
		case 2:
			return default.RallySpam;
		default:
			return default.SavedPosition;
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
		case 0: // rally point set
		case 1: // rally point set
			if (RelatedPRI_1 != none && RelatedPRI_1.Team != none)
			{
			    if (RelatedPRI_1.Team.TeamIndex == AXIS_TEAM_INDEX)
			        return default.iconID;
			    else
			        return default.altIconID;
			}
			else
			    return default.iconID;
        case 2: // can't set another rally point this soon
			return default.errorIconID;
		default:
			return default.errorIconID;
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     SavedPosition="Rally Point Saved"
     CheckObjectives="New Rally Point - Check Your Map!"
     RallySpam="Cannot Change Rally Point This Soon!"
     iconID=0
     altIconID=1
}
