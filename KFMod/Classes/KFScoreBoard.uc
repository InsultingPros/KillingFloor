class KFScoreBoard extends ScoreBoardDeathMatch;

var 	localized 	string 		TeamScoreString;
var 	localized 	string 		WaveString;
var() 	localized 	string	  	HealthText, KillsText;
var 				bool 		bDisplayWithKills;
var 	localized 	string 		HealthyString;
var 	localized 	string 		InjuredString;
var 	localized 	string 		CriticalString;
var     localized   string      WeaponHeaderText;
var     localized   string      AssistsHeaderText;

function DrawTitle(Canvas Canvas, float HeaderOffsetY, float PlayerAreaY, float PlayerBoxSizeY)
{
	local string TitleString, ScoreInfoString, RestartString;
	local float TitleXL, ScoreInfoXL, YL, TitleY, TitleYL;

	TitleString = SkillLevel[Clamp(InvasionGameReplicationInfo(GRI).BaseDifficulty, 0, 7)] @ "|" @ WaveString @ (InvasionGameReplicationInfo(GRI).WaveNumber + 1) @ "|" @ Level.Title;

	Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);

	Canvas.StrLen(TitleString, TitleXL, TitleYL);

	if ( GRI.TimeLimit != 0 )
	{
		ScoreInfoString = TimeLimit $ FormatTime(GRI.RemainingTime);
	}
	else
	{
		ScoreInfoString = FooterText @ FormatTime(GRI.ElapsedTime);
	}

	Canvas.DrawColor = HUDClass.default.RedColor;

	if ( UnrealPlayer(Owner).bDisplayLoser )
	{
		ScoreInfoString = class'HUDBase'.default.YouveLostTheMatch;
	}
	else if ( UnrealPlayer(Owner).bDisplayWinner )
	{
		ScoreInfoString = class'HUDBase'.default.YouveWonTheMatch;
	}
	else if ( PlayerController(Owner).IsDead() )
	{
		RestartString = Restart;

		if ( PlayerController(Owner).PlayerReplicationInfo.bOutOfLives )
		{
			RestartString = OutFireText;
		}

		ScoreInfoString = RestartString;
	}

	TitleY = Canvas.ClipY * 0.13;
	Canvas.SetPos(0.5 * (Canvas.ClipX - TitleXL), TitleY);
	Canvas.DrawText(TitleString);

	Canvas.StrLen(ScoreInfoString, ScoreInfoXL, YL);
	Canvas.SetPos(0.5 * (Canvas.ClipX - ScoreInfoXL), TitleY + TitleYL);
	Canvas.DrawText(ScoreInfoString);
}

simulated event UpdateScoreBoard(Canvas Canvas)
{
	local PlayerReplicationInfo PRI, OwnerPRI;
	local int i,j, FontReduction, NetXPos, PlayerCount, HeaderOffsetY, HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, OwnerOffset, HealthXPos, BoxXPos,KillsXPos, TitleYPos, BoxWidth, VetXPos, TempVetXPos, VetYPos;
	local float XL,YL, MaxScaling;
	local float deathsXL, KillsXL, netXL,HealthXL, MaxNamePos, KillWidthX, HealthWidthX, TimeXL, TimeWidthX, TimeXPos, ScoreXPos, ScoreXL;
	local bool bNameFontReduction;
	local Material VeterancyBox, StarMaterial;
	local int TempLevel, TempY;
	local string PlayerTime;
	local KFPlayerReplicationInfo KFPRI;
	local float AssistsXPos,AssistsWidthX;
	local float CashX;
	local string CashString,HealthString;
	local float OutX;
	local array<PlayerReplicationInfo> TeamPRIArray;

	OwnerPRI = KFPlayerController(Owner).PlayerReplicationInfo;
	OwnerOffset = -1;

	for (i = 0; i < GRI.PRIArray.Length; i++)
	{
		PRI = GRI.PRIArray[i];

		if ( !PRI.bOnlySpectator )
		{
			if ( PRI == OwnerPRI )
				OwnerOffset = i;

			PlayerCount++;
			TeamPRIArray[ TeamPRIArray.Length ] = PRI;
		}
	}

	PlayerCount = Min(PlayerCount, MAXPLAYERS);

	Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);
	Canvas.StrLen("Test", XL, YL);
	BoxSpaceY = 0.25 * YL;
	PlayerBoxSizeY = 1.2 * YL;
	HeadFoot = 7 * YL;
	MessageFoot = 1.5 * HeadFoot;

	if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) )
	{
		BoxSpaceY = 0.125 * YL;
		PlayerBoxSizeY = 1.25 * YL;

		if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) )
		{
			if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) )
			{
				PlayerBoxSizeY = 1.125 * YL;
			}
		}
	}

	if (Canvas.ClipX < 512)
		PlayerCount = Min(PlayerCount, 1+(Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) );
	else
		PlayerCount = Min(PlayerCount, (Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) );

	if (FontReduction > 2)
		MaxScaling = 3;
	else
		MaxScaling = 2.125;

	PlayerBoxSizeY = FClamp((1.25 + (Canvas.ClipY - 0.67 * MessageFoot)) / PlayerCount - BoxSpaceY, PlayerBoxSizeY, MaxScaling * YL);

	bDisplayMessages = (PlayerCount <= (Canvas.ClipY - MessageFoot) / (PlayerBoxSizeY + BoxSpaceY));

	HeaderOffsetY = 10 * YL;
	BoxWidth = 0.7 * Canvas.ClipX;
	BoxXPos = 0.5 * (Canvas.ClipX - BoxWidth);
	BoxWidth = Canvas.ClipX - 2 * BoxXPos;
	VetXPos = BoxXPos + 0.00005 * BoxWidth;
	NameXPos = BoxXPos + 0.075 * BoxWidth;
	KillsXPos = BoxXPos + 0.50 * BoxWidth;
	AssistsXPos = BoxXPos + 0.60 * BoxWidth;
	HealthXpos = BoxXPos + 0.70 * BoxWidth;
	ScoreXPos = BoxXPos + 0.80 * BoxWidth;
	NetXPos = BoxXPos + 0.95 * BoxWidth;


	// Draw background boxes
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.DrawColor.A = 128;

	for (i = 0; i < PlayerCount; i++)
	{
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY) * i);
		Canvas.DrawTileStretched(BoxMaterial, BoxWidth, PlayerBoxSizeY);
	}

	// Draw title
	Canvas.Style = ERenderStyle.STY_Normal;
	DrawTitle(Canvas, HeaderOffsetY, (PlayerCount + 1) * (PlayerBoxSizeY + BoxSpaceY), PlayerBoxSizeY);

	// Draw headers
	TitleYPos = HeaderOffsetY - 1.1 * YL;
	Canvas.StrLen(HealthText, HealthXL, YL);
	Canvas.StrLen(DeathsText, DeathsXL, YL);
	Canvas.StrLen(KillsText, KillsXL, YL);
	Canvas.StrLen(PointsText, ScoreXL, YL);
	Canvas.StrLen(AssistsHeaderText, TimeXL, YL);

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(NameXPos, TitleYPos);
	Canvas.DrawText(PlayerText,true);

	Canvas.SetPos(KillsXPos - 0.5 * KillsXL, TitleYPos);
	Canvas.DrawText(KillsText,true);

	Canvas.SetPos(ScoreXPos - 0.5 * ScoreXL, TitleYPos);
	Canvas.DrawText(PointsText,true);

	Canvas.SetPos(AssistsXPos - 0.5 * TimeXL, TitleYPos);
	Canvas.DrawText(AssistsHeaderText,true);

	Canvas.SetPos(HealthXPos - 0.5 * HealthXL, TitleYPos);
	Canvas.DrawText(HealthText,true);

	// Draw player names
	MaxNamePos = 0.9 * (KillsXPos - NameXPos);
	for (i = 0; i < PlayerCount; i++)
	{
		Canvas.StrLen(TeamPRIArray[i].PlayerName, XL, YL);

		if ( XL > MaxNamePos )
		{
			bNameFontReduction = true;
			break;
		}
	}

	if ( bNameFontReduction )
		Canvas.Font = GetSmallerFontFor(Canvas, FontReduction - 1);

	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);
	BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	MaxNamePos = Canvas.ClipX;
	Canvas.ClipX = KillsXPos - 4.f;

	for (i = 0; i < PlayerCount; i++)
	{
		Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);

		if( i == OwnerOffset )
		{
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;
		}
		else
		{
			Canvas.DrawColor.G = 255;
			Canvas.DrawColor.B = 255;
		}

		Canvas.DrawTextClipped(TeamPRIArray[i].PlayerName);
	}

	Canvas.ClipX = MaxNamePos;
	Canvas.DrawColor = HUDClass.default.WhiteColor;

	if (bNameFontReduction)
		Canvas.Font = GetSmallerFontFor(Canvas, FontReduction);

	Canvas.Style = ERenderStyle.STY_Normal;
	MaxScaling = FMax(PlayerBoxSizeY, 30.f);

	// Draw each player's information
	for (i = 0; i < PlayerCount; i++)
	{
        KFPRI = KFPlayerReplicationInfo(TeamPRIArray[i]) ;
		Canvas.DrawColor = HUDClass.default.WhiteColor;

		// Display perks.
		if ( KFPRI!=None && KFPRI.ClientVeteranSkill != none )
		{
			if(KFPRI.ClientVeteranSkillLevel == 6)
			{
				VeterancyBox = KFPRI.ClientVeteranSkill.default.OnHUDGoldIcon;
                StarMaterial = class'HUDKillingFloor'.default.VetStarGoldMaterial;
				TempLevel = KFPRI.ClientVeteranSkillLevel - 5;
			}
			else
			{
				VeterancyBox = KFPRI.ClientVeteranSkill.default.OnHUDIcon;
				StarMaterial = class'HUDKillingFloor'.default.VetStarMaterial;
				TempLevel = KFPRI.ClientVeteranSkillLevel;
			}

			if ( VeterancyBox != None )
			{
				TempVetXPos = VetXPos;
				VetYPos = (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY - PlayerBoxSizeY * 0.22;
				Canvas.SetPos(TempVetXPos, VetYPos);
				Canvas.DrawTile(VeterancyBox, PlayerBoxSizeY, PlayerBoxSizeY, 0, 0, VeterancyBox.MaterialUSize(), VeterancyBox.MaterialVSize());

				if(StarMaterial != none)
				{
					TempVetXPos += PlayerBoxSizeY - ((PlayerBoxSizeY/5) * 0.75);
					VetYPos += PlayerBoxSizeY - ((PlayerBoxSizeY/5) * 1.5);

					for ( j = 0; j < TempLevel; j++ )
					{
						Canvas.SetPos(TempVetXPos, VetYPos);
						Canvas.DrawTile(StarMaterial, (PlayerBoxSizeY/5) * 0.7, (PlayerBoxSizeY/5) * 0.7, 0, 0, StarMaterial.MaterialUSize(), StarMaterial.MaterialVSize());

						VetYPos -= (PlayerBoxSizeY/5) * 0.7;
					}
				}
			}
		}


		// draw kills
		if( bDisplayWithKills )
		{
			Canvas.StrLen(KFPRI.Kills, KillWidthX, YL);
			Canvas.SetPos(KillsXPos - 0.5 * KillWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
			Canvas.DrawText(KFPRI.Kills, true);

          // Draw Kill Assists

            Canvas.StrLen(KFPRI.KillAssists, AssistsWidthX, YL);
            Canvas.SetPos(AssistsXPos - 0.5 * AssistsWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
            Canvas.DrawText(KFPRI.KillAssists, true);
    	}
		// draw cash
		CashString = "£"@string(int(TeamPRIArray[i].Score)) ;

		if(TeamPRIArray[i].Score >= 1000)
		{
            CashString = "£"@string(TeamPRIArray[i].Score/1000.f)$"K" ;
		}

		Canvas.StrLen(CashString,CashX,YL);
		Canvas.SetPos(ScoreXPos - CashX/2 , (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		Canvas.DrawColor = Canvas.MakeColor(255,255,125,255);
        Canvas.DrawText(CashString);
		Canvas.DrawColor = HUDClass.default.WhiteColor;

		// Draw health status

		HealthString = KFPRI.PlayerHealth$" HP" ;
		Canvas.StrLen(HealthString,HealthWidthX,YL);
		Canvas.SetPos(HealthXpos - HealthWidthX/2, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);

		if ( TeamPRIArray[i].bOutOfLives )
		{
            Canvas.StrLen(OutText,OutX,YL);
			Canvas.DrawColor = HUDClass.default.RedColor;
            Canvas.SetPos(HealthXpos - OutX/2, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
			Canvas.DrawText(OutText);
		}
		else
		{
			if( KFPRI.PlayerHealth>=80 )
			{
				Canvas.DrawColor = HUDClass.default.GreenColor;
			}
			else if( KFPRI.PlayerHealth>=50 )
			{
				Canvas.DrawColor = HUDClass.default.GoldColor;
			}
			else
			{
				Canvas.DrawColor = HUDClass.default.RedColor;
			}

  			Canvas.DrawText(HealthString);
		}
	}

	if (Level.NetMode == NM_Standalone)
		return;

	Canvas.StrLen(NetText, NetXL, YL);
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(NetXPos - 0.5 * NetXL, TitleYPos);
	Canvas.DrawText(NetText,true);

	for (i=0; i<GRI.PRIArray.Length; i++)
		PRIArray[i] = GRI.PRIArray[i];

	DrawNetInfo(Canvas, FontReduction, HeaderOffsetY, PlayerBoxSizeY, BoxSpaceY, BoxTextOffsetY, OwnerOffset, PlayerCount, NetXPos);
	DrawMatchID(Canvas, FontReduction);
}


// Sort Scoreboard
// Kills >  Assists > Cash > PlayerName

simulated function bool InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
	local KFPlayerReplicationInfo P11,P22;

	P11 = KFPlayerReplicationInfo(P1);
	P22 = KFPlayerReplicationInfo(P2);

	if( P11==None || P22==None )
		return true;
	if( P1.bOnlySpectator )
	{
		if( P2.bOnlySpectator )
			return true;
		else return false;
	}
	else if ( P2.bOnlySpectator )
		return true;

	if( P11.Kills < P22.Kills )
		return false;
	else if( P11.Kills==P22.Kills )
	{
		// Kills is equal, go for assists.
		if( P11.KillAssists < P22.KillAssists )
		{
			return false;
		}
        else if( P11.KillAssists==P22.KillAssists )
		{
			if( P11.Score < P22.Score )
			{
                return false;
            }
            else if( P11.Score == P22.Score)
            {
               return (P1.PlayerName<P2.PlayerName); // Go for name.
            }
        }
	}
	return true;
}

function DrawNetInfo(Canvas Canvas,int FontReduction,int HeaderOffsetY,int PlayerBoxSizeY,int BoxSpaceY,int BoxTextOffsetY,int OwnerOffset,int PlayerCount, int NetXPos)
{
	local float XL,YL;
	local int i;
	local bool bHaveHalfFont, bDrawFPH, bDrawPL;
	local int PlayerPing;
	local float AdminX,AdminY;

	bDrawPL = false;
	bDrawFPH = false;
	bHaveHalfFont = false;

	// draw admins
	if ( GRI.bMatchHasBegun )
	{
		Canvas.DrawColor = HUDClass.default.RedColor;
        Canvas.StrLen(AdminText,AdminX,AdminY);

		for ( i = 0; i < PlayerCount; i++ )
			if ( PRIArray[i].bAdmin )
				{
					Canvas.SetPos(NetXPos - AdminX/2, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(AdminText);
				}
		if ( (OwnerOffset >= PlayerCount) && PRIArray[OwnerOffset].bAdmin )
		{
			Canvas.SetPos(NetXPos - AdminX/2, (PlayerBoxSizeY + BoxSpaceY) * PlayerCount + BoxTextOffsetY);
			Canvas.DrawText(AdminText);
		}
	}

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	//Canvas.Font = GetSmallFontFor(Canvas.ClipX, FontReduction);
	Canvas.StrLen("Test", XL, YL);
	BoxTextOffsetY = HeaderOffsetY + 0.5*PlayerBoxSizeY;
	//bHaveHalfFont = ( YL < 0.5 * PlayerBoxSizeY);

	// if game hasn't begun, draw ready or not ready
	if ( !GRI.bMatchHasBegun )
	{
		//bDrawPL = PlayerBoxSizeY > 3 * YL;
		for ( i=0;  i < PlayerCount; i++ )
		{
            PlayerPing = Min(999,4*PRIArray[i].Ping);
            Canvas.DrawColor = GetPingColor(PlayerPing);

			if ( bDrawPL )
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
				Canvas.DrawText(PingText@PlayerPing,true);
				Canvas.DrawColor = HUDClass.default.WhiteColor;

				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
				Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
			}
			else if ( bHaveHalfFont )
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
				Canvas.DrawText(PingText@PlayerPing,true);
				Canvas.DrawColor = HUDClass.default.WhiteColor;
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			}
			else
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
			if ( PRIArray[i].bReadyToPlay )
				Canvas.DrawText(ReadyText,true);
			else
				Canvas.DrawText(NotReadyText,true);
		}
		return;
	}

	// draw time and ping
	if ( Canvas.ClipX < 512 )
		PingText = "";
	else
	{
		PingText = Default.PingText;
		//bDrawFPH = PlayerBoxSizeY > 3 * YL;
		//bDrawPL = PlayerBoxSizeY > 4 * YL;
	}
	if ( ((FPHTime == 0) || (!UnrealPlayer(Owner).bDisplayLoser && !UnrealPlayer(Owner).bDisplayWinner))
		&& (GRI.ElapsedTime > 0) )
		FPHTime = GRI.ElapsedTime;

	for ( i = 0; i < PlayerCount; i++ )
		if ( !PRIArray[i].bAdmin && !PRIArray[i].bOutOfLives )
 			{
                PlayerPing = Min(999,4*PRIArray[i].Ping);
                Canvas.DrawColor = GetPingColor(PlayerPing);

 				if ( bDrawPL )
 				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.9 * YL);
					Canvas.DrawText(PingText@PlayerPing,true);
				    Canvas.DrawColor = HUDClass.default.WhiteColor;

					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.9 * YL);
					Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.1 * YL);
					Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 1.1 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
 				else if ( bDrawFPH )
 				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
					Canvas.DrawText(PingText@PlayerPing,true);
				    Canvas.DrawColor = HUDClass.default.WhiteColor;

					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
					Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
				else if ( bHaveHalfFont )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
					Canvas.DrawText(PingText@PlayerPing,true);
					Canvas.DrawColor = HUDClass.default.WhiteColor;

					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
				else
				{
					Canvas.StrLen(PlayerPing, XL, YL);
					Canvas.SetPos(NetXPos - 0.5 * xL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
					Canvas.DrawText(PlayerPing,true);
				}
			}
	if ( (OwnerOffset >= PlayerCount) && !PRIArray[OwnerOffset].bAdmin && !PRIArray[OwnerOffset].bOutOfLives )
	{
	    PlayerPing = Min(999,4*PRIArray[OwnerOffset].Ping);
        Canvas.DrawColor = GetPingColor(PlayerPing);

 		if ( bDrawFPH )
 		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
			Canvas.DrawText(PingText@PlayerPing,true);
			Canvas.DrawColor = HUDClass.default.WhiteColor;

			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
			Canvas.DrawText(FPH@Min(999,3600*PRIArray[OwnerOffset].Score/FMax(1,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
			Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
		}
		else if ( bHaveHalfFont )
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
			Canvas.DrawText(PingText@PlayerPing,true);
			Canvas.DrawColor = HUDClass.default.WhiteColor;

			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
		}
		else
		{
			Canvas.StrLen(PlayerPing, XL, YL);
			Canvas.SetPos(NetXPos - 0.5 * XL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
			Canvas.DrawText(PlayerPing, true);
		}
	}
}

/* Returns a color value for the supplied ping */
function Color GetPingColor( int Ping)
{
    if(Ping >= 200)
    {
        return 	HUDClass.default.RedColor;
    }
    else if( Ping >= 100)
    {
        return HUDClass.default.GoldColor;
    }
    else if( Ping < 100)
    {
        return HUDClass.default.GreenColor;
    }
}

defaultproperties
{
     TeamScoreString="Cash Bonus:"
     WaveString="Wave"
     HealthText="Status"
     KillsText="Kills"
     HealthyString="HEALTHY"
     InjuredString="INJURED"
     CriticalString="CRITICAL"
     WeaponHeaderText="Weapon"
     AssistsHeaderText="Assists"
     PointsText="Cash"
     PingText=
     NetText="PING"
     OutText="  DEAD"
     OutFireText="   You are dead. Fire to view other players."
     SkillLevel(1)="Beginner"
     SkillLevel(2)="Normal"
     SkillLevel(4)="Hard"
     SkillLevel(5)="Suicidal"
     SkillLevel(7)="Hell on Earth"
     Restart="   You were killed..."
     Ended="The game has ended."
     BoxMaterial=Texture'InterfaceArt_tex.Menu.DownTickBlurry'
     HudClass=Class'ROEngine.ROHud'
}
