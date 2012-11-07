//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFBuyMenuOptionsList extends GUIVertList;

// Settings
var	float					ItemBorder;			// Percent of Height to leave blank inside Item Background
var	float					TextTopOffset;		// Percent of Height to offset top of Text
var	float					ItemSpacing;		// Number of Pixels between Items

// Display
var	texture					ItemBackground;
var	texture					SelectedItemBackground;
var array<string>			PrimaryStrings;
var	array<string>			SecondaryStrings;

// state
var	GUIBuyable				TheBuyable;
var	int						MouseOverIndex;

var bool					bNeedsUpdate;
var	bool					bNoAutoFill;
var int						UpdateCounter;

var localized string		BuyString;
var localized string		SellString;
var localized string		BuyClipString;
var localized string		FillString;
var	localized string		AutoFillString;
var	localized string		ExitString;

var	int						AutoFillCost;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	OnDrawItem = DrawInvItem;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	PrimaryStrings.Remove(0, PrimaryStrings.Length);
	SecondaryStrings.Remove(0, SecondaryStrings.Length);
	TheBuyable = none;

	super.Closed(Sender, bCancelled);
}

function UpdateList(GUIBuyable Buyable)
{
	// Clear the arrays
	PrimaryStrings.Remove(0, PrimaryStrings.Length);
	SecondaryStrings.Remove(0, SecondaryStrings.Length);

	//Reset item count
	ItemCount = 6;

	TheBuyable = Buyable;

	if ( TheBuyable != none )
	{
		// First we have to check if the item is inv or sale
		if ( !TheBuyable.bSaleList )
		{
			//Ok, this item is already in our inventory, now let's see if we can sell it or not
			if ( TheBuyable.bSellable )
			{
				// Now we have to check if it is a melee weapon && Check if we already have full ammo
				if ( !TheBuyable.bMelee && int(TheBuyable.ItemAmmoCurrent) < int(TheBuyable.ItemAmmoMax))
				{
					// Sell Button
					PrimaryStrings[0] = SellString;
					SecondaryStrings[0]	= "£" $ int(TheBuyable.ItemCost * 0.75) ;

					// Single Clip
					PrimaryStrings[1] = BuyClipString;
					SecondaryStrings[1] = "£" $ int(TheBuyable.ItemAmmoCost);

					// Fill up
					PrimaryStrings[2] = FillString;
					SecondaryStrings[2] = "£" $ int(TheBuyable.ItemFillAmmoCost);
				}
				else
				{
					// Sell Button
					PrimaryStrings[2] = SellString;
					SecondaryStrings[2]	= "£" $ int(TheBuyable.ItemCost * 0.75) ;
				}
			}
			else
			{
				//Check if it is a melee weapon
				if ( !TheBuyable.bMelee )
				{
					//Check if we already have full ammo
					if ( int(TheBuyable.ItemAmmoCurrent) < int(TheBuyable.ItemAmmoMax) )
					{
						// Single Clip
						PrimaryStrings[1] = BuyClipString;
						SecondaryStrings[1] = "£" $ int(TheBuyable.ItemAmmoCost);

						// Fill up
						PrimaryStrings[2] = FillString;
						SecondaryStrings[2] = "£" $ int(TheBuyable.ItemFillAmmoCost);
					}
				}
			}
		}
		else
		{
			//Too heavy? Too expensive?
			if ( TheBuyable.ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight <= KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight &&
				 TheBuyable.ItemCost <= PlayerOwner().PlayerReplicationInfo.Score && PlayerOwner().SteamStatsAndAchievements.PlayerOwnsWeaponDLC(TheBuyable.ItemWeaponClass.Default.AppID) )
			{
		   		//This is an for sale item
				PrimaryStrings[2] = BuyString;
				SecondaryStrings[2] = "£" $ int(TheBuyable.ItemCost);
			}
		}

	}

	PrimaryStrings[4] = AutoFillString;
	SecondaryStrings[4] = "£" $ AutoFillCost;
	PrimaryStrings[5] = ExitString;
	SecondaryStrings[5] = "";

	if ( bNotify )
 	{
		CheckLinkedObjects(Self);
	}

	if ( MyScrollBar != none )
	{
		MyScrollBar.AlignThumb();
	}
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
	local KFWeapon MyWeapon;

	for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
    {
        //if( CurInv.Class == AClass )
        //{
        //    MyAmmo = Ammunition(CurInv);
        //}
        if ( KFWeapon(CurInv) != None && (Weapon(CurInv).AmmoClass[0]==AClass || Weapon(CurInv).AmmoClass[1]==AClass) )
        {
        	MyWeapon = KFWeapon(CurInv);
        	break;
        }
    }

    if ( MyWeapon !=  none )
    {
    	return Class<KFWeaponPickup>(MyWeapon.PickupClass).Default.AmmoCost;
    }
    else
    {
	 	return 999999;
	}
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
	local float TempX, TempY;
	local float StringHeight, StringWidth;

	if ( PrimaryStrings[CurIndex] == "" )
	{
		return;
	}

	OnClickSound=CS_Click;

	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing / 2.0;

	// Initialize the Canvas
	Canvas.Style = 1;

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);

	if ( CurIndex == MouseOverIndex )
	{
		Canvas.SetDrawColor(210, 210, 210, 255);
		Canvas.DrawTileStretched(SelectedItemBackground, Width, Height - ItemSpacing);
	}
	else
	{
		Canvas.SetDrawColor(255, 255, 255, 255);
		Canvas.DrawTileStretched(ItemBackground, Width, Height - ItemSpacing);
	}

	// Select Text color
	if ( CurIndex == MouseOverIndex )
	{
		Canvas.SetDrawColor(189, 73, 74, 255);
	}
	else
	{
		Canvas.SetDrawColor(255, 255, 255, 255);
	}

	if ( CurIndex == 4 )
	{
		if ( PlayerOwner().PlayerReplicationInfo.Score < FindCheapestAmmo() )
		{
			Canvas.SetDrawColor(128, 128, 128, 255);
			bNoAutoFill = true;
		}
		else
		{
			bNoAutoFill = false;
		}
	}

	// Draw the function(Buy, Sell, etc.)
	Canvas.StrLen(PrimaryStrings[CurIndex], StringWidth, StringHeight);
	Canvas.SetPos(TempX+ (0.2 * Height), TempY + ((Height - ItemSpacing - StringHeight) / 2));
	Canvas.DrawText(PrimaryStrings[CurIndex]);

	// Draw the price(if any)
	Canvas.StrLen(SecondaryStrings[CurIndex], StringWidth, StringHeight);
	Canvas.SetPos(TempX + Width - (StringWidth + (0.2 * Height)), TempY + ((Height - ItemSpacing - StringHeight) / 2));
	Canvas.DrawText(SecondaryStrings[CurIndex]);
	Canvas.SetDrawColor(255, 255, 255, 255);
}

function float SaleItemHeight(Canvas c)
{
	return ((MenuOwner.ActualHeight() / 6.0) - 1.0);
}

defaultproperties
{
     ItemBorder=0.030000
     TextTopOffset=0.050000
     ItemSpacing=6.000000
     ItemBackground=Texture'InterfaceArt_tex.Menu.DownTickBlurry'
     SelectedItemBackground=Texture'InterfaceArt_tex.Menu.DownTickWatched'
     BuyString="Purchase"
     SellString="Sell Weapon"
     BuyClipString="Buy Single Clip"
     FillString="Fill Selected Ammo"
     AutoFillString="Auto Fill Ammo"
     ExitString="Exit Trader Menu"
     GetItemHeight=KFBuyMenuOptionsList.SaleItemHeight
     FontScale=FNS_Medium
     OnPreDraw=KFBuyMenuOptionsList.PreDraw
}
