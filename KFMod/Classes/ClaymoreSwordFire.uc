//=============================================================================
// ClaymoreSwordFire
//=============================================================================
// Claymore sword primary fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ClaymoreSwordFire extends KFMeleeFire;
var() array<name> FireAnims;

simulated event ModeDoFire()
{
    local int AnimToPlay;

    if(FireAnims.length > 0)
    {
        AnimToPlay = rand(FireAnims.length);
        FireAnim = FireAnims[AnimToPlay];
    }

    Super.ModeDoFire();

}

defaultproperties
{
     FireAnims(0)="Fire"
     FireAnims(1)="Fire2"
     FireAnims(2)="fire3"
     FireAnims(3)="Fire4"
     FireAnims(4)="Fire5"
     FireAnims(5)="Fire6"
     MeleeDamage=210
     ProxySize=0.150000
     weaponRange=110.000000
     DamagedelayMin=0.630000
     DamagedelayMax=0.630000
     hitDamageClass=Class'KFMod.DamTypeClaymoreSword'
     HitEffectClass=Class'KFMod.AxeHitEffect'
     MeleeHitSoundRefs(0)="KF_ClaymoreSnd.Claymore_Impact_Flesh"
     WideDamageMinHitAngle=0.650000
     FireRate=1.050000
     BotRefireRate=1.000000
}
