//=============================================================================
// HazmatSpecies
//=============================================================================
// Species type for hazmat players
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HazmatSpecies extends SPECIES_KFMaleHuman;

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
     DetachedArmClass=Class'KFMod.SeveredArmHazmat'
     DetachedLegClass=Class'KFMod.SeveredLegHazmat'
     SleeveTexture=Texture'KF_Weapons2_Trip_T.hands.hands_1stP_hazmat_diff'
     MaleVoice="KFMod.KFVoicePackTwo"
     FemaleVoice="KFMod.KFVoicePackTwo"
     FemaleSoundGroup="XGame.xMercFemaleSoundGroup"
     SpeciesName="Hazmat"
     RaceNum=4
}
