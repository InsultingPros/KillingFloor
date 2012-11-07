//==============================================================================
//	KFInvWaveConfig
//==============================================================================
class KFInvWaveConfig extends GUICustomPropertyPage;

var array<string> Waves;

var automated GUIImage              i_Background;
var automated moNumericEdit         nu_Wave;
var automated GUIMultiOptionListBox lb_Waves;
var GUIMultiOptionList              li_waves;

var	localized string	WaveConfigTitle;
var	localized string	DiffHint, MaxInvaderHint;

struct WaveSquadType
{
	var string SName;
	var int Mask;
	var moCheckBox CheckButton;
};

var int ActiveWave;	// Wave currently being edited
var array<WaveSquadType> WaveSquad;
var Invasion.WaveInfo EditedWaves[16];

var moSlider sl_Diff;
var moNumericEdit nu_MaxMonster;

function string GetResult()
{
	return "";
}

function InitActiveSquads()
{
	local int i,l,m,j,z,n;
	local byte c;
	local array<string> AS;
	local string S;

	AS = Class'KFGameType'.Default.MonsterSquad;
	l = AS.Length;
	WaveSquad.Length = l;
	m = 1;
	z = Class'KFGameType'.Default.MonsterClasses.Length;
	For( i=0; i<l; i++ )
	{
		WaveSquad[i].Mask = m;
		m*=2;
		c = 0;
		while( Len(AS[i])>1 )
		{
			S = Mid(AS[i],1,1);
			n = int(Left(AS[i],1));
			AS[i] = Mid(AS[i],2);
			for( j=0; j<z; j++ )
			{
				if( Class'KFGameType'.Default.MonsterClasses[j].MID==S )
				{
					S = n$":"$GetMonsterName(Class'KFGameType'.Default.MonsterClasses[j].MClassName);
					if( Len(S)==0 )
						Break;
					if( c++==0 )
						WaveSquad[i].SName$=S;
					else WaveSquad[i].SName$=","$S;
				}
			}
			if( Len(WaveSquad[i].SName)>75 )
			{
				WaveSquad[i].SName$="...";
				Break;
			}
		}
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
	local int i;

	Super.InitComponent(MyController, MyOwner);

	li_Waves = lb_Waves.List;
	li_Waves.OnChange = InternalOnChange;
	li_Waves.bDrawSelectionBorder = False;
	li_Waves.ItemPadding=0.15;
	li_Waves.ColumnWidth=0.95;
	li_Waves.bHotTrackSound = False;

	sl_Diff       = moSlider(li_Waves.AddItem(           "XInterface.moSlider", None, "Difficulty",  true ));
	nu_MaxMonster = moNumericEdit(li_Waves.AddItem( "XInterface.moNumericEdit", None, "Number of monsters (X players count)", true ));

	sl_Diff.Hint = DiffHint;
	nu_MaxMonster.Hint=MaxInvaderHint;

	for ( i = 0; i < li_Waves.NumColumns; i++ )
		li_Waves.AddItem( "XInterface.GUIListSpacer" );
	for( i=0; i<ArrayCount(EditedWaves); i++ )
		EditedWaves[i] = Class'KFGameType'.Default.Waves[i];

	sb_Main.ManageComponent(lb_Waves);
	sb_Main.LeftPadding=0;
	sb_Main.RightPadding=0;
	sb_Main.TopPadding=0.05;
	sb_Main.BottomPadding=0.05;
	sb_Main.SetPosition(0.030234,0.075000,0.851640,0.565624);

	InitWaveControls();
}

function InitWaveControls()
{
	InitDifficulty();
	InitMaxMonsters();
}

function InitDifficulty()
{
	sl_Diff.Setup( 0.0, 3.0 );
	sl_Diff.CaptionWidth = 0.1;
	sl_Diff.ComponentWidth = -1;
	sl_Diff.bAutoSizeCaption = true;
	sl_Diff.ComponentJustification = TXTA_Left;
}

function InitMaxMonsters()
{
	nu_MaxMonster.Setup( 1, 500, 1 );
	nu_MaxMonster.CaptionWidth = 0.1;
	nu_MaxMonster.ComponentWidth = 0.3;
	nu_MaxMonster.bAutoSizeCaption = true;
	nu_MaxMonster.ComponentJustification = TXTA_Center;
}

function SetOwner( GUIComponent NewOwner )
{
	Super.SetOwner(NewOwner);

	t_WindowTitle.Caption = WaveConfigTitle;
	InitActiveSquads();
	InitializeList();
}

function InitializeList()
{
	local int i;
	local moCheckBox ch;

	for ( i = 0; i<WaveSquad.Length; i++ )
	{
		ch = moCheckbox(li_Waves.AddItem( "XInterface.moCheckbox",, WaveSquad[i].SName ));
		if ( ch != None )
		{
			WaveSquad[i].CheckButton = ch;
			ch.Tag = WaveSquad[i].Mask;
			ch.bAutoSizeCaption = True;
		}
	}

	UpdateWaveValues();
}

function string GetDataString()
{
	return "";
}

function InternalOnChange(GUIComponent Sender)
{
	local GUIMenuOption mo;

	if ( Sender == nu_Wave )
	{
		ActiveWave = nu_Wave.GetValue();
		UpdateWaveValues();
	}
	else if ( Sender == li_Waves )
	{
		mo = li_Waves.Get();

		if ( mo == sl_Diff )
			EditedWaves[ActiveWave].WaveDifficulty = sl_Diff.GetValue();
		else if ( mo == nu_MaxMonster )
			EditedWaves[ActiveWave].WaveMaxMonsters = nu_MaxMonster.GetValue();

		if ( moCheckBox(mo) != None )
		{
			if ( moCheckbox(mo).IsChecked() )
				EditedWaves[ActiveWave].WaveMask = EditedWaves[ActiveWave].WaveMask | mo.Tag;
			else EditedWaves[ActiveWave].WaveMask = EditedWaves[ActiveWave].WaveMask & ~mo.Tag;
		}
	}
}

// Called when the active wave has been changed - updates all components with the correct values
function UpdateWaveValues()
{
	local int i;

	sl_Diff.SetComponentValue( EditedWaves[ActiveWave].WaveDifficulty, true );
	nu_MaxMonster.SetComponentValue( EditedWaves[ActiveWave].WaveMaxMonsters, True );

	for ( i=0; i<WaveSquad.Length; i++ )
		WaveSquad[i].CheckButton.SetComponentValue( EditedWaves[ActiveWave].WaveMask & WaveSquad[i].CheckButton.Tag, True );
}

event Closed( GUIComponent Sender, bool bCancelled )
{
	local byte i;

	if( bCancelled )
		Return;
	for( i=0; i<ArrayCount(EditedWaves); i++ )
		Class'KFGameType'.Default.Waves[i] = EditedWaves[i];
	Class'KFGameType'.Static.StaticSaveConfig();
}

defaultproperties
{
     Begin Object Class=moNumericEdit Name=WaveNumber
         MinValue=0
         MaxValue=15
         ComponentJustification=TXTA_Center
         CaptionWidth=0.100000
         ComponentWidth=0.300000
         Caption="Wave No."
         OnCreateComponent=WaveNumber.InternalOnCreateComponent
         Hint="Select the wave you'd like to configure"
         WinTop=0.092990
         WinLeft=0.407353
         WinWidth=0.220000
         WinHeight=0.042857
         RenderWeight=0.700000
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFInvWaveConfig.InternalOnChange
     End Object
     nu_Wave=moNumericEdit'KFGui.KFInvWaveConfig.WaveNumber'

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
         OnChange=KFInvWaveConfig.InternalOnChange
     End Object
     lb_Waves=GUIMultiOptionListBox'KFGui.KFInvWaveConfig.WavesList'

     WaveConfigTitle="Killing Floor Wave config page"
     DiffHint="How hard should this wave be."
     MaxInvaderHint="What is the maximum number of monsters to spawn for this wave."
     DefaultLeft=0.050000
     DefaultWidth=0.900000
     bDrawFocusedLast=False
     WinLeft=0.050000
     WinWidth=0.900000
}
