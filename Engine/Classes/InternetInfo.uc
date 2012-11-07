//=============================================================================
// InternetInfo: Parent class for Internet connection classes
//=============================================================================
class InternetInfo extends Info
	native
	transient;

// gam ---
function int GetBeaconCount()
{
    return (0);
}
// --- gam

function string GetBeaconAddress( int i );
function string GetBeaconText( int i );

//ifdef _RO_
function Init(string Address, string Request);
delegate bool OnServerConnectTimeout();
delegate OnServerResponded(string Response);
//endif

defaultproperties
{
}
