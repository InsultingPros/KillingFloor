class PlantHitEmitter extends KFHitEmitter;

defaultproperties
{
     ImpactSounds(5)=SoundGroup'ProjectileSounds.Bullets.Impact_Grass'
     ImpactSounds(6)=SoundGroup'ProjectileSounds.Bullets.Impact_Grass'
     ImpactSounds(7)=SoundGroup'ProjectileSounds.Bullets.Impact_Grass'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-300.000000)
         DampingFactorRange=(X=(Min=0.000000,Max=0.800000),Y=(Min=0.000000,Max=0.800000),Z=(Min=0.000000,Max=0.400000))
         FadeOutStartTime=1.000000
         DetailMode=DM_High
         StartSpinRange=(X=(Min=1.000000))
         StartSizeRange=(X=(Min=3.000000,Max=1.000000))
         InitialParticlesPerSecond=200.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'KFMaterials.PlantBits'
         TextureUSubdivisions=3
         TextureVSubdivisions=3
         LifetimeRange=(Min=2.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=250.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         MaxAbsVelocity=(Z=300.000000)
     End Object
     Emitters(0)=SpriteEmitter'KFMod.PlantHitEmitter.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=2000.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.500000,Max=0.600000))
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=1.000000,Max=10.000000))
         InitialParticlesPerSecond=18.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'KFMaterials.NewDustSpray'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.101000,Max=0.210000)
     End Object
     Emitters(1)=SpriteEmitter'KFMod.PlantHitEmitter.SpriteEmitter1'

}
