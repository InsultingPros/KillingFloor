class CharFX_ReggieSmoke extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         Acceleration=(Z=5.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.350000
         FadeOutStartTime=0.900000
         FadeInEndTime=0.570000
         StartLocationRange=(Y=(Min=-10.000000,Max=-10.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.020000,Max=0.020000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=2.000000,Max=3.000000),Y=(Min=2.000000,Max=3.000000),Z=(Min=2.000000,Max=3.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'KF_FX_Char_T.Reggie_Smoke'
         LifetimeRange=(Min=2.000000,Max=2.500000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.CharFX_ReggieSmoke.SpriteEmitter2'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     bDirectional=True
}
