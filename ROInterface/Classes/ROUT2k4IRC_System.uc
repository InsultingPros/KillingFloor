//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4IRC_System extends UT2k4IRC_System;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

defaultproperties
{
     Begin Object Class=GUISplitter Name=SplitterA
         SplitPosition=0.800000
         bFixedSplitter=True
         DefaultPanels(0)="ROInterface.ROGUIScrollTextBox"
         DefaultPanels(1)="ROInterface.ROUT2K4IRC_Panel"
         OnCreateComponent=ROUT2k4IRC_System.InternalOnCreateComponent
         WinHeight=0.950000
         TabOrder=1
     End Object
     sp_Main=GUISplitter'ROInterface.ROUT2k4IRC_System.SplitterA'

}
