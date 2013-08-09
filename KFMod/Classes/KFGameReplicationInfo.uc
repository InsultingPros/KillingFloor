class KFGameReplicationInfo extends InvasionGameReplicationInfo;

var int MaxMonsters;
var bool MaxMonstersOn;
var string ClassListHeaders;
var int ClassListClassCount;
var string ClassListClassNames;
var int numMonsters ;
const CLASSLIST_CLASSES=3;
var int NumPlayersClassSelected;
var int TimeToNextWave;
var bool bWaveInProgress;

var string LastBotName[6];
var int bBotPlayerReady[6];
var int PendingBots;
var string TempBotName; // Changes with the Selections in the ComboBox (but before we click addbot) Used to satisfy the SetGRI stuffs in PlayerController
var bool bNoBots;

var int LobbyTimeout;
var float GameDiff;  // Since Level.Game  doesnt seem to replicate...let's store the difficulty value here
var bool bEnemyHealthBars;
var byte EndGameType;
var bool bHUDShowCash;

var ShopVolume CurrentShop;

var bool bObjectiveAchievementFailed; // used in objective mode

replication
{
    reliable if(Role == ROLE_Authority)
        MaxMonstersOn, bWaveInProgress, TimeToNextWave, LobbyTimeout,
        MaxMonsters, PendingBots, LastBotName, TempBotName, EndGameType, CurrentShop,
        bObjectiveAchievementFailed;

    reliable if ( bNetInitial && (Role == ROLE_Authority) )
        GameDiff, bEnemyHealthBars, bNoBots, bHUDShowCash;
}

simulated function PostNetBeginPlay()
{
    local PlayerReplicationInfo PRI;

    Level.GRI = self;

    if ( VoiceReplicationInfo == None )
        foreach DynamicActors(class'VoiceChatReplicationInfo', VoiceReplicationInfo)
            break;

    SetTimer(1.0, true);

    foreach DynamicActors(class'PlayerReplicationInfo',PRI)
        AddPRI(PRI);

    if ( Level.NetMode == NM_Client )
        TeamSymbolNotify();
}

simulated function Timer()
{
    if ( Level.NetMode == NM_Client && bMatchHasBegun )
    {
        ElapsedTime++;
        if ( RemainingMinute != 0 )
        {
            RemainingTime = RemainingMinute;
            RemainingMinute = 0;
        }
        if ( (RemainingTime > 0) && !bStopCountDown )
            RemainingTime--;
        if ( !bTeamSymbolsUpdated )
            TeamSymbolNotify();
        SetTimer(Level.TimeDilation, true);
    }
}

simulated function AddKFPRI(PlayerReplicationInfo PRI)
{
    local byte NewVoiceID;
    local int i;
    local bool bIgnoreMe;

    if ( Level.NetMode == NM_ListenServer || Level.NetMode == NM_DedicatedServer )
    {
        for (i = 0; i < PRIArray.Length; i++)
        {
            if ( PRIArray[i]==None || PRIArray[i]==PRI )
            {
                PRIArray[i] = PRI;
                bIgnoreMe = True;
            }
            if ( PRIArray[i].VoiceID == NewVoiceID )
            {
                i = -1;
                NewVoiceID++;
                continue;
            }
        }
        if ( NewVoiceID >= 32 )
            NewVoiceID = 0;
        PRI.VoiceID = NewVoiceID;
    }
    if(!bIgnoreMe)
        PRIArray[PRIArray.Length] = PRI;
}

defaultproperties
{
     LobbyTimeout=-1
     bHUDShowCash=True
}
