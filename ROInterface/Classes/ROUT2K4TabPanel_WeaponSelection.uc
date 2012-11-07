//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
class ROUT2K4TabPanel_WeaponSelection extends Settings_Tabs;

var automated GUIButton b_selectUnitButton;
var automated GUISectionBackground i_PrimaryWeaponBG, i_SecondaryWeaponBG,
                                i_GrenadeBG;

var automated moComboBox primaryCombo, secondaryCombo, grenadeCombo;

var automated GUIScrollTextBox  sc_PrimaryWeapDescr, sc_SecondaryWeapDescr, sc_GrenadeDescr;


var  ROGameReplicationInfo GRI;

var RORoleInfo currentRole;
var int currentRoleIndex;

var	localized string NoneText;

var SpinnyWeap			SpinnyWeap; // MUST be set to null when you leave the window
var SpinnyWeap			SpinnyWeap2; // MUST be set to null when you leave the window
var SpinnyWeap			SpinnyWeap3; // MUST be set to null when you leave the window
var() vector				SpinnyWeapOffset;
var() vector				SpinnyWeapOffset2;
var() vector				SpinnyWeapOffset3;


delegate OnSelect();

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
     super.InitComponent(MyController,MyOwner);

     class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

     GRI = ROGameReplicationInfo(PlayerOwner().GameReplicationInfo);
     currentRoleIndex = -1;
     //log("ROUT2K4TabPanel_WeaponSelection::InitComponent()");
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function bool InternalOnClick( GUIComponent Sender )
{
   local ROPlayer player;
   player = ROPlayer(PlayerOwner());
   player.ChangeRole(currentRoleIndex);
   player.ChangeWeapons(int(PrimaryCombo.GetExtra()), int(SecondaryCombo.GetExtra()), int(GrenadeCombo.GetExtra()));
   OnSelect();
   UpdateCurrentWeapon(SpinnyWeap,0);
   UpdateCurrentWeapon(SpinnyWeap2,1);
   UpdateCurrentWeapon(SpinnyWeap3,2);
   return true;
}
//------------------------------------------------------------------------------
// @description: populate combos and all info for weapon selection based on
// role index
//------------------------------------------------------------------------------
function setRoleByIndex(int index)
{
    if(PlayerOwner().PlayerReplicationInfo == none ||
        PlayerOwner().PlayerReplicationInfo.Team == none ||
        PlayerOwner().PlayerReplicationInfo.Team.TeamIndex > 1)
        return ;
    switch( PlayerOwner().PlayerReplicationInfo.Team.TeamIndex )
    {
        case AXIS_TEAM_INDEX: currentRole =  GRI.AxisRoles[index];
        break;

        case ALLIES_TEAM_INDEX:  currentRole =  GRI.AlliesRoles[index];
        break;
    }
    currentRoleIndex = index;
    updatePrimaryCombo();
    updatePrimaryInfo();
    updateSecondaryCombo();
    updateSecondaryInfo();
    updateGrenadeCombo();
    updateGrenadeInfo();
   UpdateCurrentWeapon(SpinnyWeap,0);
   UpdateCurrentWeapon(SpinnyWeap2,1);
   UpdateCurrentWeapon(SpinnyWeap3,2);

}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updatePrimaryCombo()
{
   // Update primary
   local int i;
   if(currentRole == none)
       return;
   // Remove all entries
	if (PrimaryCombo.ItemCount() > 0)
		PrimaryCombo.RemoveItem(0, PrimaryCombo.ItemCount());

	for (i = 0; i < ArrayCount(currentRole.PrimaryWeapons); i++)
	{
		if (currentRole.PrimaryWeapons[i].Item != None)
			primaryCombo.AddItem(currentRole.PrimaryWeapons[i].Item.default.ItemName,, string(i));
	}

	if (primaryCombo.ItemCount() == 0)
		primaryCombo.AddItem(NoneText,, "-2");


}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updatePrimaryInfo()
{

	local string S;
	local int Loc;

	if (currentRole == None || int(primaryCombo.GetExtra()) < 0)
	{
//		sc_PrimaryWeapDescr.SetContent(Controller.LoadDecoText("ROWeapons", "Default"));
		return;
	}

	S = string(currentRole.PrimaryWeapons[int(primaryCombo.GetExtra())].Item);
    //log("updatePrimaryInfo(), S = "$S);
	Loc = InStr(S, ".");

	if (Loc != -1)
		S = Mid(S, Loc + 1);
    //log("updatePrimaryInfo(), S = "$S);
//	sc_PrimaryWeapDescr.SetContent(Controller.LoadDecoText("ROWeapons", S));
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updateSecondaryInfo()
{
   local string S;
	local int Loc;

	if (currentRole == None || int(secondaryCombo.GetExtra()) < 0)
	{
//		sc_SecondaryWeapDescr.SetContent(Controller.LoadDecoText("ROWeapons", "Default"));
		return;
	}

	S = string(currentRole.SecondaryWeapons[int(secondaryCombo.GetExtra())].Item);

	Loc = InStr(S, ".");

	if (Loc != -1)
		S = Mid(S, Loc + 1);

//	sc_SecondaryWeapDescr.SetContent(Controller.LoadDecoText("ROWeapons", S));
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updateGrenadeInfo()
{
   local string S;
	local int Loc;

	if (currentRole == None || int(grenadeCombo.GetExtra()) < 0)
	{
//		sc_SecondaryWeapDescr.SetContent(Controller.LoadDecoText("ROWeapons", "Default"));
		return;
	}

	S = string(currentRole.Grenades[int(grenadeCombo.GetExtra())].Item);

	Loc = InStr(S, ".");

	if (Loc != -1)
		S = Mid(S, Loc + 1);

//	sc_GrenadeDescr.SetContent(Controller.LoadDecoText("ROWeapons", S));
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updateSecondaryCombo()
{
  local int i;
  if(currentRole == none)
     return;
  if (secondaryCombo.ItemCount() > 0)
		secondaryCombo.RemoveItem(0, secondaryCombo.ItemCount());
   // Update secondary
	for (i = 0; i < ArrayCount(currentRole.SecondaryWeapons); i++)
	{
		if (currentRole.SecondaryWeapons[i].Item != None)
			SecondaryCombo.AddItem(currentRole.SecondaryWeapons[i].Item.default.ItemName,, string(i));
	}
	if (SecondaryCombo.ItemCount() == 0)
		SecondaryCombo.AddItem(NoneText,, "-2");

}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updateGrenadeCombo()
{
  local int i;
  if(currentRole == none)
     return;

   if (grenadeCombo.ItemCount() > 0)
		grenadeCombo.RemoveItem(0, grenadeCombo.ItemCount());

   // Update grenades
	for (i = 0; i < ArrayCount(currentRole.Grenades); i++)
	{
		if (currentRole.Grenades[i].Item != None)
			grenadeCombo.AddItem(currentRole.Grenades[i].Item.default.ItemName,, string(i));
	}

	if (grenadeCombo.ItemCount() == 0)
		grenadeCombo.AddItem(NoneText,, "-2");
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function OnComboChange(GUIComponent Sender)
{
	switch (Sender)
	{
		case PrimaryCombo:
			updatePrimaryInfo();
			break;
		case SecondaryCombo:
			updateSecondaryInfo();
			break;
		case GrenadeCombo:
			updateGrenadeInfo();
			break;
	}
   UpdateCurrentWeapon(SpinnyWeap,0);
   UpdateCurrentWeapon(SpinnyWeap2,1);
   UpdateCurrentWeapon(SpinnyWeap3,2);
}

/*********** Needed for SpinnyWeap Puma 5-19-2004**********/

function ReallyInitializeWeaponList()
{

	// Spawn spinny weapon actor
	if ( SpinnyWeap == None )
		SpinnyWeap = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
	SpinnyWeap.SetRotation(PlayerOwner().Rotation);
	if ( SpinnyWeap2 == None )
		SpinnyWeap2 = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
	SpinnyWeap2.SetRotation(PlayerOwner().Rotation);
	if ( SpinnyWeap3 == None )
		SpinnyWeap3 = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
	SpinnyWeap3.SetRotation(PlayerOwner().Rotation);
	SpinnyWeap.SetStaticMesh(None);
	SpinnyWeap2.SetStaticMesh(None);
	SpinnyWeap3.SetStaticMesh(None);

   UpdateCurrentWeapon(SpinnyWeap,0);
   UpdateCurrentWeapon(SpinnyWeap2,1);
   UpdateCurrentWeapon(SpinnyWeap3,2);

	FocusFirst(none);
}

function ShowPanel(bool bShow)
{
	local rotator R;

	Super.ShowPanel(bShow);

	if (bShow)
	{
		if ( bInit )
		{
	        ReallyInitializeWeaponList();
			bInit = False;
		}

		if ( SpinnyWeap != None )
		{
			R = PlayerOwner().Rotation;
//			R.Yaw = 31000;
			SpinnyWeap.SetRotation(R);
		}
		if ( SpinnyWeap2 != None )
		{
			R = PlayerOwner().Rotation;
			R.Yaw = 31000;
			SpinnyWeap2.SetRotation(R);
		}
		if ( SpinnyWeap3 != None )
		{
			R = PlayerOwner().Rotation;
			R.Yaw = 31000;
			SpinnyWeap3.SetRotation(R);
		}
	}
}

function InternalDraw(Canvas canvas)
{
	local vector CamPos, X, Y, Z, WX, WY, WZ;
	local rotator CamRot;

	canvas.GetCameraLocation(CamPos, CamRot);
	GetAxes(CamRot, X, Y, Z);

	GetAxes(SpinnyWeap.Rotation, WX, WY, WZ);
	SpinnyWeap.SetLocation(CamPos + (SpinnyWeapOffset.X * X) + (SpinnyWeapOffset.Y * Y) + (SpinnyWeapOffset.Z * Z) - (30 * WX));
	canvas.DrawActorClipped(SpinnyWeap, false, i_PrimaryWeaponBG.ClientBounds[0], i_PrimaryWeaponBG.ClientBounds[1], i_PrimaryWeaponBG.ClientBounds[2] - i_PrimaryWeaponBG.ClientBounds[0], (i_PrimaryWeaponBG.ClientBounds[3] - i_PrimaryWeaponBG.ClientBounds[1]), true, 90.0);

	if(!( int(secondaryCombo.GetExtra()) < 0))
	{
        GetAxes(SpinnyWeap2.Rotation, WX, WY, WZ);
	    SpinnyWeap2.SetLocation(CamPos + (SpinnyWeapOffset.X * X) + (SpinnyWeapOffset.Y * Y) + (SpinnyWeapOffset.Z * Z) - (20 * WX));
	    canvas.DrawActorClipped(SpinnyWeap2, false, i_SecondaryWeaponBG.ClientBounds[0], i_SecondaryWeaponBG.ClientBounds[1], i_SecondaryWeaponBG.ClientBounds[2] - i_SecondaryWeaponBG.ClientBounds[0], (i_SecondaryWeaponBG.ClientBounds[3] - i_SecondaryWeaponBG.ClientBounds[1]), true, 90.0);
     }

	GetAxes(SpinnyWeap3.Rotation, WX, WY, WZ);
	SpinnyWeap3.SetLocation(CamPos + (SpinnyWeapOffset.X * X) + (SpinnyWeapOffset.Y * Y) + (SpinnyWeapOffset.Z * Z) - (20 * WX));
	canvas.DrawActorClipped(SpinnyWeap3, false, i_GrenadeBG.ClientBounds[0], i_GrenadeBG.ClientBounds[1], i_GrenadeBG.ClientBounds[2] - i_GrenadeBG.ClientBounds[0], (i_GrenadeBG.ClientBounds[3] - i_GrenadeBG.ClientBounds[1]), true, 90.0);


}

function UpdateCurrentWeapon(SpinnyWeap MySpinnyWeap, int weaponClass)
{
	local class<InventoryAttachment> AttachClass;
	local float defscale;
	local vector Scale3D;
	local int i;

   local ROPlayer player;
   player = ROPlayer(PlayerOwner());

    if(MySpinnyWeap == None)
    {
		return;
    }

    if(currentRole == none)
		return;

    if ( weaponClass == 0)
    {
        if(currentRole.PrimaryWeapons[int(primaryCombo.GetExtra())].Item != None)
        {
            AttachClass=currentRole.PrimaryWeapons[int(primaryCombo.GetExtra())].Item.default.AttachmentClass;
        }
    }
    else if ( weaponClass == 1)
    {
        if(currentRole.SecondaryWeapons[int(primaryCombo.GetExtra())].Item != None)
        {
            AttachClass=currentRole.SecondaryWeapons[int(primaryCombo.GetExtra())].Item.default.AttachmentClass;
        }
     }
    else if ( weaponClass == 2)
    {
        if(currentRole.Grenades[int(primaryCombo.GetExtra())].Item != None)
        {
            AttachClass=currentRole.Grenades[int(primaryCombo.GetExtra())].Item.default.AttachmentClass;
        }
     }

	if ( AttachClass != None && AttachClass.default.Mesh != None )
	{
		defscale = AttachClass.default.DrawScale;
		Scale3D = AttachClass.default.DrawScale3D;
		if ( Scale3D.X > 1.0 )
			Scale3D.X = 1.0;

		if ( Scale3D.Y > 1.0 )
			Scale3D.Y = 1.0;
	}

	else
	{
		defscale = 0.5;
		Scale3D = vect(1,1,1);
	}

		if(attachClass != None && attachClass.default.Mesh != None)
		{
			MySpinnyWeap.SetStaticMesh( None );
			MySpinnyWeap.LinkMesh( attachClass.default.Mesh );
			MySpinnyWeap.SetDrawScale( 1.3 * defscale );

			// Set skins array on spinnyweap to the same as the pickup class.
			MySpinnyWeap.Skins.Length = attachClass.default.Skins.Length;
			for(i=0; i<attachClass.default.Skins.Length; i++)
			{
				MySpinnyWeap.Skins[i] = attachClass.default.Skins[i];
			}


			MySpinnyWeap.SetDrawType(DT_Mesh);
		}
	    else
			log("Weapon: Could not find graphic for weapon: ");


}

event Opened(GUIComponent Sender)
{
	local rotator R;

	Super.Opened(Sender);

	if ( SpinnyWeap != None )
	{
		R.Yaw = 32768;
		SpinnyWeap.SetRotation(R+PlayerOwner().Rotation);
		SpinnyWeap.bHidden = false;
	}
	if ( SpinnyWeap2 != None )
	{
		R.Yaw = 32768;
		SpinnyWeap2.SetRotation(R+PlayerOwner().Rotation);
		SpinnyWeap2.bHidden = false;
	}
	if ( SpinnyWeap3 != None )
	{
		R.Yaw = 32768;
		SpinnyWeap3.SetRotation(R+PlayerOwner().Rotation);
		SpinnyWeap3.bHidden = false;
	}
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);

	if ( SpinnyWeap != None )
		SpinnyWeap.bHidden = true;
	if ( SpinnyWeap2 != None )
		SpinnyWeap2.bHidden = true;
	if ( SpinnyWeap3 != None )
		SpinnyWeap3.bHidden = true;
}

event Free()
{
	if ( SpinnyWeap != None )
	{
		SpinnyWeap.Destroy();
		SpinnyWeap = None;
	}
	if ( SpinnyWeap2 != None )
	{
		SpinnyWeap2.Destroy();
		SpinnyWeap2 = None;
	}
	if ( SpinnyWeap3 != None )
	{
		SpinnyWeap3.Destroy();
		SpinnyWeap3 = None;
	}

	Super.Free();
}
/*********** End Needed for SpinnyWeap **********/

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

defaultproperties
{
     Begin Object Class=GUIButton Name=SelectButton
         Caption="Enter Game"
         Hint="Select Weapon and start game."
         WinTop=0.992153
         WinLeft=0.796436
         WinWidth=0.139474
         WinHeight=0.052944
         TabOrder=3
         OnClick=ROUT2K4TabPanel_WeaponSelection.InternalOnClick
         OnKeyEvent=SelectButton.InternalOnKeyEvent
     End Object
     b_selectUnitButton=GUIButton'ROInterface.ROUT2K4TabPanel_WeaponSelection.SelectButton'

     Begin Object Class=GUISectionBackground Name=PrimaryWeaponBG
         HeaderTop=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBar=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBase=Texture'InterfaceArt_tex.Menu.button_normal'
         WinTop=0.014000
         WinLeft=0.024219
         WinWidth=0.950000
         WinHeight=0.300000
         OnPreDraw=PrimaryWeaponBG.InternalPreDraw
     End Object
     i_PrimaryWeaponBG=GUISectionBackground'ROInterface.ROUT2K4TabPanel_WeaponSelection.PrimaryWeaponBG'

     Begin Object Class=GUISectionBackground Name=SecondaryWeaponBG
         HeaderTop=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBar=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBase=Texture'InterfaceArt_tex.Menu.button_normal'
         WinTop=0.344000
         WinLeft=0.024219
         WinWidth=0.950000
         WinHeight=0.300000
         OnPreDraw=SecondaryWeaponBG.InternalPreDraw
     End Object
     i_SecondaryWeaponBG=GUISectionBackground'ROInterface.ROUT2K4TabPanel_WeaponSelection.SecondaryWeaponBG'

     Begin Object Class=GUISectionBackground Name=GrenadeBG
         HeaderTop=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBar=Texture'InterfaceArt_tex.Menu.button_normal'
         HeaderBase=Texture'InterfaceArt_tex.Menu.button_normal'
         WinTop=0.674000
         WinLeft=0.024219
         WinWidth=0.950000
         WinHeight=0.300000
         OnPreDraw=GrenadeBG.InternalPreDraw
     End Object
     i_GrenadeBG=GUISectionBackground'ROInterface.ROUT2K4TabPanel_WeaponSelection.GrenadeBG'

     Begin Object Class=moComboBox Name=PrimaryComboB
         bReadOnly=True
         CaptionWidth=0.450000
         Caption="Primary Weapon"
         OnCreateComponent=PrimaryComboB.InternalOnCreateComponent
         Hint="Select your primary weapon"
         WinTop=0.056350
         WinLeft=0.064063
         WinHeight=0.060000
         OnChange=ROUT2K4TabPanel_WeaponSelection.OnComboChange
     End Object
     primaryCombo=moComboBox'ROInterface.ROUT2K4TabPanel_WeaponSelection.PrimaryComboB'

     Begin Object Class=moComboBox Name=SecondaryComboB
         bReadOnly=True
         CaptionWidth=0.450000
         Caption="Secondary Weapon"
         OnCreateComponent=SecondaryComboB.InternalOnCreateComponent
         Hint="Select your secondary weapon"
         WinTop=0.386350
         WinLeft=0.064063
         WinHeight=0.060000
         OnChange=ROUT2K4TabPanel_WeaponSelection.OnComboChange
     End Object
     secondaryCombo=moComboBox'ROInterface.ROUT2K4TabPanel_WeaponSelection.SecondaryComboB'

     Begin Object Class=moComboBox Name=grenadeComboB
         bReadOnly=True
         CaptionWidth=0.450000
         Caption="Grenades"
         OnCreateComponent=grenadeComboB.InternalOnCreateComponent
         Hint="Select your grenades"
         WinTop=0.716350
         WinLeft=0.064063
         WinHeight=0.060000
         OnChange=ROUT2K4TabPanel_WeaponSelection.OnComboChange
     End Object
     grenadeCombo=moComboBox'ROInterface.ROUT2K4TabPanel_WeaponSelection.grenadeComboB'

     Begin Object Class=GUIScrollTextBox Name=PrimaryWeapDescrScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=PrimaryWeapDescrScroll.InternalOnCreateComponent
         WinTop=0.080000
         WinLeft=0.072190
         WinWidth=0.500000
         WinHeight=0.210000
         TabOrder=9
     End Object
     sc_PrimaryWeapDescr=GUIScrollTextBox'ROInterface.ROUT2K4TabPanel_WeaponSelection.PrimaryWeapDescrScroll'

     Begin Object Class=GUIScrollTextBox Name=SecondaryWeapDescrScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=SecondaryWeapDescrScroll.InternalOnCreateComponent
         WinTop=0.410000
         WinLeft=0.072190
         WinWidth=0.500000
         WinHeight=0.210000
         TabOrder=9
     End Object
     sc_SecondaryWeapDescr=GUIScrollTextBox'ROInterface.ROUT2K4TabPanel_WeaponSelection.SecondaryWeapDescrScroll'

     Begin Object Class=GUIScrollTextBox Name=GrenadeDescrScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=GrenadeDescrScroll.InternalOnCreateComponent
         WinTop=0.740000
         WinLeft=0.072190
         WinWidth=0.500000
         WinHeight=0.210000
         TabOrder=9
     End Object
     sc_GrenadeDescr=GUIScrollTextBox'ROInterface.ROUT2K4TabPanel_WeaponSelection.GrenadeDescrScroll'

     NoneText="None"
     SpinnyWeapOffset=(X=100.000000,Y=1.500000,Z=-7.000000)
     PanelCaption="Weapon"
     OnRendered=ROUT2K4TabPanel_WeaponSelection.InternalDraw
}
