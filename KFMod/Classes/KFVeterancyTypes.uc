// Base class of all veterancy types
class KFVeterancyTypes extends Info
	abstract;

var byte PerkIndex;

var const float StartingWeaponSellPriceLevel5;
var const float StartingWeaponSellPriceLevel6;

// HUD Icon is what appears for other players next to playername, sub hud icon can stand for sergeant or something else..
var() texture OnHUDIcon, OnHUDGoldIcon;
var() localized string VeterancyName, Requirements[6];
var() localized string LevelNames[7], LevelEffects[7];

var() class<KFVeterancyTypes> ReplacementVeterancy; // Replace with this veterancy once this ones becomes available.

var string VetButtonStyle; // OBSOLOTE!

// Modify syringe charge speed
static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	return 1.0;
}

// Modify syringe potency
static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	return 1.0;
}

// Modify movement speed
static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	return 1.0;
}

// Modify movement speed ONLY when holding melee weapon
static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 0.0;
}

// Reduce damage zombies can deal to you
static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, Pawn Instigator, int InDamage, class<DamageType> DmgType)
{
	return InDamage;
}

// Add damage you deal to zombies
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn Instigator, int InDamage, class<DamageType> DmgType)
{
	return InDamage;
}

// Add max carry weight for weapons
static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	return 0;
}

// Welding speed modifier
static function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	return 1.0;
}

// Add extra ammo for a weapon
static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	return 1.0;
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	return 1.0;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	return 1.0;
}

// Multiply headshot damage
static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, KFPawn P, class<DamageType> DmgType)
{
	return 1.0;
}

// Render some extra info on HUD
static function SpecialHUDInfo(KFPlayerReplicationInfo KFPRI, Canvas C);

// Modify the spear/recoil for a weapon fire.
static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	Recoil = 1.0;
	return 1.0;
}

// Modify weapon reload speed
static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	return 1.0;
}

// Modify fire speed
static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	return 1.0;
}

// Can Clots grab me?
static function bool CanBeGrabbed(KFPlayerReplicationInfo KFPRI, KFMonster Other)
{
	return true;
}

// Show stalkers?
static function bool ShowStalkers(KFPlayerReplicationInfo KFPRI)
{
	return false;
}

// Get nades type.
static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
	return class'Nade';
}

// Change effective range on FLamethrower
static function int ExtraRange(KFPlayerReplicationInfo KFPRI)
{
	return 0;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	return 1.0;
}

// Change the cost of particular ammo
static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	return 1.0;
}

// Reduce damage when wearing Armor
static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	return 1.0;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P);

// Reduce Penetration damage with Shotgun slower
static function float GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo KFPRI, float DefaultPenDamageReduction)
{
	return DefaultPenDamageReduction;
}

// Modify the Distance at which Stalkers can be viewed when Cloaked(this is multiplied by a Squared Distance)
static function float GetStalkerViewDistanceMulti(KFPlayerReplicationInfo KFPRI)
{
	return 0.0;
}

// Set number times Zed Time can be extended
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	return 0;
}

// Modify MAC 10 ammo
static function class<DamageType> GetMAC10DamageType(KFPlayerReplicationInfo KFPRI)
{
	return class'DamTypeMAC10MP';
}

static function bool CanMeleeStun()
{
	return false;
}

static function bool ShouldBecomeIncendiary(KFPlayerReplicationInfo KFPRI, KFPawn P)
{
	return false;
}

static function bool KilledShouldExplode(KFPlayerReplicationInfo KFPRI, KFPawn P)
{
	return false;
}

defaultproperties
{
     PerkIndex=255
     StartingWeaponSellPriceLevel5=200.000000
     StartingWeaponSellPriceLevel6=225.000000
}
