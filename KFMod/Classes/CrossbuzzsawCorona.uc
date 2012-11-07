//=============================================================================
// Corona for buzzsaw
//=============================================================================
class CrossbuzzsawCorona extends emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         UniformSize=True
         ColorScale(0)=(Color=(B=56,G=136,R=142,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=56,G=136,R=142,A=255))
         Opacity=0.330000
         FadeOutStartTime=10.000000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSizeRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=1.000000
         Texture=Texture'Waterworks_T.General.glow_dam01'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         WarmupTicksPerSecond=1.000000
         RelativeWarmupTime=30.000000
     End Object
     Emitters(0)=SpriteEmitter'KFMod.CrossbuzzsawCorona.SpriteEmitter0'

     bNoDelete=False
     bNetTemporary=True
     Physics=PHYS_Trailer
}
