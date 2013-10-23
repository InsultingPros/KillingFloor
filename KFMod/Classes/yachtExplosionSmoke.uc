class yachtExplosionSmoke extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter42
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=100.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000)
         FadeOutStartTime=0.960000
         FadeInEndTime=0.840000
         MaxParticles=15
         SpinsPerSecondRange=(Y=(Min=-0.050000,Max=0.050000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.250000)
         StartSizeRange=(X=(Min=300.000000,Max=420.000000),Y=(Min=300.000000,Max=420.000000),Z=(Min=300.000000,Max=420.000000))
         ParticlesPerSecond=2.000000
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.DSmoke_2'
         LifetimeRange=(Min=15.000000,Max=20.000000)
         StartVelocityRange=(X=(Min=-45.000000,Max=100.000000),Y=(Min=-45.000000,Max=100.000000),Z=(Min=25.000000,Max=75.000000))
         VelocityLossRange=(X=(Min=0.250000,Max=1.000000),Y=(Min=0.250000,Max=1.000000),Z=(Min=0.250000,Max=1.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.yachtExplosionSmoke.SpriteEmitter42'

     bNoDelete=False
     bNetTemporary=True
     Physics=PHYS_Trailer
}
