class KFDoorExplosionDustWood extends Emitter;

#exec OBJ LOAD FILE=..\Sounds\WoodBreakFX.uax

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseDirectionAs=PTDU_Up
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=-900.000000)
         DampingFactorRange=(X=(Min=0.200000),Y=(Min=0.200000),Z=(Min=0.200000,Max=0.500000))
         ColorScale(0)=(Color=(B=200,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(B=190,G=220,R=242))
         ColorScale(2)=(RelativeTime=0.400000,Color=(B=200,G=255,R=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=200,G=255,R=255))
         MaxParticles=25
         DetailMode=DM_High
         StartLocationOffset=(Z=10.000000)
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=20.000000)
         SpinsPerSecondRange=(X=(Min=-5.000000,Max=5.000000))
         StartSpinRange=(X=(Min=1.000000,Max=1.000000))
         SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.020000)
         Sounds(0)=(Sound=Sound'WoodBreakFX.WoodBreak1',Radius=(Min=512.000000,Max=512.000000),Pitch=(Min=1.000000,Max=1.500000),Volume=(Min=2.000000,Max=2.000000),Probability=(Min=0.200000,Max=0.200000))
         Sounds(1)=(Sound=Sound'WoodBreakFX.WoodBreak2',Radius=(Min=512.000000,Max=512.000000),Pitch=(Min=1.000000,Max=1.500000),Volume=(Min=2.000000,Max=2.000000),Probability=(Min=0.200000,Max=0.200000))
         Sounds(2)=(Sound=Sound'WoodBreakFX.WoodBreak3',Radius=(Min=512.000000,Max=512.000000),Pitch=(Min=1.000000,Max=1.500000),Volume=(Min=2.000000,Max=2.000000),Probability=(Min=0.200000,Max=0.200000))
         Sounds(3)=(Sound=Sound'WoodBreakFX.WoodBreak4',Radius=(Min=512.000000,Max=512.000000),Pitch=(Min=1.000000,Max=1.500000),Volume=(Min=2.000000,Max=2.000000),Probability=(Min=0.200000,Max=0.200000))
         SpawningSound=PTSC_LinearLocal
         SpawningSoundProbability=(Min=1.000000,Max=1.000000)
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'KFMaterials.WoodChips'
         TextureUSubdivisions=3
         TextureVSubdivisions=3
         LifetimeRange=(Min=0.500000,Max=1.000000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=500.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.KFDoorExplosionDustWood.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
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
         Acceleration=(Z=150.000000)
         ColorScale(0)=(Color=(B=50,G=60,R=80))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=30,G=30,R=40))
         Opacity=0.000000
         FadeOutStartTime=0.180000
         FadeInEndTime=0.040000
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartLocationRange=(Z=(Min=-19.200001,Max=76.800003))
         StartLocationShape=PTLS_Sphere
         AlphaRef=4
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=40.000000,Max=80.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'KFPatch2.WoodDust'
         LifetimeRange=(Min=0.251000,Max=0.501000)
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Max=600.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
         RotateVelocityLossRange=True
     End Object
     Emitters(1)=SpriteEmitter'KFMod.KFDoorExplosionDustWood.SpriteEmitter0'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'PatchStatics.WDoorGib1'
         UseParticleColor=True
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.620000
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=20.000000)
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.100000,Max=0.200000),Y=(Min=0.100000,Max=0.200000),Z=(Min=0.100000,Max=0.200000))
         Sounds(0)=(Sound=Sound'PatchSounds.WoodImpact4',Radius=(Min=100.000000,Max=100.000000),Pitch=(Min=-2.000000,Max=1.000000),Weight=5,Volume=(Min=1.000000,Max=1.000000),Probability=(Min=1.000000,Max=1.000000))
         CollisionSound=PTSC_Random
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=100.000000,Max=250.000000))
     End Object
     Emitters(2)=MeshEmitter'KFMod.KFDoorExplosionDustWood.MeshEmitter1'

     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'PatchStatics.WDoorGib4'
         UseParticleColor=True
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-300.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.580000
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=10.000000,Max=20.000000)
         SpinsPerSecondRange=(X=(Min=0.400000,Max=1.000000),Y=(Max=0.600000))
         StartSizeRange=(X=(Min=0.250000,Max=0.400000),Y=(Min=0.250000,Max=0.400000),Z=(Min=0.250000,Max=0.400000))
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=1.000000,Max=1.500000)
         StartVelocityRange=(X=(Min=-700.000000,Max=700.000000),Y=(Min=-700.000000,Max=700.000000),Z=(Max=200.000000))
     End Object
     Emitters(3)=MeshEmitter'KFMod.KFDoorExplosionDustWood.MeshEmitter0'

     RemoteRole=ROLE_SimulatedProxy
     bNotOnDedServer=False
}
