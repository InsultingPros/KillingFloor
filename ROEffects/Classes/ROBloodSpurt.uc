class ROBloodSpurt extends Emitter;

var class<ProjectedDecal> SplatterClass;
var class<ProjectedDecal> DripClass;

// Used for precaching splat textures
var texture Splats[9];

var	float	DripInterval;

simulated function Timer()
{
	local float TimeLeft;

    TimeLeft = LifeSpan/Default.LifeSpan;

   	Emitters[0].ParticlesPerSecond = Emitters[0].InitialParticlesPerSecond * TimeLeft;

	if ( Level.NetMode != NM_DedicatedServer )
		Drip();

	DripInterval += DripInterval * 0.1;

	SetTimer(DripInterval,false);

	//log("Timeleft = "$TimeLeft$" ParticlesPerSecond = "$Emitters[0].ParticlesPerSecond);
}

simulated function PostNetBeginPlay()
{
	SetTimer(DripInterval,false);
	if ( Level.NetMode != NM_DedicatedServer )
		GroundSplat();
	Super.PostNetBeginPlay();
}

simulated function GroundSplat()
{
	local vector WallHit, WallNormal;
	local Actor WallActor;

	if ( FRand() > 0.8 )
		return;
	WallActor = Trace(WallHit, WallNormal, Location + vect(0,0,-200), Location, false);
	if ( WallActor != None )
		spawn(SplatterClass,,,WallHit + 20 * (WallNormal + VRand()), rotator(-WallNormal));
}

simulated function Drip()
{
	local vector WallHit, WallNormal;
	local Actor WallActor;

	if ( FRand() > 0.8 )
		return;
	WallActor = Trace(WallHit, WallNormal, Location + vect(0,0,-200), Location, false);
	if ( WallActor != None )
		spawn(DripClass,,,WallHit + 20 * (WallNormal + VRand()), rotator(-WallNormal));
}

static function PrecacheContent(LevelInfo Level)
{
	local int i;

	for ( i=0; i<9; i++ )
		Level.AddPrecacheMaterial(Default.splats[i]);
}

defaultproperties
{
     SplatterClass=Class'ROEffects.ROBloodSplatter'
     DripClass=Class'ROEffects.ROSmallBloodDrops'
     Splats(0)=Texture'Effects_Tex.GoreDecals.Splatter_001'
     Splats(1)=Texture'Effects_Tex.GoreDecals.Splatter_002'
     Splats(2)=Texture'Effects_Tex.GoreDecals.Splatter_003'
     Splats(3)=Texture'Effects_Tex.GoreDecals.Splatter_004'
     Splats(4)=Texture'Effects_Tex.GoreDecals.Splatter_005'
     Splats(5)=Texture'Effects_Tex.GoreDecals.Splatter_006'
     Splats(6)=Texture'Effects_Tex.GoreDecals.Drip_001'
     Splats(7)=Texture'Effects_Tex.GoreDecals.Drip_002'
     Splats(8)=Texture'Effects_Tex.GoreDecals.Drip_003'
     DripInterval=0.750000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         UseVelocityScale=True
         Acceleration=(Z=-100.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         MaxParticles=30
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.075000,Max=0.075000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.370000,RelativeSize=2.200000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=0.250000,Max=0.750000))
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.GoreEmitters.BloodCircle'
         LifetimeRange=(Min=1.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=20.000000,Max=30.000000),Z=(Min=0.500000,Max=0.500000))
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(X=0.200000,Y=1.000000,Z=1.000000))
         VelocityScale(2)=(RelativeTime=1.000000,RelativeVelocity=(Y=0.400000,Z=0.400000))
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.ROBloodSpurt.SpriteEmitter0'

     bNoDelete=False
     bNetTemporary=True
     LifeSpan=7.000000
     Style=STY_Alpha
     bUnlit=False
     bDirectional=True
}
