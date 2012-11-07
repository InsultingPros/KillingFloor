//===================================================================
// ROBreakingGlass
//
// Copyright (C) 2004 John "Ramm-Jaeger"  Gibson
//
// Breaking Glass effect
//===================================================================

class ROBreakingGlass extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_UpAndNormal
         UseCollision=True
         UseMaxCollisions=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-500.000000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.200000,Max=0.400000))
         MaxCollisions=(Min=1.000000,Max=3.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.750000
         DetailMode=DM_High
         StartLocationRange=(Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.500000,Max=1.000000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=2.000000,Max=5.000000))
         InitialParticlesPerSecond=10000.000000
         Texture=Texture'Effects_Tex.BulletHits.brokenglass_chunks_01'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.800000,Max=1.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.ROBreakingGlass.SpriteEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bHighDetail=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     SurfaceType=EST_Glass
     Style=STY_Masked
     bHardAttach=True
     bDirectional=True
}
