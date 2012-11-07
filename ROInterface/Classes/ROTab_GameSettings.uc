//=============================================================================
// ROTab_GameSettings
//=============================================================================
// The game config tab
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROTab_GameSettings extends Settings_Tabs;

var automated GUISectionBackground i_BG1, i_BG2, i_BG3;

var automated moEditBox     ed_PlayerName;
var automated moComboBox    co_GoreLevel;

var automated moCheckBox    ch_DynNetspeed;
var automated moComboBox    co_Netspeed;

var automated moCheckBox    ch_TankThrottle, ch_VehicleThrottle, ch_ManualReloading;

var int     iGore;
var int     iNetspeed, iNetSpeedD;
var bool    bDynNet, bTankThrottle, bVehicleThrottle, bManualReloading;
var string  sPlayerName, sPlayerNameD;

var localized string    NetSpeedText[4];

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

	Super.InitComponent(MyController, MyOwner);

	if ( class'GameInfo'.Default.bAlternateMode )
    //	RemoveComponent(co_GoreLevel);
    {
        co_GoreLevel.AddItem(class'GameInfo'.default.GoreLevelText[0]);
    	co_GoreLevel.AddItem(class'GameInfo'.default.GoreLevelText[1]);
    }
    else
    {
    	co_GoreLevel.AddItem(class'GameInfo'.default.GoreLevelText[0]);
    	co_GoreLevel.AddItem(class'GameInfo'.default.GoreLevelText[2]);
    }

    for(i = 0; i < ArrayCount(NetSpeedText); i++)
        co_Netspeed.AddItem(NetSpeedText[i]);


    i_BG1.ManageComponent(ed_PlayerName);
    i_BG1.ManageComponent(co_GoreLevel);

    i_BG2.ManageComponent(co_Netspeed);
    i_BG2.ManageComponent(ch_DynNetspeed);

    i_BG3.ManageComponent(ch_TankThrottle);
    i_BG3.ManageComponent(ch_VehicleThrottle);
    i_BG3.ManageComponent(ch_ManualReloading);

    ed_PlayerName.MyEditBox.bConvertSpaces = true;
	ed_PlayerName.MyEditBox.MaxWidth=16;

}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
    local PlayerController PC;
    local int i;

    PC = PlayerOwner();

    switch (Sender)
    {
        case co_GoreLevel:
            if ( PC.Level.Game != None )
                iGore = PC.Level.Game.GoreLevel;
            else
                iGore = class'GameInfo'.default.GoreLevel;

            if (iGore == 2)
                iGore = 1;

            co_GoreLevel.SetIndex(iGore);
            break;


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

        case ed_PlayerName:
            sPlayerName = PC.GetUrlOption("Name");
			sPlayerNameD = sPlayerName;
			ed_PlayerName.SetText(sPlayerName);

        case ch_TankThrottle:
            if (ROPlayer(PC) != none)
                bTankThrottle = ROPlayer(PC).bInterpolatedTankThrottle;
            else
                bTankThrottle = class'ROPlayer'.default.bInterpolatedTankThrottle;
            ch_TankThrottle.Checked(bTankThrottle);
            break;

        case ch_VehicleThrottle:
            if (ROPlayer(PC) != none)
                bVehicleThrottle = ROPlayer(PC).bInterpolatedVehicleThrottle;
            else
                bVehicleThrottle = class'ROPlayer'.default.bInterpolatedVehicleThrottle;
            ch_VehicleThrottle.Checked(bVehicleThrottle);
            break;

        case ch_ManualReloading:
            if (ROPlayer(PC) != none)
                bManualReloading = ROPlayer(PC).bManualTankShellReloading;
            else
                bManualReloading = class'ROPlayer'.default.bManualTankShellReloading;
            ch_ManualReloading.Checked(bManualReloading);
            break;
    }
}

function SaveSettings()
{
    local PlayerController PC;
    local bool bSave;

	Super.SaveSettings();
    PC = PlayerOwner();

    if (PC.Level != None && PC.Level.Game != None)
    {
    	if ( PC.Level.Game.GoreLevel != min(2, (iGore * 2)) )
    	{
	        PC.Level.Game.GoreLevel = min(2, (iGore * 2));
	        PC.Level.Game.SaveConfig();
	    }
    }
    else
    {
		if ( class'Engine.GameInfo'.default.GoreLevel != min(2, (iGore * 2)) )
		{
	        class'Engine.GameInfo'.default.GoreLevel = min(2, (iGore * 2));
	        class'Engine.GameInfo'.static.StaticSaveConfig();
	    }
    }

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

	if (ROPlayer(PC) != none)
	{
	   if (ROPlayer(PC).bInterpolatedTankThrottle != bTankThrottle)
	   {
	       ROPlayer(PC).bInterpolatedTankThrottle = bTankThrottle;
	       bSave = true;
	   }

	   if (ROPlayer(PC).bInterpolatedVehicleThrottle != bVehicleThrottle)
	   {
	       ROPlayer(PC).bInterpolatedVehicleThrottle = bVehicleThrottle;
	       bSave = true;
	   }

	   if (ROPlayer(PC).bManualTankShellReloading != bManualReloading)
	   {
	       ROPlayer(PC).SetManualTankShellReloading(bManualReloading);
	       bSave = true;
	   }
	}
	else
	{
	    if (class'ROPlayer'.default.bInterpolatedTankThrottle != bTankThrottle)
	        class'ROPlayer'.default.bInterpolatedTankThrottle = bTankThrottle;
	    if (class'ROPlayer'.default.bInterpolatedVehicleThrottle != bVehicleThrottle)
	        class'ROPlayer'.default.bInterpolatedVehicleThrottle = bVehicleThrottle;
	    if (class'ROPlayer'.default.bManualTankShellReloading != bManualReloading)
	        class'ROPlayer'.default.bManualTankShellReloading = bManualReloading;
	    class'ROPlayer'.static.StaticSaveConfig();
	}

	if (sPlayerNameD != sPlayerName)
	{
		PC.ReplaceText(sPlayerName, "\"", "");
		sPlayerNameD = sPlayerName;
		PC.ConsoleCommand("SetName"@sPlayerName);
	}

    if (bSave)
        PC.SaveConfig();
}

function InternalOnChange(GUIComponent Sender)
{
    Super.InternalOnChange(Sender);

    switch (sender)
    {
        case ed_PlayerName:
			sPlayerName = ed_PlayerName.GetText();
			break;

        case co_GoreLevel:
            iGore = co_GoreLevel.GetIndex();
            break;

        case co_Netspeed:
            iNetSpeed = co_NetSpeed.GetIndex();
            break;

        case ch_DynNetspeed:
            bDynNet = ch_DynNetspeed.IsChecked();
            break;

        case ch_TankThrottle:
            bTankThrottle = ch_TankThrottle.IsChecked();
            break;

        case ch_VehicleThrottle:
            bVehicleThrottle = ch_VehicleThrottle.IsChecked();
            break;

        case ch_ManualReloading:
            bManualReloading = ch_ManualReloading.IsChecked();
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
   	class'Engine.GameInfo'.static.ResetConfig("GoreLevel");
	class'PlayerController'.static.ResetConfig("bDynamicNetSpeed");
    class'ROPlayer'.static.ResetConfig("bInterpolatedTankThrottle");
    class'ROPlayer'.static.ResetConfig("bInterpolatedVehicleThrottle");

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
     i_BG1=GUISectionBackground'ROInterface.ROTab_GameSettings.GameBK1'

     Begin Object Class=GUISectionBackground Name=GameBK2
         Caption="Network"
         WinTop=0.350000
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.250000
         RenderWeight=0.100200
         OnPreDraw=GameBK2.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'ROInterface.ROTab_GameSettings.GameBK2'

     Begin Object Class=GUISectionBackground Name=GameBK3
         Caption="Simulation Realism"
         WinTop=0.650000
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.250000
         RenderWeight=0.100200
         OnPreDraw=GameBK3.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'ROInterface.ROTab_GameSettings.GameBK3'

     Begin Object Class=moEditBox Name=OnlineStatsName
         Caption="Player Name"
         OnCreateComponent=OnlineStatsName.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Please select a name to use ingame"
         WinTop=0.373349
         WinLeft=0.524912
         WinWidth=0.419316
         TabOrder=1
         OnChange=ROTab_GameSettings.InternalOnChange
         OnLoadINI=ROTab_GameSettings.InternalOnLoadINI
     End Object
     ed_PlayerName=moEditBox'ROInterface.ROTab_GameSettings.OnlineStatsName'

     Begin Object Class=moComboBox Name=GameGoreLevel
         bReadOnly=True
         Caption="Gore Level"
         OnCreateComponent=GameGoreLevel.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Configure the amount of blood and gore you see while playing the game"
         WinTop=0.415521
         WinLeft=0.050000
         WinWidth=0.400000
         RenderWeight=1.040000
         TabOrder=2
         OnChange=ROTab_GameSettings.InternalOnChange
         OnLoadINI=ROTab_GameSettings.InternalOnLoadINI
     End Object
     co_GoreLevel=moComboBox'ROInterface.ROTab_GameSettings.GameGoreLevel'

     Begin Object Class=moCheckBox Name=NetworkDynamicNetspeed
         ComponentJustification=TXTA_Left
         CaptionWidth=0.950000
         Caption="Dynamic Netspeed"
         OnCreateComponent=NetworkDynamicNetspeed.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Netspeed is automatically adjusted based on the speed of your network connection"
         WinTop=0.166017
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=4
         OnChange=ROTab_GameSettings.InternalOnChange
         OnLoadINI=ROTab_GameSettings.InternalOnLoadINI
     End Object
     ch_DynNetspeed=moCheckBox'ROInterface.ROTab_GameSettings.NetworkDynamicNetspeed'

     Begin Object Class=moComboBox Name=OnlineNetSpeed
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Connection"
         OnCreateComponent=OnlineNetSpeed.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Cable Modem/DSL"
         Hint="How fast is your connection?"
         WinTop=0.122944
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=3
         OnChange=ROTab_GameSettings.InternalOnChange
         OnLoadINI=ROTab_GameSettings.InternalOnLoadINI
     End Object
     co_Netspeed=moComboBox'ROInterface.ROTab_GameSettings.OnlineNetSpeed'

     Begin Object Class=moCheckBox Name=ThrottleTanks
         ComponentJustification=TXTA_Left
         CaptionWidth=0.950000
         Caption="Incremental Tank Throttle"
         OnCreateComponent=ThrottleTanks.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enabling this allows you to incrementally increase or decrease the throttle in tanks"
         WinTop=0.166017
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=4
         OnChange=ROTab_GameSettings.InternalOnChange
         OnLoadINI=ROTab_GameSettings.InternalOnLoadINI
     End Object
     ch_TankThrottle=moCheckBox'ROInterface.ROTab_GameSettings.ThrottleTanks'

     Begin Object Class=moCheckBox Name=ThrottleVehicle
         ComponentJustification=TXTA_Left
         CaptionWidth=0.950000
         Caption="Incremental Vehicle Throttle"
         OnCreateComponent=ThrottleVehicle.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Enabling this allows you to incrementally increase or decrease the throttle for non-tank vehicles"
         WinTop=0.166017
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=4
         OnChange=ROTab_GameSettings.InternalOnChange
         OnLoadINI=ROTab_GameSettings.InternalOnLoadINI
     End Object
     ch_VehicleThrottle=moCheckBox'ROInterface.ROTab_GameSettings.ThrottleVehicle'

     Begin Object Class=moCheckBox Name=ManualReloading
         ComponentJustification=TXTA_Left
         CaptionWidth=0.950000
         Caption="Manual Tank Shell Reloading"
         OnCreateComponent=ManualReloading.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Stops tank shells from automatically reloading to allow for the selection of ammo types prior to reloading."
         WinTop=0.166017
         WinLeft=0.528997
         WinWidth=0.419297
         TabOrder=5
         OnChange=ROTab_GameSettings.InternalOnChange
         OnLoadINI=ROTab_GameSettings.InternalOnLoadINI
     End Object
     ch_ManualReloading=moCheckBox'ROInterface.ROTab_GameSettings.ManualReloading'

     NetSpeedText(0)="Modem"
     NetSpeedText(1)="ISDN"
     NetSpeedText(2)="Cable/ADSL"
     NetSpeedText(3)="LAN/T1"
     PanelCaption="Game"
     WinTop=0.150000
     WinHeight=0.720000
}
