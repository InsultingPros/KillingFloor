//=============================================================================
// Modified MP7 MedicGun Inventory class
//=============================================================================
class MP7MMedicGun extends KFMedicGun;


// Return a float value representing the current healing charge amount
simulated function float ChargeBar()
{
	return FClamp(float(HealAmmoCharge)/float(MaxAmmoCount),0,1);
}

simulated function MaxOutAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = MaxAmmo(0);
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = Ammo[0].MaxAmmo;

	HealAmmoCharge = MaxAmmoCount;
}

simulated function SuperMaxOutAmmo()
{
   HealAmmoCharge = 999;

	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = 999;
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = 999;
}

simulated function int MaxAmmo(int mode)
{
    if( Mode == 1 )
    {
	   return MaxAmmoCount;
	}
	else
	{
	   return super.MaxAmmo(mode);
	}
}

simulated function FillToInitialAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = Max(AmmoCharge[0], AmmoClass[0].Default.InitialAmount);
        HealAmmoCharge = MaxAmmoCount;
		return;
	}

	if ( Ammo[0] != None )
        Ammo[0].AmmoAmount = Ammo[0].AmmoAmount;

    HealAmmoCharge = MaxAmmoCount;
}

simulated function int AmmoAmount(int mode)
{
    if( Mode == 1 )
    {
	   return HealAmmoCharge;
	}
	else
	{
	   return super.AmmoAmount(mode);
	}
}

simulated function bool AmmoMaxed(int mode)
{
    if( Mode == 1 )
    {
	   return HealAmmoCharge>=MaxAmmoCount;
	}
	else
	{
	   return super.AmmoMaxed(mode);
	}
}

simulated function float AmmoStatus(optional int Mode) // returns float value for ammo amount
{
    if( Mode == 1 )
    {
	   return float(HealAmmoCharge)/float(MaxAmmoCount);
	}
	else
	{
	   return super.AmmoStatus(Mode);
	}
}

simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
    if( Mode == 1 )
    {
        if( Load>HealAmmoCharge )
        {
            return false;
        }

    	HealAmmoCharge-=Load;
    	Return True;
	}
	else
	{
	   return super.ConsumeAmmo(Mode, load, bAmountNeededIsMax);
	}
}

function bool AddAmmo(int AmmoToAdd, int Mode)
{
    if( Mode == 1 )
    {
    	if( HealAmmoCharge<MaxAmmoCount )
    	{
    		HealAmmoCharge+=AmmoToAdd;
    		if( HealAmmoCharge>MaxAmmoCount )
    		{
    			HealAmmoCharge = MaxAmmoCount;
    		}
    	}
        return true;
    }
    else
    {
        return super.AddAmmo(AmmoToAdd,Mode);
    }
}

simulated function bool HasAmmo()
{
    if( HealAmmoCharge > 0 )
    {
        return true;
    }

	if ( bNoAmmoInstances )
	{
    	return ( (AmmoClass[0] != none && FireMode[0] != none && AmmoCharge[0] >= FireMode[0].AmmoPerFire) );
	}
    return (Ammo[0] != none && FireMode[0] != none && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire);
}

simulated function CheckOutOfAmmo()
{
    return;
}

simulated function Tick(float dt)
{
	if ( Level.NetMode!=NM_Client && HealAmmoCharge<MaxAmmoCount && RegenTimer<Level.TimeSeconds )
	{
		RegenTimer = Level.TimeSeconds + AmmoRegenRate;

		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			HealAmmoCharge += 10 * KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetSyringeChargeRate(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));
		}
		else
		{
			HealAmmoCharge += 10;
		}

		if ( HealAmmoCharge > MaxAmmoCount )
		{
			HealAmmoCharge = MaxAmmoCount;
		}
	}
}

simulated function bool StartFire(int Mode)
{
	if( Mode == 1 )
		return super.StartFire(Mode);

	if( !super.StartFire(Mode) )  // returns false when mag is empty
	   return false;

	if( AmmoAmount(0) <= 0 )
	{
    	return false;
    }

	AnimStopLooping();

	if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	else
	{
		return false;
	}

	return true;
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

	if(!FireMode[0].IsInState('FireLoop'))
	{
        GetAnimParams(0, anim, frame, rate);

        if (ClientState == WS_ReadyToFire)
        {
             if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
            {
                PlayIdle();
            }
        }
	}
}

simulated event OnZoomOutFinished()
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);

	if (ClientState == WS_ReadyToFire)
	{
		// Play the regular idle anim when we're finished zooming out
		if (anim == IdleAimAnim)
		{
            PlayIdle();
		}
		// Switch looping fire anims if we switched to/from zoomed
		else if( FireMode[0].IsInState('FireLoop') && anim == 'Fire_Iron_Loop')
		{
            LoopAnim('Fire_Loop', FireMode[0].FireLoopAnimRate, FireMode[0].TweenTime);
		}
	}
}

/**
 * Called by the native code when the interpolation of the first person weapon to the zoomed position finishes
 */
simulated event OnZoomInFinished()
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);

	if (ClientState == WS_ReadyToFire)
	{
		// Play the iron idle anim when we're finished zooming in
		if (anim == IdleAnim)
		{
		   PlayIdle();
		}
		// Switch looping fire anims if we switched to/from zoomed
		else if( FireMode[0].IsInState('FireLoop') && anim == 'Fire_Loop' )
		{
            LoopAnim('Fire_Iron_Loop', FireMode[0].FireLoopAnimRate, FireMode[0].TweenTime);
		}
	}
}

defaultproperties
{
     HealBoostAmount=20
     SuccessfulHealMessage="You healed "
     HealAmmoCharge=500
     AmmoRegenRate=0.300000
     MagCapacity=20
     ReloadRate=3.166000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_MP7"
     Weight=3.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=55.000000
     bModeZeroCanDryFire=True
     SleeveNum=2
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_MP7m'
     bIsTier2Weapon=True
     MeshRef="KF_Weapons2_Trip.MP7_Trip"
     SkinRefs(0)="KF_Weapons2_Trip_T.Special.MP_7_cmb"
     SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
     SelectSoundRef="KF_MP7Snd.MP7_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.MP7m_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.MP7m"
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'KFMod.MP7MFire'
     FireModeClass(1)=Class'KFMod.MP7MAltFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="An advanced prototype submachine gun. Modified to fire healing darts."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=55.000000
     Priority=90
     InventoryGroup=3
     GroupOffset=5
     PickupClass=Class'KFMod.MP7MPickup'
     PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.MP7MAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="MP7M Medic Gun"
     TransientSoundVolume=1.250000
}
