//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4Tab_HudSettings extends UT2K4Tab_HudSettings;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Super.Initcomponent(MyController, MyOwner);

	RemoveComponent(co_CustomHUD);
	RemoveComponent(ch_Score);
//	RemoveComponent(ch_Portraits);
//	RemoveComponent(ch_VCPortraits);
	RemoveComponent(ch_EnemyNames);
	RemoveComponent(sl_Red);
	RemoveComponent(sl_Blue);
	RemoveComponent(sl_Green);
	RemoveComponent(i_Preview);
	RemoveComponent(i_PreviewBG);
	RemoveComponent(i_Scale);
	RemoveComponent(ch_CustomColor);

	fScale = PlayerOwner().myHUD.HudScale * 100;
	fOpacity = (PlayerOwner().myHUD.HudOpacity / 255) * 100;

	sl_Scale.SetValue(fScale);
	sl_Opacity.SetValue(fOpacity);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=GameBK
         Caption="Options"
         WinTop=0.057604
         WinLeft=0.031797
         WinWidth=0.448633
         WinHeight=0.801485
         RenderWeight=0.001000
         OnPreDraw=GameBK.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'ROInterface.ROUT2K4Tab_HudSettings.GameBK'

     Begin Object Class=GUISectionBackground Name=GameBK1
         Caption="Visuals"
         WinTop=0.060208
         WinLeft=0.517578
         WinWidth=0.448633
         WinHeight=0.801485
         RenderWeight=0.001000
         OnPreDraw=GameBK1.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'ROInterface.ROUT2K4Tab_HudSettings.GameBK1'

}
