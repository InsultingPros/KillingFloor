class KFVetFieldMedic extends KFVeterancyTypes
	abstract;

static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'MedicNade'; // Grenade detonations heal nearby teammates, and cause enemies to be poisoned

	return super.GetNadeType(KFPRI);
}

static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel == 0 )
	{
		return 1.10;
	}
	else if ( KFPRI.ClientVeteranSkillLevel <= 4 )
	{
		return 1.25 + (0.25 * float(KFPRI.ClientVeteranSkillLevel));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		return 2.50; // Recharges 150% faster
	}

	return 3.00; // Level 6 - Recharges 200% faster
}

static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel == 0 )
	{
		return 1.10;
	}
	else if ( KFPRI.ClientVeteranSkillLevel <= 2 )
	{
		return 1.25;
	}
	else if ( KFPRI.ClientVeteranSkillLevel <= 5 )
	{
		return 1.5;
	}

	return 1.75;  // Heals for 75% more
}

static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	// Medic movement speed reduced in Balance Round 2(limited to Suicidal and HoE in Round 7)
	if ( KFGRI.GameDiff >= 5.0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel <= 2 )
		{
			return 1.0;
		}

		return 1.05 + (0.05 * float(KFPRI.ClientVeteranSkillLevel - 3)); // Moves up to 20% faster
	}

	if ( KFPRI.ClientVeteranSkillLevel <= 1 )
	{
		return 1.0;
	}

	return 1.05 + (0.05 * float(KFPRI.ClientVeteranSkillLevel - 2)); // Moves up to 25% faster
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeVomit>(DmgType) != none )
	{
		// Medics don't damage themselves with the bile shooter
        if( Injured == Instigator )
		{
            return 0;
		}

        if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return float(InDamage) * 0.90;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return float(InDamage) * 0.75;
		}
		else if ( KFPRI.ClientVeteranSkillLevel <= 4 )
		{
			return float(InDamage) * 0.50;
		}

		return float(InDamage) * 0.25; // 75% decrease in damage from Bloat's Bile
	}

	return InDamage;
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( (MP7MMedicGun(Other) != none || MP5MMedicGun(Other) != none || M7A3MMedicGun(Other) != none
        || KrissMMedicGun(Other) != none || BlowerThrower(Other) != none )
        && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.20 * FMin(float(KFPRI.ClientVeteranSkillLevel), 5.0)); // 100% increase in Medic weapon ammo carry
	}

	return 1.0;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	if ( (MP7MAmmo(Other) != none || MP5MAmmo(Other) != none || M7A3MAmmo(Other) != none
        || KrissMAmmo(Other) != none || BlowerThrowerAmmo(Other) != none || CamoMP5MAmmo(Other) != none || NeonKrissMAmmo(Other) != none ) 
		&& KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.20 * FMin(float(KFPRI.ClientVeteranSkillLevel), 5.0)); // 100% increase in Medic weapon ammo carry
	}

	return 1.0;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'Vest' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel));  // Up to 70% discount on Body Armor
	}
	else if ( Item == class'MP7MPickup' || Item == class'MP5MPickup' || Item == class'M7A3MPickup'
        || Item == class'KrissMPickup' || Item == class'BlowerThrowerPickup' || Item == class'CamoMP5MPickup'
        || Item == class'NeonKrissMPickup' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Medic Weapons
	}

	return 1.0;
}

// Reduce damage when wearing Armor
static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel <= 5 )
	{
		return 1.0 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 50% improvement of Body Armor
	}

	return 0.25; // Level 6 - 75% Better Body Armor
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5 or Higher, give them Body Armor
	if ( KFPRI.ClientVeteranSkillLevel >= 5 )
	{
		P.ShieldStrength = 100;
	}

	// If Level 6, give them a Medic Gun
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.MP7MMedicGun", default.StartingWeaponSellPriceLevel6);
	}
}

defaultproperties
{
     PerkIndex=0
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Medic'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Medic_Gold'
     VeterancyName="Field Medic"
     Requirements(0)="Heal %x HP on your teammates"
     LevelEffects(0)="10% faster Syringe recharge|10% more potent healing|10% less damage from Bloat Bile|10% discount on Bio Weapons and Armor|Grenades heal teammates and hurt enemies"
     LevelEffects(1)="25% faster Syringe recharge|25% more potent healing|25% less damage from Bloat Bile|20% larger Bio Weapon clips|10% better Body Armor|20% discount on Bio Weapons and Armor|Grenades heal teammates and hurt enemies"
     LevelEffects(2)="50% faster Syringe recharge|25% more potent healing|50% less damage from Bloat Bile|5% faster movement speed|40% larger Bio Weapon clips|20% better Body Armor|30% discount on Bio Weapons and Armor|Grenades heal teammates and hurt enemies"
     LevelEffects(3)="75% faster Syringe recharge|50% more potent healing|50% less damage from Bloat Bile|10% faster movement speed|60% larger Bio Weapon clips|30% better Body Armor|40% discount on Bio Weapons and Armor|Grenades heal teammates and hurt enemies"
     LevelEffects(4)="100% faster Syringe recharge|50% more potent healing|50% less damage from Bloat Bile|15% faster movement speed|80% larger Bio Weapon clips|40% better Body Armor|50% discount on Bio Weapons and Armor|Grenades heal teammates and hurt enemies"
     LevelEffects(5)="150% faster Syringe recharge|50% more potent healing|75% less damage from Bloat Bile|20% faster movement speed|100% larger Bio Weapon clips|50% better Body Armor|60% discount on Bio Weapons and Armor|Grenades heal teammates and hurt enemies|Spawn with Body Armor"
     LevelEffects(6)="200% faster Syringe recharge|75% more potent healing|75% less damage from Bloat Bile|25% faster movement speed|100% larger Bio Weapon clips|75% better Body Armor|70% discount on Bio Weapons and Armor|Grenades heal teammates and hurt enemies|Spawn with Body Armor and Medic Gun"
}
