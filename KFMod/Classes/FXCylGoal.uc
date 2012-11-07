//=============================================================================
// Siren Scream
//=============================================================================
// Effect when the siren screams
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Created by - David Henseley
//=============================================================================
class FxCylGoal extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'SpecialEffectsSM.fx.fxgoal'
         RenderTwoSided=True
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         UniformSize=True
         Acceleration=(Z=30.000000)
         ColorScale(0)=(Color=(B=60,G=196,R=60,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=15,G=49,R=15,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(R=255,A=255))
         FadeOutStartTime=1.840000
         FadeInEndTime=1.480000
         StartLocationRange=(Z=(Min=-50.000000,Max=20.000000))
         StartSpinRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.700000),Y=(Min=0.700000),Z=(Min=0.700000))
         InitialParticlesPerSecond=10.000000
     End Object
     Emitters(0)=MeshEmitter'KFMod.FXCylGoal.MeshEmitter0'

     LightType=LT_Steady
     LightHue=63
     LightSaturation=127
     LightBrightness=500.000000
     LightRadius=10.000000
     bLightChanged=True
     bNoDelete=False
     bUnlit=False
     bSelected=True
}
