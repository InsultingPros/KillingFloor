//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4Browser_IRC extends UT2k4Browser_IRC;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int              i;

	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

	// Change the Style of the Tabs
	/*c_Channel.TabHeight=0.06;
	c_Channel.BackgroundStyle = None;
	c_Channel.BackgroundStyleName = "";*/
	for ( i = 0; i < c_Channel.TabStack.Length; i++ )
	{
		if ( c_Channel.TabStack[i] != None )
		{
	        //c_Channel.TabStack[i].Style=None;   // needed to reset style
			c_Channel.TabStack[i].FontScale=FNS_Medium;
			c_Channel.TabStack[i].bAutoSize=True;
			c_Channel.TabStack[i].bAutoShrink=False;
			//c_Channel.TabStack[i].StyleName="ROTabButton";
			//c_Channel.TabStack[i].Initcomponent(MyController, c_Channel);
        }
	}
}

/*
function UT2K4IRC_Channel AddChannel( string ChannelName, optional bool bPrivate )
{
    local UT2K4IRC_Channel channel;
	local int              i;

	channel = UT2K4IRC_Channel( c_Channel.AddTab(ChannelName, Eval( bPrivate, PrivateChannelClass, PublicChannelClass )) );

	// Change the Style of the Tabs
	c_Channel.TabHeight=0.06;
	c_Channel.BackgroundStyle = None;
	c_Channel.BackgroundStyleName = "";
	for ( i = 0; i < c_Channel.TabStack.Length; i++ )
	{
		if ( c_Channel.TabStack[i] != None )
		{
	        c_Channel.TabStack[i].Style=None;   // needed to reset style
			c_Channel.TabStack[i].FontScale=FNS_Medium;
			c_Channel.TabStack[i].bAutoSize=True;
			c_Channel.TabStack[i].bAutoShrink=False;
			c_Channel.TabStack[i].StyleName="ROTabButton";
			c_Channel.TabStack[i].Initcomponent(localController, c_Channel);
        }
	}

	return channel;
}
*/

defaultproperties
{
     SystemPageClass="ROInterface.ROUT2K4IRC_System"
     PublicChannelClass="ROInterface.ROUT2K4IRC_Channel"
     PrivateChannelClass="ROInterface.ROUT2K4IRC_Private"
}
