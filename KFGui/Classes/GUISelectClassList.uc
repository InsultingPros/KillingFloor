class GUISelectClassList extends GUIVertList;

var array< GUIClassSelectable > Elements;

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

function Add(GUIClassSelectable Item)
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
	if(GUIClassMenu(PageOwner) == None)
		return;
	if(Elements.Length <= 0)
		GUIClassMenu(PageOwner).NewInfo(None);
	else
		GUIClassMenu(PageOwner).NewInfo(Elements[Index]);


}


function DrawBuyItem(Canvas c, int Item, float X, float Y, float W, float HT, bool bSelected, bool bPending)
{
	local string tString;
	local float Iheight,Itop,Ileft,Iwidth;
	local eMenuState drawState;

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

	//Draw our nickname
	tString = GetItemAtIndex(Item);
	SectionStyle.DrawText(c,MSAT_Blurry,Ileft,Itop,Iwidth,(Iheight/2),TXTA_Center,tString,FNS_Medium);

		//Draw cost string
	tString = "Cost:"@Elements[Item].cost;
	SectionStyle.DrawText(c,MSAT_Blurry,Ileft,Itop+(Iheight/2),Iwidth,Iheight/2,TXTA_Left,tString,FNS_Medium);

		//Draw Weight string
	tString = "Weight:"@Elements[item].weight;
	SectionStyle.DrawText(c,MSAT_Blurry,Ileft,Itop+(Iheight/2),Iwidth,Iheight/2,TXTA_Right,tString,FNS_Medium);
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
     GetItemHeight=GUISelectClassList.BuyItemHeight
     StyleName="ItemBoxInfo"
     OnChange=GUISelectClassList.SelectNewItem
}
