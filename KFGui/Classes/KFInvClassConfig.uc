//==============================================================================
//	KFInvClassConfig
//==============================================================================
class KFInvClassConfig extends GUICustomPropertyPage;

var automated GUIImage              i_Background;
var automated GUIMultiOptionListBox lb_Waves;
var GUIMultiOptionList              li_waves;

var array<string> MonsterClasses;
var array<moEditBox> MTxtBoxes;

var	localized string	MonsterClassConfigTitle;

function string GetResult()
{
	return "";
}

function InitActiveClasses()
{
	local int i,l;

	// Init monster table
	l = Class'KFGameType'.Default.MonsterClasses.Length;
	MonsterClasses.Length = l;
	For( i=0; i<l; i++ )
		MonsterClasses[i] = Class'KFGameType'.Default.MonsterClasses[i].MClassName;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	li_Waves = lb_Waves.List;
	li_Waves.OnChange = InternalOnChange;
	li_Waves.bDrawSelectionBorder = False;
	li_Waves.ItemPadding=0.15;
	li_Waves.ColumnWidth=0.95;
	li_Waves.bHotTrackSound = False;

	sb_Main.ManageComponent(lb_Waves);
	sb_Main.LeftPadding=0;
	sb_Main.RightPadding=0;
	sb_Main.TopPadding=0.05;
	sb_Main.BottomPadding=0.05;
	sb_Main.SetPosition(0.030234,0.075000,0.851640,0.565624);
}

function SetOwner( GUIComponent NewOwner )
{
	Super.SetOwner(NewOwner);

	t_WindowTitle.Caption = MonsterClassConfigTitle;
	InitActiveClasses();
	InitializeList();
}

function InitializeList()
{
	local int i;
	local moEditBox ch;

	MTxtBoxes.Length = Max(MonsterClasses.Length,30);

	For( i=0; i<MTxtBoxes.Length; i++ )
	{
		ch = moEditBox(li_Waves.AddItem( "XInterface.moEditBox",, "Monster"@GetIDName(i)));
		if ( ch != None )
		{
			MTxtBoxes[i] = ch;
			if( i<MonsterClasses.Length )
				ch.SetComponentValue(MonsterClasses[i],True);
			else ch.SetComponentValue("<Empty>",True);
			ch.bAutoSizeCaption = True;
		}
	}
}

function string GetIDName( int Num )
{
	if( Num<26 )
		Return Chr(65+Num); // A-Z
	else Return Chr(71+Num); // a-z
}

function string GetDataString()
{
	return "";
}

function InternalOnChange(GUIComponent Sender)
{
	local GUIMenuOption mo;
	local int i;

	if ( Sender == li_Waves )
	{
		mo = li_Waves.Get();

		if ( moEditBox(mo)!=None )
		{
			for( i=0; i<MTxtBoxes.Length; i++ )
			{
				if( MTxtBoxes[i]==mo )
				{
					MonsterClasses[i] = MTxtBoxes[i].GetComponentValue();
					Break;
				}
			}
		}
	}
}

event Closed( GUIComponent Sender, bool bCancelled )
{
	local int i;

	if( bCancelled )
		Return;
	for( i=0; i<MonsterClasses.Length; i++ )
	{
		if( Len(MonsterClasses[i])==0 || MonsterClasses[i]=="<Empty>" || Class<Monster>(DynamicLoadObject(MonsterClasses[i],Class'Class'))==None )
		{
			MonsterClasses.Remove(i,1);
			i--;
		}
	}
	Class'KFGameType'.Default.MonsterClasses.Length = MonsterClasses.Length;
	for( i=0; i<MonsterClasses.Length; i++ )
	{
		Class'KFGameType'.Default.MonsterClasses[i].MClassName = MonsterClasses[i];
		Class'KFGameType'.Default.MonsterClasses[i].MID = GetIDName(i);
	}
	Class'KFGameType'.Static.StaticSaveConfig();
}

defaultproperties
{
     Begin Object Class=GUIMultiOptionListBox Name=WavesList
         bVisibleWhenEmpty=True
         OnCreateComponent=WavesList.InternalOnCreateComponent
         WinTop=0.150608
         WinLeft=0.007500
         WinWidth=0.983750
         WinHeight=0.698149
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFInvClassConfig.InternalOnChange
     End Object
     lb_Waves=GUIMultiOptionListBox'KFGui.KFInvClassConfig.WavesList'

     MonsterClassConfigTitle="Killing Floor Monster Classlist config page"
     DefaultLeft=0.050000
     DefaultWidth=0.900000
     bDrawFocusedLast=False
     WinLeft=0.050000
     WinWidth=0.900000
}
