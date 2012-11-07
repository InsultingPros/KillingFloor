//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROGUIScrollTextBox extends GUIScrollTextBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

defaultproperties
{
}
