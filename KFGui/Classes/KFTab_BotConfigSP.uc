class KFTab_BotConfigSP extends UT2K4Tab_BotConfigSP;

function SetupBotLists(bool bIsTeam)
{
    local int i, j;
    local class<TeamInfo> TIClass;
    local array<string> Chars;

    bTeamGame = bIsTeam;

    li_Red.Clear();
    li_Blue.Clear();


     if (bTeamGame)
    {
    	TIClass = class<TeamInfo>(DynamicLoadObject("XGame.TeamRedConfigured",class'Class'));
    	if ( TIClass != None )
    	{
    		TIClass.static.GetAllCharacters(Chars);
    		for ( i = 0; i < Chars.Length; i++ )
    		{
    			for ( j = 0; j < li_Bots.PlayerList.Length; j++ )
    			{
    				if ( li_Bots.PlayerList[j].DefaultName ~= Chars[i] )
    					li_Red.Add(li_Bots.PlayerList[j].Portrait, j);
 				}
    		}
   	}

    	TIClass = class<TeamInfo>(DynamicLoadObject("XGame.TeamBlueConfigured",class'Class'));
    	if ( TIClass != None )
		{
    		TIClass.static.GetAllCharacters(Chars);
    		for ( i = 0; i < Chars.Length; i++ )
    		{
    			for ( j = 0; j < li_Bots.PlayerList.Length; j++ )
    				if ( li_Bots.PlayerList[j].DefaultName ~= Chars[i] )
    					li_Blue.Add(li_Bots.PlayerList[j].Portrait, j);
    		}
    	}
    }
    else
    {
    	TIClass = class<TeamInfo>(DynamicLoadObject("XGame.DMRosterConfigured",class'Class'));
    	if ( TIClass != None )
		{
    		TIClass.static.GetAllCharacters(Chars);
    		for ( i = 0; i < Chars.Length; i++ )
    		{
    			for ( j = 0; j < li_Bots.PlayerList.Length; j++ )
    				if ( li_Bots.PlayerList[j].DefaultName ~= Chars[i] )
    					li_Red.Add(li_Bots.PlayerList[j].Portrait, j);
    		}
    	}
    }
    SetVis(bTeamGame);

}

defaultproperties
{
}
