//=============================================================================
// SteamStatsAndAchievementsBase
//=============================================================================
// Interface between Steam Stats/Achievements and RO/Mods
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2009 Tripwire Interactive LLC
// Created by Dayle Flowers
//=============================================================================

class SteamStatsAndAchievementsBase extends Actor
    native;

struct native export SteamStatInt
{
    var const int   Value;  // Value of this Stat(can be set by calling SetStatInt)
};

struct native export SteamStatFloat
{
    var const float Value;  // Value of this Stat(can be set by calling SetStatFloat)
};

// Steam updates an Averaging stat by adding SessionNumerator to the existing Numerator in the Steam Database and SessionDenominator
// to the existing Denominator in the Steam Database(which only exists on the client). These stats are only able to be grabbed as
// floats from Steam, but when the client sends the new Session Values Averages to Steam, the Steam Database does a full Numerator
// over Denominator calculation with the new Session Data. In short, this is not a reliable system for checking Achievements on the
// Server in real-time, as you only get the resulting Float *after* the client sends the data to Steam and the Steam Database has
// time to recalculate the new average.  The latest Float Value is only valid in OnStatsAndAchievementsReady and should not be
// considered reliable outside of that function.
struct native export SteamStatAverage
{
    var const float NumeratorValue;     // Numerator Value of this Stat during this Session
    var const float DenominatorValue;   // Denominator Value of this Stat during this Session
};

// Set to true once we've pulled Stats from the Database(prevents Steam screwing up and erasing Stats in Single Player)
var bool                bInitialized;

// Owner of these Stats and Achievements
var PlayerController    PCOwner;

// Set to true by the Timer function to allow us to completely control replication
var bool                bFlushStatsToClient;

// Number of seconds between sending Stats to client
var float               FlushStatsToClientDelay;

// Steam Names
var array<string>       SteamNameStat;
var array<string>       SteamNameAchievement;

// Used to track if God Mode, weapon cheats, summoning, and others have ever been used
var bool                bUsedCheats;

// Debug
var globalconfig bool bResetStats;
var globalconfig bool bDebugStats;

// Delegate callback for Stats and Achievements data initialization completion
delegate OnDataInitialized();

// Gets the Server ready to handle Stats
native final function bool Initialize(PlayerController MyOwner);

// Requests the Owner's Stats and Achievements from Steam(calls OnStatsAndAchievementsReady when completed)
native final function GetStatsAndAchievements();

// Functions to grab individual Stats and Achievements from Steam by name(generally done from the OnStatsAndAchievementsReady callback)
native final function       GetStatInt(SteamStatInt Stat, string SteamName);
native final function       GetStatFloat(SteamStatFloat Stat, string SteamName);
native final function float GetStatAverage(string SteamName);
native final function bool  GetAchievementCompleted(string SteamName);

// Used to natively Initialize the const Stat Variables(Server-side only)
native final function InitStatInt(SteamStatInt Stat, int NewValue);
native final function InitStatFloat(SteamStatFloat Stat, float NewValue);

// Used to natively Set the const Stat Variables(Server-side only)
native final function SetStatInt(SteamStatInt Stat, int NewValue);
native final function SetStatFloat(SteamStatFloat Stat, float NewValue);
native final function SetStatAverage(SteamStatAverage Stat, float NewNumerator, float NewDenominator);

// Called to set bNetDirty which forces replication to the owning client at a preset interval
native final function SetNetDirty();

// Send the specified Int/Float/Stat to the Local Steam Client, not the Steam Database(Client-Side only)
// NOTE: For Average stats, we send Stat.Numerator - SavedStat.Numerator and Stat.Denominator - SavedStat.Denominator,
//       because Steam is keeping a running total behind the scenes.
native final function FlushStatToSteamInt(SteamStatInt Stat, string SteamName);
native final function FlushStatToSteamFloat(SteamStatFloat Stat, string SteamName);
native final function FlushStatToSteamAverage(SteamStatAverage Stat, SteamStatAverage SavedStat, string SteamName);
native final function SetAchievementCompleted(string SteamName);

// Call after all Stats have been changed on the Client to send changed stats from the local Steam Client to the Steam Database
native final function FlushStatsToSteamDatabase();

// Returns the displayable information set in the SteamWork's Database
native final function GetAchievementDescription(string SteamName, out string DisplayName, out string Description);

native simulated final function bool    DoPotato();

// Returns an integer representation of Owned Weapon DLC Packs
native final function int GetOwnedWeaponDLC();

// Determines whether or not this player owns a particular Weapon DLC AppID
simulated function bool PlayerOwnsWeaponDLC(int AppID);
native final function bool OwnsWeaponDLC(int AppID, SteamStatInt OwnedWeaponDLCStat);

// Opens the Steam Store page for the specified AppID
native final function PurchaseWeaponDLC(int AppID);

// Fetches the name of the specified Weapons DLC Pack
function string GetWeaponDLCPackName(int AppID);

// Opens the Steam Overlay directly to the Game's Steam Workshop page
native final function ShowWorkshopContent();

// Fetches a user ID for the owning PC
native final function string GetSteamUserID();

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

replication
{
    reliable if ( Role == ROLE_Authority )
        bUsedCheats;
}

// Called via Client to Server function in PlayerController to start the FlushStatsToClient timing
function ServerSteamStatsAndAchievementsInitialized()
{
    if ( bDebugStats )
        log("STEAMSTATS: ServerSteamStatsAndAchievementsInitialized called");

    bInitialized = true;
    SetTimer(FlushStatsToClientDelay, false);
}

event PostBeginPlay()
{
    PlayerDied();
}

// Overridden to Grab the Stats and Achievements from Steam on the Client
simulated event PostNetBeginPlay()
{
    if ( Level.NetMode == NM_Client )
    {
        if ( bDebugStats )
            log("STEAMSTATS: PostNetBeginPlay grabbing Stats - StatsObject="$self);

        GetStatsAndAchievements();

        PCOwner = Level.GetLocalPlayerController();
    }
}

// Overridden in subclasses to send the Stats/Achievements that have changed to Steam
//simulated event PostNetReceive();

// Called at set interval to push all Stats to Client, then called again to reset
// NETWORK: Server only
event Timer()
{
    // We use bFlushStatsToClient to control when things are sent
    if ( !bFlushStatsToClient )
    {
        FlushStatsToClient();
    }

    // Soon after FlushStatsToClientw is called above, Timer gets called again to clear bFlushStatsToClient
    else
    {
        bFlushStatsToClient = false;
        SetTimer(FlushStatsToClientDelay, false);
    }
}

// Called on Server(via Timer) to push all Stats to Client
// NETWORK: Server only
function FlushStatsToClient()
{
    // if it's a local player, just send stuff off to Steam from here
    if ( Level.NetMode == NM_Standalone || (Level.NetMode == NM_ListenServer && PCOwner == Level.GetLocalPlayerController()) )
    {
        PostNetReceive();
        SetTimer(FlushStatsToClientDelay, false);
    }
    else
    {
        if ( bDebugStats )
            log("STEAMSTATS: Flushing Stats to Client");

        // Force Stats to be sent to Client immediately
        NetUpdateTime = Level.TimeSeconds - 1.0;
        bFlushStatsToClient = true;
        SetNetDirty();

        // Clear bFlushStatsToClient once completed
        SetTimer(0.1, false);
    }
}

// Event Callback for GetStatsAndAchievements call(Call PCOwner.ServerSteamStatsAndAchievementsInitialized when done)
// NETWORK: Client only
simulated event OnStatsAndAchievementsReady()
{
    if ( PCOwner != none && PCOwner.PlayerReplicationInfo != none )
    {
        PCOwner.PlayerReplicationInfo.SteamStatsAndAchievements = self;
    }

    bInitialized = true;
    PCOwner.ServerSteamStatsAndAchievementsInitialized();
    OnDataInitialized();
}

// Called on Server to initialize Stats from Client replication, because Servers can't access Steam Stats directly
function InitializeSteamStatInt(int Index, int Value);

// Called on Server to initialize Stats from Client replication, because Servers can't access Steam Stats directly
function InitializeSteamStatFloat(int Index, float Value);

// Sets the specified Steam Achievement as completed; also, flushes all Stats and Achievements to the client
function SetSteamAchievementCompleted(int Index)
{
    if ( bDebugStats )
        log("STEAMSTATS: SetSteamAchievementCompleted called - Name="$SteamNameAchievement[Index] @ "Player="$PCOwner.PlayerReplicationInfo.PlayerName);

    FlushStatsToClient();
    SetLocalAchievementCompleted(Index);
    SetAchievementCompleted(SteamNameAchievement[Index]);
}

// Called from multiple locations on Client and Server to set Achievement booleans for later use
simulated event SetLocalAchievementCompleted(int Index);

// Called when the owner of this Stats Actor dies(used in subclasses to reset "in one life" stats)
function PlayerDied();

native function SteamAPICall(string callString);

function CheckEvents( Name EventName );

defaultproperties
{
     FlushStatsToClientDelay=10.000000
     bHidden=True
     bOnlyRelevantToOwner=True
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=5.000000
     bNetNotify=True
}
