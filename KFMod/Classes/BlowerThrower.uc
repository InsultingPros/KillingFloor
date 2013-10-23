//=============================================================================
// BlowerThrower
//=============================================================================
// Weapon class for the bloat bile thrower
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class BlowerThrower extends KFWeapon;

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

// Allow this weapon to auto reload on alt fire
simulated function AltFire(float F)
{
	if( MagAmmoRemaining < 1 && !bIsReloading &&
		 FireMode[1].NextFireTime <= Level.TimeSeconds )
	{
		// We're dry, ask the server to autoreload
		ServerRequestAutoReload();

		PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
	}

	super.AltFire(F);
}

simulated function AnimEnd(int channel)
{
	if(!FireMode[0].IsInState('FireLoop'))
	{
	  	Super.AnimEnd(channel);
	}
}

function bool RecommendRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

simulated function bool ConsumeAmmo( int Mode, float Load, optional bool bAmountNeededIsMax )
{
	local Inventory Inv;
	local bool bOutOfAmmo;
	local KFWeapon KFWeap;

	if ( Super(Weapon).ConsumeAmmo(Mode, Load, bAmountNeededIsMax) )
	{
		if ( Load > 0 && (Mode == 0 || bReduceMagAmmoOnSecondaryFire) )
			MagAmmoRemaining -= Load;

		NetUpdateTime = Level.TimeSeconds - 1;

		if ( FireMode[Mode].AmmoPerFire > 0 && InventoryGroup > 0 && !bMeleeWeapon && bConsumesPhysicalAmmo &&
			 (Ammo[0] == none || FireMode[0] == none || FireMode[0].AmmoPerFire <= 0 || Ammo[0].AmmoAmount < FireMode[0].AmmoPerFire) &&
			 (Ammo[1] == none || FireMode[1] == none || FireMode[1].AmmoPerFire <= 0 || Ammo[1].AmmoAmount < FireMode[1].AmmoPerFire) )
		{
			bOutOfAmmo = true;

			for ( Inv = Instigator.Inventory; Inv != none; Inv = Inv.Inventory )
			{
				KFWeap = KFWeapon(Inv);

				if ( Inv.InventoryGroup > 0 && KFWeap != none && !KFWeap.bMeleeWeapon && KFWeap.bConsumesPhysicalAmmo &&
					 ((KFWeap.Ammo[0] != none && KFWeap.FireMode[0] != none && KFWeap.FireMode[0].AmmoPerFire > 0 &&KFWeap.Ammo[0].AmmoAmount >= KFWeap.FireMode[0].AmmoPerFire) ||
					 (KFWeap.Ammo[1] != none && KFWeap.FireMode[1] != none && KFWeap.FireMode[1].AmmoPerFire > 0 && KFWeap.Ammo[1].AmmoAmount >= KFWeap.FireMode[1].AmmoPerFire)) )
				{
					bOutOfAmmo = false;
					break;
				}
			}

			if ( bOutOfAmmo )
			{
				PlayerController(Instigator.Controller).Speech('AUTO', 3, "");
			}
		}

		return true;
	}
	return false;
}

defaultproperties
{
     MagCapacity=50
     ReloadRate=4.140000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_IJC_BlowerThrower"
     MinimumFireRange=300
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="Idle"
     QuickPutDownTime=0.250000
     StandardDisplayFOV=70.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_BlowerThrower'
     bIsTier2Weapon=True
     MeshRef="KF_IJC_Halloween_Weps_2.BlowerThrower"
     SkinRefs(0)="KF_IJC_Halloween_Weapons2.BlowerThrower.BlowerThrower_cmb"
     SelectSoundRef="KF_FY_BlowerThrowerSND.WEP_Bile_Foley_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.BlowerThrower_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.BlowerThrower"
     AppID=258751
     ZoomInRotation=(Pitch=-1000,Roll=1500)
     ZoomedDisplayFOV=60.000000
     FireModeClass(0)=Class'KFMod.BlowerThrowerFire'
     FireModeClass(1)=Class'KFMod.BlowerThrowerAltFire'
     PutDownAnim="PutDown"
     PutDownTime=0.500000
     AIRating=0.700000
     CurrentRating=0.700000
     Description="A leaf blower modified to launch deadly bloat bile. Spray it around and watch 'em burn!"
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=103
     InventoryGroup=3
     GroupOffset=21
     PickupClass=Class'KFMod.BlowerThrowerPickup'
     PlayerViewOffset=(X=15.000000,Y=20.000000,Z=-3.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.BlowerThrowerAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="BlowerThrower"
     TransientSoundVolume=1.250000
}
