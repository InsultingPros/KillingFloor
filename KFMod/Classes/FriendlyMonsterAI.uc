class FriendlyMonsterAI extends KFMonsterController;


function bool FindNewEnemy()
{
    local Pawn BestEnemy;
    local bool bSeeNew, bSeeBest;
    local float BestDist, NewDist;
    local KFMonsterController C;
    //local KFOBJMover Bashdoor;

    if ( Level.Game.bGameEnded )
        return false;

     ForEach AllActors(class 'KFMonsterController', C)
    {
        if ((C.Pawn != None) && (C.Pawn.Health > 0) && C.Pawn != class 'KFHumanPawn' && C != self )
        {
            if ( BestEnemy == None )
            {
                BestEnemy = C.Pawn;
                BestDist = VSize(BestEnemy.Location - Pawn.Location);
                bSeeBest = CanSee(BestEnemy);
            }
            else
            {
                NewDist = VSize(C.Pawn.Location - Pawn.Location);
                if ( !bSeeBest || (NewDist < BestDist) )
                {
                    bSeeNew = CanSee(C.Pawn);
                    if ( NewDist < BestDist)
                    {
                        BestEnemy = C.Pawn;
                        BestDist = NewDist;
                        bSeeBest = bSeeNew;
                    }
                }
            }
        }
    }


    if ( BestEnemy == Enemy )
      return false;


    if ( BestEnemy != None )
    {
        ChangeEnemy(BestEnemy,CanSee(BestEnemy));
        return true;
    }

    return false;
}


function bool SetEnemy( Pawn NewEnemy, optional bool bHateMonster, optional float MonsterHateChanceOverride )
{
    local float EnemyDist;
    local bool bNewMonsterEnemy;

    if ( (NewEnemy == None) || (NewEnemy.Health <= 0) || (NewEnemy.Controller == None) || (NewEnemy == Enemy) )
        return false;

    bNewMonsterEnemy = bHateMonster && (Level.Game.NumPlayers < 4) && !Monster(Pawn).SameSpeciesAs(NewEnemy) && !NewEnemy.Controller.bIsPlayer;

    if ( NewEnemy == class 'KFHumanPawn' )
            return false;

    if ( (bNewMonsterEnemy && LineOfSightTo(NewEnemy)) || (Enemy == None) || !EnemyVisible() )
    {
        ChangeEnemy(NewEnemy,CanSee(NewEnemy));
        return true;
    }

    if ( !CanSee(NewEnemy) )
        return false;

    if ( !bHateMonster && (Monster(Enemy) != None) && NewEnemy.Controller.bIsPlayer )
        return false;

    EnemyDist = VSize(Enemy.Location - Pawn.Location);
    if ( EnemyDist < Pawn.MeleeRange )
        return false;

    if ( EnemyDist > 1.7 * VSize(NewEnemy.Location - Pawn.Location))
    {
        ChangeEnemy(NewEnemy,CanSee(NewEnemy));
        return true;
    }
    return false;
}

event SeePlayer(Pawn SeenPlayer)
{

    if ( Enemy == SeenPlayer )
    {
        Enemy = none;
        GotoState('ZombieRestFormation', 'Begin');
    }
}

defaultproperties
{
}
