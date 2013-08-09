/*
	--------------------------------------------------------------
	KFBuyMenuInvListBox_Story
	--------------------------------------------------------------

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KFBuyMenuInvList_Story extends KFBuyMenuInvList;

/* Had to C&P this whole function just to exclude a single type of weapon from the buy menu's sell list

  @todo -  Implement a less retarded solution.  Like a bool bTraderSellable in KFWeapon , or something */

function UpdateMyBuyables()
{
	local class<KFVeterancyTypes> PlayerVeterancy;
	local KFPlayerReplicationInfo KFPRI;
	local GUIBuyable MyBuyable, KnifeBuyable, FragBuyable, SecondaryAmmoBuyable;
	local Inventory CurInv;
	local KFLevelRules KFLR;
	local bool bHasDual, bHasDualCannon, bHasDual44, bhasDualM23, bHasDualFlareGuns, bHasDualGoldenCannon;
	local float CurAmmo, MaxAmmo;
	local class<KFWeaponPickup> MyPickup, MyPrimaryPickup;
	local int DualDivider, NumInvItems;

	//Let's start with our current inventory
	if ( PlayerOwner().Pawn.Inventory == none )
    {
        log("Inventory is none!");
        return;
    }

	DualDivider = 1;
	AutoFillCost = 0.00000;

	//Clear the MyBuyables array
	MyBuyables.Remove(0, MyBuyables.Length);

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

	//Check if we have dualies or dual hand cannons
	for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
		if ( KFWeapon(CurInv) != none )
        {
			if ( KFWeapon(CurInv).default.PickupClass == class'DualDeaglePickup' )
	    	{
				bHasDualCannon = true;
			}

			if( KFWeapon(CurInv).default.PickupClass == class'GoldenDualDeaglePickup' )
			{
			    bHasDualGoldenCannon = true;
			}

			if ( KFWeapon(CurInv).default.PickupClass == class'DualiesPickup' )
	    	{
				bHasDual = true;
			}

			if ( KFWeapon(CurInv).default.PickupClass == class'Dual44MagnumPickup' )
	    	{
				bHasDual44 = true;
			}

			if ( KFWeapon(CurInv).default.PickupClass == class'DualMK23Pickup' )
	    	{
				bhasDualM23 = true;
			}

			if ( KFWeapon(CurInv).default.PickupClass == class'DualFlareRevolverPickup' )
	    	{
				bHasDualFlareGuns = true;
			}
		}
	}

	// Grab the items for sale, we need the categories
    foreach PlayerOwner().DynamicActors(class'KFLevelRules', KFLR)
        break;

	// Fill the Buyables
	NumInvItems = 0;
	for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
		if ( CurInv.IsA('Ammunition') )
        {
            continue;
        }

        // No need for Syringe and Welder
        if ( CurInv.IsA('Welder') || CurInv.IsA('Syringe') || CurInv.IsA('Dummy_JoggingWeapon') )
        {
			continue;
		}

		if ( CurInv.IsA('DualDeagle') || CurInv.IsA('Dual44Magnum') || CurInv.IsA('DualMK23Pistol')
            || CurInv.IsA('DualFlareRevolver') )
		{
			DualDivider = 2;
		}
		else
		{
			DualDivider = 1;
		}

		MyPickup = class<KFWeaponPickup>(KFWeapon(CurInv).default.PickupClass);

        // if we already own dualies, we do not need the single 9mm in the list
        if ( (bHasDual && MyPickup == class'SinglePickup') ||
			 (bHasDualCannon && MyPickup == class'DeaglePickup') ||
			 (bHasDualGoldenCannon && MyPickup == class'GoldenDeaglePickup') ||
			 (bHasDual44 && MyPickup == class'Magnum44Pickup') ||
			 (bhasDualM23 && MyPickup == class'MK23Pickup') ||
             (bHasDualFlareGuns && MyPickup == class'FlareRevolverPickup'))
        {
            continue;
        }

        if ( CurInv.IsA('KFWeapon') )
        {
			KFWeapon(CurInv).GetAmmoCount(MaxAmmo, CurAmmo);

			MyBuyable = new class'GUIBuyable';

			// This is a rather ugly way to support Secondary Ammo because all of the needed Data is jumbled between the Weapon and it's 2 Pickup Classes
			if ( KFWeapon(CurInv).bHasSecondaryAmmo )
			{
				MyPrimaryPickup = MyPickup.default.PrimaryWeaponPickup;

				MyBuyable.ItemName 			= MyPickup.default.ItemShortName;
				MyBuyable.ItemDescription 	= KFWeapon(CurInv).default.Description;
				MyBuyable.ItemCategorie		= KFLR.EquipmentCategories[MyPickup.default.EquipmentCategoryID].EquipmentCategoryName;
				MyBuyable.ItemImage			= KFWeapon(CurInv).default.TraderInfoTexture;
				MyBuyable.ItemWeaponClass	= KFWeapon(CurInv).class;
				MyBuyable.ItemAmmoClass		= KFWeapon(CurInv).default.FireModeClass[0].default.AmmoClass;
				MyBuyable.ItemPickupClass	= MyPrimaryPickup;
				MyBuyable.ItemCost			= (float(MyPickup.default.Cost) * PlayerVeterancy.static.GetCostScaling(KFPRI, MyPickup)) / DualDivider;
				MyBuyable.ItemAmmoCost		= MyPrimaryPickup.default.AmmoCost * PlayerVeterancy.static.GetAmmoCostScaling(KFPRI, MyPrimaryPickup) * PlayerVeterancy.static.GetMagCapacityMod(KFPRI, KFWeapon(CurInv));
    			MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPrimaryPickup.default.AmmoCost)) / float(KFWeapon(CurInv).default.MagCapacity))) * PlayerVeterancy.static.GetAmmoCostScaling(KFPRI, MyPrimaryPickup);
				MyBuyable.ItemWeight		= KFWeapon(CurInv).Weight;
				MyBuyable.ItemPower			= MyPickup.default.PowerValue;
				MyBuyable.ItemRange			= MyPickup.default.RangeValue;
				MyBuyable.ItemSpeed			= MyPickup.default.SpeedValue;
				MyBuyable.ItemAmmoCurrent	= CurAmmo;
				MyBuyable.ItemAmmoMax		= MaxAmmo;
				MyBuyable.bMelee			= (KFMeleeGun(CurInv) != none);
				MyBuyable.bSaleList			= false;
				MyBuyable.ItemPerkIndex		= MyPickup.default.CorrespondingPerkIndex;

				if ( KFWeapon(CurInv) != none && KFWeapon(CurInv).SellValue != -1 )
				{
					MyBuyable.ItemSellValue = KFWeapon(CurInv).SellValue;
				}
				else
				{
					MyBuyable.ItemSellValue = MyBuyable.ItemCost * 0.75;
				}

				if ( !MyBuyable.bMelee && int(MaxAmmo) > int(CurAmmo))
				{
					AutoFillCost += MyBuyable.ItemFillAmmoCost;
				}

				MyBuyable.bSellable	= !KFWeapon(CurInv).default.bKFNeverThrow;

				MyBuyables.Insert(0, 1);
				MyBuyables[0] = MyBuyable;

				NumInvItems++;

				KFWeapon(CurInv).GetSecondaryAmmoCount(MaxAmmo, CurAmmo);

				MyBuyable = new class'GUIBuyable';

				MyBuyable.ItemName 			= MyPickup.default.SecondaryAmmoShortName;
				MyBuyable.ItemDescription 	= KFWeapon(CurInv).default.Description;
				MyBuyable.ItemCategorie		= KFLR.EquipmentCategories[MyPickup.default.EquipmentCategoryID].EquipmentCategoryName;
				MyBuyable.ItemImage			= KFWeapon(CurInv).default.TraderInfoTexture;
				MyBuyable.ItemWeaponClass	= KFWeapon(CurInv).class;
				MyBuyable.ItemAmmoClass		= KFWeapon(CurInv).default.FireModeClass[1].default.AmmoClass;
				MyBuyable.ItemPickupClass	= MyPickup;
				MyBuyable.ItemCost			= (float(MyPickup.default.Cost) * PlayerVeterancy.static.GetCostScaling(KFPRI, MyPickup)) / DualDivider;
				MyBuyable.ItemAmmoCost		= MyPickup.default.AmmoCost * PlayerVeterancy.static.GetAmmoCostScaling(KFPRI, MyPickup) * PlayerVeterancy.static.GetMagCapacityMod(KFPRI, KFWeapon(CurInv));
				MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPickup.default.AmmoCost)) /* Secondary Mags always have a Mag Capacity of 1? / float(KFWeapon(CurInv).default.MagCapacity)*/)) * PlayerVeterancy.static.GetAmmoCostScaling(KFPRI, MyPickup);
				MyBuyable.ItemWeight		= KFWeapon(CurInv).Weight;
				MyBuyable.ItemPower			= MyPickup.default.PowerValue;
				MyBuyable.ItemRange			= MyPickup.default.RangeValue;
				MyBuyable.ItemSpeed			= MyPickup.default.SpeedValue;
				MyBuyable.ItemAmmoCurrent	= CurAmmo;
				MyBuyable.ItemAmmoMax		= MaxAmmo;
				MyBuyable.bMelee			= (KFMeleeGun(CurInv) != none);
				MyBuyable.bSaleList			= false;
				MyBuyable.ItemPerkIndex		= MyPickup.default.CorrespondingPerkIndex;

				if ( KFWeapon(CurInv) != none && KFWeapon(CurInv).SellValue != -1 )
				{
					MyBuyable.ItemSellValue = KFWeapon(CurInv).SellValue;
				}
				else
				{
					MyBuyable.ItemSellValue = MyBuyable.ItemCost * 0.75;
				}

				if ( !MyBuyable.bMelee && int(MaxAmmo) > int(CurAmmo))
				{
					AutoFillCost += MyBuyable.ItemFillAmmoCost;
				}
			}
			else
			{
				MyBuyable.ItemName 			= MyPickup.default.ItemShortName;
				MyBuyable.ItemDescription 	= KFWeapon(CurInv).default.Description;
				MyBuyable.ItemCategorie		= KFLR.EquipmentCategories[MyPickup.default.EquipmentCategoryID].EquipmentCategoryName;
				MyBuyable.ItemImage			= KFWeapon(CurInv).default.TraderInfoTexture;
				MyBuyable.ItemWeaponClass	= KFWeapon(CurInv).class;
				MyBuyable.ItemAmmoClass		= KFWeapon(CurInv).default.FireModeClass[0].default.AmmoClass;
				MyBuyable.ItemPickupClass	= MyPickup;
				MyBuyable.ItemCost			= (float(MyPickup.default.Cost) * PlayerVeterancy.static.GetCostScaling(KFPRI, MyPickup)) / DualDivider;
				MyBuyable.ItemAmmoCost		= MyPickup.default.AmmoCost * PlayerVeterancy.static.GetAmmoCostScaling(KFPRI, MyPickup) * PlayerVeterancy.static.GetMagCapacityMod(KFPRI, KFWeapon(CurInv));
                if( MyPickup == class'HuskGunPickup' )
				{
    				MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPickup.default.AmmoCost)) / float(MyPickup.default.BuyClipSize))) * PlayerVeterancy.static.GetAmmoCostScaling(KFPRI, MyPickup);
			    }
			    else
			    {
    				MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPickup.default.AmmoCost)) / float(KFWeapon(CurInv).default.MagCapacity))) * PlayerVeterancy.static.GetAmmoCostScaling(KFPRI, MyPickup);
			    }
				MyBuyable.ItemWeight		= KFWeapon(CurInv).Weight;
				MyBuyable.ItemPower			= MyPickup.default.PowerValue;
				MyBuyable.ItemRange			= MyPickup.default.RangeValue;
				MyBuyable.ItemSpeed			= MyPickup.default.SpeedValue;
				MyBuyable.ItemAmmoCurrent	= CurAmmo;
				MyBuyable.ItemAmmoMax		= MaxAmmo;
				MyBuyable.bMelee			= (KFMeleeGun(CurInv) != none);
				MyBuyable.bSaleList			= false;
				MyBuyable.ItemPerkIndex		= MyPickup.default.CorrespondingPerkIndex;

				if ( KFWeapon(CurInv) != none && KFWeapon(CurInv).SellValue != -1 )
				{
					MyBuyable.ItemSellValue = KFWeapon(CurInv).SellValue;
				}
				else
				{
					MyBuyable.ItemSellValue = MyBuyable.ItemCost * 0.75;
				}

				if ( !MyBuyable.bMelee && int(MaxAmmo) > int(CurAmmo))
				{
					AutoFillCost += MyBuyable.ItemFillAmmoCost;
				}
			}

			if ( KFWeapon(CurInv).bHasSecondaryAmmo )
			{
				MyBuyable.bSellable	= false;
				SecondaryAmmoBuyable = MyBuyable;
			}
			else if ( CurInv.IsA('Knife') )
			{
				MyBuyable.bSellable	= false;
				KnifeBuyable = MyBuyable;
			}
			else if ( CurInv.IsA('Frag') )
			{
				MyBuyable.bSellable	= false;
				FragBuyable = MyBuyable;
			}
			else if ( NumInvItems < 7 )
			{
				MyBuyable.bSellable	= !KFWeapon(CurInv).default.bKFNeverThrow;

				MyBuyables.Insert(0, 1);
				MyBuyables[0] = MyBuyable;

				NumInvItems++;
			}
		}
	}

	MyBuyable = new class'GUIBuyable';

	MyBuyable.ItemName 			= class'BuyableVest'.default.ItemName;
	MyBuyable.ItemDescription 	= class'BuyableVest'.default.ItemDescription;
	MyBuyable.ItemCategorie		= "";
	MyBuyable.ItemImage			= class'BuyableVest'.default.ItemImage;
	MyBuyable.ItemAmmoCurrent	= PlayerOwner().Pawn.ShieldStrength;
	MyBuyable.ItemAmmoMax		= 100;
	MyBuyable.ItemCost			= int(class'BuyableVest'.default.ItemCost * PlayerVeterancy.static.GetCostScaling(KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo), class'Vest'));
	MyBuyable.ItemAmmoCost		= MyBuyable.ItemCost / 100;
	MyBuyable.ItemFillAmmoCost	= int((100.0 - MyBuyable.ItemAmmoCurrent) * MyBuyable.ItemAmmoCost);
	MyBuyable.bIsVest			= true;
	MyBuyable.bMelee			= false;
	MyBuyable.bSaleList			= false;
	MyBuyable.bSellable			= false;
	MyBuyable.ItemPerkIndex		= class'BuyableVest'.default.CorrespondingPerkIndex;

	MyBuyables[7] = none;

	if ( SecondaryAmmoBuyable != none )
	{
		MyBuyables[8] = SecondaryAmmoBuyable;
	}
	else
	{
		MyBuyables[8] = KnifeBuyable;
	}

	MyBuyables[9] = FragBuyable;
	MyBuyables[10] = MyBuyable;

	//Now Update the list
	UpdateList();
}

defaultproperties
{
}
