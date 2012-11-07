//=============================================================================
// VehicleExhaustEffect
//=============================================================================
// Vehicle exhaust effect
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// by: John "Ramm-Jaeger" Gibson
//=============================================================================
class VehicleExhaustEffect extends Emitter;

var () int		MaxSpritePPSOne; 	// Maximum particles per second for emitter one
var () int		MaxSpritePPSTwo;    // Maximum particles per second for emitter two
var () int		IdleSpritePPSOne;   // Idle particles per second for emitter one
var () int		IdleSpritePPSTwo;   // Idle particles per second for emitter two


simulated function UpdateExhaust(float throttle)
{
	local float SpritePPSOne, SpritePPSTwo;

		if( Abs(throttle) > 0 )
		{
			SpritePPSOne = Abs(throttle) * MaxSpritePPSOne;
            SpritePPSTwo = Abs(throttle) * MaxSpritePPSTwo;

			Emitters[0].ParticlesPerSecond = SpritePPSOne;
			Emitters[0].InitialParticlesPerSecond = SpritePPSOne;
			Emitters[0].AllParticlesDead = false;

			Emitters[1].ParticlesPerSecond = SpritePPSTwo;
			Emitters[1].InitialParticlesPerSecond = SpritePPSTwo;
			Emitters[1].AllParticlesDead = false;
		}
		else
		{
			Emitters[0].ParticlesPerSecond = IdleSpritePPSOne;
			Emitters[0].InitialParticlesPerSecond = IdleSpritePPSOne;
			Emitters[0].AllParticlesDead = false;

			Emitters[1].ParticlesPerSecond = IdleSpritePPSTwo;
			Emitters[1].InitialParticlesPerSecond = IdleSpritePPSTwo;
			Emitters[1].AllParticlesDead = false;
		}
}

defaultproperties
{
     CullDistance=5000.000000
     bNoDelete=False
     bHardAttach=True
}
