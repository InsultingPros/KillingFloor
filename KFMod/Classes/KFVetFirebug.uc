class KFVetFirebug extends KFVeterancyTypes
	abstract;

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( Flamethrower(Other) != none && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% larger fuel canister
	}

	if ( MAC10MP(Other) != none && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.12 * FMin(float(KFPRI.ClientVeteranSkillLevel), 5.0)); // 60% increase in MAC10 ammo carry
	}

	/* Commented out for now, as it looks like this won't work right with weapons that reload with a single bullet
    if ( Trenchgun(Other) != none && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.12 * FMin(float(KFPRI.ClientVeteranSkillLevel), 5.0)); // 60% increase in Trenchgun ammo carry
	}*/

	return 1.0;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	if ( FlameAmmo(Other) != none && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% larger fuel canister
	}

	if ( MAC10Ammo(Other) != none && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% increase in MAC10 ammo carry
	}

	if ( HuskGunAmmo(Other) != none && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // 60% increase in Husk gun ammo carry
	}

	if ( TrenchgunAmmo(Other) != none && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // 60% increase in trench gun ammo carry
	}

	if ( FlareRevolverAmmo(Other) != none && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // 60% increase in flare gun ammo carry
	}

	return 1.0;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( AmmoType == class'FlameAmmo' && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% larger fuel canister
	}

	if ( AmmoType == class'MAC10Ammo' && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% increase in MAC10 ammo carry
	}

	if ( AmmoType == class'HuskGunAmmo' && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% increase in Husk gun ammo carry
	}

	if ( AmmoType == class'TrenchgunAmmo' && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% increase in Trench gun ammo carry
	}

	if ( AmmoType == class'FlareRevolverAmmo' && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% increase in Flare gun ammo carry
	}

	return 1.0;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn Instigator, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeBurned>(DmgType) != none || class<DamTypeFlamethrower>(DmgType) != none
        || class<DamTypeHuskGunProjectileImpact>(DmgType) != none || class<DamTypeFlareProjectileImpact>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return float(InDamage) * 1.05;
		}

		return float(InDamage) * (1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); //  Up to 60% extra damage
	}

	return InDamage;
}

// Change effective range on FlameThrower
static function int ExtraRange(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel <= 2 )
	{
		return 0;
	}
	else if ( KFPRI.ClientVeteranSkillLevel <= 4 )
	{
		return 1; // 50% Longer Range
	}

	return 2; // 100% Longer Range
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, KFMonster Instigator, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeBurned>(DmgType) != none || class<DamTypeFlamethrower>(DmgType) != none
        || class<DamTypeHuskGunProjectileImpact>(DmgType) != none || class<DamTypeFlareProjectileImpact>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel <= 3 )
		{
			return float(InDamage) * (0.50 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)));
		}

		return 0; // 100% reduction in damage from fire
	}

	return InDamage;
}

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel >= 3 )
	{
		return class'FlameNade'; // Grenade detonations cause enemies to catch fire
	}

	return super.GetNadeType(KFPRI);
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( Flamethrower(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return 1.0;
		}

		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster reload with Flamethrower
	}

	if ( MAC10MP(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return 1.0;
		}

		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster reload with MAC-10
	}

	if ( Trenchgun(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return 1.0;
		}

		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster reload with Trench gun
	}

	if ( FlareRevolver(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return 1.0;
		}

		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster reload with FlareRevolver
	}

	if ( DualFlareRevolver(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return 1.0;
		}

		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster reload with Dual FlareRevolver
	}

	return 1.0;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'FlameThrowerPickup' || Item == class'MAC10Pickup'
        || Item == class'HuskGunPickup' || Item == class'TrenchgunPickup' || Item == class'FlareRevolverPickup'
        || Item == class'DualFlareRevolverPickup' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Flame Weapons
	}

	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them a Flame Thrower
	if ( KFPRI.ClientVeteranSkillLevel >= 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.FlameThrower", GetCostScaling(KFPRI, class'FlamethrowerPickup'));
	}

	// If Level 6, add Body Armor
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		P.ShieldStrength = 100;
	}
}

static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeMAC10MPInc';
}

defaultproperties
{
     PerkIndex=5
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Firebug'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Firebug_Gold'
     VeterancyName="Firebug"
     Requirements(0)="Deal %x damage with the flame weapons"
     LevelEffects(0)="5% extra flame weapon damage|50% resistance to fire|10% discount on the flame weapons"
     LevelEffects(1)="10% extra flame weapon damage|10% faster Flamethrower reload|10% more flame weapon ammo|60% resistance to fire|20% discount on flame weapons"
     LevelEffects(2)="20% extra flame weapon damage|20% faster Flamethrower reload|20% more flame weapon ammo|70% resistance to fire|30% discount on flame weapons"
     LevelEffects(3)="30% extra flame weapon damage|30% faster Flamethrower reload|30% more flame weapon ammo|80% resistance to fire|50% extra Flamethrower range|Grenades set enemies on fire|40% discount on flame weapons"
     LevelEffects(4)="40% extra flame weapon damage|40% faster Flamethrower reload|40% more flame weapon ammo|90% resistance to fire|50% extra Flamethrower range|Grenades set enemies on fire|50% discount on flame weapons"
     LevelEffects(5)="50% extra flame weapon damage|50% faster Flamethrower reload|50% more flame weapon ammo|100% resistance to fire|100% extra Flamethrower range|Grenades set enemies on fire|60% discount on flame weapons|Spawn with a Flamethrower"
     LevelEffects(6)="60% extra flame weapon damage|60% faster Flamethrower reload|60% more flame weapon ammo|100% resistance to fire|100% extra Flamethrower range|Grenades set enemies on fire|70% discount on flame weapons|Spawn with a Flamethrower and Body Armor"
}
