class VehicleDamagedEffect extends Emitter
	native;

simulated function PostBeginPlay()
{
	local ROVehicle V;

	Super.PostBeginPlay();

	V = ROVehicle(Owner);
	if (V != None)
	{
		SetEffectScale(V.DamagedEffectScale);
		UpdateDamagedEffect(false, 0, false, false);
	}
}

simulated function SetEffectScale(float Scaling)
{
	Emitters[0].SizeScale[0].RelativeSize = Scaling * default.Emitters[0].SizeScale[0].RelativeSize;

	Emitters[1].SizeScale[0].RelativeSize = Scaling * default.Emitters[1].SizeScale[0].RelativeSize;
	Emitters[1].SizeScale[1].RelativeSize = Scaling * default.Emitters[1].SizeScale[1].RelativeSize;

	Emitters[1].StartLocationRange.X.Min = Scaling * default.Emitters[1].StartLocationRange.X.Min;
	Emitters[1].StartLocationRange.X.Max = Scaling * default.Emitters[1].StartLocationRange.X.Max;
	Emitters[1].StartLocationRange.Y.Min = Scaling * default.Emitters[1].StartLocationRange.Y.Min;
	Emitters[1].StartLocationRange.Y.Max = Scaling * default.Emitters[1].StartLocationRange.Y.Max;


	Emitters[2].StartSizeRange.X.Min = Scaling * default.Emitters[2].StartSizeRange.X.Min;
	Emitters[2].StartSizeRange.X.Max = Scaling * default.Emitters[2].StartSizeRange.X.Max;
	Emitters[2].StartSizeRange.Y.Min = Scaling * default.Emitters[2].StartSizeRange.Y.Min;
	Emitters[2].StartSizeRange.Y.Max = Scaling * default.Emitters[2].StartSizeRange.Y.Max;

	Emitters[2].StartLocationRange.X.Min = Scaling * default.Emitters[2].StartLocationRange.X.Min;
	Emitters[2].StartLocationRange.X.Max = Scaling * default.Emitters[2].StartLocationRange.X.Max;
	Emitters[2].StartLocationRange.Y.Min = Scaling * default.Emitters[2].StartLocationRange.Y.Min;
	Emitters[2].StartLocationRange.Y.Max = Scaling * default.Emitters[2].StartLocationRange.Y.Max;
}

//Called from Vehicle native code when significant changes in vehicle's health or velocity occur
simulated event UpdateDamagedEffect(bool bFlame, float VelMag, bool bMediumSmoke, bool bHeavySmoke)
{
	if(bFlame)
	{
		Emitters[1].ParticlesPerSecond = default.Emitters[1].ParticlesPerSecond;
		Emitters[1].InitialParticlesPerSecond = default.Emitters[1].InitialParticlesPerSecond;
		Emitters[1].AllParticlesDead = false;

		Emitters[2].ParticlesPerSecond = 4;
		Emitters[2].InitialParticlesPerSecond = 4;
		Emitters[2].LifetimeRange.Min = 8.0;
		Emitters[2].LifetimeRange.Max = 8.0;
		Emitters[2].AllParticlesDead = false;

		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;
	}
	else if(bHeavySmoke)
	{
		Emitters[2].ParticlesPerSecond = 2;
		Emitters[2].InitialParticlesPerSecond = 2;
		Emitters[2].LifetimeRange.Min = 6.0;
		Emitters[2].LifetimeRange.Max = 6.0;
		Emitters[2].AllParticlesDead = false;

		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;
	}
	else if(bMediumSmoke)
	{
		Emitters[0].ParticlesPerSecond = 3;
		Emitters[0].InitialParticlesPerSecond = 3;
		Emitters[0].LifetimeRange.Min = 6.0;
		Emitters[0].LifetimeRange.Max = 6.0;
		Emitters[0].AllParticlesDead = false;
	}
	else
	{
		Emitters[0].ParticlesPerSecond = 1;
		Emitters[0].InitialParticlesPerSecond = 1;
		Emitters[0].LifetimeRange.Min = 4.0;
		Emitters[0].LifetimeRange.Max = 4.0;
		Emitters[0].AllParticlesDead = false;

		Emitters[1].ParticlesPerSecond = 0;
		Emitters[1].InitialParticlesPerSecond = 0;

		Emitters[2].ParticlesPerSecond = 0;
		Emitters[2].InitialParticlesPerSecond = 0;
	}
}

defaultproperties
{
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
         Acceleration=(X=10.000000,Z=10.000000)
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=192,G=192,R=192,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(A=255))
         FadeOutStartTime=2.000000
         FadeInEndTime=1.000000
         MaxParticles=100
         RotationOffset=(Yaw=1274,Roll=13107)
         SpinCCWorCW=(Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Max=0.100000),Z=(Min=1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=16000.000000,Max=20000.000000),Z=(Min=9000.000000,Max=12000.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=25.000000,Max=50.000000),Y=(Min=25.000000,Max=50.000000),Z=(Min=25.000000,Max=50.000000))
         ParticlesPerSecond=3.000000
         InitialParticlesPerSecond=3.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.DSmoke_2'
         LifetimeRange=(Min=6.000000,Max=6.000000)
         StartVelocityRange=(Z=(Min=50.000000,Max=100.000000))
         VelocityLossRange=(X=(Max=0.050000),Y=(Max=0.050000),Z=(Max=0.050000))
     End Object
     Emitters(0)=SpriteEmitter'ROEngine.VehicleDamagedEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         UseVelocityScale=True
         Acceleration=(Z=50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=100,G=177,R=230,A=255))
         ColorScale(2)=(RelativeTime=0.750000,Color=(B=5,R=230,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.598000
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=50.000000,Max=70.000000))
         ParticlesPerSecond=5.000000
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'Effects_Tex.explosions.fire_16frame'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=1.000000,Max=1.150000)
         VelocityScale(0)=(RelativeTime=0.100000,RelativeVelocity=(X=0.100000,Y=0.100000,Z=0.100000))
         VelocityScale(1)=(RelativeTime=0.500000,RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(2)=(RelativeTime=1.000000)
     End Object
     Emitters(1)=SpriteEmitter'ROEngine.VehicleDamagedEffect.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=10.000000,Z=10.000000)
         ColorScale(0)=(Color=(A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(A=255))
         FadeOutStartTime=3.180000
         FadeInEndTime=0.420000
         MaxParticles=100
         StartLocationOffset=(Z=30.000000)
         RotationOffset=(Yaw=1092,Roll=13107)
         SpinCCWorCW=(Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Max=0.100000),Z=(Min=1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=16000.000000,Max=20000.000000),Z=(Min=9000.000000,Max=12000.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=25.000000,Max=50.000000),Y=(Min=25.000000,Max=50.000000),Z=(Min=25.000000,Max=50.000000))
         ParticlesPerSecond=4.000000
         InitialParticlesPerSecond=4.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.DSmoke_1'
         LifetimeRange=(Min=8.000000,Max=8.000000)
         StartVelocityRange=(Z=(Min=50.000000,Max=100.000000))
         VelocityLossRange=(X=(Max=0.050000),Y=(Max=0.050000),Z=(Max=0.050000))
     End Object
     Emitters(2)=SpriteEmitter'ROEngine.VehicleDamagedEffect.SpriteEmitter2'

     AutoDestroy=True
     bNoDelete=False
     bHardAttach=True
}
