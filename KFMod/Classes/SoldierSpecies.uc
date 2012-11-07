//=============================================================================
// PoliceSpecies
//=============================================================================
// Species type for soldier players
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SoldierSpecies extends SPECIES_KFMaleHuman;

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
     MaleVoice="KFMod.KFVoicePackTwo"
     FemaleVoice="KFMod.KFVoicePackTwo"
     FemaleSoundGroup="XGame.xMercFemaleSoundGroup"
     SpeciesName="Soldier"
     RaceNum=4
}
