class KFShellEjectBenelli extends KFShellEject;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
	Emitters[0].SpawnParticle(1);
	Emitters[1].SpawnParticle(3);
}

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'kf_generic_sm.Bullet_Shells.12Guage_Shell'
         RespawnDeadParticles=False
         ZTest=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         MaxParticles=50
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         StartSizeRange=(X=(Min=3.250000,Max=3.250000),Y=(Min=3.250000,Max=3.250000),Z=(Min=3.250000,Max=3.250000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(Y=(Min=150.000000,Max=200.000000),Z=(Min=25.000000,Max=75.000000))
     End Object
     Emitters(0)=MeshEmitter'ROEffects.KFShellEjectBenelli.MeshEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Up
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
         MaxParticles=50
         StartLocationRange=(Y=(Min=10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ScaleSizeByVelocityMultiplier=(X=0.010000,Y=0.010000)
         Texture=Texture'KFX.KFSparkHead'
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(Y=(Min=100.000000,Max=150.000000),Z=(Min=50.000000,Max=100.000000))
     End Object
     Emitters(1)=SpriteEmitter'ROEffects.KFShellEjectBenelli.SpriteEmitter0'

}
