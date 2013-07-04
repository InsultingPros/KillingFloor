/*
	--------------------------------------------------------------
	GUIBuyMenu_Story
	--------------------------------------------------------------

	Main Trader Menu class
	extended to add support for story elements.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class GUIBuyMenu_Story extends GUIBuyMenu;

var	automated	GUILabel				ShopTitleLabel;

var				bool					bShowPerkHeader;

function UpdateHeader()
{
	local int TimeLeftMin, TimeLeftSec;
	local string TimeString;
    local KFPlayerController_Story  StoryPC;
	local float ObjTimeRemaining;

	if ( KFPlayerController(PlayerOwner()) == none || PlayerOwner().PlayerReplicationInfo == none ||
		 PlayerOwner().GameReplicationInfo == none )
	{
		return;
	}

	StoryPC = KFPlayerController_Story(PlayerOwner());
	if(StoryPC == none)
	{
        Super.UpdateHeader();
        return;
	}

	// Current Perk
	if ( KFPlayerController(PlayerOwner()).SelectedVeterancy != none )
    {
		CurrentPerkLabel.Caption = CurrentPerk$":" @ KFPlayerController(PlayerOwner()).SelectedVeterancy.default.VeterancyName @ LvAbbrString$KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).ClientVeteranSkillLevel;
	}
    else
	{
		CurrentPerkLabel.Caption = CurrentPerk$":" @ NoActivePerk;
	}

	// Trader time left

	if(StoryPC != none)
	{
       ObjTimeRemaining = StoryPC.RemainingTraderTime;
	}


	TimeLeftMin = ObjTimeRemaining / 60;
	TimeLeftSec = ObjTimeRemaining % 60;

	if ( TimeLeftMin < 1 )
	{
		TimeString = "00:";
	}
	else
	{
		TimeString = "0" $ TimeLeftMin $ ":";
	}

	if ( TimeLeftSec >= 10 )
	{
		TimeString = TimeString $ TimeLeftSec;
	}
	else
	{
		TimeString = TimeString $ "0" $ TimeLeftSec;
	}

	TimeLeftLabel.Caption = TraderClose @ TimeString;

	if ( KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).TimeToNextWave < 10 )
	{
		TimeLeftLabel.TextColor = RedColor;
	}
	else
	{
		TimeLeftLabel.TextColor = GreenGreyColor;
	}

}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	FillInfoFromVolume();

	if(!bShowPerkHeader)
	{
		HeaderBG_Left.Hint = "";
		HeaderBG_Left_Label.Caption = "";

		c_Tabs.RemoveTab(PanelClass[1]);
		RemoveComponent(QuickPerkSelect);
		RemoveComponent(StoreTabButton);
		RemoveComponent(PerkTabButton);
	}
}

function FillInfoFromVolume()
{
	local KFShopVolume_Story		CurrentPlayerShop;

	if(KFPlayerController_Story(PlayerOwner()) != none)
	{
		CurrentplayerShop = KFPlayerController_Story(PlayerOwner()).CurrentShopVolume  ;
		if(CurrentPlayerShop != none)
		{
			if( CurrentPlayerShop.ShopName != "" )
			{
				ShopTitleLabel.Caption = CurrentPlayerShop.ShopName ;
			}

   			bShowPerkHeader = CurrentPlayerShop.bShowPerkHeader;
		}
	}
}

defaultproperties
{
     Begin Object Class=GUILabel Name=ShopTitle
         Caption="Trader"
         TextAlign=TXTA_Center
         TextColor=(B=158,G=176,R=175)
         WinTop=0.052857
         WinLeft=0.336529
         WinWidth=0.327071
         WinHeight=0.035000
     End Object
     ShopTitleLabel=GUILabel'KFStoryUI.GUIBuyMenu_Story.ShopTitle'

     bShowPerkHeader=True
     WaveLabel=None

     PanelClass(0)="KFStoryUI.KFTab_BuyMenu_Story"
}
