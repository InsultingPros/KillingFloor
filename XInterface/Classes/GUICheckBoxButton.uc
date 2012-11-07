// ====================================================================
//  Class:  UT2K4UI.GUIGFXButton
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUICheckBoxButton extends GUIGFXButton
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()	Material	CheckedOverlay[10];
var()   bool		bAllOverlay;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyController, MyOwner);

	for ( i = 0; i < ArrayCount(CheckedOverlay); i++ )
	{
		if ( CheckedOverlay[i] == None )
			CheckedOverlay[i] = Graphic;
	}
}

defaultproperties
{
     CheckedOverlay(0)=Texture'KF_InterfaceArt_tex.Menu.Checkbox'
     CheckedOverlay(1)=Texture'KF_InterfaceArt_tex.Menu.checkbox_highlight'
     CheckedOverlay(2)=Texture'KF_InterfaceArt_tex.Menu.Checkbox'
     CheckedOverlay(3)=Texture'KF_InterfaceArt_tex.Menu.Checkbox'
     CheckedOverlay(4)=Texture'KF_InterfaceArt_tex.Menu.Checkbox'
     ImageIndex=4
     Position=ICP_Scaled
     bCheckBox=True
     StyleName="CheckBox"
     bTabStop=True
}
