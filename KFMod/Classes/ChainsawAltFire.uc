//=============================================================================
// ChainsawAltFire
//=============================================================================
// Power slash chainsaw fire class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ChainsawAltFire extends KFMeleeFire;

var()   array<name>     FireAnims;
var 	sound   		FireEndSound;				// The sound to play at the end of firing

var		string			FireEndSoundRef;

static function PreloadAssets(optional KFMeleeFire Spawned)
{
	super.PreloadAssets(Spawned);

	default.FireEndSound = sound(DynamicLoadObject(default.FireEndSoundRef, class'sound', true));

	if ( ChainsawAltFire(Spawned) != none )
	{
		ChainsawAltFire(Spawned).FireEndSound = default.FireEndSound;
	}
}

static function bool UnloadAssets()
{
	super.UnloadAssets();

	default.FireEndSound = none;

	return true;
}

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

simulated Function Timer()
{
    super.Timer();

    Weapon.PlayOwnedSound(FireEndSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,,false);
}

defaultproperties
{
     FireAnims(0)="Fire2"
     FireAnims(1)="fire3"
     FireEndSoundRef="KF_ChainsawSnd.Chainsaw_RevLong_End"
     MeleeDamage=270
     DamagedelayMin=0.650000
     DamagedelayMax=0.650000
     hitDamageClass=Class'KFMod.DamTypeChainsaw'
     HitEffectClass=Class'KFMod.ChainsawHitEffect'
     FireSoundRef="KF_ChainsawSnd.Chainsaw_RevLong_Start"
     TransientSoundVolume=1.800000
     FireAnim="Fire2"
     FireRate=1.100000
     BotRefireRate=0.800000
}
