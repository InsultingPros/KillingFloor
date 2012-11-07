class KFUT2K4_FilterListPage extends UT2K4_FilterListPage;

var	localized string	NewFilterString;

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
		FN = NewFilterString;
	else
		FN = NewFilterString @ cnt;

	FM.AddCustomFilter(FN);
	InitFilterList();
    i= FM.FindFilterIndex(FN);
    Controller.OpenMenu("KFGUI.KFUT2K4_FilterEdit",""$i,FN);

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
    Controller.OpenMenu("KFGUI.KFUT2K4_FilterEdit",""$i,FN);

    return true;
}

defaultproperties
{
     NewFilterString="New Filter"
}
