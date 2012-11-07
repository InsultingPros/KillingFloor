//=============================================================================
// DismemebermentJetLimb
//=============================================================================
// blood jet when a limb dismemberment happens
//=============================================================================
// Killing Floor Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - David Hensley & John "Ramm-Jaeger" Gibson
//=============================================================================

class DismembermentJetLimb extends DismembermentJet;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter124
         UseDirectionAs=PTDU_UpAndNormal
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=-50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.120000
         FadeInEndTime=0.060000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartLocationRange=(X=(Min=20.000000,Max=20.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=3.000000
         DrawStyle=PTDS_Modulated
         Texture=Texture'kf_fx_trip_t.Gore.limbremoval_blood_b'
         LifetimeRange=(Min=0.500000,Max=0.750000)
         StartVelocityRange=(X=(Min=50.000000,Max=50.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.DismembermentJetLimb.SpriteEmitter124'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter125
         UseDirectionAs=PTDU_UpAndNormal
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=-50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.110000
         FadeInEndTime=0.020000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartLocationRange=(X=(Min=20.000000,Max=20.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=3.000000
         DrawStyle=PTDS_Modulated
         Texture=Texture'kf_fx_trip_t.Gore.limbremoval_blood_b'
         LifetimeRange=(Min=0.500000,Max=0.750000)
         StartVelocityRange=(X=(Min=50.000000,Max=50.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFMod.DismembermentJetLimb.SpriteEmitter125'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter126
         UseDirectionAs=PTDU_UpAndNormal
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=-50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.415000
         FadeInEndTime=0.225000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationRange=(X=(Min=20.000000,Max=20.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Modulated
         Texture=Texture'kf_fx_trip_t.Gore.limbremoval_blood'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=50.000000))
     End Object
     Emitters(2)=SpriteEmitter'KFMod.DismembermentJetLimb.SpriteEmitter126'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter127
         UseDirectionAs=PTDU_UpAndNormal
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=-50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.415000
         FadeInEndTime=0.225000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationRange=(X=(Min=20.000000,Max=20.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
         StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Modulated
         Texture=Texture'kf_fx_trip_t.Gore.limbremoval_blood'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=50.000000))
     End Object
     Emitters(3)=SpriteEmitter'KFMod.DismembermentJetLimb.SpriteEmitter127'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter128
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.750000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         FadeOutStartTime=0.850000
         MaxParticles=200
         StartLocationRange=(X=(Min=20.000000,Max=20.000000))
         SphereRadiusRange=(Max=1.000000)
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.070000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.250000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         InitialParticlesPerSecond=30.000000
         DrawStyle=PTDS_Modulated
         Texture=Texture'kf_fx_trip_t.Gore.kf_bloodspray_e_diff'
         TextureUSubdivisions=8
         TextureVSubdivisions=4
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=0.450000,Max=0.850000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         MaxAbsVelocity=(X=100.000000,Y=100.000000,Z=100.000000)
     End Object
     Emitters(4)=SpriteEmitter'KFMod.DismembermentJetLimb.SpriteEmitter128'

}
