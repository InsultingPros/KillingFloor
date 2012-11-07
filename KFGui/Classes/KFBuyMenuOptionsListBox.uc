//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFBuyMenuOptionsListBox extends GUIListBoxBase;

var KFBuyMenuOptionsList List;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);

	if ( DefaultListClass != "" )
	{
		List = KFBuyMenuOptionsList(AddComponent(DefaultListClass));
		
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

function int GetIndex()
{
	return List.Index;
}

function UpdateList(GUIBuyable Buyable)
{
	List.UpdateList(Buyable);	
}

defaultproperties
{
     DefaultListClass="KFGUI.KFBuyMenuOptionsList"
}
