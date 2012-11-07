//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GUIBuyPlayerInventoryPanel extends GUIPanel;

var automated   GUIInvHeaderTabPanel            TabPanelInventoryHeader;    // Innventory list header
var             array<GUIInvBodyTabPanel>       InvBodyTabPanelArray;       // The Item rows
var             array<KFAmmunition>             FillAllAmmoAmmunitions;     // List of ammo we need for filling up all ammotypes
var             KFLevelRules                    KFLR;
var             KFLevelRules                    KFLRit;
var             bool                            bNeedsUpdate;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(Mycontroller, MyOwner);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
}

function UpDateCheck(GUIComponent Sender)
{
    if ( bNeedsUpdate )
    {
        Update();
    }
}

function Update()
{
    local float OldX, CurAmmo, MaxAmmo, GameDifficulty, FillCost, FillAllAmmoCost;
    local Inventory CurInv;
    local GUIInvBodyTabPanel NewInvTabPanel;
    local class<Ammunition> AmmoClass;
    local class<KFWeaponPickUp> WeaponItem;
    local bool bHasDual;
    local int i;

    OldX = TabPanelInventoryHeader.WinTop + 0.017000;

    if ( PlayerOwner().Pawn.Inventory == none )
    {
        log("Inventory is none!");
        return;
    }

    // Remove any old items from the components list
    for ( i = 0; i < InvBodyTabPanelArray.Length; i++ )
    {
        RemoveComponent(InvBodyTabPanelArray[i]);
    }

    // Clear the component array
    InvBodyTabPanelArray.Remove(0, InvBodyTabPanelArray.Length);

    // Clear the FillAllAmmo weapons array
    FillAllAmmoAmmunitions.Remove(0, FillAllAmmoAmmunitions.Length);

    // We need the difficulty to calculate the price
    if ( PlayerOwner().GameReplicationInfo != none )
    {
		GameDifficulty = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).GameDiff;
	}

    // Let's build the list of the stiff we already have in our inevntory
    for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
        if ( CurInv.IsA('KFAmmunition') )
        {
            // Store the weapon for later use (FillAllAmmoButton)
            FillAllAmmoAmmunitions.Insert(0, 1);
            FillAllAmmoAmmunitions[0] = KFAmmunition(CurInv);

            continue;
        }

        // We do not want ammunition to be a seperate item in the list
        if ( CurInv.IsA('KFWeapon') )
        {
            // if we already own dualies, we do not need the single 9mm in the list
            if ( bHasDual && KFWeapon(CurInv).ItemName == "9mm Tactical" )
            {
                continue;
            }

            NewInvTabPanel = GUIInvBodyTabPanel(AddComponent("KFGUI.GUIInvBodyTabPanel"));
            NewInvTabPanel.WinHeight = 0.080000;
            NewInvTabPanel.bBoundToParent = true;
            NewInvTabPanel.bScaleToParent = true;

            GUILabel(NewInvTabPanel.Controls[0]).Caption = CurInv.ItemName;
            GUILabel(NewInvTabPanel.Controls[0]).TextAlign = TXTA_Left;
            GUILabel(NewInvTabPanel.Controls[0]).TextFont = "UT2SmallFont";
            GUILabel(NewInvTabPanel.Controls[0]).FontScale = FNS_Small;

            // Melee weapons do not use ammo, so no need for the buy clip / fill ammo buttons
            if ( !CurInv.IsA('KFMeleeGun') )
            {
                KFWeapon(CurInv).GetAmmoCount(MaxAmmo, CurAmmo);
                AmmoClass = KFWeapon(CurInv).default.FireModeClass[0].default.AmmoClass;

                GUILabel(NewInvTabPanel.Controls[1]).Caption = int(CurAmmo) $ "/" $ int(MaxAmmo);
                GUILabel(NewInvTabPanel.Controls[1]).TextFont = "UT2SmallFont";
                GUILabel(NewInvTabPanel.Controls[1]).FontScale = FNS_Small;

                foreach PlayerOwner().DynamicActors(class'KFLevelRules', KFLRit)
	            {
                    KFLR = KFLRit;
                    Break;
	            }

                for( i = 0; i < KFLR.MAX_BUYITEMS; ++i )
	            {
	               if ( KFLR.ItemForSale[i] != none )
                   {
                        // If we got the weapon in the inventory, store the corresponding weapon pickup for later use
                        if ( KFWeapon(CurInv).default.PickupClass == class<KFWeaponPickup>(KFLR.ItemForSale[i]) )
                        {
                            WeaponItem = class<KFWeaponPickup>(KFLR.ItemForSale[i]);

                            // Dualies?
                            if ( WeaponItem.default.ItemName == "Dual 9mms" )
                            {
                                bHasDual = true;
                            }

                            break;
                        }
                    }
                }

                // Single Clip Button
                if ( CurAmmo >= MaxAmmo )
                {
                    // Ammo is at 100%
                    GUIInvButton(NewInvTabPanel.Controls[2]).Caption = "100%";
                    GUIInvButton(NewInvTabPanel.Controls[2]).bAcceptsInput = false;
                }
                else if ( PlayerOwner().PlayerReplicationInfo.Score < WeaponItem.default.AmmoCost )
                {
                    // Not enough money
                    GUIInvButton(NewInvTabPanel.Controls[2]).Caption = "Low Cash";
                    GUIInvButton(NewInvTabPanel.Controls[2]).bAcceptsInput = false;

                    // If we do not even have enough money to buy a single clip we do not want to show the Fill Up All Button
                    FillAllAmmoCost = -100000.f;
                }
                else
                {
                    // Set the ammo clip price and store the ammopickup class
                    GUIInvButton(NewInvTabPanel.Controls[2]).Caption =  "£" $ string(WeaponItem.default.AmmoCost);
                    GUIInvButton(NewInvTabPanel.Controls[2]).Inv = KFWeapon(CurInv).GetAmmoClass(0);
                    GUIInvButton(NewInvTabPanel.Controls[2]).OnClick = DoBuyClip;
                }

                // Fill Up Ammo
                FillCost = (MaxAmmo - CurAmmo) * ((WeaponItem.default.AmmoCost) / KFWeapon(CurInv).default.MagCapacity);

                if ( CurAmmo >= MaxAmmo )
                {
                    // Ammo is at 100%
                    GUIInvButton(NewInvTabPanel.Controls[3]).Caption = "100%";
                    GUIInvButton(NewInvTabPanel.Controls[3]).bAcceptsInput = false;
                }
                else if ( PlayerOwner().PlayerReplicationInfo.Score >= int(FillCost) )
                {
                    // Enough money
                    GuiInvButton(NewInvTabPanel.Controls[3]).Caption = "£" $ string(int(FillCost));
                    GuiInvButton(NewInvTabPanel.Controls[3]).Inv = KFWeapon(CurInv).GetAmmoClass(0);
                    GuiInvButton(NewInvTabPanel.Controls[3]).OnClick = DoFillOneAmmo;
                    FillAllAmmoCost += FillCost;
                }
                else
                {
                    // Not enough money to fill up ammo for this weapon.
                    GUIInvButton(NewInvTabPanel.Controls[3]).Caption = "Low Cash";
                    GUIInvButton(NewInvTabPanel.Controls[3]).bAcceptsInput = false;

                    // If we do not have enough money to fill up a single weapons we do not want to show the Fill Up All Button
                    FillAllAmmoCost = -100000.f;
                }
            }
            else
            {
                // Melees don't have ammo
                GUILabel(NewInvTabPanel.Controls[1]).Caption = "";
            }

            // Default Inventory can't be sold
            if ( KFWeapon(CurInv).default.bKFNeverThrow )
            {
                GUILabel(NewInvTabPanel.Controls[4]).bVisible = false;
                GUILabel(NewInvTabPanel.Controls[4]).bAcceptsInput = false;
                GUIInvButton(NewInvTabPanel.Controls[5]).bVisible = false;
                GUIInvButton(NewInvTabPanel.Controls[5]).bAcceptsInput = false;
            }
            else
            {
                foreach PlayerOwner().DynamicActors(class'KFLevelRules', KFLRit)
	            {
                    KFLR = KFLRit;

                    break;
	            }

                for( i = 0; i < KFLR.MAX_BUYITEMS; ++i )
	            {
	               if ( KFLR.ItemForSale[i] != none )
                   {
                        // If we got the weapon in the inventory, store the corresponding weapon pickup for later use
                        if ( KFWeapon(CurInv).default.PickupClass == class<KFWeaponPickup>(KFLR.ItemForSale[i]) )
                        {
                            WeaponItem = class<KFWeaponPickup>(KFLR.ItemForSale[i]);

                            break;
                        }
                    }
                }

                GUILabel(NewInvTabPanel.Controls[4]).Caption =  "£" $ string(int(WeaponItem.default.Cost * 0.75));
                GUIInvButton(NewInvTabPanel.Controls[5]).Caption = "Sell";
                GUIInvButton(NewInvTabPanel.Controls[5]).Inv = CurInv.class;
                GUIInvButton(NewInvTabPanel.Controls[5]).OnClick = DoSellItem;
            }

            // No ammo buttons for the melees
            if ( CurInv.IsA('KFMeleeGun') )
            {
                for ( i = 1; i <= 3; i++ )
                {
                    NewInvTabPanel.Controls[i].bVisible = false;
                    NewInvTabPanel.Controls[i].bAcceptsInput = false;
                }
            }

            NewInvTabPanel.WinTop = OldX + 0.080000;
            NewInvTabPanel.WinLeft = TabPanelInventoryHeader.WinLeft;
            NewInvTabPanel.WinHeight = TabPanelInventoryHeader.WinHeight;
            NewInvTabPanel.WinWidth = TabPanelInventoryHeader.WinWidth;

            OldX = NewInvTabPanel.WinTop;

            InvBodyTabPanelArray.Insert(0, 1);
            InvBodyTabPanelArray[0] = NewInvTabPanel;
        }
    }

    bNeedsUpdate = false;

    //SetFocus(TabPanelInventoryHeader);

    // Fill All Ammo
    if ( FillAllAmmoCost < 1 )
    {
        return;
    }

    NewInvTabPanel = GUIInvBodyTabPanel(AddComponent("KFGUI.GUIInvBodyTabPanel"));
    NewInvTabPanel.bBoundToParent = true;
    NewInvTabPanel.bScaleToParent = true;
    NewInvTabPanel.WinTop = OldX + 0.130000;
    NewInvTabPanel.WinLeft = TabPanelInventoryHeader.WinLeft;
    NewInvTabPanel.WinHeight = TabPanelInventoryHeader.WinHeight;
    NewInvTabPanel.WinWidth = TabPanelInventoryHeader.WinWidth;
    GUILabel(NewInvTabPanel.Controls[0]).TextAlign = TXTA_Left;
    GUILabel(NewInvTabPanel.Controls[0]).TextFont = "UT2SmallFont";
    GUILabel(NewInvTabPanel.Controls[0]).FontScale = FNS_Small;
    GUILabel(NewInvTabPanel.Controls[0]).Caption = "Fill Up Ammo";
    GUILabel(NewInvTabPanel.Controls[1]).bVisible = false;
    GUIButton(NewInvTabPanel.Controls[2]).bVisible = false;
    GUIButton(NewInvTabPanel.Controls[2]).bAcceptsInput = false;

    if ( PlayerOwner().PlayerReplicationInfo.Score >= int(FillAllAmmoCost) )
    {
        GUIButton(NewInvTabPanel.Controls[3]).Caption =  "£" $ string(int(FillAllAmmoCost));
        GUIButton(NewInvTabPanel.Controls[3]).OnClick = DoFillAllAmmo;
    }
    else if ( PlayerOwner().PlayerReplicationInfo.Score >= FindCheapestAmmo() )
    {
        GUIButton(NewInvTabPanel.Controls[3]).Caption = "Auto Fill";
        GUIButton(NewInvTabPanel.Controls[3]).OnClick = DoFillAllAmmo;
    }
    else
    {
        GUIButton(NewInvTabPanel.Controls[3]).Caption = "Low Cash";
        GUIButton(NewInvTabPanel.Controls[3]).bAcceptsInput = false;
    }

    // Just filling up all weapons, can't sell
    GUILabel(NewInvTabPanel.Controls[4]).bVisible = false;
    GUIButton(NewInvTabPanel.Controls[5]).bVisible = false;
    GUIButton(NewInvTabPanel.Controls[5]).bAcceptsInput = false;

    // Add this last tab bar to the component list
    InvBodyTabPanelArray.Insert(0, 1);
    InvBodyTabPanelArray[0] = NewInvTabPanel;
}

// Fills the ammo of all weapons in the inv to the max
function bool DoFillAllAmmo(GUIComponent Sender)
{
    local int i, j, CheapestAmmo;
    local bool bAlreadyBoughtFrag;

    CheapestAmmo = FindCheapestAmmo();

    for ( i = 0; i < 999; i++ )
    {
        for ( j = 0; j < FillAllAmmoAmmunitions.Length; j++ )
        {
            // We do not want to set the priority on grenades, so let's just buy one every other buy cycle
            if ( FillAllAmmoAmmunitions[j].IsA('FragAmmo') && bAlreadyBoughtFrag )
            {
                bAlreadyBoughtFrag = false;

                continue;
            }

            if ( PlayerOwner().PlayerReplicationInfo.Score >= FindAmmoCost(FillAllAmmoAmmunitions[j].Class) )
            {
                KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(FillAllAmmoAmmunitions[j].Class, false);

                if ( FillAllAmmoAmmunitions[j].IsA('FragAmmo') )
                {
                     bAlreadyBoughtFrag = true;
                }
            }
            else
            {
                continue;
            }
        }

        if ( PlayerOwner().PlayerReplicationInfo.Score < CheapestAmmo )
        {
            break;
        }
    }

    // refresh the menu
    bNeedsUpdate = true;

    return true;
}

function int FindCheapestAmmo()
{
    local Inventory CurInv;
    local int CurrentCheapest, CurrentCost;

    CurrentCheapest = 99999;

    for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
        if ( CurInv.IsA('KFAmmunition') )
        {
            CurrentCost = FindAmmoCost(KFAmmunition(CurInv).Class);
        }

        if ( CurrentCost < CurrentCheapest )
        {
            CurrentCheapest = CurrentCost;
        }
	}

    return CurrentCheapest;
}

function int FindAmmoCost(Class<Ammunition> AClass)
{
    local Inventory CurInv;
    local Ammunition MyAmmo;
	local KFWeapon MyWeapon;

    for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
        if( CurInv.Class == AClass )
        {
            MyAmmo = Ammunition(CurInv);
        }
        else if ( MyWeapon == None && KFWeapon(CurInv) != None && (Weapon(CurInv).AmmoClass[0]==AClass || Weapon(CurInv).AmmoClass[1]==AClass) )
        {
        	MyWeapon = KFWeapon(CurInv);
        }
    }

    return Class<KFWeaponPickup>(MyWeapon.PickupClass).Default.AmmoCost;
}

function bool DoFillOneAmmo(GUIComponent Sender)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(class<Ammunition>(GUIInvButton(Sender).Inv), false);

        // refresh the menu
        bNeedsUpdate = true;
    }

    return true;
}

function bool DoBuyClip(GUIComponent Sender)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(class<Ammunition>(GUIInvButton(Sender).Inv), true);

        // refresh the menu
        bNeedsUpdate = true;
    }

    return true;
}

function bool DoSellItem(GUIComponent Sender)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerSellWeapon(class<Weapon>(GUIInvButton(Sender).Inv));

        // refresh the menu
        bNeedsUpdate = true;
    }

    return true;
}

defaultproperties
{
     Begin Object Class=GUIInvHeaderTabPanel Name=InventoryHeaderTabPanel
         WinHeight=0.080000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     TabPanelInventoryHeader=GUIInvHeaderTabPanel'KFGui.GUIBuyPlayerInventoryPanel.InventoryHeaderTabPanel'

}
