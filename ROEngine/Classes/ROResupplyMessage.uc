//=============================================================================
// ROResupplyMessage
//=============================================================================
// Message send to player when resupplying a machine gunner. This msg class
// is also sent to the gunner to inform them that they were resupplied.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROResupplyMessage extends ROCriticalMessage;

var localized string        ResuppliedGunner;
var localized string        BeenResupplied;

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
			return default.ResuppliedGunner $ RelatedPRI_1.PlayerName;
		case 1:
			return default.BeenResupplied $ RelatedPRI_1.PlayerName;

		default:
			return default.ResuppliedGunner;
	}

}

static function int getIconID(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject)
{
	if (RelatedPRI_1 != none && RelatedPRI_1.Team != none)
	{
	    if (RelatedPRI_1.Team.TeamIndex == AXIS_TEAM_INDEX)
	        return default.iconID;
	    else
	        return default.altIconID;
	}
	else
	    return default.iconID;
}

defaultproperties
{
     ResuppliedGunner="Successfully resupplied "
     BeenResupplied="You have received ammo from "
     iconID=4
     altIconID=5
}
