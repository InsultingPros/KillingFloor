class KFDLCPage_Footer extends UT2K4Settings_Footer;

var KFDLCPage DLCPage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);
    DLCPage = KFDLCPage(MyOwner);
	b_Defaults.SetVisibility(false);
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_Back)
	{
    	DLCPage.BackButtonClicked();
	}

	return true;
}

defaultproperties
{
}
