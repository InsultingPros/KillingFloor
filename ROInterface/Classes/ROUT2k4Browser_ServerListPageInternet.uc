//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4Browser_ServerListPageInternet extends UT2k4Browser_ServerListPageInternet;

var	bool	bQueryRunning;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Server);
    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Rules);
    class'ROInterfaceUtil'.static.ReformatLists(MyController, lb_Players);
}

function BindQueryClient( ServerQueryClient Client )
{
	super.BindQueryClient(Client);
	if ( MasterServerClient(Client) != None )
	{
		MasterServerClient(Client).OnReceivedServer = MyOnReceivedServer;
	}
}

// We have list of servers from master server and are going to start pinging
function QueryComplete( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	super.QueryComplete(ResponseInfo, Info);
	li_Server.SortList();
}

function MyOnReceivedServer(GameInfo.ServerResponseLine s)
{
	SetTimer(1.0);
	li_Server.MyOnReceivedServer(s);
	li_Server.AddedItem();
	li_Server.SortList();
}

event Timer()
{
	if ( bQueryRunning )
	{
		bQueryRunning = false;
		Browser.Uplink().Stop();
		QueryComplete(RI_Success, 0);
	}
	else
	{
		super.Timer();
	}
}

function Refresh()
{
	if ( bQueryRunning )
	{
		SetTimer(0.0);
		Browser.Uplink().Stop();
	}
	else
	{
		bQueryRunning = true;
	}

	super.Refresh();
}

// Commented out for now until we can complete the functionality
/*
function Refresh()
{
	local int i, j;
	local string TmpString;
	local array<CustomFilter.AFilterRule> Rules;

	local MasterServerClient.QueryData QueryItem;

	GameTypeChanged(UT2K4Browser_ServersList(Browser.co_GameType.GetObject()));
	super(UT2K4Browser_ServerListPageMS).Refresh();

	if (PlayCount==ShowAt)
	{
	    Controller.OpenMenu("gui2k4.UT2K4TryAMod",""$PlayCount);
		PlayCount=ShowAt+1;
	}
	SaveConfig();

    log("Current game type = "$GetItemName(Browser.CurrentGameType));

    if( GetItemName(Browser.CurrentGameType) ~= "Any" )
    {
       AddQueryTerm("gametype", "blah", QT_NotEquals);//log("We should be searching for any servers");
    }
    else
	   AddQueryTerm("gametype", GetItemName(Browser.CurrentGameType), QT_Equals);

	if ( Browser.bStandardServersOnly )
		AddQueryTerm( "standard", "true", QT_Equals );

	// Add any extra filtering to the query
	for (i = 0; i < FilterMaster.AllFilters.Length; i++)
	{
		if ( FilterMaster.IsActiveAt(i) )
		{
			Rules = FilterMaster.GetFilterRules( i );
			for (j = 0; j < Rules.Length; j++)
			{
				QueryItem = Rules[j].FilterItem;
				if (ValidateQueryItem(Rules[j].FilterType, QueryItem ))
				{
					TmpString = QueryItem.Value;
					if (QueryItem.QueryType < 2)
						class'CustomFilter'.static.ChopClass(TmpString);

					AddQueryTerm( QueryItem.Key, TmpString, QueryItem.QueryType );
				}
			}
		}
	}

	// Run query
	Browser.Uplink().StartQuery(CTM_Query);
	SetFooterCaption(StartQueryString);
}*/

defaultproperties
{
}
