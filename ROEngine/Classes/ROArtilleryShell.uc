//=============================================================================
// ROArtilleryShell
//=============================================================================
// An artillery round + some code to handle the FX
// Note - Poketerrain commented out till after alpha
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 John Gibson
//=============================================================================

class ROArtilleryShell extends Projectile;

//=============================================================================
// Variables
//=============================================================================

// Internal use
var 		vector 				FinalHitLocation;
var 		sound       		SavedCloseSound;
var 		bool        		bAlreadyPlayedFarSound;
var 		bool		 		bDroppedProjectileFirst;
var 		float       		DistanceToTarget;
var 		ROArtillerySound    SoundActor;

// debugging
var 		float       		SpawnTime;
var 		float       		DieTime;

// Effects
var()   	class<Emitter>  	ShellHitDirtEffectClass;  	// Artillery hitting dirt emitter
var()   	class<Emitter>  	ShellHitSnowEffectClass;    // Artillery hitting snow emitter
var()   	class<Emitter>  	ShellHitDirtEffectLowClass; // Artillery hitting dirt emitter low settings
var()   	class<Emitter>  	ShellHitSnowEffectLowClass; // Artillery hitting snow emitter low settings
var			sound				ExplosionSound[4];          // sound of the artillery exploding
var			sound				DistantSound[4];            // sound of the artillery distant overhead
var			sound				CloseSound[4];              // sound of the artillery whoosing in close

// camera shakes //
var() 		vector 				ShakeRotMag;           		// how far to rot view
var() 		vector 				ShakeRotRate;          		// how fast to rot view
var() 		float  				ShakeRotTime;          		// how much time to rot the instigator's view
var() 		vector 				ShakeOffsetMag;        		// max view offset vertically
var() 		vector 				ShakeOffsetRate;       		// how fast to offset view vertically
var() 		float  				ShakeOffsetTime;       		// how much time to offset view
var			float				BlurTime;                   // How long blur effect should last for this shell
var			float				BlurEffectScalar;

// Scare the bots away from this
var AvoidMarker Fear;

/*replication
{
 reliable if ( Role<ROLE_Authority )
        ServerPoke;
} */

//=============================================================================
// Functions
//=============================================================================

simulated function PostBeginPlay()
{
    local sound ThisDistantSound;
//	local Rotator R;
	//local float TimeToWaitToSpawn;
//	if ( !PhysicsVolume.bWaterVolume && (Level.NetMode != NM_DedicatedServer) )
//		Trail = Spawn(class'FlakShellTrail',self);

	Super.PostBeginPlay();

	// this fixes trouble when the player who initiated the arty strike leaves the server
	// because their PC is gone, so Owner is now none
	if( Owner != none )
	{
    		Instigator = ROPlayer(owner).Pawn;
    		if( InstigatorController == none)
    			InstigatorController = Controller(Owner);
    }

	SetDrawType(DT_None);

	Velocity = vect(0,0,0);
	ThisDistantSound = DistantSound[Rand(4)];
	PlaySound (ThisDistantSound,,10,,50000,1.0,true);
	SetTimer(GetSoundDuration(ThisDistantSound) * 0.95, false);
}

simulated function dotracefx()
{
	//local actor HitActor;
	//local vector HitLocation, HitNormal;

    	bAlreadyPlayedFarSound = true;

	//HitActor = trace(HitLocation,HitNormal,5000 * Normal(PhysicsVolume.Gravity),location,true);

	//DistanceToTarget = VSize(Location - HitLocation);

/*    log("HitActor = "$HitActor);

		if (  HitActor.IsA('TerrainInfo') )
		{

		   TerrainInfo(HitActor).PokeTerrain((HitLocation + 16 * HitNormal) , 1000, 250);
		}     */

	SoundActor =  Spawn(class 'ROArtillerySound',self,, FinalHitLocation, rotator(PhysicsVolume.Gravity));
	SoundActor.PlaySound (SavedCloseSound,,10,true, 5248, 1.0, true);
}

simulated function SetupStrikeFX()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HitActor = trace(HitLocation,HitNormal,Location + 50000 * Normal(PhysicsVolume.Gravity),Location,true);

	// debugging
	//Spawn(class 'RODebugTracer',self,,Location,Rotator(PhysicsVolume.Gravity));
	//Spawn(class 'RODebugTracerGreen',self,,HitLocation,Rotator(PhysicsVolume.Gravity));


	if( HitActor == none)
	{
		log("Artillery Setup Error - No FinalHitLocation Found!!!");
	}

    	SavedCloseSound = CloseSound[Rand(4)];
	FinalHitLocation = HitLocation;
	DistanceToTarget = VSize(Location - FinalHitLocation);


	if (Role == ROLE_Authority)
	{
		Fear = Spawn(class'AvoidMarker',,,FinalHitLocation);
		Fear.SetCollisionSize(DamageRadius,200);
		Fear.StartleBots();
	}
}

simulated function timer()
{
 	local float TimeToWaitToSpawn;

	if ( !bAlreadyPlayedFarSound )
	{
		SetDrawType(default.DrawType);

          SetupStrikeFX();

		if( GetSoundDuration(SavedCloseSound) > (DistanceToTarget/speed))
		{
			dotracefx();
			TimeToWaitToSpawn = GetSoundDuration(SavedCloseSound) - (DistanceToTarget/speed);
		}
		else
		{
			bDroppedProjectileFirst = true;
			bAlreadyPlayedFarSound=true;
			TimeToWaitToSpawn = (DistanceToTarget/speed)- GetSoundDuration(SavedCloseSound);
			Velocity = Normal(PhysicsVolume.Gravity) * Speed;
			SpawnTime = Level.TimeSeconds;
		}
		//log("Predicting "$(DistanceToTarget/speed)$" Sec. to land, DistanceToTarget = "$DistanceToTarget$", speed = "$speed$" D/S = "$(DistanceToTarget/speed)$" SoundDuration = "$GetSoundDuration(SavedCloseSound));

		SetTimer(TimeToWaitToSpawn, false);
	}
	else if ( bDroppedProjectileFirst )
	{
           dotracefx();
	}
	else
	{
		Velocity = Normal(PhysicsVolume.Gravity) * Speed;
		SpawnTime = Level.TimeSeconds;
	}
}

simulated function destroyed()
{
	local ROPawn Victims;
	local float damageScale, dist;
	local vector dir, Start;

	// Move karma ragdolls around when this explodes
	if ( Level.NetMode != NM_DedicatedServer )
	{
		Start = Location + 32 * vect(0,0,1);

		foreach VisibleCollidingActors( class 'ROPawn', Victims, DamageRadius, Start )
		{
			// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
			if( Victims != self)
			{
				dir = Victims.Location - Start;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

				if(Victims.Physics == PHYS_KarmaRagDoll )
				{
					Victims.DeadExplosionKarma(MyDamageType, damageScale * MomentumTransfer * dir, damageScale);
				}
			}
		}
	}

	if ( Fear != None )
		Fear.Destroy();

	if( SoundActor != none )
	{
		SoundActor.Destroy();
	}
	Super.Destroyed();
}


simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
	{
		SpawnEffects(HitLocation, -1 * Normal(Velocity) );
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
	local Vector Start;
	local vector TraceHitLocation, TraceHitNormal;
	local Material HitMaterial;
	local ESurfaceTypes ST;

	Start = HitLocation + 16 * HitNormal;
	Trace(TraceHitLocation, TraceHitNormal, Location + Vector(Rotation) * 16, Location, false,, HitMaterial);

	if (HitMaterial == None)
		ST = EST_Default;
	else
		ST = ESurfaceTypes(HitMaterial.SurfaceType);

	PlaySound (ExplosionSound[Rand(4)],,6.0*TransientSoundVolume, false, 5248, 1.0, true);

	DoShakeEffect();

	if (EffectIsRelevant(Location,false))
	{
		Spawn(class'RORocketExplosion',,, Start, rotator(HitNormal));
     	if (  ST == EST_Snow || ST == EST_Ice)
    	{
    	    if( Level.bDropDetail || Level.DetailMode == DM_Low )
				Spawn(ShellHitSnowEffectLowClass,,, HitLocation, rotator(HitNormal));
			else
				Spawn(ShellHitSnowEffectClass,,, HitLocation, rotator(HitNormal));
    	    Spawn(ExplosionDecalSnow, self,, HitLocation, rotator(-HitNormal));
    	}
    	else
    	{
    	    if( Level.bDropDetail || Level.DetailMode == DM_Low )
				Spawn(ShellHitDirtEffectLowClass,,, HitLocation, rotator(HitNormal));
			else
				Spawn(ShellHitDirtEffectClass,,, HitLocation, rotator(HitNormal));
	        Spawn(ExplosionDecal, self,, HitLocation, rotator(-HitNormal));
    	}
	}
}

// Shake the ground for poeple near the artillery hit
simulated function DoShakeEffect()
{
	local PlayerController PC;
	local float Dist, Scale;

	//viewshake
	if (Level.NetMode != NM_DedicatedServer)
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget != None)
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if (Dist < DamageRadius * 3.0 )
			{
				scale = (DamageRadius*3.0  - Dist) / (DamageRadius*3.0 /*4.0*/);
                scale *= BlurEffectScalar;

				PC.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);

				if( PC.Pawn != none && ROPawn(PC.Pawn) != none )
				{
					scale = scale - (scale * 0.35 - ((scale * 0.35) * ROPawn(PC.Pawn).GetExposureTo(Location + 50 * -Normal(PhysicsVolume.Gravity))));
				}
				ROPlayer(PC).AddBlur(BlurTime*scale, FMin(1.0,scale));
			}
		}
	}
}


simulated function Landed( vector HitNormal )
{
	SpawnEffects( Location, HitNormal );
	Explode(Location,HitNormal);
}

/*function ServerPoke(vector HitNormal, actor Wall)
{
         local ROGameReplicationInfo GRI;
         local int i;
         log("Wall = "$Wall);

         log("ServerPoke got called");

		if (  Wall.IsA('TerrainInfo') )
		{

		   TerrainInfo(Wall).PokeTerrain((Location + 16 * HitNormal) , 100, 50);
		   GRI= ROGameReplicationInfo(Level.Game.GameReplicationInfo);

     for ( i=0; i<ArrayCount(GRI.SavedPoke); i++ )
     {
           if ( GRI.SavedPoke[i].PokeLocation == vect(0,0,0))
           {
              GRI.SavedPoke[i].PokedTerrain = TerrainInfo(Wall);
              GRI.SavedPoke[i].PokeLocation = (Location + 16 * HitNormal);
              GRI.SavedPoke[i].PokeRadius = 100;
              GRI.SavedPoke[i].PokeDepth = 50;

              return;
           }
		   //TerrainInfo(Wall).PokeTerrain((Location + 16 * HitNormal) , 100, 50);
     }


		}
} */

simulated function HitWall (vector HitNormal, actor Wall)
{
	Landed(HitNormal);
   // ServerPoke(HitNormal, Wall);


    //log("Calling ServerPoke");
    //if ( Role == ROLE_Authority)
/*	        log("Wall = "$Wall);

		if (  Wall.IsA('TerrainInfo') )
		{

		   TerrainInfo(Wall).PokeTerrain((Location + 16 * HitNormal) , 1000, 250);
		}*/
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local vector start;
//    local rotator rot;
 //   local int i;
    //local float HowLong;
    //local FlakChunk NewChunk;

	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{
		//HurtRadius(damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
		DelayedHurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	}
	//DieTime = Level.TimeSeconds;
	//HowLong = DieTime - Spawntime;
	//log("It took "$HowLong$" Seconds to land");
    Destroy();
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local ROPawn P;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			if( P == Victims )
			{
				continue;
			}

			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			P = ROPawn(Victims);

			if( ROPawn(Victims) == none )
			{
				P = ROPawn(Victims.Base);
			}

			if( P != none )
			{
				damageScale *= P.GetExposureTo(Location + 50 * -Normal(PhysicsVolume.Gravity));
				if ( damageScale  <=0)
					continue;
			}

			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));

		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			(damageScale * Momentum * dir),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
	}

	bHurtEntry = false;
}

// Overrides Actor::EffectIsRelevant() because that function wasn't working correctly in vehicles
simulated function bool EffectIsRelevant(vector SpawnLocation, bool bForceDedicated )
{
	local PlayerController P;
	local bool bResult;

	if ( Level.NetMode == NM_DedicatedServer )
	{
        return bForceDedicated;
	}
	if ( Level.NetMode != NM_Client )
    {
		bResult = true;
	}
	else if ( (Instigator != None) && Instigator.IsHumanControlled() )
	{
        return  true;
	}
	else if ( SpawnLocation == Location )
	{
		bResult = ( Level.TimeSeconds - LastRenderTime < 3 );
	}
	else if ( (Instigator != None) && (Level.TimeSeconds - Instigator.LastRenderTime < 3) )
	{
		bResult = true;
	}
	if ( bResult )
	{
		P = Level.GetLocalPlayerController();

		if ( (P == None) || (P.ViewTarget == None) )
		{
			bResult = false;
		}
		else if ( P.Pawn == Instigator )
		{
            bResult = CheckMaxEffectDistance(P, SpawnLocation);
        }
        // TODO: Add code to make this check work correctly when in a vehicle so we don't have to skip it - Ramm
		else if ( !P.ViewTarget.IsA('Vehicle') && ( (Vector(P.Rotation) dot (SpawnLocation - P.ViewTarget.Location)) < 0.0 ) )
		{
			bResult = (VSize(P.ViewTarget.Location - SpawnLocation) < 1600);
		}
		else
		{
			bResult = CheckMaxEffectDistance(P, SpawnLocation);
		}
	}
	return bResult;
}

defaultproperties
{
     ShellHitDirtEffectClass=Class'ROEffects.ROArtilleryDirtEmitter'
     ShellHitSnowEffectClass=Class'ROEffects.ROArtillerySnowEmitter'
     ShellHitDirtEffectLowClass=Class'ROEffects.ROArtilleryDirtEmitter_simple'
     ShellHitSnowEffectLowClass=Class'ROEffects.ROArtillerySnowEmitter_simple'
     ShakeRotMag=(Z=200.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=5.000000
     BlurTime=6.000000
     BlurEffectScalar=2.100000
     Speed=8000.000000
     MaxSpeed=8000.000000
     Damage=500.000000
     DamageRadius=1000.000000
     MomentumTransfer=75000.000000
     MyDamageType=Class'ROEngine.ROArtilleryDamType'
     ExplosionDecal=Class'ROEffects.ArtilleryMarkDirt'
     ExplosionDecalSnow=Class'ROEffects.ArtilleryMarkSnow'
     DrawType=DT_StaticMesh
     CullDistance=50000.000000
     LifeSpan=1500.000000
     DrawScale=0.001000
     AmbientGlow=100
     SoundVolume=255
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     bProjTarget=True
     ForceType=FT_Constant
     ForceRadius=60.000000
     ForceScale=5.000000
}
