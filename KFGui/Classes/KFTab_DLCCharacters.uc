class KFTab_DLCCharacters extends KFTab_DLCAll;

function ShowPanel(bool bShow)
{
	super.ShowPanel(bShow);
}

defaultproperties
{
     Begin Object Class=KFDLCListBox Name=DLCList
         bShowCharacters=True
         OnCreateComponent=DLCList.InternalOnCreateComponent
         WinTop=0.090000
         WinLeft=0.072959
         WinWidth=0.851529
         WinHeight=0.867808
     End Object
     lb_DLC=KFDLCListBox'KFGui.KFTab_DLCCharacters.DLCList'

}
