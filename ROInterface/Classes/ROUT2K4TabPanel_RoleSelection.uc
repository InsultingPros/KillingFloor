//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ROUT2K4TabPanel_RoleSelection extends UT2K4TabPanel;

const NUM_ROLES = 10;

var automated   BackgroundImage i_Background;
var automated GUIButton b_selectUnitButton;
var automated GUIListBox  lb_Roles;
var automated GUISectionBackground i_RolesBG, i_RolesDescriptionBG;
var automated GUIScrollTextBox lb_RoleDesc;
var	automated GUIImage			RoleImage;

var GUIList                        li_Roles;

var	ROGameReplicationInfo		GRI;
var int lastTeamIndex;
var RORoleInfo currentRole;
var int currentRoleIndex;

// weapon selection
var automated GUISectionBackground i_PrimaryWeaponBG, i_SecondaryWeaponBG,
                                i_GrenadeBG;
var automated moComboBox primaryCombo, secondaryCombo, grenadeCombo;
var automated GUIImage	i_PrimaryImage, i_SecondaryImage, i_GrenadeImage;

var	localized string NoneText;

delegate OnSelect(int index);



function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local ROPlayer player;
    local ROPlayerReplicationInfo playerRep;

    Super.InitComponent(MyController, MyOwner);

    class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    GRI = ROGameReplicationInfo(PlayerOwner().GameReplicationInfo);

    player = ROPlayer(PlayerOwner());
    playerRep = ROPlayerReplicationInfo(player.PlayerReplicationInfo);
    if(playerRep != none && playerRep.RoleInfo != none)
    { //already has a role, init
      currentRole = playerRep.RoleInfo;
    }
    lastTeamIndex = -1;
    li_Roles = lb_Roles.List;
    li_Roles.TextAlign = TXTA_Left;
    setTimer(0.2,true);

    /*myStyleName = "ROScrollZone";
    lb_RoleDesc.MyScrollBar.MyScrollZone.StyleName = myStyleName;
    lb_RoleDesc.MyScrollBar.MyScrollZone.Style = MyController.GetStyle(myStyleName,lb_RoleDesc.MyScrollBar.MyScrollZone.FontScale);
    myStyleName = "RORoundScaledButton";
    lb_RoleDesc.MyScrollBar.MyGripButton.StyleName = myStyleName;
    lb_RoleDesc.MyScrollBar.MyGripButton.Style = MyController.GetStyle(myStyleName,lb_RoleDesc.MyScrollBar.MyGripButton.FontScale);
    lb_RoleDesc.MyScrollBar.MyIncreaseButton.StyleName = myStyleName;
    lb_RoleDesc.MyScrollBar.MyIncreaseButton.Style = MyController.GetStyle(myStyleName,lb_RoleDesc.MyScrollBar.MyIncreaseButton.FontScale);
    lb_RoleDesc.MyScrollBar.MyDecreaseButton.StyleName = myStyleName;
    lb_RoleDesc.MyScrollBar.MyDecreaseButton.Style = MyController.GetStyle(myStyleName,lb_RoleDesc.MyScrollBar.MyDecreaseButton.FontScale);


    myStyleName = "ROItemOutline";
    lb_Roles.List.OutLineStyleName = myStyleName;
    lb_Roles.List.OutLineStyle = MyController.GetStyle(myStyleName,lb_Roles.List.FontScale);
    myStyleName = "ROListSelection";
    lb_Roles.List.SelectedStyleName = myStyleName;
    lb_Roles.List.SelectedStyle = MyController.GetStyle(myStyleName,lb_Roles.List.FontScale);
    */
}

function setCurrentRoleSelection()
{
    local int count;
    local RORoleInfo role;
    if(currentRole != none)
    { //set the current
      for(count = 0; count < li_Roles.ItemCount; count++)
      {
         role =  RORoleInfo(li_Roles.GetObjectAtIndex(count));
         if(role.AltName == currentRole.AltName)
         {
            li_Roles.SetIndex(count);
            return;
         }
      }
    }
    else
    {//select the first one
      if( li_Roles.ItemCount > 0)
      {
         li_Roles.SetIndex(0);
         role =  RORoleInfo(li_Roles.GetObjectAtIndex(0));
         count = findRoleIndexByAltName(role.AltName);
         ROPlayer(PlayerOwner()).ChangeRole(count);
      }

    }
}

function populateRoleList()
{
    local 	int 	count,
					whichTeamIndex,
					roleLimit;

    whichTeamIndex = PlayerOwner().PlayerReplicationInfo.Team.TeamIndex;


    for(count = 0 ; count < NUM_ROLES ; count++)
    {

       switch(lastTeamIndex)
       {
         case AXIS_TEAM_INDEX :

         if(GRI.AxisRoles[count] != none)
         {
         	roleLimit = GRI.AxisRoles[count].Limit;

             // if the role isn't limited, don't have a zero tacked onto the end
         	if( roleLimit == 0 )
         	{
            	li_Roles.Add(GRI.AxisRoles[count].default.MyName$" ["$GRI.AxisRoleCount[count]$"]",
              		GRI.AxisRoles[count]);
         	}
         	else
         	{
            	li_Roles.Add(GRI.AxisRoles[count].default.MyName$" ["$GRI.AxisRoleCount[count]$"/"$GRI.AxisRoles[count].Limit$"]",
              		GRI.AxisRoles[count]);
            }
         }

         break;

         case ALLIES_TEAM_INDEX :
         if(GRI.AlliesRoles[count] != none)
         {
         	roleLimit = GRI.AlliesRoles[count].Limit;

             // if the role isn't limited, don't have a zero tacked onto the end
			if( roleLimit == 0 )
			{
            	li_Roles.Add(GRI.AlliesRoles[count].default.MyName$" ["$GRI.AlliesRoleCount[count]$"]",
              		GRI.AlliesRoles[count]);
			}
			else
			{
            	li_Roles.Add(GRI.AlliesRoles[count].default.MyName$" ["$GRI.AlliesRoleCount[count]$"/"$GRI.AlliesRoles[count].Limit$"]",
              		GRI.AlliesRoles[count]);
            }
         }
         break;
       }
    }
    li_Roles.SortList();

}

function refreshRoleCount()
{
	local 	int 		count, roleLimit, roleCount, roleBotCount, roleIndex;
   	local 	RORoleInfo 	role;

    if(PlayerOwner().PlayerReplicationInfo == none ||
       	PlayerOwner().PlayerReplicationInfo.Team == none ||
       	PlayerOwner().PlayerReplicationInfo.Team.TeamIndex > 1)
    {
    	return;
    }

   	for(count = 0 ; count <  li_Roles.Elements.Length ; count++)
   	{
	    role = none;
	    roleIndex = -1;
	    roleCount = 0;
	    roleBotCount = 0;

		if( PlayerOwner().PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX)
    	{
			role = RORoleInfo(li_Roles.GetObjectAtIndex(count));
			roleIndex = GRI.GetRoleIndex( role, AXIS_TEAM_INDEX);
			if(GRI.AxisRoles[roleIndex] != none)
         	{
         		roleLimit = GRI.AxisRoles[roleIndex].Limit;
         		roleCount = GRI.AxisRoleCount[roleIndex];
         		roleBotCount = GRI.AxisRoleBotCount[roleIndex];
				// if the role isn't limited, don't have a zero tacked onto the end
	        	if( roleLimit == 0 )
	        	{
	        		li_Roles.SetItemAtIndex(count,GRI.AxisRoles[roleIndex].default.MyName$" ["$roleCount$"]");
	        	}
	        	else if(roleBotCount > 0)
	        	{
	        		li_Roles.SetItemAtIndex(count,GRI.AxisRoles[roleIndex].default.MyName$" ["$roleCount$"/"$roleLimit$"] *");
	        	}
	        	else
	        	{
	        		if( roleCount >= roleLimit )
	        		{
	        			li_Roles.SetItemAtIndex(count,GRI.AxisRoles[roleIndex].default.MyName$"[Full]");
	        		}
	        		else
	        		{
	        			li_Roles.SetItemAtIndex(count,GRI.AxisRoles[roleIndex].default.MyName$" ["$roleCount$"/"$roleLimit$"]");
	        		}
	        	}
			}
    	}
    	else
    	{
			role = RORoleInfo(li_Roles.GetObjectAtIndex(count));

			roleIndex = GRI.GetRoleIndex( role, ALLIES_TEAM_INDEX);
			if(GRI.AlliesRoles[roleIndex] != none)
         	{
         		roleLimit = GRI.AlliesRoles[roleIndex].Limit;
         		roleCount = GRI.AlliesRoleCount[roleIndex];
         		roleBotCount = GRI.AlliesRoleBotCount[roleIndex];
				// if the role isn't limited, don't have a zero tacked onto the end
	        	if( roleLimit == 0 )
	        	{
	        		li_Roles.SetItemAtIndex(count,GRI.AlliesRoles[roleIndex].default.MyName$" ["$roleCount$"]");
	        	}
	        	else if(roleBotCount > 0)
	        	{
	        		li_Roles.SetItemAtIndex(count,GRI.AlliesRoles[roleIndex].default.MyName$" ["$roleCount$"/"$roleLimit$"] *");
	        	}
	        	else
	        	{
	        		if( roleCount >= roleLimit )
	        		{
	        			li_Roles.SetItemAtIndex(count,GRI.AlliesRoles[roleIndex].default.MyName$"[Full]");
	        		}
	        		else
	        		{
	        			li_Roles.SetItemAtIndex(count,GRI.AlliesRoles[roleIndex].default.MyName$" ["$roleCount$"/"$roleLimit$"]");
	        		}
	        	}
			}
    	}
   	}
}


function InitPreview()
{
    local RORoleInfo role;

    if(li_Roles != None)
    {
        role = RORoleInfo(li_Roles.GetObject());
        if(role != none)
        {
            //set role, show portrait and description
            lb_RoleDesc.SetContent(role.InfoText);
           //InfoText

        }
    }
}

function Timer()
{
	if (GRI == None)
	{
        GRI = ROGameReplicationInfo(PlayerOwner().GameReplicationInfo);
        li_Roles.Clear();
        populateRoleList();
        setCurrentRoleSelection();
        li_Roles.SetIndex(ROPlayer(PlayerOwner()).DesiredRole);
    }

    refreshRoleCount();
    if(lastTeamIndex != PlayerOwner().PlayerReplicationInfo.Team.TeamIndex)
    {
          lastTeamIndex = PlayerOwner().PlayerReplicationInfo.Team.TeamIndex;
          li_Roles.Clear();
          populateRoleList();
          setCurrentRoleSelection();
          li_Roles.SetIndex(ROPlayer(PlayerOwner()).DesiredRole);
    }
}

function bool InternalOnClick( GUIComponent Sender )
{
	local int roleIndex, roleCount, roleBotCount;
	local ROPlayer player;

	//log("ROUT2K4TabPanel_RoleSelection::InternalOnClick");
	if (!li_Roles.IsValid())
	    return false;

	//log("li_Roles.Index = "$li_Roles.Index);
	if(currentRole != none)
	{
		roleIndex =  findRoleIndexByAltName(currentRole.AltName);
		if(roleIndex == -1)
		 	return false;

		// If role already filled return false
		if(currentRole != none)
		{
				// if the role isn't limited no need to check
			if( currentRole.Limit != 0 )
			{
				if( PlayerOwner().PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX)
				{
					roleCount = GRI.AxisRoleCount[GRI.GetRoleIndex( currentRole, AXIS_TEAM_INDEX)];
					roleBotCount = GRI.AxisRoleCount[GRI.GetRoleIndex( currentRole, AXIS_TEAM_INDEX)];
				}
				else
				{
					roleCount = GRI.AlliesRoleCount[GRI.GetRoleIndex( currentRole, ALLIES_TEAM_INDEX)];
					roleBotCount = GRI.AlliesRoleCount[GRI.GetRoleIndex( currentRole, ALLIES_TEAM_INDEX)];
				}

				if((roleCount == currentRole.Limit) && (roleBotCount <= 0))     //RoleCounter
				{
				    PlayerOwner().ReceiveLocalizedMessage(class'RoleFullMsg');
				    controller.CloseMenu();
					return false;
		        }
			}
		}

		player = ROPlayer(PlayerOwner());

		player.ChangeRole(roleIndex);
		player.ChangeWeapons(int(PrimaryCombo.GetExtra()), int(SecondaryCombo.GetExtra()), int(GrenadeCombo.GetExtra()));
		OnSelect(roleIndex);
	}
   	UpdateCurrentWeapon();

   	return true;
}

function bool UpdateRoles()
{
   local int roleIndex;
   //log("ROUT2K4TabPanel_RoleSelection::InternalOnClick");
   if (!li_Roles.IsValid())
        return false;

   //log("li_Roles.Index = "$li_Roles.Index);
   if(currentRole != none)
   {
      roleIndex =  findRoleIndexByAltName(currentRole.AltName);
      if(roleIndex == -1)
         return false;
   }
   setRoleByIndex(roleIndex); // temp move to correct place
}

function int findRoleIndexByAltName(string altName)
{
   local int  count, whichTeamIndex;

   whichTeamIndex = PlayerOwner().PlayerReplicationInfo.Team.TeamIndex;
   //log("findRoleIndexByAltName, lastTeamIndex="$lastTeamIndex);
   for(count = 0 ; count < NUM_ROLES ; count++)
   {
        switch(lastTeamIndex)
        {
           case AXIS_TEAM_INDEX :
           if(GRI.AxisRoles[count] != none &&
              GRI.AxisRoles[count].AltName == altName)
           {
             // log("findRoleIndexByAltName("$altName$") index = "$count);
              return count;
           }
           break;
           case ALLIES_TEAM_INDEX :
           if(GRI.AlliesRoles[count] != none &&
              GRI.AlliesRoles[count].AltName == altName)
           {
              return count;
           }
           break;
        }
   }
   //not found
   return -1;
}
function OnRoleChange(GUIComponent Sender)
{
    currentRole = RORoleInfo(li_Roles.GetObject());//(li_Roles.Get());
    if(currentRole != none)
    {
        //set role, show portrait and description
        InitPreview();
        UpdateRoles();
        UpdateCurrentWeapon();
    }
}

function ShowPanel(bool bShow)
{

	super.ShowPanel(bShow);
	//log("ROUT2K4TabPanel_RoleSelection::ShowPanel("$bShow$")");
    /*if(lastTeamIndex == PlayerOwner().PlayerReplicationInfo.Team.TeamIndex)
    { // didn't change unit, don't do anything
      return;
    } */
	if (GRI == None)
        GRI = ROGameReplicationInfo(PlayerOwner().GameReplicationInfo);

    if(bShow)
    {
		if ( bInit )
		{
	        UpdateCurrentWeapon();
	        FocusFirst(none);
			bInit = False;
		}

       //log("PlayerOwner().PlayerReplicationInfo.Team.TeamIndex="$PlayerOwner().PlayerReplicationInfo.Team.TeamIndex);
       //log("lastTeamIndex="$lastTeamIndex);
       /*if(lastTeamIndex != PlayerOwner().PlayerReplicationInfo.Team.TeamIndex)
       { */

          li_Roles.Clear();
          populateRoleList();
          setCurrentRoleSelection();
      // }
       li_Roles.SetIndex(ROPlayer(PlayerOwner()).DesiredRole);

       setTimer(0.2,true);
    }
    else
    {
       //lastTeamIndex = PlayerOwner().PlayerReplicationInfo.Team.TeamIndex;
       setTimer(0.0,false);
    }

}

/*************************\
 * Weapon                *
\*************************/
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
        case AXIS_TEAM_INDEX:
             currentRole =  GRI.AxisRoles[index];
   		     RoleImage.Image = GRI.AxisRoles[index].default.MenuImage;
        break;

        case ALLIES_TEAM_INDEX:
             currentRole =  GRI.AlliesRoles[index];
 		     RoleImage.Image = GRI.AlliesRoles[index].default.MenuImage;
        break;
    }

    currentRoleIndex = index;
    updatePrimaryCombo();
    updatePrimaryInfo();
    updateSecondaryCombo();
    updateSecondaryInfo();
    updateGrenadeCombo();
    updateGrenadeInfo();
    UpdateCurrentWeapon();
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
		return;
	}

	S = string(currentRole.SecondaryWeapons[int(secondaryCombo.GetExtra())].Item);

	Loc = InStr(S, ".");

	if (Loc != -1)
		S = Mid(S, Loc + 1);

}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
function updateGrenadeInfo()
{
   local string S;
	local int Loc;

	if (currentRole == None || int(grenadeCombo.GetExtra()) < 0)
	{
		return;
	}

	S = string(currentRole.Grenades[int(grenadeCombo.GetExtra())].Item);

	Loc = InStr(S, ".");

	if (Loc != -1)
		S = Mid(S, Loc + 1);

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
   UpdateCurrentWeapon();
}

//function UpdateCurrentWeapon(SpinnyWeap MySpinnyWeap, int weaponClass)
function UpdateCurrentWeapon()
{
    local class<InventoryAttachment> AttachClass;
    local class<ROWeaponAttachment> WeaponAttach;

    local ROPlayer player;
    player = ROPlayer(PlayerOwner());

    if (currentRole != None)
    {
        i_PrimaryImage.Image = None;
        if(currentRole.PrimaryWeapons[int(primaryCombo.GetExtra())].Item != None)
        {
            AttachClass = currentRole.PrimaryWeapons[int(primaryCombo.GetExtra())].Item.default.AttachmentClass;
            WeaponAttach = class<ROWeaponAttachment>(AttachClass);
        	if ( (WeaponAttach != None) && (WeaponAttach.default.menuImage != None) )
        	{
              	i_PrimaryImage.Image =  WeaponAttach.default.menuImage;
            }
        }

        i_SecondaryImage.Image = None;
        if((int(secondaryCombo.GetExtra())>=0)&& (currentRole.SecondaryWeapons[int(secondaryCombo.GetExtra())].Item != None))
        {
            AttachClass = currentRole.SecondaryWeapons[int(secondaryCombo.GetExtra())].Item.default.AttachmentClass;
            WeaponAttach = class<ROWeaponAttachment>(AttachClass);
        	if ( (WeaponAttach != None) && (WeaponAttach.default.menuImage != None) )
        	{
              	i_SecondaryImage.Image =  WeaponAttach.default.menuImage;
            }
        }

        i_GrenadeImage.Image = None;
        if(currentRole.Grenades[int(grenadeCombo.GetExtra())].Item != None)
        {
            AttachClass = currentRole.Grenades[int(grenadeCombo.GetExtra())].Item.default.AttachmentClass;
            WeaponAttach = class<ROWeaponAttachment>(AttachClass);
        	if ( (WeaponAttach != None) && (WeaponAttach.default.menuImage != None) )
        	{
              	i_GrenadeImage.Image =  WeaponAttach.default.menuImage;
            }
        }
    }

}

defaultproperties
{
     Begin Object Class=GUIButton Name=SelectButton
         Caption="Select"
         Hint="Select Role."
         WinTop=0.930000
         WinLeft=0.796436
         WinWidth=0.139474
         WinHeight=0.052944
         TabOrder=3
         OnClick=ROUT2K4TabPanel_RoleSelection.InternalOnClick
         OnKeyEvent=SelectButton.InternalOnKeyEvent
     End Object
     b_selectUnitButton=GUIButton'ROInterface.ROUT2K4TabPanel_RoleSelection.SelectButton'

     Begin Object Class=GUIListBox Name=Roles
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=Roles.InternalOnCreateComponent
         WinTop=0.080000
         WinLeft=0.020000
         WinWidth=0.250000
         WinHeight=0.330000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=ROUT2K4TabPanel_RoleSelection.OnRoleChange
     End Object
     lb_Roles=GUIListBox'ROInterface.ROUT2K4TabPanel_RoleSelection.Roles'

     Begin Object Class=GUISectionBackground Name=RolesBG
         Caption="Role Selection"
         WinTop=0.010000
         WinWidth=0.300000
         WinHeight=0.500000
         OnPreDraw=RolesBG.InternalPreDraw
     End Object
     i_RolesBG=GUISectionBackground'ROInterface.ROUT2K4TabPanel_RoleSelection.RolesBG'

     Begin Object Class=GUISectionBackground Name=RolesDescriptionBG
         Caption="Role Description"
         WinTop=0.500000
         WinWidth=0.500000
         WinHeight=0.424000
         OnPreDraw=RolesDescriptionBG.InternalPreDraw
     End Object
     i_RolesDescriptionBG=GUISectionBackground'ROInterface.ROUT2K4TabPanel_RoleSelection.RolesDescriptionBG'

     Begin Object Class=GUIScrollTextBox Name=RoleDescription
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=RoleDescription.InternalOnCreateComponent
         WinTop=0.540000
         WinLeft=0.020000
         WinWidth=0.470000
         WinHeight=0.360000
         bTabStop=False
         bNeverFocus=True
     End Object
     lb_RoleDesc=GUIScrollTextBox'ROInterface.ROUT2K4TabPanel_RoleSelection.RoleDescription'

     Begin Object Class=GUIImage Name=RoleImg
         Image=Texture'Engine.WhiteSquareTexture'
         ImageStyle=ISTY_Scaled
         WinTop=0.030000
         WinLeft=0.320000
         WinWidth=0.180000
         WinHeight=0.470000
     End Object
     RoleImage=GUIImage'ROInterface.ROUT2K4TabPanel_RoleSelection.RoleImg'

     Begin Object Class=GUISectionBackground Name=PrimaryWeaponBG
         WinLeft=0.520000
         WinWidth=0.430000
         WinHeight=0.300000
         OnPreDraw=PrimaryWeaponBG.InternalPreDraw
     End Object
     i_PrimaryWeaponBG=GUISectionBackground'ROInterface.ROUT2K4TabPanel_RoleSelection.PrimaryWeaponBG'

     Begin Object Class=GUISectionBackground Name=SecondaryWeaponBG
         WinTop=0.310000
         WinLeft=0.520000
         WinWidth=0.430000
         WinHeight=0.300000
         OnPreDraw=SecondaryWeaponBG.InternalPreDraw
     End Object
     i_SecondaryWeaponBG=GUISectionBackground'ROInterface.ROUT2K4TabPanel_RoleSelection.SecondaryWeaponBG'

     Begin Object Class=GUISectionBackground Name=GrenadeBG
         WinTop=0.624000
         WinLeft=0.520000
         WinWidth=0.430000
         WinHeight=0.300000
         OnPreDraw=GrenadeBG.InternalPreDraw
     End Object
     i_GrenadeBG=GUISectionBackground'ROInterface.ROUT2K4TabPanel_RoleSelection.GrenadeBG'

     Begin Object Class=moComboBox Name=PrimaryComboB
         bReadOnly=True
         CaptionWidth=0.450000
         Caption="Primary Weapon"
         OnCreateComponent=PrimaryComboB.InternalOnCreateComponent
         Hint="Select your primary weapon"
         WinTop=0.046350
         WinLeft=0.550000
         WinWidth=0.350000
         WinHeight=0.060000
         OnChange=ROUT2K4TabPanel_RoleSelection.OnComboChange
     End Object
     primaryCombo=moComboBox'ROInterface.ROUT2K4TabPanel_RoleSelection.PrimaryComboB'

     Begin Object Class=moComboBox Name=SecondaryComboB
         bReadOnly=True
         CaptionWidth=0.450000
         Caption="Secondary Weapon"
         OnCreateComponent=SecondaryComboB.InternalOnCreateComponent
         Hint="Select your secondary weapon"
         WinTop=0.356350
         WinLeft=0.550000
         WinWidth=0.350000
         WinHeight=0.060000
         OnChange=ROUT2K4TabPanel_RoleSelection.OnComboChange
     End Object
     secondaryCombo=moComboBox'ROInterface.ROUT2K4TabPanel_RoleSelection.SecondaryComboB'

     Begin Object Class=moComboBox Name=grenadeComboB
         bReadOnly=True
         CaptionWidth=0.350000
         Caption="Grenades"
         OnCreateComponent=grenadeComboB.InternalOnCreateComponent
         Hint="Select your grenades"
         WinTop=0.666350
         WinLeft=0.550000
         WinWidth=0.350000
         WinHeight=0.060000
         OnChange=ROUT2K4TabPanel_RoleSelection.OnComboChange
     End Object
     grenadeCombo=moComboBox'ROInterface.ROUT2K4TabPanel_RoleSelection.grenadeComboB'

     Begin Object Class=GUIImage Name=PrimaryImage
         Image=Texture'InterfaceArt_tex.Menu.changeme_texture'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         IniOption="@Internal"
         WinTop=0.106350
         WinLeft=0.575000
         WinWidth=0.300000
         WinHeight=0.150000
         RenderWeight=0.300000
     End Object
     i_PrimaryImage=GUIImage'ROInterface.ROUT2K4TabPanel_RoleSelection.PrimaryImage'

     Begin Object Class=GUIImage Name=SecondaryImage
         Image=Texture'InterfaceArt_tex.Menu.changeme_texture'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         IniOption="@Internal"
         WinTop=0.416350
         WinLeft=0.575000
         WinWidth=0.300000
         WinHeight=0.150000
         RenderWeight=0.300000
     End Object
     i_SecondaryImage=GUIImage'ROInterface.ROUT2K4TabPanel_RoleSelection.SecondaryImage'

     Begin Object Class=GUIImage Name=GrenadeImage
         Image=Texture'InterfaceArt_tex.Menu.changeme_texture'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         IniOption="@Internal"
         WinTop=0.726350
         WinLeft=0.575000
         WinWidth=0.300000
         WinHeight=0.150000
         RenderWeight=0.300000
     End Object
     i_GrenadeImage=GUIImage'ROInterface.ROUT2K4TabPanel_RoleSelection.GrenadeImage'

     NoneText="None"
     PanelCaption="Role"
}
