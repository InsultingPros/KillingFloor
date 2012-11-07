//DamTypeBludgeon as part of the GoodKarma package
//Build 1 Beta 4.5 Release
//By: Jonathan Zepp
//Basic DamageType for any NetKActor

class DamTypeBludgeon extends DamageType
    abstract;

defaultproperties
{
     DeathString="%o was Bludgeoned to death."
     FemaleSuicide="%o beat herself to a pulp."
     MaleSuicide="%o beat himself to a pulp."
     bExtraMomentumZ=False
     GibModifier=1.500000
     GibPerterbation=0.650000
}
