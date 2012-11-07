//=============================================================================
// The trader menu's list with items for sale
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================
class KFBuyMenuSaleList extends GUIVertList;

// Settings
var	float					ItemBorder;			// Percent of Height to leave blank inside Item Background
var	float					TextTopOffset;		// Percent of Height to offset top of Text
var	float					ItemSpacing;		// Number of Pixels between Items

// Display
var	texture					ItemBackgroundLeft;
var	texture					ItemBackgroundRight;
var	texture					SelectedItemBackgroundLeft;
var	texture					SelectedItemBackgroundRight;
var texture					DisabledItemBackgroundLeft;
var	texture					DisabledItemBackgroundRight;

var array<string>			PrimaryStrings;
var	array<string>			SecondaryStrings;
var array<byte>             CanBuys;
var array<byte>				ItemPerkIndexes;

var color					DarkRedColor;

// Sounds
var	SoundGroup				TraderSoundTooExpensive;
var	SoundGroup				TraderSoundTooHeavy;

// state
var	array<GUIBuyable>		ForSaleBuyables;
var	int						MouseOverIndex;

var bool					bNeedsUpdate;
var int						UpdateCounter;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	OnDrawItem = DrawInvItem;
	SetTimer(0.05, true);
}

function Timer()
{
	UpdateForSaleBuyables();
}

event Opened(GUIComponent Sender)
{
	super.Opened(Sender);
	UpdateForSaleBuyables();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	PrimaryStrings.Remove(0, PrimaryStrings.Length);
	SecondaryStrings.Remove(0, SecondaryStrings.Length);
	CanBuys.Remove(0, CanBuys.Length);
	ItemPerkIndexes.Remove(0, ItemPerkIndexes.Length);
	ForSaleBuyables.Remove(0, ForSaleBuyables.Length);

	super.Closed(Sender, bCancelled);
}

function UpdateForSaleBuyables()
{
	local class<KFVeterancyTypes> PlayerVeterancy;
    local KFPlayerReplicationInfo KFPRI;
	local KFLevelRules KFLR, KFLRit;
	local GUIBuyable ForSaleBuyable;
	local class<KFWeaponPickup> ForSalePickup;
	local int i, j, DualDivider, ForSaleArrayIndex;
	local bool bZeroWeight;

	DualDivider = 1;

	// Grab the items for sale
    foreach PlayerOwner().DynamicActors(class'KFLevelRules', KFLRit)
    {
        KFLR = KFLRit;
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
	for ( j = 0; j < KFLR.MAX_BUYITEMS; j++ )
    {
    	if ( KFLR.ItemForSale[j] != none )
        {
			//Let's see if this is a vest, first aid kit, ammo or stuff we already have
			if ( class<Vest>(KFLR.ItemForSale[j]) != none || class<FirstAidKit>(KFLR.ItemForSale[j]) != none ||
                 class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType) == none || KFLR.ItemForSale[j].IsA('Ammunition') ||
				 class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType).default.bKFNeverThrow ||
                 IsInInventory(KFLR.ItemForSale[j]) ||
				 class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.CorrespondingPerkIndex != PlayerVeterancy.default.PerkIndex)
        	{
        		continue;
			}

            if ( class<Deagle>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'DualDeaglePickup') )
				{
					continue;
				}
			}

            if ( class<Magnum44Pistol>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'Dual44MagnumPickup') )
				{
					continue;
				}
			}

            if ( class<MK23Pistol>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'DualMK23Pickup') )
				{
					continue;
				}
			}

            if ( class<FlareRevolver>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'DualFlareRevolverPickup') )
				{
					continue;
				}
			}

			if ( class<DualDeagle>(KFLR.ItemForSale[j].default.InventoryType) != none
                || class<Dual44Magnum>(KFLR.ItemForSale[j].default.InventoryType) != none
                || class<DualMK23Pistol>(KFLR.ItemForSale[j].default.InventoryType) != none
                || class<DualFlareRevolver>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'DeaglePickup') )
				{
					DualDivider = 2;
				}
				else if ( IsInInventory(class'Magnum44Pickup') )
				{
					DualDivider = 2;
				}
				else if ( IsInInventory(class'MK23Pickup') )
				{
					DualDivider = 2;
				}
				else if ( IsInInventory(class'FlareRevolverPickup') )
				{
					DualDivider = 2;
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

			ForSalePickup =  class<KFWeaponPickup>(KFLR.ItemForSale[j]);

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
				ForSaleBuyable.ItemWeight 	= 1.f;
			}
			else if ( ForSalePickup == class'Dual44MagnumPickup' && IsInInventory(class'Magnum44Pickup') )
			{
				ForSaleBuyable.ItemWeight= ForSalePickup.default.Weight / 2;
			}
			else if ( ForSalePickup == class'DualMK23Pickup' && IsInInventory(class'MK23Pickup') )
			{
				ForSaleBuyable.ItemWeight= ForSalePickup.default.Weight / 2;
			}
			else if ( ForSalePickup == class'DualFlareRevolverPickup' && IsInInventory(class'FlareRevolverPickup') )
			{
				ForSaleBuyable.ItemWeight= ForSalePickup.default.Weight / 2;
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
	for ( j = KFLR.MAX_BUYITEMS - 1; j >= 0; j-- )
    {
    	if ( KFLR.ItemForSale[j] != none )
        {
        	//Let's see if this is a vest, first aid kit, ammo or stuff we already have
            if ( class<Vest>(KFLR.ItemForSale[j]) != none || class<FirstAidKit>(KFLR.ItemForSale[j]) != none ||
                 class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType) == none || KFLR.ItemForSale[j].IsA('Ammunition') ||
				 class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType).default.bKFNeverThrow ||
                 IsInInventory(KFLR.ItemForSale[j]) ||
				 class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.CorrespondingPerkIndex == PlayerVeterancy.default.PerkIndex )
        	{
        		continue;
			}

            if ( class<Deagle>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'DualDeaglePickup') )
				{
					continue;
				}
			}

            if ( class<Magnum44Pistol>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'Dual44MagnumPickup') )
				{
					continue;
				}
			}

            if ( class<MK23Pistol>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'DualMK23Pickup') )
				{
					continue;
				}
			}

            if ( class<FlareRevolver>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'DualFlareRevolverPickup') )
				{
					continue;
				}
			}

			if ( class<DualDeagle>(KFLR.ItemForSale[j].default.InventoryType) != none
                || class<Dual44Magnum>(KFLR.ItemForSale[j].default.InventoryType) != none
                || class<DualMK23Pistol>(KFLR.ItemForSale[j].default.InventoryType) != none
                || class<DualFlareRevolver>(KFLR.ItemForSale[j].default.InventoryType) != none )
            {
				if ( IsInInventory(class'DeaglePickup') )
				{
					DualDivider = 2;
					bZeroWeight = true;
				}
				else if ( IsInInventory(class'Magnum44Pickup') )
				{
					DualDivider = 2;
				}
				else if ( IsInInventory(class'MK23Pickup') )
				{
					DualDivider = 2;
				}
				else if ( IsInInventory(class'FlareRevolverPickup') )
				{
					DualDivider = 2;
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

			ForSalePickup =  class<KFWeaponPickup>(KFLR.ItemForSale[j]);

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

function UpdateList()
{
	local int i;

	// Clear the arrays
	if ( ForSaleBuyables.Length < ItemPerkIndexes.Length )
	{
		ItemPerkIndexes.Remove(ForSaleBuyables.Length, ItemPerkIndexes.Length);
		PrimaryStrings.Remove(ForSaleBuyables.Length, PrimaryStrings.Length);
		SecondaryStrings.Remove(ForSaleBuyables.Length, SecondaryStrings.Length);
		CanBuys.Remove(ForSaleBuyables.Length, CanBuys.Length);
	}

	// Update the ItemCount and select the first item
	ItemCount = ForSaleBuyables.Length;

	// Update the players inventory list
	for ( i = 0; i < ItemCount; i++ )
	{
		PrimaryStrings[i] = ForSaleBuyables[i].ItemName;
		SecondaryStrings[i] = "£" @ int(ForSaleBuyables[i].ItemCost);

		ItemPerkIndexes[i] = ForSaleBuyables[i].ItemPerkIndex;

        if ( ForSaleBuyables[i].ItemWeaponClass.Default.AppID > 0 && !PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC(ForSaleBuyables[i].ItemWeaponClass.Default.AppID) )
		{
			CanBuys[i] = 0;
			SecondaryStrings[i] = "DLC";
		}
		else if ( ForSaleBuyables[i].ItemCost > PlayerOwner().PlayerReplicationInfo.Score ||
			 ForSaleBuyables[i].ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
		{
			CanBuys[i] = 0;
		}
		else
		{
			CanBuys[i] = 1;
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

	bNeedsUpdate = false;
}

function bool IsInInventory(class<Pickup> Item)
{
    local Inventory CurInv;

    for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
		if ( CurInv.default.PickupClass == Item )
		{
			return true;
		}
    }

    return false;
}

function bool PreDraw(Canvas Canvas)
{
	if ( Controller.MouseX >= ClientBounds[0] && Controller.MouseX <= ClientBounds[2] && Controller.MouseY >= ClientBounds[1] )
	{
		//  Figure out which Item we're clicking on
		MouseOverIndex = Top + ((Controller.MouseY - ClientBounds[1]) / ItemHeight);

		if ( MouseOverIndex >= ItemCount )
		{
			MouseOverIndex = -1;
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
	local float TempX, TempY, TempHeight;
	local float StringHeight, StringWidth;

	OnClickSound=CS_Click;

	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing / 2.0;

	// Initialize the Canvas
	Canvas.Style = 1;
	//Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);

	if ( CanBuys[CurIndex] < 1 )
	{
		Canvas.DrawTileStretched(DisabledItemBackgroundLeft, Height - ItemSpacing, Height - ItemSpacing);

		TempX += ((Height - ItemSpacing) - 1);
		TempHeight = Height - 12;
		TempY += 6;//(Height - TempHeight) / 2;

		Canvas.SetPos(TempX, TempY);

		Canvas.DrawTileStretched(DisabledItemBackgroundRight, Width - (Height - ItemSpacing), Height - 12);
	}
	else if ( bSelected )
	{
		Canvas.DrawTileStretched(SelectedItemBackgroundLeft, Height - ItemSpacing, Height - ItemSpacing);

		TempX += ((Height - ItemSpacing) - 1);
		TempHeight = Height - 12;
		TempY += 6;//(Height - TempHeight) / 2;

		Canvas.SetPos(TempX, TempY);

		Canvas.DrawTileStretched(SelectedItemBackgroundRight, Width - (Height - ItemSpacing), Height - 12);
	}
	else
	{
		Canvas.DrawTileStretched(ItemBackgroundLeft, Height - ItemSpacing, Height - ItemSpacing);

		TempX += ((Height - ItemSpacing) - 1);
		TempHeight = Height - 12;
		TempY += 6;//(Height - TempHeight) / 2;

		Canvas.SetPos(TempX, TempY);

		Canvas.DrawTileStretched(ItemBackgroundRight, Width - (Height - ItemSpacing), Height - 12);
	}

	Canvas.SetPos(X + 4, Y + 4);
	Canvas.DrawTile(class'KFGameType'.default.LoadedSkills[ItemPerkIndexes[CurIndex]].default.OnHUDIcon, Height - 8, Height - 8, 0, 0, 256, 256);

	// Select Text color
	if ( CurIndex == MouseOverIndex )
	{
		Canvas.SetDrawColor(255, 255, 255, 255);
	}
	else
	{
		Canvas.SetDrawColor(0, 0, 0, 255);
	}

	// Draw the item's name and categorie
	Canvas.StrLen(PrimaryStrings[CurIndex], StringWidth, StringHeight);
	Canvas.SetPos(TempX + (0.2 * Height), TempY + ((TempHeight - StringHeight) / 2));
	Canvas.DrawText(PrimaryStrings[CurIndex]);

	// Draw the item's price
	Canvas.StrLen(SecondaryStrings[CurIndex], StringWidth, StringHeight);
	Canvas.SetPos((TempX - Height) + Width - (StringWidth + (0.2 * Height)), TempY + ((TempHeight - StringHeight) / 2));
	Canvas.DrawText(SecondaryStrings[CurIndex]);

	Canvas.SetDrawColor(255, 255, 255, 255);
}

function float SaleItemHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 10 - 1);
}

function IndexChanged(GUIComponent Sender)
{
	if ( CanBuys[Index] == 0 )
	{
	    if ( ForSaleBuyables[Index].ItemCost > PlayerOwner().PlayerReplicationInfo.Score )
		{
			PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooExpensive, SLOT_Interface, 2.0);
		}
		else if ( ForSaleBuyables[Index].ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
		{
			PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooHeavy, SLOT_Interface, 2.0);
		}
	}

	super.IndexChanged(Sender);
}

defaultproperties
{
     TextTopOffset=0.050000
     ItemBackgroundLeft=Texture'KF_InterfaceArt_tex.Menu.Item_box_box'
     ItemBackgroundRight=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar'
     SelectedItemBackgroundLeft=Texture'KF_InterfaceArt_tex.Menu.Item_box_box_Highlighted'
     SelectedItemBackgroundRight=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar_Highlighted'
     DisabledItemBackgroundLeft=Texture'KF_InterfaceArt_tex.Menu.Item_box_box_Disabled'
     DisabledItemBackgroundRight=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar_Disabled'
     DarkRedColor=(B=96,G=96,R=96,A=255)
     TraderSoundTooExpensive=SoundGroup'KF_Trader.TooExpensive'
     TraderSoundTooHeavy=SoundGroup'KF_Trader.TooHeavy'
     GetItemHeight=KFBuyMenuSaleList.SaleItemHeight
     FontScale=FNS_Medium
     OnPreDraw=KFBuyMenuSaleList.PreDraw
}
