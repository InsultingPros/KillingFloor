class MuzzleFlash3rdZEDGunPrimary extends ROMuzzleFlash3rd;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
	Emitters[0].SpawnParticle(2);
	Emitters[1].SpawnParticle(1);
	Emitters[2].SpawnParticle(5);
	Emitters[3].SpawnParticle(5);
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.500000
         CoordinateSystem=PTCS_Relative
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=3.000000)
         SizeScale(2)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=8.000000,Max=12.000000))
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFZED_FX_T.Energy.ZedGun_Energy_A'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SubdivisionScale(0)=0.500000
         LifetimeRange=(Min=0.115000,Max=0.115000)
     End Object
     Emitters(0)=SpriteEmitter'KFMod.MuzzleFlash3rdZEDGunPrimary.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=224,G=171,R=71,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=224,G=171,R=71,A=255))
         Opacity=0.100000
         MaxParticles=1
         StartSizeRange=(X=(Min=65.000000,Max=65.000000))
         Texture=Texture'Effects_Tex.Smoke.MuzzleCorona1stP'
         LifetimeRange=(Min=0.350000,Max=0.350000)
     End Object
     Emitters(1)=SpriteEmitter'KFMod.MuzzleFlash3rdZEDGunPrimary.SpriteEmitter9'

     Begin Object Class=SparkEmitter Name=SparkEmitter0
         LineSegmentsRange=(Min=0.000000,Max=0.000000)
         TimeBetweenSegmentsRange=(Min=0.100000,Max=0.100000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=224,G=171,R=71,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=224,G=171,R=71,A=255))
         FadeOutStartTime=0.250000
         FadeInEndTime=0.250000
         MaxParticles=4
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         Texture=Texture'Effects_Tex.BulletHits.sparkfinal2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=100.000000,Max=250.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
     End Object
     Emitters(2)=SparkEmitter'KFMod.MuzzleFlash3rdZEDGunPrimary.SparkEmitter0'

     Begin Object Class=SparkEmitter Name=SparkEmitter1
         LineSegmentsRange=(Min=0.000000,Max=0.000000)
         TimeBetweenSegmentsRange=(Min=0.100000,Max=0.100000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=224,G=171,R=71,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=224,G=171,R=71,A=255))
         FadeOutStartTime=0.250000
         FadeInEndTime=0.250000
         MaxParticles=2
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         Texture=Texture'Effects_Tex.BulletHits.sparkfinal2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=200.000000,Max=350.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
     End Object
     Emitters(3)=SparkEmitter'KFMod.MuzzleFlash3rdZEDGunPrimary.SparkEmitter1'

}
