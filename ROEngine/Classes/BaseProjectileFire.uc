// Based off or the old Xweapons.Projectilefire class

class BaseProjectileFire extends WeaponFire;

var() int ProjPerFire;
var() Vector ProjSpawnOffset; // +x forward, +y right, +z up

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

// Collision attachment debugging
 /*   if( Other.IsA('ROCollisionAttachment'))
    {
    	log(self$"'s trace hit "$Other.Base$" Collision attachment");
    }*/

    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
    }
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if( GetDesiredProjectileClass() != None )
        p = Weapon.Spawn(GetDesiredProjectileClass(),,, Start, Dir);

    /* First attempt at spawning failed, try an non zero extent trace to position it */
    if( p == None )
    {
        P = ForceSpawnProjectile(Start,Dir);
    }

    /* second trace failed.  give up */
    if( p == None)
    {
        return none;
    }

    PostSpawnProjectile(P);

    return p;
}

/* If the first projectile spawn failed it's probably because we're trying to spawn inside the collision bounds
of an object with properties that ignore zero extent traces.  We need to do a non-zero extent trace so we can
find a safe spawn loc for our projectile .. */

function projectile ForceSpawnProjectile(Vector Start, Rotator Dir)
{
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local Projectile p;

    /* perform the second trace .. */
    Other = Weapon.Trace(HitLocation, HitNormal, Start, Instigator.Location + Instigator.EyePosition(), false,vect(0,0,1));

    if (Other != None)
    {
        Start = HitLocation;
    }

    if( GetDesiredProjectileClass() != None )
        p = Weapon.Spawn(GetDesiredProjectileClass(),,, Start, Dir);

    return P;
}

/* Accessor function that returns the type of projectile we want this weapon to fire right now*/
function class<Projectile> GetDesiredProjectileClass()
{
    return ProjectileClass;
}

/* Convenient place to perform changes to a newly spawned projectile */
function PostSpawnProjectile(Projectile P)
{
    P.Damage *= DamageAtten;
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location + Instigator.EyePosition() + X*ProjSpawnOffset.X + Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
}

defaultproperties
{
     ProjPerFire=1
     ProjSpawnOffset=(Z=-10.000000)
     bLeadTarget=True
     bInstantHit=False
     NoAmmoSound=Sound'Inf_Weapons_Foley.Misc.dryfire_rifle'
     WarnTargetPct=0.500000
}
