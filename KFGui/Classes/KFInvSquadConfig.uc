//==============================================================================
//	KFInvSquadConfig
//==============================================================================
class KFInvSquadConfig extends GUICustomPropertyPage;

var automated GUIImage              i_Background;
var automated moNumericEdit         nu_Wave;
var automated GUIMultiOptionListBox lb_Waves;
var GUIMultiOptionList              li_waves;

var	localized string	SquadConfigTitle;

struct WaveMonsterType
{
	var string MName,MID;
	var moNumericEdit MonsterCount;
};

var int ActiveSquad;
var array<WaveMonsterType> SquadMonsters;
struct WMCount
{
	var array<int> MCount;
};
var array<WMCount> Squads;

function string GetResult()
{
	return "";
}

function InitActiveClasses()
{
	local int i,l,j,c,z;
	local string S,ID;

	// Init monster table
	l = Class'KFGameType'.default.MonsterCollection.Default.MonsterClasses.Length;
	SquadMonsters.Length = l;
	For( i=0; i<l; i++ )
	{
		SquadMonsters[i].MID = Class'KFGameType'.default.MonsterCollection.Default.MonsterClasses[i].MID;
		SquadMonsters[i].MName = GetMonsterName(Class'KFGameType'.default.MonsterCollection.Default.MonsterClasses[i].MClassName);
	}

	// Init active squads on current settings
	z = Class'KFGameType'.Default.MonsterSquad.Length;
	Squads.Length = 31;
	For( i=0; i<z; i++ )
	{
		Squads[i].MCount.Length = l;
		S = Class'KFGameType'.Default.MonsterSquad[i];
		while( Len(S)>0 )
		{
			c = int(Left(S,1));
			ID = Mid(S,1,1);
			for( j=0; j<l; j++ )
			{
				if( SquadMonsters[j].MID==ID )
				{
					Squads[i].MCount[j] = c;
					Break;
				}
			}
			S = Mid(S,2);
		}
	}
	while( i<31 )
	{
		Squads[i].MCount.Length = l;
		i++;
	}
}
function string GetMonsterName( string InS )
{
	local Class<Monster> MC;

	MC = Class<Monster>(DynamicLoadObject(InS,Class'Class'));
	if( MC==None )
		Return "Invalid";
	else if( MC.Default.MenuName!="" )
		Return MC.Default.MenuName;
	Return string(MC.Name);
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

	t_WindowTitle.Caption = SquadConfigTitle;
	InitActiveClasses();
	InitializeList();
}

function InitializeList()
{
	local int i;
	local moNumericEdit ch;

	For( i=0; i<SquadMonsters.Length; i++ )
	{
		ch = moNumericEdit(li_Waves.AddItem( "XInterface.moNumericEdit",, SquadMonsters[i].MName));
		if ( ch != None )
		{
			SquadMonsters[i].MonsterCount = ch;
			ch.Setup( 0, 9, 1 );
			ch.bAutoSizeCaption = True;
		}
	}

	UpdateSquadValues();
}

function string GetDataString()
{
	return "";
}

function InternalOnChange(GUIComponent Sender)
{
	local GUIMenuOption mo;
	local int i;

	if ( Sender == nu_Wave )
	{
		ActiveSquad = nu_Wave.GetValue();
		UpdateSquadValues();
	}
	else if ( Sender == li_Waves )
	{
		mo = li_Waves.Get();

		if ( moNumericEdit(mo) != None )
		{
			for( i=0; i<SquadMonsters.Length; i++ )
			{
				if( SquadMonsters[i].MonsterCount==mo )
				{
					Squads[ActiveSquad].MCount[i] = SquadMonsters[i].MonsterCount.GetValue();
					Break;
				}
			}
		}
	}
}

// Called when the active wave has been changed - updates all components with the correct values
function UpdateSquadValues()
{
	local int i;

	for( i=0; i<SquadMonsters.Length; i++ )
		SquadMonsters[i].MonsterCount.SetComponentValue( Squads[ActiveSquad].MCount[i], True );
}

event Closed( GUIComponent Sender, bool bCancelled )
{
	local array<string> AS;
	local int i,j,l,f;

	if( bCancelled )
		Return;
	AS.Length = 31;
	l = SquadMonsters.Length;
	for( i=0; i<31; i++ )
	{
		for( j=0; j<l; j++ )
		{
			if( Squads[i].MCount[j]<=0 )
				continue;
			f = i;
			AS[i]$=Squads[i].MCount[j]$SquadMonsters[j].MID;
		}
	}
	// Clean up.
	for( i=0; i<AS.Length; i++ )
	{
		if( Len(AS[i])==0 )
		{
			AS.Remove(i,1);
			i--;
		}
	}
	Class'KFGameType'.Default.MonsterSquad = AS;
	Class'KFGameType'.Static.StaticSaveConfig();
}

defaultproperties
{
     Begin Object Class=moNumericEdit Name=WaveNumber
         MinValue=0
         MaxValue=30
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         ComponentWidth=0.300000
         Caption="Squad No."
         OnCreateComponent=WaveNumber.InternalOnCreateComponent
         Hint="Select the squad you'd like to configure"
         WinTop=0.092990
         WinLeft=0.407353
         WinWidth=0.220000
         WinHeight=0.042857
         RenderWeight=0.700000
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFInvSquadConfig.InternalOnChange
     End Object
     nu_Wave=moNumericEdit'KFGui.KFInvSquadConfig.WaveNumber'

     Begin Object Class=GUIMultiOptionListBox Name=WavesList
         NumColumns=2
         bVisibleWhenEmpty=True
         OnCreateComponent=WavesList.InternalOnCreateComponent
         WinTop=0.150608
         WinLeft=0.007500
         WinWidth=0.983750
         WinHeight=0.698149
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFInvSquadConfig.InternalOnChange
     End Object
     lb_Waves=GUIMultiOptionListBox'KFGui.KFInvSquadConfig.WavesList'

     SquadConfigTitle="Killing Floor Squad config page"
     DefaultLeft=0.050000
     DefaultWidth=0.900000
     bDrawFocusedLast=False
     WinLeft=0.050000
     WinWidth=0.900000
}
