class KFVetSharpshooter extends KFVeterancyTypes
	abstract;

// Removed all General Damage additions for the Sharpshooter in Balance Round 6 in favor of a headshot focus
//static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn Instigator, int InDamage, class<DamageType> DmgType)

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn P, class<DamageType> DmgType)
{
	local float ret;

	// Removed extra SS Crossbow headshot damage in Round 1(added back in Round 2) and Removed Single/Dualies Damage for Hell on Earth in Round 6
	// Added Dual Deagles back in for Balance Round 7
	if ( DmgType == class'DamTypeCrossbow' || DmgType == class'DamTypeCrossbowHeadShot' || DmgType == class'DamTypeWinchester' ||
		 DmgType == class'DamTypeDeagle' || DmgType == class'DamTypeDualDeagle' || DmgType == class'DamTypeM14EBR' ||
		  DmgType == class'DamTypeMagnum44Pistol' || DmgType == class'DamTypeDual44Magnum'
          || DmgType == class'DamTypeMK23Pistol' || DmgType == class'DamTypeDualMK23Pistol'
          || DmgType == class'DamTypeM99SniperRifle' || DmgType == class'DamTypeM99HeadShot' ||
          DmgType == class'DamTypeSPSniper' ||
		 (DmgType == class'DamTypeDualies' && KFPRI.Level.Game.GameDifficulty < 7.0) )
	{
		if ( KFPRI.ClientVeteranSkillLevel <= 3 )
		{
			ret = 1.05 + (0.05 * float(KFPRI.ClientVeteranSkillLevel));
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 4 )
		{
			ret = 1.30;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 5 )
		{
			ret = 1.50;
		}
		else
		{
			ret = 1.60; // 60% increase in Crossbow/Winchester/Handcannon damage
		}
	}
	// Reduced extra headshot damage for Single/Dualies in Hell on Earth difficulty(added in Balance Round 6)
	else if ( DmgType == class'DamTypeDualies' && KFPRI.Level.Game.GameDifficulty >= 7.0 )
	{
		return (1.0 + (0.08 * float(Min(KFPRI.ClientVeteranSkillLevel, 5)))); // 40% increase in Headshot Damage
	}
	else
	{
		ret = 1.0; // Fix for oversight in Balance Round 6(which is the reason for the Round 6 second attempt patch)
	}

	if ( KFPRI.ClientVeteranSkillLevel == 0 )
	{
		return ret * 1.05;
	}

	return ret * (1.0 + (0.10 * float(Min(KFPRI.ClientVeteranSkillLevel, 5)))); // 50% increase in Headshot Damage
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	if ( Crossbow(Other.Weapon) != none || Winchester(Other.Weapon) != none
        || Single(Other.Weapon) != none || Dualies(Other.Weapon) != none
        || Deagle(Other.Weapon) != none || DualDeagle(Other.Weapon) != none
		|| M14EBRBattleRifle(Other.Weapon) != none || M99SniperRifle(Other.Weapon) != none
        || SPSniperRifle(Other.Weapon) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1)
		{
			Recoil = 0.75;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			Recoil = 0.50;
		}
		else
		{
			Recoil = 0.25; // 75% recoil reduction with Crossbow/Winchester/Handcannon
		}

		return Recoil;
	}

	Recoil = 1.0;
	Return Recoil;
}

// Modify fire speed
static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	if ( Winchester(Other) != none || Crossbow(Other) != none || M99SniperRifle(Other) != none
        || SPSniperRifle(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return 1.0;
		}

		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster fire rate with Winchester
	}

	return 1.0;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( Crossbow(Other) != none || Winchester(Other) != none
		 || Single(Other) != none || Dualies(Other) != none
         || Deagle(Other) != none || DualDeagle(Other) != none
         || MK23Pistol(Other) != none || DualMK23Pistol(Other) != none
         || M14EBRBattleRifle(Other) != none || Magnum44Pistol(Other) != none
         || Dual44Magnum(Other) != none || SPSniperRifle(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return 1.0;
		}

		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster reload with Crossbow/Winchester/Handcannon
	}

	return 1.0;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'DeaglePickup' || Item == class'DualDeaglePickup' ||
	    Item == class'MK23Pickup' || Item == class'DualMK23Pickup' ||
        Item == class'Magnum44Pickup' || Item == class'Dual44MagnumPickup'
        || Item == class'M14EBRPickup' || Item == class'M99Pickup'
        || Item == class'SPSniperPickup' || Item == class'GoldenDeaglePickup'
        || Item == class'GoldenDualDeaglePickup' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Handcannon/Dual Handcannons/EBR/44 Magnum(s)
	}

	return 1.0;
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'CrossbowPickup' )
	{
		return 1.0 - (0.07 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 42% discount on Crossbow Bolts(Added in Balance Round 4 at 30%, increased to 42% in Balance Round 7)
	}

	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them a  Lever Action Rifle
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Winchester", default.StartingWeaponSellPriceLevel5);
	}

	// If Level 6, give them a Crossbow
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", default.StartingWeaponSellPriceLevel6);
	}
}

defaultproperties
{
     PerkIndex=2
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_SharpShooter'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_SharpShooter_Gold'
     VeterancyName="Sharpshooter"
     Requirements(0)="Get %x headshot kills with Pistols, Rifle, Crossbow, M14, M99, or S.P. Musket"
     LevelEffects(0)="5% more damage with Pistols, Rifle, Crossbow, M14, and M99|5% extra Headshot damage with all weapons|10% discount on Handcannon/M14/M99"
     LevelEffects(1)="10% more damage with Pistols, Rifle, Crossbow, M14, and M99|25% less recoil with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|10% faster reload with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|10% extra headshot damage|20% discount on Handcannon/44 Magnum/M14/M99/S.P. Musket"
     LevelEffects(2)="15% more damage with Pistols, Rifle, Crossbow, M14, and M99|50% less recoil with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|20% faster reload with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|20% extra headshot damage|30% discount on Handcannon/44 Magnum/M14/M99/S.P. Musket"
     LevelEffects(3)="20% more damage with Pistols, Rifle, Crossbow, M14, and M99|75% less recoil with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|30% faster reload with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|30% extra headshot damage|40% discount on Handcannon/44 Magnum/M14/M99/S.P. Musket"
     LevelEffects(4)="30% more damage with Pistols, Rifle, Crossbow, M14, and M99|75% less recoil with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|40% faster reload with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|40% extra headshot damage|50% discount on Handcannon/44 Magnum/M14/M99/S.P. Musket"
     LevelEffects(5)="50% more damage with Pistols, Rifle, Crossbow, M14, and M99|75% less recoil with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|50% faster reload with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|50% extra headshot damage|60% discount on Handcannon/44 Magnum/M14/M99/S.P. Musket|Spawn with a Lever Action Rifle"
     LevelEffects(6)="60% more damage with Pistols, Rifle, Crossbow, M14, and M99|75% less recoil with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|60% faster reload with Pistols, Rifle, Crossbow, M14, M99, and S.P. Musket|50% extra headshot damage|70% discount on Handcannon/44 Magnum/M14/M99/S.P. Musket|Spawn with a Crossbow"
}
