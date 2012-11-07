//=============================================================================
// RODaddyMessage
// started by Antarian on 12/9/03
//
// Copyright (C) 2003 Jeffrey Nakai
//
// Easter Egg fun
//=============================================================================

class RODaddyMessage extends LocalMessage;

var localized string	DaddyMessage;


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
			return default.DaddyMessage;
	}
}

defaultproperties
{
     DaddyMessage="Antarian Is Your Daddy!"
     bIsUnique=True
     bIsConsoleMessage=False
     Lifetime=4
     DrawColor=(B=0,G=0)
     PosY=0.500000
     FontSize=2
}
