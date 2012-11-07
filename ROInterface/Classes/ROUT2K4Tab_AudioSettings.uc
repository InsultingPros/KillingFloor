//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4Tab_AudioSettings extends UT2K4Tab_AudioSettings;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

    co_StatusAnnouncer = None;
    co_RewardAnnouncer = None;

	Super.InitComponent(MyController, MyOwner);

	i_BG2.WinWidth=0.453398;
	i_BG2.WinHeight=0.353045;
	i_BG2.WinLeft=0.004063;
	i_BG2.WinTop=0.540831;

	i_BG3.WinWidth=0.475078;
	i_BG3.WinHeight=0.353045;
	i_BG3.WinLeft=0.468712;
	i_BG3.WinTop=0.540831;

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=AudioBK1
         Caption="Sound Effects"
         NumColumns=2
         MaxPerColumn=5
         WinTop=0.017393
         WinLeft=0.004063
         WinWidth=0.937773
         WinHeight=0.502850
         OnPreDraw=AudioBK1.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'ROInterface.ROUT2K4Tab_AudioSettings.AudioBK1'

     Begin Object Class=GUISectionBackground Name=AudioBK2
         Caption="Announcer"
         WinTop=0.004372
         WinLeft=0.004063
         WinWidth=0.987773
         WinHeight=0.117498
         OnPreDraw=AudioBK2.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'ROInterface.ROUT2K4Tab_AudioSettings.AudioBK2'

     Begin Object Class=GUISectionBackground Name=AudioBK3
         Caption="Text To Speech"
         WinTop=0.004372
         WinLeft=0.004063
         WinWidth=0.987773
         WinHeight=0.117498
         OnPreDraw=AudioBK3.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'ROInterface.ROUT2K4Tab_AudioSettings.AudioBK3'

     Begin Object Class=moButton Name=VoiceOptions
         ButtonCaption="Configure"
         MenuTitle="Voice Chat Options"
         MenuClass="ROInterface.ROVoiceChatConfig"
         CaptionWidth=0.500000
         Caption="Voice Options"
         OnCreateComponent=VoiceOptions.InternalOnCreateComponent
         WinTop=0.909065
         WinLeft=0.527734
         WinWidth=0.461134
         WinHeight=0.050000
         TabOrder=19
     End Object
     b_VoiceChat=moButton'ROInterface.ROUT2K4Tab_AudioSettings.VoiceOptions'

}
