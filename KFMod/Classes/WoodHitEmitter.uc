class WoodHitEmitter extends KFHitEmitter;

defaultproperties
{
     ImpactSounds(0)=Sound'KFWeaponSound.bullethitwood'
     ImpactSounds(1)=Sound'KFWeaponSound.bullethitwood2'
     ImpactSounds(2)=Sound'KFWeaponSound.WoodImpact'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-400.000000)
         DampingFactorRange=(X=(Min=0.000000,Max=0.800000),Y=(Min=0.000000,Max=0.800000),Z=(Min=0.000000,Max=0.400000))
         FadeOutStartTime=1.000000
         MaxParticles=5
         DetailMode=DM_High
         StartSpinRange=(X=(Min=1.000000))
         StartSizeRange=(X=(Min=3.000000,Max=1.000000))
         InitialParticlesPerSecond=200.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'KFMaterials.WoodChips'
         TextureUSubdivisions=3
         TextureVSubdivisions=3
         LifetimeRange=(Min=2.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=300.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         MaxAbsVelocity=(Z=400.000000)
     End Object
     Emitters(0)=SpriteEmitter'KFMod.WoodHitEmitter.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=DustSpray
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=22,G=137,R=241))
         ColorScale(1)=(RelativeTime=0.300000,Color=(G=64,R=192))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.500000
         MaxParticles=3
         DetailMode=DM_High
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=8.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=150.000000,Max=150.000000))
         InitialParticlesPerSecond=500.000000
         Texture=None
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(1)=SpriteEmitter'KFMod.WoodHitEmitter.DustSpray'

}
