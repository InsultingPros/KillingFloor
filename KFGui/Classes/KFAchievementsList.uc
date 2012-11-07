class KFAchievementsList extends GUIVertList;

// Settings
var()	float	OuterBorder;
var()	float	ItemBorder;
var()	float	TextTopOffset;
var()	float	ItemSpacing;
var()	float	IconToNameSpacing;
var()	float	NameToDescriptionSpacing;
var()	float	ProgressBarWidth;
var()	float	ProgressBarHeight;
var()	float	ProgressTextSpacing;
var()	float	TextHeight;

// Display
var	texture	ItemBackground;
var	texture	ProgressBarBackground;
var	texture	ProgressBarForeground;

// State
var KFSteamStatsAndAchievements KFStatsAndAchievements;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	OnDrawItem = DrawAchievement;
	Super.InitComponent(MyController, MyOwner);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	KFStatsAndAchievements = none;

	super.Closed(Sender, bCancelled);
}

function InitList(KFSteamStatsAndAchievements StatsAndAchievements)
{
	// Hold onto our reference
	KFStatsAndAchievements = StatsAndAchievements;

	// Update all the Progress percentages of the Achievements
	KFStatsAndAchievements.UpdateAchievementProgress();

	// Update the ItemCount and select the first item
	ItemCount = KFStatsAndAchievements.Achievements.Length;
	SetIndex(0);

	if ( bNotify )
 	{
		CheckLinkedObjects(Self);
	}

	if ( MyScrollBar != none )
	{
		MyScrollBar.AlignThumb();
	}
}

function DrawAchievement(Canvas Canvas, int Index, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float TempX, TempY;
	local float IconSize;
	local string ProgressString;

	// Offset for the Background
	TempX = X + OuterBorder * Width;
	TempY = Y + ItemSpacing / 2.0;

	// Initialize the Canvas
    Canvas.Style = 1;
	Canvas.SetDrawColor(255, 255, 255, 192);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ItemBackground, Width - (OuterBorder * Width * 2.0), Height - ItemSpacing);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Offset and Calculate Icon's Size
	TempX += ItemBorder * Height;
	TempY += ItemBorder * Height;
	IconSize = Height - ItemSpacing - (ItemBorder * Height * 2.0);

	// Draw Icon
	Canvas.SetPos(TempX, TempY);
	if ( KFStatsAndAchievements.Achievements[Index].bCompleted == 1 )
	{
		Canvas.DrawTile(KFStatsAndAchievements.Achievements[Index].Icon, IconSize, IconSize, 0, 0, 64, 64);
	}
	else
	{
		Canvas.DrawTile(KFStatsAndAchievements.Achievements[Index].LockedIcon, IconSize, IconSize, 0, 0, 64, 64);
	}

	TempX += IconSize + IconToNameSpacing * Width;
	TempY += TextTopOffset * Height;

	//Draw the Display Name
	SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX, TempY, Width - TempX, TextHeight * Height, TXTA_Left, KFStatsAndAchievements.Achievements[Index].DisplayName, FNS_Medium);

	//Draw the Description
	SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX, TempY + (TextHeight * Height) + (NameToDescriptionSpacing * Height), Width - TempX, TextHeight * Height, TXTA_Left, KFStatsAndAchievements.Achievements[Index].Description, FNS_Small);

	if ( KFStatsAndAchievements.Achievements[Index].bShowProgress == 1 )
	{
		TempX = X + Width - (OuterBorder * Width) - (ItemBorder * Height * 2.0) - (ProgressBarWidth * Width);
		TempY = Y + (Height / 2.0) - (ProgressBarHeight * Height / 2.0);

		// Draw Progress Bar
		Canvas.SetPos(TempX, TempY);
		Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth * Width, ProgressBarHeight * Height);
		Canvas.SetPos(TempX + 3.0, TempY + 3.0);
		if ( KFStatsAndAchievements.Achievements[Index].ProgressNumerator < KFStatsAndAchievements.Achievements[Index].ProgressDenominator )
		{
			Canvas.DrawTileStretched(ProgressBarForeground, ((ProgressBarWidth * Width) - 6.0) * (float(KFStatsAndAchievements.Achievements[Index].ProgressNumerator) / float(KFStatsAndAchievements.Achievements[Index].ProgressDenominator)), ProgressBarHeight * Height - 6.0);
		}
		else
		{
			Canvas.DrawTileStretched(ProgressBarForeground, ProgressBarWidth * Width - 6.0, ProgressBarHeight * Height - 6.0);
		}

		// Draw Progress Text
		ProgressString = KFStatsAndAchievements.Achievements[Index].ProgressNumerator$"/"$KFStatsAndAchievements.Achievements[Index].ProgressDenominator;
		SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX - 150 - (ProgressTextSpacing * Width), TempY, 150, (TextHeight * Height), TXTA_Right, ProgressString, FNS_Medium);
	}
}

function float AchievementHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 6.0) - 1.0;
}

defaultproperties
{
     OuterBorder=0.015000
     ItemBorder=0.050000
     TextTopOffset=0.082000
     ItemSpacing=5.000000
     IconToNameSpacing=0.018000
     NameToDescriptionSpacing=0.125000
     ProgressBarWidth=0.227000
     ProgressBarHeight=0.225000
     ProgressTextSpacing=0.009000
     TextHeight=0.225000
     ItemBackground=Texture'KF_InterfaceArt_tex.Menu.Thin_border_SlightTransparent'
     ProgressBarBackground=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
     ProgressBarForeground=Texture'InterfaceArt_tex.Menu.progress_bar'
     GetItemHeight=KFAchievementsList.AchievementHeight
     FontScale=FNS_Medium
}
