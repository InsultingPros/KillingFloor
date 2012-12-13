//=============================================================================
// ZEDGunAttachment
//=============================================================================
// ZEDGun third person attachment class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDGunAttachment extends KFWeaponAttachment;

var byte ZedGunCharge, OldZedGunCharge;
var() class<Emitter> ChargeEmitterClass;
var() Emitter ChargeEmitter;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && (!bNetOwner || bDemoRecording || bRepClientDemo) && (Role==ROLE_Authority) )
		ZedGunCharge;
}

simulated function PostNetReceive()
{
	if( ZedGunCharge!=OldZedGunCharge )
	{
		OldZedGunCharge = ZedGunCharge;
		UpdateZedGunCharge();
	}
}

simulated function UpdateZedGunCharge()
{
    local float ChargeScale;

    if( Level.NetMode == NM_DedicatedServer )
    {
        return;
    }

    if( ZedGunCharge == 0 )
    {
        DestroyChargeEffect();
    }
    else
    {
        InitChargeEffect();

        ChargeScale = float(ZedGunCharge)/255.0;

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
     ChargeEmitterClass=Class'ROEffects.ChargeUp3rdZEDGun'
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdZEDGunPrimary'
     MovementAnims(0)="JogF_Zed"
     MovementAnims(1)="JogB_Zed"
     MovementAnims(2)="JogL_Zed"
     MovementAnims(3)="JogR_Zed"
     TurnLeftAnim="TurnL_Zed"
     TurnRightAnim="TurnR_Zed"
     CrouchAnims(0)="CHwalkF_Zed"
     CrouchAnims(1)="CHwalkB_Zed"
     CrouchAnims(2)="CHwalkL_Zed"
     CrouchAnims(3)="CHwalkR_Zed"
     WalkAnims(0)="WalkF_Zed"
     WalkAnims(1)="WalkB_Zed"
     WalkAnims(2)="WalkL_Zed"
     WalkAnims(3)="WalkR_Zed"
     CrouchTurnRightAnim="Ch_TurnR_Zed"
     CrouchTurnLeftAnim="Ch_TurnL_Zed"
     IdleCrouchAnim="CHIdle_Zed"
     IdleWeaponAnim="Idle_Zed"
     IdleRestAnim="Idle_Zed"
     IdleChatAnim="Idle_Zed"
     IdleHeavyAnim="Idle_Zed"
     IdleRifleAnim="Idle_Zed"
     FireAnims(0)="Fire_Zed"
     FireAnims(1)="Fire_Zed"
     FireAnims(2)="Fire_Zed"
     FireAnims(3)="Fire_Zed"
     FireAltAnims(0)="Fire_Zed"
     FireAltAnims(1)="Fire_Zed"
     FireAltAnims(2)="Fire_Zed"
     FireAltAnims(3)="Fire_Zed"
     FireCrouchAnims(0)="CHFire_Zed"
     FireCrouchAnims(1)="CHFire_Zed"
     FireCrouchAnims(2)="CHFire_Zed"
     FireCrouchAnims(3)="CHFire_Zed"
     FireCrouchAltAnims(0)="CHFire_Zed"
     FireCrouchAltAnims(1)="CHFire_Zed"
     FireCrouchAltAnims(2)="CHFire_Zed"
     FireCrouchAltAnims(3)="CHFire_Zed"
     HitAnims(0)="HitF_Zed"
     HitAnims(1)="HitB_Zed"
     HitAnims(2)="HitL_Zed"
     HitAnims(3)="HitR_Zed"
     PostFireBlendStandAnim="Blend_Zed"
     PostFireBlendCrouchAnim="CHBlend_Zed"
     MeshRef="KF_Weapons3rd6_Trip.ZED_3rd"
     WeaponAmbientScale=2.000000
}
