class KFPlayerReadyBar extends GUIMultiComponent;

var automated 	GUIImage 	PerkBackGround;
var automated 	GUIImage  	PlayerBackGround;

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);
	
	ResizeMe();
}

function ResolutionChanged( int ResX, int ResY )
{
	Super.ResolutionChanged(ResX,ResY);
	
	ResizeMe();
}

function ResizeMe()
{
	PerkBackGround.WinWidth = PerkBackGround.ActualHeight();
	PlayerBackGround.WinLeft = PerkBackGround.Winleft + PerkBackGround.ActualHeight();
	PlayerBackGround.WinWidth = ActualWidth() - PerkBackGround.ActualHeight();	
}

defaultproperties
{
     Begin Object Class=GUIImage Name=PerkBG
         Image=Texture'KF_InterfaceArt_tex.Menu.Item_box_box'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinWidth=0.000000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     PerkBackground=GUIImage'KFGui.KFPlayerReadyBar.PerkBG'

     Begin Object Class=GUIImage Name=PlayerBG
         Image=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.100000
         WinHeight=0.800000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     PlayerBackGround=GUIImage'KFGui.KFPlayerReadyBar.PlayerBG'

}
