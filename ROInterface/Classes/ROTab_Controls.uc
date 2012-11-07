//=============================================================================
// ROTab_Controls
//=============================================================================
// The controls config tab
// This merges the functionalities of the speech binder and keybinder
// (Contains most of the code form KeyBindMenu)
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROTab_Controls extends Settings_Tabs;

enum ESectionIDs
{
	SID_Movement,
	SID_Looking,
	SID_Weapons,
	SID_Comm,
	SID_Game,
	SID_Misc,
	SID_Interface
};

var automated GUISectionBackground      i_BG1;
var automated GUILabel                  l_Hint;
var automated GUIMultiColumnListBox     lb_Binds;
var GUIMultiColumnList                  li_Binds;

var bool                                bFirstOpen;

struct InputKeyInfo
{
	var int KeyNumber;
	var string KeyName;
	var string LocalizedKeyName;
};

struct KeyBinding
{
    var             bool            bIsSectionLabel;
    var             string          KeyLabel;
    var             string          Alias;
    var             array<int>  	BoundKeys;
};

var() noexport editconst InputKeyInfo AllKeys[255];

var() array<KeyBinding> Bindings;
var localized string BindingLabel[150]; // remove this later
var() bool bPendingRawInput;                  // Waiting for input - changing a keybind

var() editconst noexport int  NewIndex, NewSubIndex;
var() editconst noexport GUIStyles SelStyle, SectionStyle;
var() string SectionStyleName;

var() localized string Headings[3];
var() float SectionLabelMargin;

//var() localized string PageCaption;
//var() localized string SpeechLabel;
var() localized string ClearCaption, ActionText;


var localized string        Section_Movement, Section_Looking,
                            Section_Weapons, Section_Comm,
                            Section_Game, Section_Misc,
                            Section_Interface, Section_Speech_Prefix;

var array<string>           bindings_movement,
                            bindings_looking,
                            bindings_weapons,
                            bindings_comm,
                            bindings_game,
                            bindings_misc,
                            bindings_interface;

// Those are static because for some reason it frells up if they're dynamic. go figure.
var localized string        captions_movement[15],
                            captions_looking[15],
                            captions_weapons[15],
                            captions_comm[15],
                            captions_game[15],
                            captions_misc[15],
                            captions_interface[15];

var class<ROVoicePack>      VoicePackClass;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	i_BG1.ManageComponent(lb_Binds);
	i_BG1.ManageComponent(l_Hint);

	li_Binds = lb_Binds.List;
	SectionStyle = Controller.GetStyle(SectionStyleName, li_Binds.FontScale);
	//InitializeBindingsArray();
	//Initialize();
}

function InitializeBindingsArray()
{
	local int i;

	for ( i = 0; i < ArrayCount(AllKeys); i++ )
	{
		AllKeys[i].KeyNumber = i;
		Controller.KeyNameFromIndex( byte(i), AllKeys[i].KeyName, AllKeys[i].LocalizedKeyName );
	}
}

function Initialize()
{
	LoadCommands();
	MapBindings();
}

// query each key's assigned command/alias, and add the key number to the appropriate place
function MapBindings()
{
    local int i, BindingIndex;
    local string Alias;

    LoadCustomBindings();

    for ( i = 1; i < ArrayCount(AllKeys); i++ )
    {
    	// Find out if this key is currently bound to any commands
    	if ( Controller.GetCurrentBind( AllKeys[i].KeyName, Alias ) )
        {
        	// If this key is bound to a command, find out if the command is a known alias
        	BindingIndex = FindAliasIndex( Alias );
        	if ( BindingIndex != -1 )
            	BindKeyToAlias( BindingIndex, i );
        }
    }
}

function CreateAliasMapping(string Command, string FriendlyName, bool bSectionLabel)
{
    local int At;

    At = Bindings.Length;
    Bindings.Length = Bindings.Length + 1;

    Bindings[At].bIsSectionLabel = bSectionLabel;
    Bindings[At].KeyLabel = FriendlyName;
    Bindings[At].Alias = Command;

    li_Binds.AddedItem();
}

function BindKeyToAlias( int BindIndex, int KeyIndex )
{
	local int i;

	if ( !ValidBindIndex(BindIndex) )
		return;

	if ( !ValidKeyIndex(KeyIndex) )
		return;

	for ( i = 0; i < Bindings[BindIndex].BoundKeys.Length; i++ )
	{
		if ( Bindings[BindIndex].BoundKeys[i] == KeyIndex )
			return;

		if ( class'GameInfo'.static.GetBindWeight(Bindings[BindIndex].BoundKeys[i]) < class'GameInfo'.static.GetBindWeight(KeyIndex) )
			break;
	}

	Bindings[BindIndex].BoundKeys.Insert( i, 1 );
	Bindings[BindIndex].BoundKeys[i] = KeyIndex;
}

function ClearBindings()
{
	Bindings.Remove(0,Bindings.Length);
	li_Binds.Clear();
}

function SetKeyBind(int Index, int SubIndex, byte NewKey)
{
	if ( !ValidBindIndex(Index) )
		return;

    if ( SubIndex < Bindings[Index].BoundKeys.Length && Bindings[Index].BoundKeys[SubIndex] == NewKey )
        return;

    RemoveAllOccurance(NewKey);
   	RemoveExistingKey(Index, SubIndex);

    if ( Controller.SetKeyBind(AllKeys[NewKey].KeyName, Bindings[Index].Alias) )
	    BindKeyToAlias(Index,NewKey);

//	Controller.SetKeyBind( AllKeys[NewKey].KeyName, Bindings[Index].Alias );
    li_Binds.UpdatedItem(Index);
}

function bool BeginRawInput(GUIComponent Sender)
{
    local int Index, SubIndex;

    if ( MouseOnCol1() )
        SubIndex = 0;
    else if ( MouseOnCol2() )
        SubIndex = 1;
    else
        return true;

	Index = li_Binds.CurrentListId();
	if ( ValidBindIndex(Index) && Bindings[Index].bIsSectionLabel )
		return true;

    bPendingRawInput = true;
    UpdateHint(Index);

	NewIndex = Index;
    NewSubIndex = SubIndex;

    Controller.OnNeedRawKeyPress = RawKey;
    Controller.Master.bRequireRawJoystick = true;

    PlayerOwner().ClientPlaySound(Controller.EditSound);
    PlayerOwner().ConsoleCommand("toggleime 0");

    return true;
}

function bool RawKey(byte NewKey)
{
   	SetKeyBind( NewIndex, NewSubIndex, NewKey );

    NewSubIndex = -1;
	UpdateHint(NewIndex);
    NewIndex = -1;

    bPendingRawInput = false;
    Controller.OnNeedRawKeyPress = none;
    Controller.Master.bRequireRawJoystick = false;

    PlayerOwner().ClientPlaySound(Controller.ClickSound);
    return true;

}

function string GetCurrentKeyBind(int BindIndex, int SubIndex)
{
	if ( !ValidBindIndex(BindIndex) )
		return "";

    if (Bindings[BindIndex].bIsSectionLabel)
        return "";

    if (BindIndex == NewIndex && SubIndex == NewSubIndex)
        return "???";

    if (SubIndex >= Bindings[BindIndex].BoundKeys.Length)
        return "";

    return AllKeys[Bindings[BindIndex].BoundKeys[SubIndex]].LocalizedKeyName;
}

function string ListGetSortString( int Index )
{
	switch ( li_Binds.SortColumn )
	{
	case 0: return Bindings[Index].KeyLabel;
	case 1: return GetCurrentKeyBind(Index,0);
	case 2: return GetCurrentKeyBind(Index,1);
	}

	return "";
}

function bool ListOnKeyEvent(out byte Key, out byte State, float delta)
{
    local Interactions.EInputKey iKey;

	if ( State != 3 )
		return li_Binds.InternalOnKeyEvent(Key,State,Delta);

	iKey = EInputKey(Key);
	if ( iKey == IK_Backspace )    // Backspace
    {
        // Clear Over
        if ( MouseOnCol1() )
            RemoveExistingKey(li_Binds.CurrentListId(),0);

        else if ( MouseOnCol2() )
            RemoveExistingKey(li_Binds.CurrentListId(),1);

        return true;
    }

    if ( iKey == IK_Enter )
    {
        BeginRawInput(None);
        return true;
    }

	return li_Binds.InternalOnKeyEvent(Key,State,Delta);
}

function ListTrack(GUIComponent Sender, int LastIndex)
{
	local int Index, OldIndex;

	if ( LastIndex >= 0 && LastIndex < li_Binds.ItemCount )
	{
		OldIndex = li_Binds.SortData[LastIndex].SortItem;
		Index = li_Binds.CurrentListId();

		if ( ValidBindIndex(Index) && Bindings[Index].bIsSectionLabel )
			SearchDown(OldIndex);

		if ( !bPendingRawInput )
			UpdateHint(Index);
	}
}

function SearchUp(int OldIndex)
{
    local int cindex;

    cindex = li_Binds.CurrentListId();
    while ( cindex > 0 && cindex < Bindings.length)
    {
        if ( !Bindings[cindex].bIsSectionLabel )
        {
            li_Binds.SetIndex(cIndex);
            return;
        }
        cindex--;
    }
    li_Binds.SetIndex(OldIndex);
}

function SearchDown(int OldIndex)
{
    local int cindex;

    cindex = li_Binds.CurrentListId();
    while ( cindex > 0 && cindex < Bindings.Length )
    {
        if (!Bindings[cindex].bIsSectionLabel)
        {
            li_Binds.SetIndex(cIndex);
            return;
        }
        cindex++;
    }
    li_Binds.SetIndex(OldIndex);
}



function RemoveExistingKey(int Index, int SubIndex)
{
	local int KeyIndex;

	if ( !ValidBindIndex(Index) )
		return;

    if ( SubIndex >= Bindings[Index].BoundKeys.Length || Bindings[Index].BoundKeys[SubIndex] < 0 )
        return;

	KeyIndex = Bindings[Index].BoundKeys[SubIndex];
    Bindings[Index].BoundKeys.Remove(SubIndex, 1);

	Controller.SetKeyBind( AllKeys[KeyIndex].KeyName, "" );
}

function RemoveAllOccurance(byte NewKey)
{
    local int i,j;

	for ( i = 0; i < Bindings.Length; i++ )
	{
		for ( j = 0; j < Bindings[i].BoundKeys.Length; j++ )
		{
			if ( Bindings[i].BoundKeys[j] == NewKey )
			{
				RemoveExistingKey(i,j);
				break;
			}
		}
	}
}


function UpdateHint(int BindIndex)
{
	local int i;
	local string Str, CurrentBindName;

    if ( !ValidBindIndex(BindIndex) || Bindings[BindIndex].bIsSectionLabel )
    {
    	l_Hint.Caption = "";
        return;
    }

	if ( Bindings[BindIndex].BoundKeys.Length > 0 )
	{
		if ( bPendingRawInput )
		{
		DrawCurrentBind:
			for ( i = 0; i < Bindings[BindIndex].BoundKeys.Length; i++ )
			{
				if ( Str != "" )
					Str $= ",";
				Str $= GetCurrentKeyBind(BindIndex, i);
			}

			if ( Str == "" )
				l_Hint.Caption = "";
			else l_Hint.Caption = Repl(ActionText, "%keybinds%", Str);
			return;
		}
		else
		{
			if ( MouseOnCol2() ) i = 1;
			CurrentBindName = GetCurrentKeyBind(BindIndex,i);
			if ( CurrentBindName == "" )
				goto DrawCurrentBind;

			Str = Repl(Repl(ClearCaption,"%backspace%",AllKeys[8].LocalizedKeyName),
			           "%keybind%",CurrentBindName);
			l_Hint.Caption = Repl( Str, "%keyname%", Bindings[BindIndex].KeyLabel );;
		}

	}
	else l_Hint.Caption = "";
}

function bool MouseOnCol1()
{
	local float CellLeft, CellWidth;

	li_Binds.GetCellLeftWidth(1, CellLeft, CellWidth);
	return Controller.MouseX >= CellLeft && Controller.MouseX <= CellLeft + CellWidth;
}

function bool MouseOnCol2()
{
	local float CellLeft, CellWidth;

	li_Binds.GetCellLeftWidth(2, CellLeft, CellWidth);
	return Controller.MouseX >= CellLeft && Controller.MouseX <= CellLeft + CellWidth;
}

function bool ValidBindIndex(int Index)
{
	return Index >= 0 && Index < Bindings.Length;
}

function bool ValidKeyIndex(int Index)
{
	return Index >= 0 && Index < ArrayCount(AllKeys);
}

function int FindAliasIndex( string Alias )
{
	local int i;

	for ( i = 0; i < Bindings.Length; i++ )
		if ( Bindings[i].Alias ~= Alias )
			return i;

	return -1;
}

function InternalOnCreateComponent( GUIComponent NewComp, GUIComponent Sender )
{
	local GUIMultiColumnList L;
	local int i;

	if ( GUIMultiColumnListBox(Sender) != None )
	{
		L = GUIMultiColumnList(NewComp);
		if ( L != None )
		{
			for ( i = 0; i < ArrayCount(Headings); i++ )
				L.ColumnHeadings[i] = Headings[i];

			L.OnKeyEvent = ListOnKeyEvent;
			L.OnDrawItem = DrawBinding;
			L.GetSortString = ListGetSortString;
			L.ExpandLastColumn = True;
			L.SortColumn = -1;
			L.bHotTrack = True;
			L.OnClick = BeginRawInput;
			L.OnTrack = ListTrack;
		}

		GUIMultiColumnListBox(Sender).InternalOnCreateComponent(NewComp,Sender);
	}

	//Super.InternalOnCreateComponent(NewComp,Sender);
}

function DrawBinding(Canvas Canvas, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local GUIStyles DStyle;

	// hack to fix selected item appearing offset
	// real fix would be to create a "NoBackground" style that has the same border offsets as STY2ListSelection
	local int i;
    local int SavedOffset[4];

   	Canvas.Style = 1;
    Item = li_Binds.SortData[Item].SortItem;

	if ( !ValidBindIndex(Item) )
		return;

    if ( Bindings[Item].bIsSectionLabel )
    {
    	li_Binds.GetCellLeftWidth( 0, CellLeft, CellWidth );
    	Canvas.SetPos( CellLeft + 3, Y );
    	Canvas.DrawColor = SectionStyle.ImgColors[li_Binds.MenuState];

    	Canvas.DrawTile(Controller.DefaultPens[0], W - 6, H, 0, 0, 32, 32);
    	SectionStyle.DrawText(Canvas, li_Binds.MenuState, CellLeft + SectionLabelMargin, Y, CellWidth, H, TXTA_Left, Bindings[Item].KeyLabel, li_Binds.FontScale);
        return;
    }

    if ( bPendingRawInput )
    	bSelected = Item - li_Binds.Top == NewIndex;

    if ( bSelected )
    	DStyle = li_Binds.SelectedStyle;
    else DStyle = li_Binds.Style;

	for ( i = 0; i < 4; i++ )
	{
		SavedOffset[i] = DStyle.BorderOffsets[i];
		DStyle.BorderOffsets[i] = class'STY2ListSelection'.default.BorderOffsets[i];
	}

	if ( bSelected && !bPendingRawInput )
		DStyle.Draw( Canvas, li_Binds.MenuState, X + DStyle.BorderOffsets[0], Y, W - DStyle.BorderOffsets[2], H );

	li_Binds.GetCellLeftWidth(0, CellLeft, CellWidth);
	DStyle.DrawText( Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H, TXTA_Center, Bindings[Item].KeyLabel, li_Binds.FontScale);

	li_Binds.GetCellLeftWidth(1, CellLeft, CellWidth);
	if ( bPendingRawInput && bSelected && NewSubIndex == 0 )
		DStyle.Draw( Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H );
	DStyle.DrawText(Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H, TXTA_Center, GetCurrentKeyBind(Item, 0), li_Binds.FontScale);

	li_Binds.GetCellLeftWidth(2, CellLeft, CellWidth);
	if ( bPendingRawInput && bSelected && NewSubIndex == 1 )
		DStyle.Draw(Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H);
	DStyle.DrawText(Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H, TXTA_Center, GetCurrentKeyBind(Item, 1), li_Binds.FontScale);

	for ( i = 0; i < 4; i++ )
		DStyle.BorderOffsets[i] = SavedOffset[i];
}

function ResetClicked()
{
    if (Controller != none)
        Controller.ResetKeyboard();
	Initialize();
}

event Opened(GUIComponent Sender)
{
    if (bFirstOpen)
    {
        InitializeBindingsArray();
        Initialize();
        bFirstOpen = false;
    }

    Super.Opened(Sender);
}

protected function LoadCustomBindings()
{
	local int i;
	local array<string> KeyBindClasses;
    local class<GUIUserKeyBinding> CustomKeyBindClass;

    // Load custom keybinds from .int files
    PlayerOwner().GetAllInt("XInterface.GUIUserKeyBinding",KeyBindClasses);
	for (i = 0; i < KeyBindClasses.Length; i++)
	{
		CustomKeyBindClass = class<GUIUserKeyBinding>(DynamicLoadObject(KeyBindClasses[i],class'Class'));
		if (CustomKeyBindClass != None)
			AddCustomBindings( CustomKeyBindClass.default.KeyData );
    }
}

function AddCustomBindings( array<GUIUserKeyBinding.KeyInfo> KeyData )
{
	local int i;

	for ( i = 0; i < KeyData.Length; i++ )
		CreateAliasMapping( KeyData[i].Alias, KeyData[i].KeyLabel, KeyData[i].bIsSection );
}

/*function TestClearBindings()
{
	local int i, max;

	Bindings = default.Bindings;
	max = Min(Bindings.Length, ArrayCount(BindingLabel));
	for ( i = 0; i < max; i++ )
	{
		if ( BindingLabel[i] != "" )
			Bindings[i].KeyLabel = BindingLabel[i];
	}
}*/

// Add all possible commands to the guilist
function LoadCommands()
{
    local array<string> VoiceCommands;
    local int i;

	ClearBindings();

	// Load RO keybinds
	AddBindings(Section_Game,      bindings_game.length,       SID_Game);
	AddBindings(Section_Movement,  bindings_movement.length,   SID_Movement);
	AddBindings(Section_Weapons,   bindings_weapons.length,    SID_Weapons);
	AddBindings(Section_Looking,   bindings_looking.length,    SID_Looking);
	AddBindings(Section_Comm,      bindings_comm.length,       SID_Comm);
	AddBindings(Section_Interface, bindings_interface.length,  SID_Interface);
	AddBindings(Section_Misc,      bindings_misc.length,       SID_Misc);

	// Load custom keybinds
	LoadCustomBindings();

	// Load speech binds
	UpdateVoicePackClass();

	// Support requests
    CreateAliasMapping("", Section_Speech_Prefix $ class'ROConsole'.default.SMStateName[1], True);
	VoicePackClass.static.GetAllSupports( VoiceCommands );
	for (i = 0; i < VoiceCommands.Length; i++)
		CreateAliasMapping("speech SUPPORT" @ i, VoiceCommands[i], false);

	// Acknowledgements requests
    CreateAliasMapping("", Section_Speech_Prefix $ class'ROConsole'.default.SMStateName[2], True);
	VoicePackClass.static.GetAllAcknowledges( VoiceCommands );
	for (i = 0; i < VoiceCommands.Length; i++)
		CreateAliasMapping("speech ACK" @ i, VoiceCommands[i], false);

    // Enemy spotted
    CreateAliasMapping("", Section_Speech_Prefix $ class'ROConsole'.default.SMStateName[3], True);
	VoicePackClass.static.GetAllEnemies( VoiceCommands );
	for (i = 0; i < VoiceCommands.Length; i++)
		CreateAliasMapping("speech ENEMY" @ i, VoiceCommands[i], false);

    // Alerts
    CreateAliasMapping("", Section_Speech_Prefix $ class'ROConsole'.default.SMStateName[4], True);
	VoicePackClass.static.GetAllAlerts( VoiceCommands );
	for (i = 0; i < VoiceCommands.Length; i++)
		CreateAliasMapping("speech ALERT" @ i, VoiceCommands[i], false);

    // Vehicle orders
	CreateAliasMapping("", Section_Speech_Prefix $ class'ROConsole'.default.SMStateName[5], True);
	VoicePackClass.static.GetAllVehicleDirections( VoiceCommands );
	for (i = 0; i < VoiceCommands.Length; i++)
		CreateAliasMapping("speech VEH_ORDERS" @ i, VoiceCommands[i], false);

	// Vehicle alerts
	CreateAliasMapping("", Section_Speech_Prefix $ class'ROConsole'.default.SMStateName[6], True);
	VoicePackClass.static.GetAllVehicleAlerts( VoiceCommands );
	for (i = 0; i < VoiceCommands.Length; i++)
		CreateAliasMapping("speech VEH_ALERTS" @ i, VoiceCommands[i], false);

	// Commands
	CreateAliasMapping("", Section_Speech_Prefix $ class'ROConsole'.default.SMStateName[7], True);
	VoicePackClass.static.GetAllOrders( VoiceCommands );
	for (i = 0; i < VoiceCommands.Length; i++)
		CreateAliasMapping("speech ORDER" @ i, VoiceCommands[i], false);

    // Extras
	CreateAliasMapping("", Section_Speech_Prefix $ class'ROConsole'.default.SMStateName[8], True);
	VoicePackClass.static.GetAllExtras( VoiceCommands );
	for (i = 0; i < VoiceCommands.Length; i++)
		CreateAliasMapping("speech TAUNT" @ i, VoiceCommands[i], false);

}

function UpdateVoicePackClass()
{
    // Keep default
}


// Valid section ids:
function AddBindings(string section_title, int num_elements, ESectionIDs section_id)
{
    local int i;
    local string a, c;

    if (section_title != "")
        CreateAliasMapping("", section_title, true );

    for (i = 0; i < num_elements; i++)
    {
        switch (section_id)
        {
            case SID_Movement: a = bindings_movement[i]; c = captions_movement[i]; break;
            case SID_Looking: a = bindings_looking[i]; c = captions_looking[i]; break;
            case SID_Weapons: a = bindings_weapons[i]; c = captions_weapons[i]; break;
            case SID_Comm: a = bindings_comm[i]; c = captions_comm[i]; break;
            case SID_Game: a = bindings_game[i]; c = captions_game[i]; break;
            case SID_Misc: a = bindings_misc[i]; c = captions_misc[i]; break;
            case SID_Interface: a = bindings_interface[i]; c = captions_interface[i]; break;
            default: a = ""; c = "Unknown id: " $ section_id; break;
        }

        CreateAliasMapping(a, c, false);
    }
}

defaultproperties
{
     Begin Object Class=ROGUIProportionalContainer Name=InputBK1
         Caption="Bindings"
         LeftPadding=0.000000
         RightPadding=0.000000
         TopPadding=0.010000
         BottomPadding=0.000000
         WinTop=0.021641
         WinLeft=0.021641
         WinWidth=0.956718
         WinHeight=0.956718
         OnPreDraw=InputBK1.InternalPreDraw
     End Object
     i_BG1=ROGUIProportionalContainer'ROInterface.ROTab_Controls.InputBK1'

     Begin Object Class=GUILabel Name=HintLabel
         TextAlign=TXTA_Center
         bMultiLine=True
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         StyleName="textLabel"
         WinTop=0.950000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_Hint=GUILabel'ROInterface.ROTab_Controls.HintLabel'

     Begin Object Class=GUIMultiColumnListBox Name=BindListBox
         HeaderColumnPerc(0)=0.500000
         HeaderColumnPerc(1)=0.250000
         HeaderColumnPerc(2)=0.250000
         OnCreateComponent=ROTab_Controls.InternalOnCreateComponent
         WinHeight=0.900000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_Binds=GUIMultiColumnListBox'ROInterface.ROTab_Controls.BindListBox'

     bFirstOpen=True
     SectionStyleName="ListSection"
     Headings(0)="Action"
     Headings(1)="Key 1"
     Headings(2)="Key 2"
     SectionLabelMargin=10.000000
     ClearCaption="Press '%backspace%' to unbind %keybind% from %keyname%."
     ActionText="{%keybinds%} - currently bound to this key."
     Section_Movement="Movement"
     Section_Looking="Looking"
     Section_Weapons="Weapons"
     Section_Comm="Communication"
     Section_Game="Game"
     Section_Misc="Miscellaneous"
     Section_Interface="Interface"
     Section_Speech_Prefix="Voice Commands: "
     bindings_movement(0)="MoveForward"
     bindings_movement(1)="MoveBackward"
     bindings_movement(2)="StrafeLeft"
     bindings_movement(3)="StrafeRight"
     bindings_movement(4)="LeanLeft"
     bindings_movement(5)="LeanRight"
     bindings_movement(6)="Jump"
     bindings_movement(7)="Duck"
     bindings_movement(8)="Prone"
     bindings_movement(9)="Button bSprint"
     bindings_movement(10)="Walking"
     bindings_movement(11)="ToggleDuck"
     bindings_looking(0)="TurnLeft"
     bindings_looking(1)="TurnRight"
     bindings_looking(2)="LookUp"
     bindings_looking(3)="LookDown"
     bindings_looking(4)="CenterView"
     bindings_looking(5)="ToggleBehindView"
     bindings_looking(6)="ToggleFreeCam"
     bindings_weapons(0)="Fire"
     bindings_weapons(1)="AltFire"
     bindings_weapons(2)="ROManualReload"
     bindings_weapons(3)="ROIronSights"
     bindings_weapons(4)="ThrowWeapon"
     bindings_weapons(5)="NextWeapon"
     bindings_weapons(6)="PrevWeapon"
     bindings_weapons(7)="SwitchToBestWeapon"
     bindings_weapons(8)="SwitchToLastWeapon"
     bindings_weapons(9)="Deploy"
     bindings_weapons(10)="ROMGOperation"
     bindings_weapons(11)="SwitchFireMode"
     bindings_comm(0)="Talk"
     bindings_comm(1)="TeamTalk"
     bindings_comm(2)="VehicleTalk"
     bindings_comm(3)="SpeechMenuToggle"
     bindings_comm(4)="InGameChat"
     bindings_comm(5)="VoiceTalk"
     bindings_comm(6)="Speak Public"
     bindings_comm(7)="Speak Local"
     bindings_comm(8)="Speak Team"
     bindings_game(0)="ShowMenu"
     bindings_game(1)="use"
     bindings_game(2)="ThrowMGAmmo"
     bindings_game(3)="Pause"
     bindings_misc(0)="ShowVoteMenu"
     bindings_misc(1)="ConsoleToggle"
     bindings_misc(2)="Stat Net"
     bindings_misc(3)="Cancel"
     bindings_misc(4)="demorec"
     bindings_misc(5)="stopdemo"
     bindings_misc(6)="shot"
     bindings_misc(7)="ServerInfo"
     bindings_misc(8)="ShowStats"
     bindings_misc(9)="NextStats"
     bindings_interface(0)="ShowObjectives"
     bindings_interface(1)="ShowScores"
     bindings_interface(2)="ScoreToggle"
     bindings_interface(3)="GrowHud"
     bindings_interface(4)="ShrinkHud"
     captions_movement(0)="Forward"
     captions_movement(1)="Backward"
     captions_movement(2)="Strafe Left"
     captions_movement(3)="Strafe Right"
     captions_movement(4)="Lean Left"
     captions_movement(5)="Lean Right"
     captions_movement(6)="Jump"
     captions_movement(7)="Crouch"
     captions_movement(8)="Prone"
     captions_movement(9)="Sprint"
     captions_movement(10)="Walk"
     captions_movement(11)="Toggle Crouch"
     captions_looking(0)="Turn Left"
     captions_looking(1)="Turn Right"
     captions_looking(2)="Look Up"
     captions_looking(3)="Look Down"
     captions_looking(4)="Center View"
     captions_looking(5)="Toggle Third Person Mode (offline only)"
     captions_looking(6)="Toggle Camera Mode (offline only)"
     captions_weapons(0)="Primary Fire"
     captions_weapons(1)="Alternate Fire"
     captions_weapons(2)="Reload"
     captions_weapons(3)="Iron Sights"
     captions_weapons(4)="Throw Weapon"
     captions_weapons(5)="Next Weapon"
     captions_weapons(6)="Previous Weapon"
     captions_weapons(7)="Switch to Best Weapon"
     captions_weapons(8)="Switch to Last Weapon"
     captions_weapons(9)="Attach Bayonet / Deploy MG"
     captions_weapons(10)="Change MG Barrel"
     captions_weapons(11)="Switch Fire Mode"
     captions_comm(0)="Say"
     captions_comm(1)="Team Say"
     captions_comm(2)="Vehicle Say"
     captions_comm(3)="Voice Command Menu"
     captions_comm(4)="View In-game Chat"
     captions_comm(5)="Activate Microphone"
     captions_comm(6)="Switch to Public Voice Channel"
     captions_comm(7)="Switch to Local Voice Channel"
     captions_comm(8)="Switch to Team Voice Channel"
     captions_game(0)="Open Game Menu"
     captions_game(1)="Use"
     captions_game(2)="Resupply Gunner"
     captions_game(3)="Pause Game"
     captions_misc(0)="Open Voting Menu"
     captions_misc(1)="Toggle Console"
     captions_misc(2)="View Connection Status"
     captions_misc(3)="Cancel Pending Connection"
     captions_misc(4)="Start Demo Recording"
     captions_misc(5)="Stop Demo Recording"
     captions_misc(6)="Take Screenshot"
     captions_misc(7)="View Server Info"
     captions_misc(8)="Show Personal Stats"
     captions_misc(9)="View Next Player's Stats"
     captions_interface(0)="Toggle Situation Map"
     captions_interface(1)="Toggle Scoreboard"
     captions_interface(2)="Show Scoreboard"
     captions_interface(3)="Increase HUD Size"
     captions_interface(4)="Decrease HUD Size"
     VoicePackClass=Class'ROEngine.ROVoicePack'
}
