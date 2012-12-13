//=============================================================================
// ZEDBeamEffect
//=============================================================================
// Zed Eradication Device Beam Effect
//=============================================================================
// Killing Floor Source
// Copyright (C) 2012 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
// Portions derived from LinkBeamChild Copyright (C) Epic Games
//=============================================================================
class ZEDBeamChild extends xEmitter;

//#exec OBJ LOAD FILE=XEffectMat.utx

defaultproperties
{
     mParticleType=PT_Beam
     mMaxParticles=2
     mRegenDist=75.000000
     mSpinRange(0)=45000.000000
     mSizeRange(0)=6.000000
     mColorRange(0)=(B=180,G=180,R=180)
     mColorRange(1)=(B=180,G=180,R=180)
     mAttenuate=False
     mAttenKa=0.010000
     mWaveFrequency=0.060000
     mWaveAmplitude=15.000000
     mWaveShift=100000.000000
     mBendStrength=3.000000
     mWaveLockEnd=True
     Skins(0)=FinalBlend'KFZED_FX_T.Energy.ZED_FX_Beam_FB'
     Style=STY_Additive
}
