// Zombie Soldier for KF Invasion gametype
// UPDATED : He now fires off a shotgun at ya !

class ZombieSoldier extends KFMonster;

#exec OBJ LOAD FILE=PlayerSounds.uax

function RangedAttack(Actor A)
{
    //local name Anim;
    //local float frame,rate;
    local int LastFireTime;

    if ( bShotAnim )
        return;

    bShotAnim = true;
    LastFireTime = Level.TimeSeconds;

    if ( Physics == PHYS_Swimming )
        SetAnimAction('Claw');
    else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
    {
        if ( FRand() < 0.7 )
        {
            SetAnimAction('Claw');
            //PlaySound(sound'Spin1s', SLOT_Interact); KFTODO: Replace this
            Acceleration = AccelRate * Normal(A.Location - Location);
            return;
        }
        SetAnimAction('Claw');
        //PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else if ( Velocity == vect(0,0,0) )
    {
        SetAnimAction('ZombieFireGun');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        //SpawnTwoShots();
    }
    else if (VSize(A.Location - Location) < 400)
    {
      SetAnimAction('ZombieFireGun');
      Controller.bPreparingMove = true;
      Acceleration = vect(0,0,0);
    }

    else
     return;

}

simulated event SetAnimAction(name NewAction)
{
	if ( !bWaitForAnim || (Level.NetMode == NM_Client) )
	{
		// He's never able to fire the shotgun while moving.
                if(NewAction == 'ZombieFireGun')
                {
			Controller.bPreparingMove = true;
                        Acceleration = vect(0,0,0);
                }

                if(NewAction == 'Claw')
			AnimAction = meleeAnims[Rand(3)];
		else
			AnimAction = NewAction;
		if ( PlayAnim(AnimAction,,0.1) )
		{
		//	if (NewAction == 'Claw')
			//	ClawDamageTarget();
			if ( Physics != PHYS_None )
				bWaitForAnim = true;
		}

	}
}



// Change these from bright, glowing green balls, to shotgun pellets or somesuch.

function SpawnTwoShots()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;

    GetAxes(Rotation,X,Y,Z);
    FireStart = GetFireStart(X,Y,Z);
    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }
    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);

    FireStart = FireStart - 1.8 * CollisionRadius * Y;
    FireRotation.Yaw += 400;
    spawn(MyAmmo.ProjectileClass,,,FireStart, FireRotation);

    FireStart = FireStart - 1.8 * CollisionRadius * Z;
    FireRotation.Pitch += 400;
    spawn(MyAmmo.ProjectileClass,,,FireStart, FireRotation);

    FireStart = FireStart - 1.8 * CollisionRadius * X;
    FireRotation.Roll += 400;
    spawn(MyAmmo.ProjectileClass,,,FireStart, FireRotation);
}

defaultproperties
{
     MeleeAnims(0)="PoundPunch2"
     MeleeAnims(1)="PoundPunch2"
     MeleeAnims(2)="PoundPunch2"
     MeleeDamage=10
     damageForce=5000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Pain'
     AmmunitionClass=Class'KFMod.SZombieAmmo'
     ScoringValue=2
     GroundSpeed=105.000000
     WaterSpeed=100.000000
     Health=300
     MenuName="Infected Soldier"
     ControllerClass=Class'KFChar.SoldierZombieController'
     AmbientSound=Sound'KFPlayerSound.Zombiesbreath'
     Skins(0)=Shader'KFCharacters.Zombie8Shader'
     Mass=900.000000
     RotationRate=(Yaw=45000,Roll=0)
}
