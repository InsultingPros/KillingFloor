//=============================================================================
// ROHintManager
//=============================================================================
// This class manages (most) of the hinting system stuff. It is spawned and
// referenced in ROPlayer. It also interfaces with ROHud to display the hints
// on screen. Finally, config variables are used to
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Mathieu Mallet
//=============================================================================

class ROHintManager extends Info
    config(User);

// Data structures
struct HintInfo
{
    var() int                   type;
    var() int                   priority; // 1 = highest priority, 2 = lower than 0, etc
    var() int                   delay; // how many seconds to wait before displaying the hint
    var() localized string      title;
    var() localized string      hint;   // actual hint text
    var int                     index; // set in code, do not use!
};

// Constants
const                           MAX_HINT_TYPES = 25;
const                           MAX_HINTS = 50;

// config variables
var()   float                   PostHintDisplayDelay;           // How long to wait before displaying any other hint (value higher than 0 needed)
var()   float                   SameHintTypePostDisplayDelay;   // How long to wait before authorizing a hint from same type to be displayed (value higher than 0 needed)
var()   HintInfo                Hints[MAX_HINTS];
var     config  int             bUsedUpHints[MAX_HINTS]; // 0 = hint unused, 1 = hint used before
var     float                   RandomHintTimerDelay;

// Hints array
var     int                     HintsAvailableByType[MAX_HINT_TYPES];
var     array<HintInfo>         SortedHints;

// State variables
var     HintInfo                CurrentHint; // Copy of hint for convenience
var     int                     CurrentHintIndex; // Index in the SortedHints array
var     float                   LastHintDisplayTime;
var     int                     LastHintType;


function PostBeginPlay()
{
    super.PostBeginPlay();
    LastHintType = -1;
    LoadHints();
}

static function StaticReset()
{
    local int i;
    for (i = 0; i < MAX_HINT_TYPES; i++)
        default.bUsedUpHints[i] = 0;
    StaticSaveConfig();
}

function NonStaticReset()
{
    local int i;
    for (i = 0; i < MAX_HINT_TYPES; i++)
        bUsedUpHints[i] = 0;
    SaveConfig();
    Reload();
}

function Reload()
{
    StopHinting();
    LoadHints();
}

function LoadHints()
{
    local int i, j, index, priority;

    // Initialize arrays to 0
    SortedHints.Length = 0;
    for (i = 0; i < MAX_HINT_TYPES; i++)
        HintsAvailableByType[i] = 0;

    // Sort hints in the SortedHints by priority -- highest priority hints
    // get placed first. At same time, build array of available hints
    // using id of used hints
    for (i = 0; i < MAX_HINT_TYPES; i++)
    {
        Hints[i].index = i;

        // Check if we should add this hint
        if (bUsedUpHints[i] == 0 && Hints[i].title != "")
        {
            HintsAvailableByType[Hints[i].type]++;

            // Find where we should insert the new hint
            priority = Hints[i].priority;
            index = -1;
            for (j = 0; j < SortedHints.Length; j++)
                if (SortedHints[j].priority >= priority)
                {
                    index = j;
                    break;
                }

            // Add hint to proper position
            if (index == -1)
                SortedHints[SortedHints.Length] = Hints[i];
            else
            {
                SortedHints.Insert(index, 1);
                SortedHints[index] = Hints[i];
            }
        }
    }
}


function CheckForHint(int hintType)
{
    local int i;

    if (HintsAvailableByType[hintType] == 0)
        return;

    // Check if we're allowed to display a hint of this type at this time
    if (LastHintType == hintType)
        if (level.TimeSeconds - LastHintDisplayTime < SameHintTypePostDisplayDelay)
            return;

    // We have available hints! Search array for first non-used hint of that type.
    // (first == highest priority)
    for (i = 0; i < SortedHints.Length; i++)
    {
        if (SortedHints[i].type == hintType)
        {
            CurrentHint = SortedHints[i];
            CurrentHintIndex = i;
            SetTimer(0, false);
            GotoState('PreHintDelay');
            return;
        }
    }

    // If we got here it means that hint couldn't be found. wtf?
    warn("Unable to find hint type '" $ hintType $ "' in SortedHints array, even though HintsAvailableByType"
        $ " indicates that there are " $ HintsAvailableByType[hintType] $ " hints of that type available!");
}

function StopHinting()
{
    GotoState('');
    SetTimer(0, false);
}

// Implemented in WaitHintDone state
function NotifyHintRenderingDone() {}

// Used to dump hint info to console
function DumpHints()
{
    local int i;
    log("Hint availability list:");
    for (i = 0; i < MAX_HINT_TYPES; i++)
        log("#" $ i $ " availability: " $ HintsAvailableByType[i]);
    log("Max number of hints in db: " $ MAX_HINT_TYPES);
    for (i = 0; i < MAX_HINT_TYPES; i++)
        log("#" $ i $ ", type = " $ hints[i].type
            $ ", pri = " $ hints[i].priority
            $ ", delay = " $ hints[i].delay
            $ ", used = " $ bUsedUpHints[i]
            $ ", title = '" $ hints[i].title $ "'"
            $ ", text = '" $ hints[i].hint $ "'");
    log("Hints in sorted array: " $ SortedHints.Length);
    for (i = 0; i < SortedHints.length; i++)
        log("#" $ i $ ", type = " $ SortedHints[i].type
            $ ", pri = " $ SortedHints[i].priority
            $ ", delay = " $ SortedHints[i].delay
            $ ", used = " $ bUsedUpHints[SortedHints[i].index]
            $ ", title = '" $ SortedHints[i].title $ "'"
            $ ", text = '" $ SortedHints[i].hint $ "'");

}

simulated function Timer()
{
    CheckForHint(18);
}

// This state is used when we want to show a hint.
state PreHintDelay
{
    function BeginState()
    {
        if (CurrentHint.delay ~= 0)
            GotoState('WaitHintDone');
        else
            SetTimer(CurrentHint.delay, false);
    }

    // Don't allow another hint to be scheduled when we have one scheduled already
    function CheckForHint(int hintType) {}

    function Timer()
    {
        GotoState('WaitHintDone');
    }
}

state WaitHintDone
{
    function BeginState()
    {
        local ROPlayer player;
        // Tell ROHud to display the hint
        player = ROPlayer(Owner);
        if (player != none &&
            ROHud(player.myHud) != none &&
            !ROHud(player.myHud).bHideHud)
        {
            ROHud(player.myHud).ShowHint(CurrentHint.title, CurrentHint.hint);
        }
        else
        {
            SetTimer(RandomHintTimerDelay, true);
            GotoState('');
        }
    }

    // Don't allow another hint to be scheduled when we're displaying one already
    function CheckForHint(int hintType) {}

    function NotifyHintRenderingDone()
    {
        // Hurray, hint done rendering! Switch to post-hint state.
        GotoState('PostDisplay');
    }
}

state PostDisplay
{
    function BeginState()
    {
        LastHintType = CurrentHint.type;
        LastHintDisplayTime = Level.TimeSeconds;
        SetTimer(PostHintDisplayDelay, false);
    }

    // Don't allow another hint to be scheduled until post-display delay is completed.
    function CheckForHint(int hintType) {}

    function Timer()
    {
        // Mark this hint as used up
        //log("setting hint #" $ CurrentHint.index $ " as used up.");
        bUsedUpHints[CurrentHint.index] = 1;
        SaveConfig();

        // Update hint availability list
        HintsAvailableByType[CurrentHint.type]--;

        // Remove current hint from hints list
        //log("Removing from sortedhints array. old length = " $ SortedHints.Length);
        SortedHints.Remove(CurrentHintIndex, 1);
        //log("                                 new length = " $ SortedHints.Length);

        // Go back to 'idle' state
        SetTimer(RandomHintTimerDelay, true);
        GotoState('');
    }
}

defaultproperties
{
     PostHintDisplayDelay=10.000000
     SameHintTypePostDisplayDelay=30.000000
     Hints(0)=(Delay=3,Title="Welcome",Hint="Welcome to Red Orchestra!||These hint messages will show up periodically in the game. Pay attention to them, your survival might depend on it! They can be disabled from the HUD tab in the configuration menu.")
     Hints(1)=(Type=18,Priority=10,Title="Stamina",Hint="Running or jumping will deplete your player's stamina. When it is depleted, you will be unable to run or jump until you have stopped for a bit to catch your breath.")
     Hints(2)=(Type=1,Priority=1,Delay=2,Title="Jumping",Hint="Jumping quickly drains your player's stamina. Use in moderation!")
     Hints(3)=(Type=18,Priority=20,Title="Leaning",Hint="Press %LeanRight% or %LeanLeft% to lean around corners. Leaning lets you peak around corners without exposing your whole body to the enemy.")
     Hints(4)=(Priority=15,Delay=3,Title="Role Selection",Hint="You can change your weapons and role at any time by hitting the %SHOWMENU% key. The changes you make will take effect when you respawn.")
     Hints(5)=(Type=2,Priority=10,Delay=3,Title="Iron sights",Hint="Press %ROIronSights% to aim down you weapon's sights. This substantially increases the accuracy of your weapon.")
     Hints(6)=(Type=2,Priority=20,Delay=3,Title="Accuracy",Hint="Automatic weapons are most accurate when fired in short, controllable bursts.")
     Hints(7)=(Type=3,Priority=10,Delay=2,Title="Positions",Hint="Use the number keys (%SWITCHWEAPON 1%, %SWITCHWEAPON 2%, %SWITCHWEAPON 3%, ...) to change between various positions in the vehicle.")
     Hints(8)=(Type=3,Priority=15,Delay=2,Title="Crew Members",Hint="A fully crewed tank is more effective than one driven by a lone player. Try to pick up players along the way to your objectives.")
     Hints(9)=(Priority=15,Delay=3,Title="Situation Map",Hint="You can see a map of the objectives that need to be captured or defended by pressing %SHOWOBJECTIVES%.")
     Hints(10)=(Type=4,Priority=10,Delay=2,Title="Weak Points",Hint="Each tank has its weak points. Try aiming for the driver's window or the seam between the tank body and turret.")
     Hints(11)=(Type=4,Priority=10,Delay=2,Title="Ammo Types",Hint="Press %SwitchFireMode% to switch between the various available tank ammo types.")
     Hints(12)=(Type=6,Priority=10,Delay=1,Title="Reloading",Hint="Use the %ROManualReload% key to reload your weapon. A 'Magazine Heavy' message indicates that the magazine you're loading is more than half full of ammunition.")
     Hints(13)=(Type=9,Priority=10,Delay=1,Title="Soviet grenades",Hint="To prime ('cook') Soviet grenades, press and hold the %FIRE%, then click the %ALTFIRE% button. Release the %FIRE% button when you are ready to throw the grenade. Be careful, if you cook it for too long it can go off in your hand!")
     Hints(14)=(Type=8,Priority=10,Delay=1,Title="Rally Points",Hint="When you have the binoculars in Iron Sights, use the %AltFire% button to set a Rally Point. Rally points are visible to all team members on their Situation Map.")
     Hints(15)=(Type=8,Priority=15,Delay=1,Title="Artillery Coordinates",Hint="When you have the binoculars in Iron Sights, use the %Fire% button to save Artillery Strike coordinates. Once coordinates are marked, find a radio and press %USE% to call an artillery strike on the saved position.")
     Hints(16)=(Type=10,Priority=15,Delay=1,Title="Reloading MGs",Hint="You can reload your Machine Gun ONLY when in the deployed state.")
     Hints(17)=(Type=10,Priority=20,Delay=1,Title="Requesting Resupply",Hint="When you're running low on Machine Gun ammo, you can use the voice menu to request a resupply. Players will see the resupply icon on their Situation Map. Press %SpeechMenuToggle% to open the voice menu.")
     Hints(18)=(Type=10,Priority=30,Delay=1,Title="Deployed MGs",Hint="Machine Gunners should never setup alone, find a comrade to watch your back.")
     Hints(19)=(Type=11,Priority=10,Delay=1,Title="Bayonet",Hint="Many weapons support bayonet attachments. Press %Deploy% to attach or detach the bayonet to your weapon and %AltFire% to stab enemies with it.")
     Hints(20)=(Type=12,Priority=10,Delay=1,Title="Panzerfaust Aiming",Hint="You can change the range that your Panzerfaust will target at by pressing the %Deploy% button. Match the distance of your enemy with the selected range displayed on the Panzerfaust sight.")
     Hints(21)=(Type=13,Priority=10,Delay=1,Title="Grenades",Hint="Grenades have a dangerous blast radius - get under cover or away from them!")
     Hints(22)=(Type=15,Priority=10,Delay=1,Title="Objectives Under Attack",Hint="Objectives with a flashing icon are objectives which are under attack. Whether the objective is being attacked or defended by your team, they can probably use your help.")
     Hints(23)=(Type=14,Priority=20,Delay=1,Title="Rally Points",Hint="Squad Leaders can set rally points by clicking on the Situation Map. Those rally points are visible to all team members on their Situation Map.")
     Hints(24)=(Type=14,Priority=30,Delay=1,Title="Orders & Requests",Hint="Squad leaders can set attack/defend orders to specific objectives. Those objectives show up on the map with a different icon. Similarly, MGs requesting resupply will show up as an icon on the Situation Map.")
     Hints(25)=(Type=18,Priority=40,Title="Resupplying MGs",Hint="Use the %ThrowMGAmmo% to resupply Machine Gunners who need it.")
     Hints(26)=(Type=17,Priority=20,Delay=1,Title="Points",Hint="You receive 10 points for helping to capture an objective.")
     Hints(27)=(Type=18,Priority=30,Title="Capturing Objectives",Hint="To capture an objective, you must first enter the objective area. A capture bar will appear on your HUD when you have entered the objective area. You'll likely need more than one additional teammate to initiate and complete the capture.")
     Hints(28)=(Type=2,Priority=20,Delay=3,Title="Accuracy",Hint="Crouching and going prone stabilizes your weapon and lowers recoil when firing. Press the %duck% key to crouch, or the %prone% key to go prone.")
     Hints(29)=(Type=10,Priority=30,Delay=1,Title="Changing Barrels",Hint="You can change the barrels on the MGs by using the %ROMGOperation%. Note that the barrel on the DP 28 cannot be changed, so be careful not to overheat!")
     Hints(30)=(Type=17,Priority=30,Delay=1,Title="Officers",Hint="When taking an objective, the presence of an officer boosts morale and makes your task easier!")
     Hints(31)=(Priority=15,Delay=3,Title="Diving to Prone",Hint="You can dive to prone by pressing %PRONE% while running, allowing you to quickly take cover. You can also use this to dive over small obstacles and take cover behind them.")
     Hints(32)=(Type=18,Priority=40,Title="Attacking MGs",Hint="Machine Gunners have a limited field of vision while deployed, so try attacking them from the side.")
     Hints(33)=(Type=2,Priority=30,Delay=3,Title="Weapon Deployment",Hint="You can stabilize all projectile weapons by simply resting them on a horizontal or vertical surface. An icon will appear in the lower right corner of the screen if the surface is deployable.")
     Hints(34)=(Type=3,Priority=30,Delay=2,Title="Position Views",Hint="Use the %PREVWEAPON% and %NEXTWEAPON% keys to cycle between the various views available for each vehicle position. Be careful when sticking your head out of the commander or driver hatch: you are then vulnerable to enemy fire.")
     Hints(35)=(Type=3,Priority=20,Delay=2,Title="Tank Control",Hint="Use the movement keys to steer and control your vehicle's throttle. Use the %JUMP% key to brake.")
     Hints(36)=(Type=3,Priority=40,Delay=2,Title="Armor Usage",Hint="When combating other tanks, remember that your armor is strongest at the front. Try to angle the front of your vehicle slightly away from enemy fire.")
     Hints(37)=(Type=4,Priority=10,Delay=2,Title="Cannon Fire Range",Hint="Use the %LEANLEFT% and %LEANRIGHT% keys to adjust the range of your tank sights. The range you have your sights set to is displayed, in meters, in the lower right corner of the screen.")
     Hints(38)=(Type=4,Priority=50,Delay=2,Title="Coaxial MG",Hint="Most tanks have a coaxial machine gun alongside the main gun. You can fire it from the commander's view by pressing %ALTFIRE%. Note: range adjustments have no effect on the coaxial MG.")
     Hints(39)=(Type=7,Priority=10,Delay=1,Title="Satchels",Hint="Satchels contain high explosives. They are useful for destroying enemy vehicles and certain objectives. While not all maps have destroyable objectives, those that do have those objectives specially marked on the situation map.")
     Hints(40)=(Type=9,Priority=15,Delay=1,Title="German grenades",Hint="The fuse of German grenades will begin burning as soon as you hit the %FIRE% or %ALTFIRE% button.")
     Hints(41)=(Type=10,Priority=10,Delay=1,Title="Deploying MG",Hint="To fire your Machine Gun properly, you need to deploy it. You can do this while prone or on any convenient surface: the deployment icon will appear in the bottom right corner of the HUD. Press %Deploy% to deploy when you see the icon.")
     Hints(42)=(Type=18,Priority=40,Title="Melee Attacks",Hint="You can bash an enemy soldier with your weapon by pressing the %ALTFIRE% button. The longer you keep the key pressed, the more powerful your attack will be. Aim for the head for a quick kill!")
     Hints(43)=(Type=18,Priority=40,Title="Manual Bolting",Hint="When using a bolt-action rifle, you have to manually work your bolt. After you fire your weapon, press the %FIRE% key again to bolt your rifle. Double click the key when firing to bolt quickly after your shot.")
     Hints(44)=(Type=18,Priority=40,Title="Critical Messages",Hint="Critical messages are displayed in the upper left corner of the screen. Pay attention to them to remain aware of the state of the battle.")
     RandomHintTimerDelay=29.000000
}
