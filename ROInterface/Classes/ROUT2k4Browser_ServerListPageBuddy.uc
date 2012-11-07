//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4Browser_ServerListPageBuddy extends UT2k4Browser_ServerListPageBuddy;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Server);
    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Rules);
    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Players);
    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Buddy);
}

defaultproperties
{
}
