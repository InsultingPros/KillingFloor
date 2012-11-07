//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2k4ModelSelect extends UT2k4ModelSelect;

var()	Texture				mytexture;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	SpinnyDude.SetDrawScale(0.8);

    sb_Main.HeaderTop=mytexture;
    sb_Main.HeaderBar=mytexture;
    sb_Main.HeaderBase=mytexture;

    /*myStyleName = "ROTitleBar";
    t_WindowTitle.StyleName = myStyleName;
    t_WindowTitle.Style = MyController.GetStyle(myStyleName,t_WindowTitle.FontScale);*/

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);
}

function bool SystemMenuPreDraw(canvas Canvas)
{
	b_ExitButton.SetPosition( t_WindowTitle.ActualLeft() + (t_WindowTitle.ActualWidth()-35), t_WindowTitle.ActualTop()+10, 24, 24, true);
	return true;
}
function RefreshCharacterList(string ExcludedChars, optional string Race)
{
	local int i, j;
	local array<string> Excluded;
	local bool blocked;

	// Prevent list from calling OnChange events
	CharList.List.bNotify = False;
	CharList.Clear();

	Split(ExcludedChars, ";", Excluded);
	for(i=0; i<PlayerList.Length; i++)
	{
		if ( Race == "" || Race ~= Playerlist[i].Race )
		{
			// Check that this character is selectable
			if ( PlayerList[i].Menu != "" )
			{
				for (j = 0; j < Excluded.Length; j++)
					if ( InStr(";" $ Playerlist[i].Menu $ ";", ";" $ Excluded[j] $ ";") != -1 )
						break;

				if ( j < Excluded.Length )
					continue;
			}

			bLocked = false;
			CharList.List.Add( Playerlist[i].Portrait, i, int(bLocked) );
            //log("Race "$Playerlist[i].Race);
            //log("DefaultName "$Playerlist[i].DefaultName);
            //log("MeshName "$Playerlist[i].MeshName);
            //log("TextName "$Playerlist[i].TextName);
		}
	}

	CharList.List.LockedMat = LockedImage;
	CharList.List.bNotify = True;
}

defaultproperties
{
     MyTexture=Texture'InterfaceArt_tex.Menu.button_normal'
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'InterfaceArt_tex.Menu.button_normal'
         DropShadow=None
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.020000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=0.980000
         RenderWeight=0.000003
     End Object
     i_FrameBG=FloatingImage'ROInterface.ROUT2k4ModelSelect.FloatingFrameBackground'

}
