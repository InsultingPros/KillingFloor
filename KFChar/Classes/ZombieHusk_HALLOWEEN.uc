//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieHusk_HALLOWEEN extends ZombieHusk;


#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax

function SpawnTwoShots()
{
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;
	local KFMonsterController KFMonstControl;

	if( Controller!=None && KFDoorMover(Controller.Target)!=None )
	{
		Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	FireStart = GetBoneCoords('Barrel').Origin;
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
		SavedFireProperties.ProjectileClass = Class'HuskFireProjectile_HALLOWEEN';
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = 65535;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = true;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = False;
		SavedFireProperties.bInitialized = True;
	}

    // Turn off extra collision before spawning vomit, otherwise spawn fails
    ToggleAuxCollision(false);

	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);

	foreach DynamicActors(class'KFMonsterController', KFMonstControl)
	{
        if( KFMonstControl != Controller )
        {
            if( PointDistToLine(KFMonstControl.Pawn.Location, vector(FireRotation), FireStart) < 75 )
            {
                KFMonstControl.GetOutOfTheWayOfShot(vector(FireRotation),FireStart);
            }
        }
	}

    Spawn(Class'HuskFireProjectile_HALLOWEEN',,,FireStart,FireRotation);

	// Turn extra collision back on
	ToggleAuxCollision(true);
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Husk.Husk_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Bloat.Bloat_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Husk.Husk_Jump'
     ProjectileBloodSplatClass=None
     DetachedArmClass=Class'KFChar.SeveredArmHusk_HALLOWEEN'
     DetachedLegClass=Class'KFChar.SeveredLegHusk_HALLOWEEN'
     DetachedHeadClass=Class'KFChar.SeveredHeadHusk_HALLOWEEN'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmHuskGun_HALLOWEEN'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Husk.Husk_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Husk.Husk_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Husk.Husk_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Husk.Husk_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Husk.Husk_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Husk.Husk_Challenge'
     MenuName="HALLOWEEN Husk"
     AmbientSound=Sound'KF_BaseHusk_HALLOWEEN.Husk_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks2_Trip_HALLOWEEN.Husk_Halloween'
     Skins(0)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.Husk.husk_RedneckZombie_CMB'
}
