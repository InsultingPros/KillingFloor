class MetalHitEmitter extends KFHitEmitter;

var     bool    bFlashed;
replication
{
    // Things the server should send to the client.
    reliable if( bNetDirty && (!bNetOwner || bDemoRecording || bRepClientDemo) && (Role==ROLE_Authority) )
        bFlashed;

}

simulated function PostBeginPlay()
{
   Super.Postbeginplay();
   SparkLight();
}

simulated function SparkLight()
{
    if ( !bFlashed && !Level.bDropDetail && (Instigator != None)
        && ((Level.TimeSeconds - LastRenderTime < 0.2) || (PlayerController(Instigator.Controller) != None)) )
    {
        bDynamicLight = true;
        SetTimer(0.15, false);
    }
    else
        Timer();
}


simulated function Timer()
{
    bDynamicLight = false;
}

defaultproperties
{
     ImpactSounds(0)=Sound'KFWeaponSound.bullethitmetal2'
     ImpactSounds(1)=Sound'KFWeaponSound.bullethitmetal3'
     ImpactSounds(2)=Sound'KFWeaponSound.bullethitmetal4'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter41
         UseDirectionAs=PTDU_UpAndNormal
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-210.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255,R=187))
         ColorScale(1)=(RelativeTime=0.214286,Color=(G=103,R=206,A=255))
         ColorScale(2)=(RelativeTime=0.439286,Color=(B=100,G=177,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(G=103,R=206,A=255))
         ColorScale(4)=(RelativeTime=1.000000,Color=(G=103,R=206,A=255))
         ColorScale(5)=(RelativeTime=1.000000,Color=(R=128,A=255))
         ColorScale(6)=(RelativeTime=1.000000)
         ColorScale(7)=(RelativeTime=1.000000)
         FadeOutStartTime=0.336000
         FadeInEndTime=0.064000
         MaxParticles=20
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=2.000000,Max=3.000000),Y=(Min=5000.000000,Max=5000.000000),Z=(Min=5000.000000,Max=5000.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000,Y=0.010000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'KFX.KFSparkHead'
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.MetalHitEmitter.SpriteEmitter41'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter42
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=10.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.250000,Max=0.350000),Y=(Min=0.250000,Max=0.300000),Z=(Min=0.200000,Max=0.250000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         MaxParticles=3
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=None
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.000000,Max=0.000000)
         StartVelocityRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFMod.MetalHitEmitter.SpriteEmitter42'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter43
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.900000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.500000,Max=0.600000))
         MaxParticles=1
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=6.000000,Max=6.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFX.MetalHitKF'
         LifetimeRange=(Min=0.010000,Max=0.100000)
     End Object
     Emitters(2)=SpriteEmitter'KFMod.MetalHitEmitter.SpriteEmitter43'

     LightType=LT_Steady
     LightHue=40
     LightSaturation=150
     LightBrightness=100.000000
     LightRadius=3.000000
}
