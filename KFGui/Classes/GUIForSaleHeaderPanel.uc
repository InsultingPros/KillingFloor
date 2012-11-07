//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GUIForSaleHeaderPanel extends GUIPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
}

defaultproperties
{
     Begin Object Class=GUILabel Name=ItemText
         Caption="Available In Shop"
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinWidth=0.500000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(0)=GUILabel'KFGui.GUIForSaleHeaderPanel.ItemText'

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
     Controls(1)=GUILabel'KFGui.GUIForSaleHeaderPanel.ItemPrice'

     Begin Object Class=GUILabel Name=BuyText
         Caption="Buy"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinLeft=0.750000
         WinWidth=0.250000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(2)=GUILabel'KFGui.GUIForSaleHeaderPanel.BuyText'

}
