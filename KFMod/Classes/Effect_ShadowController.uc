//=============================================================================
// © 2004 Matt 'SquirrelZero' Farber
//=============================================================================
// This is a master class for controlling all shadows.  This is needed to spawn
// and determine the visibility of all shadows.  It also keeps track of all the
// nearby lights.
//=============================================================================
// JCBDigger
// I have made all the functions simulated
// I have included a line to destroy the shadows if the Pawn no longer exists
class Effect_ShadowController extends Actor
	config(User);

// the type of shadow projector we're going to use
var class<Effect_ShadowProjector> ShadowClass;

// an array of shadows, the maximum allowed per player can be specified below
var array<Effect_ShadowProjector> Shadows;

// a special variable type, lastlight is used for fading
struct LightGroup
{
	var Actor CurrentLight;
	var Actor LastLight;
};

// an array of lightgroups, filled when spawned
var array<LightGroup> Lights;

// the maximum distance a light can be from a player to cast a shadow
var float MaxLightDistance;

// the sun
var SunLight SunLightActor;

// turns on/off all shadows
var bool bShadowActive;

// maximum allowed shadows per player, configurable
var globalconfig int MaxShadows;

// how crisp (detailed) the shadows should be.  The higher, the better
// they look, but the worse they perform.
// Low = 128x128
// Medium = 256
// High = 512
// Maximum = 1024 <- can any modern video technology even run it at maximum?
var globalconfig enum CrispnessEnum
{
	Low,
	Medium,
	High,
	Maximum
}ShadowCrispness;

simulated function Initialize()
{
	local SunLight LightActor;
	local array<SunLight> SunLights;
	local int i;
	
	// set the sunlight, pick the brightest one if we have multiple
	foreach AllActors(class'SunLight',LightActor)
	{
		if (LightActor == None)
			continue;

		SunLights[i] = LightActor;
		i++;
	}
	for (i=0;i<SunLights.Length;i++)
	{
		if (SunLightActor == None || SunLightActor.LightBrightness < SunLights[i].LightBrightness)
			SunLightActor = SunLights[i];
	}

	// fill the arrays with placeholders
	Shadows.Insert(0,MaxShadows);
	Lights.Insert(0,MaxShadows);

	// enable
	bShadowActive = true;

	// build light array
	FillLights();
}

simulated function Timer()
{
	FillLights();
}

simulated function FillLights()
{
	local int i;
	local actor LightActor;
	local array<Actor> OrigLight;

	// clear array of lights, leave LastLight alone to fade
	for (i=0;i<MaxShadows;i++)
	{
		OrigLight[i] = Lights[i].CurrentLight;
		Lights[i].CurrentLight = None;
	}

	if ( Instigator != None )	 // JCBDigger
	{
		// set the location of the controller, for light detection purposes
		SetLocation(Instigator.Location);

		// shadow is off
		if (!bShadowActive)
			return;

		// build the array of lights, we prioritize by both brightness and distance
		foreach RadiusActors(class'Actor',LightActor,MaxLightDistance)
		{
			// if we are within the light's radius, and it's shining on at least one part of us, then add it to the array
			if (LightActor != None && LightActor.LightType != LT_None && (LightActor.bStatic || LightActor.bDynamicLight) && LightActor.LightEffect != LE_Sunlight && IsVisible(LightActor.Location) && LightActor.LightBrightness > 1 && LightActor.LightRadius >= (VSize(LightActor.Location-Instigator.Location)*0.041)) // (0.041 is not perfect)
			{
				if (Lights[0].CurrentLight != None && LightPriority(Lights[0].CurrentLight.LightBrightness,Lights[0].CurrentLight.LightRadius,VSize(Lights[0].CurrentLight.Location-Instigator.Location)) > LightPriority(LightActor.LightBrightness,LightActor.LightRadius,VSize(LightActor.Location-Instigator.Location)))
					continue;

				// this puts them in order of priority
				for (i=1;i<MaxShadows;i++)
					Lights[i].CurrentLight = Lights[i-1].CurrentLight;

				Lights[0].CurrentLight = LightActor;
			}
		}
	
		// we'll use the sunlight as the very lowest priority of lights
		for (i=0;i<MaxShadows;i++)
			if (Lights[i].CurrentLight == None && SunlightActor != None && (IsVisible(SunLightActor.Location) || Lights[0].CurrentLight == None))
			{
				Lights[i].CurrentLight = SunLightActor;
				break;
			}


		// set up last light for fading
		for (i=0;i<MaxShadows;i++)	  
			if (OrigLight[i] != Lights[i].CurrentLight)
				Lights[i].LastLight = OrigLight[i];

		// loop it, loop it good
		SetTimer(0.05,false);
	}
	else
	{
		// if we don't have a pawn we should not exist
		Destroy();	// JCBDigger
	}
}

// simple function for determining the priority of a light
simulated function float LightPriority(float Brightness, float Radius, float Distance)
{
	local float Priority;

	// brightness takes higher priority
	Priority = (Brightness*10)/Distance;

	// lights that are very close get higher priority
	if (Distance < 0.1 * MaxLightDistance)
		Priority *= 1.5;

	// lights with very small radii shouldn't really cast shadows
	if (Radius < 2.0)
		Priority *= (Radius*0.38);
	
	return Priority;
}

simulated function bool IsVisible(vector Loc)
{
	local vector FootLocation;

	if ( Instigator != None )   // JCBDigger
	{  
		// get a location near the feet
		FootLocation = Instigator.Location;
		FootLocation.Z -= Instigator.CollisionHeight*0.49;
		// not very clean, returns true if either the head, feet, or middle torso of the player is visible to Loc
		if (FastTrace(Loc,Instigator.Location) || FastTrace(Loc,Instigator.GetBoneCoords('head').Origin) || FastTrace(Loc,FootLocation))
			return true;
		else return false;
	}
	else return false;
}

simulated function Tick(float dt)
{
	// fallback
	if (Instigator == None)
		return;
	
	// update all shadows
	UpdateShadows(dt);
}

simulated function UpdateShadows(float dt)
{
	local int i;

	for (i=0;i<Lights.Length;i++)
	{
		// disable the shadow attached to this slot if light no longer active, or if manually made inactive
		if ((Lights[i].CurrentLight == None && Lights[i].LastLight == None) || !bShadowActive)
		{
			if (Shadows[i] != None)
				Shadows[i].DisableShadow();
			continue;
		}

		// spawn a new shadow if it doesn't already exist
		if (Shadows[i] == None)
			Shadows[i] = SpawnShadow(rotator(Lights[i].CurrentLight.Location-Location));

		// update each shadow
		Shadows[i].UpdateShadow(dt,i,self);
	}
}

simulated function Effect_ShadowProjector SpawnShadow(rotator LightRotation)
{
	local Effect_ShadowProjector NewShadow;

	// spawn and initialize a shadow projector
	NewShadow = spawn(ShadowClass,Instigator,,Location,LightRotation);
	NewShadow.Disable('Tick');
	NewShadow.InitializeFor(self);

	return NewShadow;
}

simulated function Destroyed()
{
	local int i;

	Disable('Tick');

	// destroy all shadows
	for (i=0;i<MaxShadows;i++)
		if (Shadows[i] != None)
			Shadows[i].Destroy();
}

defaultproperties
{
     ShadowClass=Class'KFMod.Effect_ShadowProjector'
     MaxLightDistance=1000.000000
     MaxShadows=2
     DrawType=DT_None
     bHidden=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
