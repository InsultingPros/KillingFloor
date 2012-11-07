//=============================================================================
// ROArtilleryMsg
//=============================================================================
// Artillery message
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2004 John "Ramm-Jaeger" Gibson
//=============================================================================

class ROArtilleryMsg extends ROCriticalMessage;

//=============================================================================
// Variables
//=============================================================================

var(Messages) localized string SavedPosition;
var(Messages) localized string RequestStrike;
var(Messages) localized string StrikeDenied;
var(Messages) localized string StrikeConfirmed;
var(Messages) localized string NoCoords;
var(Messages) localized string InvalidTarget;
var(Messages) localized string OutOfStrikes;
var(Messages) localized string TryAgainLater;
var(Messages) localized string TryAgainSoon;
var(Messages) localized string StrikesRemaining;
var(Messages) localized string NoArtyAvailable;

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
	local int StrikesLeft;
	local ROPlayer Playa;
	local ROGameReplicationInfo GRI;

	if( OptionalObject != none )
	{
		Playa = ROPlayer(OptionalObject);
		GRI = ROGameReplicationInfo(Playa.GameReplicationInfo);

		StrikesLeft = (GRI.ArtilleryStrikeLimit[Playa.Pawn.GetTeamNum()] - (GRI.TotalStrikes[Playa.Pawn.GetTeamNum()] + 1));
	}

	switch (Switch)
	{
		case 0:
			return default.SavedPosition;
		case 1:
			return default.RequestStrike;
		case 2:
			return default.StrikeDenied;
		case 3:
			return default.StrikeConfirmed$" "$StrikesLeft$" "$default.StrikesRemaining;
		case 4:
			return default.NoCoords;
		case 5:
			return default.InvalidTarget;
		case 6:
			return default.OutOfStrikes;
		case 7:
			return default.TryAgainLater;
		case 8:
			return default.TryAgainSoon;
		case 9:
			return default.NoArtyAvailable;
		default:
			return default.StrikeDenied;
	}

}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     SavedPosition="Artillery Position Saved"
     RequestStrike="This is Platoon Commander Requesting Artillery Strike"
     StrikeDenied="This is Headquarters Artillery Strike Denied"
     StrikeConfirmed="This is Headquarters Artillery Strike Confirmed"
     NoCoords="No Coordinates Selected Yet!"
     InvalidTarget="Not a Valid Artillery Target!"
     OutOfStrikes="Your Artillery Strikes for This Mission Are Exhausted"
     TryAgainLater="We Cannot Spare Another Fire Mission So Soon!"
     TryAgainSoon="Another Fire Mission Will Be Available Soon"
     StrikesRemaining="Remaining"
     NoArtyAvailable="No Artillery Support Available"
     iconID=6
}
