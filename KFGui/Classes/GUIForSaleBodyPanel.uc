//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GUIForSaleBodyPanel extends GUIPanel;

var     automated   GUIImage    BG;
var()               GUIBuyable  SaleItemInfo;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
}

defaultproperties
{
     Begin Object Class=GUISaleLabel Name=ItemText
         Caption="Available In Shop"
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinWidth=0.500000
         WinHeight=0.800000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(0)=GUISaleLabel'KFGui.GUIForSaleBodyPanel.ItemText'

     Begin Object Class=GUILabel Name=ItemPrice
         Caption="Price"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinLeft=0.500000
         WinWidth=0.250000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(1)=GUILabel'KFGui.GUIForSaleBodyPanel.ItemPrice'

     Begin Object Class=GUIInvButton Name=BuyButton
         Caption="Buy"
         FontScale=FNS_Small
         WinLeft=0.750000
         WinWidth=0.250000
         WinHeight=0.800000
         bBoundToParent=True
         bScaleToParent=True
         ToolTip=None

         OnKeyEvent=BuyButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIInvButton'KFGui.GUIForSaleBodyPanel.BuyButton'

}
