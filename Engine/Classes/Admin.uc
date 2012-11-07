class Admin extends AdminBase;

//if _RO_
// Execute an administrative console command on the server.
function DoLoginSilent( string Username, string Password)
{
	if (Level.Game.AccessControl.AdminLoginSilent(Outer, Username, Password))
	{
	    bAdmin = true;
	    Outer.ReceiveLocalizedMessage(Level.Game.GameMessageClass, 20);
	}
}
//end _RO_

// Execute an administrative console command on the server.
function DoLogin( string Username, string Password )
{
	if (Level.Game.AccessControl.AdminLogin(Outer, Username, Password))
	{
		bAdmin = true;
	    Level.Game.AccessControl.AdminEntered(Outer, "");
	}
}

function DoLogout()
{
	//if _RO_
    local bool bWasSilent;

    bWasSilent = Outer.PlayerReplicationInfo.bSilentAdmin;
    //end _RO_

	if (Level.Game.AccessControl.AdminLogout(Outer))
	{
		bAdmin = false;
		//if _RO_
		if (bWasSilent)
    	    Outer.ReceiveLocalizedMessage(Level.Game.GameMessageClass, 21);
		else
    		Level.Game.AccessControl.AdminExited(Outer);
		//else
		//Level.Game.AccessControl.AdminExited(Outer);
		//end _RO_
	}
}

defaultproperties
{
}
