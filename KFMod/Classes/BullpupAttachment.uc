class BullpupAttachment extends KFWeaponAttachment;

defaultproperties
{
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdMP'
     mTracerClass=Class'KFMod.KFNewTracer'
     mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
     TurnLeftAnim="TurnL_Bullpup"
     TurnRightAnim="TurnR_Bullpup"
     WalkAnims(0)="WalkF_Bullpup"
     WalkAnims(1)="WalkB_Bullpup"
     WalkAnims(2)="WalkL_Bullpup"
     WalkAnims(3)="WalkR_Bullpup"
     CrouchTurnRightAnim="CH_TurnR_Bullpup"
     CrouchTurnLeftAnim="CH_TurnL_Bullpup"
     bRapidFire=True
     bAltRapidFire=True
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     CullDistance=5000.000000
     Mesh=SkeletalMesh'KF_Weapons3rd_Trip.BullPup_3rd'
}
