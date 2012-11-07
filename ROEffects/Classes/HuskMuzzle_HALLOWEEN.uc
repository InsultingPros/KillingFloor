class HuskMuzzle_HALLOWEEN extends Emitter;
	/*
defaultproperties
{
//Changed for Halloween Husk

    Begin Object Class=SpriteEmitter Name=SpriteEmitter3
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseRandomSubdivision=True
        Acceleration=(Z=50.000000)
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.667857,Color=(B=89,G=172,R=247,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
        ColorScale(4)=(RelativeTime=1.000000)
        ColorScale(5)=(RelativeTime=1.000000)
        FadeOutStartTime=0.520000
        FadeInEndTime=0.140000
        MaxParticles=8
        Name="SpriteEmitter3"
        StartLocationShape=PTLS_Sphere
        SpinsPerSecondRange=(X=(Max=0.075000))
        StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
        StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
        ScaleSizeByVelocityMax=0.000000
        InitialParticlesPerSecond=32.000000
        Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        SecondsBeforeInactive=30.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(Z=(Min=25.000000,Max=75.000000))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter3'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        Acceleration=(Z=50.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=0.102500
        FadeInEndTime=0.050000
        MaxParticles=1
        Name="SpriteEmitter4"
        SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=30.000000,Max=30.000000),Z=(Min=30.000000,Max=30.000000))
        InitialParticlesPerSecond=30.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'Effects_Tex.explosions.impact_2frame'
        TextureUSubdivisions=2
        TextureVSubdivisions=1
        LifetimeRange=(Min=0.250000,Max=0.250000)
        StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter4'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        UseDirectionAs=PTDU_Up
        UseCollision=True
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        ScaleSizeYByVelocity=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        Acceleration=(Z=-500.000000)
        DampingFactorRange=(X=(Min=0.200000),Y=(Min=0.200000),Z=(Min=0.200000,Max=0.500000))
        ColorScale(0)=(Color=(B=200,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=190,G=220,R=242))
        ColorScale(2)=(RelativeTime=0.400000,Color=(B=200,G=255,R=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(B=200,G=255,R=255))
        FadeOutStartTime=0.500000
        MaxParticles=50
        Name="SpriteEmitter5"
        DetailMode=DM_High
        SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=2.000000,Max=5.000000),Y=(Min=2.000000,Max=5.000000),Z=(Min=2.000000,Max=5.000000))
        ScaleSizeByVelocityMultiplier=(Y=0.020000)
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'KFX.KFSparkHead'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-400.000000,Max=400.000000),Z=(Min=-400.000000,Max=400.000000))
    End Object
    Emitters(2)=SpriteEmitter'SpriteEmitter5'

//    Begin Object Class=SpriteEmitter Name=SpriteEmitter39
//        FadeOut=True
//        FadeIn=True
//        RespawnDeadParticles=False
//        SpinParticles=True
//        UseSizeScale=True
//        UseRegularSizeScale=False
//        UniformSize=True
//        AutomaticInitialSpawning=False
//        UseRandomSubdivision=True
//        Acceleration=(Z=50.000000)
//        ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
//        ColorScale(2)=(RelativeTime=0.667857,Color=(B=89,G=172,R=247,A=255))
//        ColorScale(3)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
//        ColorScale(4)=(RelativeTime=1.000000)
//        ColorScale(5)=(RelativeTime=1.000000)
//        FadeOutStartTime=0.520000
//        FadeInEndTime=0.140000
//        MaxParticles=8
//        Name="SpriteEmitter39"
//        StartLocationShape=PTLS_Sphere
//        SpinsPerSecondRange=(X=(Max=0.075000))
//        StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
//        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
//        StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
//        ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
//        ScaleSizeByVelocityMax=0.000000
//        InitialParticlesPerSecond=32.000000
//        Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
//        TextureUSubdivisions=4
//        TextureVSubdivisions=4
//        SecondsBeforeInactive=30.000000
//        LifetimeRange=(Min=1.000000,Max=1.000000)
//        StartVelocityRange=(Z=(Min=25.000000,Max=75.000000))
//    End Object
//    Emitters(0)=SpriteEmitter'SpriteEmitter39'
//
//    Begin Object Class=SpriteEmitter Name=SpriteEmitter40
//        FadeOut=True
//        FadeIn=True
//        RespawnDeadParticles=False
//        UseSizeScale=True
//        UseRegularSizeScale=False
//        UniformSize=True
//        AutomaticInitialSpawning=False
//        BlendBetweenSubdivisions=True
//        Acceleration=(Z=50.000000)
//        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
//        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
//        FadeOutStartTime=0.102500
//        FadeInEndTime=0.050000
//        MaxParticles=1
//        Name="SpriteEmitter40"
//        SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
//        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
//        StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=30.000000,Max=30.000000),Z=(Min=30.000000,Max=30.000000))
//        InitialParticlesPerSecond=30.000000
//        DrawStyle=PTDS_Brighten
//        Texture=Texture'Effects_Tex.explosions.impact_2frame'
//        TextureUSubdivisions=2
//        TextureVSubdivisions=1
//        LifetimeRange=(Min=0.250000,Max=0.250000)
//        StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
//    End Object
//    Emitters(1)=SpriteEmitter'SpriteEmitter40'

    bUnlit=False
    bNoDelete=False
    bHardAttach=True
	RemoteRole=ROLE_None
	Physics=PHYS_None
	bBlockActors=False
	CullDistance=20000.0
	Style=STY_Additive
}
   */

defaultproperties
{
}
