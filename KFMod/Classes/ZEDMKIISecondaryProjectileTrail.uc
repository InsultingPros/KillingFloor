//=============================================================================
// ZEDMKIIPrimaryProjectileImpact
//=============================================================================
// Primary projectile trail effect class for the ZEDGun MKII
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDMKIISecondaryProjectileTrail extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter15
         UniformSize=True
         ColorScale(0)=(Color=(R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000))
         Opacity=0.330000
         FadeOutStartTime=10.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         InitialParticlesPerSecond=1.000000
         Texture=Texture'Waterworks_T.General.glow_dam01'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=30.000000
     End Object
     Emitters(0)=SpriteEmitter'KFMod.ZEDMKIISecondaryProjectileTrail.SpriteEmitter15'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter17
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         UseRegularSizeScale=False
         ScaleSizeYByVelocity=True
         Acceleration=(Z=-500.000000)
         DampingFactorRange=(X=(Min=0.200000),Y=(Min=0.200000),Z=(Min=0.200000,Max=0.500000))
         ColorScale(0)=(Color=(B=234,G=154,R=21))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=242,G=228,R=206))
         FadeOutStartTime=0.500000
         MaxParticles=25
         DetailMode=DM_High
         UseRotationFrom=PTRS_Actor
         SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.020000)
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFX.KFSparkHead'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.500000,Max=0.600000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFMod.ZEDMKIISecondaryProjectileTrail.SpriteEmitter17'

     Begin Object Class=MeshEmitter Name=MeshEmitter3
         StaticMesh=StaticMesh'kf_generic_sm.fx.siren_scream_ball'
         UseParticleColor=True
         SpinParticles=True
         UseRegularSizeScale=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000),Z=(Min=0.100000,Max=0.100000))
         FadeOutStartTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_Regular
         LifetimeRange=(Min=0.001000,Max=0.001000)
     End Object
     Emitters(2)=MeshEmitter'KFMod.ZEDMKIISecondaryProjectileTrail.MeshEmitter3'

     bNoDelete=False
     bNetTemporary=True
     Physics=PHYS_Trailer
     Skins(0)=Shader'KFZED_FX_T.Energy.ZED_EnergyBall_Shdr'
}
