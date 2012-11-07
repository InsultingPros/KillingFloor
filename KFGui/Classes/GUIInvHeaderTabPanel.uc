//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GUIInvHeaderTabPanel extends GUIPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
}

defaultproperties
{
     Begin Object Class=GUILabel Name=InventoryText
         Caption="Inventory"
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinWidth=0.230000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(0)=GUILabel'KFGui.GUIInvHeaderTabPanel.InventoryText'

     Begin Object Class=GUILabel Name=AmmoText
         Caption="Ammo"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinLeft=0.230000
         WinWidth=0.140000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(1)=GUILabel'KFGui.GUIInvHeaderTabPanel.AmmoText'

     Begin Object Class=GUILabel Name=ClipText
         Caption="Buy Clip"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinLeft=0.370000
         WinWidth=0.160000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(2)=GUILabel'KFGui.GUIInvHeaderTabPanel.ClipText'

     Begin Object Class=GUILabel Name=FillText
         Caption="Fill Up"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinLeft=0.540000
         WinWidth=0.160000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(3)=GUILabel'KFGui.GUIInvHeaderTabPanel.FillText'

     Begin Object Class=GUILabel Name=PriceText
         Caption="Price"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinLeft=0.700000
         WinWidth=0.140000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(4)=GUILabel'KFGui.GUIInvHeaderTabPanel.PriceText'

     Begin Object Class=GUILabel Name=SellText
         Caption="Sell"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinLeft=0.840000
         WinWidth=0.160000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(5)=GUILabel'KFGui.GUIInvHeaderTabPanel.SellText'

}
