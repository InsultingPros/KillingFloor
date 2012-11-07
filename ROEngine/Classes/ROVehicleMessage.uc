//=============================================================================
// ROVehicleMessage
//=============================================================================
// Vehicle message
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2004 John "Ramm-Jaeger" Gibson
//=============================================================================

class ROVehicleMessage extends LocalMessage;

//=============================================================================
// Variables
//=============================================================================

var(Messages) localized string NotQualified;
var(Messages) localized string VehicleIsEnemy;
var(Messages) localized string CannotEnter;

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
			return default.NotQualified;
		case 1:
			return default.VehicleIsEnemy;
		default:
			return default.CannotEnter;
	}

}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     NotQualified="Not Qualified To Operate This Vehicle"
     VehicleIsEnemy="Cannot Use An Enemy Vehicle"
     CannotEnter="Cannot Enter This Vehicle"
     bFadeMessage=True
     DrawColor=(B=36,G=28,R=214)
     PosY=0.750000
     FontSize=2
}
