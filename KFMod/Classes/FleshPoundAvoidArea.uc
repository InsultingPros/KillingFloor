//=============================================================================
// FleshPoundAvoidArea
//=============================================================================
// Custom avoid marker to make other zombies stay away from the Fleshpound
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class FleshPoundAvoidArea extends AvoidMarker;

var KFMonster KFMonst;		// KFMonster this market is attached to -- should be the same as base and owner

state BigMeanAndScary
{
Begin:
	StartleBots();
	Sleep(1.0);
	GoTo('Begin');
}

function InitFor(KFMonster V)
{
	if (V != None)
	{
		KFMonst = V;
		SetCollisionSize(KFMonst.CollisionRadius *3, KFMonst.CollisionHeight + CollisionHeight);
		SetBase(KFMonst);
		GoToState('BigMeanAndScary');
	}
}

function Touch( actor Other )
{
	if ( (Pawn(Other) != None) && RelevantTo(Pawn(Other)) )
	{
		KFMonsterController(Pawn(Other).Controller).AvoidThisMonster(KFMonst);
	}
}

function bool RelevantTo(Pawn P)
{
	return ( KFMonst != none && VSizeSquared(KFMonst.Velocity) >= 75 && Super.RelevantTo(P)
	 && KFMonst.Velocity dot (P.Location - KFMonst.Location) > 0  );
}

function StartleBots()
{
	local KFMonster P;

	if (KFMonst != None)
		ForEach CollidingActors(class'KFMonster', P, CollisionRadius)
			if ( RelevantTo(P) )
			{
				KFMonsterController(P.Controller).AvoidThisMonster(KFMonst);
			}
}

defaultproperties
{
     CollisionRadius=1000.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bBlockHitPointTraces=False
}
