//=============================================================================
// PoliceSpecies
//=============================================================================
// Species type for police players
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class PoliceSpecies extends SPECIES_KFMaleHuman;

static function string GetRagSkelName(string MeshName)
{
	if(InStr(MeshName, "Gitty") >= 0)
		return Default.FemaleRagSkelName;
	if(InStr(MeshName, "Ophelia") >= 0)
		return Default.FemaleRagSkelName;

	return Super.GetRagSkelName(MeshName);
}

defaultproperties
{
     DetachedArmClass=Class'KFMod.SeveredArmPolice'
     DetachedLegClass=Class'KFMod.SeveredLegPolice'
     SleeveTexture=Texture'KF_Weapons_Trip_T.hands.hands_1stP_riot_D'
     FemaleSoundGroup="XGame.xMercFemaleSoundGroup"
     SpeciesName="Police"
     RaceNum=4
}
