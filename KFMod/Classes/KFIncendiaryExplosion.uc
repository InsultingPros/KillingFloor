class KFIncendiaryExplosion extends KFNadeExplosion;

simulated function NadeLight()
{
    if ( !bFlashed && !Level.bDropDetail && (Instigator != None)
        && ((Level.TimeSeconds - LastRenderTime < 0.2) || (PlayerController(Instigator.Controller) != None)) )
    {
        bDynamicLight = true;
        SetTimer(0.6, false);
    }
    else
        Timer();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         Acceleration=(Z=100.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         MaxParticles=50
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=-5.000000)
         StartSizeRange=(X=(Min=6.000000,Max=60.000000),Y=(Min=6.000000,Max=60.000000),Z=(Min=6.000000,Max=60.000000))
         Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.801000,Max=1.000000)
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Max=100.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.KFIncendiaryExplosion.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         BlendBetweenSubdivisions=True
         Acceleration=(Z=-200.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=100.000000)
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSizeRange=(X=(Min=70.000000,Max=80.000000),Y=(Min=70.000000,Max=80.000000),Z=(Min=70.000000,Max=80.000000))
         Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.401000,Max=0.550100)
         StartVelocityRange=(Z=(Min=100.000000,Max=1000.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFMod.KFIncendiaryExplosion.SpriteEmitter2'

     Emitters(2)=None

     Emitters(3)=None

     Emitters(4)=None

     LightType=LT_Flicker
     LightSaturation=50
     LightBrightness=1000.000000
     LightRadius=15.000000
}
