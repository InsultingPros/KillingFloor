//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4Tab_BotConfigMP extends UT2K4Tab_BotConfigMP;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);

}

function bool InternalOnClick(GUIComponent Sender)
{
    if (Sender==b_Left)
    {
    	li_Bots.SetFocus(none);
        li_Bots.PgUp();
        return true;
    }

    if (Sender==b_Right)
    {
    	li_Bots.SetFocus(none);
        li_Bots.PgDown();
        return true;
    }

    if (Sender == b_AddR)
    {
        bIgnoreListChange = True;
		li_Red.Add( li_Bots.GetPortrait(), li_Bots.Index );
        return true;
    }

    if (Sender == b_AddB)
    {
        bIgnoreListChange = True;
		li_Blue.Add( li_Bots.GetPortrait(), li_Bots.Index );
        return true;
    }

    if (Sender == b_RemoveR)
    {
        li_Red.Remove(li_Red.Index);
        return true;
    }

    if (Sender == b_RemoveB)
    {
        li_Blue.Remove(li_Blue.Index);
        return true;
    }

    if (Sender == b_Config)
    {
        if (Controller.OpenMenu("ROInterface.ROUT2K4BotInfoPage"))
            UT2K4BotInfoPage(Controller.ActivePage).SetupBotInfo(li_bots.GetPortrait(), li_Bots.GetDecoText(), li_Bots.GetRecord());
        return true;
    }
    if (Sender == b_DoConfig)
    {
//        if (Controller.OpenMenu("GUI2K4.UT2K4BotConfigPage"))
        if (Controller.OpenMenu("ROInterface.ROUT2K4BotConfigPage"))
            UT2K4BotConfigPage(Controller.ActivePage).SetupBotInfo(li_Bots.GetPortrait(), li_Bots.GetDecoText(), li_Bots.GetRecord());
        return true;
    }

    return false;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BotConfigMainBG
         Caption="Drag a character on to its respective team"
         WinTop=0.650734
         WinLeft=0.058516
         WinWidth=0.887501
         WinHeight=0.328047
         OnPreDraw=BotConfigMainBG.InternalPreDraw
     End Object
     sb_Bots=GUISectionBackground'ROInterface.ROUT2K4Tab_BotConfigMP.BotConfigMainBG'

     Begin Object Class=GUISectionBackground Name=BotConfigRedBackground
         Caption="Red Team"
         WinTop=0.008334
         WinLeft=0.011758
         WinWidth=0.358731
         WinHeight=0.576876
         OnPreDraw=BotConfigRedBackground.InternalPreDraw
     End Object
     sb_Red=GUISectionBackground'ROInterface.ROUT2K4Tab_BotConfigMP.BotConfigRedBackground'

     Begin Object Class=GUISectionBackground Name=BotConfigBlueBackground
         Caption="Axis Team"
         WinTop=0.008334
         WinLeft=0.629743
         WinWidth=0.358731
         WinHeight=0.576876
         OnPreDraw=BotConfigBlueBackground.InternalPreDraw
     End Object
     sb_Blue=GUISectionBackground'ROInterface.ROUT2K4Tab_BotConfigMP.BotConfigBlueBackground'

     Begin Object Class=AltSectionBackground Name=BotConfigPortraitBackground
         FontScale=FNS_Small
         WinTop=0.037820
         WinLeft=0.392777
         WinWidth=0.220218
         WinHeight=0.512104
         OnPreDraw=BotConfigPortraitBackground.InternalPreDraw
     End Object
     sb_PBK=AltSectionBackground'ROInterface.ROUT2K4Tab_BotConfigMP.BotConfigPortraitBackground'

     Begin Object Class=GUICharacterList Name=BotConfigCharList
         StyleName="CharButton"
         Hint="To add a bot, drag the portrait to the desired team's list, or use the arrow buttons above"
         WinTop=0.714826
         WinLeft=0.139140
         WinWidth=0.724609
         WinHeight=0.236758
         TabOrder=7
         bDropSource=True
         bDropTarget=True
         OnClick=BotConfigCharList.InternalOnClick
         OnRightClick=BotConfigCharList.InternalOnRightClick
         OnMousePressed=BotConfigCharList.InternalOnMousePressed
         OnMouseRelease=BotConfigCharList.InternalOnMouseRelease
         OnChange=UT2K4Tab_BotConfigBase.CharListChange
         OnKeyEvent=BotConfigCharList.InternalOnKeyEvent
         OnBeginDrag=UT2K4Tab_BotConfigBase.InternalOnBeginDrag
         OnEndDrag=BotConfigCharList.InternalOnEndDrag
         OnDragDrop=BotConfigCharList.InternalOnDragDrop
         OnDragEnter=BotConfigCharList.InternalOnDragEnter
         OnDragLeave=BotConfigCharList.InternalOnDragLeave
         OnDragOver=BotConfigCharList.InternalOnDragOver
     End Object
     li_Bots=GUICharacterList'ROInterface.ROUT2K4Tab_BotConfigMP.BotConfigCharList'

     Begin Object Class=GUIImage Name=BotConfigPortrait
         DropShadow=Texture'InterfaceArt_tex.Menu.changeme_texture'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         DropShadowY=6
         WinTop=0.003986
         WinLeft=0.400000
         WinWidth=0.200000
         WinHeight=0.573754
         RenderWeight=1.101000
     End Object
     i_Portrait=GUIImage'ROInterface.ROUT2K4Tab_BotConfigMP.BotConfigPortrait'

     Begin Object Class=GUIVertImageListBox Name=BotConfigRedList
         ImageScale=0.200000
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=BotConfigRedList.InternalOnCreateComponent
         Hint="These are the bots that will play on the red team"
         WinTop=0.060750
         WinLeft=0.014258
         WinWidth=0.345352
         WinHeight=0.504883
         TabOrder=0
         OnChange=UT2K4Tab_BotConfigBase.ListChange
     End Object
     lb_Red=GUIVertImageListBox'ROInterface.ROUT2K4Tab_BotConfigMP.BotConfigRedList'

     Begin Object Class=GUIVertImageListBox Name=BotConfigBlueList
         ImageScale=0.200000
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=BotConfigBlueList.InternalOnCreateComponent
         Hint="These are the bots that will play on the blue team"
         WinTop=0.060750
         WinLeft=0.634728
         WinWidth=0.345352
         WinHeight=0.504883
         TabOrder=5
         OnChange=UT2K4Tab_BotConfigBase.ListChange
     End Object
     lb_Blue=GUIVertImageListBox'ROInterface.ROUT2K4Tab_BotConfigMP.BotConfigBlueList'

     Begin Object Class=GUIButton Name=IABotConfigConfig
         Caption="Info"
         Hint="View detailed stats for this bot."
         WinTop=0.593949
         WinLeft=0.357306
         WinWidth=0.136563
         WinHeight=0.049765
         TabOrder=9
         OnClick=ROUT2K4Tab_BotConfigMP.InternalOnClick
         OnKeyEvent=IABotConfigConfig.InternalOnKeyEvent
     End Object
     b_Config=GUIButton'ROInterface.ROUT2K4Tab_BotConfigMP.IABotConfigConfig'

     Begin Object Class=GUIButton Name=BotLeft
         StyleName="ArrowLeft"
         WinTop=0.790963
         WinLeft=0.101953
         WinWidth=0.043555
         WinHeight=0.084414
         TabOrder=6
         bNeverFocus=True
         bRepeatClick=True
         OnClick=UT2K4Tab_BotConfigBase.InternalOnClick
         OnKeyEvent=BotLeft.InternalOnKeyEvent
     End Object
     b_Left=GUIButton'ROInterface.ROUT2K4Tab_BotConfigMP.BotLeft'

     Begin Object Class=GUIButton Name=BotRight
         StyleName="ArrowRight"
         WinTop=0.790963
         WinLeft=0.854649
         WinWidth=0.043555
         WinHeight=0.084414
         TabOrder=8
         bNeverFocus=True
         bRepeatClick=True
         OnClick=UT2K4Tab_BotConfigBase.InternalOnClick
         OnKeyEvent=BotRight.InternalOnKeyEvent
     End Object
     b_Right=GUIButton'ROInterface.ROUT2K4Tab_BotConfigMP.BotRight'

     Begin Object Class=GUIButton Name=IABotConfigDoConfig
         Caption="Edit"
         Hint="Customize the AI attributes for this bot"
         WinTop=0.593949
         WinLeft=0.505743
         WinWidth=0.136563
         WinHeight=0.049765
         TabOrder=10
         OnClick=ROUT2K4Tab_BotConfigMP.InternalOnClick
         OnKeyEvent=IABotConfigDoConfig.InternalOnKeyEvent
     End Object
     b_DoConfig=GUIButton'ROInterface.ROUT2K4Tab_BotConfigMP.IABotConfigDoConfig'

     RedCaption="Allies Team"
}
