class GUILibraryMenu extends UT2k4MainPage;
const LIBLIST_CATS=3;
var automated GUIPanel p_Info;
var automated GUIListBox CategoryBox;
var automated GUILibraryItemsBox ItemsBox;
var automated GUISectionBackground CategoryBG,ItemBG,InfoBG;
var GUIList myCategories;
var GUIShowLibList myItems;

var GUILabel TimerBox;
//var KFBuyItemsList myItems;
var editconst noexport float SavedPitch;

var array<string> BuyListHeaders;
var array<string> BuyListItemNames;

//Use these values to modify/test
var int playerscore;
var float playerweight;
var float maxweight;
var float GameDifficulty;

var Sound SellSound,BuySound;


var array < GUIShowable > AllBuyableItems;

function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	local int i;
	Super.InitComponent( MyController, MyOwner );


	CategoryBG.ManageComponent(CategoryBox);
	ItemBG.ManageComponent(ItemsBox);
	myCategories = CategoryBox.List;

	for(i=0;i<LIBLIST_CATS;i++)
		myCategories.Add(KFPlayerController(PlayerOwner()).LibraryListHeaders[i]);

	//myCategories = CategoryBox.List;
	myItems = ItemsBox.List;
}

event HandleParameters(string Param1, string Param2)
{
	CategoryChange(self);
}

function KFBuyMenuClosed(optional Bool bCanceled)
{
	local rotator NewRot;

	// Reset player
	NewRot = PlayerOwner().Rotation;
	NewRot.Pitch = SavedPitch;
	PlayerOwner().SetRotation(NewRot);
	Super.OnClose(bCanceled);
}

event Opened(GUIComponent Sender)
{
	local rotator PlayerRot;

	Super.Opened(Sender);
	// Set camera's pitch to zero when menu initialised (otherwise spinny weap goes kooky)
	PlayerRot = PlayerOwner().Rotation;
	SavedPitch = PlayerRot.Pitch;
	PlayerRot.Yaw = PlayerRot.Yaw % 65536;
	PlayerRot.Pitch = 0;
	PlayerRot.Roll = 0;
	PlayerOwner().SetRotation(PlayerRot);
	playerscore = PlayerOwner().PlayerReplicationInfo.Score;

	//Indicate that we're buying things.
        //KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo).bBuyingStuff = true;
}

function NewInfo(GUIShowable b)
{
   if(p_Info != None)
   {
	   RemoveComponent(p_Info,true);
	   InfoBG.UnmanageComponent(p_Info);
	   p_Info.Closed(p_Info,false);
	   p_Info.free();
	   p_Info = None;
   }
   if(b != None)
   {
	   p_Info = new b.GetPanelType(eLibCat(myCategories.Index));;
	 //  GUILibraryMenuFooter(t_Footer).SetBuyMode(b.GetBuyCaption(eLibCat(myCategories.Index)),CanAfford(b)&&b.CanButtonMe(PlayerOwner(),myCategories.Index != 0),b.IsA('BuyableAmmo') && myCategories.Index !=0,b.Isa('BuyableAmmo') );
   } else
   {
	   p_Info = new class'GUILibInfoPanel';
	   GUILibraryMenuFooter(t_Footer).SetBuyMode("Buy",false,false,false);
   }
   p_Info.WinLeft=0;
   p_Info.WinTop=0;
   p_Info.WinWidth=1;
   p_Info.WinHeight=1;
   AppendComponent(p_Info,true);
   InfoBG.ManageComponent(p_Info);
   if(p_Info.IsA('GUILibInfoPanel'))
	   GUILibInfoPanel(p_Info).Display(b);
}

function bool CanAfford(GUIShowable b)
{
	return myCategories.Index == 0 || (playerscore-b.cost >=0 && playerweight+b.weight <= maxweight);
}

function CategoryChange(GUIComponent Sender)
{
	local int i,j;

	myItems.Clear();
	i = myCategories.Index;

	for(j=0;j<allBuyableItems.length;j++)
	{
		if(AllBuyableItems[j].ShowMe(PlayerOwner().Pawn,eLibCat(i),self))
			myItems.Add(AllBuyableItems[j]);
	}
	myItems.OnChange(myItems);
}



function BuyCurrent()
{

}

function BuyFill()
{

}

function bool CanAutoAmmo()
{
	Return False;
}

function DoAutoAmmo()
{

}

function GUIShowable FindWeapon(class<Inventory> WeaponType)
{
	Return None;
}

function InitAmmoForNewGun(class<Inventory> WeaponType)
{

}

function CloseSale(bool savePurchases)
{
}

defaultproperties
{
     Begin Object Class=GUIListBox Name=BoxForCategories
         bVisibleWhenEmpty=True
         OnCreateComponent=BoxForCategories.InternalOnCreateComponent
         Hint="Choose among these categories of equipment."
         WinTop=0.110215
         WinLeft=0.020000
         WinWidth=0.400000
         WinHeight=0.500000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=GUILibraryMenu.CategoryChange
     End Object
     CategoryBox=GUIListBox'KFGui.GUILibraryMenu.BoxForCategories'

     Begin Object Class=GUILibraryItemsBox Name=itmbox
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=itmbox.InternalOnCreateComponent
         Hint="Equipment in this category"
         WinHeight=1.000000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemsBox=GUILibraryItemsBox'KFGui.GUILibraryMenu.itmbox'

     Begin Object Class=AltSectionBackground Name=catbg
         Caption="Categories"
         WinTop=0.060215
         WinLeft=0.010000
         WinWidth=0.440000
         WinHeight=0.383940
         OnPreDraw=catbg.InternalPreDraw
     End Object
     CategoryBG=AltSectionBackground'KFGui.GUILibraryMenu.catbg'

     Begin Object Class=AltSectionBackground Name=itmbg
         Caption="Items"
         WinTop=0.060215
         WinLeft=0.480000
         WinWidth=0.500000
         WinHeight=0.880000
         OnPreDraw=itmbg.InternalPreDraw
     End Object
     ItemBG=AltSectionBackground'KFGui.GUILibraryMenu.itmbg'

     Begin Object Class=AltSectionBackground Name=infbg
         Caption="Info"
         WinTop=0.454030
         WinLeft=0.010000
         WinWidth=0.440000
         WinHeight=0.486185
         OnPreDraw=infbg.InternalPreDraw
     End Object
     InfoBG=AltSectionBackground'KFGui.GUILibraryMenu.infbg'

     Begin Object Class=GUILabel Name=TimerTextBox
         Caption="SHOP CLOSES IN: "
         WinTop=0.250000
         WinLeft=0.100000
         WinWidth=0.200000
         WinHeight=0.200000
         bNeverFocus=True
     End Object
     TimerBox=GUILabel'KFGui.GUILibraryMenu.TimerTextBox'

     SellSound=SoundGroup'KF_InventorySnd.Cash_Pickup'
     BuySound=Sound'PatchSounds.slide1-5'
     Begin Object Class=GUITabControl Name=PageTabs
         bDockPanels=True
         TabHeight=0.040000
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.040000
         RenderWeight=0.490000
         TabOrder=3
         bAcceptsInput=True
         OnActivate=PageTabs.InternalOnActivate
     End Object
     c_Tabs=GUITabControl'KFGui.GUILibraryMenu.PageTabs'

     Begin Object Class=GUILibraryMenuFooter Name=LibFooter
         WinTop=0.957943
         RenderWeight=0.300000
         TabOrder=8
         OnPreDraw=BuyFooter.InternalOnPreDraw
     End Object
     t_Footer=GUILibraryMenuFooter'KFGui.GUILibraryMenu.LibFooter'

     Begin Object Class=BackgroundImage Name=KFBackground
         Image=Texture'2K4Menus.Controls.LockerBG'
         ImageStyle=ISTY_Tiled
         RenderWeight=0.010000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_Background=BackgroundImage'KFGui.GUILibraryMenu.KFBackground'

     bAllowedAsLast=True
}
