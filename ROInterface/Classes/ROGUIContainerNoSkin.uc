//-----------------------------------------------------------
// ROGUIContainerNoSkin
// Class used to 'contain' other components.
// Same as ROGUIContainer but with no background skin &
// caption.
// emh -- 11/12/2005
//-----------------------------------------------------------

class ROGUIContainerNoSkin extends ROGUIContainer;

defaultproperties
{
     bNoCaption=True
     HeaderBase=Texture'InterfaceArt_tex.Menu.empty'
     ImageOffset(0)=0.000000
     ImageOffset(1)=0.000000
     ImageOffset(2)=0.000000
     ImageOffset(3)=0.000000
     ImageStyle=ISTY_Stretched
}
