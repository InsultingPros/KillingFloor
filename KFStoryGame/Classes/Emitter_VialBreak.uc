class Emitter_VialBreak extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter75
         FadeOut=True
         RespawnDeadParticles=False
         UseRevolution=True
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-150.000000)
         FadeOutStartTime=1.000000
         MaxParticles=6
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=5.000000,Max=10.000000))
         SpinsPerSecondRange=(X=(Min=0.100000,Max=0.500000),Y=(Min=0.100000,Max=0.500000))
         StartSpinRange=(X=(Max=16000.000000),Y=(Max=16000.000000),Z=(Max=16000.000000))
         StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=5.000000,Max=10.000000))
         InitialParticlesPerSecond=1000.000000
         Texture=Texture'Effects_Tex.BulletHits.brokenglass_chunks_01'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=45.000000,Max=55.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFStoryGame.Emitter_VialBreak.SpriteEmitter75'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter76
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-100.000000)
         FadeOutStartTime=1.000000
         MaxParticles=5
         StartLocationRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-10.000000))
         UseRotationFrom=PTRS_Normal
         StartSpinRange=(X=(Max=16000.000000),Y=(Max=16000.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=10.000000)
         StartSizeRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=5.000000,Max=5.000000))
         InitialParticlesPerSecond=10000.000000
         DrawStyle=PTDS_Modulated
         Texture=Texture'kf_fx_trip_t.Misc.Vomit_Splat_E'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=15.000000,Max=25.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFStoryGame.Emitter_VialBreak.SpriteEmitter76'

     bNoDelete=False
}
