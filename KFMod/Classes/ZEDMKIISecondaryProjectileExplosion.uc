//=============================================================================
// ZEDMKIISecondaryProjectileExplosion
//=============================================================================
// Secondary projectile explosion effect class for the ZEDGun MKII
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDMKIISecondaryProjectileExplosion extends Emitter;

var () float BurnInterval; // Interval between burn damage.
var Actor Parent;  // Parent Actor
var () int FlameDamage; // How much dmg the touchee takes.

var float ExplosionRadius;

simulated function Tick( float DeltaTime )
{
//	if( class'ROEngine.ROLevelInfo'.static.RODebugMode() )
//	{
//        DrawDebugSphere( Location, ExplosionRadius, 12, 255, 0, 0);
//    }

    super.Tick(DeltaTime);
}

static function PreInitialize( int Damage, float Interval )
{
	// You can preserve the original default values in other default variables if you want, and restore them in prebeginplay. If you want.
	default.BurnInterval = Interval;
	default.FlameDamage = Damage;
}

simulated function PostBeginPlay()
{
	SetTimer(BurnInterval,True);
}

function Timer()
{
	local Material SurfaceMat;
	local int HitSurface;
	local Vector HitLocation, HitNormal;
	local rotator EffectDir;
	local Actor Other;

	Other = Trace(HitLocation, HitNormal, Location + vector(Rotation) * 32, Location - vector(Rotation) * 16, true,, SurfaceMat);

	EffectDir = rotator(MirrorVectorByNormal(vector(Rotation), HitNormal));

	if(Vehicle(Other) != None && Other.SurfaceType == 0)
		HitSurface = 3;
	else if(Other != None && !Other.IsA('LevelInfo') && Other.SurfaceType != 0)
		HitSurface = Other.SurfaceType;
	else if(SurfaceMat != None)
		HitSurface = SurfaceMat.SurfaceType;

	if (SurfaceMat != none && Parent == none)
	{
		if (KFHumanPawn(Instigator) != none)
			Kill();
	}
	if( Parent==none || Parent.DrawScale<=0.25 )
		Kill();
}

defaultproperties
{
     BurnInterval=1.000000
     FlameDamage=10
     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'kf_generic_sm.fx.siren_scream_ball'
         UseParticleColor=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000),Z=(Min=0.100000,Max=0.100000))
         FadeOutStartTime=0.100000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=4.250000,Max=4.250000),Y=(Min=4.250000,Max=4.250000),Z=(Min=4.250000,Max=4.250000))
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_Regular
         LifetimeRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(0)=MeshEmitter'KFMod.ZEDMKIISecondaryProjectileExplosion.MeshEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter12
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.048000
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=-0.250000,Max=0.250000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.140000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=80.000000,Max=80.000000),Y=(Min=80.000000,Max=80.000000),Z=(Min=80.000000,Max=80.000000))
         InitialParticlesPerSecond=30.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFZED_FX_T.Energy.ZedGun_Energy_A'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFMod.ZEDMKIISecondaryProjectileExplosion.SpriteEmitter12'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter13
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=100.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.048000
         MaxParticles=2
         SpinsPerSecondRange=(X=(Min=-0.250000,Max=0.250000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.140000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=10.000000)
         StartSizeRange=(X=(Min=50.000000,Max=80.000000),Y=(Min=50.000000,Max=80.000000),Z=(Min=50.000000,Max=80.000000))
         InitialParticlesPerSecond=100.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFZED_FX_T.Energy.ZedGun_Energy_B'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.250000,Max=0.250000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000))
     End Object
     Emitters(2)=SpriteEmitter'KFMod.ZEDMKIISecondaryProjectileExplosion.SpriteEmitter13'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter14
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=50.000000)
         ColorScale(0)=(Color=(B=255,G=102,R=102,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=128,R=128,A=255))
         FadeOutStartTime=0.102500
         FadeInEndTime=0.050000
         MaxParticles=2
         SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
         InitialParticlesPerSecond=30.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFZED_FX_T.Energy.ZedGun_Energy_A'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
     End Object
     Emitters(3)=SpriteEmitter'KFMod.ZEDMKIISecondaryProjectileExplosion.SpriteEmitter14'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter16
         UseDirectionAs=PTDU_Up
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UseRegularSizeScale=False
         ScaleSizeYByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         DampingFactorRange=(X=(Min=0.200000),Y=(Min=0.200000),Z=(Min=0.200000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=131,G=196,R=226,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         FadeOutStartTime=0.500000
         MaxParticles=30
         DetailMode=DM_High
         UseRotationFrom=PTRS_Actor
         SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=3.000000,Max=5.000000),Z=(Min=3.000000,Max=5.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.020000)
         InitialParticlesPerSecond=200.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFX.KFSparkHead'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.700000,Max=1.000000)
         StartVelocityRange=(X=(Min=-800.000000,Max=800.000000),Y=(Min=-800.000000,Max=800.000000),Z=(Max=800.000000))
     End Object
     Emitters(4)=SpriteEmitter'KFMod.ZEDMKIISecondaryProjectileExplosion.SpriteEmitter16'

     AutoDestroy=True
     LightType=LT_Pulse
     LightHue=128
     LightSaturation=64
     LightBrightness=255.000000
     LightRadius=3.000000
     bNoDelete=False
     bDynamicLight=True
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     LifeSpan=2.000000
     Skins(0)=Shader'KFZED_FX_T.Energy.ZED_EnergyBall_Shdr'
     bGameRelevant=True
     SoundVolume=255
     SoundRadius=100.000000
}
