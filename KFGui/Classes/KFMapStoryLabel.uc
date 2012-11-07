// Text Box for our Lobby. includes a little blurb about the map. (to make peace with myself for removing intro cutscenes :-/ )

class KFMapStoryLabel extends GUIScrollTextBox ;

var string StoryString;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

    Super.InitComponent(MyController, MyOwner);

    /*

 if (PlayerOwner().Level != none)
   StoryString = PlayerOwner().Level.Description ;


   SetContent(StoryString);




    if (DefaultListClass != "")
    {
        MyScrollText = GUIScrollText(AddComponent(DefaultListClass));
        if (MyScrollText == None)
        {
            log(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
            return;
        }
    }

    if (MyScrollText == None)
    {
        Warn("Could not initialize list!");
        return;
    }

    InitBaseList(MyScrollText);
    */
}

function LoadStoryText()
{
	local string MapName;
	local int i, j;

	MapName = PlayerOwner().Level.GetLocalURL();

	i = InStr(MapName, "/");
	if ( i < 0 )
	{
		i = 0;
	}
	else
	{
		i++;
	}

	j = InStr(MapName, "?");
	if ( j < 0 )
	{
		j = Len(MapName);
	}

	MapName = Mid(MapName, i, j - i);

	StoryString = class'CacheManager'.static.GetMapRecord(MapName).Description;

	SetContent(StoryString);
}

defaultproperties
{
     bNoTeletype=True
     CharDelay=0.010000
     EOLDelay=0.010000
     bVisibleWhenEmpty=True
     WinTop=0.123207
     WinLeft=0.499288
     WinWidth=0.469593
     WinHeight=0.283379
     bAcceptsInput=False
     bNeverFocus=True
}
