/*
	--------------------------------------------------------------
	KF_Slot_Machine
	--------------------------------------------------------------

	Interactive prop for the 2013 Summer Sideshow map.   Can be used
	by players to randomly dole out prizes.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

#exec OBJ LOAD FILE=Pier_anim.ukx

class KF_Slot_Machine extends Actor
placeable;

const       NUMREELS            =  3;
const       NUMSYMBOLS          =  6;
const       NUMAMBIENTSNDS      =  3;

var()    edfindable   KF_Slot_Reel        Reels[NUMREELS] ;

var         float               DesiredRolls[NUMREELS];

var         int                 NumSpinning;

var()       float               SpinDuration;

var         float               LastSpinTime;

var         float               LastReelStopTime;

var         string              Snd_ReelStoppedRef,Snd_ReelSpinningRef,Snd_MonsterPrizeRef,Snd_CashPrizeRef;

var         Sound               Snd_ReelStopped,Snd_ReelSpinning,Snd_MonsterPrize,Snd_CashPrize;

var         string              Snd_AmbientActiveRef[NUMAMBIENTSNDS];

var         Sound               Snd_AmbientActive[NUMAMBIENTSNDS];

var         Pawn                CurrentPlayer;

var         int                 RemainingPayOut;

var()       int                 MaxBet;

var()       float               CashPayOutInterval;

var         int                 RemainingBonusSpins;

/* ==== Animation Stuff =================================*/

/* Animation the slot machine plays when it is used */
var         name                SlotPullAnim;

/* Animation to play while the slot reels are spinning */
var         name                SlotSpinAnim;

/* Animation to play when pukey is vomitting on ya */
var         name                PukeAnim;

/*  This is the last animation which played on the client */
var         name                LastClientAnim;

var         name                LoseAnim;

var         name                WinAnim;

/* Animation to replicate to clients */
var         name                RepAnim;


/* If this Machine was placed inside a trader volume, store a reference to it here */
var     ShopVolume              TraderShop;


struct SReelSymbol
{
	var	float       ReelPosition;    // The Rotation (Roll) that this symbol inhabits on the reel.
	var	string      SymbolName;      // Name of the Symbol.
	var int         NumHits;         // The number of times this symbol was on the payline during the current spin.   Cleared each new spin.
};

var         SReelSymbol         ReelSymbols[NUMSYMBOLS];

var         bool                bActive;


replication
{
    reliable if(Role == Role_Authority)
       NumSpinning,RepAnim;
}

function PreBeginPlay()
{
    PreLoadSounds();
}

function PostBeginPlay()
{
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

	if ( default.Snd_ReelStoppedRef != "" )
	{
		Snd_ReelStopped = sound(DynamicLoadObject(default.Snd_ReelStoppedRef, class'Sound', true));
	}
	if( default.Snd_ReelSpinningRef != "")
	{
		Snd_ReelSpinning = sound(DynamicLoadObject(default.Snd_ReelSpinningRef, class'Sound', true));
	}
	if( default.Snd_MonsterPrizeRef != "")
	{
		Snd_MonsterPrize = sound(DynamicLoadObject(default.Snd_MonsterPrizeRef, class'Sound', true));
	}
	if( default.Snd_CashPrizeRef != "")
	{
		Snd_CashPrize = sound(DynamicLoadObject(default.Snd_CashPrizeRef, class'Sound', true));
	}

	for(i = 0 ; i < NUMAMBIENTSNDS ; i ++)
	{
        if( default.Snd_AmbientActiveRef[i] != "")
        {
            Snd_AmbientActive[i] = sound(DynamicLoadObject(default.Snd_AmbientActiveRef[i], class'Sound', true));
        }
	}
}

/* A player threw some cash at a slot machine . */
simulated event Touch( Actor Other )
{
    local Cashpickup DroppedCash;

    DroppedCash = CashPickup(Other);
    if(DroppedCash != none)
    {
        if(DroppedCash.bDroppedCash &&
        DroppedCash.CashAmount >= MaxBet &&
        DroppedCash.DroppedBy != none &&
        DroppedCash.DroppedBy.Pawn != none &&
        AttemptSpin(DroppedCash.DroppedBy.Pawn))
        {
            DroppedCash.SetRespawn();
        }
        else
        {
            /* Flings the dropped cash back at the guy who threw it.  */
           DroppedCash.Velocity  = vect(0,0,0);
        }
    }
}

/* Attempts to spin the slot reels. Returns true if successfull */
function bool   AttemptSpin(Pawn SlotPlayer)
{
    /* Dont' allow a new spin if the reels are already spinning or the machine is still paying out a prize */
    if(bActive &&
    !ReelsAreSpinning() &&
    RemainingPayOut == 0 &&
    !IsAnimating())
    {
        bNetNotify = true;
        NetUpdateTime = Level.TimeSeconds - 1;

        CurrentPlayer = SlotPlayer;
        if(RemainingBonusSpins > 0)
        {
            RemainingBonusSpins = Max(RemainingBonusSpins -1, 0) ;
        }

        CalculateReelPositions();
        PlayPullAnim();

        return true;
    }

    return false;
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    if(EventInstigator != none)
    {
        AttemptSpin(EventInstigator);
    }
}

function bool ReelsAreSpinning()
{
    return NumSpinning > 0;
}

/* The final positions for each reel are calculated before they actually start spinning */
function CalculateReelPositions()
{
    local int i,SymbolIndex;
    local string SymbolName;

    for(i = 0 ; i < ArrayCount(ReelSymbols) ; i ++)
    {
        ReelSymbols[i].NumHits = 0;
    }

    for(i = 0 ; i < ArrayCount(Reels) ; i ++)
    {
        DesiredRolls[i] = 11000.f * Round(RandRange(0,arraycount(ReelSymbols)-1)) ;
        SymbolName = GetSymbolAtPosition(DesiredRolls[i],SymbolIndex);
        log("["$i$"] : "$SymbolName);

        ReelSymbols[SymbolIndex].NumHits ++;
    }
}

function string GetSymbolAtPosition(float Position, optional out int Index)
{
    local int i;

    for(i = 0 ; i < arrayCount(ReelSymbols); i ++ )
    {
        if(Position == ReelSymbols[i].ReelPosition)
        {
            Index = i;
            return ReelSymbols[i].SymbolName;
        }
    }

    return "COULD NOT FIND A REEL SYMBOL AT POSITION :"$Position;
}

function SpinReels()
{
    local int i;

    if(Level.NetMode == NM_Client)
    {
        return;
    }

    LastSpinTime = Level.TimeSeconds;

    for(i = 0 ; i < ArrayCount(Reels) ; i ++)
    {
        Reels[i].bFixedRotationDir = true;
        Reels[i].bRotateToDesired = false;

        NumSpinning ++ ;
    }

    if(SlotSpinAnim != '')
    {
        SetRepAnim(SlotSpinAnim);
    }
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


/* Is this Machine open for business ? */
function SetActive(bool On)
{
    local int i;

    for(i = 0 ; i < NUMREELS ; i ++)
    {
        if(Reels[i] != none)
        {
            Reels[i].bHidden = !On;
        }
    }

    bHidden = !On;
/*    bActive = On;

    if(bActive)
    {
        AmbientSound = Snd_AmbientActive[Rand(NUMAMBIENTSNDS)] ;
    }
    else
    {
        AmbientSound = none;
    }
*/
}

function Tick(Float DeltaTime)
{
    local int i;

    CheckShopState();

    if(RemainingBonusSpins > 0)
    {
        AttemptSpin(CurrentPlayer);
    }

    if(!ReelsAreSpinning())
    {
        return;
    }

    if(Level.TimeSeconds - LastSpinTime >= SpinDuration)
    {
        for(i = 0 ; i < ArrayCount(Reels) ; i ++)
        {
            if(Reels[i].bFixedRotationDir &&
            Level.TimeSeconds - LastReelStopTime >= 1.f)
            {
                LastReelStopTime = Level.TimeSeconds;

                Reels[i].bFixedRotationDir = false;
                Reels[i].bRotateToDesired = true;
                Reels[i].DesiredRotation.Roll = DesiredRolls[i];

                NumSpinning -- ;

                if(Snd_ReelStopped != none)
                {
                    PlaySound(Snd_ReelStopped,,1.0,,100,,true);
                }
            }
        }
    }

    if(NumSpinning == 0)
    {
        PayOut();
    }
}

/* Spits out a reward based on the symbols on the reels */
function PayOut()
{
    local int i;
    local bool bWon;

    for(i=0; i < ArrayCount(ReelSymbols) ; i ++)
    {
        /* 3 of a kind. */

        if(ReelSymbols[i].NumHits == Arraycount(Reels))
        {
            bWon = ReelSymbols[i].SymbolName != "Puke" && ReelSymbols[i].SymbolName != "JackPot";

            switch(ReelSymbols[i].SymbolName)
            {
                Case "Puke"         :   PlayPukeAnim() ;            break;
                Case "Dosh"         :   SpawnCash(1000);            break;
                Case "TeamDosh"     :   SpawnTeamCash(1000);        break;
                Case "JackPot"      :   DestroyMachine();           break;
                Case "Armor"        :   SpawnArmor();               break;
                Case "Weapon"       :   SpawnRandomWeapon();        break;
            }
        }
    }

    if(!bWon)  // didnt win anything, or won something bad.
    {
        if(LoseAnim != '' && !IsAnimating())
        {
            SetRepAnim(LoseAnim);
        }
    }
    else
    {
        if(WinAnim != '' && !IsAnimating())
        {
            SetRepAnim(WinAnim);
        }
    }
}

/* If you win the jackpot, the machine explodes!  isn't that hilarious?!  */
function DestroyMachine()
{
    TraderShop = none;
    Spawn(class 'KFMod.KFDoorExplodeMetal');
    SetActive(false);
}

/* Reels landed on the puke 'reward' .
play an animation of the mouth opening and vomitting on the player*/
function PlayPukeAnim()
{
    if(PukeAnim != '')
    {
        SetRepAnim(PukeAnim);
    }
}

/* The machine was just used by a player.  Make the lever animate*/
function PlayPullAnim()
{
    if(SlotPullAnim != '')
    {
        SetRepAnim(SlotPullAnim);
    }
}

/* Start of the animation process
Assigns a new animation to be played.

Network : Server
*/

function SetRepAnim( name NewAnim)
{
    RepAnim = NewAnim;
    InternalPlayAnim(NewAnim);
}

/* A variable was replicated.
Check if we need to play a new animation on the client

Network : Clients
*/

simulated event PostNetReceive()
{
    if(RepAnim != LastClientAnim)
    {
        LastClientAnim = RepAnim;
        InternalPlayAnim(RepAnim);

        LastClientAnim = '';
    }
}

/* Handle the actual playing of the animation

Network : All

*/
simulated function InternalPlayAnim(name AnimToPlay)
{
    PlayAnim(AnimToPlay,1.f,0.1);
}

/* Pukey the Clown head pukes on the player.  Called via animation script notify*/
function PukeOnMe()
{
    Spawn(class'KFMod.BileJet', self,,GetPukeSpawnLocation(),Rotation);
    if(Snd_MonsterPrize != none)
    {
        PlaySound(Snd_MonsterPrize,,1.0,,100,,true);
    }
}

/* Give the player some dosh */
function SpawnCash(int Amount)
{
    local PlayerController PC;

    if(Snd_CashPrize != none)
    {
        PlaySound(Snd_CashPrize);
    }

    if(CurrentPlayer != none && CurrentPlayer.Controller != none)
    {
        PC = PlayerController(Currentplayer.Controller);
        if(PC != none)
        {
			PC.ClientPlaySound(class 'CashPickup'.default.PickupSound);
            PC.ReceiveLocalizedMessage(class 'Msg_CashReward',Amount);

            PC.PlayerReplicationInfo.Score += Amount;
            PC.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		}
	}
}

/* Same as SpawnCash, but for the whole team */
function SpawnTeamCash(int Amount)
{
    local PlayerController PC;
    local Controller C;

    if(Snd_CashPrize != none)
    {
        PlaySound(Snd_CashPrize);
    }

	For ( C= Level.ControllerList; C!=None; C=C.NextController )
	{
        PC = PlayerController(C);
        if(PC != none)
        {
			PC.ClientPlaySound(class 'CashPickup'.default.PickupSound);
            PC.ReceiveLocalizedMessage(class 'Msg_CashReward',Amount);

            PC.PlayerReplicationInfo.Score += Amount;
            PC.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		}
	}
}


function AddBonusSpins(int NumToAdd)
{
    RemainingBonusSpins += NumToAdd;
    AttemptSpin(CurrentPlayer);
}

/* Fling prizes in the direction of the player who played the machine*/
simulated function vector GetPayoutVelocity()
{
    return Normal(Vector(Rotation)) * 250.f + VRand()*50.f ;
}

function Timer()
{
    SpawnCash(RemainingPayOut);
}

function vector GetPayoutLocation(optional float SpawnOffset)
{
    return Location + Normal(Vector(Rotation)) * ((CollisionRadius/2) + (SpawnOffset/2)) ;
}

function vector GetPukeSpawnLocation()
{
    return GetPayoutLocation() + (vect(0,0,1) * Collisionheight/2) ;
}

function SpawnArmor()
{
    local Vest NewArmor;

    NewArmor = Spawn(class 'KFMod.Vest',CurrentPlayer,,GetPayoutLocation(class 'KFMod.Vest'.default.CollisionRadius),Rotation);
    if(NewArmor != none)
    {
        NewArmor.bOnlyOwnerSee = true;
    }
}

/* Pops a random weapon out of the slot machine that only the betting player can see*/
function SpawnRandomWeapon()
{
    local KFGameType KFGI;
    local Pickup NewPickup;
    local int i;
    local int RandIdx;
    local array < class<Pickup> >  ValidPickupClasses;
    local class<Pickup> WeaponClass;

    KFGI = KFGameType(Level.Game);
    if(KFGI == none)
    {
        return;
    }

    if(KFGI.KFLRules != none)
    {
        for(i = 0 ; i < KFGI.KFLRules.MAX_BUYITEMS ; i ++)
        {
            if(KFGI.KFLRules.ItemForSale[i] != none)
            {
                ValidPickupClasses[ValidPickupClasses.length] = KFGI.KFLRules.ItemForSale[i] ;
            }
        }
    }

    RandIdx = Rand(ValidPickupClasses.length);
    WeaponClass = ValidPickupClasses[RandIdx];
    NewPickup = Spawn(WeaponClass,CurrentPlayer,,GetPayoutLocation(WeaponClass.default.CollisionRadius),Rotation);

    if(NewPickup == none)
    {
        log("Warning - "@self@" could not spawn a pickup of class : "@WeaponClass);
    }
    else
    {
        NewPickup.bOnlyOwnerSee = true;
    }
}

defaultproperties
{
     SpinDuration=6.000000
     Snd_ReelStoppedRef="SteamLand_SND.SlotMachine_ReelStop"
     Snd_ReelSpinningRef="FreakCircus_Snd_two.Test.arcade6"
     Snd_MonsterPrizeRef="Hellride_Snd.General.KF_HellRide_EvilLaugh_02"
     Snd_CashPrizeRef="SteamLand_SND.SlotMachine_Dosh"
     Snd_AmbientActiveRef(0)="SteamLand_SND.Ambient_SlotMachine_1"
     Snd_AmbientActiveRef(1)="SteamLand_SND.Ambient_SlotMachine_2"
     Snd_AmbientActiveRef(2)="SteamLand_SND.Ambient_SlotMachine_3"
     MaxBet=25
     CashPayOutInterval=0.250000
     SlotPullAnim="Pull"
     SlotSpinAnim="Spin"
     PukeAnim="puke"
     LoseAnim="Lose"
     WinAnim="Win1"
     ReelSymbols(0)=(SymbolName="Puke")
     ReelSymbols(1)=(ReelPosition=11000.000000,SymbolName="TeamDosh")
     ReelSymbols(2)=(ReelPosition=22000.000000,SymbolName="Dosh")
     ReelSymbols(3)=(ReelPosition=33000.000000,SymbolName="Armor")
     ReelSymbols(4)=(ReelPosition=44000.000000,SymbolName="Weapon")
     ReelSymbols(5)=(ReelPosition=55000.000000,SymbolName="JackPot")
     DrawType=DT_Mesh
     bUseDynamicLights=True
     bStatic=True
     RemoteRole=ROLE_None
     NetUpdateFrequency=1.000000
     Mesh=SkeletalMesh'Pier_anim.Slots'
     CollisionRadius=35.000000
     CollisionHeight=60.000000
     bCollideActors=True
     bUseCylinderCollision=True
     bNetNotify=True
     bDirectional=True
}
