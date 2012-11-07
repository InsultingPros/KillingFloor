//=============================================================================
// DamTypeMedicNade
//=============================================================================
// Damage class for being poisoned by the MedicNade
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DamTypeMedicNade extends KFWeaponDamageType;

defaultproperties
{
     bCheckForHeadShots=False
     DeathString="%k poisoned %o (MedicNade)."
     FemaleSuicide="%o poisoned herself."
     MaleSuicide="%o poisoned himself."
     bLocationalHit=False
}
