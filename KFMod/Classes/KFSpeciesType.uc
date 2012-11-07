//=============================================================================
// KFSpeciesType
//=============================================================================
// Superclass for all KF player species types
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KFSpeciesType extends SpeciesType
	abstract;

var()		material		SleeveTexture; // Sleeve texture this species will use

static function string GetVoiceType( bool bIsFemale, LevelInfo Level )
{
	return default.MaleVoice;
}

static function LoadResources(xUtil.PlayerRecord rec, LevelInfo Level, PlayerReplicationInfo PRI, int TeamNum)
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
        Level.AddPrecacheMaterial(default.SleeveTexture);
    }
}

static function Material GetSleeveTexture()
{
	return default.SleeveTexture;
}

defaultproperties
{
     SleeveTexture=Texture'KF_Weapons_Trip_T.hands.hands_1stP_military_diff'
}
