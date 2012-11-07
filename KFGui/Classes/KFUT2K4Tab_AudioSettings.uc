// Fix for the Music problem with the KF Main Menu

class KFUT2K4Tab_AudioSettings extends UT2K4Tab_AudioSettings;

function InternalOnChange(GUIComponent Sender)
{
    local PlayerController PC;
    local float AnnouncerVol;
    local Sound snd;
    local int AnnouncerIdx;
    local bool bIsWin32;

    bIsWin32 = ( ( PlatformIsWindows() ) && ( !PlatformIs64Bit() ) );

    Super.InternalOnChange(Sender);
    PC = PlayerOwner();

    switch(Sender)
    {
        case sl_VoiceVol:
            iVoice = sl_VoiceVol.GetValue();
            AnnouncerVol = 2.0 * FClamp(0.1 + iVoice*0.225,0.2,1.0);
            if ( co_StatusAnnouncer == None )
                return;

            snd = sound(co_StatusAnnouncer.GetObject());
            if ( snd == None && Announcers.Length > 0 )
            {
                snd = Sound(DynamicLoadObject(Announcers[AnnouncerIdx].PackageName $ "." $ StatusPreviewSound,class'Sound'));
                if ( snd == none )
                    snd = Sound(DynamicLoadObject(Announcers[AnnouncerIdx].FallbackPackage $ "." $ StatusPreviewSound,class'Sound'));

                co_StatusAnnouncer.MyComboBox.List.SetObjectAtIndex(co_StatusAnnouncer.MyComboBox.List.Index,snd);
            }

            if ( snd != None )
                PC.PlaySound(snd,SLOT_Talk,AnnouncerVol);

            break;

        case sl_MusicVol:
            fMusic = sl_MusicVol.GetValue();
            PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice MusicVolume"@fMusic);
            PC.ConsoleCommand("SetMusicVolume"@fMusic);

            if( PC.Level.Song != "" && PC.Level.Song != "None" )
                PC.ClientSetMusic( PC.Level.Song, MTRAN_Instant );
            else PC.ClientSetMusic( class'KFGUI.KFMainMenu'.default.MenuSong, MTRAN_Instant );
            break;

        case sl_EffectsVol:
            fEffects = sl_EffectsVol.GetValue();
            PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice SoundVolume"@fEffects);
            PC.ConsoleCommand("stopsounds");
            PC.PlaySound(sound'KF_MenuSnd.SetSoundFX');
            break;
/*
        case sl_TTS:
            fTTS = sl_TTS.GetValue();
        // Do not preview TTS voice volume, since there isn't any way to truly represent the way it will sound in-game
//              PC.TextToSpeech( "Fo Shizzle my nizzle", fTTS );
            break;
*/
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
            else PC.ClientSetMusic( class'KFGUI.KFMainMenu'.default.MenuSong, MTRAN_Instant );
            break;

        case ch_ReverseStereo:
            bRev = ch_ReverseStereo.IsChecked();
            break;

        case ch_MessageBeep:
            bBeep = ch_MessageBeep.IsChecked();
            break;

        case ch_AutoTaunt:
            bAuto = ch_AutoTaunt.IsChecked();
            break;

        case ch_TTS:
            bTTS = ch_TTS.IsChecked();
            break;

        case ch_MatureTaunts:
            bMature = ch_MatureTaunts.IsChecked();
            break;

        case co_Voices:
            iVoiceMode = co_Voices.GetIndex();
            break;

        case ch_Default:
            bDefault = ch_Default.IsChecked();
            PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice UseDefaultDriver"@bDefault);
            PC.ConsoleCommand("SOUND_REBOOT");
            break;

        case ch_LowDetail:
            bLow = ch_LowDetail.IsChecked();

            PC.Level.bLowSoundDetail = bLow;
            PC.Level.StaticSaveConfig();

            PC.ConsoleCommand("set ini:Engine.Engine.AudioDevice LowQualitySound"@bLow);
            PC.ConsoleCommand("SOUND_REBOOT");

            // Restart music.
            if( PC.Level.Song != "" && PC.Level.Song != "None" )
                PC.ClientSetMusic( PC.Level.Song, MTRAN_Instant );
            else PC.ClientSetMusic( class'KFGUI.KFMainMenu'.default.MenuSong, MTRAN_Instant );
            break;

        case co_Announce:
            iAnnounce = co_Announce.GetIndex();
            break;

        case co_RewardAnnouncer:
            AnnouncerIdx = int(co_RewardAnnouncer.GetExtra());
            sRewAnnouncer = Announcers[AnnouncerIdx].ClassName;

            AnnouncerVol = 2.0 * FClamp(0.1 + iVoice*0.225,0.2,1.0);
            snd = sound(co_RewardAnnouncer.GetObject());
            if ( snd == None )
            {
                snd = Sound(DynamicLoadObject(Announcers[AnnouncerIdx].PackageName $ "." $ RewardPreviewSound,class'Sound'));
                if ( snd == none )
                    snd = Sound(DynamicLoadObject(Announcers[AnnouncerIdx].FallbackPackage $ "." $ RewardPreviewSound,class'Sound'));

                co_RewardAnnouncer.MyComboBox.List.SetObjectAtIndex(co_RewardAnnouncer.MyComboBox.List.Index,snd);
            }
            PC.PlaySound(snd,SLOT_Talk,AnnouncerVol);
            break;

        case co_StatusAnnouncer:
            AnnouncerIdx = int(co_StatusAnnouncer.GetExtra());
            sStatAnnouncer = Announcers[AnnouncerIdx].ClassName;

            AnnouncerVol = 2.0 * FClamp(0.1 + iVoice*0.225,0.2,1.0);
            snd = sound(co_StatusAnnouncer.GetObject());
            if ( snd == None )
            {
                snd = Sound(DynamicLoadObject(Announcers[AnnouncerIdx].PackageName $ "." $ StatusPreviewSound,class'Sound'));
                if ( snd == none )
                    snd = Sound(DynamicLoadObject(Announcers[AnnouncerIdx].FallbackPackage $ "." $ StatusPreviewSound,class'Sound'));

                co_StatusAnnouncer.MyComboBox.List.SetObjectAtIndex(co_StatusAnnouncer.MyComboBox.List.Index,snd);
            }
            PC.PlaySound(snd,SLOT_Talk,AnnouncerVol);
            break;

        case ch_TTSIRC:
            bTTSIRC = ch_TTSIRC.IsChecked();
            break;

        case ch_VoiceChat:
            bVoiceChat = ch_VoiceChat.IsChecked();
            break;

        case ch_OnlyTeamTTS:
            bOnlyTeamTTS = ch_OnlyTeamTTS.IsChecked();
            break;
    }
}

defaultproperties
{
}
