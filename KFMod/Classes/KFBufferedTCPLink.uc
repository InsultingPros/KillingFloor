class KFBufferedTCPLink extends BufferedTCPLink;

var IpAddr	ServerIpAddr;
var string	ReceiveState;
var string	Waiting;
var string	Match;
var string	Timeout;

var float	RetryTime;
var	int		CurrentRetries;
var	int		MaxRetries;

var	bool	bSendRequest;
var	bool	bDone;
var	bool	bFailed;

var string	TargetAddress;
var string	TargetRequest;

function Init(string Address, string Request)
{
	Close();

	bDone = false;
	bFailed = false;

	bSendRequest = true;
	ServerIpAddr.Port = 0;
	CurrentRetries = 0;

	TargetAddress = Address;
	TargetRequest = Request;

	Resolve(Address);

	SetTimer(RetryTime, false);
}

event Timer()
{
	if ( bDone )
	{
		return;
	}

	if ( bFailed )
	{
		bFailed = false;
		bDone = OnServerConnectTimeout();
		return;
	}

	if ( ServerIpAddr.Port != 0)
	{
		if ( IsConnected() )
		{
			if ( bSendRequest )
			{
				SendBufferedData(TargetRequest$CRLF);

				bSendRequest = false;

				WaitForCount(1, 20, 1); // 20 sec timeout
			}
		}
		else if ( CurrentRetries++ > MaxRetries )
		{
			OnServerConnectTimeout();
			return;
		}
	}
	else if ( CurrentRetries++ > MaxRetries )
	{
		OnServerConnectTimeout();
		return;
	}

	SetTimer(RetryTime, false);
}

function ResolveFailed()
{
	ServerIpAddr.Port = -1;  // set error flag
}

function Resolved(IpAddr Addr)
{
	// Set the address
	ServerIpAddr.Addr = Addr.Addr;
	ServerIpAddr.Port = 80;  // connect to http port

	// Handle failure.
	if ( ServerIpAddr.Addr == 0 )
	{
		return;
	}

	// Bind the local port.
	if ( BindPort() == 0 )
	{
		return;
	}

	OpenNoSteam(ServerIpAddr);
}

function DestroyLink()
{
	SetTimer(0.0, False);

	if ( IsConnected() )
	{
		Close();
	}
}

function Tick(float DeltaTime)
{
	DoBufferQueueIO();

    Super.Tick(DeltaTime);
}

function WaitForCount(int Count, float TimeOut, int MatchData)
{
    Super.WaitForCount(Count, TimeOut, MatchData);
    ReceiveState = Waiting;
}

function GotMatch(int MatchData)
{
	// called when a match happens
    ReceiveState = Match;
}

function GotMatchTimeout(int MatchData)
{
	// when a match times out
    ReceiveState = Timeout;
}

event ReceivedText(string Text)
{
	local int Index;

	if ( !bDone )
	{
		Index = InStr(Text, "Content-Location: KF:");

		if ( Index > 0 )
		{
			bDone = true;
			OnServerResponded(Mid(Text, Index + 22));
		}
		else
		{
			bFailed = true;
		}
	}
}

defaultproperties
{
     Waiting="Waiting"
     Match="Matched"
     TimeOut="Timed Out"
     RetryTime=0.250000
     MaxRetries=20
}
