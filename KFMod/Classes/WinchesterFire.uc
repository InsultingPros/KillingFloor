//=============================================================================
// Winchester Fire
//=============================================================================
class WinchesterFire extends KFFire;

// KFTODO - Slomo compensation R&D, finish later if I have time - Ramm
//var()   bool bDoSlomoCompensation;
//
//var     bool bWasNormal;
//
//event ModeTick(float dt)
//{
//    local name anim;
//    local float frame, rate;
//    local float TimeLeft;
//
//    if( Weapon.Level.TimeDilation != 1.1 )
//    {
//        if( bWasNormal )
//        {
//        	FireRate = default.FireRate * ((Weapon.Level.TimeDilation )/1.1);
//        	TweenTime = default.TweenTime * ((Weapon.Level.TimeDilation )/1.1);
//        	log("default.FireRate = "$default.FireRate$" FireRate = "$FireRate$" Dilation Factor "$((Weapon.Level.TimeDilation * 2.0)/1.1));
//        	//FireRate = default.FireRate/Rec * (Weapon.Level.TimeDilation/1.1);
//        	FireAnimRate = default.FireAnimRate/ ((Weapon.Level.TimeDilation )/1.1);
//
//
//            Weapon.GetAnimParams(0, anim, frame, rate);
//
//            if( Anim == FireAnim )
//            {
//                Weapon.PlayAnim(FireAnim, FireAnimRate, /*TweenTime*/);
//                Weapon.SetAnimFrame( frame );
//            }
//
//            TimeLeft = NextFireTime - (Level.TimeSeconds - LastFireTime);
//            NextFireTime = TimeLeft * ((Weapon.Level.TimeDilation /** 1.75*/)/1.1);
//        }
//
//        bWasNormal = false;
//    }
//    else
//    {
//        bWasNormal = true;
//    }
//
//
//}

// KFTODO - Slomo compensation R&D, finish later if I have time - Ramm
//function Timer()
//{
//    if( Weapon.Level.TimeDilation == 1.1 )
//    {
//        KFGameType(Level.Game).DramaticEvent(1.0);
//    }
//}

// Overridden to support interrupting the reload
simulated function bool AllowFire()
{
	if( KFWeapon(Weapon).bIsReloading && KFWeapon(Weapon).MagAmmoRemaining < 2)
		return false;

	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if( KFPawn(Instigator).bThrowingNade )
		return false;

	if( Level.TimeSeconds - LastClickTime>FireRate )
	{
		LastClickTime = Level.TimeSeconds;
	}

	if( KFWeaponShotgun(Weapon).MagAmmoRemaining<1 )
	{
    	return false;
	}

	return super(WeaponFire).AllowFire();
}

event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	if( Instigator==None || Instigator.Controller==none )
		return;

	Rec = GetFireSpeed();

// KFTODO - Slomo compensation R&D, finish later if I have time - Ramm
//    if( bDoSlomoCompensation && Weapon.Level.TimeDilation != 1.1 )
//    {
//    	FireRate = default.FireRate * ((Weapon.Level.TimeDilation /** 1.75*/)/1.1);
//    	TweenTime = default.TweenTime * ((Weapon.Level.TimeDilation /** 1.75*/)/1.1);
//    	log("default.FireRate = "$default.FireRate$" FireRate = "$FireRate$" Dilation Factor "$((Weapon.Level.TimeDilation * 2.0)/1.1));
//    	//FireRate = default.FireRate/Rec * (Weapon.Level.TimeDilation/1.1);
//    	FireAnimRate = default.FireAnimRate*Rec / ((Weapon.Level.TimeDilation /** 1.75*/)/1.1);
//    	//ReloadAnimRate = default.ReloadAnimRate*Rec / ((Weapon.Level.TimeDilation * 2.0)/1.1);
//	}
//	else
//	{
    	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate;
    	ReloadAnimRate = default.ReloadAnimRate*Rec;
//	}

	Rec = 1;

	LastFireTime = Level.TimeSeconds;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}


	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	// server
	if (Weapon.Role == ROLE_Authority)
	{
		Weapon.ConsumeAmmo(ThisModeNum, Load);
		DoFireEffect();
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
		ShakeView();
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

	if (Weapon.Owner != none && AllowFire())
	{
		if (FireRate > 0.25)
		{
			Weapon.Owner.Velocity.x *= 0.1;
			Weapon.Owner.Velocity.y *= 0.1;
		}
		else
		{
			Weapon.Owner.Velocity.x *= 0.5;
			Weapon.Owner.Velocity.y *= 0.5;
		}
	}

    // client
    if (Instigator.IsLocallyControlled())
    {
        if( bDoClientRagdollShotFX && Weapon.Level.NetMode == NM_Client &&
            Weapon.Level.TimeDilation != Weapon.Level.default.TimeDilation )
        {
            DoClientOnlyFireEffect();
        }
        HandleRecoil(1.0);
    }

    // KFTODO - Slomo compensation R&D, finish later if I have time - Ramm
    //SetTimer(0.2,False);
}

defaultproperties
{
     FireAimedAnim="AimFire"
     RecoilRate=0.100000
     maxVerticalRecoilAngle=800
     maxHorizontalRecoilAngle=250
     StereoFireSoundRef="KF_RifleSnd.Rifle_FireST"
     DamageType=Class'KFMod.DamTypeWinchester'
     DamageMin=110
     DamageMax=140
     Momentum=18000.000000
     bPawnRapidFireAnim=True
     bWaitForRelease=True
     bModeExclusive=False
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.800000
     FireLoopAnim=
     FireEndAnim=
     FireSound=SoundGroup'KF_RifleSnd.Rifle_Fire'
     NoAmmoSound=Sound'KF_RifleSnd.Rifle_DryFire'
     FireForce="ShockRifleFire"
     FireRate=0.900000
     AmmoClass=Class'KFMod.WinchesterAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=100.000000,Y=100.000000,Z=500.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=10.000000,Y=3.000000,Z=12.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.650000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=0.000000
     Spread=0.007000
}
