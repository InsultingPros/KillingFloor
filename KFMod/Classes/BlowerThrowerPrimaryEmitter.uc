//=============================================================================
// BlowerThrowerPrimaryEmitter
//=============================================================================
// Primary emitter for the bloat bile thrower projectile
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class BlowerThrowerPrimaryEmitter extends HitFlameBig;

var float LastFlameSpawnTime;
var () float FlameSpawnInterval;

var Emitter SecondaryFlame;

state Ticking
{
    simulated function Tick( float dt )
    {
        if( LifeSpan < 2.0 )
        {
            mRegenRange[0] *= LifeSpan * 0.5;
            mRegenRange[1] = mRegenRange[0];
            SoundVolume = byte(float(SoundVolume) * (LifeSpan * 0.5));
        }

        if (Level.TimeSeconds - LastFlameSpawnTime > FlameSpawnInterval)
        {
            if( SecondaryFlame != none )
            {
                SecondaryFlame.Kill();
            }
          SecondaryFlame =  Spawn(class'BlowerThrowerSecondaryEmitter',self);
        }
    }
}

simulated function Destroyed()
{
    if( SecondaryFlame != none )
    {
        SecondaryFlame.Kill();
    }
}

defaultproperties
{
     mParticleType=PT_Stream
     mMaxParticles=100
     mLifeRange(1)=0.300000
     mRegenRange(0)=60.000000
     mRegenRange(1)=60.000000
     mPosDev=(X=0.000000,Y=0.000000,Z=0.000000)
     mSpawnVecB=(X=20.000000,Z=0.000000)
     mSizeRange(0)=6.000000
     mSizeRange(1)=6.000000
     mGrowthRate=6.000000
     mAttenKa=0.000000
     mNumTileColumns=1
     mNumTileRows=1
     Physics=PHYS_Trailer
     LifeSpan=2.900000
     Skins(0)=Texture'kf_fx_trip_t.Misc.vomit_trail_d'
     Style=STY_Alpha
}
