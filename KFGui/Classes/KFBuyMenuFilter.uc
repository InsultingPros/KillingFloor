//=============================================================================
// Buy Menu Filter for the trader
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// Jeff "Captain Mallard" Robinson
//=============================================================================
class KFBuyMenuFilter extends GUIMultiComponent;

var				texture							CurPerkBack;
var             texture                         NoPerkIcon;
var             texture                         FavoritesIcon;

var	automated	GUIImage						PerkBack0;
var	automated	GUIImage						PerkBack1;
var	automated	GUIImage						PerkBack2;
var	automated	GUIImage						PerkBack3;
var	automated	GUIImage						PerkBack4;
var	automated	GUIImage						PerkBack5;
var	automated	GUIImage						PerkBack6;
var	automated	GUIImage						PerkBack7;
var	automated	GUIImage						PerkBack8;

var	automated	KFIndexedGUIImage				PerkSelectIcon0;
var	automated	KFIndexedGUIImage				PerkSelectIcon1;
var	automated	KFIndexedGUIImage				PerkSelectIcon2;
var	automated	KFIndexedGUIImage				PerkSelectIcon3;
var	automated	KFIndexedGUIImage				PerkSelectIcon4;
var	automated	KFIndexedGUIImage				PerkSelectIcon5;
var	automated	KFIndexedGUIImage				PerkSelectIcon6;
var	automated	KFIndexedGUIImage				PerkSelectIcon7;
var	automated	KFIndexedGUIImage				PerkSelectIcon8;

const                                           NUM_FILTERS = 9;
var             GUIImage                        PerkSelectBacks[9];
var 			GUIImage				        PerkSelectIcons[9];

var		 		int								MaxPerks;
var				int								CurPerk;
var				bool							bPerkChange;

var 			float 							CurX;
var				float							CurY;
var 			float							BoxSizeX;
var 			float							BoxSizeY;
var 			float							SpacerX;
var 			float							SpacerY;

var 			KFSteamStatsAndAchievements 	KFStatsAndAchievements;
var 			bool							bResized;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
}

event Opened(GUIComponent Sender)
{
    super.Opened( Sender );
    CheckPerks(KFStatsAndAchievements);
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	super.Closed(Sender, bCancelled);
}

event ResolutionChanged( int ResX, int ResY )
{
	super.ResolutionChanged(ResX, ResY);
}

function bool MyOnDraw(Canvas C)
{
	local int i;

	super.OnDraw(C);

	// make em square
	if ( !bResized )
	{
		ResizeIcons(C);
		RealignIcons();
	}

	// Draw the available perks
	for ( i = 0; i < NUM_FILTERS; i++ )
	{
	    // no icon for non-perk weapons, what to do?
	    if( i < MaxPerks )
	    {
	        PerkSelectIcons[i].Image = class'KFGameType'.default.LoadedSkills[i].default.OnHUDIcon;
	    }
	    else if( i == MaxPerks ) // No-perk
	    {
	        PerkSelectIcons[i].Image = NoPerkIcon;
	    }
	    else if( i == MaxPerks + 1 ) // favorites
	    {
	        PerkSelectIcons[i].Image = FavoritesIcon;
	    }

		if ( i != CurPerk )
		{
			PerkSelectIcons[i].ImageColor.A = 95;
		}
		else
		{
			PerkSelectIcons[i].ImageColor.A = 255;
		}
	}

	return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local PlayerController PC;

	// Grab the Player Controller for later use
	PC = PlayerOwner();

	if ( Sender.IsA('KFIndexedGUIImage') )
	{
		if ( KFPlayerController(PC) != none )
		{
		    CurPerk = KFIndexedGUIImage(Sender).Index;
		    KFPlayerController(PC).BuyMenuFilterIndex = KFIndexedGUIImage(Sender).Index;
		}
	}

	return false;
}

function ResizeIcons(Canvas C)
{
    local float sizeX, sizeY;

    sizeX = (C.ClipY / C.ClipX) * BoxSizeX;
    sizeY = (C.ClipY / C.ClipX) * BoxSizeY;

	PerkBack0.WinWidth = sizeX;
	PerkSelectBacks[0] = PerkBack0;
	PerkBack1.WinWidth = sizeX;
	PerkSelectBacks[1] = PerkBack1;
	PerkBack2.WinWidth = sizeX;
	PerkSelectBacks[2] = PerkBack2;
	PerkBack3.WinWidth = sizeX;
	PerkSelectBacks[3] = PerkBack3;
	PerkBack4.WinWidth = sizeX;
	PerkSelectBacks[4] = PerkBack4;
	PerkBack5.WinWidth = sizeX;
	PerkSelectBacks[5] = PerkBack5;
	PerkBack6.WinWidth = sizeX;
	PerkSelectBacks[6] = PerkBack6;
	PerkBack7.WinWidth = sizeX;
	PerkSelectBacks[7] = PerkBack7;
	PerkBack8.WinWidth = sizeX;
	PerkSelectBacks[8] = PerkBack8;

	PerkSelectIcon0.WinWidth = sizeY;
	PerkSelectIcons[0] = PerkSelectIcon0;
	PerkSelectIcon1.WinWidth = sizeY;
	PerkSelectIcons[1] = PerkSelectIcon1;
	PerkSelectIcon2.WinWidth = sizeY;
	PerkSelectIcons[2] = PerkSelectIcon2;
	PerkSelectIcon3.WinWidth = sizeY;
	PerkSelectIcons[3] = PerkSelectIcon3;
	PerkSelectIcon4.WinWidth = sizeY;
	PerkSelectIcons[4] = PerkSelectIcon4;
	PerkSelectIcon5.WinWidth = sizeY;
	PerkSelectIcons[5] = PerkSelectIcon5;
	PerkSelectIcon6.WinWidth = sizeY;
	PerkSelectIcons[6] = PerkSelectIcon6;
	PerkSelectIcon7.WinWidth = sizeY;
	PerkSelectIcons[7] = PerkSelectIcon7;
	PerkSelectIcon8.WinWidth = sizeY;
	PerkSelectIcons[8] = PerkSelectIcon8;

	bResized = true;
}

function RealignIcons()
{
    local int i;
    local float IconWidth, TotalWidth, WidthLeft, WidthLeftForEachIcon, IconPadding;

    IconWidth = PerkSelectIcons[0].WinWidth;
    TotalWidth = IconWidth * 9.f;
    WidthLeft = 1.f - TotalWidth;
    WidthLeftForEachIcon = WidthLeft / 9.f;
    IconPadding = WidthLeftForEachIcon / 2.f;
    for( i = 0; i < 9; ++i ) // size of PerkSelectIcons
    {
        PerkSelectIcons[i].WinLeft = IconPadding + (IconPadding + IconWidth + IconPadding) * i;
        PerkSelectBacks[i].WinLeft = IconPadding + (IconPadding + IconWidth + IconPadding) * i;
    }
}

function CheckPerks(KFSteamStatsAndAchievements StatsAndAchievements)
{
	local int i;
	local KFPlayerController KFPC;

	// Grab the Player Controller for later use
	KFPC = KFPlayerController(PlayerOwner());

	// Hold onto our reference
	KFStatsAndAchievements = StatsAndAchievements;

	// Update the ItemCount and select the first item
	MaxPerks = class'KFGameType'.default.LoadedSkills.Length;

	for ( i = 0; i < MaxPerks; i++ )
	{
		if ( (KFPC != none && class'KFGameType'.default.LoadedSkills[i] == KFPC.SelectedVeterancy) ||
			 (KFPC == none && class'KFGameType'.default.LoadedSkills[i] == class'KFPlayerController'.default.SelectedVeterancy) )
		{
			CurPerk = i;
			KFPC.BuyMenuFilterIndex = CurPerk;
		}
	}
}

defaultproperties
{
     CurPerkBack=Texture'KF_InterfaceArt_tex.Menu.Perk_box'
     NoPerkIcon=Texture'KillingFloor2HUD.Perk_Icons.No_Perk_Icon'
     FavoritesIcon=Texture'KillingFloor2HUD.Perk_Icons.Favorite_Perk_Icon'
     Begin Object Class=GUIImage Name=PB0
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.700000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack0=GUIImage'KFGui.KFBuyMenuFilter.PB0'

     Begin Object Class=GUIImage Name=PB1
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.735000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack1=GUIImage'KFGui.KFBuyMenuFilter.PB1'

     Begin Object Class=GUIImage Name=PB2
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.770000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack2=GUIImage'KFGui.KFBuyMenuFilter.PB2'

     Begin Object Class=GUIImage Name=PB3
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.805000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack3=GUIImage'KFGui.KFBuyMenuFilter.PB3'

     Begin Object Class=GUIImage Name=PB4
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.840000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack4=GUIImage'KFGui.KFBuyMenuFilter.PB4'

     Begin Object Class=GUIImage Name=PB5
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.875000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack5=GUIImage'KFGui.KFBuyMenuFilter.PB5'

     Begin Object Class=GUIImage Name=PB6
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.910000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack6=GUIImage'KFGui.KFBuyMenuFilter.PB6'

     Begin Object Class=GUIImage Name=PB7
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.945000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack7=GUIImage'KFGui.KFBuyMenuFilter.PB7'

     Begin Object Class=GUIImage Name=PB8
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         WinTop=0.050000
         WinLeft=0.980000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.500000
         bBoundToParent=True
     End Object
     PerkBack8=GUIImage'KFGui.KFBuyMenuFilter.PB8'

     Begin Object Class=KFIndexedGUIImage Name=PSI0
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Medic"
         WinTop=0.052000
         WinLeft=0.700000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon0=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI0'

     Begin Object Class=KFIndexedGUIImage Name=PSI1
         Index=1
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Support"
         WinTop=0.052000
         WinLeft=0.735000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon1=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI1'

     Begin Object Class=KFIndexedGUIImage Name=PSI2
         Index=2
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Sharpshooter"
         WinTop=0.052000
         WinLeft=0.770000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon2=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI2'

     Begin Object Class=KFIndexedGUIImage Name=PSI3
         Index=3
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Commando"
         WinTop=0.052000
         WinLeft=0.805000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon3=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI3'

     Begin Object Class=KFIndexedGUIImage Name=PSI4
         Index=4
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Berserker"
         WinTop=0.052000
         WinLeft=0.840000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon4=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI4'

     Begin Object Class=KFIndexedGUIImage Name=PSI5
         Index=5
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Firebug"
         WinTop=0.052000
         WinLeft=0.875000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon5=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI5'

     Begin Object Class=KFIndexedGUIImage Name=PSI6
         Index=6
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Demolitions"
         WinTop=0.052000
         WinLeft=0.910000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon6=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI6'

     Begin Object Class=KFIndexedGUIImage Name=PSI7
         Index=7
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Non-perk"
         WinTop=0.052000
         WinLeft=0.945000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon7=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI7'

     Begin Object Class=KFIndexedGUIImage Name=PSI8
         Index=8
         Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
         ImageStyle=ISTY_Scaled
         Hint="Favorites"
         WinTop=0.052000
         WinLeft=0.980000
         WinWidth=0.040000
         WinHeight=0.040000
         RenderWeight=0.600000
         bBoundToParent=True
         OnClick=KFBuyMenuFilter.InternalOnClick
     End Object
     PerkSelectIcon8=KFIndexedGUIImage'KFGui.KFBuyMenuFilter.PSI8'

     MaxPerks=6
     BoxSizeX=0.040000
     BoxSizeY=0.040000
     SpacerX=0.001000
     SpacerY=0.004000
     OnDraw=KFBuyMenuFilter.MyOnDraw
}
