//=============================================================================
// The trader menu's list with items for sale
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================
class KFBuyMenuSaleList extends GUIVertList;

#exec OBJ LOAD FILE=Potato_T.utx

// Settings
var float                   ItemBorder;         // Percent of Height to leave blank inside Item Background
var float                   TextTopOffset;      // Percent of Height to offset top of Text
var float                   ItemSpacing;        // Number of Pixels between Items

// Display
var texture                 ItemBackgroundLeft;
var texture                 ItemBackgroundRight;
var texture                 SelectedItemBackgroundLeft;
var texture                 SelectedItemBackgroundRight;
var texture                 DisabledItemBackgroundLeft;
var texture                 DisabledItemBackgroundRight;

var texture                 NoPerkIcon;

var array<string>           PrimaryStrings;
var array<string>           SecondaryStrings;
var array<byte>             CanBuys;
var array<byte>             ItemPerkIndexes;

var color                   DarkRedColor;

// Sounds
var SoundGroup              TraderSoundTooExpensive;
var SoundGroup              TraderSoundTooHeavy;

// state
var array<GUIBuyable>       ForSaleBuyables;
var int                     MouseOverIndex;

var bool                    bNeedsUpdate;
var int                     UpdateCounter;

var localized string        WeaponDLCMessage;

var int                     CurrFilterIndex;
var int                     CurrFilterItemCount;

var GUIBuyable              BuyableToDisplay;

var KFLevelRules            KFLR;

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

    SetIndex( -1 );

    // Grab the items for sale
    foreach PlayerOwner().DynamicActors(class'KFLevelRules', KFLR)
    {
        break;
    }

    FilterBuyablesList();
    UpdateForSaleBuyables();
}

event Closed(GUIComponent Sender, bool bCancelled)
{
    PrimaryStrings.Remove(0, PrimaryStrings.Length);
    SecondaryStrings.Remove(0, SecondaryStrings.Length);
    CanBuys.Remove(0, CanBuys.Length);
    ItemPerkIndexes.Remove(0, ItemPerkIndexes.Length);
    ForSaleBuyables.Remove(0, ForSaleBuyables.Length);

    SetIndex( -1 );
    BuyableToDisplay = none;

    super.Closed(Sender, bCancelled);
}

function int PopulateBuyables()
{
    local class<KFVeterancyTypes> PlayerVeterancy;
    local KFPlayerReplicationInfo KFPRI;
    local GUIBuyable ForSaleBuyable;
    local class<KFWeaponPickup> ForSalePickup;
    local int currentIndex, i, j, DualDivider;
    local bool bZeroWeight;

    DualDivider = 1;

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
    for ( j = 0; j < KFLR.ItemForSale.Length; j++ )
    {
        if ( KFLR.ItemForSale[j] != none )
        {
            ForSalePickup = class<KFWeaponPickup>(KFLR.ItemForSale[j]);

            //if( ForSalePickup != class'KFMod.Potato' )
            //{
                //Let's see if this is a vest, first aid kit, ammo or stuff we already have
                if ( class<Vest>(KFLR.ItemForSale[j]) != none || class<FirstAidKit>(KFLR.ItemForSale[j]) != none ||
                     class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType) == none || KFLR.ItemForSale[j].IsA('Ammunition') ||
                     class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType).default.bKFNeverThrow ||
                     IsVariantInInventory(ForSalePickup) )
                {
                    continue;
                }
            //}

            if ( class<Deagle>(ForSalePickup.default.InventoryType) != none )
            {
                if ( IsVariantInInventory(class'DualDeaglePickup') )
                {
                    continue;
                }
            }

            if ( class<Magnum44Pistol>(ForSalePickup.default.InventoryType) != none )
            {
                if ( IsInInventory(class'Dual44MagnumPickup') )
                {
                    continue;
                }
            }

            if ( class<MK23Pistol>(ForSalePickup.default.InventoryType) != none )
            {
                if ( IsInInventory(class'DualMK23Pickup') )
                {
                    continue;
                }
            }

            if ( class<FlareRevolver>(ForSalePickup.default.InventoryType) != none )
            {
                if ( IsInInventory(class'DualFlareRevolverPickup') )
                {
                    continue;
                }
            }

            // reduce displayed price of dualies if player owns single
            if ( ForSalePickup.default.InventoryType == class'DualDeagle' &&
                 IsInInventory(class'DeaglePickup') )
            {
                DualDivider = 2;
            }
            else if(  ForSalePickup.default.InventoryType == class'GoldenDualDeagle' &&
                      IsInInventory(class'GoldenDeaglePickup') )
            {
                DualDivider = 2;
            }
            else if(  class<Dual44Magnum>(ForSalePickup.default.InventoryType) != none &&
                      IsInInventory(class'Magnum44Pickup') )
            {
                DualDivider = 2;
            }
            else if(  class<DualMK23Pistol>(ForSalePickup.default.InventoryType) != none &&
                      IsInInventory(class'MK23Pickup') )
            {
                DualDivider = 2;
            }
            else if(  class<DualFlareRevolver>(ForSalePickup.default.InventoryType) != none &&
                      IsInInventory(class'FlareRevolverPickup') )
            {
                DualDivider = 2;
            }
            else
            {
                DualDivider = 1;
                bZeroWeight = false;
            }

            if ( currentIndex >= ForSaleBuyables.Length )
            {
                ForSaleBuyable = new class'GUIBuyable';
                ForSaleBuyables[ForSaleBuyables.Length] = ForSaleBuyable;
            }
            else
            {
                ForSaleBuyable = ForSaleBuyables[currentIndex];
            }

            currentIndex++;

            ForSaleBuyable.ItemName         = ForSalePickup.default.ItemName;
            ForSaleBuyable.ItemDescription  = ForSalePickup.default.Description;
            ForSaleBuyable.ItemCategorie    = KFLR.EquipmentCategories[i].EquipmentCategoryName;
            /*if( ForSalePickup == class'KFMod.Potato' )
            {
                ForSaleBuyable.ItemImage        = Texture'Potato_T.ui_potato';
                ForSaleBuyable.ItemAmmoClass    = none;
            }
            else*/
            //{
                ForSaleBuyable.ItemImage        = class<KFWeapon>(ForSalePickup.default.InventoryType).default.TraderInfoTexture;
                ForSaleBuyable.ItemAmmoClass    = class<KFWeapon>(ForSalePickup.default.InventoryType).default.FireModeClass[0].default.AmmoClass;
            //}
            ForSaleBuyable.ItemWeaponClass  = class<KFWeapon>(ForSalePickup.default.InventoryType);
            ForSaleBuyable.ItemPickupClass  = ForSalePickup;
            ForSaleBuyable.ItemCost         = int((float(ForSalePickup.default.Cost)
                                              * PlayerVeterancy.static.GetCostScaling(KFPRI, ForSalePickup)) / DualDivider);
            ForSaleBuyable.ItemAmmoCost     = 0;
            ForSaleBuyable.ItemFillAmmoCost = 0;

            if ( bZeroWeight)
            {
                ForSaleBuyable.ItemWeight   = 1.f;
            }
            else if ( (ForSalePickup == class'DualDeaglePickup' || ForSalePickup == class'GoldenDualDeaglePickup')
                      && (IsInInventory(class'DeaglePickup') || IsInInventory(class'GoldenDeaglePickup')) )
            {
                ForSaleBuyable.ItemWeight= ForSalePickup.default.Weight / 2;
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
                ForSaleBuyable.ItemWeight   = ForSalePickup.default.Weight;
            }

            ForSaleBuyable.ItemPower        = ForSalePickup.default.PowerValue;
            ForSaleBuyable.ItemRange        = ForSalePickup.default.RangeValue;
            ForSaleBuyable.ItemSpeed        = ForSalePickup.default.SpeedValue;
            ForSaleBuyable.ItemAmmoCurrent  = 0;
            ForSaleBuyable.ItemAmmoMax      = 0;
            ForSaleBuyable.ItemPerkIndex    = ForSalePickup.default.CorrespondingPerkIndex;

            // Make sure we mark the list as a sale list
            ForSaleBuyable.bSaleList = true;

            bZeroWeight = false;
        }
    }
    return currentIndex;
}

function FilterBuyablesList()
{
    CurrFilterIndex = KFPlayerController( PlayerOwner() ).BuyMenuFilterIndex;

    switch( CurrFilterIndex )
    {
    case 0:
        KFLR.ItemForSale = KFLR.MediItemForSale;
        break;

    case 1:
        KFLR.ItemForSale = KFLR.SuppItemForSale;
        break;

    case 2:
        KFLR.ItemForSale = KFLR.ShrpItemForSale;
        break;

    case 3:
        KFLR.ItemForSale = KFLR.CommItemForSale;
        break;

    case 4:
        KFLR.ItemForSale = KFLR.BersItemForSale;
        break;

    case 5:
        KFLR.ItemForSale = KFLR.FireItemForSale;
        break;

    case 6:
        KFLR.ItemForSale = KFLR.DemoItemForSale;
        break;

    case 7:
        KFLR.ItemForSale = KFLR.NeutItemForSale;
        break;

    case 8:
        KFLR.ItemForSale = KFLR.FaveItemForSale;
        break;
    };

    CurrFilterItemCount = KFLR.ItemForSale.Length;
}

function UpdateForSaleBuyables()
{
    local class<KFVeterancyTypes> PlayerVeterancy;
    local KFPlayerReplicationInfo KFPRI;
    local int ForSaleArrayIndex;
    local bool bFiltered;

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

    if( KFPlayerController(PlayerOwner()) != none && CurrFilterIndex != KFPlayerController(PlayerOwner()).BuyMenuFilterIndex )
    {
       FilterBuyablesList();
       bFiltered = true;
    }

    ForSaleArrayIndex = PopulateBuyables();

    if ( ForSaleArrayIndex < ForSaleBuyables.Length )
    {
        ForSaleBuyables.Remove(ForSaleArrayIndex, ForSaleBuyables.Length - ForSaleArrayIndex);
    }

    //Now Update the list
    UpdateList();

    if( bFiltered )
    {
        SetIndex( GetDisplayedBuyableIndex() );
        if( self.Index < 0 )
        {
            SetTopItem( 0 );
        }
    }
}

function int GetDisplayedBuyableIndex()
{
    local int i;

    if( BuyableToDisplay != none && BuyableToDisplay.bSaleList )
    {
        for( i = 0; i < ForSaleBuyables.Length; ++i )
        {
            if( BuyableToDisplay.ItemName == ForSaleBuyables[i].ItemName )
            {
                return i;
            }
        }
    }

    return -1;
}

function UpdateList()
{
    local int i;
    local bool unlockedByAchievement, unlockedByApp;

    // Clear the arrays
    if ( ForSaleBuyables.Length < ItemPerkIndexes.Length )
    {
        ItemPerkIndexes.Remove(ForSaleBuyables.Length, ItemPerkIndexes.Length - ForSaleBuyables.Length);
        PrimaryStrings.Remove(ForSaleBuyables.Length, PrimaryStrings.Length - ForSaleBuyables.Length);
        SecondaryStrings.Remove(ForSaleBuyables.Length, SecondaryStrings.Length - ForSaleBuyables.Length);
        CanBuys.Remove(ForSaleBuyables.Length, CanBuys.Length - ForSaleBuyables.Length);
    }

    // Update the ItemCount and select the first item
    ItemCount = ForSaleBuyables.Length;

    // Update the players inventory list
    for ( i = 0; i < ItemCount; i++ )
    {
        PrimaryStrings[i] = ForSaleBuyables[i].ItemName;
        SecondaryStrings[i] = "£" @ int(ForSaleBuyables[i].ItemCost);

        //controls which icon to put up
        ItemPerkIndexes[i] = ForSaleBuyables[i].ItemPerkIndex;


        if ( ForSaleBuyables[i].ItemCost > PlayerOwner().PlayerReplicationInfo.Score ||
             ForSaleBuyables[i].ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
        {
            CanBuys[i] = 0;
        }
        else
        {
            CanBuys[i] = 1;
        }

        /*if( ForSaleBuyables[i].ItemPickupClass == class'KFMod.Potato' )
        {
            continue;
        }*/

        unlockedByAchievement = false;
        unlockedByApp = false;

        if( KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements) != none )
        {
            if( ForSaleBuyables[i].ItemWeaponClass.Default.UnlockedByAchievement != -1 )
            {

                unlockedByAchievement = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements).Achievements[ForSaleBuyables[i].ItemWeaponClass.Default.UnlockedByAchievement].bCompleted == 1;
            }
            if( ForSaleBuyables[i].ItemWeaponClass.Default.AppID > 0 )
            {

                unlockedByApp = PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC(ForSaleBuyables[i].ItemWeaponClass.Default.AppID);
            }
        }
        //lock the weapon if it requires an achievement that they don't have.
        if ( ForSaleBuyables[i].ItemWeaponClass.Default.UnlockedByAchievement != -1 )
        {
            if( !unlockedByAchievement && !unlockedByApp)
            {
                CanBuys[i] = 0;
                SecondaryStrings[i] = "LOCKED";
            }
        }
        else if ( ForSaleBuyables[i].ItemWeaponClass.Default.AppID > 0 && !unlockedByApp )
        {
            if( !unlockedByAchievement )
            {
                CanBuys[i] = 0;
                SecondaryStrings[i] = "DLC";
            }
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
    return KFPlayerController( PlayerOwner() ).IsInInventory( Item, true, false );
}

function bool IsVariantInInventory(class<Pickup> PickupForSale)
{
    return KFPlayerController( PlayerOwner() ).IsInInventory( PickupForSale, true, true );
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
    //controls the icon
    if(ItemPerkIndexes[CurIndex] != 7 )
    {
        Canvas.DrawTile(class'KFGameType'.default.LoadedSkills[ItemPerkIndexes[CurIndex]].default.OnHUDIcon, Height - 8, Height - 8, 0, 0, 256, 256);
    }
    /*else if( ForSaleBuyables.Length > CurIndex && ForSaleBuyables[CurIndex].ItemPickupClass == class'KFMod.Potato' )
    {
        Canvas.DrawTile(Texture'Potato_T.ui_potato', Height - 8, Height - 8, 0, 0, 256, 256);
    }*/
    else
    {
        Canvas.DrawTile(NoPerkIcon, Height - 8, Height - 8, 0, 0, 256, 256);
    }

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
    if( Index >= 0 )
    {
        // used to cache the current selection so it can be displayed in the center
        // even when it isn't in the list (like when another perk filter is set)
        BuyableToDisplay = new class'GUIBuyable';
        BuyableToDisplay.ItemName           = ForSaleBuyables[Index].ItemName;
        BuyableToDisplay.ItemDescription    = ForSaleBuyables[Index].ItemDescription;
        BuyableToDisplay.ItemCategorie      = ForSaleBuyables[Index].ItemCategorie;
        BuyableToDisplay.ItemImage          = ForSaleBuyables[Index].ItemImage;
        BuyableToDisplay.ItemWeaponClass    = ForSaleBuyables[Index].ItemWeaponClass;
        BuyableToDisplay.ItemAmmoClass      = ForSaleBuyables[Index].ItemAmmoClass;
        BuyableToDisplay.ItemPickupClass    = ForSaleBuyables[Index].ItemPickupClass;
        BuyableToDisplay.ItemCost           = ForSaleBuyables[Index].ItemCost;
        BuyableToDisplay.ItemAmmoCost       = 0;
        BuyableToDisplay.ItemFillAmmoCost   = 0;
        BuyableToDisplay.ItemWeight         = ForSaleBuyables[Index].ItemWeight;
        BuyableToDisplay.ItemPower          = ForSaleBuyables[Index].ItemPower;
        BuyableToDisplay.ItemRange          = ForSaleBuyables[Index].ItemRange;
        BuyableToDisplay.ItemSpeed          = ForSaleBuyables[Index].ItemSpeed;
        BuyableToDisplay.ItemAmmoCurrent    = 0;
        BuyableToDisplay.ItemAmmoMax        = 0;
        BuyableToDisplay.ItemPerkIndex      = ForSaleBuyables[Index].ItemPerkIndex;
        BuyableToDisplay.bSaleList = true;

        if ( CanBuys[Index] == 0 )
        {
            if ( ForSaleBuyables[Index].ItemWeaponClass.Default.AppID > 0 &&
                 KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements) != none &&
                !PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC(ForSaleBuyables[Index].ItemWeaponClass.Default.AppID) )
            {
                // TODO: Play "Purchase DLC" voice clip?
            }
            else if ( ForSaleBuyables[Index].ItemWeaponClass.Default.UnlockedByAchievement != -1 &&
                      KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements) != none &&
                      KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements).Achievements[ForSaleBuyables[index].ItemWeaponClass.Default.UnlockedByAchievement].bCompleted == 1)
            {

            }
            else if ( ForSaleBuyables[Index].ItemCost > PlayerOwner().PlayerReplicationInfo.Score )
            {
                PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooExpensive, SLOT_Interface, 2.0);
            }
            else if ( ForSaleBuyables[Index].ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
            {
                PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooHeavy, SLOT_Interface, 2.0);
            }
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
     NoPerkIcon=Texture'KillingFloor2HUD.Perk_Icons.No_Perk_Icon'
     DarkRedColor=(B=96,G=96,R=96,A=255)
     TraderSoundTooExpensive=SoundGroup'KF_Trader.TooExpensive'
     TraderSoundTooHeavy=SoundGroup'KF_Trader.TooHeavy'
     GetItemHeight=KFBuyMenuSaleList.SaleItemHeight
     FontScale=FNS_Medium
     OnPreDraw=KFBuyMenuSaleList.PreDraw
}
