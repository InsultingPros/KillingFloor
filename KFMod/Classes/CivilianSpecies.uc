//=============================================================================
// CivilianSpecies
//=============================================================================
// Species type for civilian players
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class CivilianSpecies extends SPECIES_KFMaleHuman;

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
     DetachedArmClass=Class'KFMod.SeveredArmScully'
     DetachedLegClass=Class'KFMod.SeveredLegScully'
     SleeveTexture=Texture'KF_Weapons2_Trip_T.hands.Civi_I_1st_P'
     FemaleSoundGroup="XGame.xMercFemaleSoundGroup"
     SpeciesName="Civilian"
     RaceNum=4
}
