//=============================================================================
// A GUIImage with an Index
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================
class KFIndexedGUIImage extends GUIImage;

var	int Index;

defaultproperties
{
     bAcceptsInput=True
     bCaptureMouse=True
     bMouseOverSound=True
     Begin Object Class=GUIToolTip Name=GUIButtonToolTip
     End Object
     ToolTip=GUIToolTip'XInterface.GUIButton.GUIButtonToolTip'

     OnClickSound=CS_Click
}
