class DualFlareRevolverAttachment extends DualiesAttachment;

simulated function UpdateTacBeam( float Dist );
simulated function TacBeamGone();

defaultproperties
{
     BrotherMesh=SkeletalMesh'KF_Weapons3rd_IJC.Flare_Revolver_3rd'
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdFlareRevolver'
     mTracerClass=None
     mShellCaseEmitterClass=None
     bHeavy=True
     SplashEffect=Class'ROEffects.BulletSplashEmitter'
     CullDistance=5000.000000
     Mesh=SkeletalMesh'KF_Weapons3rd_IJC.Flare_Revolver_3rd'
}
