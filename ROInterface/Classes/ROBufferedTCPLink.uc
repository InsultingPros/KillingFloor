//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROBufferedTCPLink extends BufferedTCPLink;

var IpAddr			ServerIpAddr;
var string          ReceiveState;
var string          Waiting;
var string          Match;
var string          Timeout;

function ResolveFailed()
{
	ServerIpAddr.Port = -1;  // set error flag
}
function Resolved( IpAddr Addr )
{
	// Set the address
	ServerIpAddr.Addr = Addr.Addr;
	ServerIpAddr.Port = 80;  // connect to http port

	// Handle failure.
	if( ServerIpAddr.Addr == 0 )
	{
		return;
	}

	// Bind the local port.
	if( BindPort() == 0 )
	{
		return;
	}

	Open( ServerIpAddr );
}

function DestroyLink()
{
	SetTimer(0.0,False);

	if(IsConnected())
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
    Super.WaitForCount(Count,TimeOut,MatchData);
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


function SendCommand(string Text)
{
	SendBufferedData(Text$CRLF);
}

defaultproperties
{
     Waiting="Waiting"
     Match="Matched"
     TimeOut="Timed Out"
}
