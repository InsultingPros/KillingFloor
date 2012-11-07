//=============================================================================
// VehicleWheelDustEffect
//=============================================================================
// Wheel dust effect
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// Created by: David Hensely
// Coded in by: John "Ramm-Jaeger" Gibson
// Based off the old ONSDirtSlipEffect
//=============================================================================
class VehicleWheelDustEffect extends Emitter;

var () int		MaxSpritePPS;
var () int		MaxMeshPPS;
var () sound    DirtSlipSound;
var () float	MinWheelDustSpeed;
var () float	MaxWheelDustSpeed;

simulated function SetDirtColor(color DirtColor)
{
	local color DirtColorZeroAlpha, DirtColorHalfAlpha;

	// Ignore if dust color if black.
	if(DirtColor.R == 0 && DirtColor.G == 0 && DirtColor.B == 0)
		return;

	DirtColor.A = 255;

	DirtColorZeroAlpha = DirtColor;
	DirtColorZeroAlpha.A = 0;

	DirtColorHalfAlpha = DirtColor;
	DirtColorHalfAlpha.A = 128;

	Emitters[0].ColorScale[0].Color = DirtColorZeroAlpha;
	Emitters[0].ColorScale[1].Color = DirtColorHalfAlpha;
	Emitters[0].ColorScale[2].Color = DirtColorHalfAlpha;
	Emitters[0].ColorScale[3].Color = DirtColorZeroAlpha;
}

simulated function UpdateDust(SVehicleWheel t, float DustSlipRate, float DustSlipThresh)
{
	local float SpritePPS, MeshPPS;

	 //log(" t.SpinVel = "$t.SpinVel);

	//Log("Material:"$t.GroundMaterial$" OnGround:"$t.bTireOnGround);

	// If wheel is on ground, and slipping above threshold..
	if(t.bWheelOnGround )
	{
		if( t.SlipVel > DustSlipThresh )
		{

			SpritePPS = FMin(DustSlipRate * (t.SlipVel - DustSlipThresh), MaxSpritePPS);

	        //log(" SpritePPS = "$SpritePPS);

			Emitters[0].ParticlesPerSecond = SpritePPS;
			Emitters[0].InitialParticlesPerSecond = SpritePPS;
			Emitters[0].AllParticlesDead = false;

			MeshPPS = FMin(DustSlipRate * (t.SlipVel - DustSlipThresh), MaxMeshPPS);

			Emitters[1].ParticlesPerSecond = MeshPPS;
			Emitters[1].InitialParticlesPerSecond = MeshPPS;
			Emitters[1].AllParticlesDead = false;
		}
		else if ( Abs(t.SpinVel) > MinWheelDustSpeed )
		{
			SpritePPS = Abs(t.SpinVel)/MaxWheelDustSpeed * MaxSpritePPS;//FMin(DustSlipRate * (t.SlipVel - DustSlipThresh), MaxSpritePPS);

	        //log(" SpritePPS = "$SpritePPS);

			Emitters[0].ParticlesPerSecond = SpritePPS;
			Emitters[0].InitialParticlesPerSecond = SpritePPS;
			Emitters[0].AllParticlesDead = false;

			Emitters[1].ParticlesPerSecond = 0;
			Emitters[1].InitialParticlesPerSecond = 0;
		}
		else
		{
			Emitters[0].ParticlesPerSecond = 0;
			Emitters[0].InitialParticlesPerSecond = 0;

			Emitters[1].ParticlesPerSecond = 0;
			Emitters[1].InitialParticlesPerSecond = 0;

			AmbientSound = None;
		}

//		AmbientSound = DirtSlipSound;
	}
	else // ..otherwise, switch off.
	{
		Emitters[0].ParticlesPerSecond = 0;
		Emitters[0].InitialParticlesPerSecond = 0;

		Emitters[1].ParticlesPerSecond = 0;
		Emitters[1].InitialParticlesPerSecond = 0;

		AmbientSound = None;
	}
}

defaultproperties
{
     MaxSpritePPS=5
     MaxMeshPPS=5
     MinWheelDustSpeed=0.500000
     MaxWheelDustSpeed=10.000000
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseVelocityScale=True
         Acceleration=(Z=30.000000)
         ColorScale(0)=(Color=(B=30,G=90,R=110))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=34,G=44,R=66,A=128))
         ColorScale(2)=(RelativeTime=0.896429,Color=(B=36,G=49,R=64,A=128))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=20,G=50,R=80))
         FadeOutStartTime=1.000000
         MaxParticles=200
         StartLocationRange=(Y=(Min=-24.000000,Max=24.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Max=0.050000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=4.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=8.000000)
         StartSizeRange=(X=(Min=20.000000,Max=40.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Vehicles.DustCloud'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.VehicleWheelDustEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=-550.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.500000
         MaxParticles=150
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.500000,Max=2.000000))
         StartSizeRange=(X=(Min=2.000000,Max=8.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Vehicles.Dust_KickUp'
         TextureUSubdivisions=16
         TextureVSubdivisions=16
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.650000,Max=0.650000)
         StartVelocityRange=(X=(Min=-150.000000,Max=-250.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=50.000000,Max=250.000000))
     End Object
     Emitters(1)=SpriteEmitter'ROEffects.VehicleWheelDustEffect.SpriteEmitter1'

     CullDistance=5000.000000
     bNoDelete=False
     bHardAttach=True
     SoundVolume=40
}
