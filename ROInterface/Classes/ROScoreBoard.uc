//=============================================================================
// ROScoreBoard
//=============================================================================
// New scoreboard
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003 Erik Christensen
//=============================================================================

class ROScoreBoard extends ScoreBoard;

//=============================================================================
// Variables
//=============================================================================

const MAXPLAYERS = 32;
const SPECTATOR = 3;
const MAXPERSIDE = 18;
const MAXPERSIDEWIDE = 16;

var()	Material			HeaderImage;

var()	localized	string		SpectatorTeamName;
var()	localized	string		UnassignedTeamName;
var()	localized	string		TitleText;
var()	localized	string		NameText;
var()	localized	string		AdminText;
var()	localized	string		RoleText;
var()	localized	string		ScoreText;
var()	localized	string		TimeText;
var()	localized	string		PingText;
var()	localized	string		PlayerText;
var()	localized	string		PlayerPluralText;
var()	localized	string		TotalsText;
var()	localized	string		ObjectivesHeldText;
var()	localized	string		RequiredObjHeldText;
var()	localized	string		SecondaryObjHeldText;
var()	localized	string		RoundsWonText;
var()	localized 	string		TeamNameAllies;
var()	localized 	string		TeamNameAxis;

var()	float				NameLength;
var()	float				TeamScoreLength;
var()	float				RoleLength;
var()	float				ScoreLength;
var()	float				TimeLength;
var()	float				PingLength;

var()	Color				TeamColors[4];
/*var()	Color				GermanColor;
var()	Color				RussianColor;
var()	Color				UnassignedColor;
var()	Color				SpectatorColor;*/
var()	color				HighlightColor;

var	ROPlayerReplicationInfo		PRIArray[10];
var	int				AvgPing[4];
var	float				Padding;

// New Scoreboard vars
var() localized string ReinforcementsText;
var() localized string WaitingText;
var() localized string AdminWaitingText;
var config bool bAlphaSortScoreBoard;

const BaseGermanX = 0.75;
const BaseRussianX = 15.25;

//=============================================================================
// Functions
//=============================================================================

//-----------------------------------------------------------------------------
// UpdateScoreboard - Called every frame to update the scoreboard
//-----------------------------------------------------------------------------
// This is a modified version based of of Crube's BFE scoreboard mutator
simulated function UpdateScoreBoard (Canvas C)
{
	local ROPlayerReplicationInfo PRI;
	local int i, j, CurMaxPerSide;
	local float X,Y,cellHeight,XL,YL,LeftY,RightY, CurrentTime;
	local color TeamColor;
	local ROPlayerReplicationInfo GermanPRI[32];
	local ROPlayerReplicationInfo RussianPRI[32];
	local ROPlayerReplicationInfo UnassignedPRI[32];
	local int GECount,RUCount,UnassignedCount, AxisTotalScore, AlliesTotalScore;
	local int AxisReqObjCount, AlliesReqObjCount, Axis2ndObjCount, Allies2ndObjCount;
	local string RoleName,S;
	local bool bHighLight, bRequiredObjectives;
	local bool bOwnerDrawn;

	if ( C == None )
		return;

    //Widescreen mode uses a different maximum per side setting
	if ( float(C.SizeX) / C.SizeY >= 1.60 ) //1.6 = 16/10 which is 16:10 ratio and 16:9 comes to 1.77
	    CurMaxPerSide = MAXPERSIDEWIDE;
	else
	    CurMaxPerSide = MAXPERSIDE;

	bOwnerDrawn = false;

	Padding = 0.025 * C.SizeX;

	C.Style = 5;
	C.SetDrawColor(0,0,0,128);
	C.SetPos(0.0,0.0);
	C.DrawRect(Texture'WhiteSquareTexture',C.ClipX,C.ClipY);

	C.SetPos(0.0,CalcY(0.5,C));
	C.SetDrawColor(255,255,255,255);
	C.DrawTile(HeaderImage,C.ClipX,CalcY(1,C),0.0,0.0,2048.0,64.0);

	C.SetDrawColor(0,0,0,255);
	C.Font = Class<ROHud>(HudClass).static.GetLargeMenuFont(C);
	C.DrawTextJustified(TitleText,1,0.0,0.0,C.ClipX,CalcY(2,C));
	C.DrawColor = HudClass.Default.WhiteColor;
	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);

	C.TextSize("Text",XL,YL);
	cellHeight = YL + (YL * 0.25);

	for (i = 0; i < 4; i++)
		AvgPing[i] = 0;

	for(i = 0; i < GRI.PRIArray.Length; i++)
	{
		PRI = ROPlayerReplicationInfo(GRI.PRIArray[i]);
		if( PRI != none )
		{
			if ( PRI.bOnlySpectator || PRI.RoleInfo == none )
				UnassignedPRI[UnassignedCount++] = PRI;
			else
			{
				if ( PRI.Team != None )
				{
					switch( PRI.Team.TeamIndex )
					{
						case 0:
							GermanPRI[GECount++] = PRI;
							break;
						case 1:
							RussianPRI[RUCount++] = PRI;
							break;
						case 2:
							UnassignedPRI[UnassignedCount++] = PRI;
					}
					AvgPing[PRI.Team.TeamIndex] += 4 * PRI.Ping;  // because this is how it is done in ROTeamGame DRR
				}
			}
		}
	}

  	for (i = 0; i < ArrayCount(ROGameReplicationInfo(GRI).Objectives); i++)
	{
		if (ROGameReplicationInfo(GRI).Objectives[i] == None)
			continue;

		// Count up the objective types
		if (ROGameReplicationInfo(GRI).Objectives[i].ObjState == OBJ_Axis)
		{
			if( ROGameReplicationInfo(GRI).Objectives[i].bRequired )
			{
				AxisReqObjCount++;
			}
			else
			{
				bRequiredObjectives=true;
				Axis2ndObjCount++;
			}
		}
		else if (ROGameReplicationInfo(GRI).Objectives[i].ObjState == OBJ_Allies)
		{
			if( ROGameReplicationInfo(GRI).Objectives[i].bRequired )
			{
				AlliesReqObjCount++;
			}
			else
			{
			    bRequiredObjectives=true;
				Allies2ndObjCount++;
			}
		}
	}

	if( RUCount > 0 )
		AvgPing[1] /= RUCount;
	else
		AvgPing[1] = 0;

	if( GECount > 0 )
		AvgPing[0] /= GECount;
	else
		AvgPing[0] = 0;

	if( bAlphaSortScoreBoard )
	{
		for( i=0; i<GECount-1; i++ )
			for( j=i+1; j<GECount; j++ )
				if( GermanPRI[i].PlayerName > GermanPRI[j].PlayerName )
				{
					PRI = GermanPRI[i];
					GermanPRI[i] = GermanPRI[j];
					GermanPRI[j] = PRI;
				}

		for( i=0; i<RUCount-1; i++ )
			for( j=i+1; j<RUCount; j++ )
				if( RussianPRI[i].PlayerName > RussianPRI[j].PlayerName )
				{
					PRI = RussianPRI[i];
					RussianPRI[i] = RussianPRI[j];
					RussianPRI[j] = PRI;
				}
	}

	// Draw the round timer
	if (ROGameReplicationInfo(GRI) != None)
	{
		// Update round timer
		if (!ROGameReplicationInfo(GRI).bMatchHasBegun)
			CurrentTime = ROGameReplicationInfo(GRI).RoundStartTime + ROGameReplicationInfo(GRI).PreStartTime - GRI.ElapsedTime;
		else
			CurrentTime = ROGameReplicationInfo(GRI).RoundStartTime + ROGameReplicationInfo(GRI).RoundDuration - GRI.ElapsedTime;

		S = Class<ROHud>(HudClass).default.TimeRemainingText $ Class<ROHud>(HudClass).static.GetTimeString(CurrentTime);

		if (ROGameReplicationInfo(GRI).bShowServerIPOnScoreboard && PlayerController(Owner) != None)
		    S $= Class<ROHud>(HudClass).default.SpacingText $ Class<ROHud>(HudClass).default.IPText $ PlayerController(Owner).GetServerIP();

        if (ROGameReplicationInfo(GRI).bShowTimeOnScoreboard)
		    S $= Class<ROHud>(HudClass).default.SpacingText $ Class<ROHud>(HudClass).default.TimeText $ Level.Hour$":"$Level.Minute @ " on " @ Level.Month$"/"$Level.Day$"/"$Level.Year;

		X = CalcX(BaseGermanX,C);
		Y = CalcY(2,C);

		C.DrawColor = HudClass.Default.WhiteColor;
		C.SetPos(X, Y);
		C.DrawTextClipped(S);
	}

	// Draw German data
	X = CalcX(BaseGermanX,C);
	Y = CalcY(2,C);
	Y += cellHeight;
	TeamColor = TeamColors[0];
	DrawCell(C,TeamNameAxis$" - "$ROGameReplicationInfo(GRI).UnitName[0],0,X,Y,CalcX(13.5,C),cellHeight,false,TeamColor);

	Y += cellHeight;
	DrawCell(C,ReinforcementsText $ " : " $ string(ROGameReplicationInfo(GRI).SpawnCount[0]) $ "%",0,X,Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	if( GRI.RoundLimit != 0 )
		DrawCell(C,RoundsWonText $ " : " $ string(int(GRI.Teams[0].Score))$"/"$string(GRI.RoundLimit),0,CalcX(BaseGermanX + 7,C),Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	else
		DrawCell(C,RoundsWonText $ " : " $ string(int(GRI.Teams[0].Score)),0,CalcX(BaseGermanX + 7,C),Y,CalcX(13.5,C),cellHeight,false,TeamColor);

	Y += cellHeight;
	if( bRequiredObjectives )
	{
		DrawCell(C,RequiredObjHeldText $ " : " $ string(AxisReqObjCount),0,X,Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	    DrawCell(C,SecondaryObjHeldText $ " : " $ string(Axis2ndObjCount),0,CalcX(BaseGermanX + 7,C),Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	}
	else
	{
		DrawCell(C,ObjectivesHeldText $ " : " $ string(AxisReqObjCount),0,X,Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	}

	Y += cellHeight;
	DrawCell(C,PlayerText $ " (" $ GECount $ ")",0,X,Y,CalcX(7,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);

	DrawCell(C,RoleText,0,CalcX(BaseGermanX + 7,C),Y,CalcX(4.0,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,ScoreText,1,CalcX(BaseGermanX + 11.0,C),Y,CalcX(1.5,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,PingText,1,CalcX(BaseGermanX + 12.5,C),Y,CalcX(1.5,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	Y += cellHeight;
	for( i = 0; i < GECount; i++ )
	{
		//If we're on the last available spot, the owner is on this team, and we haven't drawn the owner's score
		if ( i >= CurMaxPerSide - 1 && PlayerController(Owner).PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX && !bOwnerDrawn )
		{
		    //If this is not the owner, skip it
		    if ( GermanPRI[i] != PlayerController(Owner).PlayerReplicationInfo )
		        continue;
        }
		else if ( i >= CurMaxPerSide )
		    break;

		if ( GermanPRI[i] == PlayerController(Owner).PlayerReplicationInfo )
		{
			bHighlight = True;
            bOwnerDrawn = True;
        }
		else
			bHighlight = False;

		if ( GermanPRI[i].RoleInfo != None )
		{
			if( ROPlayer(Owner) != none && ROPlayer(Owner).bUseNativeRoleNames )
			{
	        	RoleName = GermanPRI[i].RoleInfo.Default.AltName;
	        }
	        else
	        {
	        	RoleName = GermanPRI[i].RoleInfo.Default.MyName;
	        }
		}
		else
			RoleName = "";

		// Draw name
		if( Level.NetMode != NM_Standalone && ROGameReplicationInfo(GRI).bPlayerMustReady )
		{
			if( GermanPRI[i].bReadyToPlay || GermanPRI[i].bBot )
			{
				if( GermanPRI[i].bAdmin )
				{
					// Draw Player name
					C.StrLen(GermanPRI[i].PlayerName$" "$AdminText, XL, YL);
					if( (XL/C.ClipX) > 0.21)
					{
			        	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
			        	DrawCell(C,GermanPRI[i].PlayerName$" "$AdminText,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,HudClass.Default.WhiteColor,HighLightColor);
			        	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);
			        }
			        else
			        {
						DrawCell(C,GermanPRI[i].PlayerName$" "$AdminText,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,HudClass.Default.WhiteColor,HighLightColor);
					}
				}
				else
				{
					DrawCell(C,GermanPRI[i].PlayerName,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,TeamColor,HighLightColor);
				}
			}
			else
			{
				if( GermanPRI[i].bAdmin )
				{
					// Draw Player name
					C.StrLen(GermanPRI[i].PlayerName$AdminWaitingText, XL, YL);
					if( (XL/C.ClipX) > 0.22)
					{
			        	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
			        	DrawCell(C,GermanPRI[i].PlayerName$AdminWaitingText,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,HUDClass.default.GrayColor,HighLightColor);
			        	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);
			        }
			        else
			        {
						DrawCell(C,GermanPRI[i].PlayerName$AdminWaitingText,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,HUDClass.default.GrayColor,HighLightColor);
					}
				}
				else
				{
					DrawCell(C,GermanPRI[i].PlayerName$WaitingText,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,HUDClass.default.GrayColor,HighLightColor);
				}
			}
		}
		else
		{
			if( GermanPRI[i].bAdmin )
			{
				// Draw Player name
				C.StrLen(GermanPRI[i].PlayerName$" "$AdminText, XL, YL);
				if( (XL/C.ClipX) > 0.21)
				{
		        	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
		        	DrawCell(C,GermanPRI[i].PlayerName$" "$AdminText,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,HudClass.Default.WhiteColor,HighLightColor);
		        	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);
		        }
		        else
		        {
					DrawCell(C,GermanPRI[i].PlayerName$" "$AdminText,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,HudClass.Default.WhiteColor,HighLightColor);
				}
			}
			else
			{
				DrawCell(C,GermanPRI[i].PlayerName,0,CalcX(BaseGermanX,C),Y,CalcX(7,C),cellHeight,bHighLight,TeamColor,HighLightColor);
			}
		}

		// Draw rolename
		C.StrLen(RoleName, XL, YL);
		if( (XL/C.ClipX) > 0.13)
		{
        	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
        	DrawCell(C,RoleName,0,CalcX(BaseGermanX + 7,C),Y,CalcX(4.0,C),cellHeight,bHighLight,TeamColor,HighLightColor);
        	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);
        }
        else
        {
			DrawCell(C,RoleName,0,CalcX(BaseGermanX + 7,C),Y,CalcX(4.0,C),cellHeight,bHighLight,TeamColor,HighLightColor);
		}

        AxisTotalScore += GermanPRI[i].Score;

		DrawCell(C,string(int(GermanPRI[i].Score)),1,CalcX(BaseGermanX + 11.0,C),Y,CalcX(1.5,C),cellHeight,bHighLight,TeamColor,HighLightColor);
		DrawCell(C,string(4 * GermanPRI[i].Ping),1,CalcX(BaseGermanX + 12.5,C),Y,CalcX(1.5,C),cellHeight,bHighLight,TeamColor,HighLightColor);
		Y += cellHeight;
		if( Y + cellHeight > C.ClipY )
			break;
	}

	Y += cellHeight;

    DrawCell(C,TotalsText$" : ",0,CalcX(BaseGermanX,C),Y,CalcX(11,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,string(AxisTotalScore),1,CalcX(BaseGermanX + 11.0,C),Y,CalcX(1.5,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,string(AvgPing[0]),1,CalcX(BaseGermanX + 12.5,C),Y,CalcX(1.5,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);

	LeftY = Y;

	// Draw Russian data
	X = CalcX(BaseRussianX,C);
	Y = CalcY(2,C);
	TeamColor = TeamColors[1];
	Y += cellHeight;
	DrawCell(C,TeamNameAllies$" - "$ROGameReplicationInfo(GRI).UnitName[1],0,X,Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	Y += cellHeight;

	DrawCell(C,ReinforcementsText $ " : " $ string(ROGameReplicationInfo(GRI).SpawnCount[1]) $ "%",0,X,Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	if( GRI.RoundLimit != 0 )
		DrawCell(C,RoundsWonText $ " : " $ string(int(GRI.Teams[1].Score))$"/"$string(GRI.RoundLimit),0,CalcX(BaseRussianX + 7,C),Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	else
		DrawCell(C,RoundsWonText $ " : " $ string(int(GRI.Teams[1].Score)),0,CalcX(BaseRussianX + 7,C),Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	Y += cellHeight;

	if( bRequiredObjectives )
	{
		DrawCell(C,RequiredObjHeldText $ " : " $ string(AlliesReqObjCount),0,X,Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	    DrawCell(C,SecondaryObjHeldText $ " : " $ string(Allies2ndObjCount),0,CalcX(BaseRussianX + 7,C),Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	}
	else
	{
		DrawCell(C,ObjectivesHeldText $ " : " $ string(AlliesReqObjCount),0,X,Y,CalcX(13.5,C),cellHeight,false,TeamColor);
	}
	Y += cellHeight;

	DrawCell(C,PlayerText $ " (" $ RUCount $ ")",0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,RoleText,0,CalcX(BaseRussianX + 7,C),Y,CalcX(4.0,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,ScoreText,1,CalcX(BaseRussianX + 11.0,C),Y,CalcX(1.5,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,PingText,1,CalcX(BaseRussianX + 12.5,C),Y,CalcX(1.5,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	Y += cellHeight;
	for( i = 0; i < RUCount; i++ )
	{
		//If we're on the last available spot, the owner is on this team, and we haven't drawn the owner's score
		if ( i >= CurMaxPerSide - 1 && PlayerController(Owner).PlayerReplicationInfo.Team.TeamIndex == ALLIES_TEAM_INDEX && !bOwnerDrawn )
		{
		    //If this is not the owner, skip it
		    if ( RussianPRI[i] != PlayerController(Owner).PlayerReplicationInfo )
		        continue;
        }
		else if ( i >= CurMaxPerSide )
		    break;

		if ( RussianPRI[i] == PlayerController(Owner).PlayerReplicationInfo )
		{
			bHighlight = True;
            bOwnerDrawn = True;
        }
		else
			bHighlight = False;

		if ( RussianPRI[i].RoleInfo != None )
		{
			if( ROPlayer(Owner) != none && ROPlayer(Owner).bUseNativeRoleNames )
			{
	        	RoleName = RussianPRI[i].RoleInfo.Default.AltName;
	        }
	        else
	        {
	        	RoleName = RussianPRI[i].RoleInfo.Default.MyName;
	        }
		}
		else
			RoleName = "";

		// Draw name
		if( Level.NetMode != NM_Standalone && ROGameReplicationInfo(GRI).bPlayerMustReady )
		{
			if( RussianPRI[i].bReadyToPlay || RussianPRI[i].bBot)
			{
				if( RussianPRI[i].bAdmin )
				{
					// Draw rolename
					C.StrLen(RussianPRI[i].PlayerName$" "$AdminText, XL, YL);
					if( (XL/C.ClipX) > 0.21)
					{
			        	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
			        	DrawCell(C,RussianPRI[i].PlayerName$" "$AdminText,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,HudClass.Default.WhiteColor,HighLightColor);
			        	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);
			        }
			        else
			        {
						DrawCell(C,RussianPRI[i].PlayerName$" "$AdminText,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,HudClass.Default.WhiteColor,HighLightColor);
					}
				}
				else
				{
					DrawCell(C,RussianPRI[i].PlayerName,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,TeamColor,HighLightColor);
				}
			}
			else
			{
				if( RussianPRI[i].bAdmin )
				{
					// Draw Player name
					C.StrLen(RussianPRI[i].PlayerName$AdminWaitingText, XL, YL);
					if( (XL/C.ClipX) > 0.22)
					{
			        	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
			        	DrawCell(C,RussianPRI[i].PlayerName$AdminWaitingText,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,HUDClass.default.GrayColor,HighLightColor);
			        	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);
			        }
			        else
			        {
						DrawCell(C,RussianPRI[i].PlayerName$AdminWaitingText,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,HUDClass.default.GrayColor,HighLightColor);
					}
				}
				else
				{
					DrawCell(C,RussianPRI[i].PlayerName$WaitingText,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,HUDClass.default.GrayColor,HighLightColor);
				}
			}
		}
		else
		{
			if( RussianPRI[i].bAdmin )
			{
				// Draw rolename
				C.StrLen(RussianPRI[i].PlayerName$" "$AdminText, XL, YL);
				if( (XL/C.ClipX) > 0.21)
				{
		        	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
		        	DrawCell(C,RussianPRI[i].PlayerName$" "$AdminText,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,HudClass.Default.WhiteColor,HighLightColor);
		        	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);
		        }
		        else
		        {
					DrawCell(C,RussianPRI[i].PlayerName$" "$AdminText,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,HudClass.Default.WhiteColor,HighLightColor);
				}
			}
			else
			{
				DrawCell(C,RussianPRI[i].PlayerName,0,CalcX(BaseRussianX,C),Y,CalcX(7,C),cellHeight,bHighLight,TeamColor,HighLightColor);
			}
		}

		// Draw rolename
		C.StrLen(RoleName, XL, YL);
		if( (XL/C.ClipX) > 0.13)
		{
        	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
        	DrawCell(C,RoleName,0,CalcX(BaseRussianX + 7,C),Y,CalcX(4.0,C),cellHeight,bHighLight,TeamColor,HighLightColor);
        	C.Font = Class<ROHud>(HudClass).static.GetSmallMenuFont(C);
        }
        else
        {
			DrawCell(C,RoleName,0,CalcX(BaseRussianX + 7,C),Y,CalcX(4.0,C),cellHeight,bHighLight,TeamColor,HighLightColor);
		}

        AlliesTotalScore += RussianPRI[i].Score;

        DrawCell(C,string(int(RussianPRI[i].Score)),1,CalcX(BaseRussianX + 11.0,C),Y,CalcX(1.5,C),cellHeight,bHighLight,TeamColor,HighLightColor);
		DrawCell(C,string(4 * RussianPRI[i].Ping),1,CalcX(BaseRussianX + 12.5,C),Y,CalcX(1.5,C),cellHeight,bHighLight,TeamColor,HighLightColor);
		Y += cellHeight;
		if( Y + cellHeight > C.ClipY )
			break;
	}

	Y += cellHeight;

    DrawCell(C,TotalsText$" : ",0,CalcX(BaseRussianX,C),Y,CalcX(11,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,string(AlliesTotalScore),1,CalcX(BaseRussianX + 11.0,C),Y,CalcX(1.5,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);
	DrawCell(C,string(AvgPing[1]),1,CalcX(BaseRussianX + 12.5,C),Y,CalcX(1.5,C),cellHeight,True,HudClass.Default.WhiteColor,TeamColor);

	RightY = Y;

	if( LeftY <= RightY )
		Y = RightY;
	else
		Y = LeftY;

	Y += cellHeight + 3;//Add some extra spacing above the spectators

	if( Y + cellHeight > C.ClipY )
		return;

   	C.Font = Class<ROHud>(HudClass).static.GetSmallerMenuFont(C);
	C.TextSize("Text",XL,YL);
	cellHeight = YL + (YL * 0.05);
	S = SpectatorTeamName $ " & " $ UnassignedTeamName $ " (" $ UnassignedCount $ ") : ";
	for( i = 0; i < UnassignedCount; i++ )
	{
		C.TextSize(S $ "," $ UnassignedPRI[i].PlayerName,XL,YL);
		if( CalcX(1,C) + XL > C.ClipX )
		{
			DrawCell(C,S,0,CalcX(BaseGermanX,C),Y,CalcX(29,C),cellHeight,False,HudClass.Default.WhiteColor);
			S = "";
			Y = Y + cellHeight;
			if( Y + cellHeight > C.ClipY )
				return;
		}

		if( i < UnassignedCount - 1 )
			S = S $ UnassignedPRI[i].PlayerName $ ",";
		else
		{
			S = S $ UnassignedPRI[i].PlayerName;
			DrawCell(C,S,0,CalcX(BaseGermanX,C),Y,CalcX(29,C),cellHeight,false,HudClass.Default.WhiteColor);
		}
	}
}

//-----------------------------------------------------------------------------
// DrawHeaders - Draws the titles for the columns
//-----------------------------------------------------------------------------

simulated function float DrawHeaders(Canvas C)
{
	local float X, Y, XL, YL;

	X = 0.05 * C.ClipX + Padding;
	Y = 0.10 * C.ClipY;

	C.SetPos(X, Y);
	C.DrawTextClipped(NameText);
	X += NameLength * C.ClipX;
	X += TeamScoreLength * C.ClipX;

	C.SetPos(X, Y);
	C.DrawTextClipped(RoleText);
	X += RoleLength * C.ClipX;

	C.SetPos(X, Y);
	C.DrawTextClipped(ScoreText);
	X += ScoreLength * C.ClipX;

	C.SetPos(X, Y);
	C.DrawTextClipped(TimeText);
	X += TimeLength * C.ClipX;

	C.SetPos(X, Y);
	C.DrawTextClipped(PingText);

	C.TextSize("Text", XL, YL);

	return Y + YL + Padding;
}

//-----------------------------------------------------------------------------
// DrawTeam - Draws the team bar and all players for a given team
//-----------------------------------------------------------------------------

simulated function float DrawTeam(Canvas C, int TeamNum, float YPos, int PlayerCount)
{
	local int i;
	local float X, Y, XL, YL, CellHeight;
	local color TeamColor;
	local string T, P;
	local bool bHighlight;

	X = 0.05 * C.ClipX;
	Y = YPos;

	C.TextSize("Text", XL, YL);
	CellHeight = YL + 4 * Padding;

	TeamColor = TeamColors[TeamNum];

	// Draw team name
	if (PlayerCount == 1)
		P = PlayerText;
	else
		P = PlayerPluralText;

	if (TeamNum == NEUTRAL_TEAM_INDEX)
		T = UnassignedTeamName $ " (" $ PlayerCount @ P $ ") ";
	else if (TeamNum == SPECTATOR)
		T = SpectatorTeamName $ " (" $ PlayerCount @ P $ ") ";
	else
		T = ROGameReplicationInfo(GRI).UnitName[TeamNum] $ " (" $ PlayerCount @ P $ ") ";

	DrawCell(C, T, 0, X, Y, NameLength * C.ClipX, CellHeight, true, HUDClass.default.WhiteColor, TeamColor);
	X += NameLength * C.ClipX;

	// Draw reinforcements
	if (TeamNum == NEUTRAL_TEAM_INDEX || TeamNum == SPECTATOR)
		T = "";
	else
		T = ROGameReplicationInfo(GRI).SpawnCount[TeamNum] $ "%";

	DrawCell(C, T, 1, X, Y, TeamScoreLength * C.ClipX, CellHeight, true, HUDClass.default.WhiteColor, TeamColor);
	X += TeamScoreLength * C.ClipX;

	// Draw nothing for the role cell
	DrawCell(C, "", 0, X, Y, RoleLength * C.ClipX, CellHeight, true, HUDClass.default.WhiteColor, TeamColor);
	X += RoleLength * C.ClipX;

	// Draw team score
	if (TeamNum == NEUTRAL_TEAM_INDEX || TeamNum == SPECTATOR)
		T = "";
	else
		T = string(int(GRI.Teams[TeamNum].Score));

	DrawCell(C, T, 1, X, Y, ScoreLength * C.ClipX, CellHeight, true, HUDClass.default.WhiteColor, TeamColor);
	X += ScoreLength * C.ClipX;

	// Draw nothing for the time cell
	DrawCell(C, "", 0, X, Y, TimeLength * C.ClipX, CellHeight, true, HUDClass.default.WhiteColor, TeamColor);
	X += TimeLength * C.ClipX;

	// Draw average ping
	DrawCell(C, AvgPing[TeamNum], 1, X, Y, PingLength * C.ClipX, CellHeight, true, HUDClass.default.WhiteColor, TeamColor);

	Y += CellHeight;

	for (i = 0; i < Min(PlayerCount, ArrayCount(PRIArray)); i++)
	{
		// Make sure there's enough room to draw this row
		if (Y + CellHeight > C.ClipY)
			break;

		if (PRIArray[i].bIsSpectator || PRIArray[i].bWaitingPlayer)
			TeamColor = HUDClass.default.GrayColor;
		else
			TeamColor = TeamColors[TeamNum];

		if (PRIArray[i] == PlayerController(Owner).PlayerReplicationInfo)
			bHighlight = true;
		else
			bHighlight = false;


		X = 0.05 * C.ClipX;

		// Draw name
		if( ROGameReplicationInfo(GRI).bPlayerMustReady )
		{
			if( PRIArray[i].bReadyToPlay )
				DrawCell(C, PRIArray[i].PlayerName, 0, X, Y, NameLength * C.ClipX, CellHeight, bHighlight, TeamColor, HighlightColor);
			else
				DrawCell(C, PRIArray[i].PlayerName$" --Waiting--", 0, X, Y, NameLength * C.ClipX, CellHeight, bHighlight, TeamColor, HighlightColor);
			X += NameLength * C.ClipX;
		}
		else
		{
			DrawCell(C, PRIArray[i].PlayerName, 0, X, Y, NameLength * C.ClipX, CellHeight, bHighlight, TeamColor, HighlightColor);
			X += NameLength * C.ClipX;
		}

		// Draw admin text
		if (PRIArray[i].bAdmin)
			T = AdminText;
		else
			T = "";

		DrawCell(C, T, 0, X, Y, TeamScoreLength * C.ClipX, CellHeight, bHighlight, TeamColor, HighlightColor);
		X += TeamScoreLength * C.ClipX;

		// Draw role
		if (PRIArray[i].RoleInfo != None)
		{
			if( ROPlayer(Owner) != none && ROPlayer(Owner).bUseNativeRoleNames )
			{
	        	T = PRIArray[i].RoleInfo.default.AltName;
	        }
	        else
	        {
	        	T = PRIArray[i].RoleInfo.default.MyName;
	        }
		}
		else
			T = "";

		DrawCell(C, T, 0, X, Y, RoleLength * C.ClipX, CellHeight, bHighlight, TeamColor, HighlightColor);
		X += RoleLength * C.ClipX;

		// Draw score
		DrawCell(C, int(PRIArray[i].Score), 1, X, Y, ScoreLength * C.ClipX, CellHeight, bHighlight, TeamColor, HighlightColor);
		X += ScoreLength * C.ClipX;

		// Draw time
		DrawCell(C, FormatTime(GRI.ElapsedTime - PRIArray[i].StartTime), 1, X, Y, TimeLength * C.ClipX, CellHeight, bHighlight, TeamColor, HighlightColor);
		X += TimeLength * C.ClipX;

		// Draw ping
		DrawCell(C, 4 * PRIArray[i].Ping, 1, X, Y, PingLength * C.ClipX, CellHeight, bHighlight, TeamColor, HighlightColor); // 4 * ping because thats they way it is in ROTeamGame

		Y += CellHeight;
	}

	return Y;
}

// This is a modified version based of of Crube's BFE scoreboard mutator
simulated function DrawCell(Canvas C, coerce string Text, byte Align, float XPos, float YPos, float Width, float Height, bool bDrawBacking, Color F, optional Color B)
{
	local float X;
	local float Y;
	local float XL;
	local float YL;

	X = XPos;
	Y = YPos;
	C.TextSize("TEST",XL,YL);
	C.SetOrigin(X,Y);
	C.SetClip(XPos + Width,YPos + Height);
	if ( bDrawBacking )
	{
		C.SetPos(0.0,0.0);
		C.DrawColor = B;
		C.DrawRect(Texture'WhiteSquareTexture',C.ClipX - C.OrgX,C.ClipY - C.OrgY);
	}
	if ( Text != "" )
	{
		C.SetPos(0,0);
		C.DrawColor = F;
		C.DrawTextJustified(Text,Align,X,Y,C.ClipX,C.ClipY);
	}
	C.SetOrigin(0.0,0.0);
	C.SetClip(C.SizeX,C.SizeY);
}

simulated function float CalcX(float X, Canvas C)
{
	return X * C.SizeX / 30;
}

simulated function float CalcY(float Y, Canvas C)
{
	return Y * C.SizeY / 22;
}
//-----------------------------------------------------------------------------
// InOrder - Sorts the PRIs appropriately
//-----------------------------------------------------------------------------

simulated function bool InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
	if( P1.bOnlySpectator )
	{
		if( P2.bOnlySpectator )
			return true;
		else
			return false;
	}
	else if ( P2.bOnlySpectator )
		return true;

	if( P1.Score < P2.Score )
		return false;

	if( P1.Score == P2.Score )
	{
		// Don't worry about deaths, just sort by name if scores are even
		if (P1.PlayerName < P2.PlayerName)
			return false;

		/*if ( P1.Deaths > P2.Deaths )
			return false;
		if ( (P1.Deaths == P2.Deaths) && (PlayerController(P2.Owner) != None) && (Viewport(PlayerController(P2.Owner).Player) != None) )
			return false;*/
	}
	return true;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     HeaderImage=Texture'InterfaceArt_tex.HUD.RO_Headerbar'
     SpectatorTeamName="Spectators"
     UnassignedTeamName="Unassigned"
     TitleText="SCORES"
     NameText="Name"
     AdminText="Admin"
     RoleText="Role"
     ScoreText="Score"
     TimeText="Time"
     PingText="Ping"
     PlayerText="Player"
     PlayerPluralText="Players"
     TotalsText="Team Totals"
     ObjectivesHeldText="Objectives Held"
     RequiredObjHeldText="Required Objectives Held"
     SecondaryObjHeldText="Secondary Objectives Held"
     RoundsWonText="Rounds Won"
     TeamNameAllies="Allies"
     TeamNameAxis="Axis"
     NameLength=0.300000
     TeamScoreLength=0.100000
     RoleLength=0.200000
     ScoreLength=0.100000
     TimeLength=0.100000
     PingLength=0.100000
     TeamColors(0)=(B=128,G=128,R=64,A=255)
     TeamColors(1)=(B=64,G=64,R=192,A=255)
     TeamColors(2)=(B=32,G=32,R=32,A=255)
     TeamColors(3)=(B=128,G=128,R=128,A=255)
     HighlightColor=(B=128,G=128,R=128,A=64)
     ReinforcementsText="Reinforcements"
     WaitingText=" -Not Ready-"
     AdminWaitingText=" -Admin Hold-"
     HudClass=Class'ROEngine.ROHud'
}
