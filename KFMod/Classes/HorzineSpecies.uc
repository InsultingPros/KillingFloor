//=============================================================================
// HorzineSpecies
//=============================================================================
// Species type for Horzine trooper players
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HorzineSpecies extends SPECIES_KFMaleHuman;

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
     DetachedArmClass=Class'KFMod.SeveredArmHorzine'
     DetachedLegClass=Class'KFMod.SeveredLegHorzine'
     SleeveTexture=Texture'KF_Weapons2_Trip_T.hands.Horzine_Trooper_1stP'
     MaleVoice="KFMod.KFVoicePackThree"
     FemaleVoice="KFMod.KFVoicePackThree"
     FemaleSoundGroup="XGame.xMercFemaleSoundGroup"
     SpeciesName="Horzine"
     RaceNum=4
}
