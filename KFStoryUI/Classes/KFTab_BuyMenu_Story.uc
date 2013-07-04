/*
	--------------------------------------------------------------
	KFTab_BuyMenu_Story
	--------------------------------------------------------------

	Main Trader Menu class
	extended to add support for story elements.

	Author :  Alex Quick

	--------------------------------------------------------------
*/


class KFTab_BuyMenu_Story extends KFTab_BuyMenu;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	FillInfoTextFromVolume();
}


function FillInfoTextFromVolume()
{
	local KFShopVolume_Story		CurrentPlayerShop;

	if(KFPlayerController_Story(PlayerOwner()) != none)
	{
		CurrentplayerShop = KFPlayerController_Story(PlayerOwner()).CurrentShopVolume  ;
		if(CurrentPlayerShop != none &&
		CurrentPlayerShop.WelcomeText != "")
		{
			InfoText[0] = CurrentPlayerShop.WelcomeText;
		}
	}
}

defaultproperties
{
     Begin Object Class=KFBuyMenuInvListBox_Story Name=InventoryBox
         OnCreateComponent=InventoryBox.InternalOnCreateComponent
         WinTop=0.070841
         WinLeft=0.000108
         WinWidth=0.328204
         WinHeight=0.521856
     End Object
     InvSelect=KFBuyMenuInvListBox_Story'KFStoryUI.KFTab_BuyMenu_Story.InventoryBox'

     Begin Object Class=KFBuyMenuSaleListBox_Story Name=SaleBox
         OnCreateComponent=SaleBox.InternalOnCreateComponent
         WinTop=0.064312
         WinLeft=0.672632
         WinWidth=0.325857
         WinHeight=0.674039
     End Object
     SaleSelect=KFBuyMenuSaleListBox_Story'KFStoryUI.KFTab_BuyMenu_Story.SaleBox'

}
