//-----------------------------------------------------------
//  RODiedInTankDamType
//  Copyright (C) 2007 Tripwire Interactive
//
//  Created July 2007 by Stephen Timothy Cooney
//
//  Used when a player dies in a tank. Acts as a specific
//  marker to the game engine.
//-----------------------------------------------------------
class RODiedInTankDamType extends DamageType;

defaultproperties
{
     DeathString="%k blew up %o's vehicle!"
     FemaleSuicide="%o blew up her own tank."
     MaleSuicide="%o blew up his own tank."
     bAlwaysGibs=True
     bLocationalHit=False
     bKUseTearOffMomentum=True
     bNeverSevers=True
     bExtraMomentumZ=False
     bVehicleHit=True
     GibModifier=2.000000
     GibPerterbation=0.500000
     HumanObliterationThreshhold=-1000000
}
