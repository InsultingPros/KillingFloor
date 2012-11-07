//=============================================================================
// GUIBuyable
// Stores all the information of a certain item in the trader menu
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================

class GUIBuyable extends Object;

var 	localized string 		ItemName;            			//Sale name of object
var		localized string		ItemDescription;				//Short item Description
var		localized string		ItemCategorie;

var 	texture					ItemImage; 			            //Image to show in Info

var		class<KFWeapon> 		ItemWeaponClass;				//Weapon class used for buying/selling
var		class<Ammunition> 		ItemAmmoClass;					//Ammo class used for buying/selling
var		class<KFWeaponPickup> 	ItemPickupClass;				//Pickup class

var 	float 					ItemCost;		                //Cost to buy
var		float					ItemAmmoCost;					//Single clip cost
var		float					ItemFillAmmoCost;				//Fill up cost

var 	float 					ItemWeight;                		//Heaviness
var		float					ItemPower;              		//Progressbar power
var		float					ItemRange;						//Progressbar range
var 	float					ItemSpeed;						//Progressbar speed

var		float					ItemAmmoCurrent;				//Current ammo count
var		float					ItemAmmoMax;					//Max ammo

var 	bool					bSaleList;						//Inventory or sale?
var		bool					bSellable;						//Can't sell Default weapons
var		bool					bMelee;							//Melee weapons
var		bool					bIsVest;						//Vest?
var		bool					bIsFirstAidKit;					//First Aid?
var		byte					ItemPerkIndex;					//Corresponding perk

var		int						ItemSellValue;					//Value at which this item can be sold

defaultproperties
{
     ItemName="Buyable Item Name"
     ItemImage=Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_9mm'
     ItemWeaponClass=Class'KFMod.Single'
     ItemAmmoClass=Class'KFMod.SingleAmmo'
}
