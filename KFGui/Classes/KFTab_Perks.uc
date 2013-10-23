//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFTab_Perks extends UT2K4TabPanel;

var automated GUISectionBackground	i_BGPerks;
var	automated KFPerkSelectListBox	lb_PerkSelect;

var automated GUISectionBackground	i_BGPerkEffects;
var automated GUIScrollTextBox		lb_PerkEffects;

var automated GUISectionBackground	i_BGPerkNextLevel;
var	automated KFPerkProgressListBox	lb_PerkProgress;

var	automated GUIButton	b_Save;

var	automated GUIButton	b_Done;

var	automated GUILabel	l_ChangePerkOncePerWave;

var KFSteamStatsAndAchievements KFStatsAndAchievements;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	lb_PerkSelect.List.OnChange = OnPerkSelected;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	KFStatsAndAchievements = none;

	super.Closed(Sender, bCancelled);
}

function ShowPanel(bool bShow)
{
	super.ShowPanel(bShow);

	if ( bShow )
	{
		if ( PlayerOwner() != none )
		{
			KFStatsAndAchievements = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements);

			if ( KFStatsAndAchievements != none )
			{
				// Initialize the List
				lb_PerkSelect.List.InitList(KFStatsAndAchievements);
				lb_PerkProgress.List.InitList();
			}
		}

		l_ChangePerkOncePerWave.SetVisibility(false);
	}
}

function OnPerkSelected(GUIComponent Sender)
{
	if ( KFStatsAndAchievements.bUsedCheats )
	{
		lb_PerkEffects.SetContent(class'LobbyMenu'.default.PerksDisabledString);
	}
	else
	{
		lb_PerkEffects.SetContent(class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()].default.LevelEffects[KFStatsAndAchievements.PerkHighestLevelAvailable(lb_PerkSelect.GetIndex())]);

		lb_PerkProgress.List.PerkChanged(KFStatsAndAchievements, lb_PerkSelect.GetIndex());
	}
}

function bool OnSaveButtonClicked(GUIComponent Sender)
{
	local PlayerController PC;

	PC = PlayerOwner();

	if ( KFPlayerController(PC) != none )
	{
		if ( KFPlayerController(PC).bChangedVeterancyThisWave && KFPlayerController(PC).SelectedVeterancy != class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()] )
		{
			l_ChangePerkOncePerWave.SetVisibility(true);
		}
		else
		{
			class'KFPlayerController'.default.SelectedVeterancy = class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()];
			KFPlayerController(PC).SetSelectedVeterancy( class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()] );
			KFPlayerController(PC).SendSelectedVeterancyToServer();
			PC.SaveConfig();
		}
	}
	else
	{
		class'KFPlayerController'.default.SelectedVeterancy = class'KFGameType'.default.LoadedSkills[lb_PerkSelect.GetIndex()];
		class'KFPlayerController'.static.StaticSaveConfig();
	}

	return true;
}

function bool OnDoneClick(GUIComponent Sender)
{
	GUIBuyMenu(OwnerPage()).CloseSale(false);

	return true;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BGPerks
         bFillClient=True
         Caption="Select Perk"
         WinTop=0.029674
         WinLeft=0.019240
         WinWidth=0.457166
         WinHeight=0.798982
         OnPreDraw=BGPerks.InternalPreDraw
     End Object
     i_BGPerks=GUISectionBackground'KFGui.KFTab_Perks.BGPerks'

     Begin Object Class=KFPerkSelectListBox Name=PerkSelectList
         OnCreateComponent=PerkSelectList.InternalOnCreateComponent
         WinTop=0.091627
         WinLeft=0.029240
         WinWidth=0.437166
         WinHeight=0.742836
     End Object
     lb_PerkSelect=KFPerkSelectListBox'KFGui.KFTab_Perks.PerkSelectList'

     Begin Object Class=GUISectionBackground Name=BGPerkEffects
         bFillClient=True
         Caption="Perk Effects"
         WinTop=0.029674
         WinLeft=0.486700
         WinWidth=0.491566
         WinHeight=0.369766
         OnPreDraw=BGPerkEffects.InternalPreDraw
     End Object
     i_BGPerkEffects=GUISectionBackground'KFGui.KFTab_Perks.BGPerkEffects'

     Begin Object Class=GUIScrollTextBox Name=PerkEffectsScroll
         CharDelay=0.002500
         EOLDelay=0.100000
         OnCreateComponent=PerkEffectsScroll.InternalOnCreateComponent
         WinTop=0.093121
         WinLeft=0.500554
         WinWidth=0.465143
         WinHeight=0.323477
         TabOrder=9
     End Object
     lb_PerkEffects=GUIScrollTextBox'KFGui.KFTab_Perks.PerkEffectsScroll'

     Begin Object Class=GUISectionBackground Name=BGPerksNextLevel
         bFillClient=True
         Caption="Next Level Requirements"
         WinTop=0.413209
         WinLeft=0.486700
         WinWidth=0.490282
         WinHeight=0.415466
         OnPreDraw=BGPerksNextLevel.InternalPreDraw
     End Object
     i_BGPerkNextLevel=GUISectionBackground'KFGui.KFTab_Perks.BGPerksNextLevel'

     Begin Object Class=KFPerkProgressListBox Name=PerkProgressList
         OnCreateComponent=PerkProgressList.InternalOnCreateComponent
         WinTop=0.476850
         WinLeft=0.499269
         WinWidth=0.463858
         WinHeight=0.341256
     End Object
     lb_PerkProgress=KFPerkProgressListBox'KFGui.KFTab_Perks.PerkProgressList'

     Begin Object Class=GUIButton Name=SaveButton
         Caption="Select Perk"
         Hint="Use Selected Perk"
         WinTop=0.852604
         WinLeft=0.302670
         WinWidth=0.363829
         WinHeight=0.042757
         TabOrder=2
         bBoundToParent=True
         OnClick=KFTab_Perks.OnSaveButtonClicked
         OnKeyEvent=SaveButton.InternalOnKeyEvent
     End Object
     b_Save=GUIButton'KFGui.KFTab_Perks.SaveButton'

     Begin Object Class=GUIButton Name=Done
         Caption="Exit Trader Menu"
         WinTop=0.941472
         WinLeft=0.790508
         WinWidth=0.207213
         WinHeight=0.035000
         OnClick=KFTab_Perks.OnDoneClick
         OnKeyEvent=Cancel.InternalOnKeyEvent
     End Object
     b_Done=GUIButton'KFGui.KFTab_Perks.Done'

     Begin Object Class=GUILabel Name=ChangePerkOncePerWaveLabel
         Caption="You can only change your Perk once per Wave"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.897148
         WinLeft=0.017283
         WinWidth=0.500000
         WinHeight=0.035000
     End Object
     l_ChangePerkOncePerWave=GUILabel'KFGui.KFTab_Perks.ChangePerkOncePerWaveLabel'

     PropagateVisibility=False
     WinTop=0.125000
     WinLeft=0.250000
     WinWidth=0.500000
     WinHeight=0.750000
}
