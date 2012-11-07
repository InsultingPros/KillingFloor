class UT2K4ArenaConfig extends BlackoutWindow;
// Commented out UT2k4Merge - Ramm
/*
var automated moComboBox	co_Weapon;
var automated GUIButton		b_OK;
var automated GUILabel		l_Title;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<CacheManager.WeaponRecord> Recs;
	local int i;

	Super.InitComponent(MyController, MyOwner);

	class'CacheManager'.static.GetWeaponList(Recs);
	for (i = 0; i < Recs.Length; i++)
		co_Weapon.AddItem(Recs[i].FriendlyName, None, Recs[i].ClassName);

	co_Weapon.ReadOnly(True);
	i = co_Weapon.FindExtra(class'MutArena'.default.ArenaWeaponClassName);
	if (i != -1)
		co_Weapon.SetIndex(i);
}

function bool InternalOnClick(GUIComponent Sender)
{
	class'MutArena'.default.ArenaWeaponClassName = co_Weapon.GetExtra();
	class'MutArena'.static.StaticSaveConfig();

	Controller.CloseMenu(false);

	return true;
}

defaultproperties
{
	Begin Object Class=GUIButton Name=OkButton
		Caption="OK"
		WinWidth=0.200000
		WinHeight=0.040000
		WinLeft=0.400000
		WinTop=0.563333
		OnClick=InternalOnClick
		TabOrder=1
	End Object
    b_Ok=OKButton

	Begin Object class=GUILabel Name=DialogText
		Caption="Weapon Arena"
		TextAlign=TXTA_Center
		StyleName="TextLabel"
		FontScale=FNS_Large
		WinWidth=1.000000
		WinHeight=0.058750
		WinLeft=0.000000
		WinTop=0.391667
	End Object

	Begin Object class=moComboBox Name=WeaponSelect
		WinWidth=0.500782
		WinHeight=0.126563
		WinLeft=0.255078
		WinTop=0.442760
		bStandardized=false
		Caption="Choose the weapon to populate your Arena."
		LabelJustification=TXTA_Center
		ComponentJustification=TXTA_Center
		ComponentWidth=0.25
		bReadOnly=true
		bVerticalLayout=True
		TabOrder=0
	End Object


	l_Title=DialogText
//	l_Desc=DialogText2
	co_Weapon=WeaponSelect
}     */

defaultproperties
{
}
