//=============================================================================
// RoleFullMsg
//=============================================================================
// Message when the role is full that you select. Placeholder til we get
// something better
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class RoleFullMsg extends ROCriticalMessage;

//=============================================================================
// Variables
//=============================================================================

var(Messages) localized string RoleFullMessage;

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
	switch(Switch)
	{
		default:
			return default.RoleFullMessage;
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     RoleFullMessage="Selected role is already full. Choose Another"
     iconID=1
}
