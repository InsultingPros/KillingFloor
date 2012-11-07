//=============================================================================
// Trenchgun Bullet that does fire damage (Dragon's breath)
//=============================================================================
class TrenchgunBullet extends Projectile;

var     xEmitter    Trail;
var     Emitter     FlameTrail;
var     class<Emitter> FlameTrailEmitterClass;
var     float       DamageAtten;
var     sound       ImpactSounds[6];
var()   int         MaxPenetrations; // Yeah, Hardy har har. It refers in fact to the number of times the bolt can pass through someone and keep going.
var()   float       PenDamageReduction; // how much damage does it lose with each person it passes through?
var()   float       HeadShotDamageMult;

var()	class<ROHitEffect>		ImpactEffect;
var()   class<Emitter> ExplosionEmitter;

var		string	StaticMeshRef;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    if( Pawn(Owner) != None )
        Instigator = Pawn( Owner );
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

    SetTimer(0.4, false);

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {

            //Trail = Spawn(class'KFTracer',self);
            //Trail.Lifespan = Lifespan;
			FlameTrail = Spawn(FlameTrailEmitterClass,self);
			Trail = Spawn(class'FlameThrowerFlame',self);

        }
    }
}

static function PreloadAssets()
{
	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	UpdateDefaultStaticMesh(none);

	return true;
}


simulated function PostNetBeginPlay()
{
	local PlayerController PC;

	Super.PostNetBeginPlay();

	if ( Level.NetMode == NM_DedicatedServer )
		return;

	PC = Level.GetLocalPlayerController();
	if ( (Instigator != None) && (PC == Instigator.Controller) )
		return;
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
}

simulated function Destroyed()
{
	if ( Trail != none )
	{
		Trail.mRegen=False;
		Trail.SetPhysics(PHYS_None);
		Trail.GotoState('');
	}

	if ( FlameTrail != none )
	{
        FlameTrail.Kill();
		FlameTrail.SetPhysics(PHYS_None);
	}

         Super.Destroyed();

}

simulated function Explode(vector HitLocation, vector HitNormal)
{

    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(ExplosionEmitter,,,HitLocation + HitNormal*20,rotator(HitNormal));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

    BlowUp(HitLocation);
    Destroy();

}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
    if ( Role == ROLE_Authority )
	{
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);

	if (ImpactEffect != None && (Level.NetMode != NM_DedicatedServer))
	{
			Spawn(ImpactEffect,,, Location, rotator(-HitNormal));
	}

    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(ExplosionEmitter,,,Location + HitNormal*20,rotator(HitNormal));
        Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	HurtWall = None;


    if (Trail != None)
    {
        Trail.mRegen=False;
        Trail.SetPhysics(PHYS_None);
        //Trail.mRegenRange[0] = 0.0;//trail.mRegenRange[0] * 0.6;
        //Trail.mRegenRange[1] = 0.0;//trail.mRegenRange[1] * 0.6;
    }

	if ( FlameTrail != none )
	{
        FlameTrail.Kill();
		FlameTrail.SetPhysics(PHYS_None);
	}

    Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local vector X;
	local Vector TempHitLocation, HitNormal;
	local array<int>	HitPoints;
    local KFPawn HitPawn;

	if ( Other == none || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces  )
		return;

    X = Vector(Rotation);

 	if( ROBulletWhipAttachment(Other) != none )
	{
        if(!Other.Base.bDeleteMe)
        {
	        Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

			if( Other == none || HitPoints.Length == 0 )
				return;

			HitPawn = KFPawn(Other);

            if (Role == ROLE_Authority)
            {
    	    	if ( HitPawn != none )
    	    	{
     				// Hit detection debugging
    				/*log("Bullet hit "$HitPawn.PlayerReplicationInfo.PlayerName);
    				HitPawn.HitStart = HitLocation;
    				HitPawn.HitEnd = HitLocation + (65535 * X);*/

                    if( !HitPawn.bDeleteMe )
                    	HitPawn.ProcessLocationalDamage(Damage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,HitPoints);


                    // Hit detection debugging
    				//if( Level.NetMode == NM_Standalone)
    				//	HitPawn.DrawBoneLocation();
    	    	}
    		}
		}
	}
    else
    {
        if (Pawn(Other) != none && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
        {
            Pawn(Other).TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
        }
        else
        {
            Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
        }
    }

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
   		PenDamageReduction = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo),default.PenDamageReduction);
	}
	else
	{
   		PenDamageReduction = default.PenDamageReduction;
   	}

   	Damage *= PenDamageReduction; // Keep going, but lose effectiveness each time.

    // if we've struck through more than the max number of foes, destroy.
    if ( Damage / default.Damage <= PenDamageReduction / MaxPenetrations )
    {
        Destroy();
    }

    speed = VSize(Velocity);

    if( Speed < (default.Speed * 0.25) )
    {
        Destroy();
    }
}

defaultproperties
{
     FlameTrailEmitterClass=Class'KFMod.DragonsBreathFlameEmitter'
     DamageAtten=5.000000
     MaxPenetrations=2
     PenDamageReduction=0.500000
     HeadShotDamageMult=1.500000
     ImpactEffect=Class'ROEffects.ROBulletHitEffect'
     ExplosionEmitter=Class'KFMod.DragonsBreathImpactEffect'
     StaticMeshRef="EffectsSM.Ger_Tracer"
     Speed=3500.000000
     MaxSpeed=4000.000000
     bSwitchToZeroCollision=True
     Damage=18.000000
     DamageRadius=0.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'KFMod.DamTypeTrenchgun'
     ExplosionDecal=Class'KFMod.TrenchgunDecal'
     DrawType=DT_StaticMesh
     CullDistance=3000.000000
     LifeSpan=3.000000
     DrawScale=0.500000
     Style=STY_Alpha
}
