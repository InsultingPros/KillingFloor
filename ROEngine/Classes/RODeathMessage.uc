//=============================================================================
// RODeathMessage
//=============================================================================
// New messages
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class RODeathMessage extends LocalMessage
	config(user);

//=============================================================================
// Variables
//=============================================================================

var(Message) localized string KilledString, SomeoneString;
var config bool bNoConsoleDeathMessages;

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
	local string KillerName, VictimName;

	if (Class<DamageType>(OptionalObject) == None)
		return "";

	if (RelatedPRI_2 == None)
		VictimName = Default.SomeoneString;
	else
		VictimName = RelatedPRI_2.PlayerName;

	if ( Switch == 1 )
	{
		// suicide
		return class'GameInfo'.Static.ParseKillMessage(
			KillerName, 
			VictimName,
			Class<DamageType>(OptionalObject).Static.SuicideMessage(RelatedPRI_2) );
	}

	if (RelatedPRI_1 == None)
		KillerName = Default.SomeoneString;
	else
		KillerName = RelatedPRI_1.PlayerName;

	return class'GameInfo'.Static.ParseKillMessage(
		KillerName, 
		VictimName,
		Class<DamageType>(OptionalObject).Static.DeathMessage(RelatedPRI_1, RelatedPRI_2) );
}

//-----------------------------------------------------------------------------
// ClientReceive
//-----------------------------------------------------------------------------

static function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( !Default.bNoConsoleDeathMessages )
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

//-----------------------------------------------------------------------------
// GetConsoleColor
//-----------------------------------------------------------------------------

static function Color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
	return default.DrawColor;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     KilledString="was killed by"
     SomeoneString="someone"
     bIsSpecial=False
     Lifetime=8
     DrawColor=(B=32,G=128,R=192)
}
