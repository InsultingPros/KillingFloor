class KFTab_GametypeMP extends UT2K4Tab_GameTypeMP;

function InternalOnChange(GUIComponent Sender)
{
    local int Index;

    Index = FindRecordIndex(li_Games.Get());
    if ( Index < 0 || Index >= GameTypes.Length )
    	return;

    if ( Controller.LastGameType == "" || GameTypes[Index].ClassName != Controller.LastGameType )
    {
    	InitPreview();
    	Controller.LastGameType = GameTypes[Index].ClassName;
    }
	
    if (Sender == lb_Games)
    {
		if ( li_Games.IsSection() )
			return;

		OnChangeGameType(true);
	}
}

defaultproperties
{
     Begin Object Class=GUIListBox Name=UT2004Games
         SelectedStyleName="ListSelection"
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=UT2004Games.InternalOnCreateComponent
         FontScale=FNS_Medium
         WinTop=0.144225
         WinLeft=0.045599
         WinWidth=0.438457
         WinHeight=0.796982
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=KFTab_GameTypeMP.InternalOnChange
     End Object
     lb_Games=GUIListBox'KFGui.KFTab_GameTypeMP.UT2004Games'

     EpicGameCaption=
     CustomGameCaption=
}
