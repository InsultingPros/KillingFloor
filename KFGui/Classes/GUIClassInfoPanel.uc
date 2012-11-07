class GUIClassInfoPanel extends GUIPanel;

var automated GUIImage i_back;

function Display(GUIClassSelectable item);

defaultproperties
{
     Begin Object Class=GUIImage Name=Background
         Image=Texture'Engine.WhiteSquareTexture'
         ImageColor=(B=0,G=0,R=0)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinHeight=1.000000
     End Object
     i_back=GUIImage'KFGui.GUIClassInfoPanel.Background'

}
