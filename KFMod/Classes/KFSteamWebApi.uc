class KFSteamWebApi extends Actor;

var String getRequestLeft;
var String getRequestRight;
var String getRequestSteamID;
var String getResponse;
var String steamAPIAddr;

var int		myRetryCount;
var int		myRetryMax;
var int    appID;
var string    steamID;

var ROBufferedTCPLink myLink;
var string LinkClassName;
var bool sendGet;
var bool pageWait;

var string playerStats;

simulated delegate AchievementReport( bool HasAchievement, string Achievement, int gameID, string steamID);

protected function ROBufferedTCPLink CreateNewLink()
{
	local class<ROBufferedTCPLink> NewLinkClass;
	local ROBufferedTCPLink NewLink;

	if ( LinkClassName != "" )
	{
		NewLinkClass = class<ROBufferedTCPLink>(DynamicLoadObject( LinkClassName, class'Class'));
    }
    if ( NewLinkClass != None )
    {
        NewLink = Spawn( NewLinkClass );
    }

    NewLink.ResetBuffer();

    return NewLink;
}

function GetAchievements(string steamIDIn)
{
    steamID = steamIDIn;
    playerStats = "";
    if(myLink == None)
    {
        myLink = CreateNewLink();
    }

    if(myLink != None)
    {
        myLink.ServerIpAddr.Port = 0;

        sendGet = true;
        myLink.Resolve(steamAPIAddr);  // NOTE: This is a non-blocking operation

        SetTimer(0.25, true);
    }
    else
    {
       // myMOTD = myMOTD$"|| myLink is None";
    }
}

event Timer()
{
    local string text;
    local string command;
    local int count;


    if(myLink != None)
    {
        if ( myLink.ServerIpAddr.Port != 0)
        {
            if(myLink.IsConnected())
            {
                if(sendGet)
                {
                     command = getRequestLeft$appid$getRequestSteamID$steamID$getRequestRight$myLink.CRLF$"Host: "$steamAPIAddr$myLink.CRLF$myLink.CRLF;
                     myLink.SendCommand(command);

                     pageWait = true;
                     myLink.WaitForCount(1,20,1); // 20 sec timeout
                     sendGet = false;
                }
                else
                {
                    if(pageWait)
                    {
                       //log("waiting");
                    }
                }
            }
            else
            {
                if(sendGet)
                {
                    log("could not connect");
                }
            }
        }
        else
        {
        	if (myRetryCount++ > myRetryMax)
        	{
                 log("too many retries!");
        	}
        }

        if(myLink.PeekChar() != 0)
        {
            pageWait = false;

			// data waiting
            //these two while statements get all the data we need.
            while(myLink.ReadBufferedLine(text))
            {
                playerStats = playerStats$text;
            }

            while(count > 0 )
            {
                count = myLink.ReadText(text);
                playerStats = playerStats$text;
            }
            
            count = InStr(playerStats, "\"success\": true" );
            if(count == -1 )
            {
                log("webapi*********** still need to wait", 'DevNet');                
                SetTimer(0.250000, true);
                return;
            }
            else
            {
                log("webapi EOF reached", 'DevNet');
            }


            
			log(playerStats, 'DevNet');
			log("webapi********playerstats", 'DevNet');
            HasAchievement("NotAWarhammer");

            myLink.DestroyLink();
            myLink = none;

            return;
        }
    }

    SetTimer(0.250000, true);
}

function bool HasAchievement(string achievement)
{
    local int position;
    local string rhs;
    local string findString;
    findString = "\"apiname\": \""$achievement$"\",";
    position = InStr(playerStats, findString );
    //we found it!
    if( position != -1 )
    {
        rhs = Mid(playerStats, position +Len(FindString), 20 );//- Len(findString) );
        position = InStr(rhs,"achieved\": 1");

    }
    AchievementReport( position != -1, achievement, appID, steamID);
    if( position != -1 )
    {
        return true;
    }

    return false;
}

defaultproperties
{
     getRequestLeft="GET /ISteamUserStats/GetPlayerAchievements/v0001/?appid="
     getRequestRight="&key=6477773857A981BC6F4F50D7CAFD59E4&format=json HTTP/1.1"
     getRequestSteamID="&steamID="
     steamAPIAddr="api.steampowered.com"
     myRetryMax=40
     AppID=213650
     LinkClassName="ROInterface.ROBufferedTCPLink"
     sendGet=True
     bHidden=True
}
