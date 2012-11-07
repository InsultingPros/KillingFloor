//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GUIBuyForSalePanel extends GUIPanel;

var automated   GUIForSaleHeaderPanel           PanelForSaleHeader;         // for Sale list list header
var             array<GUIForSaleBodyPanel>      ForSaleBodyPanelArray;      // The Item rows

var             KFLevelRules                    KFLR;
var             KFLevelRules                    KFLRit;

var             bool                            bNeedsUpdate;

var             color                           RedColor;
var             color                           DarkRedColor;
var             color                           GreenColor;
var             color                           GrayColor;

var             sound                           SellSound;
var             sound                           BuySound;

/*
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
    local float OldX, GameDifficulty;
    local GUIForSaleBodyPanel NewForSalePanel;
    local int i, j;
    local class<KFVeterancyTypes> PlayerVeterancy;
    local KFSteamStatsAndAchievements KFStatsAndAchievements;

    OldX = PanelForSaleHeader.WinTop + 0.00100;

    // Remove any old items from the components list
    for ( i = 0; i < ForSaleBodyPanelArray.Length; i++ )
    {
        RemoveComponent(ForSaleBodyPanelArray[i]);
    }

    // Clear the component array
    ForSaleBodyPanelArray.Remove(0, ForSaleBodyPanelArray.Length);

    // We need the difficulty to calculate the price
    if ( PlayerOwner().GameReplicationInfo != none )
    {
		GameDifficulty = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).GameDiff;
	}

    // Grab the items for sale
    foreach PlayerOwner().DynamicActors(class'KFLevelRules', KFLRit)
    {
        KFLR = KFLRit;
        Break;
	}

	// Grab Players Veterancy for quick reference
	if ( KFPlayerController(PlayerOwner()) != none && KFPlayerController(PlayerOwner()).SelectedVeterancy != none )
	{
		PlayerVeterancy = KFPlayerController(PlayerOwner()).SelectedVeterancy;
		KFStatsAndAchievements = KFSteamStatsAndAchievements(KFPlayerController(PlayerOwner()).SteamStatsAndAchievements);
	}
	else
	{
		PlayerVeterancy = class'KFVeterancyTypes';
		KFStatsAndAchievements = KFSteamStatsAndAchievements(PlayerOwner().PlayerReplicationInfo.SteamStatsAndAchievements);
	}

    // Let's build the list of buyable items
    for ( i = 0; i < KFLR.MAX_CATEGORY; ++i )
    {
        // Categroy header
        NewForSalePanel = GUIForSaleBodyPanel(AddComponent("KFGUI.GUIForSaleBodyPanel"));
        NewForSalePanel.bBoundToParent = true;
        NewForSalePanel.bScaleToParent = true;
        NewForSalePanel.WinHeight = 0.040000;
        NewForSalePanel.WinTop = OldX + 0.0500000;
        NewForSalePanel.bVisible = true;

        GUILabel(NewForSalePanel.Controls[0]).Caption = " " $ KFLR.EquipmentCategories[i].EquipmentCategoryName;
        GUILabel(NewForSalePanel.Controls[0]).ShadowOffsetX = 1.5;
        GUILabel(NewForSalePanel.Controls[0]).ShadowOffsetY = 1.5;
        GUILabel(NewForSalePanel.Controls[0]).ShadowColor = DarkRedColor;
        GUILabel(NewForSalePanel.Controls[0]).BackColor = GrayColor;
        GUILabel(NewForSalePanel.Controls[0]).bTransparent = false;
        GUILabel(NewForSalePanel.Controls[0]).WinWidth = 1.00000;
        GUILabel(NewForSalePanel.Controls[1]).BackColor = GrayColor;

        NewForSalePanel.Controls[1].bVisible = false;
        NewForSalePanel.Controls[2].bVisible = false;
        NewForSalePanel.Controls[2].bAcceptsInput = false;

        ForSaleBodyPanelArray.Insert(0, 1);
        ForSaleBodyPanelArray[0] = NewForSalePanel;

        OldX = NewForSalePanel.WinTop - 0.001000;

        // Add category's items
        for ( j = 0; j < KFLR.MAX_BUYITEMS; j++ )
        {
            if ( KFLR.ItemForSale[j] != none )
            {
                // Let's see if it is a vest or aid kit (both are no weapon pickup)
                if ( (class<Vest>(KFLR.ItemForSale[j]) != none || class<FirstAidKit>(KFLR.ItemForSale[j]) != none)  &&
                     (class'Vest'.default.EquipmentCategoryID == KFLR.EquipmentCategories[i].EquipmentCategoryID ||
                      class'FirstAidKit'.default.EquipmentCategoryID == KFLR.EquipmentCategories[i].EquipmentCategoryID) )
                {
                    NewForSalePanel = GUIForSaleBodyPanel(AddComponent("KFGUI.GUIForSaleBodyPanel"));
                    NewForSalePanel.bBoundToParent = true;
                    NewForSalePanel.bScaleToParent = true;
                    NewForSalePanel.WinHeight = 0.039000;
                    NewForSalePanel.WinTop = OldX + 0.041000;

                    GUISaleLabel(NewForSalePanel.Controls[0]).bAcceptsInput = true;

                    // Vest
                    if ( class<Vest>(KFLR.ItemForSale[j]) != none )
				    {
                        GUISaleLabel(NewForSalePanel.Controls[0]).Caption = class'BuyableVest'.default.ItemName;
                        GUILabel(NewForSalePanel.Controls[1]).TextColor = GreenColor;
                        GUILabel(NewForSalePanel.Controls[1]).Caption = "£" $ string(int(class'BuyableVest'.default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, class'Vest')));

                        if ( PlayerOwner().PlayerReplicationInfo.Score < class'BuyableVest'.default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, class'Vest') )
                        {
                            GUILabel(NewForSalePanel.Controls[1]).TextColor = RedColor;
                            GUIInvButton(NewForSalePanel.Controls[2]).Caption = "Low Cash";
                            GUIInvButton(NewForSalePanel.Controls[2]).bAcceptsInput = false;
                        }
                        else if ( KFHumanPawn(PlayerOwner().Pawn).CurrentWeight + class'BuyableVest'.default.Weight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
                        {
                            GUILabel(NewForSalePanel.Controls[1]).TextColor = RedColor;
                            GUIInvButton(NewForSalePanel.Controls[2]).Caption = "Weight";
                            GUIInvButton(NewForSalePanel.Controls[2]).bAcceptsInput = false;
                        }
                        else if ( KFPawn(PlayerOwner().Pawn).ShieldStrength == 100 )
                        {
                            GUILabel(NewForSalePanel.Controls[1]).TextColor = RedColor;
                            GUIInvButton(NewForSalePanel.Controls[2]).Caption = "100% Armor";
                            GUIInvButton(NewForSalePanel.Controls[2]).bAcceptsInput = false;
                        }
                        else
                        {
                            GUIInvButton(NewForSalePanel.Controls[2]).Caption = "Buy";
                            GUIInvButton(NewForSalePanel.Controls[2]).OnClick = DoBuyKevlar;
                        }

                        GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo = new class'BuyableVest';
                        GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo.cost = int(class'BuyableVest'.default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, class'Vest'));
                    }

                    // First Aid kit
                    if ( class<FirstAidKit>(KFLR.ItemForSale[j]) != none )
				    {
                        GUISaleLabel(NewForSalePanel.Controls[0]).Caption = class'BuyableFirstAidKit'.default.ItemName;
                        GUILabel(NewForSalePanel.Controls[1]).TextColor = GreenColor;
                        GUILabel(NewForSalePanel.Controls[1]).Caption = "£" $ string(int(class'BuyableFirstAidKit'.default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, class'FirstAidKit')));

                        if ( PlayerOwner().PlayerReplicationInfo.Score < class'BuyableFirstAidKit'.default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, class'FirstAidKit') )
                        {
                            GUILabel(NewForSalePanel.Controls[1]).TextColor = RedColor;
                            GUIInvButton(NewForSalePanel.Controls[2]).Caption = "Low Cash";
                            GUIInvButton(NewForSalePanel.Controls[2]).bAcceptsInput = false;
                        }
                        else if ( KFHumanPawn(PlayerOwner().Pawn).CurrentWeight + class'BuyableFirstAidKit'.default.Weight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
                        {
                            GUILabel(NewForSalePanel.Controls[1]).TextColor = RedColor;
                            GUIInvButton(NewForSalePanel.Controls[2]).Caption = "To Heavy";
                            GUIInvButton(NewForSalePanel.Controls[2]).bAcceptsInput = false;
                        }
                        else if ( KFPawn(PlayerOwner().Pawn).Health == 100 )
                        {
                            GUILabel(NewForSalePanel.Controls[1]).TextColor = RedColor;
                            GUIInvButton(NewForSalePanel.Controls[2]).Caption = "100% Health";
                            GUIInvButton(NewForSalePanel.Controls[2]).bAcceptsInput = false;
                        }
                        else
                        {
                            GUIInvButton(NewForSalePanel.Controls[2]).Caption = "Buy";
                            GUIInvButton(NewForSalePanel.Controls[2]).OnClick = DoBuyFirstAid;
                        }

                        GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo = new class'BuyableFirstAidKit';
                        GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo.cost = int(class'BuyableFirstAidKit'.default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, class'FirstAidKit'));
                    }

                    OldX = NewForSalePanel.WinTop;

                    GUISaleLabel(NewForSalePanel.Controls[0]).OnClick = UpdateInfo;

                    ForSaleBodyPanelArray.Insert(0, 1);
                    ForSaleBodyPanelArray[0] = NewForSalePanel;
                }

                // Now the actual weapons and not ammo, vest or aid kit
                if ( class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType) == none || KFLR.ItemForSale[j].IsA('KFAmmunition') || class<KFWeapon>(KFLR.ItemForSale[j].default.InventoryType).default.bKFNeverThrow ||
                     IsInInventory(KFLR.ItemForSale[j]) || class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.EquipmentCategoryID != KFLR.EquipmentCategories[i].EquipmentCategoryID )
                {
                    continue;
                }

                NewForSalePanel = GUIForSaleBodyPanel(AddComponent("KFGUI.GUIForSaleBodyPanel"));
                NewForSalePanel.bBoundToParent = true;
                NewForSalePanel.bScaleToParent = true;
                NewForSalePanel.WinHeight = 0.039000;
                NewForSalePanel.WinTop = OldX + 0.0410000;

                GUISaleLabel(NewForSalePanel.Controls[0]).bAcceptsInput = true;
                GUISaleLabel(NewForSalePanel.Controls[0]).Caption = class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.ItemName;

                GUILabel(NewForSalePanel.Controls[1]).TextColor = GreenColor;
                GUILabel(NewForSalePanel.Controls[1]).Caption = "£" $ string(int(class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, KFLR.ItemForSale[j])));

                if ( PlayerOwner().PlayerReplicationInfo.Score < class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, KFLR.ItemForSale[j]) )
                {
                    GUILabel(NewForSalePanel.Controls[1]).TextColor = RedColor;
                    GUIInvButton(NewForSalePanel.Controls[2]).Caption = "Low Cash";
                    GUIInvButton(NewForSalePanel.Controls[2]).bAcceptsInput = false;
                }
                else if ( KFHumanPawn(PlayerOwner().Pawn).CurrentWeight + class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.Weight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )
                {
                    GUILabel(NewForSalePanel.Controls[1]).TextColor = RedColor;
                    GUIInvButton(NewForSalePanel.Controls[2]).Caption = "To Heavy";
                    GUIInvButton(NewForSalePanel.Controls[2]).bAcceptsInput = false;
                }
                else
                {
                    GUIInvButton(NewForSalePanel.Controls[2]).Caption = "Buy";
                    GUIInvButton(NewForSalePanel.Controls[2]).Inv = KFLR.ItemForSale[j].default.InventoryType;
                    GUIInvButton(NewForSalePanel.Controls[2]).OnClick = DoBuy;
                }

                // Add the relevant info for the info panel
                GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo = new class'BuyableWeapon';
                GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo.cost = int(class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.Cost * PlayerVeterancy.static.GetCostScaling(KFStatsAndAchievements, KFLR.ItemForSale[j]));
                BuyableWeapon(GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo).PowerValue = class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.PowerValue;
				BuyableWeapon(GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo).RangeValue = class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.RangeValue;
				BuyableWeapon(GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo).SpeedValue = class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.SpeedValue;
				GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo.Description = class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.Description;
				GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo.ItemName = class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.ItemName;
				GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo.showMesh = class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.ShowMesh;
				GUISaleLabel(NewForSalePanel.Controls[0]).SaleItemInfo.relatedInventory = class<KFWeaponPickup>(KFLR.ItemForSale[j]).default.InventoryType;

                GUISaleLabel(NewForSalePanel.Controls[0]).OnClick = UpdateInfo;

                OldX = NewForSalePanel.WinTop;
                ForSaleBodyPanelArray.Insert(0, 1);
                ForSaleBodyPanelArray[0] = NewForSalePanel;
            }
        }
    }

    bNeedsUpdate = false;
}

// Sends new item to the info pane;
function bool UpdateInfo(GUIComponent Sender)
{
//    GUIBuyMenu(OwnerPage()).NewInfo(GUISaleLabel(Sender).SaleItemInfo);

    return true;
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

function bool DoBuy(GUIComponent Sender)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyWeapon(Class<Weapon>(GUIInvButton(Sender).Inv));
        BuySound = GUIInvButton(Sender).Inv.default.PickupClass.default.PickupSound;
        PlayerOwner().Pawn.PlaySound(BuySound,SLOT_Interface,255.0,,120);
    }

    bNeedsUpdate = true;

    return true;
}

function bool DoBuyKevlar(GUIComponent Sender)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyKevlar();
    }

    bNeedsUpdate = true;

    return true;
}

function bool DoBuyFirstAid(GUIComponent Sender)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyFirstAid();
    }

    bNeedsUpdate = true;

    return true;
}
*/

defaultproperties
{
}
