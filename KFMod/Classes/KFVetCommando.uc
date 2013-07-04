class KFVetCommando extends KFVeterancyTypes
	abstract;

// Display enemy health bars
static function SpecialHUDInfo(KFPlayerReplicationInfo KFPRI, Canvas C)
{
	local KFMonster KFEnemy;
	local HUDKillingFloor HKF;
	local float MaxDistanceSquared;

	if ( KFPRI.ClientVeteranSkillLevel > 0 )
	{
		HKF = HUDKillingFloor(C.ViewPort.Actor.myHUD);

		if ( HKF == none || C.ViewPort.Actor.Pawn == none )
		{
			return;
		}

		switch ( KFPRI.ClientVeteranSkillLevel )
		{
			case 1:
				MaxDistanceSquared = 25600; // 20% (160 units)
				break;
			case 2:
				MaxDistanceSquared = 102400; // 40% (320 units)
				break;
			case 3:
				MaxDistanceSquared = 230400; // 60% (480 units)
				break;
			case 4:
				MaxDistanceSquared = 409600; // 80% (640 units)
				break;
			case 5:
			case 6:
				MaxDistanceSquared = 640000; // 100% (800 units)
				break;
		}

		foreach C.ViewPort.Actor.DynamicActors(class'KFMonster',KFEnemy)
		{
			if ( KFEnemy.Health > 0 && (!KFEnemy.Cloaked() || KFEnemy.bZapped || KFEnemy.bSpotted) && VSizeSquared(KFEnemy.Location - C.ViewPort.Actor.Pawn.Location) < MaxDistanceSquared )
			{
				HKF.DrawHealthBar(C, KFEnemy, KFEnemy.Health, KFEnemy.HealthMax , 50.0);
			}
		}
	}
}

static function bool ShowStalkers(KFPlayerReplicationInfo KFPRI)
{
	return true;
}

static function float GetStalkerViewDistanceMulti(KFPlayerReplicationInfo KFPRI)
{
	switch ( KFPRI.ClientVeteranSkillLevel )
	{
		case 0:
			return 0.0625; // 25%
		case 1:
			return 0.25; // 50%
		case 2:
			return 0.36; // 60%
		case 3:
			return 0.49; // 70%
		case 4:
			return 0.64; // 80%
	}

	return 1.0; // 100% of Standard Distance(800 units or 16 meters)
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( (Bullpup(Other) != none || AK47AssaultRifle(Other) != none ||
        SCARMK17AssaultRifle(Other) != none || M4AssaultRifle(Other) != none
        || FNFAL_ACOG_AssaultRifle(Other) != none || MKb42AssaultRifle(Other) != none
        || ThompsonSMG(Other) != none || ThompsonDrumSMG(Other) != none
        || SPThompsonSMG(Other) != none) &&
        KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return 1.10;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			return 1.20;
		}

		return 1.25; // 25% increase in assault rifle ammo carry
	}

	return 1.0;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	if ( (BullpupAmmo(Other) != none || AK47Ammo(Other) != none ||
        SCARMK17Ammo(Other) != none || M4Ammo(Other) != none
        || FNFALAmmo(Other) != none || MKb42Ammo(Other) != none
        || ThompsonAmmo(Other) != none || GoldenAK47Ammo(Other) != none
        || ThompsonDrumAmmo(Other) != none || SPThompsonAmmo(Other) != none ) &&
        KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return 1.10;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			return 1.20;
		}

		return 1.25; // 25% increase in assault rifle ammo carry
	}

	return 1.0;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( (AmmoType == class'BullpupAmmo' || AmmoType == class'AK47Ammo' ||
        AmmoType == class'SCARMK17Ammo' || AmmoType == class'M4Ammo'
        || AmmoType == class'FNFALAmmo' || AmmoType == class'MKb42Ammo'
        || AmmoType == class'ThompsonAmmo' || AmmoType == class'GoldenAK47Ammo'
        || AmmoType == class'ThompsonDrumAmmo' || AmmoType == class'SPThompsonAmmo' )
        && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return 1.10;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			return 1.20;
		}

		return 1.25; // 25% increase in assault rifle ammo carry
	}

	return 1.0;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn Instigator, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeBullpup' || DmgType == class'DamTypeAK47AssaultRifle' ||
        DmgType == class'DamTypeSCARMK17AssaultRifle' || DmgType == class'DamTypeM4AssaultRifle'
        || DmgType == class'DamTypeFNFALAssaultRifle' || DmgType == class'DamTypeMKb42AssaultRifle'
        || DmgType == class'DamTypeThompson' || DmgType == class'DamTypeThompsonDrum'
        || DmgType == class'DamTypeSPThompson' )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return float(InDamage) * 1.05;
		}

		return float(InDamage) * (1.00 + (0.10 * float(Min(KFPRI.ClientVeteranSkillLevel, 5)))); // Up to 50% increase in Damage with Bullpup
	}

	return InDamage;
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	if ( Bullpup(Other.Weapon) != none || AK47AssaultRifle(Other.Weapon) != none ||
        SCARMK17AssaultRifle(Other.Weapon) != none || M4AssaultRifle(Other.Weapon) != none
        || FNFAL_ACOG_AssaultRifle(Other.Weapon) != none || MKb42AssaultRifle(Other.Weapon) != none
        || ThompsonSMG(Other.Weapon) != none || ThompsonDrumSMG(Other.Weapon) != none
        || SPThompsonSMG(Other.Weapon) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel <= 3 )
		{
			Recoil = 0.95 - (0.05 * float(KFPRI.ClientVeteranSkillLevel));
		}
		else if ( KFPRI.ClientVeteranSkillLevel <= 5 )
		{
			Recoil = 0.70;
		}
		else
		{
			Recoil = 0.60; // Level 6 - 40% recoil reduction
		}

		return Recoil;
	}

	Recoil = 1.0;
	return Recoil;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	return 1.05 + (0.05 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 35% faster reload speed
}

// Set number times Zed Time can be extended
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel >= 3 )
	{
		return KFPRI.ClientVeteranSkillLevel - 2; // Up to 4 Zed Time Extensions
	}

	return 0;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'BullpupPickup' || Item == class'AK47Pickup' ||
        Item == class'SCARMK17Pickup' || Item == class'M4Pickup'
        || Item == class'FNFAL_ACOG_Pickup' || Item == class'MKb42Pickup'
        || Item == class'ThompsonPickup' || Item == class'GoldenAK47Pickup'
        || Item == class'ThompsonDrumPickup' || Item == class'SPThompsonPickup' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Assault Rifles
	}

	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them Bullpup
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Bullpup", GetCostScaling(KFPRI, class'BullpupPickup'));
	}

	// If Level 6, give them an AK47
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	}
}

defaultproperties
{
     PerkIndex=3
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Commando'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Commando_Gold'
     VeterancyName="Commando"
     Requirements(0)="Kill %x stalkers with Assault/Battle Rifles"
     Requirements(1)="Deal %x damage with Assault/Battle Rifles"
     LevelEffects(0)="5% more damage with Assault/Battle Rifles|5% less recoil with Assault/Battle Rifles|5% faster reload with all weapons|10% discount on Assault/Battle Rifles|Can see cloaked Stalkers from 4 meters"
     LevelEffects(1)="10% more damage with Assault/Battle Rifles|10% less recoil with Assault/Battle Rifles|10% larger Assault/Battle Rifles clip|10% faster reload with all weapons|20% discount on Assault/Battle Rifles|Can see cloaked Stalkers from 8m|Can see enemy health from 4m"
     LevelEffects(2)="20% more damage with Assault/Battle Rifles|15% less recoil with Assault/Battle Rifles|20% larger Assault/Battle Rifles clip|15% faster reload with all weapons|30% discount on Assault/Battle Rifles|Can see cloaked Stalkers from 10m|Can see enemy health from 7m"
     LevelEffects(3)="30% more damage with Assault/Battle Rifles|20% less recoil with Assault/Battle Rifles|25% larger Assault/Battle Rifles clip|20% faster reload with all weapons|40% discount on Assault/Battle Rifles|Can see cloaked Stalkers from 12m|Can see enemy health from 10m|Zed-Time can be extended by killing an enemy while in slow motion"
     LevelEffects(4)="40% more damage with Assault/Battle Rifles|30% less recoil with Assault/Battle Rifles|25% larger Assault/Battle Rifles clip|25% faster reload with all weapons|50% discount on Assault/Battle Rifles|Can see cloaked Stalkers from 14m|Can see enemy health from 13m|Up to 2 Zed-Time Extensions"
     LevelEffects(5)="50% more damage with Assault/Battle Rifles|30% less recoil with Assault/Battle Rifles|25% larger Assault/Battle Rifles clip|30% faster reload with all weapons|60% discount on Assault/Battle Rifles|Spawn with a Bullpup|Can see cloaked Stalkers from 16m|Can see enemy health from 16m|Up to 3 Zed-Time Extensions"
     LevelEffects(6)="50% more damage with Assault/Battle Rifles|40% less recoil with Assault/Battle Rifles|25% larger Assault/Battle Rifles clip|35% faster reload with all weapons|70% discount on Assault/Battle Rifles|Spawn with an AK47|Can see cloaked Stalkers from 16m|Can see enemy health from 16m|Up to 4 Zed-Time Extensions"
}
