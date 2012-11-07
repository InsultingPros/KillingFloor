//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4Tab_PlayerSettings extends UT2K4Tab_PlayerSettings;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local string           myStyleName;

	Super.Initcomponent(MyController, MyOwner);

	RemoveComponent(co_SkinPreview);

   	SpinnyDude.SetDrawScale(0.7);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    myStyleName = "NoBackground";
    b_DropTarget.StyleName = myStyleName;
    b_DropTarget.Style = MyController.GetStyle(myStyleName,b_DropTarget.FontScale);
}

function bool PickModel(GUIComponent Sender)
{
    if ( Controller.OpenMenu("ROInterface.ROUT2K4ModelSelect",
                              PlayerRec.DefaultName,
		                      Eval(Controller.CtrlPressed, PlayerRec.Race, "")) )
    	Controller.ActivePage.OnClose = ModelSelectClosed;

    return true;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=PlayerBK1
         Caption="3D View"
         WinTop=0.017969
         WinLeft=0.004063
         WinWidth=0.446758
         WinHeight=0.863631
         OnPreDraw=PlayerBK1.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'ROInterface.ROUT2K4Tab_PlayerSettings.PlayerBK1'

     Begin Object Class=GUISectionBackground Name=PlayerBK2
         Caption="Misc."
         WinTop=0.017969
         WinLeft=0.463047
         WinWidth=0.531719
         WinHeight=0.573006
         OnPreDraw=PlayerBK2.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'ROInterface.ROUT2K4Tab_PlayerSettings.PlayerBK2'

     Begin Object Class=GUISectionBackground Name=PlayerBK3
         bFillClient=True
         Caption="Biography"
         LeftPadding=0.020000
         RightPadding=0.020000
         TopPadding=0.020000
         BottomPadding=0.020000
         WinTop=0.610417
         WinLeft=0.463047
         WinWidth=0.531719
         WinHeight=0.272811
         OnPreDraw=PlayerBK3.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'ROInterface.ROUT2K4Tab_PlayerSettings.PlayerBK3'

     Begin Object Class=GUIImage Name=PlayerPortrait
         Image=Texture'InterfaceArt_tex.Menu.changeme_texture'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         IniOption="@Internal"
         WinTop=0.094895
         WinLeft=0.057016
         WinWidth=0.292470
         WinHeight=0.698132
         RenderWeight=0.300000
         OnDraw=UT2K4Tab_PlayerSettings.InternalDraw
         OnLoadINI=UT2K4Tab_PlayerSettings.InternalOnLoadINI
     End Object
     i_Portrait=GUIImage'ROInterface.ROUT2K4Tab_PlayerSettings.PlayerPortrait'

     Begin Object Class=GUIButton Name=bPickModel
         Caption="Change Character"
         Hint="Select a new Character."
         WinTop=0.801559
         WinLeft=0.177174
         WinWidth=0.233399
         WinHeight=0.050000
         TabOrder=2
         OnClick=UT2K4Tab_PlayerSettings.PickModel
         OnKeyEvent=bPickModel.InternalOnKeyEvent
     End Object
     b_Pick=GUIButton'ROInterface.ROUT2K4Tab_PlayerSettings.bPickModel'

     Begin Object Class=GUIButton Name=Player3DView
         Caption="3D View"
         Hint="Toggle between 3D view and portrait of character."
         WinTop=0.801559
         WinLeft=0.043685
         WinWidth=0.130720
         WinHeight=0.050000
         TabOrder=1
         OnClick=UT2K4Tab_PlayerSettings.Toggle3DView
         OnKeyEvent=Player3DView.InternalOnKeyEvent
     End Object
     b_3DView=GUIButton'ROInterface.ROUT2K4Tab_PlayerSettings.Player3DView'

     Begin Object Class=GUIButton Name=DropTarget
         StyleName="NoBackground"
         WinTop=0.064426
         WinLeft=0.013071
         WinWidth=0.427141
         WinHeight=0.698132
         MouseCursorIndex=5
         bTabStop=False
         bNeverFocus=True
         bDropTarget=True
         OnKeyEvent=DropTarget.InternalOnKeyEvent
         OnCapturedMouseMove=UT2K4Tab_PlayerSettings.RaceCapturedMouseMove
     End Object
     b_DropTarget=GUIButton'ROInterface.ROUT2K4Tab_PlayerSettings.DropTarget'

}
