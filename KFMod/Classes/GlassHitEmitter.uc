class GlassHitEmitter extends KFHitEmitter;
             #exec OBJ LOAD FILE=KFWeaponSound.uax

defaultproperties
{
     ImpactSounds(0)=Sound'KFWeaponSound.bullethitglass'
     ImpactSounds(1)=Sound'KFWeaponSound.bullethitglass2'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-500.000000)
         DampingFactorRange=(X=(Min=0.000000,Max=0.800000),Y=(Min=0.000000,Max=0.800000),Z=(Min=0.000000,Max=0.400000))
         FadeOutStartTime=1.000000
         MaxParticles=5
         DetailMode=DM_High
         StartSpinRange=(X=(Min=1.000000))
         StartSizeRange=(X=(Min=3.000000,Max=1.000000))
         InitialParticlesPerSecond=200.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFMaterials.GlassChips'
         TextureUSubdivisions=3
         TextureVSubdivisions=3
         LifetimeRange=(Min=2.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=300.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         MaxAbsVelocity=(Z=500.000000)
     End Object
     Emitters(0)=SpriteEmitter'KFMod.GlassHitEmitter.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=10.000000)
         ColorMultiplierRange=(X=(Min=0.250000,Max=0.350000),Y=(Min=0.250000,Max=0.350000),Z=(Min=0.250000,Max=0.350000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
         TextureUSubdivisions=8
         TextureVSubdivisions=8
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFMod.GlassHitEmitter.SpriteEmitter1'

}
