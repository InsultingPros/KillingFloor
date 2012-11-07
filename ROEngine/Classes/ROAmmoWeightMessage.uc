//=============================================================================
// ROAmmoWeightMessage
// started by Antarian on 9/18/03
//
// Copyright (C) 2003 Jeffrey Nakai
//
// class for displaying Red Orchestra Ammo Weight Messages
//=============================================================================

class ROAmmoWeightMessage extends LocalMessage;

var localized string	HeavyMessage;
var localized string	LightMessage;
var localized string	VeryLightMessage;


static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch(Switch)
	{
		case 0:
			return Default.HeavyMessage;
			break;

		case 1:
			return Default.LightMessage;
			break;

		case 2:
			//DrawColor=(R=255,G=0,B=0,A=255)
			return default.VeryLightMessage;
			break;
	}
}

defaultproperties
{
     HeavyMessage="New magazine is heavy"
     LightMessage="New magazine is light"
     VeryLightMessage="New magazine is very light"
     bIsUnique=True
     bIsConsoleMessage=False
     Lifetime=2
     PosX=0.280000
     PosY=0.930000
     FontSize=-2
}
