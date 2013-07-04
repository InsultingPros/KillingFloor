class KFVetDemolitions extends KFVeterancyTypes
	abstract;

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( AmmoType == class'FragAmmo'  )
	{
		// Up to 6 extra Grenades
		return 1.0 + (0.20 * float(KFPRI.ClientVeteranSkillLevel));
	}
	else if ( AmmoType == class'PipeBombAmmo' )
	{
		// Up to 6 extra for a total of 8 Remote Explosive Devices
		return 1.0 + (0.5 * float(KFPRI.ClientVeteranSkillLevel));
	}
	else if ( AmmoType == class'LAWAmmo' )
	{
		// Modified in Balance Round 5 to be up to 100% extra ammo
		return 1.0 + (0.20 * float(KFPRI.ClientVeteranSkillLevel));
	}

	return 1.0;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn Instigator, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeFrag>(DmgType) != none || class<DamTypePipeBomb>(DmgType) != none ||
		 class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none
         || class<DamTypeM203Grenade>(DmgType) != none || class<DamTypeRocketImpact>(DmgType) != none
         || class<DamTypeSPGrenade>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return float(InDamage) * 1.05;
		}

		return float(InDamage) * (1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); //  Up to 60% extra damage
	}

	return InDamage;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, KFMonster Instigator, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeFrag>(DmgType) != none || class<DamTypePipeBomb>(DmgType) != none ||
		 class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none
         || class<DamTypeM203Grenade>(DmgType) != none || class<DamTypeRocketImpact>(DmgType) != none
         || class<DamTypeSPGrenade>(DmgType) != none )
	{
		return float(InDamage) * (0.75 - (0.05 * float(KFPRI.ClientVeteranSkillLevel)));
	}

	return InDamage;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'PipeBombPickup' )
	{
		// Todo, this won't need to be so extreme when we set up the system to only allow him to buy it perhaps
		return 0.5 - (0.04 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 74% discount on PipeBomb(changed to 68% in Balance Round 1, upped to 74% in Round 4)
	}
	else if ( Item == class'M79Pickup' || Item == class 'M32Pickup'
        || Item == class 'LawPickup' || Item == class 'M4203Pickup'
        || Item == class'GoldenM79Pickup' || Item == class'SPGrenadePickup' )
	{
		return 0.90 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on M79/M32
	}

	return 1.0;
}

// Change the cost of particular ammo
static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'PipeBombPickup' )
	{
		return 0.5 - (0.04 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 74% discount on PipeBomb(changed to 68% in Balance Round 3, upped to 74% in Round 4)
	}
	else if ( Item == class'M79Pickup' || Item == class'M32Pickup'
        || Item == class'LAWPickup' || Item == class'M4203Pickup'
        || Item == class'GoldenM79Pickup' || Item == class'SPGrenadePickup' )
	{
		return 1.0 - (0.05 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 30% discount on Grenade Launcher and LAW Ammo(Balance Round 5)
	}

	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them a pipe bomb
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.PipeBombExplosive", GetCostScaling(KFPRI, class'PipeBombPickup'));
	}

	// If Level 6, give them a M79Grenade launcher and pipe bomb
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.PipeBombExplosive", GetCostScaling(KFPRI, class'PipeBombPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M79GrenadeLauncher", GetCostScaling(KFPRI, class'M79Pickup'));
	}
}

defaultproperties
{
     PerkIndex=6
     OnHUDIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition_Gold'
     VeterancyName="Demolitions"
     Requirements(0)="Deal %x damage with the Explosives"
     LevelEffects(0)="5% extra Explosives damage|25% resistance to Explosives|10% discount on Explosives|50% off Remote Explosives"
     LevelEffects(1)="10% extra Explosives damage|30% resistance to Explosives|20% increase in grenade capacity|Can carry 3 Remote Explosives|20% discount on Explosives|54% off Remote Explosives"
     LevelEffects(2)="20% extra Explosives damage|35% resistance to Explosives|40% increase in grenade capacity|Can carry 4 Remote Explosives|30% discount on Explosives|58% off Remote Explosives"
     LevelEffects(3)="30% extra Explosives damage|40% resistance to Explosives|60% increase in grenade capacity|Can carry 5 Remote Explosives|40% discount on Explosives|62% off Remote Explosives"
     LevelEffects(4)="40% extra Explosives damage|45% resistance to Explosives|80% increase in grenade capacity|Can carry 6 Remote Explosives|50% discount on Explosives|66% off Remote Explosives"
     LevelEffects(5)="50% extra Explosives damage|50% resistance to Explosives|100% increase in grenade capacity|Can carry 7 Remote Explosives|60% discount on Explosives|70% off Remote Explosives|Spawn with a Pipe Bomb"
     LevelEffects(6)="60% extra Explosives damage|55% resistance to Explosives|120% increase in grenade capacity|Can carry 8 Remote Explosives|70% discount on Explosives|74% off Remote Explosives|Spawn with an M79 and Pipe Bomb"
}
