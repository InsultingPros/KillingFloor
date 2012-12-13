class KFBrowser_Footer extends UT2K4Browser_Footer;

var	localized 	string			StopCaption;

function UpdateActiveButtons(UT2K4Browser_Page CurrentPanel)
{
    if (CurrentPanel == None)
        return;

	UpdateButtonState( b_Join,     CurrentPanel.IsJoinAvailable( b_Join.Caption ) );
	UpdateButtonState( b_Refresh,  CurrentPanel.IsRefreshAvailable( b_Refresh.Caption ) );
	//UpdateButtonState( b_Spectate, CurrentPanel.IsSpectateAvailable( b_Spectate.Caption ) );
	//UpdateButtonState( b_Filter,   CurrentPanel.IsFilterAvailable( b_Filter.Caption ) );
}

function bool InternalOnClick(GUIComponent Sender)
{
    if (GUIButton(Sender) == None)
        return false;

    if (Sender == b_Back)
    {
       	Controller.CloseMenu(False);
    	if ( PlayerOwner().Level.NetMode != NM_Client )
    	{
			Controller.CloseAll(true, true);
			Controller.OpenMenu(Controller.GetMainMenuClass());
        }

        return true;
    }

    if ( Sender == b_Join )
    {
    	p_Anchor.JoinClicked();
    	return true;
    }

    if ( Sender == b_Spectate )
    {
    	p_Anchor.SpectateClicked();
    	return true;
    }

    if ( Sender == b_Refresh )
    {
    	p_Anchor.RefreshClicked();

    	if(  KFServerListPageInternet( p_Anchor .c_Tabs.ActiveTab.MyPanel ) != none )
    	{
    	    if( KFServerListPageInternet( p_Anchor .c_Tabs.ActiveTab.MyPanel ).bQueryRunning  )
    	    {
    	        b_refresh.Caption = StopCaption;
    	    }
            else
    	    {
    	        b_refresh.Caption = KFServerListPageInternet( p_Anchor .c_Tabs.ActiveTab.MyPanel ).RefreshCaption;
    	    }
    	}

    	return true;
    }

    /*if ( Sender == b_Filter )
    {
    	p_Anchor.FilterClicked();
    	return true;
    }
	*/

    return false;
}

function UpdateButtonState( GUIButton But, bool Active )
{
	if ( Active )
		EnableComponent(But);
	else DisableComponent(But);
}

function PositionButtons( Canvas C )
{
//	local bool b;

/*	b                 = b_Filter.bVisible;
	b_Filter.bVisible = false;
*/
	super(ButtonFooter).PositionButtons(C);

/*	b_Filter.bVisible = b;
	b_Filter.WinLeft  = GetMargin();
*/
}

function float GetButtonLeft()
{
//	local bool bWasVisible;
	local float Result;

/*	bWasVisible = b_Filter.bVisible;
	b_Filter.bVisible = False;


	b_Filter.bVisible = bWasVisible;
*/
	Result = super(ButtonFooter).GetButtonLeft();
	return Result;
}

defaultproperties
{
     StopCaption="STOP"
     Begin Object Class=GUITitleBar Name=BrowserStatus
         bUseTextHeight=False
         Justification=TXTA_Left
         FontScale=FNS_Small
         WinTop=0.300000
         WinWidth=0.500000
         WinHeight=0.400000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     t_StatusBar=GUITitleBar'KFGui.KFBrowser_Footer.BrowserStatus'

     b_Spectate=None

     b_Filter=None

     ButtonWidth=0.120000
     Padding=0.400000
}
