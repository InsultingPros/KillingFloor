class KFServerListPageFriends extends KFServerListPageInternet;

function Refresh()
{
	local int i, j;
	local string TmpString;
	local array<CustomFilter.AFilterRule> Rules;
	local MasterServerClient.QueryData QueryItem;

	if ( bQueryRunning )
	{
		SetTimer(0.0);
		Uplink().Stop();
	}
	else
	{
		bQueryRunning = true;
	}

	ResetQueryClient(Uplink());

    if ( li_Server == none )
    {
        InitServerList();
    }
    else
    {
		li_Server.StopPings();
		li_Server.InvalidatePings();
    }

    li_Server.Clear();

	AddQueryTerm("friends", "friends", QT_Equals);

	// Add any extra filtering to the query
	for ( i = 0; i < FilterMaster.AllFilters.Length; i++ )
	{
		if ( FilterMaster.IsActiveAt(i) )
		{
			Rules = FilterMaster.GetFilterRules(i);
			for ( j = 0; j < Rules.Length; j++ )
			{
				QueryItem = Rules[j].FilterItem;
				if ( ValidateQueryItem(Rules[j].FilterType, QueryItem) )
				{
					TmpString = QueryItem.Value;
					if ( QueryItem.QueryType < 2 )
					{
						class'CustomFilter'.static.ChopClass(TmpString);
					}

					AddQueryTerm(QueryItem.Key, TmpString, QueryItem.QueryType);
				}
			}
		}
	}

	// Run query
	Uplink().StartQuery(CTM_Query);
	SetFooterCaption(StartQueryString);
}

defaultproperties
{
     PanelCaption="Server Browser : Friends"
}
