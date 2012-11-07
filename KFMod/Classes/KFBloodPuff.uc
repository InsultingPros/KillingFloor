//=============================================================================
// KF Blood Spray (normal shot effect)
//=============================================================================
class KFBloodPuff extends BloodSmallHit;

#exec OBJ LOAD File=KFX.utx

defaultproperties
{
     BloodDecalClass=Class'KFMod.KFBloodSplatterDecal'
     Splats(0)=Texture'KFX.BloodSplat1'
     Splats(1)=Texture'KFX.BloodSplat2'
     Splats(2)=Texture'KFX.BloodSplat3'
     mStartParticles=2
     mMaxParticles=2
     mLifeRange(0)=0.300000
     mLifeRange(1)=0.500000
     mDirDev=(X=0.000000,Y=15.000000,Z=10.000000)
     mPosDev=(X=0.000000,Y=0.000000,Z=0.000000)
     mSpeedRange(0)=2.000000
     mSpeedRange(1)=4.000000
     mMassRange(0)=0.200000
     mMassRange(1)=0.300000
     mSpinRange(0)=50.000000
     mSpinRange(1)=90.000000
     mSizeRange(0)=1.000000
     mSizeRange(1)=2.000000
     mGrowthRate=75.000000
     mNumTileColumns=2
     mNumTileRows=2
     Skins(0)=Texture'kf_fx_trip_t.Gore.blood_hit_c'
}
