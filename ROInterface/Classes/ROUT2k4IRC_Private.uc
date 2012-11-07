//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4IRC_Private extends UT2k4IRC_Private;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

defaultproperties
{
}
