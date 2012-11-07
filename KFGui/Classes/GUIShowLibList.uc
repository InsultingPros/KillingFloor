class GUIShowLibList extends GUIVertList;

var array< GUIShowable > Elements;


event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	OnDrawItem=DrawBuyItem;
	Super.InitComponent(MyController,MyOwner);
}

function Clear()
{
	if (Elements.Length == 0)
		return;

	Elements.Remove(0,Elements.Length);
	ItemCount = 0;
	IndexChanged(self);
	Super.Clear();
}

function Add(GUIshowable Item)
{
	local int NewIndex,PointValue,ComparePointValue;

        PointValue=Item.cost;


   	if (Elements.Length > 0)
	{
		while (NewIndex < Elements.Length)
		{
		    ComparePointValue=Elements[NewIndex].cost;
			if(ComparePointValue >= PointValue)
				break;
			NewIndex++;
		}
	}
	else NewIndex = Elements.Length;

	Elements.Insert(NewIndex, 1);
	Elements[NewIndex] = Item;

	ItemCount = Elements.Length;

	if (NewIndex == 0)
		SetIndex(0);
 	else if ( bNotify )
		CheckLinkedObjects(Self);

	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();

}

function string GetItemAtIndex( int idx )
{
	return Elements[idx].ItemName;
}

function SelectNewItem(GUIComponent Sender)
{
	if(GUILibraryMenu(PageOwner) == None)
		return;
	if(Elements.Length <= 0)
		GUILibraryMenu(PageOwner).NewInfo(None);
	else
		GUILibraryMenu(PageOwner).NewInfo(Elements[Index]);
}

function bool OnDblClick(GUIComponent Sender)
{
	// HAHAH typecasting nightmare.
	// All we're doing here is hacking the Items in the buymenu list so when you
	// double clickem, it runs a quick check to see if you can buy / sell this, and acts
	// like you had clicked the footer.
 
	// Because the Sender (the actual button we're double clicking) has fuck all to do with the GUIshowable itself,
	// we've gotta route everything back through the BuyMenu... 
 	// Care of Alex
	if (GUILibraryMenu(PageOwner).CanAfford(GUILibraryMenu(PageOwner).ItemsBox.List.Elements[GUILibraryMenu(PageOwner).ItemsBox.List.Index] )
	 && GUILibraryMenu(PageOwner).ItemsBox.List.Elements[GUILibraryMenu(PageOwner).ItemsBox.List.Index].CanButtonMe(PlayerOwner()
	 ,GUILibraryMenu(PageOwner).myCategories.Index!=0) )
		GUILibraryMenuFooter(GUILibraryMenu(PageOwner).t_Footer).OnFooterClick(GUILibraryMenuFooter(GUILibraryMenu(PageOwner).t_Footer).b_Buy);
	Return False;
}


function DrawBuyItem(Canvas c, int Item, float X, float Y, float W, float HT, bool bSelected, bool bPending)
{
	local string tString;
	local float Iheight,Itop,Ileft,Iwidth;
	local eMenuState drawState;
	local int AdjustedValue;
	local float GameDifficulty;

       if (PlayerOwner().Level.Game != none)
        GameDifficulty = KFGameType(PlayerOwner().Level.Game).GetDifficulty();

	if(!bSelected)
	   drawState = MSAT_Blurry;
	else
		drawState = MSAT_Watched;

	Iheight = HT*0.808917;
	Itop = Y+(HT-Iheight)/2;
	Ileft = X;
	Iwidth = W;

	SectionStyle.Draw(c,drawState,Ileft,Itop,Iwidth,Iheight);

	Ileft = X*1.05;
	Iwidth = W-((ILeft-X)*2);

	
        if (Elements[Item].HasMe(PlayerOwner().Pawn))
         AdjustedValue =int(Elements[Item].cost / GameDifficulty);
       else
         AdjustedValue = Elements[Item].cost;

	//Draw our nickname
	tString = GetItemAtIndex(Item);
	SectionStyle.DrawText(c,MSAT_Blurry,Ileft,Itop,Iwidth,(Iheight/2),TXTA_Center,tString,FNS_Medium);

		//Draw cost string  Added to account for whether it is an item that's in myinventory (and therefore can only be sold)
	//tString = "Cost:"@Elements[Item].cost;
       if(Elements[Item].cost == AdjustedValue)
       	tString = "Cost:"@AdjustedValue;
       else
        tString = "Sale Value:"@AdjustedValue;
       SectionStyle.DrawText(c,MSAT_Blurry,Ileft,Itop,Iwidth,(Iheight),TXTA_Center,tString,FNS_small);

		//Draw Weight string
	tString = "Weight:"@Elements[item].weight;
	SectionStyle.DrawText(c,MSAT_Blurry,Ileft,Itop,Iwidth,(Iheight+(Iheight /2)),TXTA_Center,tString,FNS_small);
}

function float BuyItemHeight(Canvas c)
{
	if(GUIBuyItemsBox(MenuOwner) != None)
		 return MenuOwner.ActualHeight() * 0.25;
	else
		 return 0;
}

defaultproperties
{
     StyleName="ItemBoxInfo"
     bMouseOverSound=True
     OnClickSound=CS_Click
}
