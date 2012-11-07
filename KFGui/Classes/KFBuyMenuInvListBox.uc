//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFBuyMenuInvListBox extends GUIListBoxBase;

var KFBuyMenuInvList List;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);

	if ( DefaultListClass != "" )
	{
		List = KFBuyMenuInvList(AddComponent(DefaultListClass));
		
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
	if ( List.MyBuyables[List.Index] != none )
	{	
		return List.MyBuyables[List.Index];
	}
}

defaultproperties
{
     DefaultListClass="KFGUI.KFBuyMenuInvList"
}
