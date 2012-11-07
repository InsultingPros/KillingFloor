class KFDoorExplosionDust extends Emitter;

// THIS EFFECT FOR METALLIC DOORS ONLY!

simulated function PostBeginPlay()
{
    local PlayerController PC;
    local float dist;

    Super.PostBeginPlay();

       if ( Level.bDropDetail || (Level.DetailMode == DM_Low) || ((Level.DetailMode != DM_SuperHigh) && (Instigator != Level.GetLocalPlayerController().Pawn))
        || (VSize(Level.GetLocalPlayerController().ViewTarget.Location - Location) > 6000) )
    {
        Emitters[0].UseCollision = false;
        Emitters[0].FadeOutStartTime = 3.000000;
    }

    //

    PC = Level.GetLocalPlayerController();
    if ( PC.ViewTarget == None )
        dist = 10000;
    else
        dist = VSize(PC.ViewTarget.Location - Location);
    if ( dist > 4000 )
    {
        LightType = LT_None;
        bDynamicLight = false;
        if ( dist > 7000 )
            Emitters[1].Disabled = true;
    }
    else if ( Level.bDropDetail )
        LightRadius = 7;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=50.000000)
         ColorScale(0)=(Color=(B=150,G=150,R=150,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=100,G=100,R=100))
         Opacity=0.000000
         FadeOutStartTime=0.150000
         FadeInEndTime=0.050000
         CoordinateSystem=PTCS_Relative
         MaxParticles=20
         StartLocationRange=(Z=(Min=-19.200001,Max=76.800003))
         StartLocationShape=PTLS_Sphere
         AlphaRef=4
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=3.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=8.000000,Max=80.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=None
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=60.000000,Max=300.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
         RotateVelocityLossRange=True
     End Object
     Emitters(0)=SpriteEmitter'KFMod.KFDoorExplosionDust.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseDirectionAs=PTDU_Up
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         ScaleSizeYByVelocity=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.200000),Y=(Min=0.200000),Z=(Min=0.200000,Max=0.500000))
         ColorScale(0)=(Color=(B=200,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=190,G=220,R=242))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=200,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=200,G=255,R=255))
         MaxParticles=20
         DetailMode=DM_High
         StartLocationOffset=(Z=100.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=8.000000,Max=80.000000)
         SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=7.000000),Y=(Min=3.000000,Max=5.000000),Z=(Min=3.000000,Max=3.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.020000)
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFX.KFSparkHead'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.500000,Max=1.000000)
         StartVelocityRange=(X=(Min=-500.000000,Max=-500.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFMod.KFDoorExplosionDust.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         UseDirectionAs=PTDU_Up
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         ScaleSizeYByVelocity=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.200000),Y=(Min=0.200000),Z=(Min=0.200000,Max=0.500000))
         ColorScale(0)=(Color=(B=200,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=190,G=220,R=242))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=200,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=200,G=255,R=255))
         MaxParticles=20
         DetailMode=DM_High
         StartLocationOffset=(Z=100.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=8.000000,Max=80.000000)
         SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=7.000000),Y=(Min=3.000000,Max=5.000000),Z=(Min=3.000000,Max=3.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.020000)
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFX.KFSparkHead'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.500000,Max=1.000000)
         StartVelocityRange=(X=(Min=400.000000,Max=500.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
     End Object
     Emitters(2)=SpriteEmitter'KFMod.KFDoorExplosionDust.SpriteEmitter3'

     RemoteRole=ROLE_SimulatedProxy
     bNotOnDedServer=False
}
