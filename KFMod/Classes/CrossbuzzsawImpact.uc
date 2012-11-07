//--------------------------------------------------------------
//
//--------------------------------------------------------------
class CrossbuzzsawImpact extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Right
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-400.000000)
         ColorScale(0)=(Color=(B=155,G=220,R=255))
         ColorScale(1)=(RelativeTime=0.600000,Color=(B=13,G=69,R=202))
         ColorScale(2)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Z=(Min=0.800000))
         FadeOutStartTime=0.200000
         FadeInEndTime=0.010000
         MaxParticles=20
         StartLocationOffset=(X=7.000000)
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=4.000000,Max=6.000000),Y=(Min=0.500000,Max=1.500000))
         ScaleSizeByVelocityMultiplier=(X=0.007000)
         InitialParticlesPerSecond=2000.000000
         Texture=Texture'KFX.KFSparkHead'
         LifetimeRange=(Min=0.700000,Max=1.200000)
         StartVelocityRange=(X=(Min=300.000000,Max=1000.000000),Y=(Min=-800.000000,Max=800.000000),Z=(Min=-800.000000,Max=800.000000))
         VelocityLossRange=(X=(Min=4.000000,Max=8.000000),Y=(Min=5.000000,Max=8.000000),Z=(Min=5.000000,Max=8.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.CrossbuzzsawImpact.SpriteEmitter0'

     AutoDestroy=True
     CullDistance=6000.000000
     bNoDelete=False
}
