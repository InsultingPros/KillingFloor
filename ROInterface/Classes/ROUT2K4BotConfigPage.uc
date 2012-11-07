//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4BotConfigPage extends UT2K4BotConfigPage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    /*myStyleName = "ROTitleBar";
    t_WindowTitle.StyleName = myStyleName;
    t_WindowTitle.Style = MyController.GetStyle(myStyleName,t_WindowTitle.FontScale);*/
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=PicBK
         WinTop=0.078391
         WinLeft=0.026150
         WinWidth=0.290820
         WinHeight=0.638294
         OnPreDraw=PicBK.InternalPreDraw
     End Object
     sb_PicBK=GUISectionBackground'ROInterface.ROUT2K4BotConfigPage.PicBK'

     Begin Object Class=AltSectionBackground Name=InternalFrameImage
         WinTop=0.075000
         WinLeft=0.040000
         WinWidth=0.675859
         WinHeight=0.550976
         OnPreDraw=InternalFrameImage.InternalPreDraw
     End Object
     sb_Main=AltSectionBackground'ROInterface.ROUT2K4BotConfigPage.InternalFrameImage'

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
     i_FrameBG=FloatingImage'ROInterface.ROUT2K4BotConfigPage.FloatingFrameBackground'

}
