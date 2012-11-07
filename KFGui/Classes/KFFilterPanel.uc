//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFFilterPanel extends GUIPanel;

var automated 	AltSectionBackground sb_Options;
var automated 	moEditBox eb_Name;
var automated 	moCheckBox ck_Full, ck_Dedicated, ck_Empty, ck_Passworded, ck_VACOnly, ck_Perks;
var automated	moCheckBox ck_Hidden, ck_Hidden2;
var automated 	moComboBox cb_Difficulty;

var automated 	GUIButton b_Ok, b_Cancel;

var int 			FilterIndex;
var	BrowserFilters 	FilterMaster;

//var UT2K4_FilterListPage FLP;

var bool bInitialized;

var localized string DifficultyOptions[6];

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);

	//FLP = UT2K4_FilterListPage(ParentPage);
	//FilterMaster = KFServerBrowser(Controller.TopPage()).FilterMaster;

	sb_Options.ManageComponent(ck_Dedicated);
	sb_Options.ManageComponent(ck_Perks);
	sb_Options.ManageComponent(cb_Difficulty);
	sb_Options.ManageComponent(ck_Full);
	sb_Options.ManageComponent(ck_Empty);
	sb_Options.ManageComponent(ck_Passworded);
	sb_Options.ManageComponent(ck_VACOnly);
	sb_Options.ManageComponent(ck_Hidden);
	sb_Options.ManageComponent(ck_Hidden2);

	cb_Difficulty.AddItem(DifficultyOptions[0]);
	cb_Difficulty.AddItem(DifficultyOptions[1]);
	cb_Difficulty.AddItem(DifficultyOptions[2]);
	cb_Difficulty.AddItem(DifficultyOptions[3]);
	cb_Difficulty.AddItem(DifficultyOptions[4]);
	cb_Difficulty.AddItem(DifficultyOptions[5]);

	StartUp();
}

function StartUp()
{
	local int i;
	local array<CustomFilter.AFilterRule> Rules;
	local MasterServerClient.QueryData 	FilterItem;
	local string IdontCareString;

	FilterIndex = 0;

	/*eb_Name.SetComponentValue(Param2);

	if (Param2~="Default")
		eb_Name.DisableMe();
	else
		eb_Name.EnableMe();
	*/
	//Get the custom filter

	IdontCareString = "blah";
	KFServerBrowser(OwnerPage()).FilterMaster.InitCustomFilters();

	if ( KFServerBrowser(OwnerPage()).FilterMaster.AllFilters.Length < 1 )
	{
		KFServerBrowser(OwnerPage()).FilterMaster.AddCustomFilter(IdontCareString);
	}

   	Rules =	KFServerBrowser(OwnerPage()).FilterMaster.GetFilterRules(FilterIndex);

	for ( i = 0; i < Rules.Length; i++)
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
	//Controller.CloseMenu(true);
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

function InternalOnChange(GUIComponent Sender)
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

	KFServerBrowser(OwnerPage()).FilterMaster.PostEdit(FilterIndex,"blah",Rules);
	KFServerBrowser(OwnerPage()).FilterMaster.ActivateFilter(FilterIndex, true);
	KFServerBrowser(OwnerPage()).FilterMaster.RenameFilter(FilterIndex, "blah");
	KFServerBrowser(OwnerPage()).FilterMaster.SaveFilters();
	KFServerBrowser(OwnerPage()).RefreshClicked();
}

function bool ebPreDraw(canvas Canvas)
{
	// Reposition
//	eb_Name.WinTop = sb_Options.ActualTop() + 36;
	return true;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbOptions
         bFillClient=True
         LeftPadding=0.000000
         RightPadding=0.000000
         TopPadding=0.070000
         BottomPadding=0.070000
         ImageOffset(1)=0.000000
         ImageOffset(3)=0.000000
         NumColumns=3
         WinHeight=1.000000
         OnPreDraw=sbOptions.InternalPreDraw
     End Object
     sb_Options=AltSectionBackground'KFGui.KFFilterPanel.sbOptions'

     Begin Object Class=moCheckBox Name=ckFull
         CaptionWidth=0.400000
         ComponentWidth=0.100000
         Caption="No Full Servers"
         OnCreateComponent=ckFull.InternalOnCreateComponent
         WinTop=0.100000
         WinLeft=0.000000
         WinWidth=0.450000
         TabOrder=1
         StandardHeight=0.025000
         OnChange=KFFilterPanel.InternalOnChange
     End Object
     ck_Full=moCheckBox'KFGui.KFFilterPanel.ckFull'

     Begin Object Class=moCheckBox Name=ckDedicated
         ComponentWidth=0.100000
         Caption="Dedicated Only"
         OnCreateComponent=ckDedicated.InternalOnCreateComponent
         WinTop=0.200000
         WinLeft=0.000000
         WinWidth=0.450000
         TabOrder=2
         StandardHeight=0.025000
         OnChange=KFFilterPanel.InternalOnChange
     End Object
     ck_Dedicated=moCheckBox'KFGui.KFFilterPanel.ckDedicated'

     Begin Object Class=moCheckBox Name=ckEmpty
         ComponentWidth=0.100000
         Caption="No Empty Servers"
         OnCreateComponent=ckEmpty.InternalOnCreateComponent
         WinTop=0.200000
         WinLeft=0.000000
         WinWidth=0.450000
         TabOrder=4
         StandardHeight=0.025000
         OnChange=KFFilterPanel.InternalOnChange
     End Object
     ck_Empty=moCheckBox'KFGui.KFFilterPanel.ckEmpty'

     Begin Object Class=moCheckBox Name=ckPassworded
         ComponentWidth=0.100000
         Caption="No Passworded Servers"
         OnCreateComponent=ckPassworded.InternalOnCreateComponent
         WinTop=0.300000
         WinLeft=0.000000
         WinWidth=0.450000
         TabOrder=5
         StandardHeight=0.025000
         OnChange=KFFilterPanel.InternalOnChange
     End Object
     ck_Passworded=moCheckBox'KFGui.KFFilterPanel.ckPassworded'

     Begin Object Class=moCheckBox Name=ckVACOnly
         ComponentWidth=0.100000
         Caption="Valve Anti-Cheat Protected Only"
         OnCreateComponent=ckVACOnly.InternalOnCreateComponent
         WinTop=0.400000
         WinLeft=0.000000
         WinWidth=0.450000
         TabOrder=6
         StandardHeight=0.025000
         OnChange=KFFilterPanel.InternalOnChange
     End Object
     ck_VACOnly=moCheckBox'KFGui.KFFilterPanel.ckVACOnly'

     Begin Object Class=moCheckBox Name=ckPerks
         ComponentWidth=0.100000
         Caption="Perks Enabled"
         OnCreateComponent=ckPerks.InternalOnCreateComponent
         WinTop=0.500000
         WinLeft=0.000000
         WinWidth=0.450000
         TabOrder=7
         StandardHeight=0.025000
         OnChange=KFFilterPanel.InternalOnChange
     End Object
     ck_Perks=moCheckBox'KFGui.KFFilterPanel.ckPerks'

     Begin Object Class=moCheckBox Name=ckHidden
         ComponentWidth=0.100000
         Caption="Hidden"
         OnCreateComponent=ckHidden.InternalOnCreateComponent
         TabOrder=8
         bVisible=False
     End Object
     ck_Hidden=moCheckBox'KFGui.KFFilterPanel.ckHidden'

     Begin Object Class=moCheckBox Name=ckHidden2
         ComponentWidth=0.100000
         Caption="Hidden"
         OnCreateComponent=ckHidden2.InternalOnCreateComponent
         WinTop=0.000000
         WinLeft=0.550000
         WinWidth=0.450000
         TabOrder=9
         bVisible=False
     End Object
     ck_Hidden2=moCheckBox'KFGui.KFFilterPanel.ckHidden2'

     Begin Object Class=moComboBox Name=cbDifficulty
         bReadOnly=True
         ComponentWidth=0.550000
         Caption="Difficulty:"
         OnCreateComponent=cbDifficulty.InternalOnCreateComponent
         TabOrder=3
         StandardHeight=0.025000
         OnChange=KFFilterPanel.InternalOnChange
     End Object
     cb_Difficulty=moComboBox'KFGui.KFFilterPanel.cbDifficulty'

     DifficultyOptions(0)="Any Difficulty"
     DifficultyOptions(1)="Beginner"
     DifficultyOptions(2)="Normal"
     DifficultyOptions(3)="Hard"
     DifficultyOptions(4)="Suicidal"
     DifficultyOptions(5)="Hell on Earth"
     PropagateVisibility=False
}
