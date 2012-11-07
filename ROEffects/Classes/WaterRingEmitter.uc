//=============================================================================
// WaterRingEmitter
//=============================================================================
// bullet hitting water effect
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// Created by - David Hensely
// Coded in by - John "Ramm-Jaeger" Gibson
// Based off of the old XGame.WaterRing emitter
//=============================================================================

class WaterRingEmitter extends Emitter;

function PostBeginPlay()
{
	local float F;
	Super.PostBeginPlay();

	if ( Instigator != None )
	{
		F = (70 + 30*FRand()) * sqrt(Instigator.CollisionRadius/25);
		Emitters[0].StartSizeRange.X.Min = F;
		Emitters[0].StartSizeRange.X.Max = F;
		Emitters[0].StartSizeRange.Y.Min = F;
		Emitters[0].StartSizeRange.Y.Max = F;
		Emitters[0].StartSizeRange.Z.Min = F;
		Emitters[0].StartSizeRange.Z.Max = F;
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1.000000,Z=0.000000)
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.500000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000),Y=(Min=15.000000,Max=20.000000),Z=(Min=15.000000,Max=20.000000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'Effects_Tex.BulletHits.waterring_2frame'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         SubdivisionScale(0)=0.500000
         LifetimeRange=(Min=1.000000,Max=1.500000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.WaterRingEmitter.SpriteEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bHighDetail=True
}
