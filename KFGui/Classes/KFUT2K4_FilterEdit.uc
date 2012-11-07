class KFUT2K4_FilterEdit extends LargeWindow;

var automated GUISectionBackground sb_Options;
var automated moEditBox eb_Name;
var automated moCheckBox ck_Full, ck_Dedicated, ck_Empty, ck_Passworded, ck_VACOnly, ck_Hidden, ck_Perks;
var automated moComboBox cb_Difficulty;

var automated GUIButton b_Ok, b_Cancel;

var int 			FilterIndex;
var	BrowserFilters 	FM;

var UT2K4_FilterListPage FLP;

var bool bInitialized;

var localized string DifficultyOptions[6];

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);

	FLP = UT2K4_FilterListPage(ParentPage);

	sb_Options.ManageComponent(ck_Dedicated);
	sb_Options.ManageComponent(ck_Perks);
	sb_Options.ManageComponent(ck_Full);
	sb_Options.ManageComponent(ck_Empty);
	sb_Options.ManageComponent(ck_Passworded);
	sb_Options.ManageComponent(ck_VACOnly);
	sb_Options.ManageComponent(ck_Hidden);
	sb_Options.ManageComponent(cb_Difficulty);

	cb_Difficulty.AddItem(DifficultyOptions[0]);
	cb_Difficulty.AddItem(DifficultyOptions[1]);
	cb_Difficulty.AddItem(DifficultyOptions[2]);
	cb_Difficulty.AddItem(DifficultyOptions[3]);
	cb_Difficulty.AddItem(DifficultyOptions[4]);
	cb_Difficulty.AddItem(DifficultyOptions[5]);
}

event HandleParameters(string Param1, string Param2)
{
	local int i;
	local array<CustomFilter.AFilterRule> Rules;
	local MasterServerClient.QueryData 	FilterItem;

	FilterIndex = int(Param1);
	eb_Name.SetComponentValue(Param2);

	if (Param2~="Default")
		eb_Name.DisableMe();
	else
		eb_Name.EnableMe();

	//Get the custom filter
 	Rules = FLP.FM.GetFilterRules(FilterIndex);

	for (i=0;i<Rules.Length;i++)
	{
		FilterItem = Rules[i].FilterItem;
		log(FilterItem.Key$"="$FilterItem.Value);
		if ( FilterItem.Key~="currentplayers" && FilterItem.Value=="0" && FilterItem.QueryType==QT_GreaterThan )
			ck_Empty.Checked(true);

		if ( FilterItem.Key~="password" && FilterItem.Value=="false" && FilterItem.QueryType==QT_Equals )
			ck_Passworded.Checked(true);

		if ( FilterItem.Key~="freespace" && FilterItem.Value =="0" && FilterItem.QueryType==QT_GreaterThan )
			ck_Full.Checked(true);

		if ( FilterItem.Key~="dedicated" && FilterItem.Value=="true" && FilterItem.QueryType==QT_Equals)
			ck_Dedicated.Checked(true);

		if ( FilterItem.Key~="vacsecure" && FilterItem.Value=="true" && FilterItem.QueryType==QT_Equals)
			ck_VACOnly.Checked(true);

		if ( FilterItem.Key~="perks" && FilterItem.Value=="true" && FilterItem.QueryType==QT_Equals)
			ck_Perks.Checked(true);

		if ( FilterItem.Key~="difficulty" )
			cb_Difficulty.MyComboBox.SetIndex(int(FilterItem.Value));
	}
}

function bool CancelClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}

function CustomFilter.AFilterRule BuildRule(string Key, string Value, MasterServerClient.EQueryType qType)
{
	local CustomFilter.AFilterRule NewRule;

	NewRule.FilterItem.Key   		= key;
	NewRule.FilterItem.Value 		= value;
	NewRule.FilterItem.QueryType	= qtype;
	NewRule.FilterType				= DT_Unique;
	NewRule.ItemName				= Key;

	return NewRule;
}


function bool OkClick(GUIComponent Server)
{
	local array<CustomFilter.AFilterRule> Rules;
	local int cnt;

	cnt = 0;

	// Build Query lists

	if ( ck_Empty.IsChecked() )
		Rules[Cnt++] = BuildRule("currentplayers","0",QT_GreaterThan);

	if ( ck_Full.IsChecked() )
		Rules[Cnt++] = BuildRule("freespace","0",QT_GreaterThan);

	if ( ck_Passworded.IsChecked() )
		Rules[Cnt++] = BuildRule("password","false",QT_Equals);

	if ( ck_Dedicated.IsChecked() )
		Rules[Cnt++] = BuildRule("dedicated","true", QT_Equals);

	if ( ck_VACOnly.IsChecked() )
		Rules[Cnt++] = BuildRule("vacsecure","true", QT_Equals);

	if ( ck_Perks.IsChecked() )
		Rules[Cnt++] = BuildRule("perks","true", QT_Equals);

	Rules[Cnt++] = BuildRule("difficulty", string(cb_Difficulty.GetIndex()), QT_Equals);

	FLP.FM.PostEdit(FilterIndex,eb_Name.GetComponentValue(),Rules);
	Controller.CloseMenu(true);
	FLP.InitFilterList();

	FLP.li_Filters.SetIndex(FLP.li_Filters.Find(eb_Name.GetComponentValue()));

	return true;
}

function bool ebPreDraw(canvas Canvas)
{
	// Reposition
	eb_Name.WinTop = sb_Options.ActualTop() + 36;
	return true;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=sbOptions
         bFillClient=True
         Caption="Options..."
         LeftPadding=0.002500
         RightPadding=0.002500
         TopPadding=0.200000
         BottomPadding=0.002500
         NumColumns=2
         WinTop=0.257448
         WinLeft=0.086094
         WinWidth=0.827735
         WinHeight=0.427735
         OnPreDraw=sbOptions.InternalPreDraw
     End Object
     sb_Options=GUISectionBackground'KFGui.KFUT2K4_FilterEdit.sbOptions'

     Begin Object Class=moEditBox Name=ebName
         ComponentWidth=0.700000
         Caption="Filter Name:"
         OnCreateComponent=ebName.InternalOnCreateComponent
         WinTop=0.124114
         WinLeft=0.184531
         WinWidth=0.654297
         TabOrder=0
         OnPreDraw=KFUT2K4_FilterEdit.ebPreDraw
     End Object
     eb_Name=moEditBox'KFGui.KFUT2K4_FilterEdit.ebName'

     Begin Object Class=moCheckBox Name=ckFull
         ComponentWidth=0.100000
         Caption="No Full Servers"
         OnCreateComponent=ckFull.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.250000
         TabOrder=1
     End Object
     ck_Full=moCheckBox'KFGui.KFUT2K4_FilterEdit.ckFull'

     Begin Object Class=moCheckBox Name=ckDedicated
         ComponentWidth=0.100000
         Caption="Dedicated Only"
         OnCreateComponent=ckDedicated.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.250000
         TabOrder=2
     End Object
     ck_Dedicated=moCheckBox'KFGui.KFUT2K4_FilterEdit.ckDedicated'

     Begin Object Class=moCheckBox Name=ckEmpty
         ComponentWidth=0.100000
         Caption="No Empty Servers"
         OnCreateComponent=ckEmpty.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.250000
         TabOrder=3
     End Object
     ck_Empty=moCheckBox'KFGui.KFUT2K4_FilterEdit.ckEmpty'

     Begin Object Class=moCheckBox Name=ckPassworded
         ComponentWidth=0.100000
         Caption="No Passworded Servers"
         OnCreateComponent=ckPassworded.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.250000
         TabOrder=4
     End Object
     ck_Passworded=moCheckBox'KFGui.KFUT2K4_FilterEdit.ckPassworded'

     Begin Object Class=moCheckBox Name=ckVACOnly
         ComponentWidth=0.100000
         Caption="Valve Anti-Cheat Protected Only"
         OnCreateComponent=ckVACOnly.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.250000
         TabOrder=5
     End Object
     ck_VACOnly=moCheckBox'KFGui.KFUT2K4_FilterEdit.ckVACOnly'

     Begin Object Class=moCheckBox Name=ckHidden
         ComponentWidth=0.100000
         Caption="Hidden"
         OnCreateComponent=ckHidden.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.250000
         TabOrder=7
         bVisible=False
     End Object
     ck_Hidden=moCheckBox'KFGui.KFUT2K4_FilterEdit.ckHidden'

     Begin Object Class=moCheckBox Name=ckPerks
         ComponentWidth=0.100000
         Caption="Perks Enabled"
         OnCreateComponent=ckPerks.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.250000
         TabOrder=6
     End Object
     ck_Perks=moCheckBox'KFGui.KFUT2K4_FilterEdit.ckPerks'

     Begin Object Class=moComboBox Name=cbDifficulty
         bReadOnly=True
         ComponentWidth=0.550000
         Caption="Difficulty:"
         OnCreateComponent=cbDifficulty.InternalOnCreateComponent
         WinTop=0.250000
         WinLeft=0.250000
         TabOrder=8
     End Object
     cb_Difficulty=moComboBox'KFGui.KFUT2K4_FilterEdit.cbDifficulty'

     Begin Object Class=GUIButton Name=bOk
         Caption="OK"
         WinTop=0.698612
         WinLeft=0.561564
         WinWidth=0.168750
         WinHeight=0.050000
         OnClick=KFUT2K4_FilterEdit.OkClick
         OnKeyEvent=bOk.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'KFGui.KFUT2K4_FilterEdit.bOk'

     Begin Object Class=GUIButton Name=bCancel
         Caption="Cancel"
         WinTop=0.698612
         WinLeft=0.742814
         WinWidth=0.168750
         WinHeight=0.050000
         OnClick=KFUT2K4_FilterEdit.CancelClick
         OnKeyEvent=bCancel.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'KFGui.KFUT2K4_FilterEdit.bCancel'

     DifficultyOptions(0)="Any Difficulty"
     DifficultyOptions(1)="Beginner"
     DifficultyOptions(2)="Normal"
     DifficultyOptions(3)="Hard"
     DifficultyOptions(4)="Suicidal"
     DifficultyOptions(5)="Hell on Earth"
     WindowName="Edit Filter Rules..."
     WinLeft=0.050000
     WinWidth=0.900000
     WinHeight=0.570000
}
