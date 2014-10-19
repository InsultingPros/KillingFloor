class Emitter_CoinExplosion extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'KF_Swansong_SM.Lootbag.Coin'
         UseParticleColor=True
         UseCollision=True
         UseMaxCollisions=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-215.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         MaxCollisions=(Min=7.000000,Max=7.000000)
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=255,R=255))
         FadeOutStartTime=1.000000
         MaxParticles=30
         StartLocationRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Max=10.000000))
         UseRotationFrom=PTRS_Normal
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.800000),Y=(Min=0.200000,Max=0.800000),Z=(Min=0.200000,Max=0.800000))
         StartSpinRange=(X=(Max=16000.000000),Y=(Max=16000.000000),Z=(Max=16000.000000))
         RotationDampingFactorRange=(X=(Min=0.250000,Max=0.500000),Y=(Min=0.250000,Max=0.500000),Z=(Min=0.250000,Max=0.500000))
         StartSizeRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.600000,Max=0.600000))
         InitialParticlesPerSecond=10000.000000
         StartVelocityRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=50.000000,Max=150.000000))
     End Object
     Emitters(0)=MeshEmitter'KFStoryGame.Emitter_CoinExplosion.MeshEmitter0'

     bNoDelete=False
     DrawScale=0.500000
     AmbientGlow=48
     bUnlit=False
}
