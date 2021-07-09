//=============================================================================
// ROSTY2SelectTab
//=============================================================================
// The style is used to display the tabs at the bottom of the team select
// screen
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROSTY2SelectTab extends ROSTY2SquareButton;

defaultproperties
{
     KeyName="SelectTab"
     Images(0)=Texture'InterfaceArt_tex.SelectMenus.Tab_unpressed'
     Images(1)=Texture'InterfaceArt_tex.SelectMenus.Tab_watched'
     Images(2)=Texture'InterfaceArt_tex.SelectMenus.Tab_unpressed'
     Images(3)=Texture'InterfaceArt_tex.SelectMenus.Tab_pressed'
     Images(4)=Texture'InterfaceArt_tex.SelectMenus.Tab_unpressed'
     ImgStyle(0)=ISTY_Scaled
     ImgStyle(1)=ISTY_Scaled
     ImgStyle(2)=ISTY_Scaled
     ImgStyle(3)=ISTY_Scaled
     ImgStyle(4)=ISTY_Scaled
}
