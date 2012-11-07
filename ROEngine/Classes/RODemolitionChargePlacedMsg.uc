//=============================================================================
// RODemolitionChargePlacedMsg
//=============================================================================
// Message indicating that a teammember has placed a demolition charge
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class RODemolitionChargePlacedMsg extends ROCriticalMessage;

var(Messages) localized string DemoChargePlaced;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return default.DemoChargePlaced;
}

defaultproperties
{
     DemoChargePlaced="Demolition charge placed; take cover!"
     iconID=2
}
