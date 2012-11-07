class KFDLCListBox extends GUIListBoxBase;

var KFDLCList List;
var bool bShowCharacters;
var bool bShowWeapons;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);

    if ( DefaultListClass != "" )
	{
		List = KFDLCList(AddComponent(DefaultListClass));
		if ( List == none )
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
     DefaultListClass="KFGUI.KFDLCList"
}
