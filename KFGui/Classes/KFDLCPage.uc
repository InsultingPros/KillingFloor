class KFDLCPage extends UT2K4MainPage;

var() UT2K4TabPanel		ActivePanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

    Super.InitComponent(MyController, MyOwner);

	for ( i = 0; i < PanelCaption.Length && i < PanelClass.Length && i < PanelHint.Length; i++ )
	{
		log("KFDLCPage:" @ i @ c_Tabs.AddTab(PanelCaption[i], PanelClass[i],, PanelHint[i]));
	}

	for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
	{
		log("KFDLCPage:" @ i);
	}
}

event Opened(GUIComponent Sender)
{
	super.Opened(Sender);
	c_Tabs.ActivateTabByName(PanelCaption[0], true);
}

function InternalOnChange(GUIComponent Sender)
{
	Super.InternalOnChange(Sender);

	if ( c_Tabs.ActiveTab == None )
	{
		ActivePanel = None;
	}
	else
	{
		ActivePanel = UT2K4TabPanel(c_Tabs.ActiveTab.MyPanel);
	}
}

function BackButtonClicked()
{
	c_Tabs.ActiveTab.OnDeActivate();
	Controller.CloseMenu(False);
}

defaultproperties
{
     Begin Object Class=GUIHeader Name=Header
         Caption="DLC Content"
         WinHeight=25.000000
         RenderWeight=0.300000
     End Object
     t_Header=GUIHeader'KFGui.KFDLCPage.Header'

     Begin Object Class=KFDLCPage_Footer Name=Footer
         RenderWeight=0.300000
         TabOrder=4
         OnPreDraw=Footer.InternalOnPreDraw
     End Object
     t_Footer=KFDLCPage_Footer'KFGui.KFDLCPage.Footer'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'KillingFloor2HUD.Menu.menuBackground'
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         RenderWeight=0.010000
     End Object
     i_Background=BackgroundImage'KFGui.KFDLCPage.PageBackground'

     PanelClass(0)="KFGui.KFTab_DLCAll"
     PanelClass(1)="KFGui.KFTab_DLCCharacters"
     PanelClass(2)="KFGui.KFTab_DLCWeapons"
     PanelCaption(0)="Show All"
     PanelCaption(1)="Characters"
     PanelCaption(2)="Weapons"
     PanelHint(0)="View All DLC Packs"
     PanelHint(1)="Show only Character DLC Packs"
     PanelHint(2)="Show only Weapon DLC Packs"
     BackgroundColor=(B=0,G=0,R=0)
}
