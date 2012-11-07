//=============================================================================
// KFHintManager
//=============================================================================
// This class manages (most) of the hinting system stuff. It is spawned and
// referenced in KFPlayerController. It also interfaces with KFHud to display the hints
// on screen. Finally, config variables are used to
//=============================================================================
class KFHintManager extends Info
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
const                           MAX_HINT_TYPES = 61;
const                           MAX_HINTS = 61;

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
    CheckForHint(60);
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
        local KFPlayerController player;
        
        // Tell HUDKillingFloor to display the hint
        player = KFPlayerController(Owner);
        
		if ( player != none && HUDKillingFloor(player.myHud) != none &&
             !HUDKillingFloor(player.myHud).bHideHud )
        {
            HUDKillingFloor(player.myHud).ShowHint(CurrentHint.title, CurrentHint.hint);
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
        log("bUsedUpHints["$CurrentHint.index$"] was:" @ bUsedUpHints[CurrentHint.index]);
		bUsedUpHints[CurrentHint.index] = 1;
        SaveConfig();
		
        log("bUsedUpHints["$CurrentHint.index$"] is now:" @ bUsedUpHints[CurrentHint.index]);

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
     PostHintDisplayDelay=1.000000
     SameHintTypePostDisplayDelay=2.000000
     Hints(0)=(Type=10,Delay=1,Title="Welcome!",Hint="Use %ToggleAiming% to aim better, %ReloadWeapon% key to reload a clip. Use %PrevWeapon% or %NextWeapon% to switch weapons.")
     Hints(1)=(Type=11,Delay=1,Title="Aiming and Reloading",Hint="Use %ToggleAiming% to aim better, %ReloadWeapon% to reload a clip.")
     Hints(3)=(Type=12,Delay=1,Title="Aiming and Reloading",Hint="Use %ToggleAiming% to aim better, %ReloadWeapon% to reload a clip.")
     Hints(4)=(Type=13,Delay=1,Title="Aiming and Reloading",Hint="Use %ToggleAiming% to aim better, %ReloadWeapon% to reload a clip. Use %AltFire% to switch between full and semi auto.")
     Hints(5)=(Type=14,Delay=1,Title="Aiming and Reloading",Hint="Use %ToggleAiming% to aim better, %ReloadWeapon% to reload.")
     Hints(6)=(Type=15,Delay=1,Title="Aiming and Reloading",Hint="Use %ToggleAiming% to aim better, %ReloadWeapon% to reload.")
     Hints(7)=(Type=16,Delay=1,Title="Aiming",Hint="Use %ToggleAiming% gives you a scope for long-distance shooting.")
     Hints(8)=(Type=17,Delay=1,Title="Firing",Hint="Hit %Fire% for one barrel, %AltFire% for the both.")
     Hints(9)=(Type=18,Delay=1,Title="Watch The Flames!",Hint="Flame-thrower - it burns! Just don't let burning creatures get too close or you'll burn too!")
     Hints(10)=(Type=19,Delay=1,Title="The LAW",Hint="If you've got far enough to be carrying this baby, you shouldn't need any more hints on weapons!")
     Hints(11)=(Type=20,Delay=1,Title="Knife",Hint="Switch to this weapon to run your fastest!")
     Hints(12)=(Type=21,Delay=1,Title="Machete",Hint="Like a knife. Just bigger and nastier.")
     Hints(13)=(Type=22,Delay=1,Title="Fire-axe",Hint="You need hints on what to do with THIS?!")
     Hints(14)=(Type=30,Delay=1,Title="Specimen Counter",Hint="Shows you how many of the blighters there are left to 'remove'. Or is that how many there are trying to 'remove' YOU?")
     Hints(15)=(Type=31,Title="Way to the Trader",Hint="Trader arrow and the red 'follow-me' shows you where the Trader's shop is and how far away - get there before the timer runs out!")
     Hints(16)=(Type=32,Title="Running",Hint="Hit %SwitchWeapon 1% or use %PrevWeapon% or %NextWeapon% to switch to the knife so you can run your fastest")
     Hints(17)=(Type=33,Title="Watch the time!",Hint="Clock indicates how long you have before the next wave of specimens comes for you - time to go shopping!")
     Hints(18)=(Type=40,Title="They are coming!!",Hint="You only have a few seconds left before the next wave arrives - think about where you're going to fight them!")
     Hints(19)=(Type=45,Title="Trader arrow",Hint="Shows you where the Trader will be AFTER the incoming wave.")
     Hints(20)=(Type=50,Title="Doors",Hint="If you want to block off a door, pull out your welder and use it! It will keep them at bay - for a while.")
     Hints(21)=(Type=51,Title="Healing",Hint="Use the med-syringe on yourself - %QuickHeal% for a quick boost!")
     Hints(22)=(Type=52,Title="At the shop",Hint="Press %Use% to start shopping for new kit")
     Hints(23)=(Type=53,Title="Healing",Hint="You must be near another player to heal them.|Press %Fire% to heal a team mate or %AltFire% to heal yourself")
     Hints(24)=(Type=54,Title="Welding",Hint="You must be near a weldable door to use the welder.")
     Hints(40)=(Type=60,Priority=20,Delay=1,Title="Grenades",Hint="Hit %ThrowNade% to toss a grenade out, if it is a target-rich environment!")
     Hints(41)=(Type=60,Priority=20,Delay=1,Title="Healing",Hint="Use the med-syringe on a friend - it works way better on them than it does in your own arm!")
     RandomHintTimerDelay=29.000000
}
