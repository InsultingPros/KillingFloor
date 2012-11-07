//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4BotInfoPage extends UT2K4BotInfoPage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    /*myStyleName = "ROTitleBar";
    t_WindowTitle.StyleName = myStyleName;
    t_WindowTitle.Style = MyController.GetStyle(myStyleName,t_WindowTitle.FontScale);*/

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

defaultproperties
{
     Begin Object Class=GUIImage Name=imgBotPic
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.097923
         WinLeft=0.079861
         WinWidth=0.246875
         WinHeight=0.866809
         RenderWeight=1.010000
     End Object
     i_Portrait=GUIImage'ROInterface.ROUT2K4BotInfoPage.imgBotPic'

     Begin Object Class=GUIScrollTextBox Name=DecoDescription
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=DecoDescription.InternalOnCreateComponent
         WinTop=0.613447
         WinLeft=0.353008
         WinWidth=0.570936
         WinHeight=0.269553
         bNeverFocus=True
     End Object
     lb_Deco=GUIScrollTextBox'ROInterface.ROUT2K4BotInfoPage.DecoDescription'

     Begin Object Class=GUISectionBackground Name=PicBK
         WinTop=0.057558
         WinLeft=0.026150
         WinWidth=0.290820
         WinHeight=0.661731
         OnPreDraw=PicBK.InternalPreDraw
     End Object
     sb_PicBK=GUISectionBackground'ROInterface.ROUT2K4BotInfoPage.PicBK'

     Begin Object Class=AltSectionBackground Name=HistBk
         LeftPadding=0.010000
         RightPadding=0.010000
         WinTop=0.515790
         WinLeft=0.357891
         WinWidth=0.546522
         WinHeight=0.269553
         OnPreDraw=HistBk.InternalPreDraw
     End Object
     sb_HistBK=AltSectionBackground'ROInterface.ROUT2K4BotInfoPage.HistBk'

     Begin Object Class=AltSectionBackground Name=InternalFrameImage
         WinTop=0.075000
         WinLeft=0.040000
         WinWidth=0.675859
         WinHeight=0.550976
         OnPreDraw=InternalFrameImage.InternalPreDraw
     End Object
     sb_Main=AltSectionBackground'ROInterface.ROUT2K4BotInfoPage.InternalFrameImage'

     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'InterfaceArt_tex.Menu.button_normal'
         DropShadow=None
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.020000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=0.980000
         RenderWeight=0.000003
     End Object
     i_FrameBG=FloatingImage'ROInterface.ROUT2K4BotInfoPage.FloatingFrameBackground'

}
