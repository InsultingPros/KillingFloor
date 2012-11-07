class GUIClassMenu extends UT2k4MainPage;
const BUYLIST_CATS=7;
var automated GUIPanel p_Info;
var automated GUISelectClassesBox CategoryBox;
var automated GUISelectClassesBox ItemsBox;
var automated GUISectionBackground CategoryBG,ItemBG,InfoBG;
var GUISelectClassList myItems;
//var KFBuyItemsList myItems;
var editconst noexport float SavedPitch;

var array<string> BuyListHeaders;
var array<string> BuyListItemNames;

//Use these values to modify/test
var int playerscore;
var float playerweight;
var float maxweight;

var array < GUIClassSelectable > AllSelectableClasses;

function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	Super.InitComponent( MyController, MyOwner );

	ItemBG.ManageComponent(ItemsBox);
	myItems = ItemsBox.List;
}

event HandleParameters(string Param1, string Param2)
{

  	local int i;
	local int maxitems;
	local class<GUIClassSelectable> newitem;


	maxitems = 3;

	AllSelectableClasses.Remove(0,AllSelectableClasses.Length);
	//Lets split the delimited replication string and get the array out

	//Split(KFGameReplicationInfo(PlayerOwner().GameReplicationInfo).ClassListClassNames,",",ClassListClassNames);

	for(i=0;i<maxitems;i++)
	{

	//	newitem = class<GUIClassSelectable>(DynamicLoadObject(ClassListClassNames[i],class'Class'));
	        newitem = class 'SelectPlayerSoldier';
		AllSelectableClasses.Insert(0,1);
		AllSelectableClasses[0] = New newitem;

	}


	//GUIBuyMenuFooter(t_Footer).SetPlayerStats(playerscore,playerweight);
	ClassChange(self);

}

function KFClassMenuClosed(optional Bool bCanceled)
{
	local rotator NewRot;
	local int i;

	// Reset player
	NewRot = PlayerOwner().Rotation;
	NewRot.Pitch = SavedPitch;
	PlayerOwner().SetRotation(NewRot);

	//Reset purchased items.
	for(i=0;i<AllSelectableClasses.length;i++)
	{
		AllSelectableClasses[i].PurchasedQuantity=0;
	}
	Super.OnClose(bCanceled);


}

event Opened(GUIComponent Sender)
{
	local rotator PlayerRot;
	local int i; //,j;
	local int maxitems;
	local class<GUIClassSelectable> newitem;

	Super.Opened(Sender);

	maxitems = 3;
	AllSelectableClasses.Remove(0,AllSelectableClasses.Length);

	for(i=0;i<maxitems;i++)
	{

	//	newitem = class<GUIClassSelectable>(DynamicLoadObject(ClassListClassNames[i],class'Class'));
	        newitem = class 'SelectPlayerSoldier';
		AllSelectableClasses.Insert(0,1);
		AllSelectableClasses[0] = New newitem;

	}


	// Set camera's pitch to zero when menu initialised (otherwise spinny weap goes kooky)
	PlayerRot = PlayerOwner().Rotation;
	SavedPitch = PlayerRot.Pitch;
	PlayerRot.Yaw = PlayerRot.Yaw % 65536;
	PlayerRot.Pitch = 0;
	PlayerRot.Roll = 0;
	PlayerOwner().SetRotation(PlayerRot);
	playerscore = PlayerOwner().PlayerReplicationInfo.Score;
}

function NewInfo(GUIClassSelectable b)
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
	  // p_Info = new b.GetPanelType(eClasscat(myCategories.Index));;
	   //GUIBuyMenuFooter(t_Footer).SetBuyMode(b.GetBuyCaption(eClasscat(myCategories.Index)),CanAfford(b)&&b.CanButtonMe(PlayerOwner(),myCategories.Index != 0),b.IsA('BuyableAmmo') && myCategories.Index !=0,b.Isa('BuyableAmmo') && BuyableAmmo(b).BuyMoreClips()*b.cost < playerscore);
   } else
   {
	   p_Info = new class'GUIClassInfoPanel';
	   //GUIBuyMenuFooter(t_Footer).SetBuyMode("Buy",false,false,false);
   }
   p_Info.WinLeft=0;
   p_Info.WinTop=0;
   p_Info.WinWidth=1;
   p_Info.WinHeight=1;
   AppendComponent(p_Info,true);
   InfoBG.ManageComponent(p_Info);
   if(p_Info.IsA('GUIClassInfoPanel'))
	   GUIClassInfoPanel(p_Info).Display(b);
}

function bool CanAfford(GUIClassSelectable b)
{
	return true;
}

function ClassChange(GUIComponent Sender)
{
	local int j;

	myItems.Clear();
	//i = myCategories.Index;

	for(j=0;j<AllSelectableClasses.length;j++)
	{
	//	if(AllSelectableClasses[j].ShowMe(PlayerOwner().Pawn,eClassCat(i)))
			myItems.Add(AllSelectableClasses[j]);
	}
	myItems.OnChange(myItems);

}

function CloseSale(bool savePurchases)
{
	local int i;
	if(savePurchases && PlayerOwner().Pawn.IsA('KFHumanPawn'))
	{
		for(i=0;i<AllSelectableClasses.length;i++)
		{
			AllSelectableClasses[i].ProcessComplete(PlayerOwner());
		}

                //PlayerOwner().pawn.nextWeapon();
	}
	Controller.CloseMenu(!savePurchases);


	// Increment the number of players that are class-ready
	// If We don't meet the number of players in the level, then put the player in "Waiting mode" again.
	if (AllSelectableClasses.length > 0)
        KFGameReplicationInfo(PlayerOwner().Level.Game.GameReplicationInfo).NumPlayersClassSelected ++;

        if ( KFGameReplicationInfo(PlayerOwner().Level.Game.GameReplicationInfo).NumPlayersClassSelected >= PlayerOwner().level.game.NumPlayers)
	{
	 KFPlayerController(PlayerOwner()).bClassChosen = true;
         //PlayerOwner().ServerRestartPlayer();
         Log("Number of CLASS SELECT READY players == NUMPLAYERS.");
        }
	else
        PlayerOwner().GotoState('PlayerWaiting');

}

// We've got our player class selected, now "Buy" it.

function BuyCurrent()
{
	local GUIClassSelectable b;
	local int i;

	b = myItems.Elements[myItems.Index];

	b.BuyMe(playerscore,playerweight, playerOwner().Pawn);

//	myCategories.IndexChanged(myCategories);  //update lists
   	//Only refresh if we're out of whatever we bought.
		for(i=0;i<myItems.Elements.Length;i++)
		{
			if(myItems.Elements[i] == b)
				myItems.SetIndex(i);
		}


	//GUIBuyMenuFooter(t_Footer).SetPlayerStats(playerscore,playerweight);    //update footer
}

function BuyFill()
{

}

function bool CanAutoAmmo()
{
  return false;
}

function DoAutoAmmo()
{

}

defaultproperties
{
     Begin Object Class=GUISelectClassesBox Name=itmbox
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=itmbox.InternalOnCreateComponent
         Hint="Available Classes"
         WinHeight=1.000000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemsBox=GUISelectClassesBox'KFGui.GUIClassMenu.itmbox'

     Begin Object Class=AltSectionBackground Name=itmbg
         Caption="Player Classes"
         WinTop=0.060215
         WinLeft=0.480000
         WinWidth=0.500000
         WinHeight=0.880000
         OnPreDraw=itmbg.InternalPreDraw
     End Object
     ItemBG=AltSectionBackground'KFGui.GUIClassMenu.itmbg'

     Begin Object Class=AltSectionBackground Name=infbg
         Caption="Class Info"
         WinTop=0.454030
         WinLeft=0.010000
         WinWidth=0.440000
         WinHeight=0.486185
         OnPreDraw=infbg.InternalPreDraw
     End Object
     InfoBG=AltSectionBackground'KFGui.GUIClassMenu.infbg'

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
     c_Tabs=GUITabControl'KFGui.GUIClassMenu.PageTabs'

     Begin Object Class=GUIHeader Name=GamePageHeader
         Caption="Select Class"
         RenderWeight=0.300000
     End Object
     t_Header=GUIHeader'KFGui.GUIClassMenu.GamePageHeader'

     Begin Object Class=GUIClassMenuFooter Name=BuyFooter
         WinTop=0.957943
         RenderWeight=0.300000
         TabOrder=8
         OnPreDraw=BuyFooter.InternalOnPreDraw
     End Object
     t_Footer=GUIClassMenuFooter'KFGui.GUIClassMenu.BuyFooter'

     Begin Object Class=BackgroundImage Name=KFBackground
         Image=Texture'KillingFloor2HUD.Menu.menuBackground'
         ImageStyle=ISTY_PartialScaled
         RenderWeight=0.010000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_Background=BackgroundImage'KFGui.GUIClassMenu.KFBackground'

     bRenderWorld=True
     bAllowedAsLast=True
     OnClose=GUIClassMenu.KFClassMenuClosed
}
