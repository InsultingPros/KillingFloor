//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4_FilterListPage extends UT2K4_FilterListPage;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
    //local string           myStyleName;

	Super.InitComponent(MyC, MyO);

    class'ROInterfaceUtil'.static.SetROStyle(MyC, Controls);

    /*myStyleName = "ROTitleBar";

    //StyleName = myStyleName;
    //Style = MyC.GetStyle(myStyleName,t_WindowTitle.FontScale);

    i_FrameBG.StyleName = myStyleName;
    i_FrameBG.Style = MyC.GetStyle(myStyleName,t_WindowTitle.FontScale);

    t_WindowTitle.StyleName = myStyleName;
    t_WindowTitle.Style = MyC.GetStyle(myStyleName,t_WindowTitle.FontScale);

    sb_Background.StyleName = myStyleName;
    sb_Background.Style = MyC.GetStyle(myStyleName,t_WindowTitle.FontScale);*/
}

function bool CreateClick(GUIComponent Sender)
{
	local string FN;
	local int i,cnt;
	local moCheckbox cb;

	cnt = 0;
	for (i=0;i<li_Filters.ItemCount;i++)
	{
		cb = moCheckbox( li_Filters.GetItem(i) );
		if (inStr(cb.Caption,"New Filter")>=0)
			cnt++;
	}

	if (cnt==0)
		FN ="New Filter";
	else
		FN = "New Filter"@cnt;

	FM.AddCustomFilter(FN);
	InitFilterList();
    i= FM.FindFilterIndex(FN);
    Controller.OpenMenu("ROInterface.ROUT2K4_FilterEdit",""$i,FN);

    return true;
}

function bool EditClick(GUIComponent Sender)
{
	local string FN;
	local int i;
	local moCheckbox cb;

	cb = moCheckbox( li_Filters.Get() );
	FN = cb.Caption;
    i= FM.FindFilterIndex(FN);
    Controller.OpenMenu("ROInterface.ROUT2K4_FilterEdit",""$i,FN);

    return true;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbBackground
         bFillClient=True
         bNoCaption=True
         Caption="Filters..."
         LeftPadding=0.002500
         RightPadding=0.002500
         TopPadding=0.002500
         BottomPadding=0.002500
         WinTop=0.103281
         WinLeft=0.262656
         WinWidth=0.343359
         WinHeight=0.766448
         OnPreDraw=sbBackground.InternalPreDraw
     End Object
     sb_Background=AltSectionBackground'ROInterface.ROUT2K4_FilterListPage.sbBackground'

     Begin Object Class=GUIButton Name=bCreate
         Caption="Create"
         WinTop=0.105000
         WinLeft=0.610001
         WinWidth=0.168750
         WinHeight=0.050000
         OnClick=ROUT2K4_FilterListPage.CreateClick
         OnKeyEvent=bCreate.InternalOnKeyEvent
     End Object
     b_Create=GUIButton'ROInterface.ROUT2K4_FilterListPage.bCreate'

     Begin Object Class=GUIButton Name=bRemove
         Caption="Remove"
         WinTop=0.158333
         WinLeft=0.610001
         WinWidth=0.168750
         WinHeight=0.050000
         OnClick=ROUT2K4_FilterListPage.RemoveClick
         OnKeyEvent=bRemove.InternalOnKeyEvent
     End Object
     b_Remove=GUIButton'ROInterface.ROUT2K4_FilterListPage.bRemove'

     Begin Object Class=GUIButton Name=bEdit
         Caption="Edit"
         WinTop=0.266666
         WinLeft=0.610001
         WinWidth=0.168750
         WinHeight=0.050000
         OnClick=ROUT2K4_FilterListPage.EditClick
         OnKeyEvent=bEdit.InternalOnKeyEvent
     End Object
     b_Edit=GUIButton'ROInterface.ROUT2K4_FilterListPage.bEdit'

     Begin Object Class=GUIButton Name=bOk
         Caption="OK"
         WinTop=0.770000
         WinLeft=0.610001
         WinWidth=0.168750
         WinHeight=0.050000
         OnClick=ROUT2K4_FilterListPage.OkClick
         OnKeyEvent=bOk.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'ROInterface.ROUT2K4_FilterListPage.bOk'

     Begin Object Class=GUIButton Name=bCancel
         Caption="Cancel"
         WinTop=0.820000
         WinLeft=0.610001
         WinWidth=0.168750
         WinHeight=0.050000
         OnClick=ROUT2K4_FilterListPage.CancelClick
         OnKeyEvent=bCancel.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'ROInterface.ROUT2K4_FilterListPage.bCancel'

     Begin Object Class=GUIMultiOptionListBox Name=lbFilters
         OnCreateComponent=lbFilters.InternalOnCreateComponent
         WinTop=0.103281
         WinLeft=0.262656
         WinWidth=0.343359
         WinHeight=0.766448
     End Object
     lb_Filters=GUIMultiOptionListBox'ROInterface.ROUT2K4_FilterListPage.lbFilters'

}
