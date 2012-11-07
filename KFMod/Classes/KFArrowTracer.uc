//=============================================================================
// Tracer Bullet
//=============================================================================
class KFArrowTracer extends pclSmoke;

defaultproperties
{
     mParticleType=PT_Stream
     mStartParticles=0
     mMaxParticles=40
     mLifeRange(0)=0.300000
     mLifeRange(1)=0.300000
     mRegenRange(0)=60.000000
     mRegenRange(1)=60.000000
     mSpawnVecB=(Z=0.000000)
     mSizeRange(0)=2.000000
     mSizeRange(1)=3.000000
     mGrowthRate=-0.500000
     mColorRange(0)=(B=150,G=240,R=255,A=150)
     mColorRange(1)=(B=150,G=240,R=255,A=150)
     mNumTileColumns=1
     mNumTileRows=1
     Physics=PHYS_Trailer
     LifeSpan=2.900000
     Skins(0)=Texture'KFX.TransTrailT'
}
