//=============================================================================
// ROVehicleWaitingMsg
//=============================================================================
// Wiating for Crew message
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2004 John "Ramm-Jaeger" Gibson
//=============================================================================

class ROVehicleWaitingMsg extends LocalMessage;

//=============================================================================
// Variables
//=============================================================================

var(Messages) localized string WaitingForCrew;

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
			return default.WaitingForCrew;
		default:
			return default.WaitingForCrew;
	}

}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     WaitingForCrew="Waiting for Additional Crewmembers"
     bFadeMessage=True
     Lifetime=2
     PosY=0.750000
     FontSize=2
}
