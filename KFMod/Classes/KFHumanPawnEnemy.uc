//=============================================================================
// KFPawn
//=============================================================================
class KFHumanPawnEnemy extends KFHumanPawn;

var() enum ESoldierOrders
{
	ORDER_Guarding, // Just stand still fooling around...
	ORDER_Wander, // Randomly walk around ...
	ORDER_Hunt, // Actively hunt for enemies
	ORDER_Patrol // Follow patroling points (start as guarding if bStartPatrolOnTrigger)
} SoldierOrders;
var() enum ESoldierAttitude
{
	ATTITUDE_Hate, // Shoot right away
	ATTITUDE_Ignore, // Ignore as long as not being bumped or damaged
	ATTITUDE_Friendly, // Act as a friend
	ATTITUDE_FollowOnUse, // Follow when used, stop following when used again.
	ATTITUDE_FollowOnSee // Follow on see
} AttitudeToPlayer,AttitudeToSpecimen;

var() float Accuracy,ReactionTime;
var() int HealthMod;
var() class<Weapon> WeaponType;
var() bool bStationaryCombat,bStartPatrolOnTrigger;
var() edfindable PatrolingPoint FirstPatrolPoint;

simulated function PostNetBeginPlay(){}

function AddDefaultInventory();

function GiveDefaultWeapon()
{
	CreateInventory(string(WeaponType));
	if ( inventory != None )
		inventory.OwnerEvent('LoadOut');
	Controller.ClientSwitchToBestWeapon();
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
	return Weapon.GetFireStart(x,y,z);
}

function CreateInventory(string InventoryClassName)
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;

	InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		Inv = Spawn(InventoryClass);
		if( Inv != None )
		{
			Inv.GiveTo(self);
			if ( Inv != None )
				Inv.PickupFunction(self);
		}
	}
}

event PostBeginPlay()
{
	Super(xpawn).PostBeginPlay();

	AddDefaultInventory();
	Health = HealthMod;
	if ( (ControllerClass != None) && (Controller == None) )
	{
		Controller = spawn(ControllerClass);
		if ( Controller != None )
			Controller.Possess(self);
	}
}

function bool PreferMelee()
{
	if (Weapon != none)
		return Weapon.bMeleeWeapon;
}

function bool RecommendSplashDamage()
{
	if( LAW(Weapon) != none || Flamethrower(Weapon) != none )
		return true;
	return false;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if( Controller!=None )
		Controller.bIsPlayer = False;
	Super.Died(Killer,damageType,HitLocation);
}

defaultproperties
{
     AttitudeToPlayer=ATTITUDE_Friendly
     ReactionTime=1.000000
     HealthMod=125
     WeaponType=Class'KFMod.Single'
     MaxMultiJump=1
     GroundSpeed=270.000000
     WaterSpeed=250.000000
     AirSpeed=250.000000
     JumpZ=300.000000
     MaxFallSpeed=6000.000000
     HealthMax=125.000000
     Health=125
     ControllerClass=Class'KFMod.KFFriendlyAI'
}
