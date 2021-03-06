//=============================================================================
// speedtrail
// effect for fast things
// by David Hensley
//=============================================================================

class SpeedTrail extends xemitter;

defaultproperties
{
     mParticleType=PT_Stream
     mStartParticles=0
     mLifeRange(0)=0.650000
     mLifeRange(1)=0.650000
     mRegenRange(0)=10.000000
     mRegenRange(1)=10.000000
     mDirDev=(X=0.500000,Y=0.500000,Z=0.500000)
     mPosDev=(X=2.000000,Y=2.000000,Z=2.000000)
     mSpeedRange(0)=-20.000000
     mSpeedRange(1)=-20.000000
     mAirResistance=0.000000
     mSizeRange(0)=12.000000
     mSizeRange(1)=12.000000
     mGrowthRate=-12.000000
     mAttenKa=0.000000
     mNumTileColumns=0
     mNumTileRows=0
     LifeSpan=1.000000
     Skins(0)=Texture'kf_fx_trip_t.Misc.speedtrail_T'
     Style=STY_Additive
}
