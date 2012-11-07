// Less ugly than the UT2k4 one, anyway :)
class KFMonsterFlame extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         Acceleration=(Z=100.000000)
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.667857,Color=(B=89,G=172,R=247,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(4)=(RelativeTime=1.000000)
         ColorScale(5)=(RelativeTime=1.000000)
         FadeOutStartTime=0.520000
         FadeInEndTime=0.140000
         MaxParticles=8
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Max=0.075000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=15.000000,Max=28.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=10.000000,Max=50.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.KFMonsterFlame.SpriteEmitter2'

     LightType=LT_Flicker
     LightHue=30
     LightSaturation=100
     LightBrightness=300.000000
     LightRadius=4.000000
     bNoDelete=False
     bDynamicLight=True
     bOnlyDrawIfAttached=True
     AmbientSound=Sound'KF_FlamethrowerSnd.SetFire.FT_SetFire_Self'
     bFullVolume=True
     SoundVolume=255
     bNotOnDedServer=False
}
