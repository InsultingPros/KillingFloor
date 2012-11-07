//=============================================================================
// MP5MAttachment
//=============================================================================
// MP5 medic gun third person attachment class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class MP5MAttachment extends KFWeaponAttachment;

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdMP'
     mTracerClass=Class'KFMod.KFNewTracer'
     mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
     ShellEjectBoneName="Shell_eject"
     MovementAnims(0)="JogF_MP5"
     MovementAnims(1)="JogB_MP5"
     MovementAnims(2)="JogL_MP5"
     MovementAnims(3)="JogR_MP5"
     TurnLeftAnim="TurnL_MP5"
     TurnRightAnim="TurnR_MP5"
     CrouchAnims(0)="CHWalkF_MP5"
     CrouchAnims(1)="CHWalkB_MP5"
     CrouchAnims(2)="CHWalkL_MP5"
     CrouchAnims(3)="CHWalkR_MP5"
     WalkAnims(0)="WalkF_MP5"
     WalkAnims(1)="WalkB_MP5"
     WalkAnims(2)="WalkL_MP5"
     WalkAnims(3)="WalkR_MP5"
     CrouchTurnRightAnim="CH_TurnR_MP5"
     CrouchTurnLeftAnim="CH_TurnL_MP5"
     IdleCrouchAnim="CHIdle_MP5"
     IdleWeaponAnim="Idle_MP5"
     IdleRestAnim="Idle_MP5"
     IdleChatAnim="Idle_MP5"
     IdleHeavyAnim="Idle_MP5"
     IdleRifleAnim="Idle_MP5"
     FireAnims(0)="Fire_MP5"
     FireAnims(1)="Fire_MP5"
     FireAnims(2)="Fire_MP5"
     FireAnims(3)="Fire_MP5"
     FireAltAnims(0)="Fire_MP5"
     FireAltAnims(1)="Fire_MP5"
     FireAltAnims(2)="Fire_MP5"
     FireAltAnims(3)="Fire_MP5"
     FireCrouchAnims(0)="CHFire_MP5"
     FireCrouchAnims(1)="CHFire_MP5"
     FireCrouchAnims(2)="CHFire_MP5"
     FireCrouchAnims(3)="CHFire_MP5"
     FireCrouchAltAnims(0)="CHFire_MP5"
     FireCrouchAltAnims(1)="CHFire_MP5"
     FireCrouchAltAnims(2)="CHFire_MP5"
     FireCrouchAltAnims(3)="CHFire_MP5"
     HitAnims(0)="HitF_MP5"
     HitAnims(1)="HitB_MP5"
     HitAnims(2)="HitL_MP5"
     HitAnims(3)="HitR_MP5"
     PostFireBlendStandAnim="Blend_MP5"
     PostFireBlendCrouchAnim="CHBlend_MP5"
     MeshRef="KF_Weapons3rd3_Trip.Mp5_3rd"
     WeaponAmbientScale=2.000000
     bRapidFire=True
     bAltRapidFire=True
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     CullDistance=5000.000000
}
