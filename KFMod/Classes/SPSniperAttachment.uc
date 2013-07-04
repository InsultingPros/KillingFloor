//=============================================================================
// SPSniperAttachment
//=============================================================================
// Steampunk Sniper rifle third person attachement class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPSniperAttachment extends KFWeaponAttachment;

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdSPSniper'
     mTracerClass=Class'KFMod.SPSniperTracer'
     mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
     MovementAnims(0)="JogF_M14"
     MovementAnims(1)="JogB_M14"
     MovementAnims(2)="JogL_M14"
     MovementAnims(3)="JogR_M14"
     TurnLeftAnim="TurnL_M14"
     TurnRightAnim="TurnR_M14"
     CrouchAnims(0)="CHWalkF_M14"
     CrouchAnims(1)="CHWalkB_M14"
     CrouchAnims(2)="CHWalkL_M14"
     CrouchAnims(3)="CHWalkR_M14"
     WalkAnims(0)="WalkF_M14"
     WalkAnims(1)="WalkB_M14"
     WalkAnims(2)="WalkL_M14"
     WalkAnims(3)="WalkR_M14"
     CrouchTurnRightAnim="CH_TurnR_M14"
     CrouchTurnLeftAnim="CH_TurnL_M14"
     IdleCrouchAnim="CHIdle_M14"
     IdleWeaponAnim="Idle_M14"
     IdleRestAnim="Idle_M14"
     IdleChatAnim="Fire_spSinper"
     IdleHeavyAnim="Idle_M14"
     IdleRifleAnim="Idle_M14"
     FireAnims(0)="Fire_spSinper"
     FireAnims(1)="Fire_spSinper"
     FireAnims(2)="Fire_spSinper"
     FireAnims(3)="Fire_spSinper"
     FireAltAnims(0)="Fire_spSinper"
     FireAltAnims(1)="Fire_spSinper"
     FireAltAnims(2)="Fire_spSinper"
     FireAltAnims(3)="Fire_spSinper"
     FireCrouchAnims(0)="CHFire_spSinper"
     FireCrouchAnims(1)="CHFire_spSinper"
     FireCrouchAnims(2)="CHFire_spSinper"
     FireCrouchAnims(3)="CHFire_spSinper"
     FireCrouchAltAnims(0)="CHFire_spSinper"
     FireCrouchAltAnims(1)="CHFire_spSinper"
     FireCrouchAltAnims(2)="CHFire_spSinper"
     FireCrouchAltAnims(3)="CHFire_spSinper"
     HitAnims(0)="HitF_M14"
     HitAnims(1)="HitB_M14"
     HitAnims(2)="HitL_M14"
     HitAnims(3)="HitR_M14"
     PostFireBlendStandAnim="Blend_M14"
     PostFireBlendCrouchAnim="CHBlend_M14"
     MeshRef="KF_Weapons3rd2_IJC.spSniper_3rd"
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     CullDistance=5000.000000
}
