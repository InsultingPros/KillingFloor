class GUIBuyItemsList extends GUIVertList;

var array<GUIBuyable> Elements;

/*
event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	OnDrawItem = DrawBuyItem;
	Super.InitComponent(MyController, MyOwner);
}

function Clear()
{
	if ( Elements.Length == 0 )
	{
		return;
	}

	Elements.Remove(0, Elements.Length);
	ItemCount = 0;
	IndexChanged(self);
	Super.Clear();
}

function Add(GUIBuyable Item)
{
	local int NewIndex, PointValue, ComparePointValue;

    PointValue=Item.cost;

   	if (Elements.Length > 0)
	{
		while ( NewIndex < Elements.Length )
		{
		    ComparePointValue=Elements[NewIndex].cost;

			if ( ComparePointValue >= PointValue )
			{
				break;
			}

            NewIndex++;
		}
	}
	else
    {
        NewIndex = Elements.Length;
    }

	Elements.Insert(NewIndex, 1);
	Elements[NewIndex] = Item;

	ItemCount = Elements.Length;

	if ( NewIndex == 0 )
	{
		SetIndex(0);
	}
 	else if ( bNotify )
 	{
		CheckLinkedObjects(Self);
	}

	if ( MyScrollBar != none )
    {
		MyScrollBar.AlignThumb();
	}
}

function string GetItemAtIndex( int idx )
{
	return Elements[idx].ItemName;
}

function SelectNewItem(GUIComponent Sender)
{
	if ( GUIBuyMenu(PageOwner) == none )
	{
        return;
    }
	if ( Elements.Length <= 0 )
	{
//		GUIBuyMenu(PageOwner).NewInfo(None);
	}
	else
	{
//        GUIBuyMenu(PageOwner).NewInfo(Elements[Index]);
    }
}

function bool OnDblClick(GUIComponent Sender)
{
	// HAHAH typecasting nightmare.
	// All we're doing here is hacking the Items in the buymenu list so when you
	// double clickem, it runs a quick check to see if you can buy / sell this, and acts
	// like you had clicked the footer.
	// Because the Sender (the actual button we're double clicking) has fuck all to do with the GUIBuyable itself,
	// we've gotta route everything back through the BuyMenu...
	// Care of Alex
	return False;
}

function DrawBuyItem(Canvas c, int Item, float X, float Y, float W, float HT, bool bSelected, bool bPending)
{
	local string tString;
	local float Iheight, Itop, Ileft, Iwidth, StringHeight, StringWidth;
	local eMenuState drawState;
	local int AdjustedValue;
	local float GameDifficulty;

    if ( PlayerOwner().Level.Game != none )
    {
        GameDifficulty = KFGameType(PlayerOwner().Level.Game).GetDifficulty();
    }

	if ( !bSelected )
	{
        drawState = MSAT_Blurry;
	}
	else
	{
        drawState = MSAT_Watched;
    }

	tString = GetItemAtIndex(Item);
    c.StrLen(tString, StringWidth, StringHeight);

    FontScale = FNS_Medium;

    //Iheight = HT * 0.808917;
    Iheight = StringHeight * FontScale + 4;
	//Itop = Y + Iheight) / 2;
    Itop = Y + (Iheight - StringHeight) / 2;
	Ileft = X;
	Iwidth = W;

	SectionStyle.Draw(c, drawState, Ileft, Itop, Iwidth, Iheight);

	Ileft = X * 1.05;
	Iwidth = W - ((ILeft - X) * 2);

    if ( Elements[Item].HasMe(PlayerOwner().Pawn) )
    {
        AdjustedValue =int(Elements[Item].cost / GameDifficulty);
    }
    else
    {
        AdjustedValue = Elements[Item].cost;
    }

    c.StrLen(tString, StringWidth, StringHeight);

    //Draw our nickname

	SectionStyle.DrawText(c, MSAT_Blurry, Ileft, Itop, Iwidth, Itop - (Iheight / 2), TXTA_Left, tString, FNS_Medium);
    Ileft = ILeft + StringWidth + 20;


	//Draw cost string  Added to account for whether it is an item that's in myinventory (and therefore can only be sold)
	//tString = "Cost:"@Elements[Item].cost;
    if ( Elements[Item].cost == AdjustedValue )
    {
   	    tString = "Cost:" @ AdjustedValue;
   	}
    else
    {
        tString = "Sale Value:" @ AdjustedValue;
    }

    SectionStyle.DrawText(c, MSAT_Blurry, ILeft, Itop, Iwidth, Iheight / 2, TXTA_Left, tString, FNS_small);

    c.StrLen(tString, StringWidth, StringHeight);
    Ileft = ILeft + StringWidth + 20;

	//Draw Weight string
	tString = "Weight:" @ Elements[item].weight;
	SectionStyle.DrawText(c, MSAT_Blurry, Ileft, Itop, Iwidth, Iheight / 2, TXTA_Left, tString, FNS_small);
}

function float BuyItemHeight(Canvas c)
{
	if ( GUIBuyItemsBox(MenuOwner) != none )
	{
		 return MenuOwner.ActualHeight() * 0.25;
	}
	else
	{
        return 0;
    }
}
*/

defaultproperties
{
}
