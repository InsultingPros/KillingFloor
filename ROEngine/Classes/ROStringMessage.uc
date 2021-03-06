//=============================================================================
// ROStringMessage
//=============================================================================
// New messages
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class ROStringMessage extends LocalMessage;

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// AssembleString
//-----------------------------------------------------------------------------

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional String MessageString
	)
{
	return MessageString;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bIsSpecial=False
     Lifetime=8
     PosY=0.700000
}
