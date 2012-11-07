//=============================================================================
// RODemosMenu
//=============================================================================
// The Demos management menu. Most of the code for this comes from the
// UT2K4Demos class.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

//class RODemosMenu extends LockedFloatingWindow;
class RODemosMenu extends LargeWindow;

var automated GUIListBox lb_DemoList,lb_DemoInfo;
var automated GUIScrollTextBox lb_ReqPacks;
var automated GUILabel lbl_Game, l_NoPreview;
var automated GUIImage i_MapShot;
var automated GUISectionBackground sb_1, sb_2, sb_3, sb_4;

var automated GUIButton b_Dump, b_Watch, b_Back;

var localized string ltScoreLimit, ltTimeLimit, UnknownText, CorruptDemText,ltSelectMsg;
var localized string ltClientSide, ltServerSide, ltRecordedBy,ltGoodMsg, ltBadMsg;
var array<CacheManager.MapRecord> Maps;
var array<CacheManager.GameRecord> Games;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<string> Demos;
    local int i;

	Super.InitComponent(MyController,MyOwner);

	class'CacheManager'.static.GetMapList(Maps);
	class'CacheManager'.static.GetGameTypeList(Games);

    MyController.GetDEMList(Demos);
    for (i=0;i<Demos.Length;i++)
    	lb_DemoList.List.Add(TrimName(Demos[i]));

	bInit = False;
    if (lb_DemoList.ItemCount()>0)
	    DemoListClick(none);

	//MyPage.MyFooter.b_Watch.OnClick=WatchClick;
	//MyPage.MyFooter.b_Dump.OnClick=DumpClick;

	sb_1.ManageComponent(lb_DemoList);
	sb_2.Managecomponent(i_MapShot);
	sb_3.ManageComponent(lb_ReqPacks);
}

function string TrimName(string s)
{
	local int p;
	p = InStr(Caps(s),".DEMO4");
	if (p>=0)
		return Left(s,p);

	return s;
}

function bool DumpClick(GUIComponent Sender)
{
	Controller.OpenMenu("GUI2K4.UT2K4Demo2AVI",lb_DemoList.List.Get());
    return true;
}

function bool WatchClick(GUIComponent Sender)
{
	Console(Controller.Master.Console).DelayedConsoleCommand("demoplay"@lb_DemoList.List.Get());

	// Demoplay will frell up if we don't close menus.. Why is it commented out of the
	// engine source anyways?
    Controller.CloseAll(false, true);

    return true;
}

function bool OnCloseButtonClick(GUIComponent Sender)
{
    Controller.RemoveMenu(self);
    return true;
}


function DemoListClick(GUIComponent Sender)
{
	local string MapName, GameType, RecordedBy, TimeStamp,ReqPackages;
    local int	 i, ScoreLimit, TimeLimit, ClientSide;
    local Material Screenie;

	if ( bInit )
		return;

	lb_DemoInfo.List.Clear();
	if ( LB_DemoList.List.ItemCount<=0 )
	{
		lbl_Game.Caption = "";
		sb_2.Caption = "";
		lb_ReqPacks.SetContent("");
		i_MapShot.SetVisibility( false);
		l_NoPreview.SetVisibility( true );
		return;
	}

	if ( Controller.GetDEMHeader(lb_DemoList.List.Get( True )$".DEMO4",MapName,GameType,ScoreLimit,TimeLimit,ClientSide,RecordedBy,TimeStamp,ReqPackages) )
    {
    	lbl_Game.Caption=Caps(MapName);
    	i = GetGameIndex(GameType);

    	if ( i != -1 )
    		sb_2.Caption = Games[i].GameName;
		else sb_2.Caption = UnknownText;

		lb_DemoInfo.List.Add(ltScoreLimit@ScoreLimit@"  "@ltTimeLimit@TimeLimit);

        if (ClientSide!=0)
	        lb_DemoInfo.List.Add(ltClientSide);
    	else
	    	lb_DemoInfo.List.Add(ltServerSide);

       	lb_DemoInfo.List.Add(ltRecordedBy@RecordedBy);

        if (ReqPackages!="")
        	lb_ReqPacks.SetContent(ltBadMsg$"||"$ReqPackages);
        else
        	lb_ReqPacks.SetContent(ltGoodMsg);

		i = GetMapIndex(MapName);
		if ( i != -1 )
			Screenie = Material(DynamicLoadObject(Maps[i].ScreenshotRef, class'Material'));

    }
    else
    {
    	sb_2.Caption="";
        lbl_Game.Caption=UnknownText;
    	lb_DemoInfo.List.Clear();
    	lb_ReqPacks.SetContent(CorruptDemText);
    }

    i_MapShot.Image = Screenie;
	i_MapShot.SetVisibility( Screenie != None );
	l_NoPreview.SetVisibility( Screenie == None );

    lb_ReqPacks.Restart();
    lb_ReqPacks.Stop();

    return;
}

function SetVisibility( bool bIsVisible )
{
	Super.SetVisibility(bIsVisible);

	i_MapShot.SetVisibility( i_MapShot.Image != none );
	l_NoPreview.SetVisibility( i_MapShot.Image == None );
}

function int GetMapIndex( string MapName )
{
	local int i;

	for ( i = 0; i < Maps.Length; i++ )
		if ( Maps[i].MapName ~= MapName )
			return i;

	return -1;
}

function int GetGameIndex( string GameClass )
{
	local int i;

	for ( i = 0; i < Games.Length; i++ )
		if ( Games[i].ClassName ~= GameClass || GameClass ~= ("class " $ Games[i].ClassName ) )
			return i;

	return -1;
}

function InfoClick(GUIComponent Sender)
{
	lb_DemoInfo.List.Index=0;
}

defaultproperties
{
     Begin Object Class=GUIListBox Name=lbDemoList
         bVisibleWhenEmpty=True
         OnCreateComponent=lbDemoList.InternalOnCreateComponent
         WinTop=0.109375
         WinLeft=0.030468
         WinWidth=0.265626
         WinHeight=0.735548
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=RODemosMenu.DemoListClick
     End Object
     lb_DemoList=GUIListBox'ROInterface.RODemosMenu.lbDemoList'

     Begin Object Class=GUIListBox Name=lbDemoInfo
         bVisibleWhenEmpty=True
         OnCreateComponent=lbDemoInfo.InternalOnCreateComponent
         WinTop=0.155622
         WinLeft=0.529180
         WinWidth=0.276054
         WinHeight=0.078998
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         OnChange=RODemosMenu.InfoClick
     End Object
     lb_DemoInfo=GUIListBox'ROInterface.RODemosMenu.lbDemoInfo'

     Begin Object Class=GUIScrollTextBox Name=lbReqPacks
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=lbReqPacks.InternalOnCreateComponent
         WinTop=0.650090
         WinLeft=0.310547
         WinWidth=0.650391
         WinHeight=0.193555
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_ReqPacks=GUIScrollTextBox'ROInterface.RODemosMenu.lbReqPacks'

     Begin Object Class=GUILabel Name=lblGame
         TextAlign=TXTA_Center
         TextColor=(B=0,R=125)
         TextFont="UT2LargeFont"
         WinTop=0.103929
         WinLeft=0.355370
         WinWidth=0.634467
         WinHeight=0.061558
         RenderWeight=0.600000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lbl_Game=GUILabel'ROInterface.RODemosMenu.lblGame'

     Begin Object Class=GUILabel Name=NoPreview
         Caption="No Preview Available"
         TextAlign=TXTA_Center
         TextColor=(B=0,R=125)
         TextFont="UT2HeaderFont"
         bTransparent=False
         bMultiLine=True
         VertAlign=TXTA_Center
         WinTop=0.290546
         WinLeft=0.523305
         WinWidth=0.287844
         WinHeight=0.208806
         RenderWeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_NoPreview=GUILabel'ROInterface.RODemosMenu.NoPreview'

     Begin Object Class=GUIImage Name=iMapShot
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         DropShadowX=8
         DropShadowY=8
         WinHeight=1.000000
         RenderWeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_MapShot=GUIImage'ROInterface.RODemosMenu.iMapShot'

     Begin Object Class=GUISectionBackground Name=sb1
         bFillClient=True
         Caption="Demos"
         BottomPadding=0.200000
         WinTop=0.057205
         WinLeft=0.022249
         WinWidth=0.318642
         WinHeight=0.838661
         RenderWeight=0.500000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sb1.InternalPreDraw
     End Object
     sb_1=GUISectionBackground'ROInterface.RODemosMenu.sb1'

     Begin Object Class=GUISectionBackground Name=sb2
         bFillClient=True
         bNoCaption=True
         WinTop=0.228215
         WinLeft=0.481726
         WinWidth=0.368224
         WinHeight=0.322830
         RenderWeight=0.500000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sb2.InternalPreDraw
     End Object
     sb_2=GUISectionBackground'ROInterface.RODemosMenu.sb2'

     Begin Object Class=GUISectionBackground Name=sb3
         bFillClient=True
         Caption="Required Packages"
         LeftPadding=0.020000
         RightPadding=0.020000
         WinTop=0.598785
         WinLeft=0.352934
         WinWidth=0.624778
         WinHeight=0.296317
         RenderWeight=0.500000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sb3.InternalPreDraw
     End Object
     sb_3=GUISectionBackground'ROInterface.RODemosMenu.sb3'

     Begin Object Class=GUISectionBackground Name=iInfoBk
         Caption="Information"
         WinTop=0.059057
         WinLeft=0.352934
         WinWidth=0.624778
         WinHeight=0.537501
         RenderWeight=0.200000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=iInfoBk.InternalPreDraw
     End Object
     sb_4=GUISectionBackground'ROInterface.RODemosMenu.iInfoBk'

     Begin Object Class=GUIButton Name=BB4
         Caption="Watch Demo"
         Hint="Watch the selected demo"
         WinTop=0.908333
         WinLeft=0.701251
         WinWidth=0.120000
         WinHeight=0.036482
         TabOrder=4
         bBoundToParent=True
         OnClick=RODemosMenu.WatchClick
         OnKeyEvent=BB4.InternalOnKeyEvent
     End Object
     b_Watch=GUIButton'ROInterface.RODemosMenu.BB4'

     Begin Object Class=GUIButton Name=BB2
         Caption="Close"
         Hint="Close this dialog"
         WinTop=0.908333
         WinLeft=0.847501
         WinWidth=0.120000
         WinHeight=0.036482
         TabOrder=4
         bBoundToParent=True
         OnClick=RODemosMenu.OnCloseButtonClick
         OnKeyEvent=BB2.InternalOnKeyEvent
     End Object
     b_Back=GUIButton'ROInterface.RODemosMenu.BB2'

     ltScoreLimit="Score Limit:"
     ltTimeLimit="Time Limit:"
     UnknownText="Unknown"
     CorruptDemText="Corrupted or missing .DEMO4 file !"
     ltSelectMsg="Please select a demo from the list to the left."
     ltClientSide="Client Side Demo"
     ltServerSide="Server Side/Single Player Demo"
     ltRecordedBy="Recorded By:"
     ltGoodMsg="All of the packages required for this demo are installed"
     ltBadMsg="In order to be played, this demo requires the packages listed below.  If you are connected to the Internet, they will be autodownloaded when the demo is played||::Required Packages::"
     WindowName="Demo Management"
     WinTop=0.050000
     WinLeft=0.050000
     WinWidth=0.900000
     WinHeight=0.900000
}
