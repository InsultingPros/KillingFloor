class KFGameSettings extends Settings_Tabs;

var automated GUISectionBackground i_BG1, i_BG2;

//var automated moEditBox     ed_PlayerName;

var automated 	moCheckBox    	ch_DynNetspeed;
var automated 	moComboBox    	co_Netspeed;

var automated 	moComboBox    	co_Hints;
var 			int 			HintLevel,
								HintLevelD; // 0 = all hints, 1 = new hints, 2 = no hints
var localized 	array<string>	Hints;

var automated 	moComboBox    	co_AudioMessageLevel;
var				int             AudioMessageLevel,
								AudioMessageLevelD;
var	localized	string			AudioMessageLevels[3];

var automated 	moCheckBox		ch_TraderPath;
var				bool			bTrader;

var int     iNetspeed, iNetSpeedD;
var bool    bDynNet;
var string  sPlayerName, sPlayerNameD;

var localized string    NetSpeedText[4];

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

	Super.InitComponent(MyController, MyOwner);

    for(i = 0; i < ArrayCount(NetSpeedText); i++)
        co_Netspeed.AddItem(NetSpeedText[i]);

    i_BG2.ManageComponent(co_Netspeed);
    i_BG2.ManageComponent(ch_DynNetspeed);

   	i_BG1.ManageComponent(co_Hints);
	i_BG1.ManageComponent(ch_TraderPath);
	i_BG1.ManageComponent(co_AudioMessageLevel);

	for ( i = 0; i < Hints.Length; i++ )
	{
	    co_Hints.AddItem(Hints[i]);
	}
	co_Hints.ReadOnly(true);

	for (i = 0; i < 3; i++)
	{
	    co_AudioMessageLevel.AddItem(AudioMessageLevels[i]);
	}
	co_AudioMessageLevel.ReadOnly(true);

}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    local PlayerController PC;
    local int i;

    PC = PlayerOwner();

    switch (Sender)
    {
        case co_Netspeed:
        	if ( PC.Player != None )
        		i = PC.Player.ConfiguredInternetSpeed;
        	else
                i = class'Player'.default.ConfiguredInternetSpeed;

            if (i <= 2600)
                iNetSpeed = 0;

            else if (i <= 5000)
                iNetSpeed = 1;

            else if (i <= 10000)
                iNetSpeed = 2;

            else iNetSpeed = 3;

			iNetSpeedD = iNetSpeed;
            co_NetSpeed.SetIndex(iNetSpeed);
            break;

        case ch_DynNetspeed:
            bDynNet = PC.bDynamicNetSpeed;
            ch_DynNetspeed.Checked(bDynNet);
            break;

		case co_Hints:
    	 	if ( KFPlayerController(PlayerOwner()) != none )
    	    {
    	        if ( KFPlayerController(PlayerOwner()).bShowHints )
    	        {
    	            HintLevel = 1;
    	        }
    	        else
    	        {
    	            HintLevel = 2;
    	        }
    	    }
    	    else
    	    {
    	        if ( class'KFPlayerController'.default.bShowHints )
    	        {
				    HintLevel = 1;
				}
    	        else
    	        {
    	            HintLevel = 2;
    	        }
    	    }

			HintLevelD = HintLevel;
			co_Hints.SetIndex(HintLevel);
    	    break;

		case ch_TraderPath:
			if ( KFPlayerController(PlayerOwner()) != none )
    	    {
				bTrader = KFPlayerController(PlayerOwner()).bWantsTraderPath;
			}
			else
			{
				bTrader = class'KFPlayerController'.default.bWantsTraderPath;
			}

			ch_TraderPath.SetComponentValue(bTrader,true);
			break;

		case co_AudioMessageLevel:
	     	AudioMessageLevel = int(PC.ConsoleCommand("get KFMod.KFPlayerController AudioMessageLevel"));
	     	AudioMessageLevelD = AudioMessageLevel;
	     	co_AudioMessageLevel.SetIndex(AudioMessageLevel);
	        break;
    }
}

function SaveSettings()
{
    local PlayerController PC;
    local bool bSave;

	Super.SaveSettings();
    PC = PlayerOwner();

	if ( iNetSpeed != iNetSpeedD || (class'Player'.default.ConfiguredInternetSpeed == 9636) )
	{
		if ( PC.Player != None )
		{
			switch (iNetSpeed)
			{
				case 0: PC.Player.ConfiguredInternetSpeed = 2600; break;
				case 1: PC.Player.ConfiguredInternetSpeed = 5000; break;
				case 2: PC.Player.ConfiguredInternetSpeed = 10000; break;
				case 3: PC.Player.ConfiguredInternetSpeed = 15000; break;
			}

			PC.Player.SaveConfig();
		}

		else
		{
			switch (iNetSpeed)
			{
				case 0: class'Player'.default.ConfiguredInternetSpeed = 2600; break;
				case 1: class'Player'.default.ConfiguredInternetSpeed = 5000; break;
				case 2: class'Player'.default.ConfiguredInternetSpeed = 10000; break;
				case 3: class'Player'.default.ConfiguredInternetSpeed = 15000; break;
			}

			class'Player'.static.StaticSaveConfig();
		}
	}

	if ( PC.bDynamicNetSpeed != bDynNet )
	{
		PC.bDynamicNetSpeed = bDynNet;
		bSave = True;
	}

   	if ( HintLevelD != HintLevel )
	{
	    if (HintLevel == 0)
	    {
	        if (KFPlayerController(PC) != none)
	        {
	            KFPlayerController(PC).bShowHints = true;
                KFPlayerController(PC).UpdateHintManagement(true);
                if (KFPlayerController(PC).HintManager != none)
	                KFPlayerController(PC).HintManager.NonStaticReset();
                KFPlayerController(PC).SaveConfig();
	        }
	        else
	        {
	            class'KFHintManager'.static.StaticReset();
	            class'KFPlayerController'.default.bShowHints = true;
	            class'KFPlayerController'.static.StaticSaveConfig();
	        }
	    }
	    else
	    {
	        if (KFPlayerController(PC) != none)
	        {
	            KFPlayerController(PC).bShowHints = (HintLevel == 1);
	            KFPlayerController(PC).UpdateHintManagement(HintLevel == 1);
	            KFPlayerController(PC).SaveConfig();
	        }
	        else
	        {
	            class'KFPlayerController'.default.bShowHints = (HintLevel == 1);
	            class'KFPlayerController'.static.StaticSaveConfig();
	        }
	    }
	}

	if (KFPlayerController(PlayerOwner()) != none)
    {
		KFPlayerController(PlayerOwner()).bWantsTraderPath = bTrader;
        KFPlayerController(PC).SaveConfig();
	}
	else
    {
        class'KFPlayerController'.default.bWantsTraderPath = bTrader;
        class'KFPlayerController'.static.StaticSaveConfig();
    }


	if ( AudioMessageLevelD != AudioMessageLevel )
	{
		if (KFPlayerController(PlayerOwner()) != none)
	    {
		    KFPlayerController(PlayerOwner()).AudioMessageLevel = AudioMessageLevel;
		    KFPlayerController(PC).SaveConfig();
		}
		else
		{
			class'KFPlayerController'.default.AudioMessageLevel = AudioMessageLevel;
			class'KFPlayerController'.static.StaticSaveConfig();
		}
	}

	if (bSave)
        PC.SaveConfig();
}

function InternalOnChange(GUIComponent Sender)
{
    Super.InternalOnChange(Sender);

    switch (sender)
    {
        case co_Netspeed:
            iNetSpeed = co_NetSpeed.GetIndex();
            break;

        case ch_DynNetspeed:
            bDynNet = ch_DynNetspeed.IsChecked();
            break;

        case co_Hints:
    	    HintLevel = co_Hints.GetIndex();
    	    break;

    	case ch_TraderPath:
			bTrader = ch_TraderPath.IsChecked();
			break;

		case co_AudioMessageLevel:
			AudioMessageLevel = co_AudioMessageLevel.GetIndex();
			break;
    }
}

function ResetClicked()
{
	local PlayerController PC;
	local int i;

	Super.ResetClicked();

	PC = PlayerOwner();

	class'Player'.static.ResetConfig("ConfiguredInternetSpeed");
	class'PlayerController'.static.ResetConfig("bDynamicNetSpeed");

	for (i = 0; i < Components.Length; i++)
		Components[i].LoadINI();
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=GameBK1
         Caption="Gameplay"
         WinTop=0.050000
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.250000
         RenderWeight=0.100100
         OnPreDraw=GameBK1.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'KFGui.KFGameSettings.GameBK1'

     Begin Object Class=GUISectionBackground Name=GameBK2
         Caption="Network"
         WinTop=0.350000
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.200000
         RenderWeight=0.100200
         OnPreDraw=GameBK2.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'KFGui.KFGameSettings.GameBK2'

     Begin Object Class=moCheckBox Name=NetworkDynamicNetspeed
         ComponentJustification=TXTA_Left
         CaptionWidth=0.955000
         Caption="Dynamic Netspeed"
         OnCreateComponent=NetworkDynamicNetspeed.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Netspeed is automatically adjusted based on the speed of your network connection"
         WinTop=0.266017
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=4
         OnChange=KFGameSettings.InternalOnChange
         OnLoadINI=KFGameSettings.InternalOnLoadINI
     End Object
     ch_DynNetspeed=moCheckBox'KFGui.KFGameSettings.NetworkDynamicNetspeed'

     Begin Object Class=moComboBox Name=OnlineNetSpeed
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Connection"
         OnCreateComponent=OnlineNetSpeed.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Cable Modem/DSL"
         Hint="How fast is your connection?"
         WinTop=0.222944
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=3
         OnChange=KFGameSettings.InternalOnChange
         OnLoadINI=KFGameSettings.InternalOnLoadINI
     End Object
     co_Netspeed=moComboBox'KFGui.KFGameSettings.OnlineNetSpeed'

     Begin Object Class=moComboBox Name=HintsCombo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.550000
         Caption="Hint Level"
         OnCreateComponent=HintsCombo.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Selects whether hints should be shown or not."
         WinTop=0.335021
         WinLeft=0.547773
         WinWidth=0.401953
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFGameSettings.InternalOnChange
         OnLoadINI=KFGameSettings.InternalOnLoadINI
     End Object
     co_Hints=moComboBox'KFGui.KFGameSettings.HintsCombo'

     Hints(0)="All Hints (Reset)"
     Hints(1)="New Hints Only"
     Hints(2)="No Hints"
     Begin Object Class=moComboBox Name=AudioMessageCombo
         ComponentJustification=TXTA_Left
         CaptionWidth=0.550000
         Caption="Audio Message Level"
         OnCreateComponent=AudioMessageCombo.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Selects what type of messages are played"
         WinTop=0.335021
         WinLeft=0.547773
         WinWidth=0.401953
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFGameSettings.InternalOnChange
         OnLoadINI=KFGameSettings.InternalOnLoadINI
     End Object
     co_AudioMessageLevel=moComboBox'KFGui.KFGameSettings.AudioMessageCombo'

     AudioMessageLevels(0)="All Messages"
     AudioMessageLevels(1)="Important Messages"
     AudioMessageLevels(2)="Minimal Messages"
     Begin Object Class=moCheckBox Name=TraderPath
         ComponentJustification=TXTA_Left
         CaptionWidth=0.955000
         Caption="Show the trader path"
         OnCreateComponent=TraderPath.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Enables the path to the trader"
         OnChange=KFGameSettings.InternalOnChange
         OnLoadINI=KFGameSettings.InternalOnLoadINI
     End Object
     ch_TraderPath=moCheckBox'KFGui.KFGameSettings.TraderPath'

     NetSpeedText(0)="Modem"
     NetSpeedText(1)="ISDN"
     NetSpeedText(2)="Cable/ADSL"
     NetSpeedText(3)="LAN/T1"
     PanelCaption="Game"
     WinTop=0.150000
     WinHeight=0.720000
}
