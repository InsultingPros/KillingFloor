class KFVomitJet extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter75
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-210.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=44,G=68,R=75))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=109,G=131,R=122,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(G=103,R=206,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(G=103,R=206,A=255))
         ColorScale(4)=(RelativeTime=1.000000,Color=(R=128,A=255))
         ColorScale(5)=(RelativeTime=1.000000)
         ColorScale(6)=(RelativeTime=1.000000)
         ColorMultiplierRange=(X=(Min=0.250000,Max=0.250000),Y=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
         FadeOutStartTime=0.336000
         FadeInEndTime=0.064000
         MaxParticles=50
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=2.000000,Max=3.000000),Y=(Min=5000.000000,Max=5000.000000),Z=(Min=5000.000000,Max=5000.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000,Y=0.010000)
         InitialParticlesPerSecond=50.000000
         Texture=Texture'KFX.MetalHitKF'
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.KFVomitJet.SpriteEmitter75'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter76
         UseDirectionAs=PTDU_Up
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=-100.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=1.250000
         MaxParticles=50
         StartLocationRange=(X=(Min=10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.200000,Max=0.200000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=10.000000,Max=30.000000),Y=(Min=10.000000,Max=30.000000),Z=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'kf_fx_trip_t.Gore.bloat_vomit_spray_anim'
         TextureUSubdivisions=8
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.250000,Max=1.250000)
         InitialDelayRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(X=(Min=125.000000,Max=150.000000))
     End Object
     Emitters(1)=SpriteEmitter'ROEffects.KFVomitJet.SpriteEmitter76'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter77
         UseDirectionAs=PTDU_Up
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=-100.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=1.000000
         StartLocationRange=(X=(Min=10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.200000,Max=0.200000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=10.000000,Max=30.000000),Y=(Min=10.000000,Max=30.000000),Z=(Min=10.000000,Max=30.000000))
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'kf_fx_trip_t.Gore.bloat_vomit_spray_anim'
         TextureUSubdivisions=8
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=10.000000,Max=10.000000))
     End Object
     Emitters(2)=SpriteEmitter'ROEffects.KFVomitJet.SpriteEmitter77'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     LifeSpan=4.000000
     bUnlit=False
     bDirectional=True
}
