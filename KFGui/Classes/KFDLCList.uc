class KFDLCList extends GUIVertList;

// Settings
var()	float			HorizontalSpacing;
var()	float			VerticalSpacing;
var()	array<string>	CharacterNames;
var()	array<texture>	CharacterUnownedTextures;
var()	array<texture>	CharacterOwnedTextures;
var()	array<int>		WeaponAppIDs;
var()	array<texture>	WeaponUnownedTextures;
var()	array<texture>	WeaponOwnedTextures;
var()	texture			OverlayTexture;
var()	texture			HoverTexture;

// Display
var	array<int>		bItemIsCharacter;
var	array<int>		bItemOwned;
var	array<string>	ItemAppID;
var	array<texture>	ItemBackground;

// State
var	int								ItemHoverIndex;
var	PlayerController				MyPCOwner;
var SteamStatsAndAchievementsBase	MyStatsAndAchievements;

event Closed(GUIComponent Sender, bool bCancelled)
{
	MyPCOwner = none;
	MyStatsAndAchievements = none;

	super.Closed(Sender, bCancelled);
}

function InitList(PlayerController PCOwner, SteamStatsAndAchievementsBase StatsAndAchievements, bool bShowCharacters, bool bShowWeapons)
{
	local int i;

	OnDrawItem = DrawDLCItem;

	// Hold onto our references
	MyPCOwner = PCOwner;
	MyStatsAndAchievements = StatsAndAchievements;

	if ( ItemBackground.Length == 0 )
	{
		// Set up the Unowned Weapon DLC items
		if ( bShowWeapons )
		{
			// Show newest items first
			for ( i = WeaponAppIDs.Length - 1; i >= 0; i-- )
			{
				if ( !MyStatsAndAchievements.PlayerOwnsWeaponDLC(WeaponAppIDs[i]) )
				{
					bItemIsCharacter[bItemIsCharacter.Length] = 0;
					bItemOwned[bItemOwned.Length] = 0;
					ItemAppID[ItemAppID.Length] = string(WeaponAppIDs[i]);
					ItemBackground[ItemBackground.Length] = WeaponUnownedTextures[i];
				}
			}
		}

		// Set up the Unowned Character DLC items
		if ( bShowCharacters )
		{
			// Show newest items first
			for ( i = CharacterNames.Length - 1; i >= 0; i-- )
			{
				if ( !MyPCOwner.CharacterAvailable(CharacterNames[i]) )
				{
					bItemIsCharacter[bItemIsCharacter.Length] = 1;
					bItemOwned[bItemOwned.Length] = 0;
					ItemAppID[ItemAppID.Length] = CharacterNames[i];
					ItemBackground[ItemBackground.Length] = CharacterUnownedTextures[i];
				}
			}
		}

		// Set up the Owned Weapon DLC items
		if ( bShowWeapons )
		{
			// Show newest items first
			for ( i = WeaponAppIDs.Length - 1; i >= 0; i-- )
			{
				if ( MyStatsAndAchievements.PlayerOwnsWeaponDLC(WeaponAppIDs[i]) )
				{
					bItemIsCharacter[bItemIsCharacter.Length] = 0;
					bItemOwned[bItemOwned.Length] = 1;
					ItemAppID[ItemAppID.Length] = string(WeaponAppIDs[i]);
					ItemBackground[ItemBackground.Length] = WeaponOwnedTextures[i];
				}
			}
		}

		// Set up the Owned Character DLC items
		if ( bShowCharacters )
		{
			// Show newest items first
			for ( i = CharacterNames.Length - 1; i >= 0; i-- )
			{
				if ( MyPCOwner.CharacterAvailable(CharacterNames[i]) )
				{
					bItemIsCharacter[bItemIsCharacter.Length] = 1;
					bItemOwned[bItemOwned.Length] = 1;
					ItemAppID[ItemAppID.Length] = CharacterNames[i];
					ItemBackground[ItemBackground.Length] = CharacterOwnedTextures[i];
				}
			}
		}

		// Update the ItemCount and select the first item
		ItemCount = Ceil(float(ItemBackground.Length) / 3.0);
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
}

function DrawDLCItem(Canvas Canvas, int Index, float X, float Y, float Width, float Height, bool bSelected, bool bPending)
{
	local float ThisItemWidth, ThisItemHeight;
	local int HoverIndex, ItemIndex, i;

	ItemIndex = Index * 3;
	ThisItemWidth = (Width - (2 * HorizontalSpacing)) / 3.0;
	ThisItemHeight = Height - VerticalSpacing;

	// Setup our cheat for Mouse Click reaction
	if ( Index == Top )
	{
		ItemHoverIndex = -1;
	}

	// Determine if the Mouse is hovering over this row
	HoverIndex = -1;
	if ( Controller.MouseY - Y >= 0.0 && Controller.MouseY - Y <= ThisItemHeight )
	{
		if ( Controller.MouseX - X >= 0.0 && Controller.MouseX - X <= Width )
		{
			if ( Controller.MouseX - X <= ThisItemWidth )
			{
				HoverIndex = 0;
				ItemHoverIndex = ItemIndex;
			}
			else if ( Controller.MouseX - X >= ThisItemWidth + HorizontalSpacing && Controller.MouseX - X <= ThisItemWidth * 2 + HorizontalSpacing )
			{
				HoverIndex = 1;
				ItemHoverIndex = ItemIndex + 1;
			}
			else if ( Controller.MouseX - X >= ThisItemWidth * 2 + HorizontalSpacing * 2 )
			{
				HoverIndex = 2;
				ItemHoverIndex = ItemIndex + 2;
			}
		}
	}

	// Draw this row of items
	for ( i = 0; i < 3 && ItemIndex < ItemBackground.Length; i++ )
	{
		// Initialize the Canvas
		Canvas.Style = 1;
		Canvas.SetDrawColor(255, 255, 255, 255);

		// Draw the Item Background
		Canvas.SetPos(X, Y);
		Canvas.DrawTile(ItemBackground[ItemIndex], ThisItemWidth, ThisItemHeight, 0, 0, 256, 128);

		// Draw an Overlay, if necessary
		if ( bItemOwned[ItemIndex] == 0 )
		{
			Canvas.SetPos(X, Y);

			// Draw Hover overlay if mouse is within item
			if ( i == HoverIndex )
			{
				Canvas.DrawTile(HoverTexture, ThisItemWidth, ThisItemHeight, 0, 0, 256, 128);
			}
			else
			{
				Canvas.DrawTile(OverlayTexture, ThisItemWidth, ThisItemHeight, 0, 0, 256, 128);
			}
		}

		X += ThisItemWidth + HorizontalSpacing;
		ItemIndex++;
	}
}

function float DLCItemHeight(Canvas c)
{
	return (MenuOwner.ActualHeight() / 3.0) - 1.0;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( !IsInClientBounds() || ItemsPerPage==0 )
		return false;

	if ( bItemOwned[ItemHoverIndex] == 0 )
	{
		if ( bItemIsCharacter[ItemHoverIndex] == 1 )
		{
			MyPCOwner.PurchaseCharacter(ItemAppID[ItemHoverIndex]);
		}
		else
		{
			MyStatsAndAchievements.PurchaseWeaponDLC(int(ItemAppID[ItemHoverIndex]));
		}
	}
}

defaultproperties
{
     HorizontalSpacing=8.000000
     VerticalSpacing=5.000000
     CharacterNames(0)="FoundryWorker_Aldridge"
     CharacterNames(1)="Mr_Foster"
     CharacterNames(2)="Harold_Hunt"
     CharacterNames(3)="Captian_Wiggins"
     CharacterNames(4)="Steampunk_Berserker"
     CharacterNames(5)="Steampunk_Commando"
     CharacterNames(6)="Dave_The_Butcher_Roberts"
     CharacterNames(7)="Harold_Lott"
     CharacterNames(8)="Ash_Harding"
     CharacterNames(9)="ChickenNator"
     CharacterNames(10)="DAR"
     CharacterNames(11)="Mrs_Foster"
     CharacterNames(12)="Reggie"
     CharacterNames(13)="Harchier_Spebbington_II"
     CharacterNames(14)="Mr_Magma"
     CharacterUnownedTextures(0)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_Outbreak'
     CharacterUnownedTextures(1)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_Nightfall'
     CharacterUnownedTextures(2)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_PostMortem'
     CharacterUnownedTextures(3)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_London'
     CharacterUnownedTextures(4)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_Steampunk'
     CharacterUnownedTextures(5)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_SteamPTwo'
     CharacterUnownedTextures(6)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_UrbanNightmare'
     CharacterUnownedTextures(7)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_MoneyMoney'
     CharacterUnownedTextures(8)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_Ash'
     CharacterUnownedTextures(9)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_Chickenator'
     CharacterUnownedTextures(10)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_Robot'
     CharacterUnownedTextures(11)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_MrsFoster'
     CharacterUnownedTextures(12)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_Reggie'
     CharacterUnownedTextures(13)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_NewHarchier'
     CharacterUnownedTextures(14)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Desat_SkullyFoster'
     CharacterOwnedTextures(0)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_Outbreak'
     CharacterOwnedTextures(1)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_Nightfall'
     CharacterOwnedTextures(2)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_PostMortem'
     CharacterOwnedTextures(3)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_London'
     CharacterOwnedTextures(4)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_Steampunk'
     CharacterOwnedTextures(5)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_SteamPTwo'
     CharacterOwnedTextures(6)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_UrbanNightmare'
     CharacterOwnedTextures(7)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_MoneyMoney'
     CharacterOwnedTextures(8)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_Ash'
     CharacterOwnedTextures(9)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_Chickenator'
     CharacterOwnedTextures(10)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_Robot'
     CharacterOwnedTextures(11)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_MrsFoster'
     CharacterOwnedTextures(12)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_Reggie'
     CharacterOwnedTextures(13)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_NewHarchier'
     CharacterOwnedTextures(14)=Texture'KF_DLC.Characters.UI_KFDLC_Characters_Owned_SkullyFoster'
     WeaponAppIDs(0)=210934
     WeaponAppIDs(1)=210938
     WeaponAppIDs(2)=210943
     WeaponAppIDs(3)=210944
     WeaponAppIDs(4)=258751
     WeaponAppIDs(5)=258752
     WeaponAppIDs(6)=309991
     WeaponUnownedTextures(0)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Desat_Community'
     WeaponUnownedTextures(1)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Desat_Gold-Pack'
     WeaponUnownedTextures(2)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Desat_CommunitySteamP'
     WeaponUnownedTextures(3)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Desat_Gold-Pack2'
     WeaponUnownedTextures(4)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Desat_UsVSThemWeaponPack'
     WeaponUnownedTextures(5)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Desat_CamoWeaponPack'
     WeaponUnownedTextures(6)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Desat_Neon'
     WeaponOwnedTextures(0)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Owned_Community'
     WeaponOwnedTextures(1)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Owned_Gold-Pack'
     WeaponOwnedTextures(2)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Owned_CommunitySteamP'
     WeaponOwnedTextures(3)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Owned_Gold-Pack2'
     WeaponOwnedTextures(4)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Owned_UsVSThemWeaponPack'
     WeaponOwnedTextures(5)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Owned_CamoWeaponPack'
     WeaponOwnedTextures(6)=Texture'KF_DLC.Weapons.UI_KFDLC_Weapons_Owned_Neon'
     OverlayTexture=Texture'KF_DLC.Characters.UI_KFDLC_Unselected_BuyNow'
     HoverTexture=Texture'KF_DLC.Characters.UI_KFDLC_MouseOver_BuyNow'
     GetItemHeight=KFDLCList.DLCItemHeight
     FontScale=FNS_Medium
}
