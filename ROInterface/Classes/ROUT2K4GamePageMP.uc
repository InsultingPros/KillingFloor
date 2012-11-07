//-----------------------------------------------------------
// edited by emh 11/24/05
//-----------------------------------------------------------
class ROUT2K4GamePageMP extends UT2K4GamePageMP;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

    class'ROInterfaceUtil'.static.SetROStyle(InController, Controls);

    RuleInfo = new(None) class'Engine.PlayInfo';

    c_Tabs.RemoveTab(PanelCaption[0]); // Remove Game Type tab
    c_Tabs.RemoveTab(PanelCaption[4]); // Remove Game Type tab

	mcRules = IAMultiColumnRulesPanel(c_Tabs.ReplaceTab(c_Tabs.TabStack[1], PanelCaption[2], "ROInterface.ROIAMultiColumnRulesPanel",, PanelHint[2]));

	// hax! hide frame and difficulty setting
    ROUT2K4Tab_MainSP(c_Tabs.BorrowPanel(PanelCaption[1])).bHideDifficultyControl = true;
}

// we only have one game type so it is never locked
function bool GameTypeLocked()
{
	local int i;
	local GUITabButton tb;

		for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
		{
			tb = c_Tabs.TabStack[i];
			if ( tb != None )
			{
				EnableComponent(tb);
			}
		}

		EnableComponent(b_Primary);
		EnableComponent(b_Secondary);
		// Update the botmode stuff (tab button & minplayers property control)
		if ( RuleInfo != None && mcRules != None )
		{
			i = RuleInfo.FindIndex("BotMode");
			if ( i != -1 )
				mcRules.UpdateBotSetting(i);
		}


    return false;
}

function StartGame(string GameURL, bool bAlt)
{
	local GUIController C;

	C = Controller;

    if (bAlt)
	{
	    if ( mcServerRules != None )
			GameURL $= mcServerRules.Play();

        log("GameURL is "$GameURL);
        log("ConsoleCommand  is "$"relaunch"@GameURL@"-server -log=server.log");
	    // Append optional server flags
		PlayerOwner().ConsoleCommand("relaunch"@GameURL@"-server -log=server.log");
//		PlayerOwner().ConsoleCommand("relaunch"@GameURL@"-server  -Mod=RedOrchestra  -log=server.log");
	}
    else
        PlayerOwner().ClientTravel(GameURL $ "?Listen",TRAVEL_Absolute,False);

    C.CloseAll(false,True);
}

defaultproperties
{
     Begin Object Class=UT2K4GameFooter Name=MPFooter
         PrimaryCaption="LISTEN"
         PrimaryHint="Start A Listen Server With These Settings"
         SecondaryCaption="DEDICATED"
         SecondaryHint="Start a Dedicated Server With These Settings"
         Spacer=0.010000
         TextIndent=5
         FontScale=FNS_Small
         WinTop=0.957943
         RenderWeight=0.300000
         TabOrder=8
         OnPreDraw=MPFooter.InternalOnPreDraw
     End Object
     t_Footer=UT2K4GameFooter'ROInterface.ROUT2K4GamePageMP.MPFooter'

     Begin Object Class=GUIImage Name=BkChar
         Image=Texture'menuBackground.MainBackGround'
         ImageStyle=ISTY_Scaled
         X1=0
         Y1=0
         X2=1024
         Y2=1024
         WinHeight=1.000000
         RenderWeight=0.020000
     End Object
     i_bkChar=GUIImage'ROInterface.ROUT2K4GamePageMP.BkChar'

     PanelClass(1)="ROInterface.ROUT2K4Tab_MainSP"
     PanelClass(2)="ROInterface.ROIAMultiColumnRulesPanel"
     PanelClass(3)="ROInterface.ROUT2K4Tab_MutatorSP"
     PanelClass(4)="ROInterface.ROUT2K4Tab_BotConfigMP"
     PanelClass(5)="ROInterface.ROUT2K4Tab_ServerRulesPanel"
}
