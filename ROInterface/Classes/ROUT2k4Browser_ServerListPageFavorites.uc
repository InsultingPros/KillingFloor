//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4Browser_ServerListPageFavorites extends UT2k4Browser_ServerListPageFavorites;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Server);
    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Rules);
    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Players);
}

defaultproperties
{
     Begin Object Class=ROGUIContextMenu Name=FavoritesContextMenu
         OnOpen=UT2k4Browser_ServerListPageFavorites.ContextMenuOpened
         OnSelect=UT2k4Browser_ServerListPageFavorites.ContextSelect
     End Object
     ContextMenu=ROGUIContextMenu'ROInterface.ROUT2k4Browser_ServerListPageFavorites.FavoritesContextMenu'

}
