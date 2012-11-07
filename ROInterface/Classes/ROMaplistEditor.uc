//-----------------------------------------------------------
// created by emh, 11/24/05
//-----------------------------------------------------------
class ROMaplistEditor extends MaplistEditor;

var automated GUISectionBackground  sb_container;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    sb_MapList.ManageComponent(co_Maplist);
    sb_MapList.ManageComponent(sb_container);
    sb_container.ManageComponent(b_Delete);
    sb_container.ManageComponent(b_Rename);
    sb_container.ManageComponent(b_New);


}

// wtf is this bollocks? I want my controls statically aligned!
function bool ButtonPreDraw(Canvas C)
{
    return false;
}

defaultproperties
{
     Begin Object Class=ROGUIContainerNoSkinAlt Name=subcontainer
         NumColumns=3
         WinHeight=1.000000
         TabOrder=1
         OnPreDraw=subcontainer.InternalPreDraw
     End Object
     sb_container=ROGUIContainerNoSkinAlt'ROInterface.ROMaplistEditor.subcontainer'

     Begin Object Class=GUIButton Name=AddButton
         Caption="Add"
         Hint="Add the selected maps to your map list"
         WinTop=0.300000
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         TabOrder=6
         bScaleToParent=True
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=ROMaplistEditor.ModifyMapList
         OnKeyEvent=AddButton.InternalOnKeyEvent
     End Object
     b_Add=GUIButton'ROInterface.ROMaplistEditor.AddButton'

     Begin Object Class=GUIButton Name=AddAllButton
         Caption="Add All"
         Hint="Add all maps to your map list"
         WinTop=0.360000
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         TabOrder=5
         bScaleToParent=True
         OnClickSound=CS_Up
         OnClick=ROMaplistEditor.ModifyMapList
         OnKeyEvent=AddAllButton.InternalOnKeyEvent
     End Object
     b_AddAll=GUIButton'ROInterface.ROMaplistEditor.AddAllButton'

     Begin Object Class=GUIButton Name=RemoveButton
         Caption="Remove"
         AutoSizePadding=(HorzPerc=0.500000)
         Hint="Remove the selected maps from your map list"
         WinTop=0.700000
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         TabOrder=10
         bScaleToParent=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=ROMaplistEditor.ModifyMapList
         OnKeyEvent=RemoveButton.InternalOnKeyEvent
     End Object
     b_Remove=GUIButton'ROInterface.ROMaplistEditor.RemoveButton'

     Begin Object Class=GUIButton Name=RemoveAllButton
         Caption="Remove All"
         Hint="Remove all maps from your map list"
         WinTop=0.760000
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         TabOrder=11
         bScaleToParent=True
         OnClickSound=CS_Down
         OnClick=ROMaplistEditor.ModifyMapList
         OnKeyEvent=RemoveAllButton.InternalOnKeyEvent
     End Object
     b_RemoveAll=GUIButton'ROInterface.ROMaplistEditor.RemoveAllButton'

     Begin Object Class=GUIButton Name=MoveUpButton
         Caption="Up"
         Hint="Move this map higher up in the list"
         WinTop=0.500000
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         TabOrder=9
         bScaleToParent=True
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=ROMaplistEditor.ModifyMapList
         OnKeyEvent=MoveUpButton.InternalOnKeyEvent
     End Object
     b_MoveUp=GUIButton'ROInterface.ROMaplistEditor.MoveUpButton'

     Begin Object Class=GUIButton Name=MoveDownButton
         Caption="Down"
         Hint="Move this map lower down in the list"
         WinTop=0.560000
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         TabOrder=8
         bScaleToParent=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=ROMaplistEditor.ModifyMapList
         OnKeyEvent=MoveDownButton.InternalOnKeyEvent
     End Object
     b_MoveDown=GUIButton'ROInterface.ROMaplistEditor.MoveDownButton'

     Begin Object Class=GUIButton Name=NewMaplistButton
         Caption="New"
         Hint="Create a new custom maplist"
         WinLeft=0.600000
         WinWidth=0.100000
         WinHeight=0.050000
         TabOrder=1
         OnClick=ROMaplistEditor.CustomMaplistClick
         OnKeyEvent=NewMaplistButton.InternalOnKeyEvent
     End Object
     b_New=GUIButton'ROInterface.ROMaplistEditor.NewMaplistButton'

     Begin Object Class=GUIButton Name=DeleteMaplistButton
         Caption="Delete"
         Hint="Delete the currently selected maplist.  If this is the last maplist for this gametype, a new default maplist will be generated."
         WinLeft=0.900000
         WinWidth=0.100000
         WinHeight=0.050000
         TabOrder=3
         OnPreDraw=ROMaplistEditor.ButtonPreDraw
         OnClick=ROMaplistEditor.CustomMaplistClick
         OnKeyEvent=DeleteMaplistButton.InternalOnKeyEvent
     End Object
     b_Delete=GUIButton'ROInterface.ROMaplistEditor.DeleteMaplistButton'

     Begin Object Class=GUIButton Name=RenameMaplistButton
         Caption="Rename"
         Hint="Rename the currently selected maplist"
         WinLeft=0.750000
         WinWidth=0.100000
         WinHeight=0.050000
         TabOrder=2
         OnClick=ROMaplistEditor.CustomMaplistClick
         OnKeyEvent=RenameMaplistButton.InternalOnKeyEvent
     End Object
     b_Rename=GUIButton'ROInterface.ROMaplistEditor.RenameMaplistButton'

     Begin Object Class=GUIComboBox Name=SelectMaplistCombo
         bReadOnly=True
         Hint="Load a existing custom maplist"
         WinWidth=0.550000
         WinHeight=0.050000
         TabOrder=0
         OnChange=ROMaplistEditor.MaplistSelectChange
         OnKeyEvent=SelectMaplistCombo.InternalOnKeyEvent
     End Object
     co_Maplist=GUIComboBox'ROInterface.ROMaplistEditor.SelectMaplistCombo'

     Begin Object Class=GUISectionBackground Name=MapListSectionBackground
         Caption="Saved Map Lists"
         NumColumns=2
         WinTop=0.055162
         WinLeft=0.023646
         WinWidth=0.943100
         WinHeight=0.170000
         OnPreDraw=MapListSectionBackground.InternalPreDraw
     End Object
     sb_MapList=GUISectionBackground'ROInterface.ROMaplistEditor.MapListSectionBackground'

     Begin Object Class=GUISectionBackground Name=AvailBackground
         bFillClient=True
         Caption="Available Maps"
         LeftPadding=0.002500
         RightPadding=0.002500
         TopPadding=0.002500
         BottomPadding=0.002500
         WinTop=0.235260
         WinLeft=0.025156
         WinWidth=0.380859
         WinHeight=0.716073
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=AvailBackground.InternalPreDraw
     End Object
     sb_Avail=GUISectionBackground'ROInterface.ROMaplistEditor.AvailBackground'

     Begin Object Class=GUISectionBackground Name=ActiveBackground
         bFillClient=True
         Caption="Selected Maps"
         LeftPadding=0.002500
         RightPadding=0.002500
         TopPadding=0.002500
         BottomPadding=0.002500
         WinTop=0.235260
         WinLeft=0.586876
         WinWidth=0.380859
         WinHeight=0.716073
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=ActiveBackground.InternalPreDraw
     End Object
     sb_Active=GUISectionBackground'ROInterface.ROMaplistEditor.ActiveBackground'

}
