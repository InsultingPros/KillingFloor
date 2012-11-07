class BucketPour extends FoundryFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.750000,Color=(B=255,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Z=(Min=0.670000,Max=2.000000))
         FadeOutStartTime=0.467500
         FadeInEndTime=0.340000
         MaxParticles=150
         DetailMode=DM_High
         SphereRadiusRange=(Max=1.000000)
         SpinsPerSecondRange=(X=(Max=0.070000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.250000)
         StartSizeRange=(X=(Min=3.000000,Max=30.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         InitialParticlesPerSecond=30.000000
         Texture=Texture'KillingFloorWeapons.FlameThrower.FlameThrowerFire'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=0.480000,Max=0.840000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-100.000000,Max=-100.000000))
         MaxAbsVelocity=(X=100.000000,Y=100.000000,Z=100.000000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.BucketPour.SpriteEmitter0'

}
