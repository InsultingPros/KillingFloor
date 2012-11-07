//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4IRC_Panel extends UT2k4IRC_Panel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

defaultproperties
{
     ServerHistory(0)="irc.gamesurge.net"
     ServerHistory(1)="Olya.NY.US.GameSurge.net"
     LocalChannel="#redorchestra"
}
