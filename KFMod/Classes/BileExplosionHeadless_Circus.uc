 class BileExplosionHeadless_Circus extends FleshHitEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter136
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-500.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=0.200000
        MaxParticles=2
        Name="SpriteEmitter136"
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
        InitialParticlesPerSecond=1000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'kf_fx_trip_t.Gore.bloat_explode_blood'
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=150.000000,Max=300.000000))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter136'

    Begin Object Class=MeshEmitter Name=MeshEmitter38
        StaticMesh=StaticMesh'kf_gore_trip_sm_CIRCUS.limbs.bloat_clown_Arm_Gore'
        UseCollision=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.500000),Y=(Min=0.200000,Max=0.500000),Z=(Min=0.200000,Max=0.500000))
        MaxCollisions=(Max=2.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=1
        Name="MeshEmitter38"
        StartLocationRange=(Z=(Min=10.000000,Max=64.000000))
        SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSizeRange=(X=(Min=1.150000,Max=1.150000),Y=(Min=1.150000,Max=1.150000),Z=(Min=1.150000,Max=1.150000))
        InitialParticlesPerSecond=1000.000000
        LifetimeRange=(Min=10.000000,Max=10.000000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=250.000000,Max=500.000000))
    End Object
    Emitters(1)=MeshEmitter'MeshEmitter38'

    Begin Object Class=MeshEmitter Name=MeshEmitter39
        StaticMesh=StaticMesh'EffectsSM.PlayerGibbs.Chunk1_Gibb'
        UseCollision=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.500000),Y=(Min=0.200000,Max=0.500000),Z=(Min=0.200000,Max=0.500000))
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=30
        Name="MeshEmitter39"
        SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSizeRange=(X=(Min=0.500000,Max=2.000000),Y=(Min=0.500000,Max=2.000000),Z=(Min=0.500000,Max=2.000000))
        InitialParticlesPerSecond=1000.000000
        LifetimeRange=(Min=10.000000,Max=10.000000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=1000.000000))
        VelocityLossRange=(Z=(Min=1.000000,Max=1.000000))
    End Object
    Emitters(2)=MeshEmitter'MeshEmitter39'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter137
        RespawnDeadParticles=False
        SpawnOnlyInDirectionOfNormal=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        ScaleSizeYByVelocity=True
        ScaleSizeZByVelocity=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        Acceleration=(Z=-200.000000)
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.750000,Color=(B=96,G=160,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        FadeOutStartTime=1.000000
        MaxParticles=8
        Name="SpriteEmitter137"
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=5.000000)
        StartMassRange=(Min=11.000000,Max=11.000000)
        UseRotationFrom=PTRS_Normal
        SpinsPerSecondRange=(X=(Min=-0.300000,Max=0.300000))
        StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.500000)
        StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
        ScaleSizeByVelocityMax=3.000000
        InitialParticlesPerSecond=500.000000
        DrawStyle=PTDS_Modulated
        Texture=Texture'kf_fx_trip_t.Gore.kf_bloodspray_b_diff'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=100.000000,Max=100.000000))
    End Object
    Emitters(3)=SpriteEmitter'SpriteEmitter137'

    Begin Object Class=MeshEmitter Name=MeshEmitter40
        StaticMesh=StaticMesh'kf_gore_trip_sm_CIRCUS.limbs.bloat_clown_Arm_Gore'
        UseCollision=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.500000),Y=(Min=0.200000,Max=0.500000),Z=(Min=0.200000,Max=0.500000))
        MaxCollisions=(Max=2.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=1
        Name="MeshEmitter40"
        StartLocationRange=(X=(Min=-16.000000,Max=16.000000),Y=(Min=-16.000000,Max=16.000000),Z=(Min=12.000000,Max=64.000000))
        SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSizeRange=(X=(Min=1.150000,Max=1.150000),Y=(Min=1.150000,Max=1.150000),Z=(Min=1.150000,Max=1.150000))
        InitialParticlesPerSecond=1000.000000
        LifetimeRange=(Min=10.000000,Max=10.000000)
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=250.000000,Max=500.000000))
    End Object
    Emitters(4)=MeshEmitter'MeshEmitter40'

    Begin Object Class=MeshEmitter Name=MeshEmitter42
        StaticMesh=StaticMesh'kf_gore_trip_sm.gibbs.intestines'
        UseCollision=True
        RespawnDeadParticles=False
        SpinParticles=True
        DampRotation=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-1000.000000)
        DampingFactorRange=(X=(Min=0.200000,Max=0.500000),Y=(Min=0.200000,Max=0.500000),Z=(Min=0.200000,Max=0.500000))
        MaxCollisions=(Max=2.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        MaxParticles=1
        Name="MeshEmitter42"
        SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        InitialParticlesPerSecond=1000.000000
        DrawStyle=PTDS_Regular
        StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=250.000000,Max=500.000000))
    End Object
    Emitters(5)=MeshEmitter'MeshEmitter42'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter138
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.750000,Color=(B=255,G=255,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        FadeOutStartTime=0.850000
        MaxParticles=30
        Name="SpriteEmitter138"
        AddLocationFromOtherEmitter=1
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=1.000000)
        SpinsPerSecondRange=(X=(Max=0.070000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.250000)
        StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
        ScaleSizeByVelocityMax=0.000000
        InitialParticlesPerSecond=30.000000
        DrawStyle=PTDS_Modulated
        Texture=Texture'kf_fx_trip_t.Gore.kf_bloodspray_e_diff'
        TextureUSubdivisions=8
        TextureVSubdivisions=4
        SecondsBeforeInactive=30.000000
        LifetimeRange=(Min=0.450000,Max=0.850000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=2.000000,Max=25.000000))
        MaxAbsVelocity=(X=100.000000,Y=100.000000,Z=100.000000)
    End Object
    Emitters(6)=SpriteEmitter'SpriteEmitter138'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter139
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.750000,Color=(B=255,G=255,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        FadeOutStartTime=0.850000
        MaxParticles=60
        Name="SpriteEmitter139"
        AddLocationFromOtherEmitter=2
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=1.000000)
        SpinsPerSecondRange=(X=(Max=0.070000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.250000)
        StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
        ScaleSizeByVelocityMax=0.000000
        InitialParticlesPerSecond=60.000000
        DrawStyle=PTDS_Modulated
        Texture=Texture'kf_fx_trip_t.Gore.kf_bloodspray_e_diff'
        TextureUSubdivisions=8
        TextureVSubdivisions=4
        SecondsBeforeInactive=30.000000
        LifetimeRange=(Min=0.450000,Max=0.850000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=2.000000,Max=25.000000))
        MaxAbsVelocity=(X=100.000000,Y=100.000000,Z=100.000000)
    End Object
    Emitters(7)=SpriteEmitter'SpriteEmitter139'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter140
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.750000,Color=(B=255,G=255,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        FadeOutStartTime=0.850000
        MaxParticles=30
        Name="SpriteEmitter140"
        AddLocationFromOtherEmitter=4
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=1.000000)
        SpinsPerSecondRange=(X=(Max=0.070000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.250000)
        StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
        ScaleSizeByVelocityMax=0.000000
        InitialParticlesPerSecond=30.000000
        DrawStyle=PTDS_Modulated
        Texture=Texture'kf_fx_trip_t.Gore.kf_bloodspray_e_diff'
        TextureUSubdivisions=8
        TextureVSubdivisions=4
        SecondsBeforeInactive=30.000000
        LifetimeRange=(Min=0.450000,Max=0.850000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=2.000000,Max=25.000000))
        MaxAbsVelocity=(X=100.000000,Y=100.000000,Z=100.000000)
    End Object
    Emitters(8)=SpriteEmitter'SpriteEmitter140'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter141
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
        ColorScale(2)=(RelativeTime=0.750000,Color=(B=255,G=255,R=255))
        ColorScale(3)=(RelativeTime=1.000000)
        FadeOutStartTime=0.850000
        MaxParticles=30
        Name="SpriteEmitter141"
        AddLocationFromOtherEmitter=5
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Max=1.000000)
        SpinsPerSecondRange=(X=(Max=0.070000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.250000)
        StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
        ScaleSizeByVelocityMax=0.000000
        InitialParticlesPerSecond=30.000000
        DrawStyle=PTDS_Modulated
        Texture=Texture'kf_fx_trip_t.Gore.kf_bloodspray_e_diff'
        TextureUSubdivisions=8
        TextureVSubdivisions=4
        SecondsBeforeInactive=30.000000
        LifetimeRange=(Min=0.450000,Max=0.850000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=2.000000,Max=25.000000))
        MaxAbsVelocity=(X=100.000000,Y=100.000000,Z=100.000000)
    End Object
    Emitters(9)=SpriteEmitter'SpriteEmitter141'

	AutoDestroy=True
//    Style=STY_Masked
    bUnlit=false
    bDirectional=True
    bNoDelete=false
    RemoteRole=ROLE_None
    bNetTemporary=true
    LifeSpan = 10
}

