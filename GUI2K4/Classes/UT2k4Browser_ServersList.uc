class UT2K4Browser_ServersList extends ServerBrowserMCList;

// if _RO_
// else
//#exec OBJ LOAD file=..\Textures\Old2k4\ServerIcons.utx
//#exec texture Import File=..\Xinterface\textures\UTClassicIcon.tga Name=S_UTClassic Mips=Off Alpha=1
// end if _RO_

var() array<GameInfo.ServerResponseLine> Servers;

// OutstandingPings keeps track of simultaneous open connections vs. remaining servers awaiting pings
var() array<int> OutstandingPings;
var() int   UseSimultaneousPings;
var() int   NumReceivedPings;
var() int   NumPlayers;
var() int   RedialId;               // ListID of the server we're redialing
//ifdef _KF_
var() int   MaxPingsPerSecond;
var   float LastPingTime;
var() int   PingStart;
var   bool	bAutoPinging;
//endif _KF_

var() bool bPresort;
var() bool bInitialized;
var() array<Material>                   Icons;
var() localized array<String>           IconDescriptions;

struct report
{
	var int listid;
	var string ping, receive;
};

var array<report> reports;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController,InOwner);
}

function AddPingReport( int id, string s )
{
	local int i;

	if ( !bDebugging )
		return;

	for ( i = 0; i < reports.Length; i++ )
	{
		if ( reports[i].listid == id )
		{
			log("Warning, overwriting existing ping report ("$i$") for listid:"$id@s);
			reports[i].ping = s;
			return;
		}

		if ( reports[i].listid > id )
			break;
	}

	Reports.insert(i,1);
	Reports[i].listid = id;
	reports[i].ping = s;
}

function AddReceiveReport( int id, string s )
{
	local int i;

	if ( !bDebugging )
		return;

	for ( i = 0; i < reports.Length; i++ )
	{
		if ( reports[i].listid == id )
		{
			reports[i].receive = s;
			return;
		}

		if ( reports[i].listid > id )
			break;
	}

	log("Warning, no matching ping report found for listid:"$id@s);

	Reports.insert(i,1);
	Reports[i].listid = id;
	reports[i].receive = s;
}

function string getreportsortstring( int idx )
{
	local int i;
	local string s,port;
	local array<string> parts;

	divide(reports[idx].ping, ":", s, port);
	split(s, ".", parts);

	for ( i = 0; i < 4; i++ )
		padleft(parts[i],4,"0");

	padleft(port,5,"0");
	return JoinArray(parts,".") $ port;
}

function logall()
{
	local int i, id;
	local string idx, listid, outping, inping;

	local GUIMultiColumnList temp;


	if ( !bDebugging )
		return;

	idx = "Index";
	listId = "ListID";
	outping = "Address Pinged";
	inping = "Received";

	PadRight(idx, 8);
	PadRight(listid, 8);
	PadRight(outping, 22);


	// Add to a temporary list for sorting
	temp = new(None) class'guimulticolumnlist';
	temp.SortColumn = 0;
	temp.GetSortString = getreportsortstring;
	for ( i = 0; i < reports.Length; i++ )
		temp.addeditem();
	temp.sort();

	log(idx$listid$outping$inping);
	for ( i = 0; i < reports.Length; i++ )
	{
		id = temp.sortdata[i].sortitem;
		idx = string(id);
		listid = string(reports[id].listid);
		outping = reports[id].ping;
		inping = reports[id].receive;

		PadRight(idx, 8);
		PadRight(listid, 8);
		PadRight(outping, 22);

		log(idx$listid$outping$inping);
	}
}

event Timer()
{
//ifdef _KF_
	if( bAutoPinging )
		AutoPingServers();
	else if( IsValid() && OutstandingPings.Length <= 5 && bVisible )
		tp_MyPage.RefreshCurrentServer();
//else
	//if( IsValid() && OutstandingPings.Length <= 5 && bVisible )
	//	tp_MyPage.RefreshCurrentServer();
//endif _KF_
}

function SetAnchor(UT2K4Browser_ServerListPageBase Anchor)
{
	Super.SetAnchor(Anchor);
	if ( Anchor != None )
	{
		UseSimultaneousPings = tp_MyPage.Browser.GetMaxConnections();
//ifdef _KF_
		MaxPingsPerSecond = Controller.MaxPingsPerSecond;
//endif _KF_
	}
}

function Clear()
{
    PingStart = 0;
    StopPings();
    Servers.Remove(0,Servers.Length);
    ItemCount = 0;
    Super.Clear();
}

function CopyServerToClipboard()
{
    local string URL;

    if( IsValid() )
    {
        URL = PlayerOwner().GetURLProtocol()$"://"$Servers[CurrentListId()].IP$":"$string(Servers[CurrentListId()].Port);
        PlayerOwner().CopyToClipboard(URL);
    }
}

function Connect(bool Spectator)
{
    local string URL;
    if( IsValid() )
    {
        //!!
        URL = PlayerOwner().GetURLProtocol()$"://"$Servers[CurrentListId()].IP$":"$string(Servers[SortData[Index].SortItem].Port);
        if( Spectator )
            URL = URL $ "?SpectatorOnly=1";

        if( tp_MyPage.ConnectLAN )
            URL = URL $ "?LAN";

        Controller.CloseAll(false,True);
        PlayerOwner().ClientTravel( URL, TRAVEL_Absolute, False );
    }
}

function AddFavorite( UT2K4ServerBrowser Browser )
{
    if( IsValid() )
        Browser.OnAddFavorite( Servers[CurrentListId()] );
}

function bool MyOnDblClick(GUIComponent Sender)
{
    Connect(false);
    return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if( Super.InternalOnKeyEvent(Key, State, delta) )
        return true;

    if( State==3 )
    {
        switch( EInputKey(Key) )
        {
        case IK_Enter:
            Connect(false);
            return true;

        case IK_F5:
            tp_MyPage.RefreshList();
            return true;

        case IK_C:
            if(Controller.CtrlPressed)
            {
                // Ctrl-C on the server list copies selected server to clipboard.
                CopyServerToClipboard();
                return true;
            }
            break;
        }
    }
    return false;
}

function MyOnReceivedServer( GameInfo.ServerResponseLine s )
{
    local int i;
	local UT2K4ServerBrowser SB;

/*	if ( bPreSort && bool(s.Flags & 32) && (!bool(s.Flags & 8)) )	// if it's standard, but not listen, add it to the front
		i = 0;
	else
*/		i = Servers.Length;

	Servers.Insert(i,1);

    Servers[i] = s;
    if( Servers[i].Ping == 0 )
        Servers[i].Ping = 9999;

	if ( !bPresort )
	    AddedItem(i);

	// Add the item to the cache

	SB = UT2K4ServerBrowser(PageOwner);
	if ( SB!=None && SB.Verified )
		SB.AddToServerCache(s);
}

function MyPingTimeout( int listid, ServerQueryClient.EPingCause PingCause  )
{
    local int i;

	AddReceiveReport(listid,"TIMEOUT");
    if(listid < 0 || listid >= Servers.Length)
    {
    	PingStart = 0;
        return;
    }

    // remove from the outstanding ping list
    for( i=0;i<OutstandingPings.Length;i++ )
        if( OutstandingPings[i] == listid )
        {
            OutstandingPings.Remove(i,1);
            break;
        }

    if( Servers[listid].Ping == 9999 )
    {
        Servers[listid].Ping = 20000;
        UpdatedItem(listid);
    }

    // continue pinging
    if( PingCause == PC_AutoPing )
    {
        NumReceivedPings++;
        NeedsSorting = True;
        AutoPingServers();
    }
}

function MyReceivedPingInfo( int listid, ServerQueryClient.EPingCause PingCause, GameInfo.ServerResponseLine s )
{
    local int i,Flags;
    local bool bFound;

    if( listid < 0 || listid >= Servers.Length )
    {
        PingStart = 0;
        AddReceiveReport(listid,s.ip$":"$s.port);
        return;
    }
    else AddReceiveReport(listid,s.ip$":"$s.port);


	Flags = Servers[listid].Flags;
    Servers[listid] = s;
    Servers[listid].Flags = Flags;

    // see if we can move the ping start marker down
    for( i=PingStart;i<listid && i<Servers.Length;i++ )
        if( Servers[i].Ping == 9999 )
            break;

    if( i < listid )
        PingStart = listid;

    // remove from the outstanding ping list
    for( i=0;i<OutstandingPings.Length;i++ )
        if( OutstandingPings[i] == listid )
        {
        	bFound = True;
            OutstandingPings.Remove(i,1);
            break;
        }

    UpdatedItem(listid);

    // update rules/player info
    if( IsValid() && listid == SortData[Index].SortItem )
        OnChange(None);

    // continue pinging
    if( PingCause == PC_AutoPing )
    {
        NumReceivedPings++;
        NumPlayers += s.CurrentPlayers;
        NeedsSorting = True;
        AutoPingServers();
    }
}

function RepingServers()
{
    InvalidatePings();
    AutoPingServers();
}

function FakeFinished()
{
	local int i;
	for (i=0;I<Servers.Length;i++)
		AddedItem();

	RepingServers();
	SetTimer(5.0,true);
}

function MyQueryFinished( MasterServerClient.EResponseInfo ResponseInfo, int Info )
{
	local int i;

    if( ResponseInfo == RI_Success )
    {
    	if ( bPreSort )
    	{
    		if ( ItemCount > 0 )
    		{
    			log(Name@"RECEIVED QUERYFINISHED NOTICE WITH ITEMCOUNT > 0!!! ITEMCOUNT:"$ItemCount@"Info:"$Info);
    			return;
    		}

    		for ( i = 0; i < Servers.Length; i++ )
    			AddedItem();
    	}

		// if _RO_
        /* Commented out for Steam Master Server Integration
        // endif
        RepingServers();
		// if _RO_
        */
        // endif
        SetTimer(5.0, True);
    }
}

function InvalidatePings()
{
    local int i;

	reports.Remove(0,reports.length);
    StopPings();
    PingStart = 0;
    NumReceivedPings=0;
    NumPlayers=0;
    for( i=0;i<Servers.Length;i++ )
    {
        Servers[i].Ping = 9999;
        UpdatedItem(i);
    }
}

function AutoPingServers()
{
    local int i, j;

//ifdef _KF_
    bAutoPinging = true;

    if ( MaxPingsPerSecond > 0 )
	{
		if ( PlayerOwner().Level.TimeSeconds - LastPingTime > 1.0 / MaxPingsPerSecond )
		{
			UseSimultaneousPings = OutstandingPings.Length + 1;
			LastPingTime = PlayerOwner().Level.TimeSeconds;
		}
		else
		{
			UseSimultaneousPings = -1;
		}
	}
//endif _KF_

    for( i=PingStart;i<Servers.Length && OutstandingPings.Length < UseSimultaneousPings;i++ )
    {
        if( Servers[i].Ping == 9999 )
        {
            // see if we already have an outstanding ping for this server.
            for( j=0;j<OutstandingPings.Length;j++ )
                if( OutstandingPings[j] == i )
                    break;

            if( j == OutstandingPings.Length )
            {
                // add out outstanding ping list
                OutstandingPings[j] = i;

                // ping
                AddPingReport(i,Servers[i].IP$":"$Servers[i].Port);
                tp_MyPage.PingServer( i, PC_AutoPing, Servers[i] );
            }
        }
    }

//    if(OutstandingPings.Length == 0)
//        NumReceivedPings = Servers.Length;  // debugging

//ifdef _KF_
	if ( OutstandingPings.Length == 0 && (MaxPingsPerSecond <= 0 || PlayerOwner().Level.TimeSeconds - LastPingTime > 1.0 / MaxPingsPerSecond) )
	{
		bAutoPinging = false;
		logall();
	}
	else if ( MaxPingsPerSecond > 0 )
	{
		SetTimer(1.0 / MaxPingsPerSecond, true);
	}
//else
	//if ( OutstandingPings.Length == 0 )
	//	logall();
//endif _KF_
}

function StopPings()
{
//	log(Name@"StopPings   OutstandingPings:"$OutstandingPings.Length);
    OutstandingPings.Remove(0,OutstandingPings.Length);

    if ( tp_MyPage != None )
	    tp_MyPage.CancelPings();
}

function int RemoveServerAt( int Pos )
{
	local int i;


	if ( !IsValidIndex(pos) )
		return -1;

	// In order to avoid having to search for the SortData that has SortItem == Pos,
	// just do a switcharoo and pull out the last server
	i = Servers.Length - 1;
	if ( pos < i )
		Servers[pos] = Servers[i];

	Servers.Remove(i,1);

	if ( i == Index )
	{
		tp_MyPage.li_Rules.Clear();
		tp_MyPage.li_Players.Clear();
	}

	RemovedItem(i);
	SetIndex(Index);

	NeedsSorting = True;

	return pos;
}

function int RemoveCurrentServer()
{
	local int OldItem;

	if ( IsValid() )
	{
		OldItem = SortData[Index].SortItem;
		if ( RemoveServerAt(Index) != -1 )
			return OldItem;
	}

	return -1;
}

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth, DrawX;
    local float IconPosX, IconPosY;
    local string Ping;
    local int k, flags, checkFlag;
    local GUIStyles DStyle;

    // Draw the selection border
    if( bSelected )
    {
        SelectedStyle.Draw(Canvas,MenuState,X,Y,W,H+1);
        DStyle = SelectedStyle;
    }
    else
        DStyle = Style;

    //////////////////////////////////////////////////////////////////////
    // Here we get the flags for this server.
    // Passworded      1
    // Stats           2
    // LatestVersion   4
    // Listen Server   8
    // Vac Secured	   16		// Was Instagib        16
    // Beginner        32		// Was Standard        32
    // Normal          64		// Was UT CLassic      64
    // Hard            128
    // Suicidal        256
	flags = Servers[SortData[i].SortItem].Flags;

    //////////////////////////////////////////////////////////////////////

    GetCellLeftWidth( 0, CellLeft, CellWidth );
    IconPosX = CellLeft;
    IconPosY = Y;



    // First flag is in the second to most sig bit (dont want to mess with sign bit). Then we work down.
    checkFlag = 1;

    // While we still have icon, and we can fit another one in.
    for(k=0; (k<Icons.Length) && (IconPosX < CellLeft + CellWidth); k++)
    {
// if _RO_
        if (Icons[k] != none)
        {
// end if _RO_
        if((flags & checkFlag) != 0)
        {
            DrawX = Min(14, (CellLeft + CellWidth) - IconPosX);

            Canvas.DrawColor = Canvas.MakeColor(255, 255, 255, 255);

            Canvas.SetPos(IconPosX, IconPosY);
            Canvas.DrawTile(Icons[k], DrawX, 14, 0, 0, DrawX+1.0, 15.0);

            IconPosX += 14;
        }
// if _RO_
        }
// end if _RO_

        checkFlag = checkFlag << 1;
    }


    GetCellLeftWidth( 1, CellLeft, CellWidth );
    DStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, Servers[SortData[i].SortItem].ServerName, FontScale );

    GetCellLeftWidth( 2, CellLeft, CellWidth );
    DStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, Servers[SortData[i].SortItem].MapName, FontScale );

    GetCellLeftWidth( 3, CellLeft, CellWidth );
    if( Servers[SortData[i].SortItem].CurrentPlayers>0 || Servers[SortData[i].SortItem].MaxPlayers>0 )
        DStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(Servers[SortData[i].SortItem].CurrentPlayers)$"/"$string((Servers[SortData[i].SortItem].MaxPlayers&255)), FontScale );

    GetCellLeftWidth( 4, CellLeft, CellWidth );
    if( Servers[SortData[i].SortItem].CurrentWave>0 || Servers[SortData[i].SortItem].FinalWave>0 )
        DStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(Servers[SortData[i].SortItem].CurrentWave)$"/"$string((Servers[SortData[i].SortItem].FinalWave)), FontScale );

    GetCellLeftWidth( 5, CellLeft, CellWidth );
    if( Servers[SortData[i].SortItem].Ping == 9999 )
        Ping = "?";
    else
    if( Servers[SortData[i].SortItem].Ping > 9999 )
        Ping = "N/A";
    else
        Ping = string(Servers[SortData[i].SortItem].Ping);
    DStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, Ping, FontScale );
}

function string GetSortString( int i )
{
    local string s, t;

    switch( SortColumn )
    {
    case 0:
    	s = BuildFlagString(Servers[i].Flags) $ i;
    	break;

    case 1:
        s = Left(caps(Servers[i].ServerName), 8);
        break;

    case 2:
        s = Left(caps(Servers[i].MapName), 8);
        break;

    case 3:
        s = string(Servers[i].CurrentPlayers);
        PadLeft(S, 4, "0");

        t = string((Servers[i].MaxPlayers&255));
        PadLeft(T, 4, "0");
        s $= t $ i;
        break;

    case 4:
        s = string(Servers[i].CurrentWave);
        PadLeft(s, 4, "0");

        t = string(Servers[i].FinalWave);
        PadLeft(t, 4, "0");
        s $= t $ i;
        break;

    default:
        s = string(Servers[i].Ping);
	    PadLeft(S,5,"0");

        s $= i;

        break;
    }
    return s;
}

function string Get(optional bool bGuarantee)
{
	local string s;

	if ( IsValid() )
		s = Servers[CurrentListId()].IP $ ":" $ Servers[CurrentListId()].Port;
	else if ( Servers.Length > 0 && bGuarantee )
		s = Servers[SortData[0].SortItem].IP $ ":" $ Servers[SortData[0].SortItem].Port;

	return s;
}

function bool GetCurrent( out GameInfo.ServerResponseLine s )
{
	if ( !IsValid() )
		return false;

	s = Servers[CurrentListId()];
	return true;
}

function int FindIndex( string IP, optional string Port )
{
	local int i;

	for ( i = 0; i < Servers.Length; i++ )
		if ( Servers[i].IP == IP && (Port == "" || Servers[i].Port == int(Port)) )
			return i;

	return -1;
}

function bool IsValid()
{
	return Index >= 0 && Index < Servers.Length;
}

function bool IsValidIndex(int Test)
{
	return Test >= 0 && Test < Servers.Length;
}


event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);
	if ( bInitialized && tp_MyPage != None )
		AutoPingServers();
	else bInitialized = True;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);

	StopPings();
}

function string BuildFlagString( int Flags )
{
    // Passworded      1
    // Stats           2
    // LatestVersion   4
    // Listen Server   8
    // Instagib        16
    // Standard        32
    // UT CLassic      64
    local int Value;
    local string Result;

    Value = 9999;

    if ( bool(Flags & 256) )
    	Value -= 1000;
    else if ( bool(Flags & 128) )
    	Value -= 2000;
    else if ( bool(Flags & 64) )
    	Value -= 3000;
    else if ( bool(Flags & 32) )
    	Value -= 4000;

    if ( !bool(Flags & 8) )
    	Value -= 50;

    if ( !bool(Flags & 16) )
    	Value -= 85;

    if ( bool(Flags & 2) )
    	Value -= 100;

    Result = string(Value);
    PadLeft(Result,4,"0");

    return Result;
}

defaultproperties
{
     Icons(0)=Texture'InterfaceArt_tex.ServerIcons.passworded'
     Icons(1)=Texture'InterfaceArt_tex.ServerIcons.Stats'
     Icons(3)=Texture'InterfaceArt_tex.ServerIcons.listen2'
     Icons(4)=Texture'InterfaceArt_tex.ServerIcons.VAC_Servericon'
     Icons(5)=Texture'InterfaceArt2_tex.Server_Icons.Easy'
     Icons(6)=Texture'InterfaceArt2_tex.Server_Icons.Normal'
     Icons(7)=Texture'InterfaceArt2_tex.Server_Icons.Hard'
     Icons(8)=Texture'InterfaceArt2_tex.Server_Icons.Suicide'
     Icons(9)=Texture'InterfaceArt2_tex.Server_Icons.HellonEarth'
     IconDescriptions(0)="Passworded"
     IconDescriptions(1)="Stats Enabled"
     IconDescriptions(3)="Listen Server"
     IconDescriptions(4)="VAC Secured"
     IconDescriptions(5)="Beginner Difficulty"
     IconDescriptions(6)="Normal Difficulty"
     IconDescriptions(7)="Hard Difficulty"
     IconDescriptions(8)="Suicidal Difficulty"
     IconDescriptions(9)="Hell Difficulty"
     ColumnHeadings(1)="Server Name"
     ColumnHeadings(2)="Map"
     ColumnHeadings(3)="Players"
     ColumnHeadings(4)="Wave"
     ColumnHeadings(5)="Ping"
     InitColumnPerc(0)=0.100000
     InitColumnPerc(1)=0.400000
     InitColumnPerc(2)=0.200000
     InitColumnPerc(3)=0.100000
     InitColumnPerc(4)=0.100000
     InitColumnPerc(5)=0.100000
     SortColumn=5
     OnDrawItem=UT2k4Browser_ServersList.MyOnDrawItem
     WinHeight=1.000000
     OnDblClick=UT2k4Browser_ServersList.MyOnDblClick
}
