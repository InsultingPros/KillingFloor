//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFBuyMenuSaleListBox extends GUIListBoxBase;

var KFBuyMenuSaleList List;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);

	if ( DefaultListClass != "" )
	{
		List = KFBuyMenuSaleList(AddComponent(DefaultListClass));
		
		if (List == None)
		{
			log(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
			return;
		}
	}

	if ( List == none )
	{
		Warn("Could not initialize list!");
		return;
	}

	InitBaseList(List);
}

function GUIBuyable GetSelectedBuyable()
{
	return List.ForSaleBuyables[List.Index];
}

defaultproperties
{
     DefaultListClass="KFGUI.KFBuyMenuSaleList"
}
