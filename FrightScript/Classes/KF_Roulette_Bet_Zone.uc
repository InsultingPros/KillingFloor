/*
	--------------------------------------------------------------
	KF_Roulette_Bet_Zone
	--------------------------------------------------------------

	Represents a distinct betting area on the Roulette table. Cash
	thrown into this volume before the wheel spins will be considered
	a valid bet.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_Roulette_Bet_Zone extends StaticMeshActor;

#exec OBJ LOAD FILE=Pier_SM.usx
#exec OBJ LOAD FILE=Pier_T.utx

/* A struct representing a player's bet on this number. */
struct SPlayerBetInfo
{
	var	PlayerController               BettingPlayer;
	var CashPickup                     BetPickup;   // the cash pickup representing our bet and winnings.
};


enum EBetType
{
    BET_Straight,
    BET_Even,
    BET_Odd,
    BET_Red,
    BET_Black,
    BET_1st,
    BET_2nd,
    BET_3rd,
    BET_Low,
    BET_High,
};

var () EBetType                                             ZoneType;

var () int                                                  ZoneNumber;

/* Reference to the table this zone belongs to */
var KF_Roulette_Wheel                                       OwningTable;

/* Array of all the bets in this zone in the current spin - Cleared after each spin.*/
var     array<SPlayerBetInfo>                               CurrentBets;

/* The amount this zone pays out when it hits. Set by OwningTable */
var     float                                               PayOutAmount;

var     StaticMesh                                          ChipPileSmall,ChipPileMedium,ChipPileHuge;


function OnActorLanded(Actor FallingActor)
{
    local CashPickup Dosh;
    Dosh = CashPickup(FallingActor);
    if(Dosh != none)
    {
        if(OwningTable != none &&
        OwningTable.AcceptNewBets())
        {
            AddBet(Dosh);
        }
        else
        {
            OwningTable.OnBetRejected();
        }
    }
}

/* We didn't win anything on this tile .. remove the cash */
function ClearOldBets()
{
    local int i,NumBets;

    Numbets = CurrentBets.length ;

    /* Remove all the old chips   */
    for(i = 0 ; i < NumBets ; i ++)
    {
        if(CurrentBets[i].BetPickup != none)
        {
            CurrentBets[i].BetPickup.Destroy();
        }
    }

    CurrentBets.length = 0 ;
}

function OnWheelSpin()
{
    local int i;

    for(i = 0 ; i < Currentbets.Length ; i ++)
    {
        if(CurrentBets[i].BetPickup != none)
        {
            SetChipState(Currentbets[i].BetPickup,false);
        }
    }
}

/* Allows or disables pickup of chips from the table */
function SetChipState( CashPickup ChipStack , bool AllowPickup)
{
    ChipStack.SetCollision(AllowPickup);
    OwningTable.ClientSetChipMaterial(ChipStack,AllowPickup);
}

function AddBet(CashPickup Dosh)
{
    local int ExistingIndex;
    local bool bPlayerAlreadyBet;

    if(Dosh == none ||
    Dosh.DroppedBy == none ||
    Dosh.DroppedBy.PlayerReplicationInfo == none)
    {
        return;
    }

    bPlayerAlreadyBet = FindExistingPlayer(Dosh,ExistingIndex);

    /* This guy already has a bet here, just update the amount he put down */
    if(bPlayerAlreadyBet)
    {
        CurrentBets[ExistingIndex].BetPickup.CashAmount += Dosh.CashAmount;
        /* also update the mesh on the table */

        CurrentBets[ExistingIndex].BetPickup.SetStaticMesh(GetChipMeshFor(CurrentBets[ExistingIndex].BetPickup.CashAmount));
    }
    else
    {
        CurrentBets.length = CurrentBets.length + 1;
        CurrentBets[CurrentBets.length - 1].BettingPlayer = PlayerController(Dosh.DroppedBy);
        Currentbets[CurrentBets.length - 1].BetPickup = Dosh;

        OwningTable.AddPlayer(CurrentBets[CurrentBets.length - 1].BettingPlayer);
    }


    log("Adding : $"$Dosh.CashAmount$" Bet to :"@GetZoneName());
    log("Current total on :"@GetZoneName()@" is : $"$CurrentBets[0].BetPickup.CashAmount);

    /* turn it into a stack of chips when it hits the table */

    if(!bPlayerAlreadyBet)
    {
        Dosh.bPreventFadeOut = true;
        Dosh.LifeSpan = 0;
        Dosh.SetStaticMesh(GetChipMeshFor(Dosh.CashAmount));

        SetChipState(Dosh,false);
        Dosh.bOnlyOwnerCanPickup = true;
        Dosh.CashAmount = 0;
    }
    else
    {
        Dosh.Destroy();
    }


    OwningTable.OnAddBet();
}

/* Returns the total amount of bets placed on this part of the table */
function int GetBetTotal()
{
    local int idx;
    local int BetTotal;

    for(idx = 0 ; idx < CurrentBets.length ; idx ++)
    {
        if(CurrentBets[idx].BetPickup != none &&
        !CurrentBets[idx].BetPickup.bHidden)
        {
            BetTotal += CurrentBets[idx].BetPickup.CashAmount;
        }
    }

    return BetTotal;
}

/* Determine which mesh to use for this cash pickup.  Large values means larger chip piles */
function StaticMesh GetChipMeshFor( int CashAmount)
{
    if(CashAmount <= 50)
    {
        return ChipPileSmall ;
    }
    else if(CashAmount <= 250)
    {
        return ChipPileMedium;
    }
    else
    {
        return ChipPileHuge;
    }
}

/* Convert the Enum for this Zone's Type into a human readable name */
function string GetZoneName()
{
    local String ZoneString;

    switch(ZoneType)
    {
        case BET_Straight   : ZoneString = string(ZoneNumber);  break;
        case BET_Even       : ZoneString = "Evens";             break;
        case BET_Odd        : ZoneString = "Odds";              break;
        case BET_Black      : ZoneString = "Black";             break;
        case BET_Red        : ZoneString = "Red" ;              break;
        case BET_1st        : ZoneString = "First12";           break;
        case BET_2nd        : ZoneString = "Second12";          break;
        case Bet_3rd        : ZoneString = "Third12";           break;
        case Bet_Low        : ZoneString = "Low";               break;
        case Bet_High       : ZoneString = "High";              break;
    }

    return ZoneString;
}

function PayOut()
{
    local int i;
    local int PayOutSum;

    for(i = 0 ; i < CurrentBets.length ; i ++)
    {
        if(CurrentBets[i].BettingPlayer != none )
        {
            PayOutSum = (CurrentBets[i].BetPickup.CashAmount + (CurrentBets[i].BetPickup.CashAmount * PayOutAmount));

            log("*************************");
            log(GetZoneName()@" Paid out $"$PayOutSum@" to - "@CurrentBets[i].BettingPlayer.PlayerReplicationInfo.PlayerName);

            CurrentBets[i].BetPickup.CashAmount = PayOutSum;
            CurrentBets[i].BetPickup.SetStaticMesh(GetChipMeshFor(PayOutSum));
            SetChipState(CurrentBets[i].BetPickup,true);
        }
    }
}

/* Has this player already placed a bet in this zone or not ? */
function bool FindExistingPlayer(CashPickup Dosh, optional out int ExistingIndex)
{
    local int i;

    for(i = 0 ; i < CurrentBets.length ; i ++)
    {
        if(CurrentBets[i].BettingPlayer == Dosh.DroppedBy &&
        CurrentBets[i].BetPickup != none &&
        !CurrentBets[i].BetPickup.bHidden )
        {
            ExistingIndex = i;
            return true;
        }
    }

    return false;
}

defaultproperties
{
     ChipPileSmall=StaticMesh'Pier_SM.Env_Pier_Chips_Small'
     ChipPileMedium=StaticMesh'Pier_SM.Env_Pier_Chips_Medium'
     ChipPileHuge=StaticMesh'Pier_SM.Env_Pier_Chips_Large'
     StaticMesh=StaticMesh'Pier_SM.1'
}
