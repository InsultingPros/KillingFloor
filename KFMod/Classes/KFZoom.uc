class KFzoom extends SniperZoom;

event ModeDoFire()
{
	if (!AllowFire())
		return;

	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	// server
	if (Weapon.Role == ROLE_Authority)
	{
		HoldTime = 0;   // if bot decides to stop firing, HoldTime must be reset first
		if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

		if ( AIController(Instigator.Controller) != None )
			AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

		Instigator.DeactivateSpawnProtection();
	}
	// client
	if (Instigator.IsLocallyControlled())
	{
		if( KFWeapon(Weapon)!=none )
		{
			KFWeapon(Weapon).bAimingRifle = True;
			KFWeapon(Weapon).ServerSetAiming(True);
			KFWeapon(Weapon).PlayAnimZoom(True);
		}
		if( KFHumanPawn(Instigator)!=None )
			KFHumanPawn(Instigator).SetAiming(True);
	}


       // Weapon.IncrementFlashCount(ThisModeNum);

	// set the next firing time. must be careful here so client and server do not get out of sync
	if (bFireOnRelease)
	{
		if (bIsFiring)
			NextFireTime += MaxHoldTime + FireRate;
		else NextFireTime = Level.TimeSeconds + FireRate;
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

function PlayFireEnd()
{
	if( KFWeapon(Weapon)!=none )
	{
		KFWeapon(Weapon).bAimingRifle = False;
		KFWeapon(Weapon).ServerSetAiming(False);
		KFWeapon(Weapon).PlayAnimZoom(False);
	}
	if( KFHumanPawn(Instigator)!=None )
		KFHumanPawn(Instigator).SetAiming(False);
		

	Super.PlayFireEnd();
}

simulated function bool AllowFire()
{
	if (Weapon.Owner.Physics == PHYS_Falling)
		return false;
	if( KFWeapon(Weapon).bIsReloading || !KFWeapon(Weapon).CanZoomNow() )
		return false; 
	return true;
}

defaultproperties
{
     FireAnim="Raise"
     FireSound=Sound'KFPlayerSound.getweaponout3'
     FireRate=0.500000
     BotRefireRate=0.500000
}
