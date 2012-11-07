class BuyableWeapon extends GUIBuyable;

var int PowerValue;
var int SpeedValue;
var int RangeValue;

/*
var bool bHideSale,bInitalInit,bHasThisGun;

function bool CanBuyMe(PlayerController p)
{
	return Super.CanBuyMe(p) && !HasMe(p.Pawn);
}
function bool HasMe(Pawn p)
{
	if( bInitalInit )
		Return bHasThisGun;
	bHasThisGun = Super.HasMe(p);
	bInitalInit = True;
	Return bHasThisGun;
}

function bool ShowMe(Pawn p, eSaleCat index, GUIBuyMenu ParentMenu)
{
	local bool hasThis,melee;
	local class<Weapon> stuf;

	//cost *= 10;

        hasThis = HasMe(p);
	stuf = class<Weapon>(relatedInventory);
	melee = stuf.Default.bMeleeWeapon;

	switch(index)
	{
		case SALE_Personal:
			 return hasThis && !bHideSale;
		case SALE_Melee:
			 return melee && !hasThis;
		case SALE_Power:
			 return !melee && IsPowerWeapon() && !hasThis;
		case SALE_Speed:
			 return !melee && IsSpeedWeapon() && !hasThis;
		case SALE_Range:
			 return !melee && IsRangeWeapon() && !hasThis;
		default:
			 return false;
	}
	return false;
}

function bool IsPowerWeapon()
{
	return (PowerValue >= 65 || IsPrimaryAtt(PowerValue));
}

function bool IsSpeedWeapon()
{
	return (SpeedValue >= 65 || IsPrimaryAtt(SpeedValue));
}

function bool IsRangeWeapon()
{
	return (RangeValue >= 65 || IsPrimaryAtt(RangeValue));
}

function bool IsPrimaryAtt(int att)
{
	return (att >= RangeValue && att >=PowerValue && att >=SpeedValue);
}

//Consider ourselves bought
function BuyMe( KFPawn P )
{
	bHasThisGun = True;
	P.ServerBuyWeapon(Class<Weapon>(relatedInventory));
}

//Consider ourselves sold
function SellMe( KFPawn P )
{
	bHasThisGun = False;
	P.ServerSellWeapon(Class<Weapon>(relatedInventory));
}

*/

defaultproperties
{
}
