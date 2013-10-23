//=============================================================================
// ZEDMKIIWeapon
//=============================================================================
// Inventory class for the Zed Gun Mark II Weapon
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZEDMKIIWeapon extends KFWeapon;

var float           EnemyUpdateTime;

var()   sound   AlarmSound;      // An alarm that sounds when big guys get near
var     float   NextAlarmTime;   // The next time this alarm goes off
var     float   LastAlarmTime;   // The last time the alarm went off
var     bool    bAlarmStatus;
var     bool    bOldAlarmStatus;

// LED lights
var() Material LedOnMaterial;
var() Material LedOffMaterial;
// References to led lights
var	string	LedOnMaterialRef;
var	string	LedOffMaterialRef;

replication
{
	reliable if(Role == ROLE_Authority)
		ClientAlarmSound;
}

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	default.LedOnMaterial = Material(DynamicLoadObject(default.LedOnMaterialRef, class'Material', true));
	default.LedOffMaterial = Material(DynamicLoadObject(default.LedOffMaterialRef, class'Material', true));

	if ( ZEDMKIIWeapon(Inv) != none )
	{
	    ZEDMKIIWeapon(Inv).LedOnMaterial = default.LedOnMaterial;
        ZEDMKIIWeapon(Inv).LedOffMaterial = default.LedOffMaterial;
	}

	super.PreloadAssets(Inv, bSkipRefCount);
}

static function bool UnloadAssets()
{
	if ( super.UnloadAssets() )
	{
		default.LedOnMaterial = none;
		default.LedOffMaterial = none;

		return true;
	}

	return false;
}

// Overridden to handle reducing the ammo for the secondary fire
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

// Allow this weapon to auto reload on alt fire
simulated function AltFire(float F)
{
	if( !bIsReloading &&
		 FireMode[1].NextFireTime <= Level.TimeSeconds )
	{
		// We're dry, ask the server to autoreload
		if( MagAmmoRemaining < 1 )
		{
            ServerRequestAutoReload();
            PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
        }
        else if( MagAmmoRemaining < FireMode[1].AmmoPerFire )
        {
        	PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
        }
	}

	super.AltFire(F);
}


simulated function WeaponTick(float dt)
{
	local int TeamIndex, i;
	local Pawn EnemyPawn;
	local KFPlayerController KFPC;
	local float MaxThreat, HighestThreatDist;
	local float UsedAlarmTime;

	super.WeaponTick(dt);

	// Update the motion tracker screen
    if ( ROLE == ROLE_Authority && Instigator != none )
	{
		if( EnemyUpdateTime <= 0 )
		{
            EnemyUpdateTime = 0.2;

            TeamIndex = Instigator.GetTeamNum();

        	KFPC = KFPlayerController(Instigator.Controller);
        	if ( KFPC != none  )
            {
        		foreach Instigator.CollidingActors(class'Pawn', EnemyPawn, 1875)
        		{
        			if ( EnemyPawn.Health > 0 && EnemyPawn.GetTeamNum() != TeamIndex )
        			{
                        if( KFMonster(EnemyPawn) != none )
        				{

        				    if( KFMonster(EnemyPawn).MotionDetectorThreat > MaxThreat ||
                                (KFMonster(EnemyPawn).MotionDetectorThreat >= 3.0 && (VSize(EnemyPawn.Location - Instigator.Location) < HighestThreatDist)) )
        				    {
        				        HighestThreatDist = VSize( EnemyPawn.Location - Instigator.Location );
                                MaxThreat = KFMonster(EnemyPawn).MotionDetectorThreat;

        				    }
        				}
        				i+=1;
        			}
        		}

                if( MaxThreat >= 3.0 )
                {
            		UsedAlarmTime = Level.TimeSeconds - NextAlarmTime;

                    if( UsedAlarmTime >= 0 )
            		{
                        if( HighestThreatDist < 500 )
                        {
                            if( MaxThreat >= 5.0 )
                            {
                                NextAlarmTime = Level.TimeSeconds + 0.5;
                            }
                            else
                            {
                                NextAlarmTime = Level.TimeSeconds + 1.0;
                            }
                        }
                        else
                        {
                            NextAlarmTime = Level.TimeSeconds + 2.0;
                        }

                        if( Level.NetMode == NM_DedicatedServer )
                        {
                            ClientAlarmSound();
                        }
                        PlayOwnedSound(AlarmSound,SLOT_None,2.0,,TransientSoundRadius,,false);

                        if( Instigator.IsLocallyControlled() && Level.NetMode != NM_DedicatedServer )
                        {
                            LastAlarmTime = Level.TimeSeconds;
                            bAlarmStatus = true;
                            Skins[1] = LedOnMaterial;
                        }
                    }
                }
    		}
		}
		else
		{
            EnemyUpdateTime -= dt;
		}
	}

	if( bAlarmStatus != bOldAlarmStatus && Instigator.IsLocallyControlled()
        && Level.NetMode != NM_DedicatedServer)
    {
        if( bAlarmStatus && ((Level.TimeSeconds - LastAlarmTime) > 0.2) )
        {
            bAlarmStatus = false;
            bOldAlarmStatus = bAlarmStatus;
            Skins[1] = LedOffMaterial;
        }

    }
}

simulated function ClientAlarmSound()
{
    PlayOwnedSound(AlarmSound,SLOT_None,2.0,,TransientSoundRadius,,false);

    LastAlarmTime = Level.TimeSeconds;
    bAlarmStatus = true;
    Skins[1] = LedOnMaterial;
}

defaultproperties
{
     AlarmSound=Sound'KF_FY_ZEDV2SND.foley.WEP_ZEDV2_Alert'
     LedOnMaterialRef="KF_IJC_Halloween_Weapons2.ZEDV2.ZED_V2_LED_ON_SHDR"
     LedOffMaterialRef="'KF_IJC_Halloween_Weapons2.ZEDV2.ZEDV2_LED"
     MagCapacity=30
     ReloadRate=1.900000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_IJC_ZEDV2"
     Weight=6.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     SleeveNum=3
     TraderInfoTexture=Texture'KF_IJC_HUD.Trader_Weapon_Icons.Trader_ZEDV2'
     bIsTier2Weapon=True
     MeshRef="KF_IJC_Halloween_Weps_2.ZEDV2"
     SkinRefs(0)="KF_IJC_Halloween_Weapons2.ZEDV2.ZEDV2_SHDR"
     SkinRefs(1)="KF_IJC_Halloween_Weapons2.ZEDV2.ZEDV2_LED"
     SkinRefs(2)="KF_IJC_Halloween_Weapons2.ZEDV2.ZEDV2_Sight_SHDR"
     SelectSoundRef="KF_FY_ZEDV2SND.WEP_ZEDV2_Foley_Select"
     HudImageRef="KF_IJC_HUD.WeaponSelect.ZEDV2_unselected"
     SelectedHudImageRef="KF_IJC_HUD.WeaponSelect.ZEDV2"
     AppID=258751
     PlayerIronSightFOV=80.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'KFMod.ZEDMKIIFire'
     FireModeClass(1)=Class'KFMod.ZEDMKIIAltFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="The second revision of the ZED gun. Smaller and more light weight, but not quite as powerful as the original."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=65.000000
     Priority=132
     InventoryGroup=3
     GroupOffset=23
     PickupClass=Class'KFMod.ZEDMKIIPickup'
     PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-2.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.ZEDMKIIAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="ZED GUN MKII"
     TransientSoundVolume=1.250000
}
