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

var         string              Snd_ReelStoppedRef,Snd_ReelSpinningRef,Snd_MonsterPrizeRef,Snd_CashPrizeRef,Snd_JackpotRef, Snd_LeverPullRef;

var         Sound               Snd_ReelStopped,Snd_ReelSpinning,Snd_MonsterPrize,Snd_CashPrize,Snd_Jackpot,Snd_LeverPull;

// The volume to play these slot machine sounds at
var       float               ReelStoppedVolume, CashPrizeVolume, MonsterPrizeVolume, JackpotVolume, LeverPullVolume;
// The sound radius to use for these slot machine sounds
var       float               ReelSpinningRadius, ReelStoppedRadius, CashPrizeRadius, MonsterPrizeRadius, JackpotRadius, LeverPullRadius;

// The volume of the ambient sound when the real spinning is playing
var byte ReelSpinningVolume;

var         string              Snd_AmbientActiveRef[NUMAMBIENTSNDS];

var         Sound               Snd_AmbientActive[NUMAMBIENTSNDS];

var         Pawn                CurrentPlayer;

var() const name                YouLostEvent;

var() const name                YouWonEvent;

var         int                 RemainingPayOut;

// rate at which you accrue 'good karma' if you keep pulling and not hitting.
var() const float               JackPotChanceIncreaseRate;

var()       int                 MaxBet;

var         int                 RemainingBonusSpins;

var()       const edfindable    KF_StoryWaveDesigner    AssociatedDesigner;

var         float               JackPotChance;

var         bool                bFirstSpin;

/* ==== Animation Stuff =================================*/

/* Animation the slot machine plays when it is used */
var         name                SlotPullAnim;

var         byte                RepAnimByte,LastRepAnimByte;


struct SReelSymbol
{
	var	float       ReelPosition;    // The Rotation (Roll) that this symbol inhabits on the reel.
	var	string      SymbolName;      // Name of the Symbol.
    var int         NumReqHits;      // The number of hits this symbol requires to pay out.
	var int         NumHits;         // The number of times this symbol was on the payline during the current spin.   Cleared each new spin.
};

var         SReelSymbol         ReelSymbols[NUMSYMBOLS];

var         bool                bActive;

var() const bool                bStartActive;


replication
{
    reliable if(Role == Role_Authority && bNetDirty)
       RepAnimByte;
}

function PreBeginPlay()
{
    PreLoadSounds();
}

function PostBeginPlay()
{
    SetActive(bStartActive);
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

	if( default.Snd_JackpotRef != "")
	{
		Snd_Jackpot = sound(DynamicLoadObject(default.Snd_JackpotRef, class'Sound', true));
	}

	if( default.Snd_LeverPullRef != "")
	{
		Snd_LeverPull = sound(DynamicLoadObject(default.Snd_LeverPullRef, class'Sound', true));
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
        if(Snd_LeverPull != none)
        {
            PlaySound(Snd_LeverPull,SLOT_None,LeverPullVolume,false,LeverPullRadius,SoundPitch / 64.0);
        }

        AmbientSound = Snd_ReelSpinning;
        SoundVolume = ReelSpinningVolume;
        SoundRadius = ReelSpinningRadius;

        bNetNotify = true;
        NetUpdateTime = Level.TimeSeconds - 1;

        CurrentPlayer = SlotPlayer;
        if(RemainingBonusSpins > 0)
        {
            RemainingBonusSpins = Max(RemainingBonusSpins -1, 0) ;
        }

        CalculateReelPositions();

        if(SlotPullAnim != '')
        {
            RepAnimByte ++ ;
            PlayPullAnim();
        }

        return true;
    }

    return false;
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    SetActive(!bActive);
}

function bool ReelsAreSpinning()
{
    return NumSpinning > 0;
}

/* The final positions for each reel are calculated before they actually start spinning */
function CalculateReelPositions()
{
    local int i,idx;
    local string SymbolName;

    for(i = 0 ; i < ArrayCount(ReelSymbols) ; i ++)
    {
        ReelSymbols[i].NumHits = 0;
    }

//    log("CHANCE TO HIT JACKPOINT : "@JackPotChance*100$"%");

    for(i = 0 ; i < ArrayCount(Reels) ; i ++)
    {
        if(FRand() < JackPotChance)
        {
            DesiredRolls[i] = 0.f;
        }
        else
        {
            DesiredRolls[i] = 11000.f * Round(RandRange(0,arraycount(ReelSymbols)-1)) ;
        }

        SymbolName = GetSymbolAtPosition(DesiredRolls[i]);
//        log("["$i$"] : "$SymbolName);

        for(idx = 0 ; idx < arraycount(ReelSymbols) ; idx ++)
        {
            if(ReelSymbols[idx].SymbolName == SymbolName)
            {
                ReelSymbols[idx].NumHits ++;
            }
        }
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
        Reels[i].NetUpdateFrequency = 5;
        Reels[i].NetUpdateTime = Level.TimeSeconds - 1;

        NumSpinning ++ ;
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
            Reels[i].NetUpdateTime = Level.TimeSeconds - 1;
        }
    }

//   bHidden = !On;

    bActive = On;

    if(bActive)
    {
        AmbientSound = Snd_AmbientActive[Rand(NUMAMBIENTSNDS)] ;
        SoundVolume = default.SoundVolume;
        SoundRadius = default.SoundRadius;
    }
    else
    {
        AmbientSound = none;
    }

}

function Tick(Float DeltaTime)
{
    local int i;

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
                Reels[i].NetUpdateFrequency = Reels[i].default.NetUpdateFrequency ;

                NumSpinning -- ;

                if(Snd_ReelStopped != none)
                {
                    PlaySound(Snd_ReelStopped,,ReelStoppedVolume,false,ReelStoppedRadius,SoundPitch / 64.0);
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
    local int i,idx;
    local bool bWon;
    local array<String> WinningSymbols;
    local bool bAlreadyWonOnThisSymbol;

    AmbientSound = Snd_AmbientActive[Rand(NUMAMBIENTSNDS)];
    SoundVolume = default.SoundVolume;
    SoundRadius = default.SoundRadius;

    for(i=0; i < ArrayCount(ReelSymbols) ; i ++)
    {
        bAlreadyWonOnThisSymbol = false;

        for(idx = 0 ; idx < WinningSymbols.length ; idx ++)
        {
            if(ReelSymbols[i].SymbolName == WinningSymbols[idx])
            {
                bAlreadyWonOnThisSymbol = true;
                break;
            }
        }

        if(!bAlreadyWonOnThisSymbol && ReelSymbols[i].NumHits >= ReelSymbols[i].NumReqHits)
        {
            WinningSymbols[WinningSymbols.length] = ReelSymbols[i].SymbolName;

            if(!bWon && ReelSymbols[i].SymbolName == "Fuel")
            {
                bWon = true;
            }

            switch(ReelSymbols[i].SymbolName)
            {
                Case "Fuel"         :   SpawnFuel() ;                                                       break;
                Case "Ammo"         :   SpawnAmmo(ReelSymbols[i].NumHits - 1);                              break;
                Case "Monster"      :   SpawnEnemy(ReelSymbols[i].NumHits);                                 break;
            }
        }
    }

    if(!bWon)  // didnt win anything, or won something bad.
    {
        if(YouLostEvent != '')
        {
            TriggerEvent(YouLostEvent,self,CurrentPlayer);
        }

        // give the player a helping hand if he fails enough times.
        JackPotChance = FMin(JackPotChance + JackPotChanceIncreaseRate,1.f);
    }
    else
    {
        if(YouWonEvent != '')
        {
            TriggerEvent(YouWonEvent,self,CurrentPlayer);
        }

        JackPotChance = 0.f;  // reset.
    }

    if(bFirstSpin)
    {
        bFirstSpin = false;
    }
}

function SpawnAmmo(int NumToSpawn)
{
    local KF_Slot_AmmoPickup   AmmoPickup;
    local int i;

    if(Snd_CashPrize != none)
    {
        PlaySound(Snd_CashPrize,SLOT_None,CashPrizeVolume,false,CashPrizeRadius,SoundPitch / 64.0);
    }

    for(i = 0 ; i < NumToSpawn ; i ++)
    {
        AmmoPickup = Spawn(class 'KF_Slot_AmmoPickup',self,,GetPayoutLocation(),Rotation);
        if(AmmoPickup != none)
        {
            AmmoPickup.Velocity = GetPayoutVelocity() +  (i * GetPayoutVelocity()/2) ;
        }
    }
}

function SpawnFuel()
{
    local Pickup_GasCan   FuelPickup;

    FuelPickup = Spawn(class 'Pickup_GasCan',self,,GetPayoutLocation(),Rotation);
    if(FuelPickup != none)
    {
        FuelPickup.Velocity = GetPayoutVelocity();
    }

    if(Snd_Jackpot != none)
    {
        PlaySound(Snd_Jackpot,SLOT_None,JackpotVolume,,JackpotRadius,SoundPitch / 64.0);
    }

    if(bFirstSpin)
    {
        UnlockAchievement();
    }
}

// The player got the fuel on his first spin!
function UnlockAchievement()
{
    local Controller C;
	local KFPlayerController KFPC;
	local KFSteamStatsAndAchievements KFAchievements;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
        KFPC = KFPlayerController(C);
        if(KFPC != none)
        {
            KFAchievements = KFSteamStatsAndAchievements( KFPC.SteamStatsAndAchievements );
            if(KFAchievements != none)
            {
                KFAchievements.CheckAndSetAchievementComplete( KFAchievements.KFACHIEVEMENT_777 );
            }
        }
	}
}

function SpawnEnemy(int NumHits)
{
    local int i;
    local string Type;

    if(AssociatedDesigner == none)
    {
        log("Warning - No wave Designer associated with : "@self@" it will not be able to spawn ZEDs.");
        return;
    }

    Switch(NumHits)
    {
        case 1 :  Type = "Siren";       break;
        case 2 :  Type = "Scrake";      break;
        case 3 :  Type = "FleshPound";  break;
    }

    if(Type == "FleshPound" && Snd_MonsterPrize != none)
    {
        if(Snd_MonsterPrize != none)
        {
            PlaySound(Snd_MonsterPrize,SLOT_None,MonsterPrizeVolume,false,MonsterPrizeRadius,SoundPitch / 64.0);
        }
    }

    for(i = 0 ; i < AssociatedDesigner.Waves.Length ; i ++)
    {
        if(AssociatedDesigner.Waves[i].Wave_Spawns[0].SquadList[0] ~= Type)
        {
            if(AssociatedDesigner.Waves[i].WaveController != none)
            {
                AssociatedDesigner.Waves[i].WaveController.Trigger(self,none);
            }
        }
    }
}

/* The machine was just used by a player.  Make the lever animate*/
simulated function PlayPullAnim()
{
    PlayAnim(SlotPullAnim,1.f,0.1);
}

/* A variable was replicated.
Check if we need to play a new animation on the client

Network : Clients
*/

simulated event PostNetReceive()
{
    if(RepAnimByte != LastRepAnimByte)
    {
        LastRepAnimByte = RepAnimByte;
        PlayPullAnim();
    }
}

/* Give the player some dosh */
function SpawnCash(int Amount)
{
    local PlayerController PC;

    if(Snd_CashPrize != none)
    {
        PlaySound(Snd_CashPrize,SLOT_None,CashPrizeVolume,false,CashPrizeRadius);
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


function AddBonusSpins(int NumToAdd)
{
    RemainingBonusSpins += NumToAdd;
    AttemptSpin(CurrentPlayer);
}

/* Fling prizes in the direction of the player who played the machine*/
simulated function vector GetPayoutVelocity()
{
    return Normal(Vector(Rotation)) * 50.f + (Vect(0,0,1) * 25.f)  ;
}

function Timer()
{
    SpawnCash(RemainingPayOut);
}

function vector GetPayoutLocation(optional float SpawnOffset)
{
    return Location + Normal(Vector(Rotation)) * ((CollisionRadius/2) + (SpawnOffset/2)) ;
}

defaultproperties
{
     SpinDuration=6.000000
     Snd_ReelStoppedRef="SteamLand_SND.SlotMachine_ReelStop"
     Snd_ReelSpinningRef="FreakCircus_Snd_two.Test.arcade6"
     Snd_MonsterPrizeRef="Hellride_Snd.General.KF_HellRide_EvilLaugh_02"
     Snd_CashPrizeRef="SteamLand_SND.SlotMachine_Dosh"
     Snd_JackpotRef="SteamLand_SND.SlotMachine_JackPot"
     Snd_LeverPullRef="SteamLand_SND.SlotMachine_LeverPull"
     Snd_ReelSpinning=Sound'FreakCircus_Snd_two.Test.arcade6'
     ReelStoppedVolume=2.000000
     CashPrizeVolume=2.000000
     MonsterPrizeVolume=2.000000
     JackpotVolume=2.000000
     LeverPullVolume=2.000000
     ReelSpinningRadius=750.000000
     ReelStoppedRadius=500.000000
     CashPrizeRadius=500.000000
     MonsterPrizeRadius=500.000000
     JackpotRadius=750.000000
     LeverPullRadius=500.000000
     ReelSpinningVolume=255
     Snd_AmbientActiveRef(0)="SteamLand_SND.Ambient_SlotMachine_1"
     Snd_AmbientActiveRef(1)="SteamLand_SND.Ambient_SlotMachine_2"
     Snd_AmbientActiveRef(2)="SteamLand_SND.Ambient_SlotMachine_3"
     JackPotChanceIncreaseRate=0.020000
     MaxBet=50
     bFirstSpin=True
     SlotPullAnim="Pull"
     ReelSymbols(0)=(SymbolName="Fuel",NumReqHits=3)
     ReelSymbols(1)=(ReelPosition=11000.000000,SymbolName="Ammo",NumReqHits=2)
     ReelSymbols(2)=(ReelPosition=22000.000000,SymbolName="Monster",NumReqHits=1)
     ReelSymbols(3)=(ReelPosition=33000.000000,SymbolName="Fuel",NumReqHits=3)
     ReelSymbols(4)=(ReelPosition=44000.000000,SymbolName="Ammo",NumReqHits=2)
     ReelSymbols(5)=(ReelPosition=55000.000000,SymbolName="Monster",NumReqHits=1)
     DrawType=DT_Mesh
     bUseDynamicLights=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=1.000000
     Mesh=SkeletalMesh'FrightYard_SKM.GasPump_Slots'
     bFullVolume=True
     SoundRadius=250.000000
     CollisionRadius=35.000000
     CollisionHeight=60.000000
     bCollideActors=True
     bUseCylinderCollision=True
     bNetNotify=True
     bDirectional=True
}
