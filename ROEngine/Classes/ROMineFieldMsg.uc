//=============================================================================
// ROMineFieldMsg
//=============================================================================
// This is a localized message class used to send critical messages
// when a player enters an ROMineVolume
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 John "Ramm-Jaeger" Gibson
//=============================================================================

class ROMineFieldMsg extends ROCriticalMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if (ROMineVolume(OptionalObject) == none)
	{
	    warn("ROMineVolume message received with no associated ROMineVolume!");
	    return("");
	}
	else
	{
	    return ROMineVolume(OptionalObject).WarningMessage;
	}
}

defaultproperties
{
     iconID=10
}
