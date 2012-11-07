//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4Tab_IForceSettings extends UT2K4Tab_IForceSettings;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Super.Initcomponent(MyController, MyOwner);

class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

}

function bool InternalOnClick(GUIComponent Sender)
{
	local GUITabControl C;
	local int i;

	if ( Sender == b_Controls )
	{
		Controller.OpenMenu(ControlBindMenu);
	}

	else if ( Sender == b_Speech )
	{
		// Hack - need to update the players character and voice options before opening the speechbind menu
		C = GUITabControl(MenuOwner);
		if ( C != None )
		{
			for ( i = 0; i < C.TabStack.Length; i++ )
			{
				if ( C.TabStack[i] != None && UT2K4Tab_PlayerSettings(C.TabStack[i].MyPanel) != None )
				{
					UT2K4Tab_PlayerSettings(C.TabStack[i].MyPanel).SaveSettings();
					break;
				}
			}
		}

		Controller.OpenMenu(SpeechBindMenu);
	}

	return true;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=InputBK1
         Caption="Options"
         WinTop=0.028176
         WinLeft=0.021641
         WinWidth=0.331328
         WinHeight=0.605039
         OnPreDraw=InputBK1.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'ROInterface.ROUT2K4Tab_IForceSettings.InputBK1'

     Begin Object Class=GUISectionBackground Name=InputBK2
         Caption="TouchSense Force Feedback"
         WinTop=0.680000
         WinLeft=0.021641
         WinWidth=0.857500
         WinHeight=0.190977
         OnPreDraw=InputBK2.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'ROInterface.ROUT2K4Tab_IForceSettings.InputBK2'

     Begin Object Class=GUISectionBackground Name=InputBK3
         Caption="Fine Tuning"
         WinTop=0.028176
         WinLeft=0.401289
         WinWidth=0.477812
         WinHeight=0.605039
         OnPreDraw=InputBK3.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'ROInterface.ROUT2K4Tab_IForceSettings.InputBK3'

     Begin Object Class=moCheckBox Name=InputIFWeaponEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Weapon Effects"
         OnCreateComponent=InputIFWeaponEffects.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option On/Off to feel the weapons you fire."
         WinTop=0.755333
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=12
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_WeaponEffects=moCheckBox'ROInterface.ROUT2K4Tab_IForceSettings.InputIFWeaponEffects'

     Begin Object Class=moCheckBox Name=InputIFPickupEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Pickup Effects"
         OnCreateComponent=InputIFPickupEffects.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option On/Off to feel the items you pick up."
         WinTop=0.806333
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=13
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_PickupEffects=moCheckBox'ROInterface.ROUT2K4Tab_IForceSettings.InputIFPickupEffects'

     Begin Object Class=moCheckBox Name=InputIFDamageEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Damage Effects"
         OnCreateComponent=InputIFDamageEffects.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option On/Off to feel the damage you take."
         WinTop=0.755333
         WinLeft=0.563867
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=14
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_DamageEffects=moCheckBox'ROInterface.ROUT2K4Tab_IForceSettings.InputIFDamageEffects'

     Begin Object Class=moCheckBox Name=InputIFGUIEffects
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Vehicle Effects"
         OnCreateComponent=InputIFGUIEffects.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Turn this option On/Off to feel the vehicle effects."
         WinTop=0.806333
         WinLeft=0.563867
         WinWidth=0.300000
         WinHeight=0.040000
         TabOrder=15
         OnChange=UT2K4Tab_IForceSettings.InternalOnChange
         OnLoadINI=UT2K4Tab_IForceSettings.InternalOnLoadINI
     End Object
     ch_GUIEffects=moCheckBox'ROInterface.ROUT2K4Tab_IForceSettings.InputIFGUIEffects'

     ControlBindMenu="ROInterface.ROControlBinder"
     SpeechBindMenu="ROInterface.ROSpeechBinder"
}
