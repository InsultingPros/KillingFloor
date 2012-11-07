class KFAudioSettingsTab extends Settings_Tabs;

var localized string	AudioModes[4],
						VoiceModes[3];


var automated GUISectionBackground	i_BG1, i_BG2, i_BG3;
var automated moSlider		sl_MusicVol, sl_EffectsVol, sl_VOIP;
var automated moComboBox	co_Mode, co_Announce;
var automated moCheckbox 	ch_ReverseStereo, ch_MessageBeep, ch_LowDetail, ch_Default, ch_VoiceChat;

var automated moCheckBox    ch_AJPublic, ch_AutoSpeak, ch_Dampen;
var automated moEditBox     ed_Active;
var automated moEditBox     ed_ChatPassword;
var automated moComboBox    co_Quality, co_LANQuality;

var float	fMusic, fEffects, fVOIP;
var int		iVoice, iMode, iVoiceMode;
var bool	bRev, bBeep, bLow, bCompat, b3DSound, bEAX, bDefault, bVoiceChat, bDampen;

var bool 	bAJPublic, bAutoSpeak;
var string  sPwd, sCodec, sLANCodec, sActive;
var float 	fVoice;

var class<VoiceChatReplicationInfo> VoiceChatClass;
var string VoiceChatClassName;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
    local bool bIsWin32;
   	local string CName, CDesc;
	local class<VoiceChatReplicationInfo> Cls;
	local array<string>    InstalledCodecs;

	bIsWin32 = ( ( PlatformIsWindows() ) && ( !PlatformIs64Bit() ) );

	Super.InitComponent(MyController, MyOwner);

	if ( bIsWin32 )
	{
		for(i = 0;i < ArrayCount(AudioModes);i++)
			co_Mode.AddItem(AudioModes[i]);
	}
	else
	{
		co_Mode.AddItem("OpenAL");
	}

	// Need to load TeamVoiceReplicationInfo to get team channel names
	Cls = class<VoiceChatReplicationInfo>( DynamicLoadObject( VoiceChatClassName, class'Class') );
	if ( Cls != None )
		VoiceChatClass = Cls;

	VoiceChatClass.static.GetInstalledCodecs( InstalledCodecs );
	for ( i = 0; i < InstalledCodecs.Length; i++ )
	{
		VoiceChatClass.static.GetCodecInfo( InstalledCodecs[i], CName, CDesc );
		co_Quality.AddItem( CName,, InstalledCodecs[i] );
		co_LANQuality.AddItem( CName,, InstalledCodecs[i] );
	}

    ed_ChatPassword.MaskText(True);


	i_BG1.ManageComponent(sl_MusicVol);
	i_BG1.ManageComponent(sl_EffectsVol);
	i_BG1.ManageComponent(sl_VOIP);
	i_BG1.ManageComponent(co_Mode);
	i_BG1.ManageComponent(ch_LowDetail);
	i_BG1.ManageComponent(ch_Default);
	i_BG1.ManageComponent(ch_reverseStereo);
	i_BG1.ManageComponent(ch_MessageBeep);

	i_BG3.ManageComponent(ch_VoiceChat);
	i_BG3.ManageComponent(ch_Dampen);
	i_BG3.ManageComponent(ch_AJPublic);
	i_BG3.ManageComponent(ch_AutoSpeak);
	i_BG3.ManageComponent(ed_Active);
	i_BG3.ManageComponent(ed_ChatPassword);
	i_BG3.ManageComponent(co_Quality);
	i_BG3.ManageComponent(co_LANQuality);


	// !!! FIXME: Might use a preinstalled system OpenAL in the future on
	// !!! FIXME:  Mac or Unix, but for now, we don't...  --ryan.
	if ( !PlatformIsWindows() )
		ch_Default.DisableMe();
}

function ResetClicked()
{
	local class<AudioSubSystem> A;
	local PlayerController PC;
	local int i;

	Super.ResetClicked();

	PC = PlayerOwner();

	A = class<AudioSubSystem>(DynamicLoadObject(GetNativeClassName("Engine.Engine.AudioDevice"), Class'Class'));
	A.static.ResetConfig();

	class'Hud'.static.ResetConfig("bMessageBeep");
	class'LevelInfo'.static.ResetConfig("bLowSoundDetail");

	class'PlayerController'.static.ResetConfig("bNoVoiceTaunts");
	class'PlayerController'.static.ResetConfig("bNoVoiceMessages");

	A.static.ResetConfig("VoiceVolume");

	class'Engine.PlayerController'.static.ResetConfig("VoiceChatCodec");
	class'Engine.PlayerController'.static.ResetConfig("VoiceChatLANCodec");
    class'Engine.PlayerController'.static.ResetConfig("AutoJoinMask");
    class'Engine.PlayerController'.static.ResetConfig("ChatPassword");
    class'Engine.PlayerController'.static.ResetConfig("DefaultActiveChannel");
    class'Engine.PlayerController'.static.ResetConfig("bEnableInitialChatRoom");

	for (i = 0; i < Components.Length; i++)
		Components[i].LoadINI();
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local PlayerController PC;
	local bool bIsWin32;

	PC = PlayerOwner();

	switch (Sender)
	{
    	case sl_MusicVol:
    		fMusic = float(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume"));
    		sl_MusicVol.SetComponentValue(fMusic,true);
    		break;

    	case sl_EffectsVol:
    		fEffects = float(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume"));
    		sl_EffectsVol.SetComponentValue(fEffects,true);
    		break;

    	case co_Mode:
    		iMode = 1;
    		bIsWin32 = ( ( PlatformIsWindows() ) && ( !PlatformIs64Bit() ) );
    		if ( !bIsWin32 )
    		{
    			bCompat = False;
    			b3DSound = True;
    			iMode = 0;
    		}
    		else
    		{
    			if ( bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice CompatibilityMode")) )
    			{
    				bCompat = True;
    				iMode = 0;
    			}

    			if ( bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3DSound")) )
    			{
    				b3DSound = True;
    				iMode = 2;
    			}

    			if ( bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice UseEAX" )) )
    			{
    				bEAX = True;
    				iMode = 3;
    			}
    		}
    		co_Mode.SilentSetIndex(iMode);
    		break;

    	case ch_ReverseStereo:
    		bRev = bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice ReverseStereo"));
    		ch_ReverseStereo.SetComponentValue(bRev,true);
    		break;

    	case ch_Default:
    		bDefault = bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice UseDefaultDriver"));
    		ch_Default.SetComponentValue(bDefault,true);
    		break;

       	case ch_MessageBeep:
    		bBeep = class'HUD'.default.bMessageBeep;
    		ch_MessageBeep.SetComponentValue(bBeep,true);
    		break;

    	case ch_LowDetail:
    		bLow = PC.Level.bLowSoundDetail;

    		// Make sure both are the same - LevelInfo.bLowSoundDetail take priority
    		if ( bLow != bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice LowQualitySound" )) )
    		{
    			PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowQualitySound"@bLow);
    			PC.ConsoleCommand("SOUND_REBOOT");

    			// Restart music.
    			if( PC.Level.Song != "" && PC.Level.Song != "None" )
    				PC.ClientSetMusic( PC.Level.Song, MTRAN_Instant );

    			else PC.ClientSetMusic( class'ROMainMenu'.default.MenuSong, MTRAN_Instant );
    		}

    		ch_LowDetail.SetComponentValue(bLow,true);
    		break;

    	case ch_VoiceChat:
    		bVoiceChat = bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice UseVoIP"));
    		ch_VoiceChat.SetComponentValue(bVoiceChat,true);
    		UpdateVOIPControlsState();
    		break;

        case ed_ChatPassword:
            sPwd = PC.ChatPassword;
            ed_ChatPassword.SetComponentValue(sPwd, True);
            break;

        case sl_VOIP:
        	fVoice = float(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice VoiceVolume"));
        	sl_VOIP.SetComponentValue(fVoice, True);
        	break;

    	case co_Quality:
    		sCodec = PC.VoiceChatCodec;
    		co_Quality.SetExtra(sCodec,true);
    		break;

    	case co_LANQuality:
    		sLANCodec = PC.VoiceChatLANCodec;
    		co_LANQuality.SetExtra(sLANCodec,true);
    		break;

    	case ch_Dampen:
    	    bDampen = bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice DampenWithVoIP"));
    	    ch_Dampen.SetComponentValue(bDampen,true);
    	    break;

    	case ch_AJPublic:
    		bAJPublic = bool(PC.AutoJoinMask & 1);
    		ch_AJPublic.SetComponentValue(bAJPublic,True);
    		break;

    	case ch_AutoSpeak:
    		bAutoSpeak = PC.bEnableInitialChatRoom;
    		if ( bAutoSpeak )
    			EnableComponent(ed_Active);
    		else DisableComponent(ed_Active);

    		ch_AutoSpeak.SetComponentValue(bAutoSpeak, True);
    		break;

    	case ed_Active:
    		sActive = PC.DefaultActiveChannel;
    		ed_Active.SetComponentValue(sActive, True);
    		break;

    	default:
    		log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
    		GUIMenuOption(Sender).SetComponentValue(s,true);
	}
}

function InternalOnChange(GUIComponent Sender)
{
	local PlayerController PC;
	local bool bIsWin32;

	bIsWin32 = ( ( PlatformIsWindows() ) && ( !PlatformIs64Bit() ) );

	Super.InternalOnChange(Sender);
	PC = PlayerOwner();

	switch(Sender)
	{
		case sl_MusicVol:
			fMusic = sl_MusicVol.GetValue();
			PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume"@fMusic);
			PC.ConsoleCommand("SetMusicVolume"@fMusic);

			if( PC.Level.Song != "" && PC.Level.Song != "None" )
				PC.ClientSetMusic( PC.Level.Song, MTRAN_Instant );
			else PC.ClientSetMusic( class'ROMainMenu'.default.MenuSong, MTRAN_Instant );
			break;

		case sl_EffectsVol:
			fEffects = sl_EffectsVol.GetValue();
			PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume"@fEffects);
			PC.ConsoleCommand("stopsounds");
			break;

		case co_Mode:
			if ( !bIsWin32 )  // Simple OpenAL abstraction...  --ryan.
				break;

			iMode = co_Mode.GetIndex();
			if (iMode > 1)
				ShowPerformanceWarning();

			bCompat = iMode < 1;
			b3DSound = iMode > 1;
			bEAX = iMode > 2;
	        PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice CompatibilityMode"@bCompat);
	        PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice Use3DSound"@b3DSound);
	        PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice UseEAX"@bEAX);
			PC.ConsoleCommand("SOUND_REBOOT");

			// Restart music.
			if( PC.Level.Song != "" && PC.Level.Song != "None" )
				PC.ClientSetMusic( PC.Level.Song, MTRAN_Instant );
			else PC.ClientSetMusic( class'ROMainMenu'.default.MenuSong, MTRAN_Instant );
			break;

		case ch_ReverseStereo:
			bRev = ch_ReverseStereo.IsChecked();
			break;

		case ch_MessageBeep:
			bBeep = ch_MessageBeep.IsChecked();
			break;

		case ch_Default:
			bDefault = ch_Default.IsChecked();
			PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice UseDefaultDriver"@bDefault);
			PC.ConsoleCommand("SOUND_REBOOT");
			break;

		case ch_LowDetail:
			bLow = ch_LowDetail.IsChecked();

			PC.Level.bLowSoundDetail = bLow;
			PC.Level.SaveConfig();

			PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowQualitySound"@bLow);
			PC.ConsoleCommand("SOUND_REBOOT");

			// Restart music.
			if( PC.Level.Song != "" && PC.Level.Song != "None" )
				PC.ClientSetMusic( PC.Level.Song, MTRAN_Instant );
			else PC.ClientSetMusic( class'ROMainMenu'.default.MenuSong, MTRAN_Instant );
			break;

		case ch_VoiceChat:
			bVoiceChat = ch_VoiceChat.IsChecked();
			UpdateVOIPControlsState();
			break;

        case ch_Dampen:
            bDampen = ch_Dampen.IsChecked();
            break;

        case ed_ChatPassword:
            sPwd = ed_ChatPassword.GetText();
            break;

        case sl_VOIP:
        	fVoice = sl_VOIP.GetValue();
        	break;

		case co_Quality:
			sCodec = co_Quality.GetExtra();
			break;

		case co_LANQuality:
			sLANCodec = co_LANQuality.GetExtra();
			break;

		case ch_AJPublic:
			bAJPublic = ch_AJPublic.IsChecked();
			break;

		case ch_AutoSpeak:
			bAutoSpeak = ch_AutoSpeak.IsChecked();
			if ( bAutoSpeak )
				EnableComponent(ed_Active);
			else DisableComponent(ed_Active);
			break;

		case ed_Active:
			sActive = ed_Active.GetText();
			break;
	}
}

function SaveSettings()
{
	local PlayerController PC;
	local bool bSave, bReboot;

	Super.SaveSettings();
	PC = PlayerOwner();

	if (PC.bNoAutoTaunts != iVoiceMode > 0)
	{
		PC.bNoAutoTaunts = iVoiceMode > 0;
		PC.default.bNoAutoTaunts = PC.bNoAutoTaunts;
		bSave = True;
	}

	if (PC.bNoVoiceTaunts != iVoiceMode > 0)
	{
		PC.bNoVoiceTaunts = iVoiceMode > 0;
		PC.default.bNoVoiceTaunts = PC.bNoVoiceTaunts;
		bSave = True;
	}

	if (PC.bNoVoiceMessages != iVoiceMode == 2)
	{
		PC.bNoVoiceMessages = iVoiceMode == 2;
		PC.default.bNoVoiceMessages = PC.bNoVoiceMessages;
		bSave = True;
	}

	if (fMusic != sl_MusicVol.GetValue())
		PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume"@fMusic);

	if (fEffects != sl_EffectsVol.GetValue())
		PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume"@fEffects);

	if (bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice ReverseStereo")) != bRev)
		PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice ReverseStereo"@bRev);

	if (bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice DampenWithVoIP")) != bDampen)
		PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice DampenWithVoIP"@bDampen);

	if (bDefault != bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice UseDefaultDriver")))
	{
		PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice UseDefaultDriver"@bDefault);
		bReboot = True;
	}

	if( PC.MyHud != None )
	{
		if ( PC.myHUD.bMessageBeep != bBeep )
		{
			PC.myHUD.bMessageBeep = bBeep;
			PC.myHUD.SaveConfig();
		}
	}

	else
	{
		if ( class'HUD'.default.bMessageBeep != bBeep )
		{
			class'HUD'.default.bMessageBeep = bBeep;
			class'HUD'.static.StaticSaveConfig();
		}
	}

	if ( bAJPublic != bool(PC.AutoJoinMask & 1) )
	{
		if ( bAJPublic )
			PC.AutoJoinMask = PC.AutoJoinMask | 1;
		else PC.AutoJoinMask = PC.AutoJoinMask & ~1;
		bSave = True;
	}

    if ( fVoice != float(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice VoiceVolume")) )
    	PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice VoiceVolume"@fVoice);

    if ( sCodec != PC.VoiceChatCodec )
    {
    	PC.VoiceChatCodec = sCodec;
    	bSave = True;
    }

    if ( sLANCodec != PC.VoiceChatLANCodec )
    {
    	PC.VoiceChatLANCodec = sLANCodec;
    	bSave = True;
    }

    if ( PC.bEnableInitialChatRoom != bAutoSpeak )
    {
    	PC.bEnableInitialChatRoom = bAutoSpeak;
    	bSave = True;
    }

	if ( !(PC.DefaultActiveChannel ~= sActive) )
	{
		PC.DefaultActiveChannel = sActive;
		bSave = True;
	}

    if (PC.ChatPassword != sPwd)
    {
        PC.SetChatPassword(sPwd);
        bSave = False;
    }

    if (bVoiceChat != bool(PC.ConsoleCommand("get ini:Engine.Engine.AudioDevice UseVoIP")))
	{
		if (bVoiceChat)
			PC.EnableVoiceChat();
		else
            PC.DisableVoiceChat();

		bReboot = False;
	}

	if (bSave)
		PC.SaveConfig();

	if (bReboot)
		PC.ConsoleCommand("SOUND_REBOOT");
}

function UpdateVOIPControlsState()
{
    if (bVoiceChat)
    {
        //ch_AJLocal.EnableMe();
        sl_VOIP.EnableMe();
        //ch_AJLocal.EnableMe();
        ch_AJPublic.EnableMe();
        //ch_AJTeam.EnableMe();
        ed_Active.EnableMe();
        ed_ChatPassword.EnableMe();
        co_Quality.EnableMe();
        co_LANQuality.EnableMe();
        ch_AutoSpeak.EnableMe();
    }
    else
    {
        //ch_AJLocal.DisableMe();
        sl_VOIP.DisableMe();
        //ch_AJLocal.DisableMe();
        ch_AJPublic.DisableMe();
        //ch_AJTeam.DisableMe();
        ed_Active.DisableMe();
        ed_ChatPassword.DisableMe();
        co_Quality.DisableMe();
        co_LANQuality.DisableMe();
        ch_AutoSpeak.DisableMe();
    }
}

defaultproperties
{
     AudioModes(0)="Safe Mode"
     AudioModes(1)="3D Audio"
     AudioModes(2)="H/W 3D Audio"
     AudioModes(3)="H/W 3D + EAX"
     VoiceModes(0)="All"
     VoiceModes(1)="No taunts"
     VoiceModes(2)="None"
     Begin Object Class=GUISectionBackground Name=AudioBK1
         Caption="Sound System"
         WinTop=0.100000
         WinLeft=0.000948
         WinWidth=0.485000
         WinHeight=0.650000
         OnPreDraw=AudioBK1.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'KFGui.KFAudioSettingsTab.AudioBK1'

     Begin Object Class=GUISectionBackground Name=AudioBK3
         Caption="Voice Chat"
         WinTop=0.100000
         WinLeft=0.495826
         WinWidth=0.502751
         WinHeight=0.650000
         OnPreDraw=AudioBK3.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'KFGui.KFAudioSettingsTab.AudioBK3'

     Begin Object Class=moSlider Name=AudioMusicVolume
         MaxValue=0.500000
         Caption="Music Volume"
         OnCreateComponent=AudioMusicVolume.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="0.25"
         Hint="Adjusts the volume of the background music."
         WinTop=0.070522
         WinLeft=0.018164
         WinWidth=0.450000
         TabOrder=2
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     sl_MusicVol=moSlider'KFGui.KFAudioSettingsTab.AudioMusicVolume'

     Begin Object Class=moSlider Name=AudioEffectsVolumeSlider
         MaxValue=0.500000
         Caption="Effects Volume"
         OnCreateComponent=AudioEffectsVolumeSlider.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="0.35"
         Hint="Adjusts the volume of all in game sound effects."
         WinTop=0.070522
         WinLeft=0.524024
         WinWidth=0.450000
         TabOrder=1
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     sl_EffectsVol=moSlider'KFGui.KFAudioSettingsTab.AudioEffectsVolumeSlider'

     Begin Object Class=moSlider Name=VoiceVolume
         MaxValue=10.000000
         MinValue=1.000000
         Caption="Voice Chat Volume"
         OnCreateComponent=VoiceVolume.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="1.0"
         Hint="Adjusts the volume of other players' voice chat communication."
         WinTop=0.142484
         WinLeft=0.518507
         WinWidth=0.408907
         RenderWeight=1.040000
         TabOrder=3
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     sl_VOIP=moSlider'KFGui.KFAudioSettingsTab.VoiceVolume'

     Begin Object Class=moComboBox Name=AudioMode
         bReadOnly=True
         Caption="Audio Mode"
         OnCreateComponent=AudioMode.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Software 3D Audio"
         Hint="Changes the audio system mode."
         WinTop=0.149739
         WinLeft=0.018164
         WinWidth=0.450000
         TabOrder=4
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     co_Mode=moComboBox'KFGui.KFAudioSettingsTab.AudioMode'

     Begin Object Class=moCheckBox Name=AudioReverseStereo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Reverse Stereo"
         OnCreateComponent=AudioReverseStereo.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Reverses the left and right audio channels."
         WinTop=0.405678
         WinLeft=0.018164
         WinWidth=0.450000
         TabOrder=7
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ch_ReverseStereo=moCheckBox'KFGui.KFAudioSettingsTab.AudioReverseStereo'

     Begin Object Class=moCheckBox Name=AudioMessageBeep
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Message Beep"
         OnCreateComponent=AudioMessageBeep.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enables a beep when receiving a text message from other players."
         WinTop=0.405678
         WinLeft=0.524024
         WinWidth=0.450000
         TabOrder=9
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ch_MessageBeep=moCheckBox'KFGui.KFAudioSettingsTab.AudioMessageBeep'

     Begin Object Class=moCheckBox Name=AudioLowDetail
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="Low Sound Detail"
         OnCreateComponent=AudioLowDetail.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Lowers quality of sound."
         WinTop=0.235052
         WinLeft=0.018164
         WinWidth=0.450000
         TabOrder=5
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ch_LowDetail=moCheckBox'KFGui.KFAudioSettingsTab.AudioLowDetail'

     Begin Object Class=moCheckBox Name=AudioDefaultDriver
         ComponentJustification=TXTA_Left
         CaptionWidth=0.940000
         Caption="System Driver"
         OnCreateComponent=AudioDefaultDriver.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Use system installed OpenAL driver"
         WinTop=0.320365
         WinLeft=0.018164
         WinWidth=0.450000
         TabOrder=6
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ch_Default=moCheckBox'KFGui.KFAudioSettingsTab.AudioDefaultDriver'

     Begin Object Class=moCheckBox Name=EnableVoiceChat
         CaptionWidth=-1.000000
         Caption="Enable Voice Chat"
         OnCreateComponent=EnableVoiceChat.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enables the voice chat system during online matches."
         WinTop=0.834777
         WinLeft=0.527734
         WinWidth=0.461134
         TabOrder=20
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ch_VoiceChat=moCheckBox'KFGui.KFAudioSettingsTab.EnableVoiceChat'

     Begin Object Class=moCheckBox Name=AutoJoinPublic
         CaptionWidth=0.940000
         Caption="Autojoin Public Channel"
         OnCreateComponent=AutoJoinPublic.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Automatically join the 'Public' channel upon connecting to a server."
         WinTop=0.145784
         WinLeft=0.086280
         WinWidth=0.826652
         TabOrder=23
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ch_AJPublic=moCheckBox'KFGui.KFAudioSettingsTab.AutoJoinPublic'

     Begin Object Class=moCheckBox Name=AutoSpeakCheckbox
         Caption="Auto-select Active Channel"
         OnCreateComponent=AutoSpeakCheckbox.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Automatically set an active channel when you join a server.  The default channel is determined by the gametype, but you can specify your own using the editbox below"
         WinTop=0.603526
         WinLeft=0.039812
         WinWidth=0.442638
         WinHeight=0.060000
         TabOrder=24
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ch_AutoSpeak=moCheckBox'KFGui.KFAudioSettingsTab.AutoSpeakCheckbox'

     Begin Object Class=moCheckBox Name=Dampen
         CaptionWidth=0.940000
         Caption="Dampen Game Volume When Using VOIP"
         OnCreateComponent=Dampen.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Dampens the volume of the game when receiving VOIP communications."
         WinTop=0.145784
         WinLeft=0.086280
         WinWidth=0.826652
         TabOrder=21
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ch_Dampen=moCheckBox'KFGui.KFAudioSettingsTab.Dampen'

     Begin Object Class=moEditBox Name=DefaultActiveChannelEditBox
         CaptionWidth=0.600000
         Caption="Default Channel Name"
         OnCreateComponent=DefaultActiveChannelEditBox.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enter the name of the channel to speak on by default when you join the server.  To use the default chatroom for whichever gametype you're playing, leave this field empty"
         WinTop=0.757277
         WinLeft=0.032569
         WinWidth=0.420403
         TabOrder=25
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ed_Active=moEditBox'KFGui.KFAudioSettingsTab.DefaultActiveChannelEditBox'

     Begin Object Class=moEditBox Name=ChatPasswordEdit
         CaptionWidth=0.600000
         Caption="Chat Password"
         OnCreateComponent=ChatPasswordEdit.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Set a password on your personal chat room to limit who is allowed to join"
         WinTop=0.332828
         WinLeft=0.032569
         WinWidth=0.420403
         TabOrder=26
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     ed_ChatPassword=moEditBox'KFGui.KFAudioSettingsTab.ChatPasswordEdit'

     Begin Object Class=moComboBox Name=VoiceQuality
         bReadOnly=True
         CaptionWidth=0.600000
         Caption="Internet Quality"
         OnCreateComponent=VoiceQuality.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Determines the codec used to transmit voice chat to and from internet servers."
         WinTop=0.241391
         WinLeft=0.523390
         WinWidth=0.408907
         TabOrder=27
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     co_Quality=moComboBox'KFGui.KFAudioSettingsTab.VoiceQuality'

     Begin Object Class=moComboBox Name=VoiceQualityLAN
         bReadOnly=True
         CaptionWidth=0.600000
         Caption="LAN Quality"
         OnCreateComponent=VoiceQualityLAN.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Determines the codec used to transmit voice chat to and from LAN servers."
         WinTop=0.333786
         WinLeft=0.523390
         WinWidth=0.408907
         TabOrder=28
         OnChange=KFAudioSettingsTab.InternalOnChange
         OnLoadINI=KFAudioSettingsTab.InternalOnLoadINI
     End Object
     co_LANQuality=moComboBox'KFGui.KFAudioSettingsTab.VoiceQualityLAN'

     VoiceChatClass=Class'Engine.VoiceChatReplicationInfo'
     VoiceChatClassName="UnrealGame.TeamVoiceReplicationInfo"
     PanelCaption="Audio"
     WinTop=0.150000
     WinHeight=0.740000
}
