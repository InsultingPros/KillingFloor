class KFVetBerserker extends KFVeterancyTypes
	abstract;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn Instigator, int InDamage, class<DamageType> DmgType)
{
	local float ret;
	local KFPawn Friendly;

	if( class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsMeleeDamage )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			ret = float(InDamage) * 1.10;
		}
		else
		{
			// Up to 100% increase in Melee Damage
			ret = float(InDamage) * (1.0 + (0.20 * float(Min(KFPRI.ClientVeteranSkillLevel, 5))));
		}
	}
	else
	{
		ret = InDamage;
	}


	return ret;
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	if ( KFMeleeGun(Other) != none  || Crossbuzzsaw(Other) != none)
	{
		switch ( KFPRI.ClientVeteranSkillLevel )
		{
			case 1:
				return 1.05;
			case 2:
			case 3:
				return 1.10;
			case 4:
				return 1.15;
			case 5:
				return 1.20;
			case 6:
				return 1.25; // 25% increase in wielding Melee Weapon
		}
	}

	return 1.0;
}

static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel == 0 )
	{
		return 0.05; // Was 0.10 in Balance Round 1
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 1 )
	{
		return 0.10; // Was 0.15 in Balance Round 1
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 2 )
	{
		return 0.15; // Was 0.20 in Balance Round 1
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		// Was 0.35 in Balance Round 1
		return 0.30; // Level 6 - 30% increase in movement speed while wielding Melee Weapon
	}

	// Was 0.25 in Balance Round 1
	return 0.20; // 20% increase in movement speed while wielding Melee Weapon
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, KFMonster Instigator, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeVomit' )
	{
		switch ( KFPRI.ClientVeteranSkillLevel )
		{
			case 0:
				return float(InDamage) * 0.90;
			case 1:
				return float(InDamage) * 0.75;
			case 2:
				return float(InDamage) * 0.65;
			case 3:
				return float(InDamage) * 0.50;
			case 4:
				return float(InDamage) * 0.35;
			case 5:
				return float(InDamage) * 0.25;
			case 6:
				return float(InDamage) * 0.20; // 80% reduced Bloat Bile damage
		}
	}

	switch ( KFPRI.ClientVeteranSkillLevel )
	{
//		This did exist in Balance Round 1, but was removed for Balance Round 2
//		case 0:
//			return float(InDamage) * 0.95;
		case 1:
			return float(InDamage) * 0.95; // was 0.90 in Balance Round 1
		case 2:
			return float(InDamage) * 0.90; // was 0.85 in Balance Round 1
		case 3:
			return float(InDamage) * 0.85; // was 0.80 in Balance Round 1
		case 4:
			return float(InDamage) * 0.80; // was 0.70 in Balance Round 1
		case 5:
			return float(InDamage) * 0.70; // was 0.60 in Balance Round 1
		case 6:
			return float(InDamage) * 0.60; // 40% reduced Damage(was 50% in Balance Round 1)
	}

	return InDamage;
}

// Added in Balance Round 1(returned false then, by accident, fixed in Balance Round 2)
static function bool CanMeleeStun()
{
	return true;
}

static function bool CanBeGrabbed(KFPlayerReplicationInfo KFPRI, KFMonster Other)
{
	return !Other.IsA('ZombieClot');
}

// Set number times Zed Time can be extended
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	return Min(KFPRI.ClientVeteranSkillLevel, 4);
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'ChainsawPickup' || Item == class'KatanaPickup' || Item == class'ClaymoreSwordPickup'
        || Item == class'CrossbuzzsawPickup' || Item == class'ScythePickup' || Item == class'GoldenKatanaPickup'
        || Item == class'MachetePickup' || Item == class'AxePickup' || Item == class'DwarfAxePickup' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Melee Weapons
	}

	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them Machete
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Machete", GetCostScaling(KFPRI, class'MachetePickup'));
	}

	// If Level 6, give them an Axe
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Axe", GetCostScaling(KFPRI, class'AxePickup'));
	}

	// If Level 6, give them Body Armor(Removed from Suicidal and HoE in Balance Round 7)
	if ( KFPRI.Level.Game.GameDifficulty < 5.0 && KFPRI.ClientVeteranSkillLevel == 6 )
	{
		P.ShieldStrength = 100;
	}
}

defaultproperties
{
     PerkIndex=4
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Berserker'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Berserker_Gold'
     VeterancyName="Berserker"
     Requirements(0)="Deal %x damage with melee weapons"
     LevelEffects(0)="10% extra melee damage|5% faster melee movement|10% less damage from Bloat Bile|10% discount on melee weapons|Can't be grabbed by Clots"
     LevelEffects(1)="20% extra melee damage|5% faster melee attacks|10% faster melee movement|25% less damage from Bloat Bile|5% resistance to all damage|20% discount on melee weapons|Can't be grabbed by Clots"
     LevelEffects(2)="40% extra melee damage|10% faster melee attacks|15% faster melee movement|35% less damage from Bloat Bile|10% resistance to all damage|30% discount on melee weapons|Can't be grabbed by Clots|Zed-Time can be extended by killing an enemy while in slow motion"
     LevelEffects(3)="60% extra melee damage|10% faster melee attacks|20% faster melee movement|50% less damage from Bloat Bile|15% resistance to all damage|40% discount on melee weapons|Can't be grabbed by Clots|Up to 2 Zed-Time Extensions"
     LevelEffects(4)="80% extra melee damage|15% faster melee attacks|20% faster melee movement|65% less damage from Bloat Bile|20% resistance to all damage|50% discount on melee weapons|Can't be grabbed by Clots|Up to 3 Zed-Time Extensions"
     LevelEffects(5)="100% extra melee damage|20% faster melee attacks|20% faster melee movement|75% less damage from Bloat Bile|30% resistance to all damage|60% discount on melee weapons|Spawn with a Machete|Can't be grabbed by Clots|Up to 4 Zed-Time Extensions"
     LevelEffects(6)="100% extra melee damage|25% faster melee attacks|30% faster melee movement|80% less damage from Bloat Bile|40% resistance to all damage|70% discount on melee weapons|Spawn with an Axe and Body Armor|Can't be grabbed by Clots|Up to 4 Zed-Time Extensions"
}
