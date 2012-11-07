class BreakWindowGlassEmitter extends KFHitEmitter;
             #exec OBJ LOAD FILE=KFWeaponSound.uax

defaultproperties
{
     ImpactSounds(0)=Sound'KFWeaponSound.bullethitglass'
     ImpactSounds(1)=Sound'KFWeaponSound.bullethitglass2'
     Begin Object Class=SpriteEmitter Name=GlassExplosionEmitter
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.000000,Max=0.800000),Y=(Min=0.000000,Max=0.800000),Z=(Min=0.000000,Max=0.400000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=1.000000
         MaxParticles=20
         DetailMode=DM_High
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Min=1.000000))
         StartSizeRange=(X=(Min=5.000000,Max=7.000000))
         InitialParticlesPerSecond=200.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'KFMaterials.GlassChips'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=2.000000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         MaxAbsVelocity=(Z=500.000000)
     End Object
     Emitters(0)=SpriteEmitter'KFMod.BreakWindowGlassEmitter.GlassExplosionEmitter'

}
