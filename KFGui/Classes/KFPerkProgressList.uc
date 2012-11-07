class KFPerkProgressList extends GUIVertList;

// Settings
var()	float	ItemBorder;			// Percent of Width to leave blank inside Item Background
var()	float	ItemSpacing;		// Number of Pixels between Items
var()	float	ProgressBarHeight;	// Percent of Height to make Progress Bar's Height
var()	float	TextTopOffset;		// Percent of Height to off Progress String from top of Progress Bar(typically negative)

// Display
var	texture	ItemBackground;
var	texture	ProgressBarBackground;
var	texture	ProgressBarForeground;

// Strings
var	localized string	OneThousandSuffix;
var	localized string	OneMillionSuffix;
var	localized string	DecimalPoint;
var	localized string	UnitDelimiter;

// State
var	array<string>				RequirementString;
var	array<string>				RequirementProgressString;
var	array<float>				RequirementProgress;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	OnDrawItem = DrawPerk;
	Super.InitComponent(MyController, MyOwner);
}

function InitList()
{
	if ( bNotify )
 	{
		CheckLinkedObjects(Self);
	}
}

function PerkChanged(KFSteamStatsAndAchievements KFStatsAndAchievements, int NewPerkIndex)
{
	local int i, Numerator, Denominator;
	local float Progress;

	if ( !KFStatsAndAchievements.bUsedCheats )
	{
		// Update the ItemCount and select the first item
		ItemCount = KFStatsAndAchievements.GetPerkProgressDetailsCount(NewPerkIndex);
		SetIndex(0);

		RequirementString.Remove(0, RequirementString.Length);
		RequirementProgressString.Remove(0, RequirementProgressString.Length);
		RequirementProgress.Remove(0, RequirementProgress.Length);
		for ( i = 0; i < ItemCount; i++ )
		{
			KFStatsAndAchievements.GetPerkProgressDetails(NewPerkIndex, i, Numerator, Denominator, Progress);

			RequirementString[RequirementString.Length] = Repl(class'KFGameType'.default.LoadedSkills[NewPerkIndex].default.Requirements[i], "%x", FormatNumber(Denominator));
			RequirementProgressString[RequirementProgressString.Length] = FormatNumber(Numerator)$"/"$FormatNumber(Denominator);
			RequirementProgress[RequirementProgress.Length] = Progress;
		}
	}

	if ( MyScrollBar != none )
	{
		MyScrollBar.AlignThumb();
	}
}

function DrawPerk(Canvas Canvas, int CurIndex, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float AspectRatio;
	local float BorderSize;
	local float TempX, TempY;
	local float TempWidth, TempHeight;
	local array<string> WrappedArray;

	// Calculate the Aspect Ratio(Helps Widescreen)
	AspectRatio = Canvas.ClipX / Canvas.ClipY;

	// Calc BorderSize so we dont do it 10 times per draw
	BorderSize = (3.0 - AspectRatio) * ItemBorder * Width;

	// Offset for the Background
	TempX = X;
	TempY = Y + ItemSpacing / 2.0;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawTileStretched(ItemBackground, Width, Height - ItemSpacing);

	// Offset Border
	TempX += BorderSize;
	TempY += ((3.0 - AspectRatio) * BorderSize) + (TextTopOffset * Height);

	// Draw the Requirement string
	Canvas.SetDrawColor(192, 192, 192, 255);
	Canvas.WrapStringToArray(RequirementString[CurIndex], WrappedArray, Width - BorderSize * 2.0);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawText(WrappedArray[0]);

	// Draw Second Line of Requirement string(if necessary)
	if ( WrappedArray.Length > 1 )
	{
		Canvas.StrLen(WrappedArray[0], TempWidth, TempHeight);
		Canvas.SetPos(TempX, TempY + (TempHeight * 0.8));
		Canvas.DrawText(WrappedArray[1]);
	}

	// Get Width of Requirements Progress String
	Canvas.StrLen(RequirementProgressString[CurIndex], TempWidth, TempHeight);

	TempX = Width - TempWidth - BorderSize;
	TempY = Y + Height - TempHeight;

	// Draw the Requirement's Progress String
	Canvas.SetPos(X + TempX + 2.0, TempY - 2.0);
	Canvas.DrawText(RequirementProgressString[CurIndex]);

	// Create gap between Progress Bar and Progress String
	TempX -= ItemSpacing;
	TempHeight = Y + Height - TempY - (BorderSize / 2.0) - (ItemSpacing / 2.0);

	// Draw Progress Bar
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.SetPos(X + BorderSize, TempY);
	Canvas.DrawTileStretched(ProgressBarBackground, TempX - BorderSize, TempHeight);
	Canvas.SetPos(X + BorderSize + 3.0, TempY + 3.0);
	Canvas.DrawTileStretched(ProgressBarForeground, (TempX - BorderSize - 6.0) * RequirementProgress[CurIndex], TempHeight - 6.0);
}

function string AddCommas(int Value)
{
	local string StrValue;

	if ( Value < 1000 )
	{
		return string(Value);
	}
	else
	{
		if ( Value >= 1000000 )
		{
			StrValue = string(Value / 1000000)$UnitDelimiter;
			Value = Value % 1000000;

			if ( Value < 10000 )
			{
				StrValue $= "00"$(Value / 1000);
			}
			else if ( Value < 100000 )
			{
				StrValue $= "0"$(Value / 1000);
			}
			else
			{
				StrValue $= (Value / 1000);
			}

			StrValue $= UnitDelimiter;
			Value = Value % 1000;
		}
		else
		{
			StrValue = string(Value / 1000)$UnitDelimiter;
			Value = Value % 1000;
		}

		if ( Value < 10 )
		{
			StrValue $= "00"$Value;
		}
		else if ( Value < 100 )
		{
			StrValue $= "0"$Value;
		}
		else
		{
			StrValue $= Value;
		}
	}

	return StrValue;
}

function string FormatNumber(int Value)
{
	if ( Value < 100000 )
	{
		// Anything less than 100,000 needs no formatting
		return string(Value);
	}

	if ( Value < 1000000 )
	{
		// Anything between 100,000 and 1 million turns into ___K
		return string(Value / 1000)$OneThousandSuffix;
	}

	// Anything over 1 million turns into _._M
	return string(Value / 1000000)$DecimalPoint$string(int((Value % 1000000) / 100000))$OneMillionSuffix;
}

function float RequirementHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 3.0) - 1.0;
}

defaultproperties
{
     ItemBorder=0.018000
     ProgressBarHeight=0.250000
     TextTopOffset=-0.140000
     ItemBackground=Texture'KF_InterfaceArt_tex.Menu.Thin_border'
     ProgressBarBackground=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
     ProgressBarForeground=Texture'InterfaceArt_tex.Menu.progress_bar'
     OneThousandSuffix="K"
     OneMillionSuffix="M"
     DecimalPoint="."
     UnitDelimiter=","
     GetItemHeight=KFPerkProgressList.RequirementHeight
     FontScale=FNS_Medium
}
