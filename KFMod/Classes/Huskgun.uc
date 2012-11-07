//=============================================================================
// HuskGun
//=============================================================================
// Husk Arm fireball launching gun
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class HuskGun extends KFWeapon;

//=============================================================================
// Functions
//=============================================================================

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

simulated function AnimEnd(int channel)
{
    if (FireMode[0].bIsFiring)
    {
    	if( bAimingRifle )
    	{
    		LoopAnim('ChargeLoop_Iron');
    	}
    	else
    	{
    		LoopAnim('ChargeLoop');
    	}
    }
    else
    {
        Super.AnimEnd(channel);
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
		else if(anim == 'ChargeLoop_Iron')
		{
            LoopAnim('ChargeLoop');
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
		else if( anim == 'ChargeLoop' )
		{
            LoopAnim('ChargeLoop_Iron');
		}
	}
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

// complete cut n' paste job needed, so that it can be modified
// overriding to properly handly giving extra ammo to this weapon
// for the firebug perk
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
	local bool bJustSpawnedAmmo;
	local int addAmount, InitialAmount;
	local float AddMultiplier;

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if ( FireMode[m] != None && FireMode[m].AmmoClass != None )
	{
		Ammo[m] = Ammunition(Instigator.FindInventoryType(FireMode[m].AmmoClass));
		bJustSpawnedAmmo = false;

		if ( bNoAmmoInstances )
		{
			if ( (FireMode[m].AmmoClass == None) || ((m != 0) && (FireMode[m].AmmoClass == FireMode[0].AmmoClass)) )
				return;

			InitialAmount = FireMode[m].AmmoClass.Default.InitialAmount;

			if(WP!=none && WP.bThrown==true)
				InitialAmount = WP.AmmoAmount[m];
			else
			{
				// Other change - if not thrown, give the gun a full clip
				MagAmmoRemaining = MagCapacity;
			}

			if ( Ammo[m] != None )
			{
				addamount = InitialAmount + Ammo[m].AmmoAmount;
				Ammo[m].Destroy();
			}
			else
				addAmount = InitialAmount;

			AddAmmo(addAmount,m);
		}
		else
		{
			if ( (Ammo[m] == None) && (FireMode[m].AmmoClass != None) )
			{
				Ammo[m] = Spawn(FireMode[m].AmmoClass, Instigator);
				Instigator.AddInventory(Ammo[m]);
				bJustSpawnedAmmo = true;
			}
			else if ( (m == 0) || (FireMode[m].AmmoClass != FireMode[0].AmmoClass) )
				bJustSpawnedAmmo = ( bJustSpawned || ((WP != None) && !WP.bWeaponStay) );

	  	      // and here is the modification for instanced ammo actors

			if(WP!=none && WP.bThrown==true)
			{
				addAmount = WP.AmmoAmount[m];
			}
			else if ( bJustSpawnedAmmo )
			{
        		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
        		{
        			AddMultiplier = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), FireMode[m].AmmoClass);
        		}
        		else
        		{
                    AddMultiplier = 1.0;
        		}

				if (default.MagCapacity == 0)
					addAmount = 0;  // prevent division by zero.
				else
					addAmount = Ammo[m].InitialAmount * (float(MagCapacity) / float(default.MagCapacity)) * AddMultiplier;
			}

			if ( WP != none && WP.Class == class'BoomstickPickup' && m > 0 )
			{
				return;
			}

			Ammo[m].AddAmmo(addAmount);
			Ammo[m].GotoState('');
		}
	}
}

defaultproperties
{
     MagCapacity=1
     ReloadRate=0.010000
     Weight=8.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     TraderInfoTexture=Texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_Huskgun'
     bIsTier3Weapon=True
     MeshRef="KF_Wep_HuskGun.HuskGun_Trip"
     SkinRefs(0)="KF_Weapons4_Trip_T.Weapons.HUSKGun_shdr"
     SelectSoundRef="KF_HuskGunSnd.Husk_Select"
     HudImageRef="KillingFloor2HUD.WeaponSelect.Huskgun_unselected"
     SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.Huskgun"
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'KFMod.HuskGunFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="A fireball cannon ripped from the arm of a dead Husk. Does more damage when charged up."
     DisplayFOV=65.000000
     Priority=180
     InventoryGroup=4
     GroupOffset=7
     PickupClass=Class'KFMod.HuskGunPickup'
     PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.HuskGunAttachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="Husk Fireball Launcher"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
}
