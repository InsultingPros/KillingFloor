class FriendlyMonsterController extends MonsterController;

var Controller Master;
var Emitter Effect;

function Possess(Pawn aPawn)
{
    Super(ScriptedController).Possess(aPawn);
    InitializeSkill(DeathMatch(Level.Game).AdjustedDifficulty);
    Pawn.MaxFallSpeed = 1.1 * Pawn.default.MaxFallSpeed; // so bots will accept a little falling damage for shorter routes
    Pawn.SetMovementPhysics();
    if (Pawn.Physics == PHYS_Walking)
        Pawn.SetPhysics(PHYS_Falling);
    enable('NotifyBump');
}


function SetMaster(Controller NewMaster)
{

    Master = NewMaster;
    if (Master.PlayerReplicationInfo != None && Master.PlayerReplicationInfo.Team != None)
    {
        PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
        PlayerReplicationInfo.PlayerName = Master.PlayerReplicationInfo.PlayerName$"'s"@Pawn.GetHumanReadableName();
        PlayerReplicationInfo.bIsSpectator = true;
        PlayerReplicationInfo.bBot = true;
        PlayerReplicationInfo.Team = Master.PlayerReplicationInfo.Team;
        PlayerReplicationInfo.RemoteRole = ROLE_None;
        Pawn.PlayerReplicationInfo = PlayerReplicationInfo;
        Pawn.bNoTeamBeacon = true;
    }

    //Effect = Pawn.spawn(class'FriendlyMonsterEffect', Pawn);
   // Effect.SetBase(Pawn);
    //Effect.MasterPRI = Master.PlayerReplicationInfo;
    //Effect.Initialize();

}

function bool FindNewEnemy()
{
    local Pawn BestEnemy;
    local float BestDist;
    local Controller C;

    BestDist = 50000.f;
    for (C = Level.ControllerList; C != None; C = C.NextController)
        if ( C != Master && C != self && C.Pawn != None && (FriendlyMonsterController(C) == None || FriendlyMonsterController(C).Master != Master) && !C.SameTeamAs(Master)
             && VSize(C.Pawn.Location - Pawn.Location) < BestDist && !Monster(Pawn).SameSpeciesAs(C.Pawn) && CanSee(C.Pawn) )
        {
            BestEnemy = C.Pawn;
            BestDist = VSize(C.Pawn.Location - Pawn.Location);
        }

    if ( BestEnemy == Enemy )
        return false;

    if ( BestEnemy != None )
    {
        ChangeEnemy(BestEnemy, true);
        return true;
    }
    return false;
}

function bool SetEnemy(Pawn NewEnemy, optional bool bThisIsNeverUsed)
{
    local float EnemyDist;

    if (NewEnemy == None || NewEnemy.Health <= 0 || NewEnemy.Controller == None || NewEnemy == Enemy)
        return false;
    if ( Master != None && ( (Master.Pawn != None && NewEnemy == Master.Pawn)
                 || (FriendlyMonsterController(NewEnemy.Controller) != None && FriendlyMonsterController(NewEnemy.Controller).Master == Master) ) )
        return false;
    if (NewEnemy.Controller.SameTeamAs(Master) || !CanSee(NewEnemy))
        return false;

    if (Enemy == None)
    {
        ChangeEnemy(NewEnemy, CanSee(NewEnemy));
        return true;
    }

    EnemyDist = VSize(Enemy.Location - Pawn.Location);
    if ( EnemyDist < Pawn.MeleeRange )
        return false;

    if ( EnemyDist > 1.7 * VSize(NewEnemy.Location - Pawn.Location))
    {
        ChangeEnemy(NewEnemy, CanSee(NewEnemy));
        return true;
    }
    return false;
}

function ChangeEnemy(Pawn NewEnemy, bool bCanSeeNewEnemy)
{
    Super.ChangeEnemy(NewEnemy, bCanSeeNewEnemy);

    //hack for invasion monsters so they'll fight back
    if ( MonsterController(NewEnemy.Controller) != None && FriendlyMonsterController(NewEnemy.Controller) == None
         && (NewEnemy.Controller.Enemy == Master.Pawn || FRand() < 0.5) )
        MonsterController(NewEnemy.Controller).ChangeEnemy(Pawn, NewEnemy.Controller.CanSee(Pawn));
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
}

event SeePlayer(Pawn SeenPlayer)
{
    if (Enemy == None && ((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) && SetEnemy(SeenPlayer))
        WhatToDoNext(3);
    if ( Enemy == SeenPlayer )
    {
        VisibleEnemy = Enemy;
        EnemyVisibilityTime = Level.TimeSeconds;
        bEnemyIsVisible = true;
    }
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

    // if we don't have a master or it switched teams, then we should die
    if ( Master == None || Master.PlayerReplicationInfo == None || Master.PlayerReplicationInfo.bOnlySpectator
        || (PlayerReplicationInfo != None && PlayerReplicationInfo.Team != Master.PlayerReplicationInfo.Team) )
    {
        Pawn.Suicide();
        return;
    }

    if ( bPreparingMove && Monster(Pawn).bShotAnim )
    {
        Pawn.Acceleration = vect(0,0,0);
        GotoState('WaitForAnim');
        return;
    }
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
    else if (Master.Pawn != None)
        FollowMaster();
    else
    {
        GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
        WanderOrCamp(true);
    }
}

function FollowMaster()
{
    if ( VSize(Master.Pawn.Location - Pawn.Location) > 1000 || VSize(Master.Pawn.Velocity) > Master.Pawn.WalkingPct * Master.Pawn.GroundSpeed
         || !LineOfSightTo(Master.Pawn) )
    {
        GoalString = "Follow Master "$Master.PlayerReplicationInfo.PlayerName;
        if (FindBestPathToward(Master.Pawn, false, Pawn.bCanPickupInventory))
        {
            if ( Enemy != None )
                GotoState('Fallback');
            else
                GotoState('Roaming');

            return;
        }
    }

    GoalString = "Wander or Camp at "$Level.TimeSeconds;
    WanderOrCamp(true);
}



function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
    if (Killer == self || Killer == Master)
        Celebrate();
    if (KilledPawn == Enemy)
    {
        Enemy = None;
        FindNewEnemy();
    }
}

function Destroyed()
{
    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.Destroy();
    if (Effect != None)
        Effect.Destroy();

    Super.Destroyed();
}

state RestFormation
{
    function BeginState()
    {
        Enemy = None;
        Pawn.bCanJump = false;
        Pawn.bAvoidLedges = true;
        Pawn.bStopAtLedges = true;
        Pawn.SetWalking(true);
        MinHitWall += 0.15;
        if (Master != None && Master.Pawn != None)
            StartMonitoring(Master.Pawn, 1000);
    }
}

state Fallback extends MoveToGoalWithEnemy
{
    function MayFall()
    {
        Pawn.bCanJump = ( (MoveTarget != None)
                    && ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
    }

Begin:
    SwitchToBestWeapon();
    WaitForLanding();

Moving:
    if (InventorySpot(MoveTarget) != None)
        MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,0);
    MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
    WhatToDoNext(14);
    if ( bSoaking )
        SoakStop("STUCK IN FALLBACK!");
    goalstring = goalstring$" STUCK IN FALLBACK!";
}

defaultproperties
{
}
