//=============================================================================
// Pipe Bomb Fire
//=============================================================================
class PipeBombFire extends KFShotgunFire;

#exec OBJ LOAD FILE=KF_AxeSnd.uax

var()   float   ProjectileSpawnDelay;

function InitEffects()
{
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

    if( ProjectileClass != None )
        p = Weapon.Spawn(ProjectileClass,,, Start, Dir);

    if( p == None )
        return None;

    p.Damage *= DamageAtten;

    if( PipeBombProjectile(p) != none && Instigator != none )
    {
        PipeBombProjectile(p).PlacedTeam = Instigator.PlayerReplicationInfo.Team.TeamIndex;
    }

    return p;
}

function Timer()
{
    Weapon.ConsumeAmmo(ThisModeNum, Load);
    DoFireEffect();
    Weapon.PlaySound(Sound'KF_AxeSnd.Axe_Fire',SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,,false);

    if( Weapon.ammoAmount(0) <= 0 && Instigator != none && Instigator.Controller != none )
    {
        Weapon.Destroy();
        Instigator.Controller.ClientSwitchToBestWeapon();
    }
}

event ModeDoFire()
{
    if (!AllowFire())
        return;

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        // Consume ammo, etc later
        SetTimer(ProjectileSpawnDelay, False);

		HoldTime = 0;	// if bot decides to stop firing, HoldTime must be reset first
        if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

        if ( AIController(Instigator.Controller) != None )
            AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

        Instigator.DeactivateSpawnProtection();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        //ShakeView();
        PlayFiring();
        FlashMuzzleFlash();
        StartMuzzleSmoke();
    }
    else // server
    {
        ServerPlayFiring();
    }

    Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if (bIsFiring)
            NextFireTime += MaxHoldTime + FireRate;
        else
            NextFireTime = Level.TimeSeconds + FireRate;
    }
    else
    {
        NextFireTime += FireRate;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }

    Load = AmmoPerFire;
    HoldTime = 0;

    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        bIsFiring = false;
        Weapon.PutDown();
    }
}


function PlayFireEnd(){}

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
    	if( Level.TimeSeconds - LastClickTime>FireRate )
    	{
    		LastClickTime = Level.TimeSeconds;
    	}

		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

	return super(WeaponFire).AllowFire();
}

defaultproperties
{
     ProjectileSpawnDelay=1.100000
     bRandomPitchFireSound=False
     ProjPerFire=1
     ProjSpawnOffset=(X=10.000000,Y=0.000000,Z=-10.000000)
     bWaitForRelease=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireAnim="Toss"
     NoAmmoSound=None
     FireRate=1.750000
     AmmoClass=Class'KFMod.PipeBombAmmo'
     ProjectileClass=Class'KFMod.PipeBombProjectile'
     BotRefireRate=0.250000
     aimerror=1.000000
     Spread=15.000000
}
