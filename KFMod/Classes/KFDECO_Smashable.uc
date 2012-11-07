//-----------------------------------------------------------
// It Breaks good..
//-----------------------------------------------------------
class KFDECO_Smashable extends decoration;

var () float RespawnTime;
var () bool  bNeedsSingleShot;     // If true, it will only smash on damage if it's all in a single shot
var  bool  bImperviusToPlayer;   // If true, the player can't smash it
var () bool bExplosive;
var () float       ExplosionDamage;
var () float ExplosionRadius;
var () float ExplosionForce;
var class<DamageType> ExplosionDamType;

var() class<Pickup> DestroyedContents;    // spawned when destroyed
var() bool bContentsRespawn;

function Reset()
{
    super.Reset();
    Gotostate('Working');
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    disable('tick');
    CullDistance = default.CullDistance;
}


function BreakApart(vector HitLocation, vector momentum)
{
    // If we are single player or on a listen server, just spawn the actor, otherwise
    // bHidden will trigger the effect

    if (Level.NetMode == NM_ListenServer || Level.NetMode == NM_StandAlone)
    {
        if ( (EffectWhenDestroyed!=None ) && EffectIsRelevant(location,false) )
            Spawn( EffectWhenDestroyed, Owner,, Location );
    }

    gotostate('Broken');
}

auto state Working
{
    function BeginState()
    {
        super.BeginState();

        SetCollision(true,true,true);
        NetUpdateTime = Level.TimeSeconds - 1;
        bHidden = false;
        //Health = default.health;
    }

    function EndState()
    {
        local Pawn DummyPawn;
        local pickup DroppedPickup;
        local vector AdjustedLoc;

        super.EndState();

        NetUpdateTime = Level.TimeSeconds - 1;
        bHidden = true;
        SetCollision(false,false,false);
        TriggerEvent( Event, self , DummyPawn);
        //PostNetReceive();
        Spawn( EffectWhenDestroyed, Owner,, Location );
        AdjustedLoc = Location;
        AdjustedLoc.Z += 0.5 * collisionHeight;

		if (bExplosive)
			HurtRadius( ExplosionDamage, ExplosionRadius, ExplosionDamType, ExplosionForce, Location );

		if ( Role == ROLE_Authority )
		{
			if( (DestroyedContents!=None) && !Level.bStartup )
			{
				DroppedPickup = Spawn(DestroyedContents,,,AdjustedLoc );
				if( !bContentsRespawn && DroppedPickup!=None )
					DroppedPickup.RespawnTime = 0;
			}
		}
	}

    function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
    {
        if ( Instigator != None )
            MakeNoise(1.0);

        if (bNeedsSingleShot)
        {
            if (Damage > Health)
                BreakApart(HitLocation, Momentum);
        }
        else
        {
            Health -= Damage;
            if ( Health < 0 )
                BreakApart(HitLocation, Momentum);
        }
    }

    function Bump( actor Other )
    {
        if ( Mover(Other) != None && Mover(Other).bResetting )
            return;

        if ( UnrealPawn(Other)!=None && bImperviusToPlayer )
            return;

        if ( VSize(Other.Velocity)>500 )
            BreakApart(Other.Location, Other.Velocity);
    }

    function bool EncroachingOn(Actor Other)
    {
        if ( Mover(Other) != None && Mover(Other).bResetting )
            return false;

        BreakApart(Other.Location, Other.Velocity);
        return false;
    }


    event EncroachedBy(Actor Other)
    {
        if ( Mover(Other) != None && Mover(Other).bResetting )
            return;

        BreakApart(Other.Location, Other.Velocity);
    }
}


state Broken
{
    function BeginState()
    {
        super.BeginState();
       if(RespawnTime > 0)
        SetTimer(RespawnTime,false);
    }

    event Timer()
    {
        local pawn p;
        super.Timer();

        foreach RadiusActors(class'Pawn', P, CollisionRadius * 1.25)
        {
            SetTimer(5,false);
            return;
        }

        GotoState('Working');
    }
}

simulated function PostNetReceive()
{
    if ( bHidden && EffectWhenDestroyed != none && EffectIsRelevant(location,false) )
        Spawn( EffectWhenDestroyed, Owner,, Location );
}


/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;

    if( bHurtEntry )
        return;

    bHurtEntry = true;
    foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {
        // don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
        if( (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
        {
            dir = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dir));
            dir = dir/dist;
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

            Victims.TakeDamage
            (
                damageScale * DamageAmount,
                Instigator,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                (damageScale * Momentum * dir),
                DamageType
            );

        }
    }
    bHurtEntry = false;
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bImperviusToPlayer=True
     bDamageable=True
     CullDistance=4500.000000
     bStatic=False
     bNoDelete=True
     bStasis=False
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=1.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockKarma=True
     bNetNotify=True
     bFixedRotationDir=True
     bEdShouldSnap=True
}
