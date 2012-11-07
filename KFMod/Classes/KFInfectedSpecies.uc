class KFInfectedSpecies extends SpeciesType
    abstract;

static function string GetRagSkelName(String MeshName)
{
    return "Infected";
}

defaultproperties
{
     MaleVoice="KFmod.KFMaleZombieSounds"
     FemaleVoice="KFmod.KFMaleZombieSounds"
     MaleSoundGroup="KFmod.KFMaleZombieSounds"
     FemaleSoundGroup="KFmod.KFMaleZombieSounds"
     SpeciesName="Infected"
     AirControl=1.200000
     GroundSpeed=1.400000
     ReceivedDamageScaling=1.300000
     AccelRate=1.100000
}
