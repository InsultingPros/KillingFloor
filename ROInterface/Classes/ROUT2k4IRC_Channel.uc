//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4IRC_Channel extends UT2k4IRC_Channel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

defaultproperties
{
     IRCNickColor=(B=150,R=255)
     IRCInfoColor=(B=130,R=160)
}
