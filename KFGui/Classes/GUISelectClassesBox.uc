class GUISelectClassesBox extends GUIListBoxBase;

var GUISelectClassList List;

function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	Super.InitComponent(MyController,MyOwner);

	if (DefaultListClass != "")
	{
		List = GUISelectClassList(AddComponent(DefaultListClass));
		if (List == None)
		{
			log(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
			return;
		}

	}

	if (List == None)
	{
		Warn("Could not initialize list!");
		return;
	}
	InitBaseList(List);
}

defaultproperties
{
     SectionStyleName="ItemBoxInfo"
     DefaultListClass="KFGUI.GUISelectClassList"
}
