//-----------------------------------------------------------
//   edited emh 11/24/05
//-----------------------------------------------------------
class ROIAMultiColumnRulesPanel extends IAMultiColumnRulesPanel;

var GUIController localController;

var automated GUISectionBackground sb_background;

delegate OnDifficultyChanged(int index, int tag);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    localController = MyController;

    Super.InitComponent(MyController, MyOwner);

    RemoveComponent(b_Symbols);

    sb_background.ManageComponent(ch_Advanced);
    sb_background.ManageComponent(lb_Rules);
}

function UpdateSymbolButton()
{
	b_Symbols=None;
}

function InternalOnChange(GUIComponent Sender)
{
    local moComboBox combo;

    if (GUIMultiOptionList(Sender) != None)
	{
		if (Controller.bCurMenuInitialized)
		{
		    combo = moComboBox(GUIMultiOptionList(Sender).Get());
		    if (combo != none)
		        OnDifficultyChanged(combo.getIndex(), combo.tag);
		}
    }

    Super.InternalOnChange(Sender);
}

defaultproperties
{
     Begin Object Class=ROGUIProportionalContainer Name=myBackgroundGroup
         bNoCaption=True
         WinHeight=1.000000
         OnPreDraw=myBackgroundGroup.InternalPreDraw
     End Object
     sb_Background=ROGUIProportionalContainer'ROInterface.ROIAMultiColumnRulesPanel.myBackgroundGroup'

     Begin Object Class=moCheckBox Name=AdvancedButton
         Caption="View Advanced Options"
         OnCreateComponent=AdvancedButton.InternalOnCreateComponent
         Hint="Toggles whether advanced properties are displayed"
         WinTop=0.948334
         WinLeft=0.000000
         WinWidth=0.350000
         WinHeight=0.040000
         RenderWeight=1.000000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=ROIAMultiColumnRulesPanel.InternalOnChange
     End Object
     ch_Advanced=moCheckBox'ROInterface.ROIAMultiColumnRulesPanel.AdvancedButton'

     i_bk=None

}
