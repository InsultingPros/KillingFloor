// The fire that gets spawned when a Fuel puddle is shot. This damages pawns and then dissipates.
class FlameImpact_HALLOWEEN extends Emitter;

var () float BurnInterval; // Interval between burn damage.
var Actor Parent;  // Parent Actor
var () int FlameDamage; // How much dmg the touchee takes.

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
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Up
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=51,G=152,R=200))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=48,G=91,R=222))
         ColorScale(2)=(RelativeTime=1.000000)
         MaxParticles=6
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=48.000000,Max=48.000000)
         MeshScaleRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=10.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
         TextureUSubdivisions=8
         TextureVSubdivisions=8
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.700000,Max=1.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=25.000000,Max=50.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.FlameImpact_HALLOWEEN.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=150.000000)
         ColorScale(0)=(Color=(G=255,R=255,A=128))
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=47,G=80,R=179,A=255))
         ColorScale(2)=(RelativeTime=0.600000,Color=(A=80))
         ColorScale(3)=(RelativeTime=1.000000)
         MaxParticles=6
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=20.000000,Max=20.000000)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=20.000000,Max=40.000000),Y=(Min=20.000000,Max=40.000000))
         InitialParticlesPerSecond=800.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
         TextureUSubdivisions=8
         TextureVSubdivisions=8
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFMod.FlameImpact_HALLOWEEN.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         Acceleration=(Z=50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.102500
         FadeInEndTime=0.050000
         MaxParticles=2
         SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
         InitialParticlesPerSecond=30.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'Effects_Tex.explosions.impact_2frame'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
     End Object
     Emitters(2)=SpriteEmitter'KFMod.FlameImpact_HALLOWEEN.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=True
         Acceleration=(Z=100.000000)
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.667857,Color=(B=89,G=172,R=247,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(4)=(RelativeTime=1.000000)
         ColorScale(5)=(RelativeTime=1.000000)
         FadeOutStartTime=0.520000
         FadeInEndTime=0.140000
         MaxParticles=8
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Max=0.075000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
         StartSizeRange=(X=(Min=70.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=25.000000,Max=75.000000))
     End Object
     Emitters(3)=SpriteEmitter'KFMod.FlameImpact_HALLOWEEN.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=125.000000)
         ColorScale(1)=(RelativeTime=0.300000,Color=(B=255,G=255,R=255))
         ColorScale(2)=(RelativeTime=0.667857,Color=(B=89,G=172,R=247,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         ColorScale(4)=(RelativeTime=1.000000)
         ColorScale(5)=(RelativeTime=1.000000)
         FadeOutStartTime=0.200000
         FadeInEndTime=0.140000
         MaxParticles=3
         StartLocationRange=(Z=(Min=50.000000,Max=50.000000))
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=70.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(Z=(Min=75.000000,Max=75.000000))
     End Object
     Emitters(4)=SpriteEmitter'KFMod.FlameImpact_HALLOWEEN.SpriteEmitter5'

     Begin Object Class=SparkEmitter Name=SparkEmitter2
         LineSegmentsRange=(Min=0.000000,Max=0.000000)
         TimeBetweenSegmentsRange=(Min=0.100000,Max=0.100000)
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.250000
         FadeInEndTime=0.250000
         MaxParticles=50
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=1.000000)
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'Effects_Tex.BulletHits.sparkfinal2'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Max=500.000000))
     End Object
     Emitters(5)=SparkEmitter'KFMod.FlameImpact_HALLOWEEN.SparkEmitter2'

     LightType=LT_Pulse
     LightHue=30
     LightSaturation=100
     LightBrightness=300.000000
     LightRadius=4.000000
     bNoDelete=False
     bDynamicLight=True
     AmbientSound=Sound'Amb_Destruction.Fire.Kessel_Fire_Small_Vehicle'
     LifeSpan=6.000000
     SoundVolume=255
     SoundRadius=100.000000
}
