//=============================================================================
// ROGUITeamSelection
//=============================================================================
// The Role Selection menu.
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROGUIRoleSelection extends UT2K4GUIPage
    config;

// DELETE THIS::
//#exec OBJ LOAD FILE=..\Animations\Characters_anm.ukx
//#exec OBJ LOAD FILE=..\Textures\Characters_tex.utx
//#exec OBJ LOAD FILE=..\StaticMeshes\WeaponPickupSM.usx

// Config
var config bool bUseModel;

// Constants
const NUM_ROLES = 10;

// Controls

// Containers
var automated ROGUIProportionalContainer    MainContainer;

var automated ROGUIProportionalContainer    UnitsContainer,
                                            RolesContainer,
                                            RoleDescContainer,
                                            PlayerContainer,
                                            PrimaryWeaponContainer,
                                            SecondaryWeaponContainer,
                                            EquipContainer;

var automated GUILabel                      l_RolesTitle,
                                            l_RoleDescTitle,
                                            l_PrimaryWeaponTitle,
                                            l_SecondaryWeaponTitle,
                                            l_EquipTitle;


var automated BackgroundImage               bg_Background,
                                            bg_Background2;

// Button bar
var automated GUIButton                     b_Disconnect,
                                            b_Map,
                                            b_Score,
                                            b_Config,
                                            b_Continue;

// Current units controls

var automated ROGUIContainer                CurrentUnitsContainerA, CurrentUnitsContainerB;

var automated GUIButton                     b_JoinAxis, b_JoinAllies, b_Spectate;
var automated GUILabel                      l_numAxis, l_numAllies, l_numFake;


// Roles controls

var ROGUIListPlus                           li_Roles;
var automated GUIListBox                    lb_Roles;
var automated GUIImage                      i_PlayerImage;


// Roles description controls

var automated GUIScrollTextBox              l_RoleDescription;


// Player controls

var automated GUILabel                      l_PlayerName;
var automated GUIEditBox                    e_PlayerName;


// Weapons (both primary and secondary) controls

var automated GUIImage                      i_WeaponImages[2];
var automated GUIScrollTextBox              l_WeaponDescription[2];
var ROGUIListPlus                           li_AvailableWeapons[2];
var automated GUIListBox                    lb_AvailableWeapons[2];

// Equipment
var automated GUIGFXButton                  b_Equipment[4];
var automated GUIScrollTextBox              l_EquipmentDescription;
var string                                  equipmentDescriptions[4];

// Advanced/configuration buttons
var automated ROGUIContainer                ConfigButtonsContainer;
var automated GUIButton                     b_StartNewGame,
                                            b_ServerBrowser,
                                            b_AddFavorite,
                                            b_MapVoting,
                                            b_KickVoting,
                                            b_Communication,
                                            b_Configuration,
                                            b_ExitRO;

// Localized text

var localized string                        NoSelectedRoleText;
var localized string                        RoleHasBotsText;
var localized string                        RoleFullText;
var localized string                        SelectEquipmentText;
var localized string                        RoleIsFullMessageText;
var localized string                        ChangingRoleMessageText;
var localized string                        UnknownErrorMessageText;
var localized string                        ErrorChangingTeamsMessageText;

var localized string                        UnknownErrorSpectatorMissingReplicationInfo;
var localized string                        SpectatorErrorTooManySpectators;
var localized string                        SpectatorErrorRoundHasEnded;
var localized string                        UnknownErrorTeamMissingReplicationInfo;
var localized string                        ErrorTeamMustJoinBeforeStart;
var localized string                        TeamSwitchErrorTooManyPlayers;
var localized string                        UnknownErrorTeamMaxLives;
var localized string                        TeamSwitchErrorRoundHasEnded;
var localized string                        TeamSwitchErrorGameHasStarted;
var localized string                        TeamSwitchErrorPlayingAgainstBots;
var localized string                        TeamSwitchErrorTeamIsFull;

var localized string                        ConfigurationButtonText1;
var localized string                        ConfigurationButtonHint1;
var localized string                        ConfigurationButtonText2;
var localized string                        ConfigurationButtonHint2;


// Variables
var ROGameReplicationInfo       GRI;
var RORoleInfo                  currentRole, desiredRole;
var int                         currentTeam, desiredTeam;
var string                      currentName, desiredName;
var int                         currentWeapons[2], desiredWeapons[2];

var bool                        bShowingConfigButtons;
var float                       SavedMainContainerPos, SavedConfigButtonsContainerPos;

var float                       RoleSelectFooterButtonsWinTop,
                                OptionsFooterButtonsWinTop;

// for player model
var SpinnyWeap			        PlayerModel; // MUST be set to null when you leave the window
var SpinnyWeap                  PlayerModelHeadgear;
var SpinnyWeap                  PlayerModelAmmoPouch;
var SpinnyWeap                  PlayerModelWeapon;

var vector				        PlayerModelOffset;
var rotator				        PlayerModelRotOffset;
var float                       PlayerModelScale;
var vector                      PlayerModelRotScale;
var name                        PlayerModelAnim;
var float                       PlayerModelFOV;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    //class'ROInterfaceUtil'.static.SetROStyle(MyController, Controls);

    GRI = ROGameReplicationInfo(PlayerOwner().GameReplicationInfo);

    // Main containers
    MainContainer.ManageComponent(UnitsContainer);
    MainContainer.ManageComponent(l_RolesTitle);
    MainContainer.ManageComponent(RolesContainer);
    MainContainer.ManageComponent(PlayerContainer);
    MainContainer.ManageComponent(l_RoleDescTitle);
    MainContainer.ManageComponent(RoleDescContainer);

    MainContainer.ManageComponent(l_PrimaryWeaponTitle);
    MainContainer.ManageComponent(PrimaryWeaponContainer);
    MainContainer.ManageComponent(l_SecondaryWeaponTitle);
    MainContainer.ManageComponent(SecondaryWeaponContainer);
    MainContainer.ManageComponent(l_EquipTitle);
    MainContainer.ManageComponent(EquipContainer);

    // Current units container
    UnitsContainer.ManageComponent(CurrentUnitsContainerA);
    UnitsContainer.ManageComponent(CurrentUnitsContainerB);
    CurrentUnitsContainerA.ManageComponent(b_JoinAxis);
    CurrentUnitsContainerA.ManageComponent(b_JoinAllies);
    CurrentUnitsContainerA.ManageComponent(b_Spectate);
    CurrentUnitsContainerB.ManageComponent(l_numAxis);
    CurrentUnitsContainerB.ManageComponent(l_numAllies);
    CurrentUnitsContainerB.ManageComponent(l_numFake);

    // Roles container
    RolesContainer.ManageComponent(lb_Roles);
    li_Roles = ROGUIListPlus(lb_Roles.List);

    // Role description container
    RoleDescContainer.ManageComponent(l_RoleDescription);

    // Player container
    PlayerContainer.ManageComponent(l_PlayerName);
    PlayerContainer.ManageComponent(e_PlayerName);
    PlayerContainer.ManageComponent(i_PlayerImage);

    // Primary weapon container
    PrimaryWeaponContainer.ManageComponent(i_WeaponImages[0]);
    PrimaryWeaponContainer.ManageComponent(l_WeaponDescription[0]);
    PrimaryWeaponContainer.ManageComponent(lb_AvailableWeapons[0]);
    li_AvailableWeapons[0] = ROGUIListPlus(lb_AvailableWeapons[0].List);

    // Secondary weapon container
    SecondaryWeaponContainer.ManageComponent(i_WeaponImages[1]);
    SecondaryWeaponContainer.ManageComponent(l_WeaponDescription[1]);
    SecondaryWeaponContainer.ManageComponent(lb_AvailableWeapons[1]);
    li_AvailableWeapons[1] = ROGUIListPlus(lb_AvailableWeapons[1].List);

    // Equipment container
    EquipContainer.ManageComponent(b_Equipment[0]);
    EquipContainer.ManageComponent(b_Equipment[1]);
    EquipContainer.ManageComponent(b_Equipment[2]);
    EquipContainer.ManageComponent(b_Equipment[3]);
    EquipContainer.ManageComponent(l_EquipmentDescription);

    // Config buttons container
    if (PlayerOwner().Level.NetMode == NM_StandAlone)
        ConfigButtonsContainer.ManageComponent(b_StartNewGame);
    else
        b_StartNewGame.bVisible = false;
    ConfigButtonsContainer.ManageComponent(b_ServerBrowser);
    if (PlayerOwner().Level.NetMode != NM_StandAlone)
    {
        ConfigButtonsContainer.ManageComponent(b_AddFavorite);
        ConfigButtonsContainer.ManageComponent(b_MapVoting);
        ConfigButtonsContainer.ManageComponent(b_KickVoting);
        ConfigButtonsContainer.ManageComponent(b_Communication);
    }
    else
    {
        b_AddFavorite.bVisible = false;
        b_MapVoting.bVisible = false;
        b_KickVoting.bVisible = false;
        b_Communication.bVisible = false;
    }
    ConfigButtonsContainer.ManageComponent(b_Configuration);
    ConfigButtonsContainer.ManageComponent(b_ExitRO);

    // Player model
    if (bUseModel)
    {
        if (PlayerModel == None)
    		PlayerModel = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
    	PlayerModel.SpinRate = 0;
    	PlayerModel.SetDrawType(DT_Mesh);

        // Player model headgear
        if (PlayerModelHeadgear == none)
            PlayerModelHeadgear = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
        PlayerModelHeadgear.SpinRate = 0;
        PlayerModelHeadgear.SetDrawType(DT_Mesh);

        // Player model ammo pouch
        if (PlayerModelAmmoPouch == none)
            PlayerModelAmmoPouch = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
        PlayerModelAmmoPouch.SpinRate = 0;
        PlayerModelAmmoPouch.SetDrawType(DT_Mesh);

        // Player model weapon
        if (PlayerModelWeapon == none)
            PlayerModelWeapon = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
        PlayerModelWeapon.SpinRate = 0;
        PlayerModelWeapon.SetDrawType(DT_Mesh);
    }

    // Get player's initial values (name, team, role, weapons)
    GetInitialValues();

    // Fill roles list
    FillRoleList();
    if (currentRole == none)
    {
        AutoPickRole();
        NotifyDesiredRoleUpdated();
    }
    else
        ChangeDesiredRole(currentRole);

    // Set controls visibility
    UpdateConfigButtonsVisibility();

    // Set initial counts
    Timer();
	SetTimer(0.1, true);
}

function GetInitialValues()
{
    local ROPlayer player;
    local ROPlayerReplicationInfo PRI;

    player = ROPlayer(PlayerOwner());

    // Get player's current role and team (if any)
    PRI = ROPlayerReplicationInfo(player.PlayerReplicationInfo);
    if (PRI != none)
    {
        // Get player's current team
        if (ROPlayer(PlayerOwner()) != none && ROPlayer(PlayerOwner()).ForcedTeamSelectOnRoleSelectPage != -5)
        {
            currentTeam = ROPlayer(PlayerOwner()).ForcedTeamSelectOnRoleSelectPage;
            ROPlayer(PlayerOwner()).ForcedTeamSelectOnRoleSelectPage = -5;
        }
        else if (PRI.bOnlySpectator)
            currentTeam = -1;
        else if (PRI.Team != none)
            currentTeam = PRI.Team.TeamIndex;
        else
            currentTeam = -1;

        if (currentTeam != AXIS_TEAM_INDEX && currentTeam != ALLIES_TEAM_INDEX)
            currentTeam = -1;
    }
    else
        currentTeam = -1;

    // Get player's current/desired role
    if (currentTeam == -1)
        currentRole = none;
    else if (player.CurrentRole != player.DesiredRole)
    {
        if (currentTeam == AXIS_TEAM_INDEX)
            currentRole = GRI.AxisRoles[player.DesiredRole];
        else if (currentTeam == ALLIES_TEAM_INDEX)
            currentRole = GRI.AlliesRoles[player.DesiredRole];
        else
            currentRole = none;
    }
    else if (PRI.RoleInfo != none)
        currentRole = PRI.RoleInfo;
    else
        currentRole = none;

    // Get player's current name
    currentName = player.GetUrlOption("Name");

    // Get player's current weapons
    if (currentRole == none)
    {
        currentWeapons[0] = -1;
        currentWeapons[1] = -1;
    }
    else if (player.CurrentRole != player.DesiredRole)
    {
        currentWeapons[0] = player.DesiredPrimary;
        currentWeapons[1] = player.DesiredSecondary;
    }
    else
    {
        currentWeapons[0] = player.PrimaryWeapon;
        currentWeapons[1] = player.SecondaryWeapon;
    }

    // Set desired stuff to be same as current stuff
    desiredTeam = currentTeam;
    desiredRole = currentRole;
    desiredName = currentName;
    desiredWeapons[0] = -5; // These values tell the AutoPickWeapon() function
    desiredWeapons[1] = -5; // to use the currentWeapon[] value instead
}

function FillRoleList()
{
    local int i;
    local RORoleInfo role;

    li_Roles.Clear();

    ChangeDesiredRole(none);

    if (desiredTeam != AXIS_TEAM_INDEX && desiredTeam != ALLIES_TEAM_INDEX)
        return;

    for (i = 0; i < NUM_ROLES; i++)
    {
        if (desiredTeam == AXIS_TEAM_INDEX)
            role = GRI.AxisRoles[i];
        else
            role = GRI.AlliesRoles[i];

        if (role == none)
            continue;

		if( ROPlayer(PlayerOwner()) != none && ROPlayer(PlayerOwner()).bUseNativeRoleNames )
		{
        	li_Roles.Add(role.default.AltName, role);
        }
        else
        {
        	li_Roles.Add(role.default.MyName, role);
        }
    }

    li_Roles.SortList();
}

function ChangeDesiredRole(RORoleInfo newRole)
{
    local int roleIndex;

    // Don't change role if we already have correct role selected
    if (newRole == desiredRole && desiredTeam != -1)
        return;

    desiredRole = newRole;
    if (newRole == none)
    {
        li_Roles.SetIndex(-1);
    }
    else
    {
        roleIndex = FindRoleIndexInList(newRole);
        if (roleIndex != -1)
            li_Roles.SetIndex(roleIndex);
    }

    NotifyDesiredRoleUpdated();
}

function AutoPickRole()
{
    local int i, currentRoleCount;
    local RORoleInfo role;

    if (desiredTeam == AXIS_TEAM_INDEX || desiredTeam == ALLIES_TEAM_INDEX)
    {
        // Pick the first non-full role
        for (i = 0; i < NUM_ROLES; i++)
        {
            if (desiredTeam == AXIS_TEAM_INDEX)
            {
                role = GRI.AxisRoles[i];
                currentRoleCount = GRI.AxisRoleCount[i];
            }
            else
            {
                role = GRI.AlliesRoles[i];
                currentRoleCount = GRI.AlliesRoleCount[i];
            }

            if (role == none)
                continue;

            if (role.GetLimit(GRI.MaxPlayers) == 0 || currentRoleCount < role.GetLimit(GRI.MaxPlayers))
            {
                ChangeDesiredRole(role);
                return;
            }
        }

        // if they're all full.. well though noogies :)
        warn("All roles are full!");
    }
    else
        ChangeDesiredRole(none);
}

function NotifyDesiredRoleUpdated()
{
    UpdateRoleDescription();
    UpdateWeaponsInfo();
    UpdatePlayerInfo();
}

function ChangeDesiredTeam(int team)
{
    desiredTeam = team;
    desiredRole = none;
    desiredWeapons[0] = -1;
    desiredWeapons[1] = -1;

    FillRoleList();
    AutoPickRole();
}

function int FindRoleIndexInList(RORoleInfo newRole)
{
    local int i;

    if (li_Roles.ItemCount == 0)
        return -1;

    for (i = 0; i < li_Roles.ItemCount; i++)
        if (newRole == li_Roles.GetObjectAtIndex(i))
            return i;

    return -1;
}

function UpdateRoleDescription()
{
    if (desiredRole == none)
    {
        if (desiredTeam != AXIS_TEAM_INDEX && desiredTeam != ALLIES_TEAM_INDEX)
            l_RoleDescription.SetContent("");
        else
            l_RoleDescription.SetContent(NoSelectedRoleText);
    }
    else
        l_RoleDescription.SetContent(desiredRole.InfoText);
}

function UpdatePlayerInfo()
{
    e_PlayerName.SetText(desiredName);
    UpdatePlayerModelInfo();
}

function UpdateWeaponsInfo()
{
    local int i;

    // Clear boxes
    li_AvailableWeapons[0].Clear();
    li_AvailableWeapons[1].Clear();
    ClearEquipment();

    // Clear descriptions & images
    i_WeaponImages[0].Image = none;
    i_WeaponImages[1].Image = none;
    l_WeaponDescription[0].SetContent("");
    l_WeaponDescription[1].SetContent("");

    if (desiredRole != none)
    {
        // Update available primary weapons list
        for (i = 0; i < ArrayCount(desiredRole.PrimaryWeapons); i++)
            if (desiredRole.PrimaryWeapons[i].item != none)
                li_AvailableWeapons[0].Add(desiredRole.PrimaryWeapons[i].Item.default.ItemName,, string(i));
        //li_AvailableWeapons[0].SortList();

        // Update available secondary weapons list
        for (i = 0; i < ArrayCount(desiredRole.SecondaryWeapons); i++)
            if (desiredRole.SecondaryWeapons[i].item != none)
                li_AvailableWeapons[1].Add(desiredRole.SecondaryWeapons[i].Item.default.ItemName,, string(i));
        //li_AvailableWeapons[1].SortList();

        // Update equipment
        UpdateRoleEquipment();

        AutoPickWeapons();
    }
}

function ClearEquipment()
{
    local int i;

    for (i = 0; i < 4; i++)
    {
        b_Equipment[i].Graphic = none;
        b_Equipment[i].bVisible = false;
    }

    l_EquipmentDescription.setContent(SelectEquipmentText);
    l_EquipmentDescription.bVisible = false;
}

function UpdateRoleEquipment()
{
    local int count, i, temp;
    local class<ROWeaponAttachment> WeaponAttach;
    local class<Weapon> w;

    count = 0;
    temp = -1;

    // Add grenades if needed
    for (i = 0; i < arraycount(desiredRole.Grenades); i++)
    {
        if (desiredRole.Grenades[i].Item != none)
        {
            WeaponAttach = class<ROWeaponAttachment>(desiredRole.Grenades[i].Item.default.AttachmentClass);
            if (WeaponAttach != none)
            {
                if (WeaponAttach.default.menuImage != None)
                {
                    b_Equipment[count].Graphic = WeaponAttach.default.menuImage;
                    b_Equipment[count].bVisible = true;
                }
                equipmentDescriptions[count] = WeaponAttach.default.menuDescription;
                l_EquipmentDescription.bVisible = true;
            }
            count++;
        }
    }

    // Parse GivenItems array
    for (i = 0; i < desiredRole.GivenItems.Length; i++)
    {
        if (desiredRole.GivenItems[i] != "")
        {
            w = class<Weapon>(DynamicLoadObject(desiredRole.GivenItems[i], class'class'));
            WeaponAttach = class<ROWeaponAttachment>(w.default.AttachmentClass);
            if (WeaponAttach != none)
            {
                // Force panzer to go in slot #4
                if (desiredRole.GivenItems[i] == "ROInventory.PanzerFaustWeapon")
                {
                    temp = count;
                    count = 3;
                }

                if (WeaponAttach.default.menuImage != None)
                {
                    b_Equipment[count].Graphic = WeaponAttach.default.menuImage;
                    b_Equipment[count].bVisible = true;
                }
                equipmentDescriptions[count] = WeaponAttach.default.menuDescription;
                l_EquipmentDescription.bVisible = true;

                if (temp != -1)
                {
                    count = temp - 1;
                    temp = -1;
                }
            }
            count++;
        }

        if (count > arraycount(b_Equipment))
            return;
    }
}

function AutoPickWeapons()
{
    local int i;

    // If we already had selected a weapon, then re-select it.
    if (currentTeam == desiredTeam && currentRole == desiredRole &&
        desiredWeapons[0] == -5 && desiredWeapons[1] == -5)
    {
        for (i = 0; i < 2; i++)
        {
            desiredWeapons[i] = currentWeapons[i];

            if (li_AvailableWeapons[i].ItemCount != 0)
                li_AvailableWeapons[i].SetIndex(FindIndexInWeaponsList(desiredWeapons[i], li_AvailableWeapons[i]));

            UpdateSelectedWeapon(i);
        }
    }
    else
    {
        // Simple implementation, just select first weapon in list.
        for (i = 0; i < 2; i++)
        {
            if (li_AvailableWeapons[i].ItemCount != 0)
                li_AvailableWeapons[i].SetIndex(0);

            desiredWeapons[i] = int(li_AvailableWeapons[i].GetExtraAtIndex(0));

            UpdateSelectedWeapon(i);
        }
    }
}

function int FindIndexInWeaponsList(int index, GUIList list)
{
    local int i;
    for (i = 0; i < list.ItemCount; i++)
        if (int(list.GetExtraAtIndex(i)) == index)
            return i;

    return -1;
}

function UpdateSelectedWeapon(int weaponCategory)
{
    local class<InventoryAttachment> AttachClass;
    local class<ROWeaponAttachment> WeaponAttach;
    local int i;
    local class<Inventory> item;

    // Clear current weapon display
    l_WeaponDescription[weaponCategory].SetContent("");
    i_WeaponImages[weaponCategory].Image = none;

    if (desiredRole != none)
    {
        i = int(li_AvailableWeapons[weaponCategory].GetExtra());
        if (weaponCategory == 0)
            item = desiredRole.PrimaryWeapons[i].Item;
        else
            item = desiredRole.SecondaryWeapons[i].Item;

        if (item != none)
        {
            AttachClass = item.default.AttachmentClass;
            WeaponAttach = class<ROWeaponAttachment>(AttachClass);
            if (WeaponAttach != none)
            {
                if (WeaponAttach.default.menuImage != None)
                    i_WeaponImages[weaponCategory].Image = WeaponAttach.default.menuImage;
                l_WeaponDescription[weaponCategory].SetContent(WeaponAttach.default.menuDescription);
            }

            desiredWeapons[weaponCategory] = i;

            // Update current weapon on player model
            UpdatePlayerInfo();
        }
    }
}

// Used to update team counts & role counts
function Timer()
{
    UpdateTeamCounts();
    UpdateRoleCounts();
}

function UpdateTeamCounts()
{
    l_numAxis.Caption = ""$getTeamCount(AXIS_TEAM_INDEX);
    l_numAllies.Caption = ""$getTeamCount(ALLIES_TEAM_INDEX);
}

function int getTeamCount(int index)
{
    return class'ROGUITeamSelection'.static.getTeamCountStatic(GRI, PlayerOwner(), index);
}

function UpdateRoleCounts()
{
    local int i, roleLimit, roleCurrentCount, roleBotCount;
    local RORoleInfo role;
    local bool bHasBots, bIsFull;

    if (desiredTeam != AXIS_TEAM_INDEX && desiredTeam != ALLIES_TEAM_INDEX)
        return;

    for (i = 0; i < li_Roles.ItemCount; i++)
    {
        role = RORoleInfo(li_Roles.GetObjectAtIndex(i));
        if (role == none)
            continue;

        bIsFull = checkIfRoleIsFull(role, desiredTeam, roleLimit, roleCurrentCount, roleBotCount);
        bHasBots = (roleBotCount > 0);

		if( ROPlayer(PlayerOwner()) != none &&  ROPlayer(PlayerOwner()).bUseNativeRoleNames )
		{
        	li_Roles.SetItemAtIndex(i, FormatRoleString(role.AltName, roleLimit, roleCurrentCount, bHasBots));
        }
        else
        {
        	li_Roles.SetItemAtIndex(i, FormatRoleString(role.MyName, roleLimit, roleCurrentCount, bHasBots));
        }
        li_Roles.SetDisabledAtIndex(i, bIsFull);
    }
}

function bool checkIfRoleIsFull(RORoleInfo role, int team, optional out int roleLimit, optional out int roleCount, optional out int roleBotCount)
{
    local int index;

    index = FindRoleIndexInGRI(role, team); // ugh, slow

    if (team == AXIS_TEAM_INDEX)
    {
        roleCount = GRI.AxisRoleCount[index];
        roleBotCount = GRI.AxisRoleBotCount[index];
    }
    else if (team == ALLIES_TEAM_INDEX)
    {
        roleCount = GRI.AlliesRoleCount[index];
        roleBotCount = GRI.AlliesRoleBotCount[index];
    }
    else
    {
        warn("Invalid team used when calling checkIfRoleIsFull(): " $ team);
        return false;
    }

    roleLimit = role.GetLimit(GRI.MaxPlayers);

    return (roleCount == roleLimit) &&
            (roleLimit != 0) &&
            !(roleBotCount > 0) &&
            (currentRole != role);
}

function int FindRoleIndexInGRI(RORoleInfo role, int team)
{
    local int i;
    if (team == AXIS_TEAM_INDEX)
    {
        for (i = 0; i < ArrayCount(GRI.AxisRoles); i++)
            if (GRI.AxisRoles[i] == role)
                return i;
    }
    else if (team == ALLIES_TEAM_INDEX)
    {
        for (i = 0; i < ArrayCount(GRI.AlliesRoles); i++)
            if (GRI.AlliesRoles[i] == role)
                return i;
    }
    else
        return -1;
}

function string FormatRoleString(string roleName, int roleLimit, int roleCount, bool bHasBots)
{
    local string s;
    if (roleLimit == 0)
        s = roleName $ " [" $ roleCount $ "]";
    else
    {
        if (roleCount == roleLimit && !bHasBots)
            s = roleName $ " [" $ RoleFullText $ "]";
        else
            s = roleName $ " [" $ roleCount $ "/" $ roleLimit $ "]";
    }

    if (bHasBots)
        return s $ RoleHasBotsText;
    else
        return s;
}

function AttemptRoleApplication()
{
    local ROPlayer player;
    local byte teamIndex, roleIndex, w1, w2;

    player = ROPlayer(PlayerOwner());

    if (player == none)
    {
        warn("Unable to cast PlayerOwner() to ROPlayer in ROGUIRoleSelection.AttemptRoleApplication() !");
        return;
    }

    // Change player name (no need for confirmation on this)
    if (desiredName != currentName)
    {
        player.ReplaceText(desiredName, "\"", "");
		player.ConsoleCommand("SetName"@desiredName);
        currentName = desiredName;
    }

    // Get desired team info
    if (desiredTeam == currentTeam)
    {
        teamIndex = 255;    // No change
    }
    else
    {
        if (desiredTeam == -1)
            teamIndex = 254; // spectator
        else
            teamIndex = desiredTeam;
    }

    // Get role switch info
    if (teamIndex == 254 || (teamIndex == 255 && desiredTeam == -1))
        roleIndex = 255; // no role switch if we're spectating
    else if (desiredRole == none)
    {
        warn("No role selected, using role #0");
        roleIndex = 0; // force role of 0 if we havn't picked a role (should never happen)
    }
    else if (desiredRole == currentRole && desiredTeam == currentTeam)
    {
        roleIndex = 255; // No change
    }
    else
    {
        if (checkIfRoleIsFull(desiredRole, desiredTeam) && Controller != none)
        {
            Controller.OpenMenu(Controller.QuestionMenuClass);
		    GUIQuestionPage(Controller.TopPage()).SetupQuestion(RoleIsFullMessageText, QBTN_Ok, QBTN_Ok);
		    return;
        }

        roleIndex = FindRoleIndexInGRI(RORoleInfo(li_Roles.GetObject()), desiredTeam);
    }

    // Get weapons info
    w1 = desiredWeapons[0];
    w2 = desiredWeapons[1];
    //if (desiredWeapons[0] == currentWeapons[0] && desiredWeapons[1] == currentWeapons[1])
    //    w1 = 255;

    // Open 'changing role' dialog
    /*if (Controller != none)
    {
        Controller.OpenMenu(QuestionClass);
        GUIQuestionPage(Controller.TopPage()).SetupQuestion(ChangingRoleMessageText, QBTN_Abort, QBTN_Abort);
        GUIQuestionPage(Controller.TopPage()).OnButtonClick = InternalOnAbortButtonClick;
    }*/

    // Disable continue button
    SetContinueButtonState(true);

    // Attempt team, role and weapons change
    player.ServerChangePlayerInfo(teamIndex, roleIndex, w1, w2);
}

function CloseMenu()
{
    local ROPlayer player;

    player = ROPlayer(PlayerOwner());
    if (player != none)
    {
        if (player.bShowMapOnFirstSpawn && !player.bFirstObjectiveScreenDisplayed)
        {
            player.bFirstObjectiveScreenDisplayed = true;
			if( ROHud(player.MyHUD) != none )
				ROHud(player.MyHUD).ShowObjectives();
        }
    }
    // Check if we should start fade-from-black effect on player
    CheckNeedForFadeFromBlackEffect(PlayerOwner());

    if (Controller != none)
        Controller.RemoveMenu(self);
}

static function CheckNeedForFadeFromBlackEffect(PlayerController controller)
{
//    local ROPlayer player;

//    player = ROPlayer(controller);
//    if (player != none)
//    {
//        if (!player.bDisplayedRoleSelectAtLeastOnce)
//        {
//            player.bDisplayedRoleSelectAtLeastOnce = true;
//            player.StartFadeFromBlackEffect();
//        }
//    }
}

function SetContinueButtonState(bool bDisabled)
{
    if (bDisabled)
        b_Continue.MenuStateChange(MSAT_Disabled);
    else
        b_Continue.MenuStateChange(MSAT_Blurry);
}

function UpdateConfigButtonsVisibility()
{
    local float myWinTop;
    if (bShowingConfigButtons)
    {
        MainContainer.SetVisibility(false);
        ConfigButtonsContainer.SetVisibility(true);
        bg_Background.SetVisibility(false);
        bg_Background2.SetVisibility(true);
        b_Config.Caption = ConfigurationButtonText2;
        b_Config.SetHint(ConfigurationButtonHint2);
        myWinTop = OptionsFooterButtonsWinTop;
    }
    else
    {
        MainContainer.SetVisibility(true);
        ConfigButtonsContainer.SetVisibility(false);
        bg_Background.SetVisibility(true);
        bg_Background2.SetVisibility(false);
        b_Config.Caption = ConfigurationButtonText1;
        b_Config.SetHint(ConfigurationButtonHint1);
        myWinTop = RoleSelectFooterButtonsWinTop;

        // To make sure items that should be hidden are hidden
        NotifyDesiredRoleUpdated();
    }

    b_Disconnect.WinTop = myWinTop;
    b_Score.WinTop = myWinTop;
    b_Map.WinTop = myWinTop;
    b_Config.WinTop = myWinTop;
    b_Continue.WinTop = myWinTop;
}

function UpdatePlayerModelPositionInfo(vector CamPos, rotator CamRot)
{
    //local float width, height, ratio;
    local rotator r;
    //local actor a;
    //local PlayerController c;
    //local string s;
    local Quat rQuat, tQuat;

    PlayerModel.SetDrawScale(PlayerModelScale);

    /*c = PlayerOwner();
    a = c.ViewTarget;
    if (a != none)
    {
        log("viewtarget name = " $ a.name);
        if (a.IsA('PlayerController'))
        {
            r = c.viewtarget.rotation;
            log("using player controller rotation");
        }
        else if (a.IsA('Pawn'))
        {
            if (a == c.pawn)
            {
                r = c.rotation;
                log("using pawn rotation.");
            }
            else if (c.bBehindView)
            {
                log("using controller rotation. (bbehindview)");
                r = c.rotation;
            }
            else
            {
                log("using viewtarget rotation.");
                r = a.rotation;
            }
        }
        else
        {
            r = c.rotation;
            log("Unknown viewtarget, using pawn rotation");
        }
    }
    else
    {
        log("no viewtarget, using cam rotation");
        r = CamRot;
    }*/

    // All this frelling around while I could just have used this one line?!
    // Shoot me now :|
    r = CamRot;

    rQuat = QuatFromRotator(r);
    tQuat = QuatFromRotator(PlayerModelRotOffset);
    tQuat = QuatProduct(tQuat, rQuat);
    r = QuatToRotator(tQuat);

    /*

    // test0r
    s =     "controller rot = " $ c.rotation.yaw$", "$c.rotation.Pitch$", "$c.rotation.Roll $
            " ||" $
            "pawn rot = " $ c.pawn.rotation.yaw$", "$c.pawn.rotation.Pitch$", "$c.pawn.rotation.Roll $
            " ||" $
            "camrot = " $ CamRot.yaw$", "$CamRot.Pitch$", "$CamRot.Roll $
            " ||" $
            "campos = " $ campos.x$", "$campos.y$", "$campos.z $
            " ||" $
            "result rot = " $ r.yaw$", "$r.Pitch$", "$r.Roll;
    if (l_RoleDescription.Tag != r.Yaw + r.Pitch + r.Roll)
    {
        l_RoleDescription.Tag = r.yaw + r.Pitch + r.roll;
        l_RoleDescription.SetContent(s);
    }*/

    PlayerModel.SetRotation(r);

    PlayerModelHeadgear.SetDrawScale(PlayerModelScale);
    PlayerModelAmmoPouch.SetDrawScale(PlayerModelScale);
    PlayerModelWeapon.SetDrawScale(PlayerModelScale);

    /*width = bg_Background.ActualWidth();
    height = bg_Background.ActualHeight();

    if (width < 1 || height < 1)
        return;

    ratio = height / width;

    PlayerModelOffset.X = 100;
    PlayerModelOffset.Y = (i_PlayerImage.ActualLeft() + i_PlayerImage.ActualWidth() / 2) / width * 200 - 100;
    //PlayerModelOffset.Y *= -1;
    PlayerModelOffset.Z = (i_PlayerImage.ActualTop() + i_PlayerImage.ActualHeight() / 2) / height * 200 - 100;
    PlayerModelOffset.Z *= -ratio;*/
}

function UpdatePlayerModelInfo()
{
	local Mesh PlayerMesh;
	local Material BodySkin, HeadSkin;
    local string BodySkinName, HeadSkinName, TeamSuffix;
    local xUtil.PlayerRecord PlayerRec;
    local class<ROAmmoPouch> ammoPouch;
    local class<ROHeadgear> headGear;
    local class<Inventory> item;
    local class<ROWeaponAttachment> weapon;

    // Set background image
    if (!bUseModel)
    {
        if (desiredRole == none)
            i_PlayerImage.Image = none;
        else
        {
            i_PlayerImage.Image = desiredRole.default.MenuImage;
        }

        return;
    }

    // Set initial visibility states
    PlayerModel.bHidden = true;
    PlayerModelHeadgear.bHidden = true;
    PlayerModelAmmoPouch.bHidden = true;
    PlayerModelWeapon.bHidden = true;

    // Check if there's a role selected
    if (desiredRole == none)
        return;

    PlayerModel.bHidden = false;

    // Get player record
    PlayerRec = class'xUtil'.static.FindPlayerRecord(desiredRole.static.GetModel());
    if (PlayerRec.MeshName == "")
    {
        log("Unable to get player record for model " $ desiredRole.static.GetModel());
        return;
    }

	// Get player mesh
	PlayerMesh = Mesh(DynamicLoadObject(PlayerRec.MeshName, class'Mesh'));
	if (PlayerMesh == None)
	{
		Log("Could not load mesh: "$PlayerRec.MeshName$" For player: "$PlayerRec.DefaultName);
		return;
	}

	// Get the body skin
    BodySkinName = PlayerRec.BodySkinName $ TeamSuffix;

	// Get the head skin
    HeadSkinName = PlayerRec.FaceSkinName;
    if ( PlayerRec.TeamFace )
    	HeadSkinName $= TeamSuffix;

	BodySkin = Material(DynamicLoadObject(BodySkinName, class'Material'));
	if(BodySkin == None)
	{
		Log("Could not load body material: "$PlayerRec.BodySkinName$" For player: "$PlayerRec.DefaultName);
		return;
	}

	//if ( bBrightSkin )
	//	SpinnyDude.AmbientGlow = SpinnyDude.default.AmbientGlow * 0.8;
	//else
        PlayerModel.AmbientGlow = PlayerModel.default.AmbientGlow;

	HeadSkin = Material(DynamicLoadObject(HeadSkinName, class'Material'));
	if (HeadSkin == None)
	{
		Log("Could not load head material: "$HeadSkinName$" For player: "$PlayerRec.DefaultName);
		return;
	}

    // Detach attachements
    PlayerModel.DetachFromBone(PlayerModelHeadgear);
    PlayerModel.DetachFromBone(PlayerModelAmmoPouch);
    PlayerModel.DetachFromBone(PlayerModelWeapon);

	PlayerModel.LinkMesh(PlayerMesh);
	PlayerModel.Skins[0] = BodySkin;
	PlayerModel.Skins[1] = HeadSkin;
	PlayerModel.LoopAnim(default.PlayerModelAnim, 1.0 / PlayerModel.Level.TimeDilation);

	// Get headgear mesh class
	headGear = desiredRole.GetHeadgear();
	if (headGear != none)
	{
    	PlayerMesh = headGear.default.mesh;
    	if (PlayerMesh == None)
    	{
    		Log("Could not load headgear mesh for class " $ headGear);
    		return;
    	}

    	PlayerModelHeadgear.LinkMesh(PlayerMesh);
    	PlayerModel.AttachToBone(PlayerModelHeadgear, class'ROHeadgear'.default.AttachmentBone);

    	PlayerModelHeadgear.bHidden = false;
    }

	// Get ammo pounch (if available)
	if (desiredWeapons[0] >= 0)
	{
	    ammoPouch = desiredRole.PrimaryWeapons[desiredWeapons[0]].AssociatedAttachment;
        if (ammoPouch != none)
        {
            PlayerMesh = ammoPouch.default.mesh;
            if (PlayerMesh == None)
        	{
        		Log("Could not load ammo pouch mesh for class " $ ammoPouch);
        		return;
        	}

            PlayerModelAmmoPouch.LinkMesh(PlayerMesh);
    	    PlayerModel.AttachToBone(PlayerModelAmmoPouch, ammoPouch.default.AttachmentBone);

    	    PlayerModelAmmoPouch.bHidden = false;
    	}
	}

	// Get weapon (if available)
	if (desiredWeapons[0] >= 0)
	{
        item = desiredRole.PrimaryWeapons[desiredWeapons[0]].Item;
        if (item != none)
        {
            weapon = class<ROWeaponAttachment>(item.default.AttachmentClass);
            if (weapon != none)
            {
                PlayerMesh = weapon.default.Mesh;
                //PlayerModelAnim = weapon.default.PA_IdleRestAnim;
                PlayerModelAnim = weapon.default.PA_ReloadAnim;

                if (PlayerMesh == none)
                {
            		Log("Could not load weapon mesh for class " $ weapon);
            		return;
            	}

            	PlayerModelWeapon.LinkMesh(PlayerMesh);
        	    PlayerModel.AttachToBone(PlayerModelWeapon, class'ROPawn'.static.StaticGetWeaponBoneFor(item));

        	    PlayerModelWeapon.bHidden = false;

        	    if (PlayerModelAnim != '')
        	    {
        	        //PlayerModel.LoopAnim(PlayerModelAnim, 1.0 / PlayerModel.Level.TimeDilation);
        	        PlayerModel.PlayAnim(PlayerModelAnim, 1.0 / PlayerModel.Level.TimeDilation);
            	    PlayerModel.AnimNames[0] = weapon.default.PA_IdleRestAnim;
        	    }
            }
        }
	}
}

function bool InternalOnClick( GUIComponent Sender )
{
    local ROPlayer player;

    player = ROPlayer(PlayerOwner());

    switch (sender)
    {
        case b_JoinAxis:
            ChangeDesiredTeam(AXIS_TEAM_INDEX);
            break;

        case b_JoinAllies:
            ChangeDesiredTeam(ALLIES_TEAM_INDEX);
            break;

        case b_Spectate:
            ChangeDesiredTeam(-1);
            break;

        case b_Continue:
            AttemptRoleApplication();
            break;

        case b_Config:
            bShowingConfigButtons = !bShowingConfigButtons;
            UpdateConfigButtonsVisibility();
            break;

        case b_Disconnect:
            PlayerOwner().ConsoleCommand( "DISCONNECT" );
	        CloseMenu();
	        break;

	    case b_Score:
	        if (player != none && ROHud(player.myHUD) != none)
	            player.myHUD.bShowScoreBoard = !player.myHUD.bShowScoreBoard;
	        CloseMenu();
	        break;

	    case b_Map:
	        if (player != none && ROHud(player.myHUD) != none)
                ROHud(player.myHUD).ShowObjectives();
	        CloseMenu();
	        break;
    }

    if (bShowingConfigButtons)
    {
        switch (sender)
        {
            case b_StartNewGame:
                if (b_StartNewGame.bVisible)
                    Controller.OpenMenu(Controller.GetInstantActionPage());
                break;

            case b_ServerBrowser:
                Controller.OpenMenu("ROInterface.ROUT2k4ServerBrowser");
                break;

            case b_AddFavorite:
                if (b_AddFavorite.bVisible && player != none)
                    player.ConsoleCommand( "ADDCURRENTTOFAVORITES" );
                break;

            case b_MapVoting:
                if (b_MapVoting.bVisible)
                    Controller.OpenMenu(Controller.MapVotingMenu);
                break;

            case b_KickVoting:
                if (b_MapVoting.bVisible)
                    Controller.OpenMenu(Controller.KickVotingMenu);
                break;

            case b_Communication:
                Controller.OpenMenu("ROInterface.ROCommunicationPage");
                break;

            case b_Configuration:
                //Controller.OpenMenu("ROInterface.ROSettingsPage");
                Controller.OpenMenu("ROInterface.ROSettingsPage_new");
                break;

            case b_ExitRO:
                Controller.OpenMenu(Controller.GetQuitPage());
                break;
        }
    }
    else
    {
        switch (sender)
        {
            case b_Equipment[0]:
                l_EquipmentDescription.setContent(equipmentDescriptions[0]);
                break;

            case b_Equipment[1]:
                l_EquipmentDescription.setContent(equipmentDescriptions[1]);
                break;

            case b_Equipment[2]:
                l_EquipmentDescription.setContent(equipmentDescriptions[2]);
                break;

            case b_Equipment[3]:
                l_EquipmentDescription.setContent(equipmentDescriptions[3]);
                break;
        }
    }

    return true;
}

function InternalOnChange( GUIComponent Sender )
{
    local string s;
    local RORoleInfo role;

    if (bShowingConfigButtons)
        return;

    switch (Sender)
    {
        case e_PlayerName:
            s = e_PlayerName.GetText();
            if (s != "")
                desiredName = s;
            break;

        case lb_Roles:
            role = RORoleInfo(li_Roles.GetObject());
            if (role != none)
                ChangeDesiredRole(role);
            break;

        case lb_AvailableWeapons[0]:
            UpdateSelectedWeapon(0);
            break;

        case lb_AvailableWeapons[1]:
            UpdateSelectedWeapon(1);
            break;
    }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
    if (key == 0x1B)
    {
        CloseMenu();
        return true;
    }

    return super.OnKeyEvent(key, state, delta);
}

function InternalOnMessage(coerce string Msg, float MsgLife)
{
    local int result;
    local string error_msg;

    if (msg == "notify_gui_role_selection_page")
    {
        // Received success/failure message from server.

        result = int(MsgLife);

        switch (result)
        {
            case 0: // All is well!
            case 97:
            case 98:
                // Set flag saying that player is ready to play
                if (ROPlayer(PlayerOwner()) != none)
                    ROPlayer(PlayerOwner()).PlayerReplicationInfo.bReadyToPlay = true;

                CloseMenu();
                return;
                //break;

            default:
                error_msg = getErrorMessageForId(result);
                break;
        }

        SetContinueButtonState(false);

        if (Controller != none)
        {
            Controller.OpenMenu(Controller.QuestionMenuClass);
            GUIQuestionPage(Controller.TopPage()).SetupQuestion(error_msg, QBTN_Ok, QBTN_Ok);
        }
    }
}

function bool InternalOnDraw(Canvas canvas)
{
	local vector CamPos, X, Y, Z; //, WX, WY, WZ;
	local rotator CamRot;

	if (!bUseModel || !i_PlayerImage.bVisible || PlayerModel == none || PlayerModel.bHidden)
        return false;

	canvas.GetCameraLocation(CamPos, CamRot);
	GetAxes(CamRot, X, Y, Z);

	UpdatePlayerModelPositionInfo(CamPos, CamRot);


	/*if (PlayerModel.DrawType == DT_Mesh)
	{
		GetAxes(PlayerModel.Rotation, WX, WY, WZ);
		PlayerModel.SetLocation(CamPos + (PlayerModelOffset.X * X) + (PlayerModelOffset.Y * Y) + (PlayerModelOffset.Z * Z) + (30 * WX));
	}
	else
	{*/
		PlayerModel.SetLocation(CamPos + (PlayerModelOffset.X * X) + (PlayerModelOffset.Y * Y) + (PlayerModelOffset.Z * Z));
	//}

	canvas.DrawActorClipped(PlayerModel, false, i_PlayerImage.ClientBounds[0], i_PlayerImage.ClientBounds[1], i_PlayerImage.ClientBounds[2] - i_PlayerImage.ClientBounds[0], i_PlayerImage.ClientBounds[3] - i_PlayerImage.ClientBounds[1], true, PlayerModelFOV);
}

function InternalOnClose(optional bool bCancelled)
{
    local PlayerController pc;

    if (PlayerModelHeadgear != none)
        PlayerModelHeadgear.Destroy();
    PlayerModelHeadgear = none;

    if (PlayerModelAmmoPouch != none)
        PlayerModelAmmoPouch.Destroy();
    PlayerModelAmmoPouch = none;

    if (PlayerModelWeapon != none)
        PlayerModelWeapon.Destroy();
    PlayerModelWeapon = none;

    if (PlayerModel != none)
        PlayerModel.Destroy();
    PlayerModel = none;

    // Turn pause off if currently paused
    pc = PlayerOwner();
	if (pc != None && pc.Level.Pauser != None)
		pc.SetPause(false);

	Super.OnClose(bCancelled);
}

static function string getErrorMessageForId(int id)
{
    local string error_msg;
    switch (id)
    {
        // TEAM CHANGE ERROR

        case 01: // Couldn't switch to spectator: no player replication info
            error_msg = default.UnknownErrorMessageText $ default.UnknownErrorSpectatorMissingReplicationInfo;
            break;

        case 02: // Couldn't switch to spectator: out of spectator slots
            error_msg = default.SpectatorErrorTooManySpectators;
            break;

        case 03: // Couldn't switch to spectator: game has ended
        case 04: // Couldn't switch to spectator: round has ended
            error_msg = default.SpectatorErrorRoundHasEnded;
            break;


        case 10: // Couldn't switch teams: no player replication info
            error_msg = default.UnknownErrorMessageText $ default.UnknownErrorTeamMissingReplicationInfo;
            break;

        case 11: // Couldn't switch teams: must join team before game start
            error_msg = default.ErrorTeamMustJoinBeforeStart;
            break;

        case 12: // Couldn't switch teams: too many active players
            error_msg = default.TeamSwitchErrorTooManyPlayers;
            break;

        case 13: // Couldn't switch teams: MaxLives > 0 (wtf is this)
            error_msg = default.UnknownErrorMessageText $ default.UnknownErrorTeamMaxLives;
            break;

        case 14: // Couldn't switch teams: game has ended
        case 15: // Couldn't switch teams: round has ended
            error_msg = default.TeamSwitchErrorRoundHasEnded;
            break;

        case 16: // Couldn't switch teams: server rules disallow team changes after game has started
            error_msg = default.TeamSwitchErrorGameHasStarted;
            break;

        case 17: // Couldn't switch teams: playing game against bots
            error_msg = default.TeamSwitchErrorPlayingAgainstBots;
            break;

        case 18: // Couldn't switch teams: team is full
            error_msg = default.TeamSwitchErrorTeamIsFull;
            break;


        case 99: // Couldn't change teams: unknown reason
            error_msg = default.ErrorChangingTeamsMessageText;
            break;


        // ROLE CHANGE ERROR

        case 100: // Couldn't change roles (role is full)
            error_msg = default.RoleIsFullMessageText;
            break;


        case 199: // Couldn't change roles (unknown error)
            error_msg = default.UnknownErrorMessageText;
            break;


        default:
            error_msg = default.UnknownErrorMessageText $ " (id = " $ id $ ")";
    }

    return error_msg;
}

defaultproperties
{
     Begin Object Class=ROGUIProportionalContainerNoSkinAlt Name=MainContiner_inst
         WinHeight=1.000000
         OnPreDraw=MainContiner_inst.InternalPreDraw
     End Object
     MainContainer=ROGUIProportionalContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.MainContiner_inst'

     Begin Object Class=ROGUIProportionalContainerNoSkinAlt Name=UnitsContainer_inst
         ImageOffset(0)=10.000000
         ImageOffset(1)=10.000000
         ImageOffset(2)=10.000000
         ImageOffset(3)=10.000000
         WinTop=0.031667
         WinLeft=0.010000
         WinWidth=0.243750
         WinHeight=0.156250
         OnPreDraw=UnitsContainer_inst.InternalPreDraw
     End Object
     UnitsContainer=ROGUIProportionalContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.UnitsContainer_inst'

     Begin Object Class=ROGUIProportionalContainerNoSkinAlt Name=RolesContainer_inst
         ImageOffset(0)=10.000000
         ImageOffset(1)=10.000000
         ImageOffset(2)=10.000000
         ImageOffset(3)=10.000000
         WinTop=0.260000
         WinLeft=0.010000
         WinWidth=0.243750
         WinHeight=0.288750
         OnPreDraw=RolesContainer_inst.InternalPreDraw
     End Object
     RolesContainer=ROGUIProportionalContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.RolesContainer_inst'

     Begin Object Class=ROGUIProportionalContainerNoSkinAlt Name=RoleDesc_inst
         ImageOffset(0)=10.000000
         ImageOffset(1)=10.000000
         ImageOffset(2)=10.000000
         ImageOffset(3)=10.000000
         WinTop=0.620000
         WinLeft=0.010000
         WinWidth=0.485000
         WinHeight=0.310000
         OnPreDraw=RoleDesc_inst.InternalPreDraw
     End Object
     RoleDescContainer=ROGUIProportionalContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.RoleDesc_inst'

     Begin Object Class=ROGUIProportionalContainerNoSkinAlt Name=PlayerContainer_inst
         ImageOffset(0)=10.000000
         ImageOffset(1)=10.000000
         ImageOffset(2)=10.000000
         ImageOffset(3)=10.000000
         WinTop=0.031667
         WinLeft=0.272500
         WinWidth=0.221250
         WinHeight=0.518750
         OnPreDraw=PlayerContainer_inst.InternalPreDraw
     End Object
     PlayerContainer=ROGUIProportionalContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.PlayerContainer_inst'

     Begin Object Class=ROGUIProportionalContainerNoSkinAlt Name=PrimaryWeaponContainer_inst
         ImageOffset(0)=10.000000
         ImageOffset(1)=10.000000
         ImageOffset(2)=10.000000
         ImageOffset(3)=10.000000
         WinTop=0.066667
         WinLeft=0.513750
         WinWidth=0.475000
         WinHeight=0.243750
         OnPreDraw=PrimaryWeaponContainer_inst.InternalPreDraw
     End Object
     PrimaryWeaponContainer=ROGUIProportionalContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.PrimaryWeaponContainer_inst'

     Begin Object Class=ROGUIProportionalContainerNoSkinAlt Name=SecondaryWeaponContainer_inst
         ImageOffset(0)=10.000000
         ImageOffset(1)=10.000000
         ImageOffset(2)=10.000000
         ImageOffset(3)=10.000000
         WinTop=0.380000
         WinLeft=0.513750
         WinWidth=0.475000
         WinHeight=0.236250
         OnPreDraw=SecondaryWeaponContainer_inst.InternalPreDraw
     End Object
     SecondaryWeaponContainer=ROGUIProportionalContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.SecondaryWeaponContainer_inst'

     Begin Object Class=ROGUIProportionalContainerNoSkinAlt Name=EquipmentContainer_inst
         ImageOffset(0)=10.000000
         ImageOffset(1)=10.000000
         ImageOffset(2)=10.000000
         ImageOffset(3)=10.000000
         WinTop=0.680000
         WinLeft=0.513750
         WinWidth=0.475000
         WinHeight=0.250000
         OnPreDraw=EquipmentContainer_inst.InternalPreDraw
     End Object
     EquipContainer=ROGUIProportionalContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.EquipmentContainer_inst'

     Begin Object Class=GUILabel Name=RolesTitle
         Caption="Role Selection"
         TextAlign=TXTA_Right
         StyleName="CaptionLabel"
         WinTop=0.223333
         WinLeft=0.071250
         WinWidth=0.175000
         WinHeight=0.040000
     End Object
     l_RolesTitle=GUILabel'ROInterface.ROGUIRoleSelection.RolesTitle'

     Begin Object Class=GUILabel Name=RoleDescTitle
         Caption="Role Description"
         TextAlign=TXTA_Right
         StyleName="CaptionLabel"
         WinTop=0.571666
         WinLeft=0.316250
         WinWidth=0.175000
         WinHeight=0.040000
     End Object
     l_RoleDescTitle=GUILabel'ROInterface.ROGUIRoleSelection.RoleDescTitle'

     Begin Object Class=GUILabel Name=PrimaryWeaponTitle
         Caption="Primary Weapon"
         TextAlign=TXTA_Right
         StyleName="CaptionLabel"
         WinTop=0.035000
         WinLeft=0.803751
         WinWidth=0.175000
         WinHeight=0.040000
     End Object
     l_PrimaryWeaponTitle=GUILabel'ROInterface.ROGUIRoleSelection.PrimaryWeaponTitle'

     Begin Object Class=GUILabel Name=SecondaryWeaponTitle
         Caption="Backup Weapon"
         TextAlign=TXTA_Right
         StyleName="CaptionLabel"
         WinTop=0.343334
         WinLeft=0.802501
         WinWidth=0.175000
         WinHeight=0.040000
     End Object
     l_SecondaryWeaponTitle=GUILabel'ROInterface.ROGUIRoleSelection.SecondaryWeaponTitle'

     Begin Object Class=GUILabel Name=EquipmentWeaponTitle
         Caption="Equipment"
         TextAlign=TXTA_Right
         StyleName="CaptionLabel"
         WinTop=0.640000
         WinLeft=0.806250
         WinWidth=0.175000
         WinHeight=0.040000
     End Object
     l_EquipTitle=GUILabel'ROInterface.ROGUIRoleSelection.EquipmentWeaponTitle'

     Begin Object Class=BackgroundImage Name=PageBackground
         Image=Texture'InterfaceArt_tex.SelectMenus.roleselect'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=1023
         Y2=1023
     End Object
     bg_Background=BackgroundImage'ROInterface.ROGUIRoleSelection.PageBackground'

     Begin Object Class=BackgroundImage Name=PageBackground2
         Image=Texture'InterfaceArt_tex.SelectMenus.Setupmenu'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Alpha
         X1=0
         Y1=0
         X2=1023
         Y2=1023
     End Object
     bg_Background2=BackgroundImage'ROInterface.ROGUIRoleSelection.PageBackground2'

     Begin Object Class=GUIButton Name=DisconnectButton
         Caption="Disconnect"
         bAutoShrink=False
         StyleName="SelectTab"
         Hint="Disconnect from current game"
         WinTop=0.958750
         WinLeft=0.012000
         WinWidth=0.180000
         TabOrder=1
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=DisconnectButton.InternalOnKeyEvent
     End Object
     b_Disconnect=GUIButton'ROInterface.ROGUIRoleSelection.DisconnectButton'

     Begin Object Class=GUIButton Name=MapButton
         Caption="Situation Map"
         bAutoShrink=False
         StyleName="SelectTab"
         Hint="View Situation Map"
         WinTop=0.958750
         WinLeft=0.220000
         WinWidth=0.180000
         TabOrder=2
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=MapButton.InternalOnKeyEvent
     End Object
     b_Map=GUIButton'ROInterface.ROGUIRoleSelection.MapButton'

     Begin Object Class=GUIButton Name=ScoreButton
         Caption="Score"
         bAutoShrink=False
         StyleName="SelectTab"
         Hint="View current team and player scores"
         WinTop=0.958750
         WinLeft=0.410000
         WinWidth=0.180000
         TabOrder=3
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=ScoreButton.InternalOnKeyEvent
     End Object
     b_Score=GUIButton'ROInterface.ROGUIRoleSelection.ScoreButton'

     Begin Object Class=GUIButton Name=ConfigButton
         bAutoShrink=False
         StyleName="SelectTab"
         WinTop=0.958750
         WinLeft=0.600000
         WinWidth=0.180000
         TabOrder=4
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=ConfigButton.InternalOnKeyEvent
     End Object
     b_Config=GUIButton'ROInterface.ROGUIRoleSelection.ConfigButton'

     Begin Object Class=GUIButton Name=ContinueButton
         Caption="Continue"
         bAutoShrink=False
         StyleName="SelectTab"
         Hint="Continue current game"
         WinTop=0.958750
         WinLeft=0.808000
         WinWidth=0.180000
         TabOrder=5
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=ContinueButton.InternalOnKeyEvent
     End Object
     b_Continue=GUIButton'ROInterface.ROGUIRoleSelection.ContinueButton'

     Begin Object Class=ROGUIContainerNoSkinAlt Name=CurrentUnitsA
         WinWidth=0.700000
         WinHeight=1.000000
         OnPreDraw=CurrentUnitsA.InternalPreDraw
     End Object
     CurrentUnitsContainerA=ROGUIContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.CurrentUnitsA'

     Begin Object Class=ROGUIContainerNoSkinAlt Name=CurrentUnitsB
         WinLeft=0.700000
         WinWidth=0.300000
         WinHeight=1.000000
         OnPreDraw=CurrentUnitsB.InternalPreDraw
     End Object
     CurrentUnitsContainerB=ROGUIContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.CurrentUnitsB'

     Begin Object Class=GUIButton Name=JoinAxisButton
         Caption="Join Axis"
         StyleName="SelectButton"
         Hint="Join the Axis forces"
         WinHeight=0.037500
         TabOrder=6
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=JoinAxisButton.InternalOnKeyEvent
     End Object
     b_JoinAxis=GUIButton'ROInterface.ROGUIRoleSelection.JoinAxisButton'

     Begin Object Class=GUIButton Name=JoinAlliesButton
         Caption="Join Allies"
         StyleName="SelectButton"
         Hint="Join the Allied forces"
         WinHeight=0.037500
         TabOrder=7
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=JoinAlliesButton.InternalOnKeyEvent
     End Object
     b_JoinAllies=GUIButton'ROInterface.ROGUIRoleSelection.JoinAlliesButton'

     Begin Object Class=GUIButton Name=SpectateButton
         Caption="Spectate"
         StyleName="SelectButton"
         Hint="Observe the game as a non-playing spectator"
         WinHeight=0.037500
         TabOrder=8
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=SpectateButton.InternalOnKeyEvent
     End Object
     b_Spectate=GUIButton'ROInterface.ROGUIRoleSelection.SpectateButton'

     Begin Object Class=GUILabel Name=NumAxisLabel
         Caption="?"
         TextAlign=TXTA_Center
         StyleName="TextLabel"
     End Object
     l_numAxis=GUILabel'ROInterface.ROGUIRoleSelection.NumAxisLabel'

     l_numAllies=GUILabel'ROInterface.ROGUIRoleSelection.NumAxisLabel'

     Begin Object Class=GUILabel Name=NumFakeLabel
         Caption=" "
         TextAlign=TXTA_Center
         StyleName="TextLabel"
     End Object
     l_numFake=GUILabel'ROInterface.ROGUIRoleSelection.NumFakeLabel'

     Begin Object Class=ROGUIListBoxPlus Name=Roles
         SelectedStyleName="ListSelection"
         OutlineStyleName="ItemOutline"
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=Roles.InternalOnCreateComponent
         WinHeight=1.000000
         TabOrder=0
         OnChange=ROGUIRoleSelection.InternalOnChange
     End Object
     lb_Roles=ROGUIListBoxPlus'ROInterface.ROGUIRoleSelection.Roles'

     Begin Object Class=GUIImage Name=PlayerImage
         Image=Texture'InterfaceArt_tex.Menu.empty'
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         WinTop=0.120000
         WinHeight=0.880000
         OnDraw=ROGUIRoleSelection.InternalOnDraw
     End Object
     i_PlayerImage=GUIImage'ROInterface.ROGUIRoleSelection.PlayerImage'

     Begin Object Class=GUIScrollTextBox Name=RoleDescriptionTextBox
         bNoTeletype=True
         OnCreateComponent=RoleDescriptionTextBox.InternalOnCreateComponent
         StyleName="TextLabel"
         WinHeight=1.000000
     End Object
     l_RoleDescription=GUIScrollTextBox'ROInterface.ROGUIRoleSelection.RoleDescriptionTextBox'

     Begin Object Class=GUILabel Name=PlayerNameLabel
         Caption="Name:"
         StyleName="TextLabel"
         WinWidth=0.350000
         WinHeight=0.100000
     End Object
     l_PlayerName=GUILabel'ROInterface.ROGUIRoleSelection.PlayerNameLabel'

     Begin Object Class=GUIEditBox Name=PlayerNameEditbox
         TextStr="(Player name)"
         WinLeft=0.350000
         WinWidth=0.650000
         WinHeight=0.100000
         OnActivate=PlayerNameEditbox.InternalActivate
         OnDeActivate=PlayerNameEditbox.InternalDeactivate
         OnChange=ROGUIRoleSelection.InternalOnChange
         OnKeyType=PlayerNameEditbox.InternalOnKeyType
         OnKeyEvent=PlayerNameEditbox.InternalOnKeyEvent
     End Object
     e_PlayerName=GUIEditBox'ROInterface.ROGUIRoleSelection.PlayerNameEditbox'

     Begin Object Class=GUIImage Name=WeaponImage
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         WinWidth=0.650000
         WinHeight=0.500000
     End Object
     i_WeaponImages(0)=GUIImage'ROInterface.ROGUIRoleSelection.WeaponImage'

     i_WeaponImages(1)=GUIImage'ROInterface.ROGUIRoleSelection.WeaponImage'

     Begin Object Class=GUIScrollTextBox Name=WeaponDescription
         bNoTeletype=True
         OnCreateComponent=WeaponDescription.InternalOnCreateComponent
         StyleName="TextLabel"
         WinTop=0.550000
         WinHeight=0.450000
     End Object
     l_WeaponDescription(0)=GUIScrollTextBox'ROInterface.ROGUIRoleSelection.WeaponDescription'

     l_WeaponDescription(1)=GUIScrollTextBox'ROInterface.ROGUIRoleSelection.WeaponDescription'

     Begin Object Class=ROGUIListBoxPlus Name=WeaponListBox
         SelectedStyleName="ListSelection"
         OutlineStyleName="ItemOutline"
         bVisibleWhenEmpty=True
         OnCreateComponent=WeaponListBox.InternalOnCreateComponent
         WinLeft=0.700000
         WinWidth=0.300000
         WinHeight=0.500000
         TabOrder=0
         OnChange=ROGUIRoleSelection.InternalOnChange
     End Object
     lb_AvailableWeapons(0)=ROGUIListBoxPlus'ROInterface.ROGUIRoleSelection.WeaponListBox'

     lb_AvailableWeapons(1)=ROGUIListBoxPlus'ROInterface.ROGUIRoleSelection.WeaponListBox'

     Begin Object Class=GUIGFXButton Name=EquipButton0
         Graphic=Texture'InterfaceArt_tex.HUD.satchel_ammo'
         Position=ICP_Scaled
         bClientBound=True
         StyleName="ImageButton"
         WinWidth=0.200000
         WinHeight=0.495000
         TabOrder=21
         bTabStop=True
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=EquipButton0.InternalOnKeyEvent
     End Object
     b_Equipment(0)=GUIGFXButton'ROInterface.ROGUIRoleSelection.EquipButton0'

     Begin Object Class=GUIGFXButton Name=EquipButton1
         Graphic=Texture'InterfaceArt_tex.HUD.satchel_ammo'
         Position=ICP_Scaled
         bClientBound=True
         StyleName="ImageButton"
         WinLeft=0.210000
         WinWidth=0.200000
         WinHeight=0.495000
         TabOrder=22
         bTabStop=True
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=EquipButton1.InternalOnKeyEvent
     End Object
     b_Equipment(1)=GUIGFXButton'ROInterface.ROGUIRoleSelection.EquipButton1'

     Begin Object Class=GUIGFXButton Name=EquipButton2
         Graphic=Texture'InterfaceArt_tex.HUD.satchel_ammo'
         Position=ICP_Scaled
         bClientBound=True
         StyleName="ImageButton"
         WinLeft=0.420000
         WinWidth=0.200000
         WinHeight=0.495000
         TabOrder=23
         bTabStop=True
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=EquipButton2.InternalOnKeyEvent
     End Object
     b_Equipment(2)=GUIGFXButton'ROInterface.ROGUIRoleSelection.EquipButton2'

     Begin Object Class=GUIGFXButton Name=EquipButton3
         Graphic=Texture'InterfaceArt_tex.HUD.satchel_ammo'
         Position=ICP_Scaled
         bClientBound=True
         StyleName="ImageButton"
         WinTop=0.505000
         WinWidth=0.410000
         WinHeight=0.495000
         TabOrder=24
         bTabStop=True
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=EquipButton3.InternalOnKeyEvent
     End Object
     b_Equipment(3)=GUIGFXButton'ROInterface.ROGUIRoleSelection.EquipButton3'

     Begin Object Class=GUIScrollTextBox Name=EquipDescTextBox
         bNoTeletype=True
         OnCreateComponent=EquipDescTextBox.InternalOnCreateComponent
         StyleName="TextLabel"
         WinLeft=0.440000
         WinWidth=0.560000
         WinHeight=1.000000
     End Object
     l_EquipmentDescription=GUIScrollTextBox'ROInterface.ROGUIRoleSelection.EquipDescTextBox'

     Begin Object Class=ROGUIContainerNoSkinAlt Name=ConfigButtonsContainer_inst
         WinTop=0.208333
         WinLeft=0.060000
         WinWidth=0.200000
         WinHeight=0.600000
         OnPreDraw=ConfigButtonsContainer_inst.InternalPreDraw
     End Object
     ConfigButtonsContainer=ROGUIContainerNoSkinAlt'ROInterface.ROGUIRoleSelection.ConfigButtonsContainer_inst'

     Begin Object Class=GUIButton Name=StartNewGameButton
         Caption="Start New Game"
         StyleName="SelectButton"
         Hint="Start a new single player session"
         TabOrder=11
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=StartNewGameButton.InternalOnKeyEvent
     End Object
     b_StartNewGame=GUIButton'ROInterface.ROGUIRoleSelection.StartNewGameButton'

     Begin Object Class=GUIButton Name=ServerBrowserButton
         Caption="Server Browser"
         StyleName="SelectButton"
         Hint="View available Red Orchestra servers"
         TabOrder=12
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=ServerBrowserButton.InternalOnKeyEvent
     End Object
     b_ServerBrowser=GUIButton'ROInterface.ROGUIRoleSelection.ServerBrowserButton'

     Begin Object Class=GUIButton Name=FavoritesButton
         Caption="Add Favorite"
         StyleName="SelectButton"
         Hint="Add current server in favorites list"
         TabOrder=13
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=FavoritesButton.InternalOnKeyEvent
     End Object
     b_AddFavorite=GUIButton'ROInterface.ROGUIRoleSelection.FavoritesButton'

     Begin Object Class=GUIButton Name=MapVotingButton
         Caption="Map Voting"
         StyleName="SelectButton"
         Hint="Open the Map Voting dialog"
         TabOrder=2
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=MapVotingButton.InternalOnKeyEvent
     End Object
     b_MapVoting=GUIButton'ROInterface.ROGUIRoleSelection.MapVotingButton'

     Begin Object Class=GUIButton Name=KickVotingButton
         Caption="Kick Voting"
         StyleName="SelectButton"
         Hint="Open the Kick Voting dialog"
         TabOrder=14
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=KickVotingButton.InternalOnKeyEvent
     End Object
     b_KickVoting=GUIButton'ROInterface.ROGUIRoleSelection.KickVotingButton'

     Begin Object Class=GUIButton Name=CommunicationButton
         Caption="Communication"
         StyleName="SelectButton"
         Hint="Open the VOIP Communication dialog"
         TabOrder=15
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=CommunicationButton.InternalOnKeyEvent
     End Object
     b_Communication=GUIButton'ROInterface.ROGUIRoleSelection.CommunicationButton'

     Begin Object Class=GUIButton Name=ConfigurationButton
         Caption="Configuration"
         StyleName="SelectButton"
         Hint="Configure Red Orchestra"
         TabOrder=16
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=ConfigurationButton.InternalOnKeyEvent
     End Object
     b_Configuration=GUIButton'ROInterface.ROGUIRoleSelection.ConfigurationButton'

     Begin Object Class=GUIButton Name=ExitROButton
         Caption="Exit Red Orchestra"
         StyleName="SelectButton"
         Hint="Exit from the game"
         TabOrder=17
         OnClick=ROGUIRoleSelection.InternalOnClick
         OnKeyEvent=ExitROButton.InternalOnKeyEvent
     End Object
     b_ExitRO=GUIButton'ROInterface.ROGUIRoleSelection.ExitROButton'

     NoSelectedRoleText="Select a role from the role list."
     RoleHasBotsText=" (has bots)"
     RoleFullText="Full"
     SelectEquipmentText="Select an item to view its description."
     RoleIsFullMessageText="The role you selected is full. Select another role from the list and hit continue."
     ChangingRoleMessageText="Please wait while your player information is being updated."
     UnknownErrorMessageText="An unknown error occured when updating player information. Please wait a bit and retry."
     ErrorChangingTeamsMessageText="An error occured when changing teams. Please retry in a few moments or select another team."
     UnknownErrorSpectatorMissingReplicationInfo=" (Spectator switch error: player has no replication info.)"
     SpectatorErrorTooManySpectators="Cannot switch to Spectating mode: too many spectators on server."
     SpectatorErrorRoundHasEnded="Cannot switch to Spectating mode: round has ended."
     UnknownErrorTeamMissingReplicationInfo=" (Team switch error: player has no replication info.)"
     ErrorTeamMustJoinBeforeStart="Cannot switch teams: must join team before game starts."
     TeamSwitchErrorTooManyPlayers="Cannot switch teams: too many active players in game."
     UnknownErrorTeamMaxLives=" (Team switch error: MaxLives > 0)"
     TeamSwitchErrorRoundHasEnded="Cannot switch teams: round has ended."
     TeamSwitchErrorGameHasStarted="Cannot switch teams: server rules disallow team changes after game has started."
     TeamSwitchErrorPlayingAgainstBots="Cannot switch teams: server rules ask for bots on one team and players on the other."
     TeamSwitchErrorTeamIsFull="Cannot switch teams: the selected team is full."
     ConfigurationButtonText1="Game Controls"
     ConfigurationButtonHint1="Show the game and configuration controls"
     ConfigurationButtonText2="Role Selection"
     ConfigurationButtonHint2="Show the role selection controls"
     RoleSelectFooterButtonsWinTop=0.946667
     OptionsFooterButtonsWinTop=0.958750
     PlayerModelOffset=(X=100.000000,Y=-30.000000,Z=-65.000000)
     PlayerModelRotOffset=(Yaw=19000)
     PlayerModelScale=1.700000
     PlayerModelRotScale=(X=1.000000,Y=1.000000,Z=1.000000)
     PlayerModelAnim="'"
     PlayerModelFOV=90.000000
     bRenderWorld=True
     bAllowedAsLast=True
     OnClose=ROGUIRoleSelection.InternalOnClose
     OnMessage=ROGUIRoleSelection.InternalOnMessage
     OnKeyEvent=ROGUIRoleSelection.InternalOnKeyEvent
}
