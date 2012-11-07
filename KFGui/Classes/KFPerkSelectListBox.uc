class KFPerkSelectListBox extends GUIListBoxBase;

var KFPerkSelectList List;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);

	if ( DefaultListClass != "" )
	{
		List = KFPerkSelectList(AddComponent(DefaultListClass));
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

defaultproperties
{
     DefaultListClass="KFGUI.KFPerkSelectList"
}
