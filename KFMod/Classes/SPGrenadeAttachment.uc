//=============================================================================
// SPShotgunAttachment
//=============================================================================
// Steampunk Shotgun third person attachement class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class SPGrenadeAttachment extends KFWeaponAttachment;

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdSPGrenade'
     MovementAnims(0)="JogF_M79"
     MovementAnims(1)="JogB_M79"
     MovementAnims(2)="JogL_M79"
     MovementAnims(3)="JogR_M79"
     TurnLeftAnim="TurnL_M79"
     TurnRightAnim="TurnR_M79"
     CrouchAnims(0)="CHWalkF_M79"
     CrouchAnims(1)="CHWalkB_M79"
     CrouchAnims(2)="CHWalkL_M79"
     CrouchAnims(3)="CHWalkR_M79"
     WalkAnims(0)="WalkF_M79"
     WalkAnims(1)="WalkB_M79"
     WalkAnims(2)="WalkL_M79"
     WalkAnims(3)="WalkR_M79"
     CrouchTurnRightAnim="CH_TurnR_M79"
     CrouchTurnLeftAnim="CH_TurnL_M79"
     IdleCrouchAnim="CHIdle_M79"
     IdleWeaponAnim="Idle_M79"
     IdleRestAnim="Idle_M79"
     IdleChatAnim="Idle_M79"
     IdleHeavyAnim="Idle_M79"
     IdleRifleAnim="Idle_M79"
     FireAnims(0)="Fire_IJC_spGrenadeLauncher"
     FireAnims(1)="Fire_IJC_spGrenadeLauncher"
     FireAnims(2)="Fire_IJC_spGrenadeLauncher"
     FireAnims(3)="Fire_IJC_spGrenadeLauncher"
     FireAltAnims(0)="Fire_IJC_spGrenadeLauncher"
     FireAltAnims(1)="Fire_IJC_spGrenadeLauncher"
     FireAltAnims(2)="Fire_IJC_spGrenadeLauncher"
     FireAltAnims(3)="Fire_IJC_spGrenadeLauncher"
     FireCrouchAnims(0)="CHFire_IJC_spGrenadeLauncher"
     FireCrouchAnims(1)="CHFire_IJC_spGrenadeLauncher"
     FireCrouchAnims(2)="CHFire_IJC_spGrenadeLauncher"
     FireCrouchAnims(3)="CHFire_IJC_spGrenadeLauncher"
     FireCrouchAltAnims(0)="CHFire_IJC_spGrenadeLauncher"
     FireCrouchAltAnims(1)="CHFire_IJC_spGrenadeLauncher"
     FireCrouchAltAnims(2)="CHFire_IJC_spGrenadeLauncher"
     FireCrouchAltAnims(3)="CHFire_IJC_spGrenadeLauncher"
     HitAnims(0)="HitF_M79"
     HitAnims(1)="HitB_M79"
     HitAnims(2)="HitL_M79"
     HitAnims(3)="HitR_M79"
     PostFireBlendStandAnim="Blend_M79"
     PostFireBlendCrouchAnim="CHBlend_M79"
     MeshRef="KF_Weapons3rd2_IJC.spGrenadeLauncher_3rd"
}
