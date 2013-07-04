/*
	--------------------------------------------------------------
	KFBuyMenuSaleList_Story
	--------------------------------------------------------------

	TraderShop GUI's ItemList Widget
	extended to add support for story elements.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KFBuyMenuSaleList_Story extends KFBuyMenuSaleList;


function KFShopVolume_Story		GetCurrentShop()
{
	local KFPlayerController_Story	StoryPC;

	StoryPC = KFPlayerController_Story(PlayerOwner());
	if(StoryPC != none)
	{
		return StoryPC.CurrentShopVolume ;
	}

	return none;
}


/* overriden so that it fills the buyables list from the Shop Volume the player is currently standing in
 rather than the level rules actor */

function UpdateForSaleBuyables()
{
	local class<KFVeterancyTypes> PlayerVeterancy;
	local KFPlayerReplicationInfo KFPRI;
	local GUIBuyable ForSaleBuyable;
	local class<KFWeaponPickup> ForSalePickup;
	local int i, j, DualDivider, ForSaleArrayIndex;
	local bool bZeroWeight;
	local KFShopVolume_Story	CurrentShop;
	local KFLevelRules KFLR;

	DualDivider = 1;

	CurrentShop = GetCurrentShop();
	if(CurrentShop == none )
	{
	//	log("Warning - Trader UI is open but player"@PlayerOwner()@"is not inside a story shop volume!");
		super.UpdateForSaleBuyables();
		return;
	}

    foreach PlayerOwner().DynamicActors(class'KFLevelRules', KFLR)
    {
        Break;
	}

	// Grab Players Veterancy for quick reference
	if ( KFPlayerController(PlayerOwner()) != none && KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		PlayerVeterancy = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkill;
	}
	else
	{
		PlayerVeterancy = class'KFVeterancyTypes';
	}

	KFPRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);

	//Grab the perk's weapons first
	for ( j = 0; j < CurrentShop.SaleItems.length ; j++ )
	{
		if ( CurrentShop.SaleItems[j] != none )
		{
			//Let's see if this is a vest, first aid kit, ammo or stuff we already have
			if ( class<Vest>(CurrentShop.SaleItems[j]) != none || class<FirstAidKit>(CurrentShop.SaleItems[j]) != none ||
				 class<KFWeapon>(CurrentShop.SaleItems[j].default.InventoryType) == none || CurrentShop.SaleItems[j].IsA('Ammunition') ||
				 class<KFWeapon>(CurrentShop.SaleItems[j].default.InventoryType).default.bKFNeverThrow ||
				 IsInInventory(CurrentShop.SaleItems[j]) ||
				 class<KFWeaponPickup>(CurrentShop.SaleItems[j]).default.CorrespondingPerkIndex != PlayerVeterancy.default.PerkIndex)
			{
				continue;
			}

			if ( class<Deagle>(CurrentShop.SaleItems[j].default.InventoryType) != none )
			{
				if ( IsInInventory(class'DualDeaglePickup') )
				{
					continue;
				}
			}

			if ( class<GoldenDeagle>(CurrentShop.SaleItems[j].default.InventoryType) != none )
			{
				if ( IsInInventory(class'GoldenDualDeaglePickup') )
				{
					continue;
				}
			}

			if ( class<Magnum44Pistol>(CurrentShop.SaleItems[j].default.InventoryType) != none )
			{
				if ( IsInInventory(class'Dual44MagnumPickup') )
				{
					continue;
				}
			}

			if ( class<DualDeagle>(CurrentShop.SaleItems[j].default.InventoryType) != none ||
				 class<Dual44Magnum>(CurrentShop.SaleItems[j].default.InventoryType) != none ||
                 class<GoldenDualDeagle>(CurrentShop.SaleItems[j].default.InventoryType) != none)
			{
				if ( IsInInventory(class'DeaglePickup') )
				{
					DualDivider = 2;
					bZeroWeight = true;
				}
				else if ( IsInInventory(class'GoldenDeaglePickup') )
				{
					DualDivider = 2;
					bZeroWeight = true;
				}
				else if ( IsInInventory(class'Magnum44Pickup') )
				{
					DualDivider = 2;
					bZeroWeight = true;
				}
			}
			else
			{
				DualDivider = 1;
				bZeroWeight = false;
			}

			if ( ForSaleArrayIndex >= ForSaleBuyables.Length )
			{
				ForSaleBuyable = new class'GUIBuyable';
				ForSaleBuyables[ForSaleBuyables.Length] = ForSaleBuyable;
			}
			else
			{
				ForSaleBuyable = ForSaleBuyables[ForSaleArrayIndex];
			}

			ForSaleArrayIndex++;

			ForSalePickup =  class<KFWeaponPickup>(CurrentShop.SaleItems[j]);

   			ForSaleBuyable.ItemName 		= ForSalePickup.default.ItemName;
			ForSaleBuyable.ItemDescription 	= ForSalePickup.default.Description;
			ForSaleBuyable.ItemCategorie	= KFLR.EquipmentCategories[i].EquipmentCategoryName;
			ForSaleBuyable.ItemImage		= class<KFWeapon>(ForSalePickup.default.InventoryType).default.TraderInfoTexture;
			ForSaleBuyable.ItemWeaponClass	= class<KFWeapon>(ForSalePickup.default.InventoryType);
			ForSaleBuyable.ItemAmmoClass	= class<KFWeapon>(ForSalePickup.default.InventoryType).default.FireModeClass[0].default.AmmoClass;
			ForSaleBuyable.ItemPickupClass	= ForSalePickup;
			ForSaleBuyable.ItemCost			= int((float(ForSalePickup.default.Cost)
										  	  * PlayerVeterancy.static.GetCostScaling(KFPRI, ForSalePickup)) / DualDivider);
			ForSaleBuyable.ItemAmmoCost		= 0;
			ForSaleBuyable.ItemFillAmmoCost	= 0;

			if ( bZeroWeight)
			{
				ForSaleBuyable.ItemWeight 	= 0.f;
			}
			else
			{
				ForSaleBuyable.ItemWeight	= ForSalePickup.default.Weight;
			}

			ForSaleBuyable.ItemPower		= ForSalePickup.default.PowerValue;
			ForSaleBuyable.ItemRange		= ForSalePickup.default.RangeValue;
			ForSaleBuyable.ItemSpeed		= ForSalePickup.default.SpeedValue;
			ForSaleBuyable.ItemAmmoCurrent	= 0;
			ForSaleBuyable.ItemAmmoMax		= 0;
			ForSaleBuyable.ItemPerkIndex	= ForSalePickup.default.CorrespondingPerkIndex;

			// Make sure we mark the list as a sale list
			ForSaleBuyable.bSaleList = true;

			bZeroWeight = false;
		}
	}

	// now the rest
	for ( j = CurrentShop.SaleItems.length - 1; j >= 0; j-- )
	{
		if (CurrentShop.SaleItems[j] != none )
		{
			//Let's see if this is a vest, first aid kit, ammo or stuff we already have
			if ( class<Vest>(CurrentShop.SaleItems[j]) != none || class<FirstAidKit>(CurrentShop.SaleItems[j]) != none ||
				 class<KFWeapon>(CurrentShop.SaleItems[j].default.InventoryType) == none || CurrentShop.SaleItems[j].IsA('Ammunition') ||
				 class<KFWeapon>(CurrentShop.SaleItems[j].default.InventoryType).default.bKFNeverThrow ||
				 IsInInventory(CurrentShop.SaleItems[j]) ||
				 class<KFWeaponPickup>(CurrentShop.SaleItems[j]).default.CorrespondingPerkIndex == PlayerVeterancy.default.PerkIndex )
			{
				continue;
			}

			if ( class<Deagle>(CurrentShop.SaleItems[j].default.InventoryType) != none )
			{
				if ( IsInInventory(class'DualDeaglePickup') )
				{
					continue;
				}
			}

			if ( class<GoldenDeagle>(CurrentShop.SaleItems[j].default.InventoryType) != none )
			{
				if ( IsInInventory(class'GoldenDualDeaglePickup') )
				{
					continue;
				}
			}

			if ( class<Magnum44Pistol>(CurrentShop.SaleItems[j].default.InventoryType) != none )
			{
				if ( IsInInventory(class'Dual44MagnumPickup') )
				{
					continue;
				}
			}

			if ( class<DualDeagle>(CurrentShop.SaleItems[j].default.InventoryType) != none ||
				 class<Dual44Magnum>(CurrentShop.SaleItems[j].default.InventoryType) != none ||
                 class<GoldenDualDeagle>(CurrentShop.SaleItems[j].default.InventoryType) != none )
			{
				if ( IsInInventory(class'DeaglePickup') )
				{
					DualDivider = 2;
					bZeroWeight = true;
				}
				else if ( IsInInventory(class'GoldenDeaglePickup') )
				{
					DualDivider = 2;
					bZeroWeight = true;
				}
				else if ( IsInInventory(class'Magnum44Pickup') )
				{
					DualDivider = 2;
					bZeroWeight = true;
				}
			}
			else
			{
				DualDivider = 1;
				bZeroWeight = false;
			}

			if ( ForSaleArrayIndex >= ForSaleBuyables.Length )
			{
				ForSaleBuyable = new class'GUIBuyable';
				ForSaleBuyables[ForSaleBuyables.Length] = ForSaleBuyable;
			}
			else
			{
				ForSaleBuyable = ForSaleBuyables[ForSaleArrayIndex];
			}

			ForSaleArrayIndex++;

			ForSalePickup =  class<KFWeaponPickup>(CurrentShop.SaleItems[j]);

   			ForSaleBuyable.ItemName 		= ForSalePickup.default.ItemName;
			ForSaleBuyable.ItemDescription 	= ForSalePickup.default.Description;
			ForSaleBuyable.ItemCategorie	= KFLR.EquipmentCategories[i].EquipmentCategoryName;

			if ( class<KFWeapon>(ForSalePickup.default.InventoryType) != none )
			{
				ForSaleBuyable.ItemImage		= class<KFWeapon>(ForSalePickup.default.InventoryType).default.TraderInfoTexture;
				ForSaleBuyable.ItemWeaponClass	= class<KFWeapon>(ForSalePickup.default.InventoryType);
				ForSaleBuyable.ItemAmmoClass	= class<KFWeapon>(ForSalePickup.default.InventoryType).default.FireModeClass[0].default.AmmoClass;
			}

			ForSaleBuyable.ItemPickupClass	= ForSalePickup;
			ForSaleBuyable.ItemCost			= int((float(ForSalePickup.default.Cost)
										  	  * PlayerVeterancy.static.GetCostScaling(KFPRI, ForSalePickup)) / DualDivider);
			ForSaleBuyable.ItemAmmoCost		= 0;
			ForSaleBuyable.ItemFillAmmoCost	= 0;

			if ( bZeroWeight)
			{
				ForSaleBuyable.ItemWeight 	= 0.f;
			}
			else
			{
				ForSaleBuyable.ItemWeight	= ForSalePickup.default.Weight;
			}

			ForSaleBuyable.ItemPower		= ForSalePickup.default.PowerValue;
			ForSaleBuyable.ItemRange		= ForSalePickup.default.RangeValue;
			ForSaleBuyable.ItemSpeed		= ForSalePickup.default.SpeedValue;
			ForSaleBuyable.ItemAmmoCurrent	= 0;
			ForSaleBuyable.ItemAmmoMax		= 0;
			ForSaleBuyable.ItemPerkIndex	= ForSalePickup.default.CorrespondingPerkIndex;

			// Make sure we mark the list as a sale list
			ForSaleBuyable.bSaleList = true;

			bZeroWeight = false;
		}
	}

	if ( ForSaleArrayIndex < ForSaleBuyables.Length )
	{
		ForSaleBuyables.Remove(ForSaleArrayIndex, ForSaleBuyables.Length);
	}

	//Now Update the list
	UpdateList();
}

defaultproperties
{
}
