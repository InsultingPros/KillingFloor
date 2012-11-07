//=============================================================================
// ROMapVotingPage
//=============================================================================
// Modified Map Voting page
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROMapVotingPage extends MapVotingPage;

function bool AlignBK(Canvas C)
{
	i_MapCountListBackground.WinWidth  = lb_VoteCountListbox.MyList.ActualWidth();
	i_MapCountListBackground.WinHeight = lb_VoteCountListbox.MyList.ActualHeight();
	i_MapCountListBackground.WinLeft   = lb_VoteCountListbox.MyList.ActualLeft();
	i_MapCountListBackground.WinTop    = lb_VoteCountListbox.MyList.ActualTop();

	return false;
}

defaultproperties
{
     Begin Object Class=MapVoteCountMultiColumnListBox Name=VoteCountListBox
         HeaderColumnPerc(0)=0.400000
         HeaderColumnPerc(1)=0.200000
         DefaultListClass="ROInterface.ROMapVoteCountMultiColumnList"
         bVisibleWhenEmpty=True
         OnCreateComponent=VoteCountListBox.InternalOnCreateComponent
         WinTop=0.077369
         WinLeft=0.020000
         WinWidth=0.960000
         WinHeight=0.267520
         bBoundToParent=True
         bScaleToParent=True
         OnRightClick=VoteCountListBox.InternalOnRightClick
     End Object
     lb_VoteCountListBox=MapVoteCountMultiColumnListBox'ROInterface.ROMapVotingPage.VoteCountListBox'

     Begin Object Class=moComboBox Name=GameTypeCombo
         CaptionWidth=0.350000
         Caption="Filter Game Type:"
         OnCreateComponent=GameTypeCombo.InternalOnCreateComponent
         bScaleToParent=True
         bVisible=False
     End Object
     co_GameType=moComboBox'ROInterface.ROMapVotingPage.GameTypeCombo'

     i_MapListBackground=None

     Begin Object Class=GUIImage Name=MapCountListBackground
         Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border_SlightTransparent'
         ImageStyle=ISTY_Stretched
         OnDraw=ROMapVotingPage.AlignBK
     End Object
     i_MapCountListBackground=GUIImage'ROInterface.ROMapVotingPage.MapCountListBackground'

}
