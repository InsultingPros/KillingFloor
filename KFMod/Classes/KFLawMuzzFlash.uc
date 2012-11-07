class KFLawMuzzFlash extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=LAWMuzzFlashEmitter
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.037500
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartLocationOffset=(X=8.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Max=0.500000))
         StartSizeRange=(X=(Min=25.000000,Max=35.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'PatchTex.Common.1PMuzzFlashSkin'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=SpriteEmitter'KFMod.KFLawMuzzFlash.LAWMuzzFlashEmitter'

     bNoDelete=False
     bHardAttach=True
}
