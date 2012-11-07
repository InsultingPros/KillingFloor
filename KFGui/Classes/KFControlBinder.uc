class KFControlBinder extends KeyBindMenu;

var localized string BindingLabel[150];

function LoadCommands()
{
    local int i;

    Super.LoadCommands();

    // Update the MultiColumnList's sortdata array to reflect the indexes of our Bindings array
    for (i = 0; i < Bindings.Length; i++)
        li_Binds.AddedItem();
}

function MapBindings()
{
    LoadCustomBindings();
    Super.MapBindings();
}

protected function LoadCustomBindings()
{
    local int i;
    local array<string> KeyBindClasses;
    local class<GUIUserKeyBinding> CustomKeyBindClass;

    // Load custom keybinds from .int files
    PlayerOwner().GetAllInt("XInterface.GUIUserKeyBinding",KeyBindClasses);
    for (i = 0; i < KeyBindClasses.Length; i++)
    {
        CustomKeyBindClass = class<GUIUserKeyBinding>(DynamicLoadObject(KeyBindClasses[i],class'Class'));
        if (CustomKeyBindClass != None)
            AddCustomBindings( CustomKeyBindClass.default.KeyData );
    }
}

function AddCustomBindings( array<GUIUserKeyBinding.KeyInfo> KeyData )
{
    local int i;

    for ( i = 0; i < KeyData.Length; i++ )
        CreateAliasMapping( KeyData[i].Alias, KeyData[i].KeyLabel, KeyData[i].bIsSection );
}

function ClearBindings()
{
    local int i, max;

    Super.ClearBindings();
    Bindings = default.Bindings;
    max = Min(Bindings.Length, ArrayCount(BindingLabel));
    for ( i = 0; i < max; i++ )
    {
        if ( BindingLabel[i] != "" )
            Bindings[i].KeyLabel = BindingLabel[i];
    }
}

defaultproperties
{
     BindingLabel(0)="Movement"
     BindingLabel(1)="Forward"
     BindingLabel(2)="Backward"
     BindingLabel(3)="Strafe Left"
     BindingLabel(4)="Strafe Right"
     BindingLabel(5)="Jump"
     BindingLabel(6)="Walk"
     BindingLabel(7)="Crouch"
     BindingLabel(8)="Strafe Toggle"
     BindingLabel(9)="Looking"
     BindingLabel(10)="Turn Left"
     BindingLabel(11)="Turn Right"
     BindingLabel(12)="Look Up"
     BindingLabel(13)="Look Down"
     BindingLabel(14)="Center View"
     BindingLabel(15)="Toggle 'BehindView'"
     BindingLabel(16)="Toggle Camera Mode"
     BindingLabel(17)="Weapons"
     BindingLabel(18)="Fire"
     BindingLabel(19)="Alt-Fire"
     BindingLabel(20)="Aiming"
     BindingLabel(21)="Toggle Aiming"
     BindingLabel(22)="Reload"
     BindingLabel(23)="Throw Weapon"
     BindingLabel(24)="Best Weapon"
     BindingLabel(25)="Switch to Knife"
     BindingLabel(26)="Next Weapon"
     BindingLabel(27)="Prev Weapon"
     BindingLabel(28)="Last Weapon"
     BindingLabel(29)="Throw Grenade"
     BindingLabel(30)="Communication"
     BindingLabel(31)="Say"
     BindingLabel(32)="Team Say"
     BindingLabel(33)="In Game Chat"
     BindingLabel(34)="Perks Menu"
     BindingLabel(35)="Activate Microphone"
     BindingLabel(36)="Speak in Public Channel"
     BindingLabel(37)="Speak in local Channel"
     BindingLabel(38)="Speak in Team Channel"
     BindingLabel(39)="Toggle Public Channel"
     BindingLabel(40)="Toggle local Channel"
     BindingLabel(41)="Toggle Team Channel"
     BindingLabel(42)="ShoutSupport"
     BindingLabel(43)="ShoutFormUp"
     BindingLabel(44)="ShoutTakeThis"
     BindingLabel(45)="ShoutTrading"
     BindingLabel(46)="ShoutMedic"
     BindingLabel(47)="ShoutWelding"
     BindingLabel(48)="ShoutCovering"
     BindingLabel(49)="Taunts"
     BindingLabel(50)="Pelvic Thrust"
     BindingLabel(51)="Ass Smack"
     BindingLabel(52)="Throat Cut"
     BindingLabel(53)="Brag"
     BindingLabel(54)="Hud"
     BindingLabel(55)="Grow Hud"
     BindingLabel(56)="Shrink Hud"
     BindingLabel(57)="Game"
     BindingLabel(58)="Use"
     BindingLabel(59)="Pause"
     BindingLabel(60)="Screenshot"
     BindingLabel(61)="Drop Cash"
     BindingLabel(62)="Show Personal Stats"
     BindingLabel(63)="View Next Player's Stats"
     BindingLabel(64)="Server Info"
     BindingLabel(65)="Miscellaneous"
     BindingLabel(66)="Show Objectives"
     BindingLabel(67)="Menu"
     BindingLabel(68)="Music Player"
     BindingLabel(69)="Voting Menu"
     BindingLabel(70)="Toggle Console"
     BindingLabel(71)="View Connection Status"
     BindingLabel(72)="Cancel Pending Connection"
     BindingLabel(73)="Select Melee"
     BindingLabel(74)="Select Pistol/Bullpup"
     BindingLabel(75)="Select Handcannon/Shotgun"
     BindingLabel(76)="Select LAW/Crossbow/Rifle"
     BindingLabel(77)="Select Syringe/Welder"
     BindingLabel(78)="Quick Self-Heal"
     Bindings(0)=(bIsSectionLabel=True,KeyLabel="Movement")
     Bindings(1)=(KeyLabel="Forward",Alias="MoveForward")
     Bindings(2)=(KeyLabel="Backward",Alias="MoveBackward")
     Bindings(3)=(KeyLabel="Strafe Left",Alias="StrafeLeft")
     Bindings(4)=(KeyLabel="Strafe Right",Alias="StrafeRight")
     Bindings(5)=(KeyLabel="Jump",Alias="Jump")
     Bindings(6)=(KeyLabel="Walk",Alias="Walking")
     Bindings(7)=(KeyLabel="Crouch",Alias="Duck")
     Bindings(8)=(KeyLabel="Strafe Toggle",Alias="Strafe")
     Bindings(9)=(bIsSectionLabel=True,KeyLabel="Looking")
     Bindings(10)=(KeyLabel="Turn Left",Alias="TurnLeft")
     Bindings(11)=(KeyLabel="Turn Right",Alias="TurnRight")
     Bindings(12)=(KeyLabel="Look Up",Alias="LookUp")
     Bindings(13)=(KeyLabel="Look Down",Alias="LookDown")
     Bindings(14)=(KeyLabel="Center View",Alias="CenterView")
     Bindings(15)=(KeyLabel="Toggle 'BehindView'",Alias="ToggleBehindView")
     Bindings(16)=(KeyLabel="Toggle Camera Mode",Alias="ToggleFreeCam")
     Bindings(17)=(bIsSectionLabel=True,KeyLabel="Weapons")
     Bindings(18)=(KeyLabel="Fire",Alias="Fire")
     Bindings(19)=(KeyLabel="Alt-Fire/Flashlight",Alias="AltFire")
     Bindings(20)=(KeyLabel="Aiming",Alias="Aiming")
     Bindings(21)=(KeyLabel="Toggle Aiming",Alias="ToggleAiming")
     Bindings(22)=(KeyLabel="Reload Weapon",Alias="ReloadWeapon")
     Bindings(23)=(KeyLabel="Throw Weapon",Alias="ThrowWeapon")
     Bindings(24)=(KeyLabel="Best Weapon",Alias="SwitchToBestWeapon")
     Bindings(25)=(KeyLabel="Switch to Knife",Alias="SwitchToBestMeleeWeapon")
     Bindings(26)=(KeyLabel="Next Weapon",Alias="NextWeapon")
     Bindings(27)=(KeyLabel="Prev Weapon",Alias="PrevWeapon")
     Bindings(28)=(KeyLabel="Last Weapon",Alias="SwitchToLastWeapon")
     Bindings(29)=(KeyLabel="Throw Grenade",Alias="ThrowNade")
     Bindings(30)=(bIsSectionLabel=True,KeyLabel="Communication")
     Bindings(31)=(KeyLabel="Say",Alias="Talk")
     Bindings(32)=(KeyLabel="Team Say",Alias="TeamTalk")
     Bindings(33)=(KeyLabel="In Game Chat",Alias="InGameChat")
     Bindings(34)=(KeyLabel="Perks Menu",Alias="OpenVeterancyMenu")
     Bindings(35)=(KeyLabel="Activate Microphone",Alias="VoiceTalk")
     Bindings(36)=(KeyLabel="Speak in Public Channel",Alias="Speak Public")
     Bindings(37)=(KeyLabel="Speak in local Channel",Alias="Speak Local")
     Bindings(38)=(KeyLabel="Speak in Team Channel",Alias="Speak Team")
     Bindings(39)=(KeyLabel="Toggle Public Chatroom",Alias="TogglePublicChat")
     Bindings(40)=(KeyLabel="Toggle local Chatroom",Alias="ToggleLocalChat")
     Bindings(41)=(KeyLabel="Toggle Team Chatroom",Alias="ToggleTeamChat")
     Bindings(42)=(KeyLabel="Shout: Need Support",Alias="ShoutSupport")
     Bindings(43)=(KeyLabel="Shout: Form Up On Me",Alias="ShoutFormUp")
     Bindings(44)=(KeyLabel="Shout: Take This",Alias="ShoutTakeThis")
     Bindings(45)=(KeyLabel="Shout: I'm Going Trading",Alias="ShoutTrading")
     Bindings(46)=(KeyLabel="Shout: MEDIC!",Alias="ShoutMedic")
     Bindings(47)=(KeyLabel="I'm Welding!",Alias="ShoutWelding")
     Bindings(48)=(KeyLabel="I'll Cover You!",Alias="ShoutCovering")
     Bindings(49)=(bIsSectionLabel=True,KeyLabel="Taunts")
     Bindings(50)=(KeyLabel="Pelvic Thrust",Alias="taunt pthrust")
     Bindings(51)=(KeyLabel="Ass Smack",Alias="taunt asssmack")
     Bindings(52)=(KeyLabel="Throat Cut",Alias="taunt throatcut")
     Bindings(53)=(KeyLabel="Brag",Alias="taunt gesture_point")
     Bindings(54)=(bIsSectionLabel=True,KeyLabel="Hud")
     Bindings(55)=(KeyLabel="Grow Hud",Alias="GrowHud")
     Bindings(56)=(KeyLabel="Shrink Hud",Alias="ShrinkHud")
     Bindings(57)=(bIsSectionLabel=True,KeyLabel="Game")
     Bindings(58)=(KeyLabel="Use",Alias="use")
     Bindings(59)=(KeyLabel="Pause",Alias="Pause")
     Bindings(60)=(KeyLabel="Screenshot",Alias="shot")
     Bindings(61)=(KeyLabel="Drop Cash",Alias="TossCash")
     Bindings(62)=(KeyLabel="Show Personal Stats",Alias="ShowStats")
     Bindings(63)=(KeyLabel="View Next Player's Stats",Alias="NextStats")
     Bindings(64)=(KeyLabel="Server Info",Alias="ServerInfo")
     Bindings(65)=(bIsSectionLabel=True,KeyLabel="Miscellaneous")
     Bindings(66)=(KeyLabel="Show Objectives",Alias="ShowScores")
     Bindings(67)=(KeyLabel="Menu",Alias="ShowMenu")
     Bindings(68)=(KeyLabel="Music Player",Alias="MusicMenu")
     Bindings(69)=(KeyLabel="Voting Menu",Alias="ShowVoteMenu")
     Bindings(70)=(KeyLabel="Toggle Console",Alias="ConsoleToggle")
     Bindings(71)=(KeyLabel="View Connection Status",Alias="Stat Net")
     Bindings(72)=(KeyLabel="Cancel Pending Connection",Alias="Cancel")
     Bindings(73)=(KeyLabel="Select Melee",Alias="SwitchWeapon 1")
     Bindings(74)=(KeyLabel="Select Pistol/Bullpup",Alias="SwitchWeapon 2")
     Bindings(75)=(KeyLabel="Select Handcannon/Shotgun",Alias="SwitchWeapon 3")
     Bindings(76)=(KeyLabel="Select LAW/Crossbow/Rifle",Alias="SwitchWeapon 4")
     Bindings(77)=(KeyLabel="Select Syringe/Welder",Alias="SwitchWeapon 6")
     Bindings(78)=(KeyLabel="Quick Self-Heal",Alias="QuickHeal")
     Headings(0)="Action"
     PageCaption="Configure Keys"
}
