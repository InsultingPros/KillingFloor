class KFFriendlyAI extends MonsterController;

var KFHumanPawnEnemy KFHM;
var Actor MoveGoal;
var bool bStoppedFiring,bFireSuccess;

function Restart()
{
	Super.Restart();
	KFHM = KFHumanPawnEnemy(Pawn);
	Accuracy = KFHM.Accuracy;
	ReactionTime = KFHM.ReactionTime;
	ReSetSkill();
}
function Possess(Pawn aPawn)
{
	Super(AIController).Possess(aPawn);
	InitializeSkill(DeathMatch(Level.Game).AdjustedDifficulty);
	GoToState('InitilizingMe');
	Disable('Tick');
}

State InitilizingMe
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	function SetupFlags()
	{
		Pawn.MaxFallSpeed = 1.1 * Pawn.default.MaxFallSpeed; // so bots will accept a little falling damage for shorter routes
		Pawn.SetMovementPhysics();
		if( Pawn.Physics==PHYS_Walking )
			Pawn.SetPhysics(PHYS_Falling);
		bIsPlayer = True; // Fake player to make zombies attack me, and make me see zombies.
		KFHM.GiveDefaultWeapon();
		enable('NotifyBump');
		Switch( KFHM.SoldierOrders )
		{
			Case ORDER_Guarding:
				GoToState('Waiting');
				Break;
			Case ORDER_Wander:
				GoToState('Wandering');
				Break;
			Case ORDER_Hunt:
				GoToState('ActiveHunting');
				Break;
			Default:
				GoToState('Patroling');
				Break;
		}
	}
Begin:
	Sleep(0.001);
	SetupFlags();
}

// added CanAttack() check to calm trigger-happy bots
function bool FireWeaponAt(Actor A)
{
	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Target = A;

	if ( Pawn.Weapon != None )
	{
		Pawn.Weapon.FillToInitialAmmo();
		if( !Pawn.Weapon.CanAttack(A) )
			return false;
		if ( Pawn.Weapon.HasAmmo() )
			return WeaponFireAgain(Pawn.Weapon.RefireRate(),false);
	}
	else return WeaponFireAgain(Pawn.RefireRate(),false);

	return false;
}
function TimedFireWeaponAtEnemy()
{
	if ( (Enemy == None) || FireWeaponAt(Enemy) )
		SetCombatTimer();
	else SetTimer(0.1, True);
}
function StopFiring()
{
    if ( (Pawn != None) && Pawn.StopWeaponFiring() )
        bStoppedFiring = true;

    bCanFire = false;
    bFire = 0;
    bAltFire = 0;
}

function WanderOrCamp(bool bMayCrouch)
{
    Switch( KFHM.SoldierOrders )
	{
		Case ORDER_Guarding:
			GoToState('Waiting');
			Break;
		Case ORDER_Wander:
			GoToState('Wandering');
			Break;
		Case ORDER_Hunt:
			GoToState('ActiveHunting');
			Break;
		Default:
			GoToState('Patroling');
			Break;
	}
}

state Wandering
{
ignores EnemyNotVisible,Timer;

	function CancelCampFor(Controller C)
	{
		DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
	}
	function bool Formation()
	{
		return true;
	}
	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( NoiseMaker.Instigator!=None && FastTrace(NoiseMaker.Location,Pawn.Location) && SetEnemy(NoiseMaker.Instigator,False) )
			WhatToDoNext(3);
	}
	function PickDestination()
	{
		if ( TestDirection(VRand(),Destination) )
			return;
		TestDirection(VRand(),Destination);
	}
	function BeginState()
	{
		Enemy = None;
		Pawn.bCanJump = false;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		Pawn.SetWalking(true);
		MinHitWall += 0.15;
	}
	function EndState()
	{
		MonitoredPawn = None;
		MinHitWall -= 0.15;
		if ( Pawn != None )
		{
			Pawn.bStopAtLedges = false;
			Pawn.bAvoidLedges = false;
			Pawn.SetWalking(false);
			if (Pawn.JumpZ > 0)
				Pawn.bCanJump = true;
		}
	}
	event MonitoredPawnAlert()
	{
		WhatToDoNext(6);
	}

Begin:
	WaitForLanding();
Camping:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	FocalPoint = Pawn.Location+VRand()*500;
	NearWall(MINVIEWDIST);
	FinishRotation();
	Sleep(3 + FRand());
Moving:
	WaitForLanding();
	PickDestination();
	MoveTo(Destination,,true);
	if ( Pawn.bCanFly && (Physics == PHYS_Walking) )
		SetPhysics(PHYS_Flying);
	Goto('Begin');
}
state Waiting extends Wandering
{
Begin:
	WaitForLanding();
Camping:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	FocalPoint = Pawn.Location+vector(Pawn.Rotation)*2500;
	NearWall(MINVIEWDIST);
	Stop;
}
state ActiveHunting
{
ignores EnemyNotVisible,Timer;

	function HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( NoiseMaker.Instigator!=None && FastTrace(NoiseMaker.Location,Pawn.Location) && SetEnemy(NoiseMaker.Instigator,False) )
			WhatToDoNext(3);
	}
	function PickDestination()
	{
		if( MoveGoal==None )
			MoveGoal = FindRandomDest();
		if( MoveGoal!=None )
		{
			if( ActorReachable(MoveGoal) )
			{
				MoveTarget = MoveGoal;
				MoveGoal = None;
				Return;
			}
			if( FindBestPathToward(MoveGoal,True,True) )
				Return;
			MoveGoal = None;
		}
		if ( TestDirection(VRand(),Destination) )
			return;
		TestDirection(VRand(),Destination);
	}
	function BeginState()
	{
		Enemy = None;
		Pawn.bCanJump = True;
		Pawn.bAvoidLedges = False;
		Pawn.bStopAtLedges = False;
		Pawn.SetWalking(False);
	}

Begin:
	WaitForLanding();
	PickDestination();
	if( MoveTarget!=None )
		MoveToward(MoveTarget,,,ShouldStrafeTo(MoveTarget));
	else MoveTo(Destination);
	if( FRand()<0.1 )
	{
		Pawn.Acceleration = vect(0,0,0);
		Focus = None;
		FocalPoint = Pawn.Location+VRand()*200;
		Sleep(0.5+FRand()*1.5);
	}
	Goto'Begin';
}

function EnemyChanged(bool bNewEnemyVisible)
{
	bEnemyAcquired = false;
	SetEnemyInfo(bNewEnemyVisible);
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	if ( Enemy!=None && Enemy==KilledPawn )
	{
		Enemy = None;
		WhatToDoNext(45);
	}
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	local NavigationPoint N;

	if ( Skill + StrafingAbility < 3 )
		return false;

	if ( WayPoint == Enemy )
		return ( Skill + StrafingAbility < 5 * FRand() - 1 );
	else if ( Pickup(WayPoint) == None )
	{
		N = NavigationPoint(WayPoint);
		if ( (N == None) || N.bNeverUseStrafing )
			return false;
		if ( N.FearCost > 200 )
			return true;
		if ( N.bAlwaysUseStrafing && (FRand() < 0.8) )
			return true;
	}
	if ( Pawn(WayPoint) != None )
		return ( Skill + StrafingAbility < 5 * FRand() - 1 );
	if ( Skill + StrafingAbility < 7 * FRand() - 1 )
		return false;
	if ( Enemy == None )
		return ( FRand() < 0.4 );
	if ( EnemyVisible() )
		return ( FRand() < 0.85 );
	return ( FRand() < 0.6 );
}

/* CheckIfShouldCrouch()
returns true if target position still can be shot from crouched position,
or if couldn't hit it from standing position either
*/
function CheckIfShouldCrouch(vector StartPosition, vector TargetPosition, float probability)
{
    local actor HitActor;
    local vector HitNormal,HitLocation, X,Y,Z, projstart;

    if ( !Pawn.bCanCrouch || (!Pawn.bIsCrouched && (FRand() > probability))
        || (Skill < 3 * FRand())
        || KFHumanPawnEnemy(Pawn).RecommendSplashDamage() )
    {
        Pawn.bWantsToCrouch = false;
        return;
    }

    GetAxes(Rotation,X,Y,Z);
    projStart = KFHumanPawnEnemy(Pawn).GetFireStart(X,Y,Z);
    projStart = projStart + StartPosition - Pawn.Location;
    projStart.Z = projStart.Z - 1.8 * (Pawn.CollisionHeight - Pawn.CrouchHeight);
    HitActor =  Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
    if ( HitActor == None )
    {
        Pawn.bWantsToCrouch = true;
        return;
    }

    projStart.Z = projStart.Z + 1.8 * (Pawn.Default.CollisionHeight - Pawn.CrouchHeight);
    HitActor =  Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
    if ( HitActor == None )
    {
        Pawn.bWantsToCrouch = false;
        return;
    }
    Pawn.bWantsToCrouch = true;
}



//=============================================================================
function WhatToDoNext(byte CallingByte)
{
	if ( ChooseAttackTime == Level.TimeSeconds )
		ChooseAttackCounter++;
	else
	{
		ChooseAttackTime = Level.TimeSeconds;
		ChooseAttackCounter = 0;
	}
	ChoosingAttackLevel++;
	ExecuteWhatToDoNext();
	ChoosingAttackLevel--;
}

function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
    if ( Target == None )
        Target = Enemy;  
    if ( Target != None )
    {
        if ( !Pawn.IsFiring() )
        {
            if ( (Pawn.Weapon != None && Pawn.Weapon.bMeleeWeapon) || (!NeedToTurn(Target.Location) && Pawn.CanAttack(Target)) )
            {
                Focus = Target;
                bCanFire = true;
                bStoppedFiring = false;
                if (Pawn.Weapon != None)
                    bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);
                else
                {
                    Pawn.ChooseFireAt(Target);
                    bFireSuccess = true;
                }
                return bFireSuccess;
            }
            else
            {
                bCanFire = false;
            }
        }
        else if ( bCanFire && ShouldFireAgain(RefireRate) )
        {
            if ( (Target != None) && (Focus == Target) && !Target.bDeleteMe )
            {
                bStoppedFiring = false;
                if (Pawn.Weapon != None)
                    bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);
                else
                {
                    Pawn.ChooseFireAt(Target);
                    bFireSuccess = true;
                }
                return bFireSuccess;
            }
        }
    }
    StopFiring();
    return false;
}

function bool ShouldFireAgain(float RefireRate)
{
	if ( FRand() < RefireRate )
		return true;
	if ( Pawn.FireOnRelease() && (Pawn.Weapon == None || !Pawn.Weapon.bMeleeWeapon) )
		return false;
	if ( Pawn(Target) != None )
		return ( (Pawn.bStationary || Pawn(Target).bStationary) && (Pawn(Target).Health > 0) );
	return false;
}

function FightEnemy(bool bCanCharge)
{
	local vector X,Y,Z;
	local float enemyDist;
	local float AdjustedCombatStyle, Aggression;
	local bool bFarAway, bOldForcedCharge;

	if ( (Enemy == None) || (Pawn == None) )
	{
		WhatToDoNext(45);
		Return;
	}

	if ( (Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime) )
	{
		if ( Enemy == FailedHuntEnemy )
		{
			GoalString = "FAILED HUNT - HANG OUT";
			if ( EnemyVisible() )
				bCanCharge = false;
		}
	}

	if( !EnemyVisible() )
	{
		if( KFHM.bStationaryCombat )
		{
			Enemy = None;
			WhatToDoNext(44);
		}
		else GoToState('Hunting');
		Return;
	}
	else if( KFHM.bStationaryCombat )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}
	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSize(Pawn.Location - Enemy.Location);
	AdjustedCombatStyle = CombatStyle;
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle
	 + FRand() * (Normal(Enemy.Velocity - Pawn.Velocity) Dot Normal(Enemy.Location - Pawn.Location));
	if ( Enemy.Weapon != None )
		Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();
	if ( enemyDist > MAXSTAKEOUTDIST )
		Aggression += 0.5;

	// Bloodlust *__*
	if ( (Enemy.Health / Enemy.HealthMax) <= 0.5 )
		Aggression += 0.5;

	if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
	{
		if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE)
			Aggression = FMax(0.0, Aggression - 1.0 + AdjustedCombatStyle);
		else if ( (Skill < 4) && (enemyDist > 0.65 * MAXSTAKEOUTDIST) )
		{
			bFarAway = true;
			Aggression += 0.5;
		}
		else if (Pawn.Location.Z < Enemy.Location.Z - Pawn.CollisionHeight) // below enemy
			Aggression += CombatStyle;
	}

	// see enemy - decide whether to charge it or strafe around/stand and fire
	Target = Enemy;
	if( KFHM.PreferMelee() || (bCanCharge && bOldForcedCharge) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}
	if ( bCanCharge && bFarAway && (Aggression > 1) && (FRand() < 0.5) )
	{
		GoalString = "Charge closer";
		DoCharge();
		return;
	}
	if ( !KFHM.PreferMelee() && (FRand() > 0.17 * (skill - 1)) && !DefendMelee(enemyDist) )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}
	if ( bCanCharge )
	{
		if ( Aggression > 1 )
		{
			GoalString = "Charge 2";
			DoCharge();
			return;
		}
	}
	if ( !Pawn.bCanStrafe )
	{
		GoalString = "Ranged Attack";
		DoRangedAttackOn(Enemy);
		return;
	}
	GoalString = "Do tactical move";
	if ( !KFHM.RecommendSplashDamage() && KFHM.bCanDodgeDoubleJump && (FRand() < 0.7) && (FRand()*Skill > 3) )
	{
		GetAxes(Pawn.Rotation,X,Y,Z);
		GoalString = "Try to Duck ";
		if ( FRand() < 0.5 )
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else TryToDuck(Y, false);
	}
	DoTacticalMove();
}

function bool FindNewEnemy()
{
	return false;
}

function DoCharge()
{
    if ( Enemy.PhysicsVolume.bWaterVolume )
    {
        if ( !Pawn.bCanSwim )
        {
            DoTacticalMove();
            return;
        }
    }
    else if ( !Pawn.bCanFly && !Pawn.bCanWalk )
    {
        DoTacticalMove();
        return;
    }
    GotoState('Charging');
}

function SeeMonster( Pawn Seen )
{
	SeePlayer(Seen);
}

state Charging
{
ignores SeePlayer, HearNoise;

    /* MayFall() called by engine physics if walking and bCanJump, and
        is about to go off a ledge.  Pawn has opportunity (by setting
        bCanJump to false) to avoid fall
    */
    function MayFall()
    {
        if ( MoveTarget != Enemy )
            return;

        Pawn.bCanJump = ActorReachable(Enemy);
        if ( !Pawn.bCanJump )
            MoveTimer = -1.0;
    }

    function bool TryToDuck(vector duckDir, bool bReversed)
    {
        if ( FRand() < 0.6 )
            return Global.TryToDuck(duckDir, bReversed);
        if ( MoveTarget == Enemy )
            return TryStrafe(duckDir);
    }

    function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
    {
        local vector sideDir;

        sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
        if ( (Pawn.Velocity Dot sidedir) > 0 )
            sidedir *= -1;

        return TryStrafe(sideDir);
    }

    function bool TryStrafe(vector sideDir)
    {
        local vector extent, HitLocation, HitNormal;
        local actor HitActor;

        Extent = Pawn.GetCollisionExtent();
        HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
        if (HitActor != None)
        {
            sideDir *= -1;
            HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
        }
        if (HitActor != None)
            return false;

        if ( Pawn.Physics == PHYS_Walking )
        {
            HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir - MAXSTEPHEIGHT * vect(0,0,1), Pawn.Location + MINSTRAFEDIST * sideDir, false, Extent);
            if ( HitActor == None )
                return false;
        }
        Destination = Pawn.Location + 2 * MINSTRAFEDIST * sideDir;
        GotoState('TacticalMove', 'DoStrafeMove');
        return true;
    }

    function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
    {
        local float pick;
        local vector sideDir;
        local bool bWasOnGround;

        Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);

        bWasOnGround = (Pawn.Physics == PHYS_Walking);
        if ( Pawn.health <= 0 )
            return;
        if ( StrafeFromDamage(damage, damageType, true) )
            return;
        else if ( bWasOnGround && (MoveTarget == Enemy) &&
                    (Pawn.Physics == PHYS_Falling) ) //weave
        {
            pick = 1.0;
            if ( bStrafeDir )
                pick = -1.0;
            sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
            sideDir.Z = 0;
            Pawn.Velocity += pick * Pawn.GroundSpeed * 0.7 * sideDir;
            if ( FRand() < 0.2 )
                bStrafeDir = !bStrafeDir;
        }
    }

    event bool NotifyBump(actor Other)
    {
        if ( Other == Enemy )
        {
            DoRangedAttackOn(Enemy);
            return false;
        }
        return Global.NotifyBump(Other);
    }

    function Timer()
    {
        enable('NotifyBump');
        Target = Enemy;
        if(ClearShot(Target.Location,true))
         TimedFireWeaponAtEnemy();
    }

    function EnemyNotVisible()
    {
       // WhatToDoNext(15);
       GotoState('Charging', 'Moving');
       WhatToDoNext(15);
    }

    function EndState()
    {
        if ( (Pawn != None) && Pawn.JumpZ > 0 )
            Pawn.bCanJump = true;
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
    /*
    if ( Pawn.bShotAnim )
    {
        Sleep(0.35);
        Goto('WaitForAnim');
    }
    */
    if ( !FindBestPathToward(Enemy, false,true) )
        GotoState('TacticalMove');
Moving:
    MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
    WhatToDoNext(17);
    if ( bSoaking )
        SoakStop("STUCK IN CHARGING!");
}

State WaitForAnim
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	event AnimEnd(int Channel)
	{
		WhatToDoNext(99);
	}
Begin:
	Sleep(0.1);
	WhatToDoNext(99);
}

function bool IsStrafing()
{
	return false;
}

function bool SetEnemy( Pawn NewEnemy, optional bool bHateMonster )
{
	if ( (NewEnemy == None) || (NewEnemy.Health <= 0) || (NewEnemy.Controller == None) || (NewEnemy == Enemy) )
		return false;
        
	if( Monster(NewEnemy)!=None )
	{
		if( KFHM.AttitudeToSpecimen>=ATTITUDE_Friendly )
			Return False;
		else if( KFHM.AttitudeToSpecimen==ATTITUDE_Ignore && !bHateMonster )
			Return False;
	}
	else if( KFHumanPawnEnemy(NewEnemy)!=None )
	{
		if( KFHM.AttitudeToPlayer>=ATTITUDE_Friendly && KFHumanPawnEnemy(NewEnemy).AttitudeToPlayer>=ATTITUDE_Friendly )
			Return False;
		else if( KFHM.AttitudeToPlayer<ATTITUDE_Friendly && KFHumanPawnEnemy(NewEnemy).AttitudeToPlayer<ATTITUDE_Friendly )
			Return False;
	}
	else if( KFPawn(NewEnemy)!=None )
	{
		if( KFHM.AttitudeToPlayer>=ATTITUDE_Friendly )
			Return False;
		else if( KFHM.AttitudeToPlayer==ATTITUDE_Ignore && !bHateMonster )
			Return False;
	}
	ChangeEnemy(NewEnemy,CanSee(NewEnemy));
	return true;
}

function DoRangedAttackOn(Actor A)
{
	Target = A;
	GotoState('RangedAttack');
}

function bool ClearShot(Vector TargetLoc, bool bImmediateFire)
{
    local bool bSeeTarget;

    if ( VSize(Enemy.Location - TargetLoc) > MAXSTAKEOUTDIST )
        return false;

    bSeeTarget = FastTrace(TargetLoc, Pawn.Location + Pawn.EyeHeight * vect(0,0,1));
    // if pawn is crouched, check if standing would provide clear shot
    if ( !bImmediateFire && !bSeeTarget && Pawn.bIsCrouched )
        bSeeTarget = FastTrace(TargetLoc, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1));

    if ( !bSeeTarget || !FastTrace(TargetLoc , Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1)) );
        return false;
    if ( (Monster(Pawn).SplashDamage() && (VSize(Pawn.Location - TargetLoc) < Monster(Pawn).GetDamageRadius()))
        || !FastTrace(TargetLoc + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location) )
    {
        StopFiring();
        return false;
    }
    return true;
}


state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

    function bool Stopped()
    {
        return true;
    }

    function CancelCampFor(Controller C)
    {
        DoTacticalMove();
    }

    function StopFiring()
    {
        Global.StopFiring();
        if ( bHasFired )
        {
            bHasFired = false;
            WhatToDoNext(32);
        }
    }

    function EnemyNotVisible()
    {
        //let attack animation complete
         DoCharge();
       // WhatToDoNext(33);
    }

    function Timer()
    {
        if ( KFHumanPawnEnemy(Pawn).PreferMelee() )
        {
            SetCombatTimer();
            StopFiring();
            Pawn.bWantsToCrouch = false;
            WhatToDoNext(34);
        }
        else
            TimedFireWeaponAtEnemy();
    }

    function DoRangedAttackOn(Actor A)
    {
        Target = A;
        GotoState('RangedAttack');
    }

    function BeginState()
    {
        StopStartTime = Level.TimeSeconds;
        bHasFired = false;
        Pawn.Acceleration = vect(0,0,0); //stop
        if ( Target == None )
            Target = Enemy;
        if ( Target == None )
            log(GetHumanReadableName()$" no target in ranged attack");
    }

Begin:
    bHasFired = false;
    GoalString = "Ranged attack";
    Focus = Target;
    Sleep(0.0);
    if ( Enemy != None )
        CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
    if ( NeedToTurn(Target.Location) )
    {
        Focus = Target;
        FinishRotation();
    }
    bHasFired = true;
    if ( Target == Enemy )
        TimedFireWeaponAtEnemy();
    else
        FireWeaponAt(Target);
    Sleep(0.1);
    if ( KFHumanPawnEnemy(Pawn).PreferMelee() || (Target == None) || (Target != Enemy)  )
        WhatToDoNext(35);
    if ( Enemy != None )
        CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
    Focus = Target;
    Sleep(FMax(Pawn.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
    WhatToDoNext(36);
    if ( bSoaking )
        SoakStop("STUCK IN RANGEDATTACK!");
}

function SetMaxDesiredSpeed()
{
    if ( Pawn != None )
            Pawn.MaxDesiredSpeed = 1;
}

state Hunting
{
ignores EnemyNotVisible;

    /* MayFall() called by] engine physics if walking and bCanJump, and
        is about to go off a ledge.  Pawn has opportunity (by setting
        bCanJump to false) to avoid fall
    */
    function bool IsHunting()
    {
        return true;
    }

    function MayFall()
    {
        Pawn.bCanJump = ( (MoveTarget == None) || (MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup') );
    }

    function SeePlayer(Pawn SeenPlayer)
    {
        if ( SeenPlayer == Enemy )
        {
            if ( Level.timeseconds - ChallengeTime > 7 )
            {
                ChallengeTime = Level.TimeSeconds;
                //Monster(Pawn).PlayChallengeSound();
            }
            VisibleEnemy = Enemy;
            EnemyVisibilityTime = Level.TimeSeconds;
            bEnemyIsVisible = true;
            Focus = Enemy;
            WhatToDoNext(22);
        }
        else
            Global.SeePlayer(SeenPlayer);
    }

    function Timer()
    {
        SetCombatTimer();
        StopFiring();
    }

    function PickDestination()
    {
        local vector nextSpot, ViewSpot,Dir;
        local float posZ;
        local bool bCanSeeLastSeen;

        // If no enemy, or I should see him but don't, then give up
        if ( (Enemy == None) || (Enemy.Health <= 0) )
        {
            Enemy = None;
            WhatToDoNext(23);
            return;
        }

        if ( Pawn.JumpZ > 0 )
            Pawn.bCanJump = true;

        if ( ActorReachable(Enemy) )
        {
            Destination = Enemy.Location;
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
            WhatToDoNext(26);
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

    function bool FindViewSpot()
    {
        local vector X,Y,Z;

        GetAxes(Rotation,X,Y,Z);

        // try left and right

        if ( FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
        {
            Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
            return true;
        }

        if ( FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
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

    function EndState()
    {
        if ( (Pawn != None) && (Pawn.JumpZ > 0) )
            Pawn.bCanJump = true;
    }

AdjustFromWall:
    MoveTo(Destination, MoveTarget);

Begin:
    WaitForLanding();
    if ( CanSee(Enemy) )
        SeePlayer(Enemy);
WaitForAnim:
    PickDestination();
    if ( Level.timeseconds - ChallengeTime > 10 )
    {
        ChallengeTime = Level.TimeSeconds;
       // Monster(Pawn).PlayChallengeSound();
    }

SpecialNavig:
    if (MoveTarget == None)
        MoveTo(Destination);
    else
        MoveToward(MoveTarget,FaceActor(10),,(FRand() < 0.75) && ShouldStrafeTo(MoveTarget));

    WhatToDoNext(27);
    if ( bSoaking )
        SoakStop("STUCK IN HUNTING!");
}

function bool Stopped()
{
	return bPreparingMove;
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

    if ( bPreparingMove )
    {
        Pawn.Acceleration = vect(0,0,0);
       // GotoState('WaitForAnim');
        return;
    }
    if (Pawn.Physics == PHYS_None)
        Pawn.SetMovementPhysics();
    if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
        return;
    if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
        Enemy = None;

    if ( Level.Game.bGameEnded && (Enemy != None) && Enemy.Controller.bIsPlayer )
        Enemy = None;

    if ( (Enemy == None))     // || !EnemyVisible()
        FindNewEnemy();

    if ( Enemy != None )
        ChooseAttackMode();
    else
    {
        GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
        WanderOrCamp(true);
    }

    SwitchToBestWeapon();
}

function bool CheckPathToGoalAround(Pawn P)
{
    return false;
}


state Fallback extends MoveToGoalWithEnemy
{

    function bool IsRetreating()
    {
        return ( (Pawn.Acceleration Dot (Pawn.Location - Enemy.Location)) > 0 );
    }

    event bool NotifyBump(actor Other)
    {
        local Pawn P;

        Disable('NotifyBump');
        if ( MoveTarget == Other )
        {
            if ( MoveTarget == Enemy && Pawn.HasWeapon() )
            {
                TimedFireWeaponAtEnemy();
                DoRangedAttackOn(Enemy);
            }
            return false;
        }

        P = Pawn(Other);

        if ( (P == None) || (P.Controller == None) )
            return false;
        
        if ( !SameTeamAs(P.Controller) && (MoveTarget == RouteCache[0]) && (RouteCache[1] != None) && P.ReachedDestination(MoveTarget) )
        {
            MoveTimer = VSize(RouteCache[1].Location - Pawn.Location)/(Pawn.GroundSpeed * Pawn.DesiredSpeed) + 1;
            MoveTarget = RouteCache[1];
        }

        SetEnemy(P);

        if ( Enemy == Other )
        {
            Focus = Enemy;
            TimedFireWeaponAtEnemy();
        }
        if ( CheckPathToGoalAround(P) )
            return false;

        AdjustAround(P);
        return false;
    }

    function MayFall()
    {
        Pawn.bCanJump = ( MoveTarget != None && (MoveTarget.Physics != PHYS_Falling) );
    }

    function EnemyNotVisible()
    {
        if ( !FindNewEnemy() || (Enemy == None) )
            WhatToDoNext(13);
        else
        {
            enable('SeePlayer');
            disable('EnemyNotVisible');
        }
    }

    function EnemyChanged(bool bNewEnemyVisible)
    {
        bEnemyAcquired = false;
        SetEnemyInfo(bNewEnemyVisible);
        if ( bNewEnemyVisible )
        {
            disable('SeePlayer');
            enable('EnemyNotVisible');
        }
    }

Begin:
    WaitForLanding();

Moving:
    MoveTarget = RouteCache[1];
    MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
    WhatToDoNext(14);
    if ( bSoaking )
        SoakStop("STUCK IN FALLBACK!");
    goalstring = goalstring$" STUCK IN FALLBACK!";
}

/* ChooseAttackMode()
Handles tactical attacking state selection - choose which type of attack to do from here
*/
function ChooseAttackMode()
{
	GoalString = " ChooseAttackMode last seen "$(Level.TimeSeconds - LastSeenTime);
	// should I run away?
	if ( (pawn.Health / pawn.HealthMax) <= 0.25 || VSize(location - enemy.Location) < 50 && pawn.Weapon != none && !pawn.Weapon.bMeleeWeapon)
	{
		GoalString = "Retreat";
		GotoState('FallBack');
	}
	GoalString = "ChooseAttackMode FightEnemy";
	FightEnemy(true);
}

function float AdjustAimError(float aimerror, float TargetDist, bool bDefendMelee, bool bInstantProj, bool bLeadTargetNow )
{
    if ( (Pawn(Target) != None) && (Pawn(Target).Visibility < 2) )
        aimerror *= 2.5;

    // figure out the relative motion of the target across the bots view, and adjust aim error
    // based on magnitude of relative motion
    aimerror = aimerror * FMin(5,(12 - 11 *
        (Normal(Target.Location - Pawn.Location) Dot Normal((Target.Location + 1.2 * Target.Velocity) - (Pawn.Location + Pawn.Velocity)))));

    // if enemy is charging straight at bot with a melee weapon, improve aim
    if ( bDefendMelee )
        aimerror *= 0.5;

    if ( Target.Velocity == vect(0,0,0) )
        aimerror *= 0.6;

    // aiming improves over time if stopped
    if ( Stopped() && (Level.TimeSeconds > StopStartTime) )
    {
        if ( (Skill+Accuracy) > 4 )
            aimerror *= 0.9;
        aimerror *= FClamp((2 - 0.08 * FMin(skill,7) - FRand())/(Level.TimeSeconds - StopStartTime + 0.4),0.7,1.0);
    }

    // adjust aim error based on skill
    if ( !bDefendMelee )
        aimerror *= (3.3 - 0.37 * (FClamp(skill+Accuracy,0,8.5) + 0.5 * FRand()));

    // Bots don't aim as well if recently hit, or if they or their target is flying through the air
    if ( ((skill < 7) || (FRand()<0.5)) && (Level.TimeSeconds - Pawn.LastPainTime < 0.2) )
        aimerror *= 1.3;
    if ( (Pawn.Physics == PHYS_Falling) || (Target.Physics == PHYS_Falling) )
        aimerror *= 1.6;

    // Bots don't aim as well at recently acquired targets (because they haven't had a chance to lock in to the target)
    if ( AcquireTime > Level.TimeSeconds - 0.5 - 0.6 * (7 - skill) )
    {
        aimerror *= 1.5;
        if ( bInstantProj )
            aimerror *= 1.5;
    }
	return  (Rand(2 * aimerror) - aimerror);
}

defaultproperties
{
}
