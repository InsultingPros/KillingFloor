//=============================================================================
// FoundrySpecies
//=============================================================================
// Species type for foundry worker players
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class FoundrySpecies extends SPECIES_KFMaleHuman;

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
     DetachedArmClass=Class'KFMod.SeveredArmFoundry'
     DetachedLegClass=Class'KFMod.SeveredLegFoundry'
     SleeveTexture=Texture'KF_Weapons2_Trip_T.hands.Foundry1_soldier_1stP'
     FemaleSoundGroup="XGame.xMercFemaleSoundGroup"
     SpeciesName="Foundry"
     RaceNum=4
}
