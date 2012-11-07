class KFServerListPageInternet extends UT2K4Browser_ServerListPageInternet;

var protected ROMasterServerClient  ROMSC;

var	bool						bQueryRunning;
var	string						CurrentGameType;
var	localized 	string			ServerCountString;
var automated 	KFFilterPanel	FilterPanel;

var array<GameInfo.ServerResponseLine> AllServers;

function ShowPanel(bool bShow)
{
	if ( bShow )
	{
        if ( bInit )
        {
            sp_Main.SplitterUpdatePositions();
            sp_Detail.SplitterUpdatePositions();
        }

		Browser.t_Header.SetCaption(PanelCaption);
		RefreshFooter(self, string(!bCommonButtonWidth));
    	SetFooterCaption(CurrentFooterCaption);

		Uplink().bInternetQueryRunning = true;
		bQueryRunning = true;
		Refresh();

		bInit = false;
	}
    else if ( !bInit )
    {
    	// Remove all outstanding pings so that they will be repinged when this panel is made active again
    	// Otherwise, we'll get stuck if the new active tab is using the same masterserveruplink
		li_Server.OutstandingPings.Remove(0, li_Server.OutstandingPings.Length);
	}

	SetVisibility(bShow);
}

function InitServerList()
{
	super(UT2k4Browser_ServerListPageBase).InitServerList();
	li_Server.bPresort = True;
}

function BindQueryClient(ServerQueryClient Client)
{
}

function ROMasterServerClient Uplink()
{
	if ( ROMSC == None && PlayerOwner() != None )
	{
		ROMSC = PlayerOwner().Spawn(class'ROMasterServerClient');
		ROMSC.OnReceivedServer		= MyOnReceivedServer;
		ROMSC.OnQueryFinished		= QueryComplete;
		ROMSC.OnReceivedPingInfo	= ReceivedPingInfo;
		ROMSC.OnPingTimeout			= ReceivedPingTimeout;
	}

	return ROMSC;
}

function NewGameType(GUIComponent Sender)
{
	local string SelectedGame;
	local UT2K4Browser_ServersList List;

	if (Sender != Browser.co_GameType)
		return;

	SelectedGame = moComboBox(Sender).GetExtra();
	if (Browser.CurrentGameType ~= SelectedGame)
		return;

	CurrentGameType = moComboBox(Sender).GetText();
	Browser.CurrentGameType = SelectedGame;
	Browser.SaveConfig();

	List = UT2K4Browser_ServersList(Browser.co_GameType.GetObject());

	GameTypeChanged(List);
	BindQueryClient(Browser.Uplink());
	li_Server.AutoPingServers();
}

function GameTypeChanged(UT2K4Browser_ServersList NewList)
{
	local int i;

	if (NewList != None)
	{
		if (li_Server != None)
		{
			li_Server.OnChange = None;
			li_Server.StopPings();
			li_Server.SetAnchor(None);
		}

		lb_Server.InitBaseList(NewList);
	}

	CurrentGameType = Browser.co_GameType.GetText();

	li_Server.Clear();

	// Display any found servers of the current game type
	for (i = 0; i < AllServers.Length; i++)
	{
		if (AllServers[i].GameType == CurrentGameType ||
			Browser.co_GameType.GetComponentValue() == KFServerBrowser(Browser).AllTypesClassName)
		{
			DisplayServers(AllServers[i]);
		}
	}

	InitServerList();
}

function AddQueryTerm(coerce string Key, coerce string Value, MasterServerClient.EQueryType QueryType)
{
	local MasterServerClient.QueryData QD;
	local int i;

	for ( i = 0; i < Uplink().Query.Length; i++ )
	{
		QD = Uplink().Query[i];
		if ( QD.Key ~= Key && QD.Value ~= Value && QD.QueryType == QueryType )
			return;
	}

	QD.Key			= Key;
	QD.Value		= Value;
	QD.QueryType	= QueryType;

	Uplink().Query[i] = QD;
}

function bool ValidateQueryItem(CustomFilter.EDataType FilterType, MasterServerClient.QueryData Data)
{
	local int i;

	if ( Data.QueryType == QT_Disabled )
	{
		return false;
	}

	switch ( FilterType )
	{
		case DT_Unique:
			for ( i = 0; i < Uplink().Query.Length; i++ )
			{
				if ( Uplink().Query[i].Key == Data.Key )
				{
					return false;
				}
			}

   			return true;

		case DT_Ranged:
			if ( Data.QueryType == QT_NotEquals )
			{
				return false;
			}

			for (i = 0; i < Uplink().Query.Length; i++)
			{
				if (Uplink().Query[i].Key == Data.Key)
				{
					if (Data.QueryType == QT_Equals)
					   return false;

  					switch (Uplink().Query[i].QueryType)
					{
						case QT_GreaterThan:
							if (Data.QueryType == QT_GreaterThanEquals)
								return false;

						case QT_GreaterThanEquals:
							if (Data.QueryType == QT_GreaterThan)
								return false;

							if (Uplink().Query[i].Value >= Data.Value)
							   return false;

                            break;

						case QT_LessThan:
						     if (Data.QueryType == QT_LessThanEquals)
						        return false;

						case QT_LessThanEquals:
						     if (Data.QueryType == QT_LessThan)
						        return false;

			                 if (Uplink().Query[i].Value <= Data.Value)
			                    return false;

					}

					break;
				}
			}

			return true;

		case DT_Multiple:
		     for (i = 0; i < Uplink().Query.Length; i++)
		         if ((Uplink().Query[i].Key == Data.Key) &&
		         	 (Uplink().Query[i].Value == Data.Value))
		               return false;

			return true;
	}

	return false;
}

function NotifyLevelChange()
{
	if ( ROMSC != none )
	{
		ROMSC.Stop();
		ROMSC.Destroy();
		ROMSC = none;
	}
}

function MyOnReceivedServer(GameInfo.ServerResponseLine s)
{
	local int i;

	SetTimer(60.0);

    AllServers.Insert(AllServers.Length, 1);
    AllServers[AllServers.Length - 1] = s;

	if ( s.GameType != CurrentGameType &&
		 Browser.co_GameType.GetComponentValue() != KFServerBrowser(Browser).AllTypesClassName )
	{
		return;
	}

	for ( i = 0; i < li_Server.Servers.Length; i++ )
	{
		if ( s.IP == li_Server.Servers[i].IP && s.Port == li_Server.Servers[i].Port )
		{
			return;
		}
	}

	DisplayServers(s);
	li_Server.AutoPingServers();

	SetFooterCaption(Repl(ServerCountString, "%NumServers%", Uplink().ResultCount));
}

function DisplayServers(GameInfo.ServerResponseLine s)
{
	li_Server.MyOnReceivedServer(s);
	li_Server.AddedItem();
	li_Server.SortList();
}

// We have list of servers from master server and are going to start pinging
function QueryComplete( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	li_Server.MyQueryFinished(ResponseInfo, Info);

	switch ( ResponseInfo )
	{
		case RI_Success:
			SetFooterCaption(Repl(QueryCompleteString, "%NumServers%", Uplink().ResultCount));
			break;

		case RI_AuthenticationFailed:
			SetFooterCaption(AuthFailString);
			break;

		case RI_ConnectionFailed:
	    	UT2K4ServerBrowser(PageOwner).GetFromServerCache(li_Server);
	    	li_Server.FakeFinished();
			SetFooterCaption(ConnFailString);
			break;

		case RI_ConnectionTimeout:
	    	UT2K4ServerBrowser(PageOwner).GetFromServerCache(li_Server);
	    	li_Server.FakeFinished();
			SetFooterCaption(ConnTimeoutString);
			break;

		case RI_MustUpgrade:
			SetFooterCaption(MustUpgradeString);
			break;
	}

	li_Server.SortList();
}

event Timer()
{
	if ( bQueryRunning )
	{
		bQueryRunning = false;
		Uplink().Stop();
		QueryComplete(RI_Success, 0);
	}
}

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
    AllServers.Remove(0, AllServers.Length);

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

function UpdateStatusPingCount()
{
    CheckJoinButton(li_Server.IsValid());
    CheckSpectateButton(li_Server.IsValid());
}

function CancelPings()
{
    Uplink().CancelPings();
    SetFooterCaption(ReadyString);
}

function PingServer(int listid, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s)
{
    if( PingCause == PC_Clicked )
        Uplink().PingServer( listid, PingCause, s.IP, s.QueryPort, QI_RulesAndPlayers, s );
    else
        Uplink().PingServer( listid, PingCause, s.IP, s.QueryPort, QI_Ping, s );
}

function CloseMSConnection()
{
	if ( Browser != None )
	{
		Uplink().CancelPings();
	    Uplink().Stop();
	}
}

defaultproperties
{
     ServerCountString="Received: %NumServers% Servers"
     Begin Object Class=KFFilterPanel Name=PanelFilter
         WinTop=0.890500
         WinHeight=0.107000
         TabOrder=3
     End Object
     FilterPanel=KFFilterPanel'KFGui.KFServerListPageInternet.PanelFilter'

     PlayCount=10
     Begin Object Class=GUISplitter Name=HorzSplitter
         DefaultPanels(0)="GUI2K4.UT2K4Browser_ServerListBox"
         DefaultPanels(1)="XInterface.GUISplitter"
         MaxPercentage=0.900000
         OnReleaseSplitter=KFServerListPageInternet.InternalReleaseSplitter
         OnCreateComponent=KFServerListPageInternet.InternalOnCreateComponent
         IniOption="@Internal"
         WinTop=0.012910
         WinHeight=0.876881
         RenderWeight=1.000000
         OnLoadINI=KFServerListPageInternet.InternalOnLoadINI
     End Object
     sp_Main=GUISplitter'KFGui.KFServerListPageInternet.HorzSplitter'

}
