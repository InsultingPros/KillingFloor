class ROServerLoading extends UT2K4ServerLoading;

var localized string    loadingMapPrefix;

var localized string    vacSecuredText;

var Material            vacIcon;

simulated event Init()
{
    Super.Init();

	SetVACInfo();
}

simulated function SetText()
{
	local GUIController GC;
	local DrawOpText HintOp;
	local string Map;

    Map = StripMap(MapName);
    Map = StripPrefix(Map);
    Map = AddSpaces(Map);

    // Exceptions
    if (Caps(Map) == "HEDGE HOG")
        Map = "Hedgehog";

	DrawOpText(Operations[2]).Text = loadingMapPrefix @ Map;

    DrawOpText(Operations[1]).Text = "";

	GC = GUIController(Level.GetLocalPlayerController().Player.GUIController);
	if (GC!=none)
	{
		GC.LCDCls();
		GC.LCDDrawTile(GC.LCDLogo,0,0,64,43,0,0,64,43);
		GC.LCDDrawText(loadingMapPrefix,55,10,GC.LCDMedFont);
		GC.LCDDrawText(StripMap(Map),55,26,GC.LCDTinyFont);
		GC.LCDRePaint();
	}

	if (Level.IsSoftwareRendering())
		return;

	HintOp = DrawOpText(Operations[3]);
	if ( HintOp == None )
		return;

	HintOp.Text = "";
}

simulated function SetVACInfo()
{
    if (bVACSecured)
    {
        DrawOpImage(Operations[4]).Image = vacIcon;
        DrawOpText(Operations[5]).Text = vacSecuredText;
    }
}

simulated function string AddSpaces(string s)
{
    local string temp, result, char;
    local int lastpos, pos;

    // Replace '_' with ' '
    temp = Repl(s, "_", " ", false);

    // Search for capitals in the name and add spaces inbetween words
    if (len(temp) > 1)
    {
        lastpos = 0;

        while (pos < len(temp))
    	{
    	    char = mid(temp, pos, 1);

    		if (Caps(char) == char && Locs(char) != char)
    		{
    			if (result != "")
    			    result $= " ";
                result $= mid(temp, lastpos, pos - lastpos);
                lastpos = pos;
      		}

            pos++;
    	}

    	if (lastpos != pos)
    	{
    	    if (result != "")
    			result $= " ";
            result $= mid(temp, lastpos, pos - lastpos);
    	}
    	return result;
    }
    else
        return temp;
}

simulated function string StripPrefix(string s)
{
    if (Left(s, 3) == "RO-" && len(s) > 3)
        return Right(s, len(s) - 3);
    else
        return s;
}

defaultproperties
{
     loadingMapPrefix="Deploying to"
     vacSecuredText="NOTE: This server is VAC Secured. Cheating will result in a permanent ban."
     vacIcon=Texture'InterfaceArt_tex.ServerIcons.VAC_protected'
     Backgrounds(0)="MenuBackground.LoadingScreen1"
     Backgrounds(1)="MenuBackground.LoadingScreen2"
     Backgrounds(2)="MenuBackground.LoadingScreen3"
     Backgrounds(3)="MenuBackground.LoadingScreen4"
     Backgrounds(4)="MenuBackground.LoadingScreen5"
     Operations(2)=RODrawOpShadowedText'ROInterface.ROServerLoading.OpMapname'
     Operations(4)=DrawOpImage'ROInterface.ROServerLoading.OpVACImg'
     Operations(5)=RODrawOpShadowedText'ROInterface.ROServerLoading.OpVACText'
}
