class SPSniperTracer extends KFNewTracer;
//#exec OBJ LOAD FILE=..\Textures\AW-2004Particles.utx

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter13
         UseDirectionAs=PTDU_Right
         RespawnDeadParticles=False
         UseAbsoluteTimeForSizeScale=True
         UseRegularSizeScale=False
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         ExtentMultiplier=(X=0.200000)
         ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000))
         MaxParticles=100
         StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=3.000000,Max=3.000000))
         ScaleSizeByVelocityMultiplier=(X=0.001000)
         DrawStyle=PTDS_Brighten
         Texture=Texture'Effects_Tex_Steampunk.Steampunk_Tracer'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(Z=(Min=10000.000000,Max=10000.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.SPSniperTracer.SpriteEmitter13'

}
