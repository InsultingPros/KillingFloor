class KFPerkProgressListBox extends GUIListBoxBase;

var KFPerkProgressList List;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);

	if ( DefaultListClass != "" )
	{
		List = KFPerkProgressList(AddComponent(DefaultListClass));
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

defaultproperties
{
     DefaultListClass="KFGUI.KFPerkProgressList"
}
