class CharFX_Smoke extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ColorScale(0)=(Color=(B=192,G=192,R=192,A=128))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=192,G=192,R=192,A=128))
         ColorMultiplierRange=(X=(Min=0.720000,Max=0.720000),Y=(Min=0.720000,Max=0.720000),Z=(Min=0.720000,Max=0.720000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.500000
         MaxParticles=15
         StartLocationRange=(X=(Min=-4.000000,Max=4.000000),Y=(Max=20.000000),Z=(Min=-4.000000,Max=4.000000))
         MeshScaleRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=15.000000,Max=25.000000),Y=(Min=15.000000,Max=25.000000),Z=(Min=15.000000,Max=25.000000))
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
         TextureUSubdivisions=8
         TextureVSubdivisions=8
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.400000,Max=2.000000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.CharFX_Smoke.SpriteEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     bDirectional=True
}
