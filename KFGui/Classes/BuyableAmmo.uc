class BuyableAmmo extends GUIBuyable;

var bool bHasAmmo;
var int maxAmmoCount;
var class<Ammunition> ammoType;

// Function to initialise values when player is buying a new gun,
// but has not completed purchase, therefore the weapon is not in the players
// inventory (and therefore InitOwnedQuantity is useless)
/*
function InitNewPurchase( Pawn P )
{
	bHasAmmo = ShowMe(p,SALE_Ammo,None);
}

function int BuyMoreClips()
{
	Return 0;
}
function int NumClips()
{
	Return 0;
}

function string GetBuyCaption(eSaleCat index)
{
	return "Clip";
}

//Consider ourselves bought
function BuyMe( KFPawn P )
{
	P.ServerBuyAmmo(ammoType,True);
}

//Consider ourselves sold
function SellMe( KFPawn P )
{
	P.ServerSellAmmo(ammoType);
}

//Fill up the weapon
function FillMe( KFPawn P )
{
	P.ServerBuyAmmo(ammoType,False);
}


function bool ShowMe(Pawn p, eSaleCat index, GuiBuyMenu ParentMenu )
{
	local Inventory I;

	if(index != SALE_Ammo)
		return false;

	For( I=P.Inventory; I!=None; I=I.Inventory )
	{
		if( I.Class==relatedInventory )
			Return True;
		else if( Weapon(I)!=None && (Weapon(I).AmmoClass[0]==ammoType || Weapon(I).AmmoClass[1]==ammoType) )
			Return True;
	}
	return false;
}
*/

defaultproperties
{
}
