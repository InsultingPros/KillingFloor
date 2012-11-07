class KFTab_Achievements extends UT2K4TabPanel;

var	automated GUISectionBackground	i_BGAchievements;
var	automated GUIProgressBar		pb_AchievementProgress;
var	automated GUILabel				l_AchievementProgress;
var	automated KFAchievementsListBox	lb_Achievements;

var	localized string	OutOfString;
var	localized string	UnlockedString;

function ShowPanel(bool bShow)
{
	local KFSteamStatsAndAchievements KFStatsAndAchievements;
	local int CompletedCount;

	if ( bShow )
	{
		if ( PlayerOwner() != none )
		{
			KFStatsAndAchievements = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements);

			if ( KFStatsAndAchievements != none )
			{
				// Initialize the List
				lb_Achievements.List.InitList(KFStatsAndAchievements);

				// Initialize Achievement Progress
				CompletedCount = KFStatsAndAchievements.GetAchievementCompletedCount();
				pb_AchievementProgress.Value = CompletedCount;
				pb_AchievementProgress.High = KFStatsAndAchievements.Achievements.Length;
				l_AchievementProgress.Caption = CompletedCount @ OutOfString @ KFStatsAndAchievements.Achievements.Length @ UnlockedString;
		    }
		}
	}

	super.ShowPanel(bShow);
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BGAchievements
         HeaderBase=Texture'KF_InterfaceArt_tex.Menu.Med_border'
         Caption="My Achievements"
         WinTop=0.018000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.960000
         OnPreDraw=BGAchievements.InternalPreDraw
     End Object
     i_BGAchievements=GUISectionBackground'KFGui.KFTab_Achievements.BGAchievements'

     Begin Object Class=GUIProgressBar Name=AchievementProgressBar
         BarBack=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
         BarTop=Texture'InterfaceArt_tex.Menu.progress_bar'
         BarColor=(B=255,G=255)
         CaptionWidth=0.000000
         bShowValue=False
         BorderSize=3.000000
         WinTop=0.090000
         WinLeft=0.180867
         WinWidth=0.655610
         WinHeight=0.030000
         RenderWeight=1.200000
     End Object
     pb_AchievementProgress=GUIProgressBar'KFGui.KFTab_Achievements.AchievementProgressBar'

     Begin Object Class=GUILabel Name=AchievementProgressLabel
         Caption="0 of 0 unlocked"
         TextColor=(B=192,G=192,R=192)
         WinTop=0.120000
         WinLeft=0.180867
         WinWidth=0.655610
         WinHeight=0.030000
     End Object
     l_AchievementProgress=GUILabel'KFGui.KFTab_Achievements.AchievementProgressLabel'

     Begin Object Class=KFAchievementsListBox Name=AchievementsList
         OnCreateComponent=AchievementsList.InternalOnCreateComponent
         WinTop=0.187382
         WinLeft=0.072959
         WinWidth=0.851529
         WinHeight=0.777808
     End Object
     lb_Achievements=KFAchievementsListBox'KFGui.KFTab_Achievements.AchievementsList'

     OutOfString="of"
     UnlockedString="unlocked"
     WinTop=0.150000
     WinHeight=0.720000
}
