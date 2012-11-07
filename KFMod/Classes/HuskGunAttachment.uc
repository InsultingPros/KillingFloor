//=============================================================================
// HuskGunAttachment
//=============================================================================
// Husk Gun third person attachment class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HuskGunAttachment extends KFWeaponAttachment;

var byte HuskGunCharge, OldHuskGunCharge;
var() class<Emitter> ChargeEmitterClass;
var() Emitter ChargeEmitter;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && (!bNetOwner || bDemoRecording || bRepClientDemo) && (Role==ROLE_Authority) )
		HuskGunCharge;
}

simulated function PostNetReceive()
{
	if( HuskGunCharge!=OldHuskGunCharge )
	{
		OldHuskGunCharge = HuskGunCharge;
		UpdateHuskGunCharge();
	}
}

simulated function UpdateHuskGunCharge()
{
    local float ChargeScale;

    if( Level.NetMode == NM_DedicatedServer )
    {
        return;
    }

    if( HuskGunCharge == 0 )
    {
        DestroyChargeEffect();
    }
    else
    {
        InitChargeEffect();

        ChargeScale = float(HuskGunCharge)/255.0;

        ChargeEmitter.Emitters[0].SizeScale[1].RelativeSize = Lerp( ChargeScale, 1, 3 );
        ChargeEmitter.Emitters[1].StartVelocityRadialRange.Min = Lerp( ChargeScale, 10, 75 );
        ChargeEmitter.Emitters[1].StartVelocityRadialRange.Max = Lerp( ChargeScale, 10, 75 );
        ChargeEmitter.Emitters[1].SizeScale[0].RelativeSize = Lerp( ChargeScale, 1, 3 );
    }
}

simulated function Destroyed()
{
    DestroyChargeEffect();

	Super.Destroyed();
}

simulated function InitChargeEffect()
{
    // don't even spawn on server
    if ( Level.NetMode == NM_DedicatedServer)
		return;

    if ( (ChargeEmitterClass != None) && ((ChargeEmitter == None) || ChargeEmitter.bDeleteMe) )
    {
        ChargeEmitter = Spawn(ChargeEmitterClass);
        if ( ChargeEmitter != None )
    		AttachToBone(ChargeEmitter, 'tip');
    }
}

simulated function DestroyChargeEffect()
{
    if (ChargeEmitter != None)
        ChargeEmitter.Destroy();
}

defaultproperties
{
     ChargeEmitterClass=Class'ROEffects.ChargeUp3rdHusk'
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdNadeL'
     MovementAnims(0)="JogF_HuskGun"
     MovementAnims(1)="JogB_HuskGun"
     MovementAnims(2)="JogL_HuskGun"
     MovementAnims(3)="JogR_HuskGun"
     TurnLeftAnim="TurnL_HuskGun"
     TurnRightAnim="TurnR_HuskGun"
     CrouchAnims(0)="CHWalkF_HuskGun"
     CrouchAnims(1)="CHWalkB_HuskGun"
     CrouchAnims(2)="CHWalkL_HuskGun"
     CrouchAnims(3)="CHWalkR_HuskGun"
     WalkAnims(0)="WalkF_HuskGun"
     WalkAnims(1)="WalkB_HuskGun"
     WalkAnims(2)="WalkL_HuskGun"
     WalkAnims(3)="WalkR_HuskGun"
     CrouchTurnRightAnim="CH_TurnR_HuskGun"
     CrouchTurnLeftAnim="CH_TurnL_HuskGun"
     IdleCrouchAnim="CHIdle_HuskGun"
     IdleWeaponAnim="Idle_HuskGun"
     IdleRestAnim="Idle_HuskGun"
     IdleChatAnim="Idle_HuskGun"
     IdleHeavyAnim="Idle_HuskGun"
     IdleRifleAnim="Idle_HuskGun"
     FireAnims(0)="Fire_HuskGun"
     FireAnims(1)="Fire_HuskGun"
     FireAnims(2)="Fire_HuskGun"
     FireAnims(3)="Fire_HuskGun"
     FireAltAnims(0)="Fire_HuskGun"
     FireAltAnims(1)="Fire_HuskGun"
     FireAltAnims(2)="Fire_HuskGun"
     FireAltAnims(3)="Fire_HuskGun"
     FireCrouchAnims(0)="CHFire_HuskGun"
     FireCrouchAnims(1)="CHFire_HuskGun"
     FireCrouchAnims(2)="CHFire_HuskGun"
     FireCrouchAnims(3)="CHFire_HuskGun"
     FireCrouchAltAnims(0)="CHFire_HuskGun"
     FireCrouchAltAnims(1)="CHFire_HuskGun"
     FireCrouchAltAnims(2)="CHFire_HuskGun"
     FireCrouchAltAnims(3)="CHFire_HuskGun"
     HitAnims(0)="HitF_HuskGun"
     HitAnims(1)="HitB_HuskGun"
     HitAnims(2)="HitL_HuskGun"
     HitAnims(3)="HitR_HuskGun"
     PostFireBlendStandAnim="Blend_HuskGun"
     PostFireBlendCrouchAnim="CHBlend_HuskGun"
     MeshRef="KF_Weapons3rd3_Trip.HuskGun_3rd"
     WeaponAmbientScale=2.000000
}
