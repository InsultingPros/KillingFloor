//=============================================================================
// DwarfAxeFireB
//=============================================================================
// Dwarf Axe secondary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class DwarfAxeFireB extends KFMeleeFire;

defaultproperties
{
     MeleeDamage=325
     ProxySize=0.150000
     weaponRange=90.000000
     DamagedelayMin=0.740000
     DamagedelayMax=0.740000
     hitDamageClass=Class'KFMod.DamTypeDwarfAxeSecondary'
     MeleeHitSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
     HitEffectClass=Class'KFMod.AxeHitEffect'
     WideDamageMinHitAngle=0.900000
     bWaitForRelease=True
     FireAnim="PowerAttack"
     FireRate=1.500000
     BotRefireRate=1.100000
}
