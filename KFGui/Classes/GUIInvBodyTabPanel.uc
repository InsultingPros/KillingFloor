//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GUIInvBodyTabPanel extends GUIPanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
}

//function InitPanel()
//{
//    super.InitPanel();
//}

defaultproperties
{
     Begin Object Class=GUILabel Name=ItemName
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         WinWidth=0.230000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(0)=GUILabel'KFGui.GUIInvBodyTabPanel.ItemName'

     Begin Object Class=GUILabel Name=Ammo
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
     Controls(1)=GUILabel'KFGui.GUIInvBodyTabPanel.Ammo'

     Begin Object Class=GUIInvButton Name=ClipButton
         FontScale=FNS_Small
         WinLeft=0.370000
         WinWidth=0.160000
         WinHeight=0.800000
         bBoundToParent=True
         bScaleToParent=True
         ToolTip=None

         OnKeyEvent=ClipButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIInvButton'KFGui.GUIInvBodyTabPanel.ClipButton'

     Begin Object Class=GUIInvButton Name=FillButton
         FontScale=FNS_Small
         WinLeft=0.540000
         WinWidth=0.160000
         WinHeight=0.800000
         bBoundToParent=True
         bScaleToParent=True
         ToolTip=None

         OnKeyEvent=FillButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIInvButton'KFGui.GUIInvBodyTabPanel.FillButton'

     Begin Object Class=GUILabel Name=ItemPrice
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
     Controls(4)=GUILabel'KFGui.GUIInvBodyTabPanel.ItemPrice'

     Begin Object Class=GUIInvButton Name=SellButton
         FontScale=FNS_Small
         WinLeft=0.840000
         WinWidth=0.160000
         WinHeight=0.800000
         bBoundToParent=True
         bScaleToParent=True
         ToolTip=None

         OnKeyEvent=SellButton.InternalOnKeyEvent
     End Object
     Controls(5)=GUIInvButton'KFGui.GUIInvBodyTabPanel.SellButton'

}
