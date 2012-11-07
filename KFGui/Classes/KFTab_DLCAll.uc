class KFTab_DLCAll extends UT2K4TabPanel;

var	automated GUISectionBackground	i_BGDLC;
var	automated KFDLCListBox			lb_DLC;

function ShowPanel(bool bShow)
{
	if ( bShow )
	{
		if ( PlayerOwner() != none )
		{
			// Initialize the List
			lb_DLC.List.InitList(PlayerOwner(), PlayerOwner().SteamStatsAndAchievements, lb_DLC.bShowCharacters, lb_DLC.bShowWeapons);
		}
	}

	super.ShowPanel(bShow);
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BGDLC
         HeaderBase=Texture'KF_InterfaceArt_tex.Menu.Med_border'
         WinTop=0.018000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.960000
         OnPreDraw=BGDLC.InternalPreDraw
     End Object
     i_BGDLC=GUISectionBackground'KFGui.KFTab_DLCAll.BGDLC'

     Begin Object Class=KFDLCListBox Name=DLCList
         bShowCharacters=True
         bShowWeapons=True
         OnCreateComponent=DLCList.InternalOnCreateComponent
         WinTop=0.090000
         WinLeft=0.072959
         WinWidth=0.851529
         WinHeight=0.867808
     End Object
     lb_DLC=KFDLCListBox'KFGui.KFTab_DLCAll.DLCList'

     WinTop=0.150000
     WinHeight=0.720000
}
