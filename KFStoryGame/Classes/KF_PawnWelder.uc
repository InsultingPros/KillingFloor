/* a welder that can be used on human pawns to heal them */

class KF_PawnWelder extends Welder;

#exec OBJ LOAD FILE=KF_Weapons_Trip_T.utx


simulated function Tick(float dt)
{
    local KF_BreakerBoxNPC  Breaker;

    Super.Tick(dt);

    if(WeldFire(FireMode[FireModeArray]).LastHitActor != none)
    {
        Breaker = KF_BreakerBoxNPC(WeldFire(FireMode[FireModeArray]).LastHitActor);
        if(Breaker != none)
        {
            ScreenWeldPercent = (Breaker.Health / Breaker.HealthMax) * 100;
        }
    }
}

defaultproperties
{
     FireModeClass(0)=Class'KFStoryGame.PawnWeldFire'
}
