// Kill all zombies within this volume (clean up map mid-game).
class KFVolume_ZedPit extends Volume;

// Tag name of pathnode to send Zeds to
var() name NodeTag;
var() bool bAffectsBloats;
var() bool bAffectsCrawlers;
var() bool bAffectsFleshPounds;
var() bool bAffectsGorefasts;
var() bool bAffectsStalkers;
var() bool bAffectsSirens;
var() bool bAffectsClots;
var() bool bAffectsScrakes;
var() bool bAffectsHusks;

var PathNode MyNode;


function Touch( actor Other )
{
    local KFMonster KFM;
    local KFMonsterController KFMC;
    local PathNode P;

    KFM = KFMonster(Other);

    if ( KFM == none )
    {
     	return;
    }

    if( !bAffectsBloats && KFM.IsA( 'ZombieBloatBase' ) )
    {
        return;
    }
    if( !bAffectsCrawlers && KFM.IsA( 'ZombieCrawlerBase' ) )
    {
        return;
    }
    if( !bAffectsFleshPounds && KFM.IsA( 'ZombieFleshpoundBase' ) )
    {
        return;
    }
    if( !bAffectsGorefasts && KFM.IsA( 'ZombieGorefastBase' ) )
    {
        return;
    }
    if( !bAffectsStalkers && KFM.IsA( 'ZombieStalkerBase' ) )
    {
        return;
    }
    if( !bAffectsSirens && KFM.IsA( 'ZombieSirenBase' ) )
    {
        return;
    }
    if( !bAffectsClots && KFM.IsA( 'ZombieClotBase' ) )
    {
        return;
    }
    if( !bAffectsScrakes && KFM.IsA( 'ZombieScrakeBase' ) )
    {
        return;
    }
    if( !bAffectsHusks && KFM.IsA( 'ZombieHuskBase' ) )
    {
        return;
    }

    KFMC = KFMonsterController(KFM.Controller);

    if( KFMC != none )
    {
        if( MyNode == none )
        {
            foreach AllActors( class'PathNode', P )
            {
                if( P.Tag == NodeTag )
                {
                    MyNode = P;
                    break;
                }
            }
        }
        KFMC.ScriptedMoveTarget = MyNode;
        KFMC.MoveTimer = -1.f;
        KFM.Acceleration = vect(0,0,0);
        KFMC.GotoState( 'ScriptedMoveTo' );
    }
}

defaultproperties
{
     bAffectsBloats=True
}
