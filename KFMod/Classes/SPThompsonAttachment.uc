//=============================================================================
// SPThompsonAttachment
//=============================================================================
// Steampunk Thompson SMG third person attachment class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - IJC Weapon Development and John "Ramm-Jaeger" Gibson
//=============================================================================
class SPThompsonAttachment extends KFWeaponAttachment;

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdSPThompson'
     mTracerClass=Class'KFMod.KFNewTracer'
     mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
     MovementAnims(0)="JogF_IJC_spThompson_Drum"
     MovementAnims(1)="JogB_IJC_spThompson_Drum"
     MovementAnims(2)="JogL_IJC_spThompson_Drum"
     MovementAnims(3)="JogR_IJC_spThompson_Drum"
     TurnLeftAnim="TurnL_IJC_spThompson_Drum"
     TurnRightAnim="TurnR_IJC_spThompson_Drum"
     CrouchAnims(0)="CHWalkF_IJC_spThompson_Drum"
     CrouchAnims(1)="CHWalkB_IJC_spThompson_Drum"
     CrouchAnims(2)="CHWalkL_IJC_spThompson_Drum"
     CrouchAnims(3)="CHWalkR_IJC_spThompson_Drum"
     WalkAnims(0)="WalkF_IJC_spThompson_Drum"
     WalkAnims(1)="WalkB_IJC_spThompson_Drum"
     WalkAnims(2)="WalkL_IJC_spThompson_Drum"
     WalkAnims(3)="WalkR_IJC_spThompson_Drum"
     CrouchTurnRightAnim="CH_TurnR_IJC_spThompson_Drum"
     CrouchTurnLeftAnim="CH_TurnL_IJC_spThompson_Drum"
     IdleCrouchAnim="CHIdle_IJC_spThompson_Drum"
     IdleWeaponAnim="Idle_IJC_spThompson_Drum"
     IdleRestAnim="Idle_IJC_spThompson_Drum"
     IdleChatAnim="Idle_IJC_spThompson_Drum"
     IdleHeavyAnim="Idle_IJC_spThompson_Drum"
     IdleRifleAnim="Idle_IJC_spThompson_Drum"
     FireAnims(0)="Fire_IJC_spThompson_Drum"
     FireAnims(1)="Fire_IJC_spThompson_Drum"
     FireAnims(2)="Fire_IJC_spThompson_Drum"
     FireAnims(3)="Fire_IJC_spThompson_Drum"
     FireAltAnims(0)="Fire_IJC_spThompson_Drum"
     FireAltAnims(1)="Fire_IJC_spThompson_Drum"
     FireAltAnims(2)="Fire_IJC_spThompson_Drum"
     FireAltAnims(3)="Fire_IJC_spThompson_Drum"
     FireCrouchAnims(0)="CHFire_IJC_spThompson_Drum"
     FireCrouchAnims(1)="CHFire_IJC_spThompson_Drum"
     FireCrouchAnims(2)="CHFire_IJC_spThompson_Drum"
     FireCrouchAnims(3)="CHFire_IJC_spThompson_Drum"
     FireCrouchAltAnims(0)="CHFire_IJC_spThompson_Drum"
     FireCrouchAltAnims(1)="CHFire_IJC_spThompson_Drum"
     FireCrouchAltAnims(2)="CHFire_IJC_spThompson_Drum"
     FireCrouchAltAnims(3)="CHFire_IJC_spThompson_Drum"
     HitAnims(0)="HitF_IJC_spThompson_Drum"
     HitAnims(1)="HitB_IJC_spThompson_Drum"
     HitAnims(2)="HitL_IJC_spThompson_Drum"
     HitAnims(3)="HitR_IJC_spThompson_Drum"
     PostFireBlendStandAnim="Blend_IJC_spThompson_Drum"
     PostFireBlendCrouchAnim="CHBlend_IJC_spThompson_Drum"
     MeshRef="KF_Weapons3rd2_IJC.Steampunk_Thompson_3rd"
     WeaponAmbientScale=2.000000
     bRapidFire=True
     bAltRapidFire=True
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     CullDistance=5000.000000
}
