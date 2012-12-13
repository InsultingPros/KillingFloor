//=============================================================================
// The actual trader menu
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================
class KFTab_BuyMenu extends UT2K4TabPanel;

var automated 	GUIImage						InvBG;
var automated	GUIButton						SaleButton;
var automated 	GUIImage						MagBG;
var automated 	GUIImage						FillBG;
var	automated	GUILabel						MagLabel;
var	automated	GUILabel						FillLabel;
var	automated 	KFBuyMenuInvListBox				InvSelect;

var automated 	GUIImage						MoneyBG;
var	automated	GUILabel						SelectedItemLabel;
var automated 	GUIImage						ItemBG;

var automated	GUIBuyWeaponInfoPanel			ItemInfo;

var automated 	GUIImage						SaleBG;
var automated	GUIButton						PurchaseButton;
var	automated 	KFBuyMenuSaleListBox			SaleSelect;

var automated	GUIButton						AutoFillButton;
var automated	GUIButton						ExitButton;

var automated 	GUIImage						InfoBG;
var automated 	GUIScrollTextBox				InfoScrollText;

var	automated	GUILabel						MoneyLabel;
var automated 	GUIImage						BankNote;

var	automated	GUILabel						SaleValueLabel;
var automated 	GUIImage						SaleValueLabelBG;

var localized	string							InfoText[5];
var	localized	string							AutoFillString;
var	localized	string							MoneyCaption;
var	localized	string							SaleValueCaption;
var	localized	string							RepairBodyArmorCaption;
var	localized	string							BuyBodyArmorCaption;

var             array<KFAmmunition>             MyAmmos;     // List of ammo we need for filling up all ammotypes
var				GUIBuyable						TheBuyable;
var				GUIBuyable						LastBuyable;

var 			float							AutoFillCost;
var				int								UpdateCount;
var				class<Pickup> 					OldPickupClass;
var 			bool							bDidBuyableUpdate;

var				SoundGroup						TraderSoundTooExpensive;
var				bool							bClosed;

var automated 	GUIImage						AmmoExitBG;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	InvSelect.List.OnChange = InvChange;
	InvSelect.List.OnDblClick = InvDblClick;
	InvSelect.List.OnBuyClipClick = DoBuyClip;
	InvSelect.List.OnFillAmmoClick = DoFillOneAmmo;
	InvSelect.List.OnBuyVestClick = DoBuyKevlar;

	SaleSelect.List.OnChange = SaleChange;
	SaleSelect.List.OnDblClick = SaleDblClick;

	InfoScrollText.SetContent(InfoText[0]);

	UpdateBuySellButtons();
	UpdateAutoFillAmmo();
	SetTimer(0.05, true);

	bClosed = false;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);

	bClosed = true;

	// Clear the arrays
    MyAmmos.Remove(0, MyAmmos.Length);
    TheBuyable = none;
    LastBuyable = none;
}

function ShowPanel(bool bShow)
{
	local int i, PistolIndex;

	super.ShowPanel(bShow);

	bClosed = false;

	for ( i = 0; i < InvSelect.List.MyBuyables.Length; i++ )
	{
		if ( InvSelect.List.MyBuyables[i].ItemWeaponClass == class'Single' ||
			 InvSelect.List.MyBuyables[i].ItemWeaponClass == class'Dualies' )
		{
			PistolIndex = i;
			break;
		}
	}

	TheBuyable = InvSelect.List.MyBuyables[i];
	InvSelect.List.Index = i;

	if ( KFPlayerController(PlayerOwner()) != none )
	{
		KFPlayerController(PlayerOwner()).bDoTraderUpdate = true;
	}

	LastBuyable = TheBuyable;

	InvSelect.SetPosition(InvBG.WinLeft + 7.0 / float(Controller.ResX),
						  InvBG.WinTop + 55.0 / float(Controller.ResY),
						  InvBG.WinWidth - 15.0 / float(Controller.ResX),
						  InvBG.WinHeight - 45.0 / float(Controller.ResY),
						  true);

	SaleSelect.SetPosition(SaleBG.WinLeft + 7.0 / float(Controller.ResX),
						   SaleBG.WinTop + 55.0 / float(Controller.ResY),
						   SaleBG.WinWidth - 15.0 / float(Controller.ResX),
						   SaleBG.WinHeight - 63.0 / float(Controller.ResY),
						   true);
}

function Timer()
{
	MoneyLabel.Caption = MoneyCaption $ int(PlayerOwner().PlayerReplicationInfo.Score);
	UpdateCheck();
}

function UpdateCheck()
{
	if ( KFPlayerController(PlayerOwner()).bDoTraderUpdate )
	{
		UpdateCount = 0;
		SetTimer(0.1, true);
	}

	if ( UpdateCount < 10 )
	{
		UpdateAll();
		UpdateCount++;
	}
	else
	{
		SetTimer(0.05, true);
	}
}

function UpdateAll()
{
	KFPlayerController(PlayerOwner()).bDoTraderUpdate = false;

	InvSelect.List.UpdateMyBuyables();
	SaleSelect.List.UpdateForSaleBuyables();

	GetUpdatedBuyable();

	UpdatePanel();
}

function UpdateBuySellButtons()
{
	if ( InvSelect.List.Index < 0 || (!TheBuyable.bSaleList && !TheBuyable.bSellable))
	{
		SaleButton.DisableMe();
	}
	else
	{
		SaleButton.EnableMe();
	}

	if ( SaleSelect.List.Index < 0 || (TheBuyable.bSaleList && TheBuyable.ItemCost > PlayerOwner().PlayerReplicationInfo.Score))
	{
		PurchaseButton.DisableMe();
	}
	else
	{
		PurchaseButton.EnableMe();
	}
}


function InvChange(GUIComponent Sender)
{
	SaleSelect.List.Index = -1;

	TheBuyable = InvSelect.GetSelectedBuyable();

	GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = 0;
	OnAnychange();
}

function bool InvDblClick(GUIComponent Sender)
{
	if ( InvSelect.List.MouseOverXIndex == 0 )
	{
		SaleSelect.List.Index = -1;

		if ( InvSelect.GetSelectedBuyable() != none )
		{
			TheBuyable = InvSelect.GetSelectedBuyable();
		}

		GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = 0;

		if ( TheBuyable.bSellable )
		{
			DoSell();
			TheBuyable = none;
		}
		else
		{
			return false;
		}

		OnAnychange();

		return true;
	}

	return false;
}

function SaleChange(GUIComponent Sender)
{
	InvSelect.List.Index = -1;

	TheBuyable = SaleSelect.GetSelectedBuyable();

	GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = TheBuyable.ItemWeight;
	OnAnychange();
}

function bool IsLocked(GUIBuyable buyable)
{
    local bool hasAchievement, hasAppID, canBuy;

	if( KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements) != none )
	{
        if( TheBuyable.ItemWeaponClass.Default.UnlockedByAchievement != -1 )
        {
            hasAchievement = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements).Achievements[TheBuyable.ItemWeaponClass.Default.UnlockedByAchievement].bCompleted == 1;
        }
        if( TheBuyable.ItemWeaponClass.Default.AppID > 0 )
        {
            hasAppID = PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC(TheBuyable.ItemWeaponClass.Default.AppID);
        }
	}

    if( TheBuyable.ItemWeaponClass.Default.AppID > 0 &&
        TheBuyable.ItemWeaponClass.Default.UnlockedByAchievement != -1 )
    {
        canBuy = hasAchievement || hasAppId;
    }
    else if( TheBuyable.ItemWeaponClass.Default.AppID > 0 )
    {
        canBuy = hasAppId;
    }
    else if( TheBuyable.ItemWeaponClass.Default.UnlockedByAchievement != -1 )
    {
        canBuy = hasAchievement;
    }
    else
    {
        canBuy = true;
    }

    return !canBuy;
}

function bool SaleDblClick(GUIComponent Sender)
{

	InvSelect.List.Index = -1;

	TheBuyable = SaleSelect.GetSelectedBuyable();

	GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = TheBuyable.ItemWeight;





	if ( TheBuyable.ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight <= KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight &&
		 TheBuyable.ItemCost <= PlayerOwner().PlayerReplicationInfo.Score && !IsLocked(TheBuyable))
	{
		DoBuy();
   		TheBuyable = none;
	}

	OnAnychange();

	return false;
}

function OnAnychange()
{
    LastBuyable = TheBuyable;
	ItemInfo.Display(TheBuyable);
	SetInfoText();
	UpdatePanel();
	UpdateBuySellButtons();
}

function GetUpdatedBuyable(optional bool bSetInvIndex)
{
	local int i;

	if ( LastBuyable == none )
	{
		return;
	}

	InvSelect.List.UpdateMyBuyables();

	for ( i = 0; i < InvSelect.List.MyBuyables.Length; i++ )
	{
		if ( InvSelect.List.MyBuyables[i] != none && LastBuyable.ItemName == InvSelect.List.MyBuyables[i].ItemName )
		{
			TheBuyable = InvSelect.List.MyBuyables[i];
			break;
		}
	}

	if ( bSetInvIndex )
	{
		InvSelect.List.Index = i;
	}
}

function UpdateAutoFillAmmo()
{
	local Inventory CurInv;

	if ( PlayerOwner().Pawn.Inventory == none )
	{
		return;
	}

	InvSelect.List.UpdateMyBuyables();

	// Clear the MyAmmo array
    MyAmmos.Remove(0, MyAmmos.Length);

	if ( !bClosed )
    {
		// Let's build the list of the stuff we already have in our inevntory
	    for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	    {
	        if ( CurInv.IsA('KFAmmunition') )
	        {
	            // Store the weapon for later use (FillAllAmmoButton)
	            MyAmmos.Insert(0, 1);
	            MyAmmos[0] = KFAmmunition(CurInv);
	        }
	    }
	}

    AutoFillButton.Caption = AutoFillString @ "(£" @ int(InvSelect.List.AutoFillCost)$")";

    if ( int(InvSelect.List.AutoFillCost) < 1 )
    {
		AutoFillButton.DisableMe();
	}
	else
	{
		AutoFillButton.EnableMe();
	}
}

// Fills the ammo of all weapons in the inv to the max
function DoFillAllAmmo()
{
    local int i, j, CheapestAmmo;

    CheapestAmmo = FindCheapestAmmo();

	if ( PlayerOwner().PlayerReplicationInfo.Score < CheapestAmmo )
	{
		PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooExpensive, SLOT_Interface, 2.0);
		return;
	}

	for ( i = 0; i < 50; i++ )
    {
        for ( j = 0; j < MyAmmos.Length; j++ )
        {
            // We do not want to set the priority on grenades, so let's just buy one every other buy cycle
            if ( MyAmmos[j].IsA('FragAmmo') && MyAmmos[j].IsA('PipeBombAmmo') )
            {
				continue;
            }

            if ( PlayerOwner().PlayerReplicationInfo.Score >= FindAmmoCost(MyAmmos[j].Class) )
            {
                KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(MyAmmos[j].Class, false);
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

	for ( j = 0; j < MyAmmos.Length; j++ )
	{
		if ( !MyAmmos[j].IsA('FragAmmo') )
		{
			continue;
		}
		else if ( PlayerOwner().PlayerReplicationInfo.Score >= FindAmmoCost(MyAmmos[j].Class) )
		{
		    KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(MyAmmos[j].Class, false);
		}
		else
		{
			break;
		}
	}

	for ( j = 0; j < MyAmmos.Length; j++ )
	{
		if ( !MyAmmos[j].IsA('PipeBombAmmo') )
		{
			continue;
		}
		else if ( PlayerOwner().PlayerReplicationInfo.Score >= FindAmmoCost(MyAmmos[j].Class) )
		{
		    KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(MyAmmos[j].Class, false);
		}
		else
		{
			break;
		}
	}

    TheBuyable = none;

    SaleSelect.List.Index = -1;
    InvSelect.List.Index = -1;

	UpdatePanel();
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
        else
        {
			continue;
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
        if ( CurInv.Class == AClass )
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


function SetInfoText()
{
	local string TempString;

	if ( TheBuyable == none && !bDidBuyableUpdate )
	{
		InfoScrollText.SetContent(InfoText[0]);
		bDidBuyableUpdate = true;

		return;
	}

	if ( TheBuyable != none && OldPickupClass != TheBuyable.ItemPickupClass )
	{
		// Unowned Weapon DLC
		if ( TheBuyable.ItemWeaponClass.Default.AppID > 0 && !PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC(TheBuyable.ItemWeaponClass.Default.AppID) )
		{
			InfoScrollText.SetContent(Repl(InfoText[4], "%1", PlayerOwner().SteamStatsAndAchievements.GetWeaponDLCPackName(TheBuyable.ItemWeaponClass.Default.AppID)));
		}
		// Too expensive
		else if ( TheBuyable.ItemCost > PlayerOwner().PlayerReplicationInfo.Score && TheBuyable.bSaleList )
		{
			InfoScrollText.SetContent(InfoText[2]);
		}
		// Too heavy
		else if ( TheBuyable.ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight && TheBuyable.bSaleList )
		{
			TempString = Repl(Infotext[1], "%1", int(TheBuyable.ItemWeight));
			TempString = Repl(TempString, "%2", int(KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight - KFHumanPawn(PlayerOwner().Pawn).CurrentWeight));
			InfoScrollText.SetContent(TempString);
		}
		// default
		else
		{
			InfoScrollText.SetContent(InfoText[0]);
		}

		bDidBuyableUpdate = false;
		OldPickupClass = TheBuyable.ItemPickupClass;
	}
}

function OptionsChange(GUIComponent Sender)
{
/*	local int SelectedAction;

	SelectedAction = OptionsSelect.GetIndex();

	// Is this Auto-Fill Ammo?
	if ( SelectedAction == 4 )
	{
		DoFillAllAmmo();
	}
	// Is this Exit Trader?
	else if ( SelectedAction == 5 )
	{
		GUIBuyMenu(OwnerPage()).CloseSale(false);
	}
	//Is this a purchase?
	else if ( TheBuyable.bSaleList )
	{
		if ( TheBuyable.ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight <= KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight &&
			 TheBuyable.ItemCost <= PlayerOwner().PlayerReplicationInfo.Score &&
			 (TheBuyable.ItemWeaponClass.Default.AppID <= 0 || PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC(TheBuyable.ItemWeaponClass.Default.AppID)))
		{
			// Is it a vest?
			if ( TheBuyable.bIsVest )
			{
				DoBuyKevlar();
			}
			// Fist aid kit?
			else if ( TheBuyable.bIsFirstAidKit )
			{
				DoBuyFirstAid();
			}
			// should be a "regular" weapon
			else
			{
				DoBuy();
			}

	   		TheBuyable = none;
	   	}
	}
	// We want to do something with an item already in our inventory
	else
	{
		if ( TheBuyable.bSellable )
		{
			if ( !TheBuyable.bMelee && int(TheBuyable.ItemAmmoCurrent) < int(TheBuyable.ItemAmmoMax) )
			{
				if ( SelectedAction == 0 )
				{
					DoSell();
					TheBuyable = none;
				}
				else if ( SelectedAction == 1 )
				{
					DoBuyClip();
				}
				else
				{
					DoFillOneAmmo();
				}
			}
			else
			{
				DoSell();
				TheBuyable = none;
			}
		}
		else if ( !TheBuyable.bMelee )
		{
			if ( SelectedAction == 1 )
			{
			 	DoBuyClip();
			}
			else
			{
				DoFillOneAmmo();
			}
		}
	}

	OptionsSelect.UpdateList(TheBuyable);*/
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

function DoFillOneAmmo(GUIBuyable Buyable)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(Buyable.ItemAmmoClass, false);
        GetUpdatedBuyable(true);
    }
}

function DoBuyClip(GUIBuyable Buyable)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
		KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(Buyable.ItemAmmoClass, true);
        GetUpdatedBuyable(true);
    }
}

function DoBuyGrenade(bool bSingle)
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
			KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(class'FragAmmo', bSingle);
        	GetUpdatedBuyable(true);
    }
}

function DoSell()
{
	local class<KFWeapon> ItemWeaponClass;

    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
    	ItemWeaponClass = TheBuyable.ItemWeaponClass;

        InvSelect.List.Index = -1;
        TheBuyable = none;
        LastBuyable = none;

        KFPawn(PlayerOwner().Pawn).ServerSellWeapon(ItemWeaponClass);
    }
}

function DoBuy()
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
	KFPawn(PlayerOwner().Pawn).ServerBuyWeapon(TheBuyable.ItemWeaponClass);
        MakeSomeBuyNoise();

		SaleSelect.List.Index = -1;
        TheBuyable = none;
        LastBuyable = none;
    }
}

function DoBuyKevlar()
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyKevlar();
        MakeSomeBuyNoise(class'Vest');
    }
}

function DoBuyFirstAid()
{
    if ( KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyFirstAid();
        MakeSomeBuyNoise();

		SaleSelect.List.Index = -1;
        TheBuyable = none;
        UpdateAll();
    }
}

function MakeSomeBuyNoise(optional class<Pickup> PickupClass)
{
	if ( PlayerOwner().Pawn != none )
	{
		if ( PickupClass == none )
		{
			PlayerOwner().Pawn.PlaySound(TheBuyable.ItemPickupClass.default.PickupSound,SLOT_Interface, 255.0, , 120);
		}
		else
		{
			PlayerOwner().Pawn.PlaySound(PickupClass.default.PickupSound,SLOT_Interface, 255.0,, 120);
		}
	}
}

function UpdatePanel()
{
	local float Price;

	Price = 0.0;

	if ( TheBuyable != none && !TheBuyable.bSaleList && TheBuyable.bSellable )
	{
		SaleValueLabel.Caption = SaleValueCaption $ TheBuyable.ItemSellValue;

		SaleValueLabel.bVisible = true;
		SaleValueLabelBG.bVisible = true;
	}
	else
	{
		SaleValueLabel.bVisible = false;
		SaleValueLabelBG.bVisible = false;
	}

	if ( TheBuyable == none || !TheBuyable.bSaleList )
	{
		GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = 0;
	}

	ItemInfo.Display(TheBuyable);
	UpdateAutoFillAmmo();
	SetInfoText();

	// Money update
	if ( PlayerOwner() != none )
	{
		MoneyLabel.Caption = MoneyCaption $ int(PlayerOwner().PlayerReplicationInfo.Score);
	}
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == PurchaseButton )
	{
		if ( TheBuyable != none )
		{
			DoBuy();
			TheBuyable = none;
		}
	}
	else if ( Sender == SaleButton )
	{
		if ( TheBuyable.bSellable )
		{
			DoSell();
			TheBuyable = none;
		}
	}
	else if ( Sender == AutoFillButton )
	{
		DoFillAllAmmo();
	}
	else if ( Sender == ExitButton )
	{
		GUIBuyMenu(OwnerPage()).CloseSale(false);
	}

	UpdateAll();

	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=Inv
         Image=Texture'KF_InterfaceArt_tex.Menu.Thick_border_Transparent'
         ImageStyle=ISTY_Stretched
         Hint="The items in your inventory"
         WinTop=-0.003371
         WinLeft=-0.004500
         WinWidth=0.336905
         WinHeight=0.752000
     End Object
     InvBG=GUIImage'KFGui.KFTab_BuyMenu.Inv'

     Begin Object Class=GUIButton Name=SaleB
         Caption="Sell Weapon"
         Hint="Sell selected weapon"
         WinTop=0.004750
         WinLeft=0.000394
         WinWidth=0.162886
         WinHeight=35.000000
         RenderWeight=0.450000
         OnClick=KFTab_BuyMenu.InternalOnClick
         OnKeyEvent=SaleB.InternalOnKeyEvent
     End Object
     SaleButton=GUIButton'KFGui.KFTab_BuyMenu.SaleB'

     Begin Object Class=GUIImage Name=MagB
         Image=Texture'KF_InterfaceArt_tex.Menu.Innerborder_transparent'
         ImageStyle=ISTY_Stretched
         WinTop=0.011072
         WinLeft=0.205986
         WinWidth=0.054624
         WinHeight=25.000000
         RenderWeight=0.500000
     End Object
     MagBG=GUIImage'KFGui.KFTab_BuyMenu.MagB'

     Begin Object Class=GUIImage Name=FillB
         Image=Texture'KF_InterfaceArt_tex.Menu.Innerborder_transparent'
         ImageStyle=ISTY_Stretched
         WinTop=0.011572
         WinLeft=0.266769
         WinWidth=0.054624
         WinHeight=25.000000
         RenderWeight=0.500000
     End Object
     FillBG=GUIImage'KFGui.KFTab_BuyMenu.FillB'

     Begin Object Class=GUILabel Name=MagL
         Caption="1 Mag"
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2SmallFont"
         FontScale=FNS_Small
         WinTop=0.011072
         WinLeft=0.205986
         WinWidth=0.054624
         WinHeight=25.000000
         RenderWeight=0.510000
     End Object
     MagLabel=GUILabel'KFGui.KFTab_BuyMenu.MagL'

     Begin Object Class=GUILabel Name=FillL
         Caption="Fill"
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2SmallFont"
         FontScale=FNS_Small
         WinTop=0.011572
         WinLeft=0.266769
         WinWidth=0.054624
         WinHeight=25.000000
         RenderWeight=0.510000
     End Object
     FillLabel=GUILabel'KFGui.KFTab_BuyMenu.FillL'

     Begin Object Class=KFBuyMenuInvListBox Name=InventoryBox
         OnCreateComponent=InventoryBox.InternalOnCreateComponent
         WinTop=0.070841
         WinLeft=0.000108
         WinWidth=0.328204
         WinHeight=0.521856
     End Object
     InvSelect=KFBuyMenuInvListBox'KFGui.KFTab_BuyMenu.InventoryBox'

     Begin Object Class=GUIImage Name=MoneyBack
         Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border_Transparent'
         ImageStyle=ISTY_Stretched
         Hint="Your Money"
         WinTop=-0.003371
         WinLeft=0.332571
         WinWidth=0.333947
         WinHeight=0.137855
     End Object
     MoneyBG=GUIImage'KFGui.KFTab_BuyMenu.MoneyBack'

     Begin Object Class=GUILabel Name=SelectedItemL
         Caption="Selected Item Info"
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2SmallFont"
         FontScale=FNS_Small
         WinTop=0.141451
         WinLeft=0.332571
         WinWidth=0.333947
         WinHeight=20.000000
         RenderWeight=0.510000
     End Object
     SelectedItemLabel=GUILabel'KFGui.KFTab_BuyMenu.SelectedItemL'

     Begin Object Class=GUIImage Name=Item
         Image=Texture'KF_InterfaceArt_tex.Menu.Med_border_Transparent'
         ImageStyle=ISTY_Stretched
         Hint="Your selected item"
         WinTop=0.134311
         WinLeft=0.332571
         WinWidth=0.333947
         WinHeight=0.614680
     End Object
     ItemBG=GUIImage'KFGui.KFTab_BuyMenu.Item'

     Begin Object Class=GUIBuyWeaponInfoPanel Name=ItemInf
         WinTop=0.193730
         WinLeft=0.332571
         WinWidth=0.333947
         WinHeight=0.489407
     End Object
     ItemInfo=GUIBuyWeaponInfoPanel'KFGui.KFTab_BuyMenu.ItemInf'

     Begin Object Class=GUIImage Name=Sale
         Image=Texture'KF_InterfaceArt_tex.Menu.Thick_border_Transparent'
         ImageStyle=ISTY_Stretched
         Hint="These items are available in the shop"
         WinTop=-0.003371
         WinLeft=0.667306
         WinWidth=0.335919
         WinHeight=0.752000
     End Object
     SaleBG=GUIImage'KFGui.KFTab_BuyMenu.Sale'

     Begin Object Class=GUIButton Name=PurchaseB
         Caption="Purchase Weapon"
         Hint="Buy selected weapon"
         WinTop=0.004750
         WinLeft=0.729647
         WinWidth=0.220714
         WinHeight=35.000000
         RenderWeight=0.450000
         OnClick=KFTab_BuyMenu.InternalOnClick
         OnKeyEvent=PurchaseB.InternalOnKeyEvent
     End Object
     PurchaseButton=GUIButton'KFGui.KFTab_BuyMenu.PurchaseB'

     Begin Object Class=KFBuyMenuSaleListBox Name=SaleBox
         OnCreateComponent=SaleBox.InternalOnCreateComponent
         WinTop=0.064312
         WinLeft=0.672632
         WinWidth=0.325857
         WinHeight=0.674039
     End Object
     SaleSelect=KFBuyMenuSaleListBox'KFGui.KFTab_BuyMenu.SaleBox'

     Begin Object Class=GUIButton Name=AutoFill
         Caption="Auto Fill Ammo"
         Hint="Fills Up All Weapons"
         WinTop=0.805073
         WinLeft=0.725646
         WinWidth=0.220714
         WinHeight=0.050852
         RenderWeight=0.450000
         OnClick=KFTab_BuyMenu.InternalOnClick
         OnKeyEvent=AutoFill.InternalOnKeyEvent
     End Object
     AutoFillButton=GUIButton'KFGui.KFTab_BuyMenu.AutoFill'

     Begin Object Class=GUIButton Name=Exit
         Caption="Exit Trader Menu"
         Hint="Close The Trader Menu"
         WinTop=0.887681
         WinLeft=0.725646
         WinWidth=0.220714
         WinHeight=0.050852
         RenderWeight=0.450000
         OnClick=KFTab_BuyMenu.InternalOnClick
         OnKeyEvent=Exit.InternalOnKeyEvent
     End Object
     ExitButton=GUIButton'KFGui.KFTab_BuyMenu.Exit'

     Begin Object Class=GUIImage Name=Info
         Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border'
         ImageStyle=ISTY_Stretched
         Hint="Trader Informations"
         WinTop=0.746753
         WinLeft=-0.004500
         WinWidth=0.670457
         WinHeight=0.179353
     End Object
     InfoBG=GUIImage'KFGui.KFTab_BuyMenu.Info'

     Begin Object Class=GUIScrollTextBox Name=IScrollText
         CharDelay=0.005000
         EOLDelay=0.007500
         RepeatDelay=0.000000
         OnCreateComponent=IScrollText.InternalOnCreateComponent
         StyleName="TraderNoBackground"
         WinTop=0.758244
         WinLeft=0.004946
         WinWidth=0.651687
         WinHeight=0.160580
         bBoundToParent=True
         bScaleToParent=True
     End Object
     InfoScrollText=GUIScrollTextBox'KFGui.KFTab_BuyMenu.IScrollText'

     Begin Object Class=GUILabel Name=Money
         Caption="£123456"
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2HeaderFont"
         FontScale=FNS_Large
         WinTop=0.035524
         WinLeft=0.516045
         WinWidth=0.144797
         WinHeight=0.058675
     End Object
     MoneyLabel=GUILabel'KFGui.KFTab_BuyMenu.Money'

     Begin Object Class=GUIImage Name=Cash
         Image=Texture'PatchTex.Statics.BanknoteSkin'
         ImageStyle=ISTY_Scaled
         WinTop=0.026828
         WinLeft=0.393095
         WinWidth=0.107313
         WinHeight=0.077172
     End Object
     BankNote=GUIImage'KFGui.KFTab_BuyMenu.Cash'

     Begin Object Class=GUILabel Name=SaleValue
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         TextFont="UT2LargeFont"
         FontScale=FNS_Large
         WinTop=0.675470
         WinLeft=0.337502
         WinWidth=0.325313
         WinHeight=0.059661
     End Object
     SaleValueLabel=GUILabel'KFGui.KFTab_BuyMenu.SaleValue'

     Begin Object Class=GUIImage Name=SaleValueBG
         Image=Texture'KF_InterfaceArt_tex.Menu.Innerborder_transparent'
         ImageStyle=ISTY_Stretched
         WinTop=0.678411
         WinLeft=0.370054
         WinWidth=0.256263
         WinHeight=0.053742
     End Object
     SaleValueLabelBG=GUIImage'KFGui.KFTab_BuyMenu.SaleValueBG'

     InfoText(0)="Welcome to my shop! You can buy ammo or sell from your inventory on the left. Or you can buy new items from the right."
     InfoText(1)="Item is too heavy! It requires %1 free weight blocks, you only have %2 free. Sell some of your inventory!"
     InfoText(2)="Item is too expensive! Ask some blokes to spare some money or sell some of your inventory!"
     InfoText(3)="Select an item or option"
     AutoFillString="Auto Fill Ammo"
     MoneyCaption="£"
     SaleValueCaption="Sell Value: £"
     RepairBodyArmorCaption="Repair £"
     BuyBodyArmorCaption="Buy £"
     TraderSoundTooExpensive=SoundGroup'KF_Trader.TooExpensive'
     Begin Object Class=GUIImage Name=AmmoExit
         Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border'
         ImageStyle=ISTY_Stretched
         WinTop=0.746753
         WinLeft=0.666905
         WinWidth=0.335919
         WinHeight=0.252349
     End Object
     AmmoExitBG=GUIImage'KFGui.KFTab_BuyMenu.AmmoExit'

     PropagateVisibility=False
     WinTop=0.125000
     WinLeft=0.250000
     WinWidth=0.500000
     WinHeight=0.750000
}
