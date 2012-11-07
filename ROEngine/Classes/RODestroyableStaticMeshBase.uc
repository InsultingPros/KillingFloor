//===================================================================
// RODestroyableStaticMeshBase
//
// Copyright (C) 2004 John "Ramm-Jaeger"  Gibson
//
// A destroyable/damagable static mesh
//===================================================================

class RODestroyableStaticMeshBase extends Actor
    abstract placeable;

var 		bool 			bDamaged; 			// Static mesh has received enough damage to swap to a damaged mesh
var() 		bool 			bUseDamagedMesh;	// Swap to the damaged mesh when health is <= 0
var 		StaticMesh 		SavedStaticMesh;    // Original static mesh when the game starts
var() 		StaticMesh 		DamagedMesh;        // mesh to swap to when health is <= 0 and bUseDamagedMesh is true

var()  		class<Emitter> 	DestroyedEffect;    // Effects to spawn when health hits 0
var()		vector			DestroyedEffectOffset;
var()		int				Health;             // Health - duh :)
var() array< class<DamageType> > 	TypesCanDamage;     // An array of damage types that will inflict damage on this mesh
var() 		name 			DestroyedEvent;     // event tag to trigger when health hits 0;

var()		bool			bWontStopBullets;

var()		float			DestroyedTime;		// When this thing was destroyed

var()       bool            bShowOnSituationMap;

enum ECriticalMessageBroadcastTarget
{
    CMBT_Nobody,
	CMBT_Everyone,
	CMBT_Teammates,
	CMBT_Enemies,
	CMBT_InstigatorOnly
};

var()       localized string                OnDestroyCriticalMessage;
var() 	    ECriticalMessageBroadcastTarget	OnDestroyBroadcastTarget;

var         name            SavedName;  // Used to let clients know which destroyablestaticmesh
                                        // we're talking about when we're getting the critical
                                        // message.. hax :|

replication
{
	reliable if( bNetInitial && ROLE == ROLE_Authority )
		bUseDamagedMesh, DamagedMesh, DestroyedEffect, bWontStopBullets,DestroyedEffectOffset;
	reliable if( bNetDirty && ROLE == ROLE_Authority )
		Health, SavedStaticMesh, bDamaged, DestroyedTime, SavedName;

}

simulated function string GetOnDestroyCriticalMessage()
{
    local string s;
    //log("GetOnDestroyCriticalMessage called.");
    //log("Looking at localize info for " $ SavedName $ ", " $ string(class) $ ", " $ string(level.outer) );
    s = Localize(string(SavedName), "OnDestroyCriticalMessage", string(level.outer));
    if (s != "")
        return s;
    else
        return default.OnDestroyCriticalMessage;
}

function Reset()
{
	super.Reset();
    Gotostate('Working');
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SavedStaticMesh = StaticMesh;
	SavedName = name;
	disable('tick');
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( EventInstigator != None )
		MakeNoise(1.0);

	Health = 0;
	TriggerEvent(DestroyedEvent, self, EventInstigator);
	BroadcastCriticalMessage(EventInstigator);
	BreakApart(Location);
}

// Check to see if this mesh can recieve damage from a particular damagetype
function bool ShouldTakeDamage( class<DamageType> damageType )
{
	local int i;

	for(i=0; i<TypesCanDamage.Length; i++)
	{

		if(damageType==TypesCanDamage[i] || ClassIsChildOf( damageType, TypesCanDamage[i]))
		{
			return true;
		}
	}
	return false;
}

function BroadcastCriticalMessage(Pawn instigatedBy)
{
	local PlayerReplicationInfo PRI;

	// Broadcast critical message if needed
	if (OnDestroyCriticalMessage != "" && OnDestroyBroadcastTarget != CMBT_Nobody)
    {
        if (Level.game != none)
        {
            if (instigatedBy != none)
            {
                PRI = instigatedBy.PlayerReplicationInfo;
                //if (PRI == none)
                //    log("no valid PRI!!!");
            }
            else
            {
                //log("no valid PRI!!");
                PRI = none;
            }

            Level.game.BroadcastLocalizedMessage(class'RODestroyableSMDestroyedMsg',
                                                OnDestroyBroadcastTarget, PRI,, self);
        }
    }
}

function BreakApart(vector HitLocation, optional vector momentum)
{
    // if we are single player or on a listen server, just spawn the actor, otherwise
	// bHidden will trigger the effect
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( (DestroyedEffect!=None ) /*&& EffectIsRelevant(location,false)*/ )
			Spawn( DestroyedEffect, Owner,, (Location + (DestroyedEffectOffset >> Rotation)));
	}

    gotostate('Broken');
}

auto state Working
{
	function BeginState()
	{
		super.BeginState();

        KSetBlockKarma( false );
		NetUpdateTime = Level.TimeSeconds - 1;
		SetStaticMesh(SavedStaticMesh);
		SetCollision(true,true,true);
		KSetBlockKarma( true );				// Update karma collision

		bHidden = false;
		bDamaged = false;
		Health = default.health;
		DestroyedTime = 0;
	}

	function EndState()
	{
		super.EndState();

		NetUpdateTime = Level.TimeSeconds - 1;

        DestroyedTime = Level.TimeSeconds;

		if( bUseDamagedMesh )
		{
	        KSetBlockKarma( false );

			SetStaticMesh(DamagedMesh);
			SetCollision(true,true,true);
			KSetBlockKarma( true );				// Update karma collision

		    bDamaged = true;
		}
		else
		{
	        	bHidden = true;
	        	SetCollision(false,false,false);
		}
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,	Vector momentum, class<DamageType> damageType, optional int HitIndex)
	{
		if ( !ShouldTakeDamage(damageType))
			return;

		if ( instigatedBy != None )
			MakeNoise(1.0);

		Health -= Damage;
		if ( Health <= 0 )
		{
			TriggerEvent(DestroyedEvent, self, instigatedBy);
			BroadcastCriticalMessage(instigatedBy);
			BreakApart(HitLocation, Momentum);
		}
	}

/*	function Bump( actor Other )
	{
		log("Got bumped by "$Other);

		if ( Mover(Other) != None && Mover(Other).bResetting )
			return;

		if( ROVehicle(Other) != none)
		{
        	log(Other$" hit us");

			if ( VSize(Other.Velocity)>100 )
			{
				BreakApart(Other.Location, Other.Velocity);
			}
		}
	}*/


}

state Broken
{
	function BeginState()
	{
		super.BeginState();
		//NetUpdateFrequency=2;
	}
}

simulated function PostNetReceive()
{
	if ( (bHidden || bDamaged) && DestroyedEffect != none && Level.TimeSeconds - DestroyedTime < 1.5 )
		Spawn( DestroyedEffect, Owner,, (Location + (DestroyedEffectOffset >> Rotation)));
}


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bUseDamagedMesh=True
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DebugObjects.Arrows.debugarrow1'
     bNoDelete=True
     bWorldGeometry=True
     bAlwaysRelevant=True
     bOnlyDirtyReplication=True
     NetUpdateFrequency=0.100000
     bCanBeDamaged=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bCollideActors=True
     bBlockActors=True
     bBlockProjectiles=True
     bProjTarget=True
     bBlockKarma=True
     bNetNotify=True
     bFixedRotationDir=True
     bEdShouldSnap=True
     bPathColliding=True
}
