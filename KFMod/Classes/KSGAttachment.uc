//=============================================================================
// KSGAttachment
//=============================================================================
// KSG shotgun attachment class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson and IJC
//=============================================================================
class KSGAttachment extends KFWeaponAttachment;

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdKar'
     mShellCaseEmitterClass=Class'KFMod.KFShotgunShellSpewer'
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
     FireAnims(0)="Fire_KSG"
     FireAnims(1)="Fire_KSG"
     FireAnims(2)="Fire_KSG"
     FireAnims(3)="Fire_KSG"
     FireAltAnims(0)="Fire_KSG"
     FireAltAnims(1)="Fire_KSG"
     FireAltAnims(2)="Fire_KSG"
     FireAltAnims(3)="Fire_KSG"
     FireCrouchAnims(0)="CHFire_KSG"
     FireCrouchAnims(1)="CHFire_KSG"
     FireCrouchAnims(2)="CHFire_KSG"
     FireCrouchAnims(3)="CHFire_KSG"
     FireCrouchAltAnims(0)="CHFire_KSG"
     FireCrouchAltAnims(1)="CHFire_KSG"
     FireCrouchAltAnims(2)="CHFire_KSG"
     FireCrouchAltAnims(3)="CHFire_KSG"
     HitAnims(0)="HitF_MP5"
     HitAnims(1)="HitB_MP5"
     HitAnims(2)="HitL_MP5"
     HitAnims(3)="HitR_MP5"
     PostFireBlendStandAnim="Blend_MP5"
     PostFireBlendCrouchAnim="CHBlend_MP5"
     MeshRef="KF_Weapons3rd4_Trip.KSG_3rd"
}
