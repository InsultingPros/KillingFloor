class KFMOTD extends UT2K4Browser_MOTD;

var String myMOTD;

var String getRequest;
var String getResponse;
var String newsIPAddr;
var int		myRetryCount;
var int		myRetryMax;

var ROBufferedTCPLink myLink;
var string LinkClassName;
var bool sendGet;
var bool pageWait;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    super.InitComponent(MyController, MyOwner);

    GetNewNews();
    lb_MOTD.MyScrollText.SetContent(myMOTD);
}

event Opened(GUIComponent Sender)
{
	l_Version.Caption = VersionString@PlayerOwner().Level.ROVersion;

	super(Ut2k4Browser_Page).Opened(Sender);
}

protected function ROBufferedTCPLink CreateNewLink()
{
	local class<ROBufferedTCPLink> NewLinkClass;
	local ROBufferedTCPLink NewLink;

	if ( PlayerOwner() == None )
		return None;

	if ( LinkClassName != "" )
	{
		NewLinkClass = class<ROBufferedTCPLink>(DynamicLoadObject( LinkClassName, class'Class'));
    }
    if ( NewLinkClass != None )
    {
        NewLink = PlayerOwner().Spawn( NewLinkClass );
    }

    NewLink.ResetBuffer();

    return NewLink;
}


function ReceivedMOTD(MasterServerClient.EMOTDResponse Command, string Data)
{
}

function GetNewNews()
{
    if(myLink == None)
    {
        myLink = CreateNewLink();
    }

    if(myLink != None)
    {
        myLink.ServerIpAddr.Port = 0;

        sendGet = true;
        myLink.Resolve(newsIPAddr);  // NOTE: This is a non-blocking operation

        SetTimer(ReReadyPause, true);
    }
    else
    {
        myMOTD = myMOTD$"|| myLink is None";
    }
}

event Timer()
{
    local string text;
    local string page;
    local string command;


    if(myLink != None)
    {
        if ( myLink.ServerIpAddr.Port != 0)
        {
            if(myLink.IsConnected())
            {
                if(sendGet)
                {
                     command = getRequest$myLink.CRLF$"Host: "$newsIPAddr$myLink.CRLF$myLink.CRLF;
                     myLink.SendCommand(command);

                     pageWait = true;
                     myLink.WaitForCount(1,20,1); // 20 sec timeout
                     sendGet = false;
                }
                else
                {
                    if(pageWait)
                    {
                        myMOTD = myMOTD$".";
                        lb_MOTD.MyScrollText.SetContent(myMOTD);
                    }
                }
            }
            else
            {
                if(sendGet)
                {
                    myMOTD = myMOTD$"|| Could not connect to news server";
                    lb_MOTD.MyScrollText.SetContent(myMOTD);
                }
            }
        }
        else
        {
        	if (myRetryCount++ > myRetryMax)
        	{
                myMOTD = myMOTD$"|| Retries Failed";
                KillTimer();
                lb_MOTD.MyScrollText.SetContent(myMOTD);
        	}
        }

        if(myLink.PeekChar() != 0)
        {
            pageWait = false;

			// data waiting
            page = "";
            while(myLink.ReadBufferedLine(text))
            {
                page = page$text;
            }

            NewsParse(page);

            myMOTD = "|"$page;

            lb_MOTD.MyScrollText.SetContent(myMOTD);

            myLink.DestroyLink();
            myLink = none;

            KillTimer();
        }
    }

    SetTimer(ReReadyPause, true);
}

function NewsParse(out string page)
{
    local string junk;
    local int i;

    junk = page;
    Caps(junk);

    i = InStr(junk, "<BODY>");
    if ( i > -1 )
    {
         // remove all header from string
         page = Right(page, len(page) - i - 6);
    }

    junk = page;
    Caps(junk);

    i = InStr(junk, "</BODY>");
    if ( i > -1 )
    {
         // remove all footers from string
         page = Left(page, i);
    }

    page = Repl(page, "<br>", "|", false);
}

defaultproperties
{
     myMOTD="||Connecting To News Server"
     getRequest="GET /kfnews.htm HTTP/1.1"
     newsIPAddr="redorchestragame.com"
     myRetryMax=40
     LinkClassName="ROInterface.ROBufferedTCPLink"
     sendGet=True
     Begin Object Class=GUIScrollTextBox Name=MyMOTDText
         bNoTeletype=True
         CharDelay=0.050000
         EOLDelay=0.100000
         bVisibleWhenEmpty=True
         OnCreateComponent=MyMOTDText.InternalOnCreateComponent
         WinTop=0.001679
         WinLeft=0.010000
         WinWidth=0.990000
         WinHeight=0.833203
         RenderWeight=0.600000
         TabOrder=1
         bNeverFocus=True
     End Object
     lb_MOTD=GUIScrollTextBox'KFGui.KFMOTD.MyMOTDText'

     Begin Object Class=GUILabel Name=VersionNum
         TextAlign=TXTA_Right
         StyleName="TextLabel"
         WinTop=-0.043415
         WinLeft=0.738500
         WinWidth=0.252128
         WinHeight=0.040000
         RenderWeight=20.700001
     End Object
     l_Version=GUILabel'KFGui.KFMOTD.VersionNum'

     b_QuickConnect=None

     ReReadyPause=0.250000
     VersionString="KF Version"
}
