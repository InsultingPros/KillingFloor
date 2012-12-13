//=============================================================================
// The trader menu's list with player's current inventory
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Dayle "Xienen" Flowers
//=============================================================================
class KFBuyMenuInvList extends GUIVertList;

// Settings
var	float	ItemBGWidthScale;
var	float	AmmoBGWidthScale;
var	float	ClipButtonWidthScale;
var	float	AmmoBGHeightScale;
var	float	ButtonBGHeightScale;
var	float	EquipmentBGWidthScale;
var	float	EquipmentBGHeightScale;
var	float	ItemBGYOffset;
var	float	AmmoSpacing;
var	float	ItemNameSpacing;
var	float	ButtonSpacing;
var	float	EquipmentBGXOffset;
var	float	EquipmentBGYOffset;

// Strings
var	localized string	EquipmentString;
var	localized string	BuyString;
var	localized string	PurchasedString;
var	localized string	RepairString;

// Display
var	texture	ItemBackgroundLeft;
var	texture	ItemBackgroundRight;
var	texture	SelectedItemBackgroundLeft;
var	texture	SelectedItemBackgroundRight;
var	texture	DisabledItemBackgroundLeft;
var	texture	DisabledItemBackgroundRight;
var	texture	AmmoBackground;
var	texture	ButtonBackground;
var	texture	HoverButtonBackground;
var	texture	DisabledButtonBackground;

var array<string>	NameStrings;
var	array<string>	AmmoStrings;
var	array<string>	ClipPriceStrings;
var	array<string>	FillPriceStrings;
var	array<texture>	PerkTextures;

// state
var	array<GUIBuyable>	MyBuyables;
var	int					MouseOverIndex;
var	int					MouseOverXIndex;

var bool	bNeedsUpdate;
var int		UpdateCounter;
var float	AutoFillCost;

delegate OnBuyClipClick(GUIBuyable Buyable);
delegate OnFillAmmoClick(GUIBuyable Buyable);
delegate OnBuyVestClick();

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	OnDrawItem = DrawInvItem;
	UpdateMyBuyables();
}

event Opened(GUIComponent Sender)
{
	super.Opened(Sender);
	UpdateMyBuyables();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	NameStrings.Remove(0, NameStrings.Length);
	AmmoStrings.Remove(0, AmmoStrings.Length);
	ClipPriceStrings.Remove(0, ClipPriceStrings.Length);
	FillPriceStrings.Remove(0, FillPriceStrings.Length);
	PerkTextures.Remove(0, PerkTextures.Length);
	MyBuyables.Remove(0, MyBuyables.Length);

	super.Closed(Sender, bCancelled);
}

function UpdateMyBuyables()
{
	local class<KFVeterancyTypes> PlayerVeterancy;
	local KFPlayerReplicationInfo KFPRI;
	local GUIBuyable MyBuyable, KnifeBuyable, FragBuyable, SecondaryAmmoBuyable;
	local Inventory CurInv;
	local KFLevelRules KFLR;
	local bool bHasDual, bHasDualCannon, bHasDual44, bhasDualM23, bHasDualFlareGuns;
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
        if ( CurInv.IsA('Welder') || CurInv.IsA('Syringe') )
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

function UpdateList()
{
	local int i;

	if ( MyBuyables.Length < 1 )
	{
		bNeedsUpdate = true;
		return;
	}

	// Clear the arrays
	NameStrings.Remove(0, NameStrings.Length);
	AmmoStrings.Remove(0, AmmoStrings.Length);
	ClipPriceStrings.Remove(0, ClipPriceStrings.Length);
	FillPriceStrings.Remove(0, FillPriceStrings.Length);
	PerkTextures.Remove(0, PerkTextures.Length);

	// Update the ItemCount and select the first item
	ItemCount = MyBuyables.Length;

	// Update the players inventory list
	for ( i = 0; i < ItemCount; i++ )
	{
		if ( MyBuyables[i] == none )
			continue;

		NameStrings[i] = MyBuyables[i].ItemName; //@ "(" $	MyBuyables[i].ItemCategorie $ ")";

		if ( !MyBuyables[i].bIsVest )
		{
			AmmoStrings[i] = int(MyBuyables[i].ItemAmmoCurrent)$"/"$int(MyBuyables[i].ItemAmmoMax);

			if ( MyBuyables[i].ItemAmmoCurrent < MyBuyables[i].ItemAmmoMax )
			{
				if ( MyBuyables[i].ItemAmmoCost > MyBuyables[i].ItemFillAmmoCost )
				{
					ClipPriceStrings[i] = "£" @ int(MyBuyables[i].ItemFillAmmoCost);
				}
				else
				{
					ClipPriceStrings[i] = "£" @ int(MyBuyables[i].ItemAmmoCost);
				}
			}
			else
			{
				ClipPriceStrings[i] = "£ 0";
			}

			FillPriceStrings[i] = "£" @ int(MyBuyables[i].ItemFillAmmoCost);
		}
		else
		{
			AmmoStrings[i] = int((MyBuyables[i].ItemAmmoCurrent / MyBuyables[i].ItemAmmoMax) * 100.0)$"%";

			if ( MyBuyables[i].ItemAmmoCurrent == 0 )
			{
				FillPriceStrings[i] = BuyString @ ": £" @ int(MyBuyables[i].ItemFillAmmoCost);
			}
			else if ( MyBuyables[i].ItemAmmoCurrent == 100 )
			{
				FillPriceStrings[i] = PurchasedString;
			}
			else
			{
				FillPriceStrings[i] = RepairString @ ": £" @ int(MyBuyables[i].ItemFillAmmoCost);
			}
		}


	    if(MyBuyables[i].ItemPerkIndex == 7 )
	    {
            PerkTextures[i] = class'KFBuyMenuSaleList'.default.NoPerkIcon;
        }
        else
        {
            PerkTextures[i] = class'KFGameType'.default.LoadedSkills[MyBuyables[i].ItemPerkIndex].default.OnHUDIcon;
        }
	}

	if ( bNotify )
 	{
		CheckLinkedObjects(Self);
	}

	if ( MyScrollBar != none )
	{
		MyScrollBar.AlignThumb();
	}
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex;
	local float RelativeMouseX;

	if ( IsInClientBounds() )
	{
		//  Figure out which Item we're clicking on
		NewIndex = CalculateIndex();
		RelativeMouseX = Controller.MouseX - ClientBounds[0];
		if ( RelativeMouseX < ActualWidth() * ItemBGWidthScale )
		{
			if ( MyBuyables[NewIndex] != none )
			{
				SetIndex(NewIndex);
				MouseOverXIndex = 0;
				return true;
			}
		}
		else
		{
			RelativeMouseX -= ActualWidth() * (ItemBGWidthScale + AmmoBGWidthScale);

			if ( RelativeMouseX > 0 )
			{
				if ( MyBuyables[NewIndex].bIsVest )
				{
					if ( (PlayerOwner().Pawn.ShieldStrength > 0 && PlayerOwner().PlayerReplicationInfo.Score >= MyBuyables[NewIndex].ItemAmmoCost) || PlayerOwner().PlayerReplicationInfo.Score >= MyBuyables[NewIndex].ItemCost )
					{
						OnBuyVestClick();
					}
				}
				else if ( RelativeMouseX < ActualWidth() * (1.0 - ItemBGWidthScale - AmmoBGWidthScale) * ClipButtonWidthScale )
				{
					// Buy Clip
					OnBuyClipClick(MyBuyables[NewIndex]);
				}
				else
				{
					// Fill Ammo
					OnFillAmmoClick(MyBuyables[NewIndex]);
				}
			}
		}
	}

	return false;
}

function bool PreDraw(Canvas Canvas)
{
	local float RelativeMouseX;

	if ( IsInClientBounds() )
	{
		//  Figure out which Item we're clicking on
		MouseOverIndex = Top + ((Controller.MouseY - ClientBounds[1]) / ItemHeight);
		if ( MouseOverIndex >= ItemCount )
		{
			MouseOverIndex = -1;
		}
		else
		{
			RelativeMouseX = Controller.MouseX - ClientBounds[0];
			if ( RelativeMouseX < ActualWidth() * ItemBGWidthScale )
			{
				MouseOverXIndex = 0;
			}
			else
			{
				RelativeMouseX -= ActualWidth() * (ItemBGWidthScale + AmmoBGWidthScale);

				if ( RelativeMouseX > 0 )
				{
					if ( RelativeMouseX < ActualWidth() * (1.0 - ItemBGWidthScale - AmmoBGWidthScale) * ClipButtonWidthScale )
					{
						MouseOverXIndex = 1;
					}
					else
					{
						MouseOverXIndex = 2;
					}
				}
				else
				{
					MouseOverXIndex = -1;
				}
			}
		}
	}
	else
	{
		MouseOverIndex = -1;
	}

	return false;
}

function DrawInvItem(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float IconBGSize, ItemBGWidth, AmmoBGWidth, ClipButtonWidth, FillButtonWidth;
	local float TempX, TempY;
	local float StringHeight, StringWidth;

	OnClickSound=CS_Click;

	// Initialize the Canvas
	Canvas.Style = 1;
	// Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	if ( MyBuyables[CurIndex] == none )
	{
		if ( CurIndex < 7 )
		{
			return;
		}

		Canvas.SetPos(X + EquipmentBGXOffset, Y + Height - EquipmentBGYOffset - EquipmentBGHeightScale * Height);
		Canvas.DrawTileStretched(AmmoBackground, EquipmentBGWidthScale * Width, EquipmentBGHeightScale * Height);

		Canvas.SetDrawColor(175, 176, 158, 255);
		Canvas.StrLen(EquipmentString, StringWidth, StringHeight);
		Canvas.SetPos(X + EquipmentBGXOffset + ((EquipmentBGWidthScale * Width - StringWidth) / 2.0), Y + Height - EquipmentBGYOffset - EquipmentBGHeightScale * Height + ((EquipmentBGHeightScale * Height - StringHeight) / 2.0));
		Canvas.DrawText(EquipmentString);
	}
	else
	{
		// Calculate Widths for all components
		IconBGSize = Height;
		ItemBGWidth = (Width * ItemBGWidthScale) - IconBGSize;
		AmmoBGWidth = Width * AmmoBGWidthScale;

		if ( !MyBuyables[CurIndex].bIsVest )
		{
			FillButtonWidth = ((1.0 - ItemBGWidthScale - AmmoBGWidthScale) * Width) - ButtonSpacing;
			ClipButtonWidth = FillButtonWidth * ClipButtonWidthScale;
			FillButtonWidth -= ClipButtonWidth;
		}
		else
		{
			FillButtonWidth = ((1.0 - ItemBGWidthScale - AmmoBGWidthScale) * Width);
		}

		// Offset for the Background
		TempX = X;
		TempY = Y;

		// Draw Item Background
		Canvas.SetPos(TempX, TempY);

		if ( bSelected )
		{
			Canvas.DrawTileStretched(SelectedItemBackgroundLeft, IconBGSize, IconBGSize);
			Canvas.SetPos(TempX + 4, TempY + 4);
			Canvas.DrawTile(PerkTextures[CurIndex], IconBGSize - 8, IconBGSize - 8, 0, 0, 256, 256);

			TempX += IconBGSize;
			Canvas.SetPos(TempX, TempY + ItemBGYOffset);
			Canvas.DrawTileStretched(SelectedItemBackgroundRight, ItemBGWidth, IconBGSize - (2.0 * ItemBGYOffset));
		}
		else
		{
			Canvas.DrawTileStretched(ItemBackgroundLeft, IconBGSize, IconBGSize);
			Canvas.SetPos(TempX + 4, TempY + 4);
			Canvas.DrawTile(PerkTextures[CurIndex], IconBGSize - 8, IconBGSize - 8, 0, 0, 256, 256);

			TempX += IconBGSize;
			Canvas.SetPos(TempX, TempY + ItemBGYOffset);
			Canvas.DrawTileStretched(ItemBackgroundRight, ItemBGWidth, IconBGSize - (2.0 * ItemBGYOffset));
		}

		// Select Text color
		if ( CurIndex == MouseOverIndex && MouseOverXIndex == 0 )
		{
			Canvas.SetDrawColor(255, 255, 255, 255);
		}
		else
		{
			Canvas.SetDrawColor(0, 0, 0, 255);
		}

		// Draw the item's name
		Canvas.StrLen(NameStrings[CurIndex], StringWidth, StringHeight);
		Canvas.SetPos(TempX + ItemNameSpacing, Y + ((Height - StringHeight) / 2.0));
		Canvas.DrawText(NameStrings[CurIndex]);

		// Draw the item's ammo status if it is not a melee weapon
		if ( !MyBuyables[CurIndex].bMelee )
		{
			TempX += ItemBGWidth + AmmoSpacing;

			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.SetPos(TempX, TempY + ((Height - AmmoBGHeightScale * Height) / 2.0));
			Canvas.DrawTileStretched(AmmoBackground, AmmoBGWidth, AmmoBGHeightScale * Height);

			Canvas.SetDrawColor(175, 176, 158, 255);
			Canvas.StrLen(AmmoStrings[CurIndex], StringWidth, StringHeight);
			Canvas.SetPos(TempX + ((AmmoBGWidth - StringWidth) / 2.0), TempY + ((Height - StringHeight) / 2.0));
			Canvas.DrawText(AmmoStrings[CurIndex]);

			TempX += AmmoBGWidth + AmmoSpacing;

			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.SetPos(TempX, TempY + ((Height - ButtonBGHeightScale * Height) / 2.0));

			if ( !MyBuyables[CurIndex].bIsVest )
			{
				if ( MyBuyables[CurIndex].ItemAmmoCurrent >= MyBuyables[CurIndex].ItemAmmoMax ||
					 (PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemFillAmmoCost && PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemAmmoCost) )
				{
					Canvas.DrawTileStretched(DisabledButtonBackground, ClipButtonWidth, ButtonBGHeightScale * Height);
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
				else if ( CurIndex == MouseOverIndex && MouseOverXIndex == 1 )
				{
					Canvas.DrawTileStretched(HoverButtonBackground, ClipButtonWidth, ButtonBGHeightScale * Height);
				}
				else
				{
					Canvas.DrawTileStretched(ButtonBackground, ClipButtonWidth, ButtonBGHeightScale * Height);
					Canvas.SetDrawColor(0, 0, 0, 255);
				}

				Canvas.StrLen(ClipPriceStrings[CurIndex], StringWidth, StringHeight);
				Canvas.SetPos(TempX + ((ClipButtonWidth - StringWidth) / 2.0), TempY + ((Height - StringHeight) / 2.0));
				Canvas.DrawText(ClipPriceStrings[CurIndex]);

				TempX += ClipButtonWidth + ButtonSpacing;

				Canvas.SetDrawColor(255, 255, 255, 255);
				Canvas.SetPos(TempX, TempY + ((Height - ButtonBGHeightScale * Height) / 2.0));

				if ( MyBuyables[CurIndex].ItemAmmoCurrent >= MyBuyables[CurIndex].ItemAmmoMax ||
					 (PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemFillAmmoCost && PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemAmmoCost) )
				{
					Canvas.DrawTileStretched(DisabledButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
				else if ( CurIndex == MouseOverIndex && MouseOverXIndex == 2 )
				{
					Canvas.DrawTileStretched(HoverButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
				}
				else
				{
					Canvas.DrawTileStretched(ButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
			}
			else
			{
				if ( (PlayerOwner().Pawn.ShieldStrength > 0 && PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemAmmoCost) ||
					 (PlayerOwner().Pawn.ShieldStrength <= 0 && PlayerOwner().PlayerReplicationInfo.Score < MyBuyables[CurIndex].ItemCost) ||
					 MyBuyables[CurIndex].ItemAmmoCurrent >= MyBuyables[CurIndex].ItemAmmoMax )
				{
					Canvas.DrawTileStretched(DisabledButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
				else if ( CurIndex == MouseOverIndex && MouseOverXIndex >= 1 )
				{
					Canvas.DrawTileStretched(HoverButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
				}
				else
				{
					Canvas.DrawTileStretched(ButtonBackground, FillButtonWidth, ButtonBGHeightScale * Height);
					Canvas.SetDrawColor(0, 0, 0, 255);
				}
			}

			Canvas.StrLen(FillPriceStrings[CurIndex], StringWidth, StringHeight);
			Canvas.SetPos(TempX + ((FillButtonWidth - StringWidth) / 2.0), TempY + ((Height - StringHeight) / 2.0));
			Canvas.DrawText(FillPriceStrings[CurIndex]);
		}

		Canvas.SetDrawColor(255, 255, 255, 255);
	}
}

function float InvItemHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 11) - 1.0;
}

defaultproperties
{
     ItemBGWidthScale=0.510000
     AmmoBGWidthScale=0.190000
     ClipButtonWidthScale=0.450000
     AmmoBGHeightScale=0.500000
     ButtonBGHeightScale=0.500000
     EquipmentBGWidthScale=0.350000
     EquipmentBGHeightScale=0.600000
     ItemBGYOffset=6.000000
     AmmoSpacing=1.000000
     ItemNameSpacing=10.000000
     ButtonSpacing=3.000000
     EquipmentBGXOffset=3.000000
     EquipmentBGYOffset=6.000000
     EquipmentString="Equipment"
     BuyString="Buy"
     PurchasedString="Purchased"
     RepairString="Repair"
     ItemBackgroundLeft=Texture'KF_InterfaceArt_tex.Menu.Item_box_box'
     ItemBackgroundRight=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar'
     SelectedItemBackgroundLeft=Texture'KF_InterfaceArt_tex.Menu.Item_box_box_Highlighted'
     SelectedItemBackgroundRight=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar_Highlighted'
     DisabledItemBackgroundLeft=Texture'KF_InterfaceArt_tex.Menu.Item_box_box_Disabled'
     DisabledItemBackgroundRight=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar_Disabled'
     AmmoBackground=Texture'KF_InterfaceArt_tex.Menu.Innerborder_transparent'
     ButtonBackground=Texture'KF_InterfaceArt_tex.Menu.Button'
     HoverButtonBackground=Texture'KF_InterfaceArt_tex.Menu.button_Highlight'
     DisabledButtonBackground=Texture'KF_InterfaceArt_tex.Menu.button_Disabled'
     GetItemHeight=KFBuyMenuInvList.InvItemHeight
     FontScale=FNS_Medium
     OnPreDraw=KFBuyMenuInvList.PreDraw
}
