/*
	--------------------------------------------------------------
	KFScoreBoard_Story
	--------------------------------------------------------------

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KFScoreBoard_Story extends KFScoreboardNew;

/* Override to replace the Wavestring with the Title of the current objective */

function DrawTitle(Canvas Canvas, float HeaderOffsetY, float PlayerAreaY, float PlayerBoxSizeY)
{
	local string TitleString, ScoreInfoString, RestartString;
	local float TitleXL, ScoreInfoXL, YL, TitleY, TitleYL;
	local KF_StoryObjective CurrentObj;
    local string ObjString;

    if(KF_StoryGRI(GRI) != none)
    {
        CurrentObj = KF_StoryGRI(GRI).GetCurrentObjective() ;
        if(CurrentObj != none)
        {
            ObjString = CurrentObj.HUD_Header.Header_Text ;
        }
    }

	TitleString = SkillLevel[Clamp(InvasionGameReplicationInfo(GRI).BaseDifficulty, 0, 7)] @ "|" @ ObjString @ "|" @ Level.Title;

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

defaultproperties
{
}
