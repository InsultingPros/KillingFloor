class KFGamePageMP extends UT2K4GamePageMP;

var config 	bool	bExpert;
var 		string	FirewallWarning;

// Helper for Hack fix for selecting GameType tab
var bool bFirstChangeCompleted;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
   	super(UT2K4MainPage).Initcomponent(MyController, MyOwner);

	RuleInfo = new(None) class'Engine.PlayInfo';

	p_Game = UT2K4Tab_GameTypeBase(c_Tabs.AddTab(PanelCaption[0],PanelClass[0],,PanelHint[0], true));
	p_Game.OnChangeGameType = ChangeGameType;

	p_Main = UT2K4Tab_MainBase(c_Tabs.AddTab(PanelCaption[1],PanelClass[1],,PanelHint[1], true));
	p_Game.tp_Main = p_Main;

	mcRules = KFIAMultiColumnRulesPanel(c_Tabs.AddTab(PanelCaption[2], "KFGUI.KFIAMultiColumnRulesPanel",, PanelHint[2], false));
	p_Mutators = UT2K4Tab_MutatorBase(c_Tabs.AddTab(PanelCaption[3],PanelClass[3],,PanelHint[3], false));
	mcServerRules = KFUT2K4Tab_ServerRulesPanel(c_Tabs.AddTab(PanelCaption[4], PanelClass[4],, PanelHint[4]));

	b_Back = UT2K4GameFooter(t_Footer).b_Back;
	b_Secondary = UT2K4GameFooter(t_Footer).b_Secondary;
	b_Primary = UT2K4GameFooter(t_Footer).b_Primary;

	EnableComponent(b_Secondary);
	EnableComponent(b_Primary);

	// Disable the Sandbox Tab if we're not in Sandbox mode
	if ( class'KFGameType'.default.KFGameLength != 3 )
	{
		c_Tabs.TabStack[2].DisableMe();
	}
}

function InternalOnOpen()
{
	if ( Controller != None && !default.bExpert )
	{
		Controller.OpenMenu(FirewallWarning);
	}

	ChangeGameType(False);
}

function InternalOnChange(GUIComponent Sender)
{
	// HACK: Switch back to the GameType tab if we have more than 1 GameType available
	if ( !bFirstChangeCompleted )
	{
		if ( p_Game.li_Games.Elements.Length > 0 )
		{
			if ( p_Game.li_Games.Elements.Length > 1 )
			{
				bFirstChangeCompleted = true;
				c_Tabs.ActivateTabByName(PanelCaption[0], True);
			}
			
			p_Game.li_Games.SetIndex(0);
		}
	}

	bFirstChangeCompleted = p_Game.li_Games.Elements.Length > 0;
	super.InternalOnChange(Sender);
}

function StartGame(string GameURL, bool bAlt)
{
	local GUIController C;

	C = Controller;

	if (bAlt)
	{
	   if ( mcServerRules != None )
		  GameURL $= mcServerRules.Play();

	   // Append optional server flags
	   PlayerOwner().ConsoleCommand("relaunch"@GameURL@"-server  -log=server.log");
	}
	else
	   PlayerOwner().ClientTravel(GameURL $ "?Listen",TRAVEL_Absolute,False);

	C.CloseAll(false,True);
}

function UpdateBotSetting( string NewValue, moNumericEdit BotControl )
{
	local GUITabButton BotTab;
	// local byte Value;

	if ( BotControl == None || NewValue == "" )
		return;

	BotTab = GetBotTab();

	EnableComponent(BotControl);
	EnableComponent(BotTab);

}

function ChangeGameType(bool bIsCustom)
{
	if ( GameTypeLocked() )
		return;

	// We've changed the gametype, so the settings in PlayInfo may no longer be applicable
	// Re-initialize PlayInfo and refresh the applicable pages, then update the maplists
	// and bot configurations
	if ( p_Main != None )
	{
		p_Main.InitGameType();
		if ( p_Mutators != None )
			p_Mutators.SetCurrentGame(p_Main.CurrentGameType);
	}

	SetRuleInfo();
	
	KFMapPage(p_Main).RefreshOptions();

	// We use the bIsCustom flag to denote whether or not we should move on to the Maps tab
	if ( bIsCustom )
	{
		c_Tabs.ActivateTabByName(PanelCaption[1], True);
	}
		
	if ( p_BotConfig != none )
		p_BotConfig.SetupBotLists(p_Main.GetIsTeamGame());
}

// Forces the player to choose a gametype if none has been chosen - prevents having to load any gametypes until one is chosen, and speeds the page load
function bool GameTypeLocked()
{
	local int i;
	local GUITabButton tb;

	// Don't lock if we don't have a gametype tab (for whatever reason)
	if ( p_Game == None )
		return false;

	if ( Controller.LastGameType == "" )
	{
		for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
		{
			tb = c_Tabs.TabStack[i];
			if ( tb != None && tb != p_Game.MyButton )
				DisableComponent(tb);
		}

		DisableComponent(b_Primary);
		DisableComponent(b_Secondary);

		return true;
	}

	else
	{
		for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
		{
			tb = c_Tabs.TabStack[i];
			if ( tb != None )
			{
				if ( tb.MyPanel == p_Mutators && class'LevelInfo'.static.IsDemoBuild() )
					DisableComponent(tb);
				else EnableComponent(tb);
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
	}

	return false;
}

defaultproperties
{
     FirewallWarning="KFGUI.KFFirewallWarn"
     PageCaption=
     t_Header=GUIHeader'GUI2K4.UT2k4ServerBrowser.ServerBrowserHeader'

     Begin Object Class=KFGameFooter Name=SPFooter
         PrimaryCaption="LISTEN"
         PrimaryHint="Start a listen server..."
         SecondaryCaption="DEDICATED"
         SecondaryHint="Start a dedicated server..."
         Justification=TXTA_Center
         TextIndent=5
         FontScale=FNS_Small
         RenderWeight=0.300000
         TabOrder=8
         OnPreDraw=SPFooter.InternalOnPreDraw
     End Object
     t_Footer=KFGameFooter'KFGui.KFGamePageMP.SPFooter'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'KillingFloor2HUD.Menu.menuBackground'
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         RenderWeight=0.010000
     End Object
     i_Background=BackgroundImage'KFGui.KFGamePageMP.PageBackground'

     PanelClass(0)="KFGUI.KFTab_GameTypeMP"
     PanelClass(1)="KFGUI.KFMapPage"
     PanelClass(2)="KFGUI.KFRules"
     PanelClass(3)="KFGUI.KFMutatorPage"
     PanelClass(4)="KFGUI.KFUT2K4Tab_ServerRulesPanel"
     PanelCaption(2)="Sandbox"
     PanelCaption(4)="Server Rules"
     PanelHint(4)="Configure the server settings..."
     OnOpen=KFGamePageMP.InternalOnOpen
}
