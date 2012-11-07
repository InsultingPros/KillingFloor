class HuskChargeUp_HALLOWEEN extends Emitter;
			/*
defaultproperties
{
//changed for the halloween husk firework arm canon

    Begin Object Class=SpriteEmitter Name=SpriteEmitter7
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
        MaxParticles=100
        Name="SpriteEmitter7"
        DetailMode=DM_High
        SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
        SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=2.000000,Max=5.000000),Y=(Min=2.000000,Max=5.000000),Z=(Min=2.000000,Max=5.000000))
        ScaleSizeByVelocityMultiplier=(Y=0.020000)
        InitialParticlesPerSecond=100.000000
        Texture=Texture'KFX.KFSparkHead'
        TextureUSubdivisions=1
        TextureVSubdivisions=2
        LifetimeRange=(Min=2.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=50.000000,Max=100.000000))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter7'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter8
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=15.000000)
        ColorScale(0)=(Color=(B=51,G=152,R=200))
        ColorScale(1)=(RelativeTime=0.646429,Color=(B=89,G=89,R=89))
        ColorScale(2)=(RelativeTime=1.000000)
        MaxParticles=6
        Name="SpriteEmitter8"
        StartLocationShape=PTLS_Sphere
        MeshScaleRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
        StartSizeRange=(X=(Min=10.000000,Max=15.000000),Y=(Min=10.000000,Max=15.000000),Z=(Min=10.000000,Max=15.000000))
        InitialParticlesPerSecond=6.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
        TextureUSubdivisions=8
        TextureVSubdivisions=8
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=50.000000,Max=100.000000))
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter8'




//    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
//        UseColorScale=True
//        RespawnDeadParticles=False
//        SpinParticles=True
//        UseSizeScale=True
//        UseRegularSizeScale=False
//        UniformSize=True
//        AutomaticInitialSpawning=False
//        ResetOnTrigger=True
//        ColorScale(1)=(RelativeTime=0.550000,Color=(G=128,R=255))
//        ColorScale(2)=(RelativeTime=1.000000)
//        MaxParticles=3
//        Name="SpriteEmitter0"
//        StartSpinRange=(X=(Max=1.000000))
//        SizeScale(0)=(RelativeSize=1.000000)
//        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.000000)
//        StartSizeRange=(X=(Min=7.000000,Max=7.000000))
//        InitialParticlesPerSecond=12.000000
//        Texture=Texture'kf_fx_trip_t.Misc.healingFXflare'
//        LifetimeRange=(Min=0.500000,Max=0.500000)
//        InitialDelayRange=(Min=0.250000,Max=0.250000)
//    End Object
//    Emitters(0)=SpriteEmitter'SpriteEmitter0'
//
//    Begin Object Class=BeamEmitter Name=BeamEmitter0
//        LowFrequencyNoiseRange=(X=(Min=-16.000000,Max=16.000000),Y=(Min=-16.000000,Max=16.000000),Z=(Min=-16.000000,Max=16.000000))
//        LowFrequencyPoints=4
//        HighFrequencyNoiseRange=(X=(Min=-4.000000,Max=4.000000),Y=(Min=-4.000000,Max=4.000000),Z=(Min=-4.000000,Max=4.000000))
//        HighFrequencyPoints=8
//        LFScaleFactors(0)=(FrequencyScale=(Z=100.000000),RelativeLength=1.000000)
//        HFScaleFactors(0)=(FrequencyScale=(X=50.000000,Y=50.000000,Z=50.000000))
//        UseBranching=True
//        BranchProbability=(Min=1.000000,Max=1.000000)
//        BranchSpawnAmountRange=(Min=5.000000,Max=5.000000)
//        UseColorScale=True
//        RespawnDeadParticles=False
//        UseSizeScale=True
//        UseRegularSizeScale=False
//        AutomaticInitialSpawning=False
//        ColorScale(0)=(Color=(B=128,G=255,R=255,A=255))
//        ColorScale(1)=(RelativeTime=1.000000,Color=(B=72,G=132,R=255,A=255))
//        MaxParticles=30
//        Name="BeamEmitter0"
//        StartLocationRange=(X=(Min=-18.000000,Max=18.000000),Y=(Min=-18.000000,Max=18.000000),Z=(Min=-18.000000,Max=18.000000))
//        StartLocationShape=PTLS_Sphere
//        SphereRadiusRange=(Min=32.000000,Max=32.000000)
//        SizeScale(0)=(RelativeTime=0.500000,RelativeSize=3.000000)
//        SizeScale(1)=(RelativeTime=1.000000)
//        StartSizeRange=(X=(Min=0.100000,Max=0.500000),Y=(Min=0.100000,Max=0.500000),Z=(Min=0.100000,Max=0.500000))
//        InitialParticlesPerSecond=90.000000
//        Texture=Texture'kf_fx_trip_t.Misc.healingFX'
//        LifetimeRange=(Min=0.200000,Max=0.500000)
//        StartVelocityRadialRange=(Min=300.000000,Max=300.000000)
//        GetVelocityDirectionFrom=PTVD_AddRadial
//    End Object
//    Emitters(1)=BeamEmitter'BeamEmitter0'

  	AutoDestroy=True
//    Style=STY_Masked
    bUnlit=false
    bDirectional=True
    bNoDelete=false
    RemoteRole=ROLE_None
    bNetTemporary=true
    LifeSpan = 4

}
	   */

defaultproperties
{
}
