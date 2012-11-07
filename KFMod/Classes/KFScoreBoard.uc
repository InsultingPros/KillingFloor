class KFScoreBoard extends ScoreBoardDeathMatch;

var 	localized 	string 		TeamScoreString;
var 	localized 	string 		WaveString;
var() 	localized 	string	  	HealthText, KillsText;
var 				bool 		bDisplayWithKills;
var 	localized 	string 		HealthyString;
var 	localized 	string 		InjuredString;
var 	localized 	string 		CriticalString;

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

// Adjust for Kills, instead of cash.
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
		// Kills is equal, go for cash.
		if( P11.Score < P22.Score )
			return false;
		else if( P11.Score==P22.Score )
			return (P1.PlayerName<P2.PlayerName); // Go for name.
	}
	return true;
}


simulated event UpdateScoreBoard(Canvas Canvas)
{
	local PlayerReplicationInfo PRI, OwnerPRI;
	local int i, FontReduction, NetXPos, PlayerCount, HeaderOffsetY, HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, OwnerOffset, HealthXPos, BoxXPos,KillsXPos, TitleYPos, BoxWidth, VetXPos;
	local float XL,YL, MaxScaling;
	local float deathsXL, KillsXL, netXL,HealthXL, MaxNamePos, KillWidthX, HealthWidthX;
	local bool bNameFontReduction;
	local Material VeterancyBox;

	OwnerPRI = KFPlayerController(Owner).PlayerReplicationInfo;
	OwnerOffset = -1;

	for ( i = 0; i < GRI.PRIArray.Length; i++)
	{
		PRI = GRI.PRIArray[i];

		if ( !PRI.bOnlySpectator )
		{
			if ( PRI == OwnerPRI )
			{
				OwnerOffset = i;
			}

			PlayerCount++;
		}
	}

	PlayerCount = Min(PlayerCount, MAXPLAYERS);

	// Select best font size and box size to fit as many players as possible on screen
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
			/*
			if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) )
			{
				FontReduction++;
				Canvas.Font = GetSmallerFontFor(Canvas, FontReduction);
				Canvas.StrLen("Test", XL, YL);
				BoxSpaceY = 0.125 * YL;
				PlayerBoxSizeY = 1.125 * YL;
				HeadFoot = 7 * YL;

				if ( PlayerCount > (Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) )
				{
					FontReduction++;
					Canvas.Font = GetSmallerFontFor(Canvas, FontReduction);
					Canvas.StrLen("Test", XL, YL);
					BoxSpaceY = 0.125 * YL;
					PlayerBoxSizeY = 1.125 * YL;
					HeadFoot = 7 * YL;

					if ( (Canvas.ClipY >= 768) && (PlayerCount > (Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY)) )
					{
						FontReduction++;
						Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
						Canvas.StrLen("Test", XL, YL);
						BoxSpaceY = 0.125 * YL;
						PlayerBoxSizeY = 1.125 * YL;
						HeadFoot = 7 * YL;
					}
				}
			}*/
		}
	}

	if ( Canvas.ClipX < 512 )
	{
		PlayerCount = Min(PlayerCount, 1+(Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) );
	}
	else
	{
		PlayerCount = Min(PlayerCount, (Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) );
	}

	if ( FontReduction > 2 )
	{
		MaxScaling = 3;
	}
	else
	{
		MaxScaling = 2.125;
	}

	PlayerBoxSizeY = FClamp((1.25 + (Canvas.ClipY - 0.67 * MessageFoot)) / PlayerCount - BoxSpaceY, PlayerBoxSizeY, MaxScaling * YL);

	bDisplayMessages = (PlayerCount <= (Canvas.ClipY - MessageFoot) / (PlayerBoxSizeY + BoxSpaceY));

	HeaderOffsetY = 10 * YL;
	BoxWidth = 0.7 * Canvas.ClipX;
	BoxXPos = 0.5 * (Canvas.ClipX - BoxWidth);
	BoxWidth = Canvas.ClipX - 2 * BoxXPos;
	VetXPos = BoxXPos + 0.0001 * BoxWidth;
	NameXPos = BoxXPos + 0.08 * BoxWidth;
	KillsXPos = BoxXPos + 0.60 * BoxWidth;
	HealthXpos = BoxXPos + 0.75 * BoxWidth;
	NetXPos = BoxXPos + 0.90 * BoxWidth;

	// draw background boxes
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.DrawColor.A = 128;

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY) * i);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
	}

	// draw title
	Canvas.Style = ERenderStyle.STY_Normal;
	DrawTitle(Canvas, HeaderOffsetY, (PlayerCount + 1) * (PlayerBoxSizeY + BoxSpaceY), PlayerBoxSizeY);

	// Draw headers
	TitleYPos = HeaderOffsetY - 1.1 * YL;
	Canvas.StrLen(HealthText, HealthXL, YL);
	Canvas.StrLen(DeathsText, DeathsXL, YL);
	Canvas.StrLen(KillsText, KillsXL, YL);
	Canvas.StrLen("INJURED", HealthWidthX, YL);

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(NameXPos, TitleYPos);
	Canvas.DrawText(PlayerText,true);

	if( bDisplayWithKills )
	{
		Canvas.SetPos(KillsXPos - 0.5 * KillsXL, TitleYPos);
		Canvas.DrawText(KillsText,true);
	}

	Canvas.SetPos(HealthXPos - 0.5 * HealthXL, TitleYPos);
	Canvas.DrawText(HealthText,true);

	// draw player names
	MaxNamePos = 0.9 * (KillsXPos - NameXPos);

	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.StrLen(GRI.PRIArray[i].PlayerName, XL, YL);

		if ( XL > MaxNamePos )
		{
			bNameFontReduction = true;
			break;
		}
	}

	if ( bNameFontReduction )
	{
		Canvas.Font = GetSmallerFontFor(Canvas, FontReduction + 1);
	}

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);
	BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	MaxNamePos = Canvas.ClipX;
	Canvas.ClipX = KillsXPos - 4.f;

	for ( i = 0; i < PlayerCount; i++ )
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

		Canvas.DrawTextClipped(GRI.PRIArray[i].PlayerName);
	}

	Canvas.ClipX = MaxNamePos;
	Canvas.DrawColor = HUDClass.default.WhiteColor;

	if ( bNameFontReduction )
	{
		Canvas.Font = GetSmallerFontFor(Canvas, FontReduction);
	}

	Canvas.Style = ERenderStyle.STY_Normal;
	MaxScaling = FMax(PlayerBoxSizeY,30.f);

	// Draw the player informations.
	for ( i = 0; i < PlayerCount; i++ )
	{
		Canvas.DrawColor = HUDClass.default.WhiteColor;

		// Display perks.
		if ( KFPlayerReplicationInfo(GRI.PRIArray[i])!=None && KFPlayerReplicationInfo(GRI.PRIArray[i]).ClientVeteranSkill != none )
		{
			VeterancyBox = KFPlayerReplicationInfo(GRI.PRIArray[i]).ClientVeteranSkill.default.OnHUDIcon;

			if ( VeterancyBox != None )
			{
				Canvas.SetPos(VetXPos, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY - PlayerBoxSizeY * 0.22);
				Canvas.DrawTile(VeterancyBox, PlayerBoxSizeY, PlayerBoxSizeY, 0, 0, VeterancyBox.MaterialUSize(), VeterancyBox.MaterialVSize());
			}
		}

		// draw kills
		if( bDisplayWithKills )
		{
			Canvas.StrLen(KFPlayerReplicationInfo(GRI.PRIArray[i]).Kills, KillWidthX, YL);
			Canvas.SetPos(KillsXPos - 0.5 * KillWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
			Canvas.DrawText(KFPlayerReplicationInfo(GRI.PRIArray[i]).Kills, true);
		}

		// draw cash
		//Canvas.SetPos(ScoreXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
		//Canvas.DrawText(int(GRI.PRIArray[i].Score),true);

		// draw healths
		Canvas.SetPos(HealthXpos - 0.5 * HealthWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);

		if ( GRI.PRIArray[i].bOutOfLives )
		{
			Canvas.DrawColor = HUDClass.default.RedColor;
			Canvas.DrawText(OutText,true);
		}
		else
		{
			if( KFPlayerReplicationInfo(GRI.PRIArray[i]).PlayerHealth>=95 )
			{
				Canvas.DrawColor = HUDClass.default.GreenColor;
				Canvas.DrawText(HealthyString,true);
			}
			else if( KFPlayerReplicationInfo(GRI.PRIArray[i]).PlayerHealth>=50 )
			{
				Canvas.DrawColor = HUDClass.default.GoldColor;
				Canvas.DrawText(InjuredString,true);
			}
			else
			{
				Canvas.DrawColor = HUDClass.default.RedColor;
				Canvas.DrawText(CriticalString,true);
			}
		}
	}

	if ( Level.NetMode == NM_Standalone )
		return;

	Canvas.StrLen(NetText, NetXL, YL);
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(NetXPos - 0.5 * NetXL, TitleYPos);
	Canvas.DrawText(NetText,true);

	for ( i=0; i<GRI.PRIArray.Length; i++ )
	{
		PRIArray[i] = GRI.PRIArray[i];
	}

	DrawNetInfo(Canvas, FontReduction, HeaderOffsetY, PlayerBoxSizeY, BoxSpaceY, BoxTextOffsetY, OwnerOffset, PlayerCount, NetXPos);
	DrawMatchID(Canvas, FontReduction);
}

function DrawNetInfo(Canvas Canvas,int FontReduction,int HeaderOffsetY,int PlayerBoxSizeY,int BoxSpaceY,int BoxTextOffsetY,int OwnerOffset,int PlayerCount, int NetXPos)
{
	local float XL,YL;
	local int i;
	local bool bHaveHalfFont, bDrawFPH, bDrawPL;

	bDrawPL = false;
	bDrawFPH = false;
	bHaveHalfFont = false;

	// draw admins
	if ( GRI.bMatchHasBegun )
	{
		Canvas.DrawColor = HUDClass.default.RedColor;

		for ( i = 0; i < PlayerCount; i++ )
			if ( PRIArray[i].bAdmin )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(AdminText,true);
				}
		if ( (OwnerOffset >= PlayerCount) && PRIArray[OwnerOffset].bAdmin )
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY) * PlayerCount + BoxTextOffsetY);
			Canvas.DrawText(AdminText,true);
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
			if ( bDrawPL )
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
				Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
				Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
			}
			else if ( bHaveHalfFont )
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
				Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
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
 				if ( bDrawPL )
 				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.9 * YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
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
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
					Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
				else if ( bHaveHalfFont )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
				else
				{
					Canvas.StrLen(Min(999, 4 * PRIArray[i].Ping), XL, YL);
					Canvas.SetPos(NetXPos - 0.5 * xL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
					Canvas.DrawText(Min(999,4*PRIArray[i].Ping),true);
				}
			}
	if ( (OwnerOffset >= PlayerCount) && !PRIArray[OwnerOffset].bAdmin && !PRIArray[OwnerOffset].bOutOfLives )
	{
 		if ( bDrawFPH )
 		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
			Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
			Canvas.DrawText(FPH@Min(999,3600*PRIArray[OwnerOffset].Score/FMax(1,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
			Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
		}
		else if ( bHaveHalfFont )
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
			Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
		}
		else
		{
			Canvas.StrLen(Min(999, 4 * PRIArray[i].Ping), XL, YL);
			Canvas.SetPos(NetXPos - 0.5 * XL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
			Canvas.DrawText(Min(999,4*PRIArray[OwnerOffset].Ping), true);
		}
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
