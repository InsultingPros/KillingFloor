class KFWaveConfigMenu extends GUICustomPropertyPage;

var string PropName;
var string PropValue;

var array<string> Waves;

var automated GUIImage              i_Background;
var automated moNumericEdit         nu_Wave;
var automated GUIMultiOptionListBox lb_Waves;
var GUIMultiOptionList              li_waves;


// 3D Monsters

var float nFov;
var() editinline editconst noexport SpinnyWeap	InfoWeapon; // MUST be set to null when you leave the window
var vector offset;


var localized string WaveText, DiffHint, DurationHint, MaxInvaderHint,AIHint;

// Local copy of wave info
struct WaveInfo
{
    var int     WaveMask;
    var byte    WaveMaxMonsters;
    var byte    WaveDuration;
    var float   WaveDifficulty;
};

struct WaveMonster
{
    var localized string MName;
    var int Mask;
};

var int ActiveWave; // Wave currently being edited
var WaveInfo WaveCopy[20];
var string MonsterSquad[20];

var moSlider sl_Diff;
var moNumericEdit nu_Duration;
var moNumericEdit nu_MaxMonster;

function string GetResult()
{
    return PropValue;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
    local class<GameInfo> InvClass;

    Super.InitComponent(MyController, MyOwner);

    InvClass = class<GameInfo>(DynamicLoadObject("KFMod.KFGameType", class'Class'));

    li_Waves = lb_Waves.List;
    li_Waves.OnChange = InternalOnChange;
    li_Waves.bDrawSelectionBorder = False;
    li_Waves.ItemPadding=0.15;
    li_Waves.ColumnWidth=0.95;
    li_Waves.bHotTrackSound = False;

    sl_Diff       = moSlider(li_Waves.AddItem(           "XInterface.moSlider", None, InvClass.static.GetDisplayText("WaveDifficulty"),  true ));
    nu_Duration   = moNumericEdit(li_Waves.AddItem( "XInterface.moNumericEdit", None, InvClass.static.GetDisplayText("WaveDuration"),    true ));
    nu_MaxMonster = moNumericEdit(li_Waves.AddItem( "XInterface.moNumericEdit", None, InvClass.static.GetDisplayText("WaveMaxMonsters"), true ));

    sl_Diff.Hint = DiffHint;
    nu_Duration.Hint=DurationHint;
    nu_MaxMonster.Hint=MaxInvaderHint;


    for ( i = 0; i < li_Waves.NumColumns; i++ )
        li_Waves.AddItem( "XInterface.GUIListSpacer" );

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
    InitDuration();
    InitMaxMonsters();
}

function InitDifficulty()
{
    sl_Diff.Setup( 0.0, 7.0 );
    sl_Diff.CaptionWidth = 0.1;
    sl_Diff.ComponentWidth = -1;
    sl_Diff.bAutoSizeCaption = true;
    sl_Diff.ComponentJustification = TXTA_Left;
}

function InitDuration()
{
    nu_Duration.Setup( 1, 255, 1 );
    nu_Duration.CaptionWidth = 0.1;
    nu_Duration.ComponentWidth = 0.3;
    nu_Duration.bAutoSizeCaption = true;
    nu_Duration.ComponentJustification = TXTA_Center;
}

function InitMaxMonsters()
{
    nu_MaxMonster.Setup( 1, 24, 1 );
    nu_MaxMonster.CaptionWidth = 0.1;
    nu_MaxMonster.ComponentWidth = 0.3;
    nu_MaxMonster.bAutoSizeCaption = true;
    nu_MaxMonster.ComponentJustification = TXTA_Center;
}

function SetOwner( GUIComponent NewOwner )
{
    Super.SetOwner(NewOwner);

    PropName = Item.DisplayName;
    PropValue = Mid(Item.Value,2,Len(Item.Value) - 4);
    t_WindowTitle.Caption = PropName;

    DisassembleWaveString();
    InitializeList();
}

function AssembleWaveString()
{
    local int i;

    PropValue = "((";
    for ( i = 0; i < ArrayCount(WaveCopy); i++ )
    {
        if ( i > 0 )
            PropValue $= "),(";

        PropValue $= "WaveMask="         $ WaveCopy[i].WaveMask;
        PropValue $= ",WaveMaxMonsters=" $ WaveCopy[i].WaveMaxMonsters;
        PropValue $= ",WaveDuration="    $ WaveCopy[i].WaveDuration;
        PropValue $= ",WaveDifficulty="  $ WaveCopy[i].WaveDifficulty;
    }
    PropValue $= "))";
}

function DisassembleWaveString()
{
    local int i;

    // Remove extra () and ""
    Split(PropValue, "),(", Waves);

    for ( i = 0; i < Waves.Length && i < ArrayCount(WaveCopy); i++ )
    {
        WaveCopy[i].WaveMask =          int(ParseOption(Waves[i], ",", "WaveMask"));
        WaveCopy[i].WaveMaxMonsters =  byte(ParseOption(Waves[i], ",", "WaveMaxMonsters"));
        WaveCopy[i].WaveDuration =     byte(ParseOption(Waves[i], ",", "WaveDuration"));
        WaveCopy[i].WaveDifficulty =  float(ParseOption(Waves[i], ",", "WaveDifficulty"));
    }
}

function InitializeList()
{
    local int i;
    local moNumericEdit ch;
    local string DummyString;

    for ( i = 0; i < ArrayCount(WaveCopy); i++ )
    {
        //ch = moNumericEdit(li_Waves.AddItem( "XInterface.moNumericEdit",, MonsterSquad[i]));
        ch = moNumericEdit(li_Waves.AddItem( "XInterface.moNumericEdit",, DummyString));

        if ( ch != None )
        {
           // ch.SetText(MonsterSquad[i]);
            ch.bAutoSizeCaption = True;
        }
    }

    UpdateWaveValues();
}

function string GetDataString()
{
    return PropValue;
}

event Closed( GUIComponent Sender, bool bCancelled )
{
    if ( !bCancelled )
        AssembleWaveString();
    else PropValue = "((" $ PropValue $ "))";

    // 3D
    InfoWeapon.bHidden = true;

    Super.Closed(Sender, bCancelled);
}

event Opened(GUIComponent Sender)
{
      Super.Opened(Sender);

    // 3D
    InfoWeapon.bHidden = false;

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
            WaveCopy[ActiveWave].WaveDifficulty = sl_Diff.GetValue();

        else if ( mo == nu_Duration )
            WaveCopy[ActiveWave].WaveDuration = nu_Duration.GetValue();

        else if ( mo == nu_MaxMonster )
            WaveCopy[ActiveWave].WaveMaxMonsters = nu_MaxMonster.GetValue();

        if ( moCheckBox(mo) != None )
        {
            if ( moCheckbox(mo).IsChecked() )
                WaveCopy[ActiveWave].WaveMask = WaveCopy[ActiveWave].WaveMask | mo.Tag;
            else WaveCopy[ActiveWave].WaveMask = WaveCopy[ActiveWave].WaveMask & ~mo.Tag;
        }
    }
}

// Called when the active wave has been changed - updates all components with the correct values
function UpdateWaveValues()
{
    local moNumericEdit ch;
    local int i;

    sl_Diff.SetComponentValue( WaveCopy[ActiveWave].WaveDifficulty, true );
    nu_Duration.SetComponentValue( WaveCopy[ActiveWave].WaveDuration, True );
    nu_MaxMonster.SetComponentValue( WaveCopy[ActiveWave].WaveMaxMonsters, True );

    for ( i = 3; i < li_Waves.Elements.Length; i++ )
    {
        ch = moNumericEdit(li_Waves.Elements[i]);

        if ( ch == None )
            continue;

        ch.SetComponentValue( MonsterSquad[i], True );
    }
}


function PostRenderWaveConfigMenu(Canvas Canvas)
{
	local float oOrgX,oOrgY;
	local float oClipX,oClipY;
	local vector CamPos,X,Y,Z;
	local rotator CamRot;
	local rotator DummyRot;

  	oOrgX = Canvas.OrgX;
	oOrgY = Canvas.OrgY;
	oClipX = Canvas.ClipX;
	oClipY = Canvas.ClipY;

	Canvas.OrgX = ActualLeft();
	Canvas.OrgY = ActualTop();
	Canvas.ClipX = ActualWidth();
	Canvas.ClipY = ActualHeight();

	canvas.GetCameraLocation(CamPos, CamRot);
	GetAxes(CamRot, X, Y, Z);



        if(InfoWeapon == None)
	    InfoWeapon = PlayerOwner().Spawn(class'XInterface.SpinnyWeap');

        InfoWeapon.SetLocation(CamPos + (X*offset.X)+(Y*offset.Y)+(Z*offset.Z));
        InfoWeapon.SetDrawType(DT_Mesh);
        InfoWeapon.SetDrawScale(0.1);
        InfoWeapon.SetRotation(DummyRot);
	//InfoWeapon.LinkMesh(Mesh 'KFCharacterModels.InfectedWhiteMale1');
	InfoWeapon.LoopAnim('Idle_LargeZombie');
   	canvas.DrawActorClipped(InfoWeapon, false,  ActualLeft(), ActualTop(), ActualWidth(), ActualHeight(), true, nFov);

	Canvas.OrgX = oOrgX;
	Canvas.OrgY = oOrgY;
   	Canvas.ClipX = oClipX;
	Canvas.ClipY = oClipY;
}

function HideSpinners()
{
  InfoWeapon.bHidden = true;
}

function ShowSpinners()
{
  InfoWeapon.bHidden = false;
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
         OnChange=KFWaveConfigMenu.InternalOnChange
     End Object
     nu_Wave=moNumericEdit'KFGui.KFWaveConfigMenu.WaveNumber'

     Begin Object Class=GUIMultiOptionListBox Name=WavesList
         NumColumns=3
         bVisibleWhenEmpty=True
         OnCreateComponent=WavesList.InternalOnCreateComponent
         WinTop=0.150608
         WinLeft=0.007500
         WinWidth=0.983750
         WinHeight=0.698149
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFWaveConfigMenu.InternalOnChange
     End Object
     lb_Waves=GUIMultiOptionListBox'KFGui.KFWaveConfigMenu.WavesList'

     nfov=65.000000
     offset=(X=50.000000,Y=-20.000000)
     DiffHint="How hard should this wave be."
     DurationHint="How long should this wave last."
     MaxInvaderHint="What is the maximum number of monsters to spawn for this wave."
     AIHint="Allow/Disallow this monster"
     MonsterSquad(0)="4A2G"
     MonsterSquad(1)="3A2D1G"
     MonsterSquad(2)="2A2D1C1G"
     MonsterSquad(3)="3A2C1G"
     MonsterSquad(4)="3B1C2D"
     MonsterSquad(5)="6B"
     MonsterSquad(6)="2A2D1G1E"
     MonsterSquad(7)="3D2E1H"
     DefaultLeft=0.050000
     DefaultWidth=0.900000
     bDrawFocusedLast=False
     WinLeft=0.050000
     WinWidth=0.900000
     OnRendered=KFWaveConfigMenu.PostRenderWaveConfigMenu
}
