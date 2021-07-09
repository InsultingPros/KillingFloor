//-----------------------------------------------------------
// ROCommunicationPage
// Programmed by Puma
// Last change: 05.16.2004
//
// Contains the main menu for Voice Communication
// Copyright 2004 by Red Orchestra
///-----------------------------------------------------------
class ROCommunicationPage extends LargeWindow;

var(MidGame) array<GUITabItem> Panels;
var(MidGame) GUITabItem        SPRulesPanel;
var(MidGame) GUITabItem        IARulesPanel;

var(MidGame) automated GUITabControl c_Main;

var automated GUIButton b_Reset, b_Close;

var ROUT2K4Tab_MidGameVoiceChat mainpanel;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	local PlayerController PC;
	local string saved_caption;

	Super.InitComponent(MyController, MyComponent);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

	// rjp -- when playing SinglePlayer or InstantAction game, remove tabs which only apply to multiplayer
	PC = PlayerOwner();
//    if ( PC != None && PC.Level.NetMode == NM_StandAlone )
//		RemoveMultiplayerTabs(PC.Level.Game);
	// -- rjp

    saved_caption = Panels[0].Caption;

	if ( Panels.Length > 0 )
		AddPanels();

	SetTitle();
	//T_WindowTitle.DockedTabs = c_Main;

    /*myStyleName = "ROTitleBar";
    T_WindowTitle.StyleName = myStyleName;
    T_WindowTitle.Style = MyController.GetStyle(myStyleName,t_WindowTitle.FontScale);

    c_Main.bFillSpace = True;
	// Change the Style of the Tabs; Puma 05-11-2004
    */
    /*myStyleName = "ROTabButton";
	for ( i = 0; i < c_Main.TabStack.Length; i++ )
	{
		if ( c_Main.TabStack[i] != None )
		{
			c_Main.TabStack[i].FontScale=FNS_Small;
			c_Main.TabStack[i].bAutoSize=True;
			c_Main.TabStack[i].bAutoShrink=False;
            //c_Main.TabStack[i].StyleName = myStyleName;
            //c_Main.TabStack[i].Style = MyController.GetStyle(myStyleName,c_Main.FontScale);
        }
	} */

	c_Main.TabStack[0].SetVisibility(false);
	mainpanel = ROUT2K4Tab_MidGameVoiceChat(c_Main.BorrowPanel(saved_caption));
	mainpanel.b_Reset = b_Reset;
}

function bool FloatingPreDraw( Canvas C )
{
	if (PlayerOwner().GameReplicationInfo!=None)
		SetVisibility(true);
	else
		SetVisibility(false);

	return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_Reset )
	{
	    return mainpanel.InternalOnClick(Sender);
	}
    else if (Sender == b_Close)
    {
        Controller.CloseMenu(False);
    }

    return false;
}


function InternalOnClose(optional Bool bCanceled)
{
	local PlayerController PC;

	PC = PlayerOwner();

	// Turn pause off if currently paused
	if(PC != None && PC.Level.Pauser != None)
		PC.SetPause(false);

	Super.OnClose(bCanceled);
}

function AddPanels()
{
	local int i;
	local MidGamePanel Panel;

	for ( i = 0; i < Panels.Length; i++ )
	{
		Panel = MidGamePanel(c_Main.AddTabItem(Panels[i]));
		if ( Panel != None )
			Panel.ModifiedChatRestriction = UpdateChatRestriction;
	}
}

// Called via delegate by a MidGamePanel when a player chat restriction has been updated
// this notifies all other panels about the change
function UpdateChatRestriction( MidGamePanel Sender, int PlayerID )
{
	local int i;

	if ( Sender == None )
		return;

	for ( i = 0; i < c_Main.TabStack.Length; i++ )
	{
		if ( c_Main.TabStack[i] != None && MidGamePanel(c_Main.TabStack[i].MyPanel) != None &&
			c_Main.TabStack[i].MyPanel != Sender )
			MidGamePanel(c_Main.TabStack[i].MyPanel).UpdateChatRestriction(PlayerID);
	}
}

function SetTitle()
{
	local PlayerController PC;

	PC = PlayerOwner();
	if ( PC.Level.NetMode == NM_StandAlone || PC.GameReplicationInfo == None || PC.GameReplicationInfo.ServerName == "" )
		WindowName = PC.Level.GetURLMap();
	else WindowName = PC.GameReplicationInfo.ServerName;

	t_WindowTitle.SetCaption(WindowName);
}

function RemoveMultiplayerTabs(GameInfo Game)
{

	Panels.Remove(0,1);
/****\
	if (Game.CurrentGameProfile != none)
		Panels[2] = SPRulesPanel; //there's no map rotation in a single player tournament

	Panels.Remove(3,1);
	Panels.Remove(1,1);
\*****/
}

event bool NotifyLevelChange()
{
	bPersistent = false;
	LevelChanged();
	return true;
}

/*function bool SystemMenuPreDraw(canvas Canvas)
{
	b_ExitButton.SetPosition( t_WindowTitle.ActualLeft() + (t_WindowTitle.ActualWidth()-35), t_WindowTitle.ActualTop()+10, 24, 24, true);
	return true;
}*/

defaultproperties
{
     Panels(0)=(ClassName="ROInterface.ROUT2K4Tab_MidGameVoiceChat",Caption="Communication",Hint="Manage communication with other players")
     SPRulesPanel=(ClassName="ROInterface.ROUT2K4Tab_ServerInfo",Caption="Rules",Hint="Game settings")
     Begin Object Class=GUITabControl Name=LoginMenuTC
         bFillSpace=True
         bDockPanels=True
         TabHeight=0.000000
         WinTop=0.050000
         WinLeft=0.012500
         WinWidth=0.974999
         WinHeight=0.900000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=LoginMenuTC.InternalOnActivate
     End Object
     c_Main=GUITabControl'ROInterface.ROCommunicationPage.LoginMenuTC'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Reset"
         MenuState=MSAT_Disabled
         Hint="Reset & reload all player chat restrictions"
         WinTop=0.841335
         WinLeft=0.607745
         WinWidth=0.120067
         TabOrder=7
         bStandardized=True
         OnClick=ROCommunicationPage.InternalOnClick
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     b_Reset=GUIButton'ROInterface.ROCommunicationPage.ResetButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         Hint="Close this window"
         WinTop=0.841335
         WinLeft=0.738995
         WinWidth=0.120067
         TabOrder=8
         bStandardized=True
         OnClick=ROCommunicationPage.InternalOnClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     b_Close=GUIButton'ROInterface.ROCommunicationPage.CloseButton'

     DefaultLeft=0.110313
     DefaultTop=0.057916
     DefaultWidth=0.779688
     DefaultHeight=0.847083
     bPersistent=True
     bAllowedAsLast=True
     WinTop=0.057916
     WinLeft=0.110313
     WinWidth=0.779688
     WinHeight=0.847083
}
