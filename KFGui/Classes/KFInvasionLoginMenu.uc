class KFInvasionLoginMenu extends UT2K4PlayerLoginMenu;

var bool bNoSteam;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	local PlayerController PC;
	local int i;

	Super.InitComponent(MyController, MyComponent);

	// Remove Perks tab if Perks aren't enabled
	PC = PlayerOwner();
	if ( !MyController.CheckSteam() || PC == none || KFGameReplicationInfo(PC.Level.GRI) == none )
	{
		c_Main.RemoveTab(Panels[1].Caption);
		c_Main.ActivateTabByName(Panels[2].Caption, true);
		bNoSteam = true;
	}
	else if ( PC.SteamStatsAndAchievements == none )
	{
		if ( PC.Level.NetMode != NM_Client )
		{
			PC.SteamStatsAndAchievements = PC.Spawn(PC.default.SteamStatsAndAchievementsClass, PC);
			if ( !PC.SteamStatsAndAchievements.Initialize(PC) )
			{
				PC.SteamStatsAndAchievements.Destroy();
				PC.SteamStatsAndAchievements = none;
			}
		}

		c_Main.RemoveTab(Panels[1].Caption);
		c_Main.ActivateTabByName(Panels[2].Caption, true);
		bNoSteam = true;
	}
	else if ( !PC.SteamStatsAndAchievements.bInitialized )
	{
		PC.SteamStatsAndAchievements.GetStatsAndAchievements();
		c_Main.RemoveTab(Panels[1].Caption);
		c_Main.ActivateTabByName(Panels[2].Caption, true);
		bNoSteam = true;
	}
	else
	{
		for ( i = 0; i < class'KFGameType'.default.LoadedSkills.Length; i++ )
		{
			if ( KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).GetPerkProgress(i) < 0.0 )
			{
				PC.SteamStatsAndAchievements.GetStatsAndAchievements();
				c_Main.RemoveTab(Panels[1].Caption);
				c_Main.ActivateTabByName(Panels[2].Caption, true);
				bNoSteam = true;
			}
		}
	}

	c_Main.RemoveTab(Panels[0].Caption);
	if ( !bNoSteam )
	{
		c_Main.ActivateTabByName(Panels[1].Caption, true);
	}
}

// Overridden to stop the unnecessary removal of Panels
function RemoveMultiplayerTabs(GameInfo Game)
{
}

defaultproperties
{
     Panels(0)=(ClassName="KFGUI.KFLoginControls")
     Panels(1)=(ClassName="KFGUI.KFTab_MidGamePerks",Caption="Perks",Hint="Select your current Perk")
     Panels(2)=(ClassName="KFGUI.KFTab_MidGameVoiceChat",Caption="Communication",Hint="Manage communication with other players")
     Panels(3)=(ClassName="KFGUI.KFTab_MidGameHelp",Caption="Help",Hint="How to survive in Killing Floor")
     Begin Object Class=GUITabControl Name=LoginMenuTC
         bDockPanels=True
         BackgroundStyleName="TabBackground"
         WinTop=0.026336
         WinLeft=0.012500
         WinWidth=0.974999
         WinHeight=0.050000
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=LoginMenuTC.InternalOnActivate
     End Object
     c_Main=GUITabControl'KFGui.KFInvasionLoginMenu.LoginMenuTC'

     WinTop=0.006158
     WinWidth=0.814844
     WinHeight=0.990311
}
