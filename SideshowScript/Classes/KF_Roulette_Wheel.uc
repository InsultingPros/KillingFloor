/*
	--------------------------------------------------------------
	KF_Roulette_Wheel
	--------------------------------------------------------------

	Interactive prop for the 2013 Summer Sideshow map.   Players
	place bets by throwing dosh onto the table.  The game begins
	when there are enough bets on the table.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_Roulette_Wheel extends Actor
placeable
dependson(KF_Roulette_Bet_Zone);


const NUMPOCKETS = 37;
const POCKETSPACING = 1771.24;      // (65536 /  NumPockets)
const NUMBETSNDS = 3;

var     int                             FinalPocket;

/* The Tags of the Roulette zone volumes should all match this name */
var()   name                            TableName;


/* A struct representing a player who has bets on this table */
struct SPlayerTableInfo
{
	var	PlayerController               BettingPlayer;
	var	int                            InitialBetSum;      // amount this player had on the table as of the first bet.
	var int                            CurrentBetSum;      // amount this player has on the table right this minute.
};

/* Array of all players who have bets placed on this table */
var array<SPlayerTableInfo>             AllPlayers;


/* A struct representing a pocket on the roulette wheel. */
struct SPocketInfo
{
    var byte                            PocketClr;          // 0 = Green, 1=Black , 2 = Red
    var int                             PocketPosition;     // Rotation Roll value for this pocket.  (RUUs)
};

/* An array that stores all the colours associated with the "Pockets on the roulette wheel. */
var     SPocketInfo                     PocketInfo[NUMPOCKETS];

/* Minimum bet that must be on the table to play */
var()   int                             MinBet;

var()   KF_Roulette_Ball                Ball;

var     float                           MaxBallSpin,MaxWheelSpin;

var     float                           LastBallSpeedDecrement,BallSpeedDecrementInterval;

var     array<int>                      WinningNumbers;

/* Array of all the areas on this table that players can bet in */
var     array<KF_Roulette_Bet_Zone>     BetZones;

var     float                           SpinDuration;

/* Percent of SpinDuration that must pass before all betting is closed */
var     float                           BetsClosedTimePct;

var     float                           LastSpinTime;

/* The Roulette wheel is turning and the ball is in motion */
var     bool                            bSpinning;

/* Amount of time after a bet is placed before the wheel starts spinning */
var     float                           SpinCountDown;

var     float                           LastSpinCountDownTime;

/* There are sufficient bets on the table to spin, and the countdown to spin is in progress */
var     bool                            bCountingDownToSpin;

var     bool                            bNotifiedBettingClosed;

/* At least one player left his winnings from a previous spin on the table*/
var     bool                            bLettingItRide;

/* If this table was placed inside a trader volume, store a reference to it here */
var     ShopVolume                      TraderShop;

/*  Sounds ===============================================================*/


/* Sound the roulette wheel makes when its spinning around */
var Sound                               WheelSpinSnd;

var Sound                               PlaceBetSnds[NUMBETSNDS];

var string                              PlaceBetSndsRef[NUMBETSNDS];

var string                              WheelSpinSndRef;

/* This Table is active and open for business */
var bool                                bActive;


replication
{
    reliable if(Role == Role_Authority)
        FinalPocket;
}

function PreBeginPlay()
{
    PreLoadSounds();
}

function PostBeginPlay()
{
    FindBetZones();

    foreach TouchingActors(class 'ShopVolume',  TraderShop)
    {
        log(self@" is located in shop : "@TraderShop);
        break;
    }

    if(TraderShop != none)
    {
        SetActive(TraderShop.bCurrentlyOpen);
    }
}

function PreLoadSounds()
{
    local int i;

	if ( default.WheelSpinSndRef != "" )
	{
		WheelSpinSnd = sound(DynamicLoadObject(default.WheelSpinSndRef, class'Sound', true));
	}

    for(i = 0 ; i < NUMBETSNDS; i ++)
    {
        if ( default.PlaceBetSndsRef[i] != "" )
        {
            PlaceBetSnds[i] = sound(DynamicLoadObject(default.PlaceBetSndsRef[i], class'Sound', true));
        }
    }
}


/* Cache all the 'pieces' of this table */
function FindBetZones()
{
    local KF_Roulette_Bet_Zone Zone;

    foreach AllActors(class 'KF_Roulette_Bet_Zone', Zone, TableName)
    {
        BetZones[BetZones.length] = Zone;
        Zone.OwningTable = self;
        Zone.PayOutAmount = GetPayoutFor(Zone.ZoneType);
    }
}

/* Returns true if this table is open for betting */
function bool AcceptNewBets()
{
    return bActive && (!bSpinning || Level.TimeSeconds - LastSpinTime < (SpinDuration*BetsClosedTimePct)) ;
}

/* Player placed a bet on this table */
function OnAddBet()
{
    StartCountDown();
    PlaySound(PlaceBetSnds[Rand(NUMBETSNDS)]);
}

/* bet was rejected */
function OnBetRejected()
{
    NotifyBettingClosed();
}

/* Check if there are enough bets on the table to start the countdown to the spin */
function bool StartCountDown(optional bool SuppressNotifications)
{
    if(!bCountingDownToSpin && !bSpinning && CheckMinBet(SuppressNotifications))
    {
        bCountingDownToSpin = true;
        LastSpinCountDownTime = Level.TimeSeconds;
        SetTimer(SpinCountDown,false);

        return true;
    }

    return false;
}

function AbortCountDown()
{
    bLettingItRide = false;
    bCountingDownToSpin = false;
    SetTimer(0.f,false);
}

function Timer()
{
    bCountingDownToSpin = false;
    SpinWheel();
}

/* A player placed a bet somewhere on this table. Add him to the game */
function AddPlayer(PlayerController NewPlayer)
{
    if(!FindPlayer(NewPlayer))
    {
        AllPlayers.length = AllPlayers.length + 1;
        AllPlayers[AllPlayers.length - 1].BettingPlayer = NewPlayer;
    }

    StartCountDown();
}

/* A Player was removed from the game - (busted out or took his winnings off the table) */
function RemovePlayer(PlayerController PlayerToRemove)
{
    local int PlayerIdx;

    if(FindPlayer(PlayerToRemove,PlayerIdx))
    {
        AllPlayers.Remove(PlayerIdx,1);
    }
}

function  bool FindPlayer(PlayerController PlayerToFind, optional out int PlayerIdx)
{
    local int i;

    for(i = 0 ; i < AllPlayers.length ; i ++)
    {
        if(AllPlayers[i].BettingPlayer == PlayerToFind)
        {
            PlayerIdx = i;
            return true;
        }
    }

    return false;
}


/* Begins the wheel animation */
function SpinWheel()
{
    local int i;

    if(Level.TimeSeconds - LastSpinTime > SpinDuration)
    {
        if(WheelSpinSnd != none)
        {
            PlaySound(WheelSpinSnd);
        }

        LastSpinTime = Level.TimeSeconds;
        log("******* SPINNING THE WHEEL ********** ");
        FinalPocket = Rand(arrayCount(PocketInfo));
        log(" The ball landed on : "@FinalPocket@GetPocketClr(FinalPocket));

        bFixedRotationDir = true;
        bRotateToDesired = false;
        RotationRate.Yaw = -MaxWheelSpin ;

        Ball.StartRolling();

        bSpinning = true;

        for(i = 0 ; i < BetZones.length ; i ++)
        {
            BetZones[i].OnWheelSpin();
        }

        if(bLettingItRide)
        {
            NotifyLetItRide();
        }

        UpdatePlayerBetTotals();
    }
}

simulated function int GetCurrentPocket()
{
    return GetPocketAtPosition(RUUToPosition(Ball.Rotation.Yaw - Rotation.Yaw));
}

/* If this roulette wheel is located inside a trader shop, check to make sure it's still open.  If it is not, abort
the game and give players their winnings automatically */

function CheckShopState()
{
    if(TraderShop != none)
    {
        if(bActive != TraderShop.bCurrentlyOpen)
        {
            SetActive(TraderShop.bCurrentlyOpen);
        }
    }
}

/* Toggle Table Active or not*/
function SetActive(bool On)
{
    if(Ball != none)
    {
        Ball.bHidden = !On;
    }

    bHidden = !On;
/*  bActive = On;

    if(!bActive)
    {
        if(bCountingDownToSpin)
        {
            AbortCountDown();
        }

        OnSpinComplete();
    }
*/
}

function Tick(Float DeltaTime)
{
    local int i;

    CheckShopState();

    /* Betting is closed */
    if(!AcceptNewBets() && !bNotifiedBettingClosed)
    {
        bNotifiedBettingClosed = true;
        NotifyBettingClosed();
    }


    if(bCountingDownToSpin)
    {
        /* Someone picked up their winnings */
        if(!CheckMinBet())
        {
            AbortCountDown();
        }

        for(i = 0 ; i < AllPlayers.Length ; i ++)
        {
            if(AllPlayers[i].BettingPlayer != none)
            {
                AllPlayers[i].BettingPlayer.ReceiveLocalizedMessage(class 'Msg_RouletteCountDown',int(SpinCountDown - (Level.TimeSeconds - LastSpinCountDownTime)));
            }
        }
    }

    if(bSpinning)
    {
/*      if(Level.TimeSeconds - LastBallSpeedDecrement > BallSpeedDecrementInterval)
        {
            LastBallSpeedDecrement = Level.TimeSeconds;
            Ball.RotationRate.Yaw = FMax(Ball.RotationRate.Yaw - ((MaxBallSpin * BallSpeedDecrementInterval)/SpinDuration),MaxBallSpin*0.01);
        }
*/


        if(Level.TimeSeconds - LastSpinTime >= SpinDuration )
        {
            OnSpinComplete();
        }
    }
}

function int GetPocketAtPosition(int InPos)
{
    local int i;

    for(i = 0 ; i < NUMPOCKETS ; i ++)
    {
        if(PocketInfo[i].PocketPosition == InPos)
        {
            return i ;
        }
    }

    return -1;
}

/* Converts the wheel position integer to a Unreal Unit Rotation value */

function float PositionToRUU(int Position)
{
    return (Position * PocketSpacing) & 65536;
}

/* Converts a Rotation value to a wheel position integer */
function int RUUToPosition(float RotVal)
{
    return FClamp(Round(RotVal / PocketSpacing),0,NumPockets-1) ;
}

/* Called when the ball has come to a rest on the desired number. */
function OnSpinComplete()
{
    RotationRate.Yaw = 0.f;

    Ball.DesiredRotation.Yaw = PositionToRUU(FinalPocket);
    Ball.StopRolling();

    bFixedRotationDir = false;
    bRotateToDesired = true;
    DesiredRotation.Yaw = 0.f;

    bSpinning = false;
    bNotifiedBettingClosed = false;

    WinningNumbers[WinningNumbers.length] = FinalPocket;
    ProcessBets();
}


static function string GetPocketClr(int Pocket)
{
    local int ClrIdx;
    local string ClrString;

    ClrIdx = default.PocketInfo[Pocket].PocketClr;
    switch(ClrIdx)
    {
        case 0 : ClrString = "Green" ; break;
        case 1 : ClrString = "Black" ; break;
        case 2 : ClrString = "Red" ; break;
    }

    return ClrString;
}

/* Returns true if there are enough bets on the table to spin the wheel */
function bool CheckMinBet(optional bool SuppressNotification)
{
    local int i;
    local int BetTotal;
    local bool EnoughCash;

    for(i = 0 ; i < BetZones.length ; i ++)
    {
        BetTotal += BetZones[i].GetBetTotal();
    }

    EnoughCash = BetTotal >= MinBet;

    if(!EnoughCash && !SuppressNotification)
    {
        NotifyNeedMinBet();
    }

    return EnoughCash;
}

/* Returns the payout ratio for a specific type of Bet */
function float GetPayoutFor(KF_Roulette_Bet_Zone.EBetType Bet)
{
    switch(Bet)
    {
        case BET_Straight :     return 35.f ;  break; // 35 to 1
        Default :               return 1.f;    break; // 1 to 1
    }
}

/* Calculates the winnings for each BetZone and clears bets on Zones which didn't hit */
function ProcessBets()
{
    local int i;

    if(BetZones.length == 0)
    {
        log("WARNING - No BetZones associated with this table. ");
    }

    for(i = 0 ; i < BetZones.length ; i ++)
    {
        if(BetZones[i].ZoneType == BET_Red && IsRed(FinalPocket))            //  Red bet
        {
            log("Red bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if(BetZones[i].ZoneType == BET_Black && IsBlack(FinalPocket))   //  Black bet
        {
            log("Black bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if (BetZones[i].ZoneType == BET_Even && IsEven(FinalPocket))
        {
            log("Even number bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if (BetZones[i].ZoneType == BET_Odd && !IsEven(FinalPocket))
        {
            log("Odd number bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if(BetZones[i].ZoneType == BET_1st && IsFirsts(FinalPocket)) // First 12
        {
            log("Firsts bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if(BetZones[i].ZoneType == BET_2nd && IsSeconds(FinalPocket)) // Second 12
        {
            log("Seconds bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if(BetZones[i].ZoneType == BET_3rd && IsThirds(FinalPocket)) // Third 12
        {
            log("Thirds bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if(BetZones[i].ZoneType == BET_Low && IsLow(FinalPocket)) // Low Bet
        {
            log("Low bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if(BetZones[i].ZoneType == BET_High && IsHigh(FinalPocket)) // High Bet
        {
            log("High bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else if(BetZones[i].ZoneType == BET_Straight &&
        FinalPocket == BetZones[i].ZoneNumber)                           // Straight number
        {
            log("Straight Bet Wins on "$FinalPocket);
            BetZones[i].PayOut();
        }
        else
        {
            BetZones[i].ClearOldBets();
        }
    }

    UpdatePlayerBetTotals();
    NotifyWinnings();
    RemoveBustedPlayers();

    /* Let's see if there's enough cash on the table to start another spin ... */
    if(StartCountDown(true))
    {
        bLettingItRide = true;
    }
}

/* Updates the current bet totals for all players on the table */
function UpdatePlayerBetTotals()
{
    local int i, NumPlayers;

    NumPlayers = AllPlayers.length;

    for(i = 0 ; i < NumPlayers ; i ++)
    {
        AllPlayers[i].CurrentbetSum = GetCurrentBetTotalFor(AllPlayers[i].BettingPlayer);
    }
}


/* Returns the total amount of dosh a player has bet on this table at the moment */
function int GetCurrentBetTotalFor( PlayerController Player)
{
    local int i;
    local int idx;
    local int TotalBet;

    for(i = 0; i < BetZones.Length ; i ++)
    {
        for(idx = 0 ; idx < BetZones[i].CurrentBets.length ;idx ++)
        {
            if(BetZones[i].CurrentBets[idx].BettingPlayer == Player)
            {
                TotalBet += BetZones[i].CurrentBets[idx].BetPickup.CashAmount ;
            }
        }
    }

    return TotalBet;
}

/* Remove any players who have no more bets on the table */
function RemoveBustedPlayers()
{
    local int i, NumPlayers;

    NumPlayers = AllPlayers.length;

    for(i = 0 ; i < NumPlayers ; i ++)
    {
        if(AllPlayers[i].CurrentBetSum <= 0)     // this guys went broke, he's not in the game anymore.
        {
            AllPlayers.Remove(i,1);
        }
    }
}


/* == Player Feedback & Localized Messaging ======================================================
==================================================================================================*/

/* Let players know how the last spin went.  Send them a local message with their net winnings */
function NotifyWinnings()
{
    local int i;
    local int NetWinnings;

    for(i = 0 ; i< AllPlayers.length ; i ++)
    {
        if(AllPlayers[i].BettingPlayer != none)
        {
            NetWinnings = AllPlayers[i].CurrentBetSum - AllPlayers[i].InitialBetSum ;

            /* let players know which number it landed on */
            AllPlayers[i].BettingPlayer.ReceiveLocalizedMessage(class 'Msg_RouletteSpin',FinalPocket);

            /* let players know how much they have won so far. */
            AllPlayers[i].BettingPlayer.ReceiveLocalizedMessage(class 'Msg_RouletteWinnings', NetWinnings);
        }
    }
}

/* Let players know that they are letting it ride. */
function NotifyLetitRide()
{
    local int i;

    for(i = 0 ; i< AllPlayers.length ; i ++)
    {
        if(AllPlayers[i].BettingPlayer != none)
        {
            AllPlayers[i].BettingPlayer.ReceiveLocalizedMessage(class 'Msg_RouletteGeneric', 1);
        }
    }
}

/* Let players know that they need to place more cash on the table to play*/
function NotifyNeedMinBet()
{
    local int i;

    for(i = 0 ; i< AllPlayers.length ; i ++)
    {
        if(AllPlayers[i].BettingPlayer != none)
        {
            AllPlayers[i].BettingPlayer.ReceiveLocalizedMessage(class 'Msg_RouletteGeneric', 3);
        }
    }
}

/* Let players know that they cannot place anymore bets right now */
function NotifyBettingClosed()
{
    local int i;

    for(i = 0 ; i< AllPlayers.length ; i ++)
    {
        if(AllPlayers[i].BettingPlayer != none)
        {
            AllPlayers[i].BettingPlayer.ReceiveLocalizedMessage(class 'Msg_RouletteGeneric', 2);
        }
    }
}

/*============================================================================================
=============================================================================================*/


/* Changes the UV2 Material on the Chips so they look glowy to the player who won them
and not glowy to everyone else */

function ClientSetChipMaterial(CashPickup Chips, bool Glow)
{
    local int i;
    local Material NewMat;

    for(i = 0 ; i < AllPlayers.length ; i ++)
    {
        NewMat = none ;

        if(KFPlayerController_Story(AllPlayers[i].BettingPlayer) != none )
        {
            if(Glow && AllPlayers[i].Bettingplayer == Chips.DroppedBy)
            {
                NewMat = Chips.default.UV2Texture ;
            }

            KFPlayerController_Story(AllPlayers[i].BettingPlayer).ClientSetUV2Tex(Chips,NewMat);
        }
    }
}

function bool IsBlack(int Num)
{
    return PocketInfo[Num].PocketClr == 1;
}

function bool IsRed(int Num)
{
    return PocketInfo[Num].PocketClr == 2;
}

function bool IsEven(int Num)
{
    return Num % 2 == 0;
}

function bool IsFirsts(int Num)
{
    return Num <= 12 && Num > 0;
}

function bool IsSeconds(int Num)
{
    return Num > 12 && Num <= 24 ;
}

function bool IsThirds( int Num)
{
    return Num > 24 && Num <= 36;
}

function bool IsLow (int Num)
{
    return Num > 0 && Num <= 18;
}

function bool IsHigh( int Num)
{
    return Num >= 19 && Num <= 36 ;
}

defaultproperties
{
     PocketInfo(0)=(PocketPosition=32)
     PocketInfo(1)=(PocketClr=2,PocketPosition=18)
     PocketInfo(2)=(PocketClr=1,PocketPosition=1)
     PocketInfo(3)=(PocketClr=2,PocketPosition=30)
     PocketInfo(4)=(PocketClr=2,PocketPosition=36)
     PocketInfo(5)=(PocketClr=2,PocketPosition=14)
     PocketInfo(6)=(PocketClr=1,PocketPosition=5)
     PocketInfo(7)=(PocketClr=2,PocketPosition=26)
     PocketInfo(8)=(PocketClr=1,PocketPosition=11)
     PocketInfo(9)=(PocketClr=2,PocketPosition=22)
     PocketInfo(10)=(PocketClr=1,PocketPosition=13)
     PocketInfo(11)=(PocketClr=1,PocketPosition=9)
     PocketInfo(12)=(PocketClr=2,PocketPosition=28)
     PocketInfo(13)=(PocketClr=1,PocketPosition=7)
     PocketInfo(14)=(PocketClr=2,PocketPosition=20)
     PocketInfo(15)=(PocketClr=1,PocketPosition=34)
     PocketInfo(17)=(PocketClr=1,PocketPosition=3)
     PocketInfo(18)=(PocketClr=2,PocketPosition=24)
     PocketInfo(19)=(PocketClr=2,PocketPosition=35)
     PocketInfo(20)=(PocketClr=1,PocketPosition=19)
     PocketInfo(21)=(PocketClr=2)
     PocketInfo(22)=(PocketClr=1,PocketPosition=23)
     PocketInfo(23)=(PocketClr=2,PocketPosition=12)
     PocketInfo(24)=(PocketClr=1,PocketPosition=15)
     PocketInfo(25)=(PocketClr=2,PocketPosition=2)
     PocketInfo(26)=(PocketClr=1,PocketPosition=31)
     PocketInfo(27)=(PocketClr=2,PocketPosition=6)
     PocketInfo(28)=(PocketClr=1,PocketPosition=27)
     PocketInfo(29)=(PocketClr=1,PocketPosition=25)
     PocketInfo(30)=(PocketClr=2,PocketPosition=10)
     PocketInfo(31)=(PocketClr=1,PocketPosition=21)
     PocketInfo(32)=(PocketClr=2,PocketPosition=33)
     PocketInfo(33)=(PocketClr=1,PocketPosition=17)
     PocketInfo(34)=(PocketClr=2,PocketPosition=4)
     PocketInfo(35)=(PocketClr=1,PocketPosition=29)
     PocketInfo(36)=(PocketClr=2,PocketPosition=8)
     MinBet=100
     MaxBallSpin=190000.000000
     MaxWheelSpin=10000.000000
     BallSpeedDecrementInterval=0.100000
     SpinDuration=5.000000
     BetsClosedTimePct=0.500000
     SpinCountDown=5.000000
     PlaceBetSndsRef(0)="Steamland_SND.Roulette_StackOff_1"
     PlaceBetSndsRef(1)="Steamland_SND.Roulette_StackOff_2"
     PlaceBetSndsRef(2)="Steamland_SND.Roulette_StackOff_3"
     WheelSpinSndRef="Steamland_SND.Roulette_WheelSpin"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Pier_SM.Env_Pier_Roulette_Table_Wheel'
     bStatic=True
     Physics=PHYS_Rotating
     RemoteRole=ROLE_None
     bCollideActors=True
     bFixedRotationDir=True
}
