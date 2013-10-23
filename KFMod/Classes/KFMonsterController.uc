class KFMonsterController extends MonsterController;
// Custom Zombie Thinkerating
// By : Alex

var KFMonster KFM;

var int MoanTime,ThreatTime;
var bool ItsSet,bUseFreezeHack,bAboutToGetDoor,bTriggeredFirstEvent;
var int TimeToSet;
var int EvaluateTime;
var float ChargeStart,LastCorpseTime;
var byte NumAttmpts;
var byte CorpseBiteCount;

var KFDoorMover TargetDoor;
var PlayerDeathMark TargetCorpse;
var KActor KickTarget;

var Actor InitialPathGoal;
var byte PathFindState;

// Used for alternative pathing:
var Actor LastResult;
var NavigationPoint BlockedWay,ExtraCostWay;

var float		NearMult, FarMult;		// multipliers for startle collision distances
var KFMonster   AvoidMonster;			// vehicle we are currently avoiding
var actor		StartleActor;           // Actor we're moving away from because it startled us

var vector GetOutOfTheWayDirection;     // When told to get out of the way of an incoming shot, this is the direction the shot is coming from
var vector GetOutOfTheWayOrigin;        // When told to get out of the way of an incoming shot, this is where the shot game from

struct KillAssistant
{
	var	Controller 	PC;
	var	float		Damage;
};

var	array<KillAssistant>	KillAssistants;	// List of Controllers who damaged the specimen

/* Should this monster query the pawns he is attacking to assess threat priority?   -  NOTE:   currently only enabled in story mode gametype*/
var bool                    bUseThreatAssessment;
var PathNode                ScriptedMoveTarget;

function Restart()
{
	KFM = KFMonster(Pawn);
	if( !KFM.bStartUpDisabled )
		Super.Restart();
}

function Reset()
{
    StartleActor = none;
	Super.Reset();
}

event bool NotifyBump(actor Other)
{
	local Pawn P;

	Disable('NotifyBump');
	P = Pawn(Other);
	if ( (P == None) || (P.Controller == None) || (Enemy == P) )
		return false;
	if ( SetEnemy(P) )
	{
		WhatToDoNext(4);
		return false;
	}

	if ( Enemy == P )
		return false;

	if ( !AdjustAround(P) )
		CancelCampFor(P.Controller);
	return false;
}

event SeePlayer(Pawn SeenPlayer)
{
	if ( ((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) && SetEnemy(SeenPlayer) )
		WhatToDoNext(3);
	if ( Enemy == SeenPlayer )
	{
		VisibleEnemy = Enemy;
		EnemyVisibilityTime = Level.TimeSeconds;
		bEnemyIsVisible = true;
	}
}

// Overridden because we want our Zeds to be a bit more scared of fear spots
function FearThisSpot(AvoidMarker aSpot)
{
	if ( Skill > 1 + 2.0 * FRand() )
        super(Controller).FearThisSpot(aSpot);
}

// Make the AI try and stay away from this Monster
function AvoidThisMonster(KFMonster Feared)
{
	GoalString = "VEHICLE AVOID!";
	AvoidMonster = Feared;
	GotoState('MonsterAvoid');
}

// This state currently only used in KFO-FrightYard to force Zeds into the toxic pit.
// State is activated by KFVolume_ZedPit, when touched by a Zed.
state ScriptedMoveTo
{
    ignores TakeDamage, SeePlayer, HearNoise, SeeMonster, Bump, HitWall, Touch;

    function BeginState()
    {
        //log( self$" MoveToNodeGoal BeginState" );
    }

Begin:
    if( Pawn.Physics == PHYS_Falling )
    {
        WaitForLanding();
    }
    if( ActorReachable( ScriptedMoveTarget ) )
    {
        MoveToward( ScriptedMoveTarget );
        Goto( 'Begin' );
    }
    else if( FindBestPathToward( ScriptedMoveTarget, false, false ) )
    {
        MoveToward( MoveTarget );
        Goto( 'Begin' );
    }
    else
    {
        Sleep( 0.1f );
        Goto( 'Begin' );
    }
}

// State for being scared of something, the bot attempts to move away from it
state MonsterAvoid
{
	ignores EnemyNotVisible,SeePlayer,HearNoise;

	function AvoidThisMonster(KFMonster Feared)
	{
		GoalString = "AVOID MONSTER!";
		// Switch to the new guy if he is closer
		if (VSizeSquared(Pawn.Location - Feared.Location) < VSizeSquared(Pawn.Location - AvoidMonster.Location))
		{
			AvoidMonster = Feared;
			BeginState();
		}
	}

	function BeginState()
	{
		SetTimer(0.4,true);
	}

	event Timer()
	{
		local vector dir, side;
		local float dist;

		if ( AvoidMonster == None || AvoidMonster.Velocity dot (Pawn.Location - AvoidMonster.Location) < 0)
		{
                WhatToDoNext(11);

			return;
		}
		Pawn.bIsWalking = false;
		Pawn.bWantsToCrouch = False;
		dir = Pawn.Location - AvoidMonster.Location;
		dist = VSize(dir);
		if (dist <= AvoidMonster.CollisionRadius*NearMult)
			HitTheDirt();
		else if (dist < AvoidMonster.CollisionRadius*FarMult)
		{
			side = dir cross vect(0,0,1);
			// pick the shortest direction to move to
			if (side dot AvoidMonster.Velocity > 0)
				Destination = Pawn.Location + (-Normal(side) * (AvoidMonster.CollisionRadius*FarMult));
			else
				Destination = Pawn.Location + (Normal(side) * AvoidMonster.CollisionRadius*FarMult);

			GoalString = "AVOID VEHICLE!   Moving my arse..";
		}
	}

	function HitTheDirt()
	{
		local vector dir, side;

		GoalString = "AVOID Monster!   Jumping!!!";
		dir = Pawn.Location - AvoidMonster.Location;
		side = dir cross vect(0,0,1);
		Pawn.Velocity = Pawn.AccelRate * Normal(side);
		// jump the other way if its shorter
		if (side dot AvoidMonster.Velocity > 0)
			Pawn.Velocity = -Pawn.Velocity;
		Pawn.Velocity.Z = Pawn.JumpZ;
		bPlannedJump=True;
		Pawn.SetPhysics(PHYS_Falling);
	}

	function EndState()
	{
		bTimerLoop = False;
		AvoidMonster=None;
		Focus=None;
	}

Begin:
	WaitForLanding();
	MoveTo(Destination,AvoidMonster,False);
	if (AvoidMonster == None || VSize(Pawn.Location - AvoidMonster.Location) > AvoidMonster.CollisionRadius*FarMult || AvoidMonster.Velocity dot (Pawn.Location - AvoidMonster.Location) < 0)
	{
            WhatToDoNext(11);

		warn("!! " @ Pawn.GetHumanReadableName() @ " STUCK IN AVOID MONSTER !!");
		GoalString = "!! STUCK IN AVOID MONSTER !!";
	}
	Sleep(0.2);
	GoTo('Begin');

}

// Something is shooting along a line, get out of the way of that line
function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin)
{
    GetOutOfTheWayDirection = ShotDirection;
    GetOutOfTheWayOrigin = ShotOrigin;
    if( KFMonster(Pawn) != none && KFMonster(Pawn).CanGetOutOfWay() &&
        !IsInState('GettingOutOfTheWayOfShot'))
    {
        GotoState('GettingOutOfTheWayOfShot');
    }
}

// State for being scared of something, the bot attempts to move away from it
state GettingOutOfTheWayOfShot
{
	ignores EnemyNotVisible,SeePlayer,HearNoise;

	function HitTheDirt()
	{
		local vector dir, side;

		GoalString = "AVOID Shot!   Jumping!!!";

		dir = GetOutOfTheWayDirection;
		side = dir cross vect(0,0,1);

		Pawn.Velocity = Pawn.JumpZ * 0.5 * Normal(side);

		// jump the other way if its shorter
		if ( side dot (Pawn.Location - GetOutOfTheWayOrigin) < 0)
			Pawn.Velocity = -Pawn.Velocity;
		Pawn.Velocity.Z = Pawn.JumpZ * 0.5;
		bPlannedJump=True;
		Pawn.SetPhysics(PHYS_Falling);
	}

Begin:
	WaitForLanding();
	HitTheDirt();
	Sleep(0.2);
	WhatToDoNext(11);
}

// Something has startled this actor and they want to stay away from it
function Startle(Actor Feared)
{
	if ( Monster(Pawn) != none && !Monster(Pawn).bShotAnim && Skill > 1 + 2.0 * FRand() )
    {
    	GoalString = "STARTLED!";
    	StartleActor = Feared;
    	GotoState('Startled');
	}
}

state Startled
{
	ignores EnemyNotVisible,SeePlayer,HearNoise;

	function Startle(Actor Feared)
	{
		GoalString = "STARTLED!";
		StartleActor = Feared;
		BeginState();
	}

	function BeginState()
	{
		// FIXME - need FindPathAwayFrom()
		Pawn.Acceleration = Pawn.Location - StartleActor.Location;
		Pawn.Acceleration.Z = 0;
		Pawn.bIsWalking = false;
		Pawn.bWantsToCrouch = false;
		if ( Pawn.Acceleration == vect(0,0,0) )
			Pawn.Acceleration = VRand();
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);
	}
Begin:
	Sleep(0.5);
	WhatToDoNext(11);
	Goto('Begin');
}


// Randomly plays a different moan sound for the Zombie each time it is called. Gruesome!
function ZombieMoan()
{
	if( Pawn==None || Pawn.Health<=0 )
		Destroy();
	else if( !KFM.bDecapitated ) // Headless zombies can't moan.
		KFM.ZombieMoan();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetCombatTimer();
	if ( UnrealMPGameInfo(Level.Game).bSoaking )
		bSoaking = true;
	MoanTime = Level.TimeSeconds + 2 + (36*FRand());
	EvaluateTime = Level.TimeSeconds;
	TimeToSet = Level.TimeSeconds;
	ItsSet=false;

    /* Kind of a hack, but it's the safest way to toggle Threat assessment behaviour right now .. */
    if(KFGameType(Level.Game) != none &&
    KFGameType(Level.Game).bUseZEDThreatAssessment)
    {
        bUseThreatAssessment = true;
    }
}

// Get rid of this Zed if he's stuck somewhere and noone has seen him
function bool CanKillMeYet()
{
    if( KFMonster(Pawn) != none &&
        KFGameType(Level.Game).WaveNum >= KFGameType(Level.Game).FinalWave )
    {
        return true;
    }

    if( KFMonster(Pawn) != none &&
        (Level.TimeSeconds - KFMonster(Pawn).LastSeenOrRelevantTime) > 8 )
    {
        return true;
    }

    return false;
}

function BreakUpDoor( KFDoorMover Other, bool bTryDistanceAttack ) // I have came up to a door, break it!
{
	TargetDoor = Other;
	if( Pawn != none && KFMonster(Pawn) != none )
    {
        if( KFMonster(Pawn).bCanDistanceAttackDoors && bTryDistanceAttack )
        {
            KFMonster(Pawn).bDistanceAttackingDoor = true;
        }
        else
        {
            KFMonster(Pawn).bDistanceAttackingDoor = false;
        }
    }
	GoalString = "DOORBASHING";
	GotoState('DoorBashing');
}

// The Times between each call of the ZombieMoan function ...
function tick(float DeltaTime)
{
	if( Level.TimeSeconds >= MoanTime )
	{
		ZombieMoan();
		MoanTime = Level.TimeSeconds + 12 + (FRand()*8);
	}
	if( bAboutToGetDoor )
	{
		bAboutToGetDoor = False;
		if( TargetDoor!=None )
		{
        	BreakUpDoor(TargetDoor, true);
		}
	}
}

// If we're not dead, and we can see our target, and we still have a head. lets go eat it.
function bool FindFreshBody()
{
	local KFGameType K;
	local int i;
	local PlayerDeathMark Best;
	local float Dist,BDist;

	K = KFGameType(Level.Game);
	if( K==None || KFM.bDecapitated || !KFM.bCannibal || (!Level.Game.bGameEnded && Pawn.Health>=(Pawn.Default.Health*1.5)) )
		Return False;
	for( i=0; i<K.DeathMarkers.Length; i++ )
	{
		if( K.DeathMarkers[i]==None )
			Continue;
		Dist = VSize(K.DeathMarkers[i].Location-Pawn.Location);
		if( Dist<800 && ActorReachable(K.DeathMarkers[i]) && (Best==None || Dist<BDist) )
		{
			Best = K.DeathMarkers[i];
			BDist = Dist;
		}
	}
	if( Best==None )
		Return False;
	TargetCorpse = Best;
	GoToState('CorpseFeeding');
	Return True;
}


function bool FindNewEnemy()
{
	local Pawn BestEnemy;
	local bool bSeeBest;
	local float BestDist, NewDist;
	local Controller PC;
	local KFHumanPawn Human;
	local float HighestThreatLevel,ThreatLevel;

	if( KFM.bNoAutoHuntEnemies )
		Return False;

	for ( PC=Level.ControllerList; PC!=None; PC=PC.NextController )
	{
        Human = KFHumanPawn(PC.Pawn);

		if(Human != none &&
          Human.Health > 0 &&
          !Human.bPendingDelete)
		{
            /* New Monster Threat logic ------------------------------------------

            currently only used in story mode missions -  Gives the pawn a chance to
            adjust the amount of interest ZEDs take in attacking him.
            */

            if(bUseThreatAssessment)
            {
                ThreatLevel = Human.AssessThreatTo(self,true);
                if(ThreatLevel <= 0)
                {
                    continue;
                }
                else if(ThreatLevel > HighestThreatLevel)
                {
                    HighestThreatLevel = ThreatLevel;
                    BestEnemy = Human;
                    bSeeBest = CanSee(Human);
                }
            }
            else  // Dont use threat assessment.  Fall back on the old Distance based stuff.
            {
			    NewDist = VSizeSquared(Human.Location - Pawn.Location);
				if( BestEnemy == none || (NewDist < BestDist) )
				{
                    BestEnemy = Human;
                    BestDist = NewDist;
                }
		    }
		}
	}

	if ( BestEnemy == Enemy )
		return false;

	if ( BestEnemy != None )
	{
		ChangeEnemy(BestEnemy,bSeeBest);
		return true;
	}

	return false;
}


// TODO - Is this the best way to deal with enemies we can't see?
function EnemyNotVisible();

function Timer();

function DoCharge()
{
	if(pawn != none)
	{
		if ( Enemy.PhysicsVolume.bWaterVolume )
		{
			if ( !Pawn.bCanSwim )
			{
				DoTacticalMove();
				return;
			}
		}
		else
		{
			if (KFM.MeleeRange != KFM.default.MeleeRange)
				KFM.MeleeRange = KFM.default.MeleeRange;
			GotoState('ZombieCharge');
		}
	}
}

function DoTacticalMove();

function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
	local vector Dummy;

	RouteCache[1] = None;
	if( A==None )
		Return False; // Shouldn't get to this, but just in case.
	if ( !bCheckedReach && ActorReachable(A) )
		MoveTarget = A;
	else
	{
		// Sometimes they may attempt to find another way around if this way leads to i.e. a welded door.
		if( ExtraCostWay!=None )
			ExtraCostWay.ExtraCost+=200;
		if( BlockedWay!=None )
		{
			BlockedWay.ExtraCost+=10000;
			MoveTarget = FindPathToward(A);
			BlockedWay.ExtraCost-=10000;
		}
		else MoveTarget = FindPathToward(A);
		if( ExtraCostWay!=None )
			ExtraCostWay.ExtraCost-=200;
		if( MoveTarget!=None )
		{
			if( LastResult==MoveTarget && NavigationPoint(MoveTarget)!=None && NumAttmpts>3 && FRand()<0.6 )
			{
				BlockedWay = NavigationPoint(MoveTarget);
				LastResult = None;
				NumAttmpts = 0;
				return FindBestPathToward(A,True,bAllowDetour);
			}
			else if( LastResult==MoveTarget )
				NumAttmpts++;
			else NumAttmpts = 0;
			LastResult = MoveTarget;
			if( NavigationPoint(MoveTarget)!=None && KFMonster(Trace(Dummy,Dummy,MoveTarget.Location,Pawn.Location,True))!=None )
			{
				ExtraCostWay = NavigationPoint(MoveTarget);
				ExtraCostWay.ExtraCost+=200;
				MoveTarget = FindPathToward(A); // Might consider taking another path if zombie is blocking this one.
				ExtraCostWay.ExtraCost-=200;
			}
		}
	}
	if ( MoveTarget!=None )
	{
		if( RouteCache[1]!=None && ActorReachable(RouteCache[1]) )
			MoveTarget = RouteCache[1];
		if( KFM.bCanDistanceAttackDoors )
		{
			A = Trace(Dummy,Dummy,MoveTarget.Location,Pawn.Location,False);
			if( KFDoorMover(A)!=None && KFDoorMover(A).bSealed )
			{
				TargetDoor = KFDoorMover(A);
				bAboutToGetDoor = True;
			}
		}
		return true;
	}
	else
	{
		if ( (A == Enemy) && (A != None) )
		{
			FailedHuntTime = Level.TimeSeconds;
			FailedHuntEnemy = Enemy;
		}
		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND BEST PATH TO "$A);
	}
	return false;
}

/* Threat Assessment Logic - Returns true if there's a player nearby who has a higher threat level
than the current enemy.  Probably means this ZED should break off and attack it */

function bool EnemyThreatChanged()
{
    local Controller PC;
    local KFHumanPawn C;
    local float NewThreat,CurrentThreat;

    if(!bUseThreatAssessment)
    {
        return false;
    }

    if(KFHumanPawn(Enemy) != none)
    {
        CurrentThreat = KFHumanPawn(Enemy).AssessThreatTo(self);
	}

    /* Current Enemy is of no threat suddenly */
	if(CurrentThreat <= 0)
	{
        return true;
	}

    /* There's another guy nearby with a greater threat than me */
    for ( PC=Level.ControllerList; PC!=None; PC=PC.NextController )
	{
		C = KFHumanPawn(PC.Pawn);
		if(C == none || C == Enemy)
		{
		    continue;
		}
		NewThreat = C.AssessThreatTo(self);
        if(NewThreat > CurrentThreat)
		{
            return true;
        }
    }

    return false;
}

function FightEnemy(bool bCanCharge)
{
	if( KFM.bShotAnim )
	{
		GoToState('WaitForAnim');
		Return;
	}
	if (KFM.MeleeRange != KFM.default.MeleeRange)
		KFM.MeleeRange = KFM.default.MeleeRange;

	if ( Enemy == none || Enemy.Health <= 0 || EnemyThreatChanged())
		FindNewEnemy();

	if ( (Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime) )
	{
	//	if ( Enemy.Controller.bIsPlayer )
		//	FindNewEnemy();

		if ( Enemy == FailedHuntEnemy )
		{
                        GoalString = "FAILED HUNT - HANG OUT";
			if ( EnemyVisible() )
				bCanCharge = false;
		}
	}
	if ( !EnemyVisible() )
	{
		GoalString = "Hunt";
		GotoState('ZombieHunt');
		return;
	}

	// see enemy - decide whether to charge it or strafe around/stand and fire
	Target = Enemy;
	GoalString = "Charge";
	PathFindState = 2;
	DoCharge();
}

state ZombieRoam extends Roaming
{
	function Timer()
	{
		if(Pawn.Velocity == vect(0,0,0))
			GotoState('ZombieRestFormation','Moving');
	}
}

state ZombieHunt extends Hunting
{
	function BeginState()
	{
		local float ZDif;

		if( Pawn.CollisionRadius>27 || Pawn.CollisionHeight>46 )
		{
			ZDif = Pawn.CollisionHeight-44;
			Pawn.SetCollisionSize(24,44);
			Pawn.MoveSmooth(vect(0,0,-1)*ZDif);
		}
	}
	function EndState()
	{
		local float ZDif;

		if( Pawn != none && Pawn.CollisionRadius!=Pawn.Default.CollisionRadius || Pawn.CollisionHeight!=Pawn.Default.CollisionHeight )
		{
			ZDif = Pawn.Default.CollisionRadius-44;
			Pawn.MoveSmooth(vect(0,0,1)*ZDif);
			Pawn.SetCollisionSize(Pawn.Default.CollisionRadius,Pawn.Default.CollisionHeight);
		}
	}
	function Timer()
	{
		if(Pawn.Velocity == vect(0,0,0))
			GotoState('ZombieRestFormation','Moving');
		SetCombatTimer();
		StopFiring();
	}
	function PickDestination()
	{
		local vector nextSpot, ViewSpot,Dir;
		local float posZ;
		local bool bCanSeeLastSeen;

		if( FindFreshBody() )
			Return;
		if ( (Enemy != None) && !KFM.bCannibal && (Enemy.Health <= 0) )
		{
			Enemy = None;
			WhatToDoNext(23);
			return;
		}
		if( PathFindState==0 )
		{
			InitialPathGoal = FindRandomDest();
			PathFindState = 1;
		}
		if( PathFindState==1 )
		{
			if( InitialPathGoal==None )
				PathFindState = 2;
			else if( ActorReachable(InitialPathGoal) )
			{
				MoveTarget = InitialPathGoal;
				PathFindState = 2;
				Return;
			}
			else if( FindBestPathToward(InitialPathGoal, true,true) )
				Return;
			else PathFindState = 2;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;

		if( KFM.Intelligence==BRAINS_Retarded && FRand()<0.25 )
		{
			Destination = Pawn.Location+VRand()*200;
			Return;
		}
		if ( ActorReachable(Enemy) )
		{
			Destination = Enemy.Location;
			if( KFM.Intelligence==BRAINS_Retarded && FRand()<0.5 )
			{
				Destination+=VRand()*50;
				Return;
			}
			MoveTarget = None;
			return;
		}

        ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
        bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

        if ( FindBestPathToward(Enemy, true,true) )
            return;

        if ( bSoaking && (Physics != PHYS_Falling) )
            SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

        MoveTarget = None;
        if ( !bEnemyInfoValid )
        {
            Enemy = None;
            GotoState('StakeOut');
            return;
        }

        Destination = LastSeeingPos;
        bEnemyInfoValid = false;
        if ( FastTrace(Enemy.Location, ViewSpot)
            && VSize(Pawn.Location - Destination) > Pawn.CollisionRadius )
            {
                SeePlayer(Enemy);
                return;
            }

        posZ = LastSeenPos.Z + Pawn.CollisionHeight - Enemy.CollisionHeight;
        nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CollisionRadius;
        nextSpot.Z = posZ;
        if ( FastTrace(nextSpot, ViewSpot) )
            Destination = nextSpot;
        else if ( bCanSeeLastSeen )
        {
            Dir = Pawn.Location - LastSeenPos;
            Dir.Z = 0;
            if ( VSize(Dir) < Pawn.CollisionRadius )
            {
                Destination = Pawn.Location+VRand()*500;
                return;
            }
            Destination = LastSeenPos;
        }
        else
        {
            Destination = LastSeenPos;
            if ( !FastTrace(LastSeenPos, ViewSpot) )
            {
                // check if could adjust and see it
                if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
                {
                    if ( Pawn.Physics == PHYS_Falling )
                        SetFall();
                    else
                        GotoState('Hunting', 'AdjustFromWall');
                }
                else
                {
                    Destination = Pawn.Location+VRand()*500;
                    return;
                }
            }
        }
    }
}

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local KFMonster Monster;

    // Get ticked and attack nearby bloats because you think they puked on you!
    if(class<DamTypeBlowerThrower>(DamageType)!=none && Damage > 0)
    {
        foreach VisibleCollidingActors( class 'KFMonster', Monster, 1000, Pawn.Location )
     	{
    	   if( Monster.IsA('ZombieBloatBase') && Monster != Pawn && KFHumanPawn(instigatedBy) != none )
    	   {
    	        if( KFMonster(Pawn) != none )
    	        {
                    SetEnemy(Monster,true,KFMonster(Pawn).HumanBileAggroChance);
    	        }
    	        return;
    	   }
    	}
    }

	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);
}

state ZombieCharge extends Charging
{
	function SeePlayer( Pawn Seen )
	{
		if( KFM.Intelligence==BRAINS_Human )
			SetEnemy(Seen);
	}
	function DamageAttitudeTo(Pawn Other, float Damage)
	{
		if( KFM.Intelligence>=BRAINS_Mammal && Other!=None && SetEnemy(Other) )
			SetEnemy(Other);
	}
	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if( KFM.Intelligence==BRAINS_Human && NoiseMaker.Instigator!=None && FastTrace(NoiseMaker.Location,Pawn.Location) )
			SetEnemy(NoiseMaker.Instigator);
	}
	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		return false;
	}

	// I suspect this function causes bloats to get confused
	function bool TryStrafe(vector sideDir)
	{
		return false;
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		local KFMonster Monster;

        // Get ticked and attack nearby bloats because you think they puked on you!
        if(class<DamTypeBlowerThrower>(DamageType)!=none && Damage > 0)
        {
            foreach VisibleCollidingActors( class 'KFMonster', Monster, 1000, Pawn.Location )
         	{
        	   if( Monster.IsA('ZombieBloatBase') && Monster != Pawn && KFHumanPawn(instigatedBy) != none )
        	   {
        	        if( KFMonster(Pawn) != none )
        	        {
                        SetEnemy(Monster,true,KFMonster(Pawn).HumanBileAggroChance);
        	        }
        	        return;
        	   }
        	}
        }

		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
    }

Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if ( Enemy == None )
		WhatToDoNext(16);
WaitForAnim:
	While( KFM.bShotAnim )
		Sleep(0.35);
	if ( !FindBestPathToward(Enemy, false,true) )
		GotoState('TacticalMove');
Moving:
	if( KFM.Intelligence==BRAINS_Retarded )
	{
		if( FRand()<0.3 )
			MoveTo(Pawn.Location+VRand()*200,None);
		else if( MoveTarget==Enemy && FRand()<0.5 )
			MoveTo(MoveTarget.Location+VRand()*50,None);
		else MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	}
	else MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}


function CheckIfShouldCrouch(vector StartPosition, vector TargetPosition, float probability);

function InitializeSkill(float InSkill);

function ResetSkill();

// Randomize their speeds a bit.
function SetMaxDesiredSpeed()
{
	Pawn.MaxDesiredSpeed = 0.9+FRand()*0.2;
}

function SetPeripheralVision();

// TODO: zombies commit suicide. Is this right that they do so?
function bool FindRoamDest()
{
	local actor BestPath;

	if ( Pawn.FindAnchorFailedTime == Level.TimeSeconds )
	{
		// couldn't find an anchor.
		GoalString = "No anchor "$Level.TimeSeconds;
		if ( Pawn.LastValidAnchorTime > 5 )
		{
			if ( bSoaking )
				SoakStop("NO PATH AVAILABLE!!!");
			else
			{
				if ( NumRandomJumps > 5 )
				{
					Pawn.Health = 0;
					Pawn.Died( self, class'Suicided', Pawn.Location );
					return true;
				}
                else
                {
                    // jump
                    NumRandomJumps++;
                    if ( Physics != PHYS_Falling )
                    {
                        Pawn.SetPhysics(PHYS_Falling);
                       // Pawn.Velocity = 0.5 * Pawn.GroundSpeed * VRand();
                        Pawn.Velocity.Z = Pawn.JumpZ;
                    }
                }
            }
        }
        //log(self$" Find Anchor failed!");
        return false;
    }
    NumRandomJumps = 0;
    GoalString = "Find roam dest "$Level.TimeSeconds;
    // find random NavigationPoint to roam to
    if ( (RouteGoal == None) || (Pawn.Anchor == RouteGoal)
        || Pawn.ReachedDestination(RouteGoal) )
    {
        RouteGoal = FindRandomDest();
        BestPath = RouteCache[0];
        if ( RouteGoal == None )
        {
            if ( bSoaking && (Physics != PHYS_Falling) )
                SoakStop("COULDN'T FIND ROAM DESTINATION");
            return false;
        }
    }
    if ( BestPath == None )
        BestPath = FindPathToward(RouteGoal,false);
    if ( BestPath != None )
    {
        MoveTarget = BestPath;
        GotoState('ZombieRoam');
        return true;
    }
    if ( bSoaking && (Physics != PHYS_Falling) )
        SoakStop("COULDN'T FIND ROAM PATH TO "$RouteGoal);
    RouteGoal = None;
    return false;
}

function DirectedWander(vector WanderDir)
{
	GoalString = "DIRECTED WANDER "$GoalString;
	if ( TestDirection(WanderDir,Destination) )
		GotoState('ZombieRestFormation', 'Moving');
	else GotoState('ZombieRestFormation', 'Begin');
}

function WanderOrCamp(bool bMayCrouch)
{
	if( KFM.bNoAutoHuntEnemies )
		GoToState('WaitToStart');
	else FindRoamDest();
}

state ZombieRestFormation extends RestFormation
{
ignores EnemyNotVisible;

	function CancelCampFor(Controller C)
	{
		DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
	}

	function bool Formation()
	{
		return true;
	}
	function Timer()
	{
		if(Pawn.Velocity == vect(0,0,0))
			Gotostate('ZombieRestFormation','Moving');
		SetCombatTimer();
		disable('NotifyBump');
	}
	function PickDestination()
	{
		local vector nextSpot, ViewSpot,Dir;
		local float posZ;
		local bool bCanSeeLastSeen;

		if ( TestDirection(VRand(),Destination) )
		{
			// If we're not a cannibal.  dont munch
			if ( (Enemy != None) && !KFM.bCannibal && (Enemy.Health <= 0) )
			{
				Enemy = None;
				WhatToDoNext(23);
				return;
			}

			if ( Pawn.JumpZ > 0 )
				Pawn.bCanJump = true;

			if ( Enemy!=None && ActorReachable(Enemy) )
			{
				Destination = Enemy.Location;
				MoveTarget = None;
				return;
			}

			ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
			bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

			if ( Enemy!=None && FindBestPathToward(Enemy, true,true) )
				return;

			if ( bSoaking && (Physics != PHYS_Falling) )
				SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

			MoveTarget = None;
			if ( Enemy==None || !bEnemyInfoValid )
			{
				Enemy = None;
				WhatToDoNext(26);
				return;
			}

			Destination = LastSeeingPos;
			bEnemyInfoValid = false;
			if ( FastTrace(Enemy.Location, ViewSpot) && VSize(Pawn.Location - Destination) > Pawn.CollisionRadius )
			{
				SeePlayer(Enemy);
				return;
			}

			posZ = LastSeenPos.Z + Pawn.CollisionHeight - Enemy.CollisionHeight;
			nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CollisionRadius;
			nextSpot.Z = posZ;
			if ( FastTrace(nextSpot, ViewSpot) )
				Destination = nextSpot;
			else if ( bCanSeeLastSeen )
			{
				Dir = Pawn.Location - LastSeenPos;
				Dir.Z = 0;
				if ( VSize(Dir) < Pawn.CollisionRadius )
				{
					GoalString = "Stakeout 3 from hunt";
					GotoState('StakeOut');
					return;
				}
				Destination = LastSeenPos;
			}
			else
			{
				Destination = LastSeenPos;
				if ( !FastTrace(LastSeenPos, ViewSpot) )
				{
					// check if could adjust and see it
					if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
					{
						if ( Pawn.Physics == PHYS_Falling )
							SetFall();
						else
							GotoState('Hunting', 'AdjustFromWall');
					}
					else
					{
						GoalString = "Stakeout 2 from hunt";
						GotoState('StakeOut');
						return;
					}
				}
			}
		}
		else TestDirection(VRand(),Destination);
	}

    function BeginState()
    {
       // Enemy = None;
        //Pawn.bAvoidLedges = true;
        //Pawn.bStopAtLedges = true;
        //Pawn.SetWalking(true);
        MinHitWall += 0.15;
    }



    function EndState()
    {
        //MonitoredPawn = None;
        MinHitWall -= 0.15;
        if ( Pawn != None )
        {
            if (Pawn.JumpZ > 0)
                Pawn.bCanJump = true;
        }
    }

	function bool FindViewSpot()
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		// try left and right

		if ( Enemy!=None && FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		if ( Enemy!=None && FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}
		if ( FRand() < 0.5 )
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
		else
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
		return true;
	}

    event MonitoredPawnAlert()
    {
        WhatToDoNext(6);
    }

Begin:
    WaitForLanding();
Camping:
    //Pawn.Acceleration = vect(0,0,0);
    Focus = None;
    FocalPoint = VRand();
    NearWall(MINVIEWDIST);
    FinishRotation();
    Sleep(3 + FRand());
Moving:
//    WaitForLanding();
    PickDestination();
WaitForAnim:
    if ( KFM.bShotAnim )
    {
        Sleep(0.5);
        Goto('WaitForAnim');
    }
    MoveTo(Destination,,true);
    if ( Pawn.bCanFly && (Physics == PHYS_Walking) )
        SetPhysics(PHYS_Flying);
    WhatToDoNext(8);
    Goto('Begin');
}

state DoorBashing extends MoveToGoalNoEnemy
{
ignores EnemyNotVisible,SeeMonster;

	function Timer()
	{
		Disable('NotifyBump');
	}

	function AttackDoor()
	{
		Target = TargetDoor;
		KFM.Acceleration = vect(0,0,0);
		KFM.DoorAttack(Target);
	}
	function SeePlayer( Pawn Seen )
	{
		if( KFM.Intelligence==BRAINS_Human && ActorReachable(Seen) && SetEnemy(Seen) )
			WhatToDoNext(23);
	}
	function DamageAttitudeTo(Pawn Other, float Damage)
	{
		if( KFM.Intelligence>=BRAINS_Mammal && Other!=None && ActorReachable(Other) && SetEnemy(Other) )
			WhatToDoNext(32);
	}
	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if( KFM.Intelligence==BRAINS_Human && NoiseMaker!=None && NoiseMaker.Instigator!=None
		 && ActorReachable(NoiseMaker.Instigator) && SetEnemy(NoiseMaker.Instigator) )
			WhatToDoNext(32);
	}

	function Tick( float Delta )
	{
		Global.Tick(Delta);

        // Don't move while we are bashing a door!
		MoveTarget = None;
		MoveTimer = -1;
		Pawn.Acceleration = vect(0,0,0);
		Pawn.GroundSpeed = 1;
		Pawn.AccelRate = 0;
	}

	function EndState()
	{
		if( Pawn!=None )
		{
			Pawn.AccelRate = Pawn.Default.AccelRate;
			Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
		}
	}

Begin:
	WaitForLanding();

KeepMoving:
	//MoveTarget = TargetDoor;
	//if(MoveTarget!=none)
	//	MoveToward(MoveTarget,FaceActor(1),,false ); //,GetDesiredOffset(),ShouldStrafeTo(MoveTarget));

	While( KFM.bShotAnim )
		Sleep(0.25);
	While( TargetDoor!=none && !TargetDoor.bHidden && TargetDoor.bSealed && !TargetDoor.bZombiesIgnore )
	{
		AttackDoor();
		While( KFM.bShotAnim )
			Sleep(0.25);
		Sleep(0.1);
		if( KFM.Intelligence>=BRAINS_Mammal && Enemy!=None && ActorReachable(Enemy) )
			WhatToDoNext(14);
	}
	WhatToDoNext(152);

Moving:
	MoveToward(TargetDoor);
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}


state CorpseFeeding
{
ignores EnemyNotVisible,SeePlayer,HearNoise,NotifyBump;

    // Don't do this in this state
    function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}

	function Timer()
	{
		Target = TargetCorpse;
		if(Target == none)
			WhatToDoNext(38);
	}
	function AttackCorpse()
	{
		Target = TargetCorpse;
		KFM.CorpseAttack(Target);
	}

Begin:
	WaitForLanding();
	While( TargetCorpse!=None && !ActorReachable(TargetCorpse) )
	{
		if( !FindBestPathToward(TargetCorpse,True,False) )
			WhatToDoNext(33);
		MoveToward(MoveTarget,MoveTarget);
	}
	if( TargetCorpse==None )
		WhatToDoNext(32);
	MoveTo(TargetCorpse.Location+Normal(Pawn.Location-TargetCorpse.Location)*(20+FRand()*20),TargetCorpse);
	if( TargetCorpse==None )
		WhatToDoNext(31);
	Focus = TargetCorpse;
	While( TargetCorpse!=None && (Pawn.Health<(Pawn.Default.Health*1.5) || Level.Game.bGameEnded) )
	{
		AttackCorpse();
		While( KFM.bShotAnim )
			Sleep(0.1);
		if( Enemy!=None && VSize(Enemy.Location-Pawn.Location)<500 && CanSee(Enemy) )
			WhatToDoNext(37); // Can't look, eating.
	}
	WhatToDoNext(30);
}

function WaitForMover(Mover M)
{
    if ( (Enemy != None) && (Level.TimeSeconds - LastSeenTime < M.MoveTime) )
        Focus = Enemy;
    PendingMover = M;
    bPreparingMove = true;
    Pawn.Acceleration = vect(0,0,0);

    StopStartTime = Level.TimeSeconds;
}


function HearNoise(float Loudness, Actor NoiseMaker)
{
	if( NoiseMaker!=none && FastTrace(NoiseMaker.Location,Pawn.Location) )
	{
		if ( ((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) && SetEnemy(NoiseMaker.instigator) )
			WhatToDoNext(2);
	}
}



state Kicking
{
  ignores EnemyNotVisible;

  Begin:


  WaitForAnim:
	if ( KFM.bShotAnim )
	{
	      if(KickTarget!=none)
              {
               //MoveToward(KickTarget,FaceActor(1),,false ); //,GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
               Sleep(0.1);
	       Goto('WaitForAnim');
	      }
	}


	WhatToDoNext(152);
	if ( bSoaking )
		SoakStop("STUCK IN KICKING!!!");
}

state KnockDown
{
  ignores EnemyNotVisible,Startle;

  // Don't do this in this state
  function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}

  Begin:
  Pawn.ShouldCrouch(True);


  WaitForAnim:
	if ( KFM.bShotAnim )
	{
               Sleep(0.1);

	       Goto('WaitForAnim');
	}


	WhatToDoNext(152);
	if ( bSoaking )
		SoakStop("STUCK IN STAGGERED!!!");

 End:
  Pawn.ShouldCrouch(False);

}


function ExecuteWhatToDoNext()
{
	bHasFired = false;
	GoalString = "WhatToDoNext at "$Level.TimeSeconds;
	if ( Pawn == None )
	{
		warn(GetHumanReadableName()$" WhatToDoNext with no pawn");
		return;
	}
	if( KFM.bStartUpDisabled )
	{
		KFM.bStartUpDisabled = False;
		GoToState('WaitToStart');
		Return;
	}
	if( KFM.bShotAnim )
	{
		GoToState('WaitForAnim');
		Return;
	}
	if( Level.Game.bGameEnded && FindFreshBody() )
		Return;
	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics();
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		Enemy = None;

	if ( (Enemy == None) || !EnemyVisible() )
		FindNewEnemy();

	if ( Enemy != None )
		ChooseAttackMode();
	else
	{
		GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
		WanderOrCamp(true);
	}
}

state StakeOut
{
ignores EnemyNotVisible;

	/* DoStakeOut()
	called by ChooseAttackMode - if called in this state, means stake out twice in a row
	*/
	function DoStakeOut()
	{
		SetFocus();
		if ( Enemy!=None && ((FRand() < 0.3) || !FastTrace(FocalPoint + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location + vect(0,0,0.8) * Pawn.CollisionHeight)) )
			FindNewStakeOutDir();
		GotoState('StakeOut','Begin');
	}

	function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
	{
		local vector FireSpot;
		local actor HitActor;
		local vector HitLocation, HitNormal;

		if( Enemy==None )
			Return Pawn.Rotation;

		FireSpot = FocalPoint;

		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if( HitActor != None )
		{
			FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			if ( !FastTrace(FireSpot, ProjStart) )
			{
				FireSpot = FocalPoint;
				StopFiring();
			}
		}

		SetRotation(Rotator(FireSpot - ProjStart));
		return Rotation;
	}
	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		Pawn.Acceleration = vect(0,0,0);
		Pawn.bCanJump = false;
		SetFocus();
		if ( Enemy!=None && (!bEnemyInfoValid || !ClearShot(FocalPoint,false) || ((Level.TimeSeconds - LastSeenTime > 6) && (FRand() < 0.5))) )
			FindNewStakeOutDir();
	}
	function SetFocus()
	{
		if ( bEnemyInfoValid )
			FocalPoint = LastSeenPos;
		else if( Enemy!=None )
			FocalPoint = Enemy.Location;
	}

Begin:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	CheckIfShouldCrouch(Pawn.Location,FocalPoint, 1);
	FinishRotation();
	if ( Enemy!=None && KFM.HasRangedAttack() && (FRand() < 0.5) && (VSize(Enemy.Location - FocalPoint) < 150)
		 && (Level.TimeSeconds - LastSeenTime < 4) && ClearShot(FocalPoint,true) )
		FireWeaponAt(Enemy);
	else StopFiring();
	Sleep(0.4 + FRand()*0.4);
	// check if uncrouching would help
	if ( Pawn.bIsCrouched
		&& !FastTrace(FocalPoint, Pawn.Location + Pawn.EyeHeight * vect(0,0,1))
		&& FastTrace(FocalPoint, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1)) )
	{
		Pawn.bWantsToCrouch = false;
		Sleep(0.4 + FRand()*0.4);
	}
	MoveTo(Pawn.Location+VRand()*80); // Try moving somewhere
	WhatToDoNext(31);
	if ( bSoaking )
		SoakStop("STUCK IN STAKEOUT!");
}

state WaitForAnim
{
Ignores SeePlayer,HearNoise,Timer,EnemyNotVisible,NotifyBump,Startle;

    // Don't do this in this state
    function GetOutOfTheWayOfShot(vector ShotDirection, vector ShotOrigin){}

	event AnimEnd(int Channel)
	{
    	/*local name  Sequence;
    	local float Frame, Rate;


        Pawn.GetAnimParams( KFMonster(Pawn).ExpectingChannel, Sequence, Frame, Rate );

        log(GetStateName()$" AnimEnd for Exp Chan "$KFMonster(Pawn).ExpectingChannel$" = "$Sequence);

        Pawn.GetAnimParams( 0, Sequence, Frame, Rate );
        log(GetStateName()$" AnimEnd for Chan 0 = "$Sequence);

        Pawn.GetAnimParams( 1, Sequence, Frame, Rate );
        log(GetStateName()$" AnimEnd for Chan 1 = "$Sequence);

        log(GetStateName()$" AnimEnd bShotAnim = "$Monster(Pawn).bShotAnim);*/

		Pawn.AnimEnd(Channel);
		if ( !Monster(Pawn).bShotAnim )
			WhatToDoNext(99);
	}

	function BeginState()
	{
		bUseFreezeHack = False;
	}
	function Tick( float Delta )
	{
		Global.Tick(Delta);
		if( bUseFreezeHack )
		{
			MoveTarget = None;
			MoveTimer = -1;
			Pawn.Acceleration = vect(0,0,0);
			Pawn.GroundSpeed = 1;
			Pawn.AccelRate = 0;
		}
	}
	function EndState()
	{
		if( Pawn!=None )
		{
			Pawn.AccelRate = Pawn.Default.AccelRate;
			Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
		}
		bUseFreezeHack = False;
	}

Begin:
	While( KFM.bShotAnim )
	{
    	Sleep(0.15);
	}
	WhatToDoNext(99);
}

function bool SetEnemy( Pawn NewEnemy, optional bool bHateMonster, optional float MonsterHateChanceOverride )
{
    /* This enemy is of absolutely no threat currently, ignore it */
    if(bUseThreatAssessment && KFHumanpawn(NewEnemy) != none &&
    KFHumanpawn(NewEnemy).AssessThreatTo(self) <= 0)
    {
        return false;
    }

	if( !bHateMonster && KFHumanPawnEnemy(NewEnemy)!=None && KFHumanPawnEnemy(NewEnemy).AttitudeToSpecimen<=ATTITUDE_Ignore )
		Return False; // In other words, dont attack human pawns as long as they dont damage me or hates me.

	if( KFM.Intelligence>=BRAINS_Mammal && Enemy!=None && NewEnemy!=None && NewEnemy!=Enemy && NewEnemy.Controller!=None && NewEnemy.Controller.bIsPlayer )
	{
		if( LineOfSightTo(Enemy) && VSize(Enemy.Location-Pawn.Location)<VSize(NewEnemy.Location-Pawn.Location) )
			Return False;
		Enemy = None;
	}

	if( MonsterHateChanceOverride == 0 )
	{
	   MonsterHateChanceOverride = 0.15;
	}

	if( bHateMonster && KFMonster(NewEnemy)!=None && NewEnemy.Controller!=None && (NewEnemy.Controller.Target==Self || FRand()<MonsterHateChanceOverride)
	 && NewEnemy.Health>0 && VSize(NewEnemy.Location-Pawn.Location)<1500 && LineOfSightTo(NewEnemy) ) // Get pissed at this fucker..
	{
        ChangeEnemy(NewEnemy,CanSee(NewEnemy));
		return true;
	}
	if( Super.SetEnemy(NewEnemy,bHateMonster,MonsterHateChanceOverride) )
	{
		if( !bTriggeredFirstEvent )
		{
			bTriggeredFirstEvent = True;
			if( KFM.FirstSeePlayerEvent!='' )
				TriggerEvent(KFM.FirstSeePlayerEvent,Pawn,Pawn);
		}
		Return True;
	}
	Return False;
}
function Celebrate();

State WaitToStart
{
Ignores Tick,Timer,FindNewEnemy,NotifyLanded,DoWaitForLanding;

	function Trigger( actor Other, pawn EventInstigator )
	{
		SetEnemy(EventInstigator,True);
		WhatToDoNext(56);
	}
	function bool SetEnemy( Pawn NewEnemy, optional bool bHateMonster, optional float MonsterHateChanceOverride )
	{
		if( Level.TimeSeconds<1 )
			Return False;
		Return Global.SetEnemy(NewEnemy,bHateMonster,MonsterHateChanceOverride);
	}
	function EndState()
	{
		if( Pawn.Health>0 )
		{
			if( !bTriggeredFirstEvent )
			{
				bTriggeredFirstEvent = True;
				if( KFM.FirstSeePlayerEvent!='' )
					TriggerEvent(KFM.FirstSeePlayerEvent,Pawn,Pawn);
			}
			Pawn.AmbientSound = Pawn.Default.AmbientSound;
		}
	}
Begin:
	Pawn.AmbientSound = None;
	Enemy = None;
	Focus = None;
	FocalPoint = Pawn.Location+vector(Pawn.Rotation)*5000;
	Pawn.Acceleration = vect(0,0,0);
}

function Trigger( actor Other, pawn EventInstigator )
{
	if( SetEnemy(EventInstigator,True) )
		WhatToDoNext(54);
}

simulated event Destroyed()
{
	local int i;

    StartleActor = none;

	for ( i = 0; i < KillAssistants.Length; i++ )
	{
		KillAssistants[i].PC = none;
	}

	KillAssistants.Remove(0, KillAssistants.Length);

	Super.Destroyed();
}

simulated function AddKillAssistant(Controller PC, float Damage)
{
	local bool bIsalreadyAssistant;
	local int i;

	for ( i = 0; i < KillAssistants.Length; i++ )
	{
		if ( PC == KillAssistants[i].PC )
		{
			bIsalreadyAssistant = true;
			KillAssistants[i].Damage += Damage;
			break;
		}
	}

	if ( !bIsalreadyAssistant )
	{
		KillAssistants.Insert(0, 1);
		KillAssistants[0].PC = PC;
		KillAssistants[0].Damage = Damage;
	}
}

defaultproperties
{
     NearMult=1.500000
     FarMult=3.000000
     StrafingAbility=-1.000000
     CombatStyle=1.000000
     ReactionTime=1.000000
}
