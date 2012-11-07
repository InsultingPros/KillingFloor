//=============================================================================
// ROWeaponLost
// started by Puma on 6/17/2004
//
// Copyright (C) 2004 Red Orchestra
//
//=============================================================================

class ROWeaponLostMessage extends ROCriticalMessage;

var localized string	WeaponLostMessage;


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
			return default.WeaponLostMessage;
	}
}

defaultproperties
{
     WeaponLostMessage="Weapon Shot Out Of Your Hand!"
     iconID=7
}
