class KFPerkSelectList extends GUIVertList;

// Settings
var	float	IconBorder;			// Percent of Height to leave blank inside Icon Background
var	float	ItemBorder;			// Percent of Height to leave blank inside Item Background
var	float	TextTopOffset;		// Percent of Height to offset top of Text
var	float	ItemSpacing;		// Number of Pixels between Items
var	float	IconToInfoSpacing;	// Percent of Width to offset Info from right side of Icon
var	float	ProgressBarHeight;	// Percent of Height to make Progress Bar's Height

// Localized Strings
var	localized string LvAbbrString;

// Display
var	texture	PerkBackground;
var	texture	InfoBackground;
var	texture	SelectedPerkBackground;
var	texture	SelectedInfoBackground;
var	texture	ProgressBarBackground;
var	texture	ProgressBarForeground;

// State
var KFSteamStatsAndAchievements KFStatsAndAchievements;
var	array<string>				PerkName;
var	array<string>				PerkLevelString;
var	array<float>				PerkProgress;
var	int							MouseOverIndex;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	OnDrawItem = DrawPerk;
	Super.InitComponent(MyController, MyOwner);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	KFStatsAndAchievements = none;

	super.Closed(Sender, bCancelled);
}

function InitList(KFSteamStatsAndAchievements StatsAndAchievements)
{
	local int i;
	local KFPlayerController KFPC;

	// Grab the Player Controller for later use
	KFPC = KFPlayerController(PlayerOwner());

	// Hold onto our reference
	KFStatsAndAchievements = StatsAndAchievements;

	// Update the ItemCount and select the first item
	ItemCount = class'KFGameType'.default.LoadedSkills.Length;
	SetIndex(0);

	PerkName.Remove(0, PerkName.Length);
	PerkLevelString.Remove(0, PerkLevelString.Length);
	PerkProgress.Remove(0, PerkProgress.Length);

	for ( i = 0; i < ItemCount; i++ )
	{
		PerkName[PerkName.Length] = class'KFGameType'.default.LoadedSkills[i].default.VeterancyName;
		PerkLevelString[PerkLevelString.Length] = LvAbbrString @ (KFStatsAndAchievements.PerkHighestLevelAvailable(i));
		PerkProgress[PerkProgress.Length] = KFStatsAndAchievements.GetPerkProgress(i);

		if ( (KFPC != none && class'KFGameType'.default.LoadedSkills[i] == KFPC.SelectedVeterancy) ||
			 (KFPC == none && class'KFGameType'.default.LoadedSkills[i] == class'KFPlayerController'.default.SelectedVeterancy) )
		{
			SetIndex(i);
		}
	}

	if ( bNotify )
 	{
		CheckLinkedObjects(Self);
	}

	if ( MyScrollBar != none )
	{
		MyScrollBar.AlignThumb();
	}
}

function bool PreDraw(Canvas Canvas)
{
	if ( Controller.MouseX >= ClientBounds[0] && Controller.MouseX <= ClientBounds[2] && Controller.MouseY >= ClientBounds[1] )
	{
		//  Figure out which Item we're clicking on
		MouseOverIndex = Top + ((Controller.MouseY - ClientBounds[1]) / ItemHeight);
		if ( MouseOverIndex >= ItemCount )
		{
			MouseOverIndex = -1;
		}
	}
	else
	{
		MouseOverIndex = -1;
	}

	return false;
}

function DrawPerk(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float TempX, TempY;
	local float IconSize, ProgressBarWidth;
	local float TempWidth, TempHeight;

	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing / 2.0;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Calculate the Icon's Size
	IconSize = Height - ItemSpacing;// - (ItemBorder * 2.0 * Height);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	if ( bSelected )
	{
		Canvas.DrawTileStretched(SelectedPerkBackground, IconSize, IconSize);
		Canvas.SetPos(TempX + IconSize - 1.0, Y + 7.0);
		Canvas.DrawTileStretched(SelectedInfoBackground, Width - IconSize, Height - ItemSpacing - 14);
	}
	else
	{
		Canvas.DrawTileStretched(PerkBackground, IconSize, IconSize);
		Canvas.SetPos(TempX + IconSize - 1.0, Y + 7.0);
		Canvas.DrawTileStretched(InfoBackground, Width - IconSize, Height - ItemSpacing - 14);
	}

	IconSize -= IconBorder * 2.0 * Height;

	// Draw Icon
	Canvas.SetPos(TempX + IconBorder * Height, TempY + IconBorder * Height);
	Canvas.DrawTile(class'KFGameType'.default.LoadedSkills[CurIndex].default.OnHUDIcon, IconSize, IconSize, 0, 0, 256, 256);

	TempX += IconSize + (IconToInfoSpacing * Width);
	TempY += TextTopOffset * Height + ItemBorder * Height;

	ProgressBarWidth = Width - (TempX - X) - (IconToInfoSpacing * Width);

	// Select Text Color
	if ( CurIndex == MouseOverIndex )
	{
		Canvas.SetDrawColor(255, 0, 0, 255);
	}
	else
	{
		Canvas.SetDrawColor(0, 0, 0, 255);
	}

	// Draw the Perk's Level Name
	Canvas.StrLen(PerkName[CurIndex], TempWidth, TempHeight);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawText(PerkName[CurIndex]);

	// Draw the Perk's Level
	if ( PerkLevelString[CurIndex] != "" )
	{
		Canvas.StrLen(PerkLevelString[CurIndex], TempWidth, TempHeight);
		Canvas.SetPos(TempX + ProgressBarWidth - TempWidth, TempY);
		Canvas.DrawText(PerkLevelString[CurIndex]);
	}

	TempY += TempHeight - (0.04 * Height);

	// Draw Progress Bar
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth, ProgressBarHeight * Height);
	Canvas.SetPos(TempX + 3.0, TempY + 3.0);
	Canvas.DrawTileStretched(ProgressBarForeground, (ProgressBarWidth - 6.0) * PerkProgress[CurIndex], (ProgressBarHeight * Height) - 6.0);
}

function float PerkHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 7.0) - 1.0;
}

defaultproperties
{
     IconBorder=0.050000
     ItemBorder=0.110000
     TextTopOffset=0.050000
     IconToInfoSpacing=0.050000
     ProgressBarHeight=0.300000
     LvAbbrString="Lv"
     PerkBackground=Texture'KF_InterfaceArt_tex.Menu.Item_box_box'
     InfoBackground=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar'
     SelectedPerkBackground=Texture'KF_InterfaceArt_tex.Menu.Item_box_box_Highlighted'
     SelectedInfoBackground=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar_Highlighted'
     ProgressBarBackground=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
     ProgressBarForeground=Texture'InterfaceArt_tex.Menu.progress_bar'
     GetItemHeight=KFPerkSelectList.PerkHeight
     FontScale=FNS_Medium
     OnPreDraw=KFPerkSelectList.PreDraw
}
