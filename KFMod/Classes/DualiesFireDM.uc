//=============================================================================
// Dualies Fire DM VERSION
//=============================================================================
class DualiesFireDM extends DualiesFire;

var() class<xEmitter> HitEmitterClass;
var() class<xEmitter> SecHitEmitterClass;
var() float SecDamageMult;
var() float SecTraceDist;
//var() float HeadShotDamageMult;
//var() class<DamageType> DamageTypeHeadShot;
var(tweak) float offsetadj;


function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
    local Actor Other;
    local ROBulletHitEffect S;
    local Pawn HeadShotPawn;

    Weapon.GetViewAxes(X, Y, Z);
    if ( Weapon.WeaponCentered() )
        ArcEnd = (Instigator.Location +
            Weapon.EffectOffset.X * X +
            1.5 * Weapon.EffectOffset.Z * Z);
    else
        ArcEnd = (Instigator.Location +
            Instigator.CalcDrawOffset(Weapon) +
            Weapon.EffectOffset.X * X +
            Weapon.Hand * Weapon.EffectOffset.Y * Y +
            Weapon.EffectOffset.Z * Z);

    X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

    if ( (Level.NetMode != NM_Standalone) || (PlayerController(Instigator.Controller) == None) )
        Weapon.Spawn(class'TracerProjectile',Instigator.Controller,,Start,Dir);

    if ( Other != None && (Other != Instigator) )
    {
        if ( !Other.bWorldGeometry )
        {
            if (Vehicle(Other) != None)
                HeadShotPawn = Vehicle(Other).CheckForHeadShot(HitLocation, X, 1.0);

            //if (HeadShotPawn != None)
            //    HeadShotPawn.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
            //else if ( (Pawn(Other) != None) && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
            //    Other.TakeDamage(DamageMax * HeadShotDamageMult, Instigator, HitLocation, Momentum*X, DamageTypeHeadShot);
            else
                Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum*X, DamageType);
        }
        else
                HitLocation = HitLocation + 2.0 * HitNormal;
    }
    else
    {
        HitLocation = End;
        HitNormal = Normal(Start - End);
    }

    if ( (HitNormal != Vect(0,0,0)) && (HitScanBlockingVolume(Other) == None) )
    {
        S = Weapon.Spawn(class'ROBulletHitEffect',,, HitLocation, rotator(-1 * HitNormal));
        // KFTODO: Not sure about commenting this out
//        if ( S != None )
//            S.FireStart = Start;
    }

}

defaultproperties
{
     DamageMax=40
     Momentum=10000.000000
}
