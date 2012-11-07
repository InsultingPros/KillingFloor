//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4Tab_ServerInfo extends UT2K4Tab_ServerInfo;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    //local string           myStyleName;

	Super.Initcomponent(MyController, MyOwner);

    /*myStyleName = "ROScrollZone";
    lb_Text.MyScrollBar.MyScrollZone.StyleName = myStyleName;
    lb_Text.MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,lb_Text.MyScrollBar.MyScrollZone.FontScale);
    myStyleName = "RORoundScaledButton";
    lb_Text.MyScrollBar.MyGripButton.StyleName = myStyleName;
    lb_Text.MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,lb_Text.MyScrollBar.MyGripButton.FontScale);
    lb_Text.MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
    lb_Text.MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,lb_Text.MyScrollBar.MyIncreaseButton.FontScale);
    lb_Text.MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
    lb_Text.MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,lb_Text.MyScrollBar.MyDecreaseButton.FontScale);
    */
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=InfoText
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         TextAlign=TXTA_Center
         OnCreateComponent=InfoText.InternalOnCreateComponent
         WinTop=0.143750
         WinHeight=0.866016
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lb_Text=GUIScrollTextBox'ROInterface.ROUT2K4Tab_ServerInfo.InfoText'

     Begin Object Class=GUIImage Name=ServerInfoBK1
         Image=Texture'InterfaceArt_tex.Menu.button_normal'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.070779
         WinLeft=0.021641
         WinWidth=0.418437
         WinHeight=0.016522
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_BG=GUIImage'ROInterface.ROUT2K4Tab_ServerInfo.ServerInfoBK1'

     Begin Object Class=GUIImage Name=ServerInfoBK2
         Image=Texture'InterfaceArt_tex.Menu.button_normal'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.070779
         WinLeft=0.576329
         WinWidth=0.395000
         WinHeight=0.016522
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_BG2=GUIImage'ROInterface.ROUT2K4Tab_ServerInfo.ServerInfoBK2'

     Begin Object Class=GUILabel Name=ServerInfoLabel
         Caption="Rules"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.042708
         WinHeight=32.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_Title=GUILabel'ROInterface.ROUT2K4Tab_ServerInfo.ServerInfoLabel'

}
