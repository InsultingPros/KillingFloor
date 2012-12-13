//=============================================================================
// ClaymoreSwordFireB
//=============================================================================
// Claymore sword secondary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ClaymoreSwordFireB extends KFMeleeFire;

defaultproperties
{
     MeleeDamage=320
     ProxySize=0.150000
     weaponRange=110.000000
     DamagedelayMin=0.970000
     DamagedelayMax=0.970000
     hitDamageClass=Class'KFMod.DamTypeClaymoreSword'
     HitEffectClass=Class'KFMod.AxeHitEffect'
     MeleeHitSoundRefs(0)="KF_ClaymoreSnd.Claymore_Impact_Flesh"
     WideDamageMinHitAngle=0.600000
     bWaitForRelease=True
     FireAnim="HardAttack"
     FireRate=1.250000
     BotRefireRate=1.100000
}
