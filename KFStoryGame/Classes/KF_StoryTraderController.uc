/*
	--------------------------------------------------------------
    KF_StoryTraderController
	--------------------------------------------------------------

    This Actor is used to control the opening / closing of trader shops
    in story mode missions .

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_StoryTraderController extends info
placeable;

enum EShopAction
{
   Action_OpenCurrentShop,
   Action_SelectNewShop,
};

var () EShopAction              ShopAction;
var    ShopVolume               CurrentShop;
var    KFGameReplicationInfo    KFGRI;

/* List of shops we want to active / de-activate */
var () array<ShopVolume>        Shops;

/* Should we disable player collision when the trader is activated ? */
var () bool                     bDisablePlayerCollision;

/* Should we remove pickups from the ground when the trader shop closes ? */
var () bool                     bDestroyPickupsOnShopClose;

event PostBeginPlay()
{
     Super.PostBeginPlay();
     KFGRI = KFGameReplicationInfo(Level.game.GameReplicationInfo) ;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
    switch(ShopAction)
    {
        case Action_SelectNewShop       :
             CloseCurrentShop();
             FindNewShop();
             break;
        case Action_OpenCurrentShop     :
             OpenCurrentShop();
             break;
    }
}

function OpenCurrentShop()
{
    local Controller C;

    if(GetCurrentShop() == none)
    {
        FindNewShop();
    }

    log("=========================================",'Story_Debug');
    log("OPEN trader shop : "@GetCurrentShop(),'Story_Debug');

    GetCurrentShop().OpenShop();

    if(KFGameType(Level.Game) != none)
    {
        KFGameType(Level.Game).bTradingDoorsOpen = true;
    }

    /* Maybe disable player collision when the shop is opened ? */
    if(bDisablePlayerCollision)
    {
        for ( C = Level.ControllerList; C != none; C = C.NextController )
        {
            if(C.Pawn != none && C.Pawn.Health > 0 )
            {
                C.Pawn.bBlockActors = false;
            }
        }
    }
}

function bool CloseCurrentShop()
{
    local bool bSuccessfulBoot;
    local Controller C;
    local WeaponPickup DroppedWeapon;

    if(GetCurrentShop() == none ||
    !GetCurrentShop().bCurrentlyOpen)
    {
        return false;
    }

    log("=========================================",'Story_Debug');
    log("CLOSE trader shop : "@GetCurrentShop(),'Story_Debug');

    bSuccessfulBoot = GetCurrentShop().BootPlayers();
    GetCurrentShop().CloseShop();

	// wait for doors to close before BootPlayers (see KFGameInfo.Timer)
	SetTimer(1.f, false);

    if( KFGameType(Level.Game) != none)
    {
        KFGameType(Level.Game).bTradingDoorsOpen = false;
    }

    /* Post Buy-Menu garbage collection & Player Collision Handling */
    for ( C = Level.ControllerList; C != none; C = C.NextController )
    {
        /* Maybe turn player collision back on ? */
        if ( bDisablePlayerCollision &&
        C.Pawn != none && C.Pawn.Health > 0 )
        {
            C.Pawn.bBlockActors = C.Pawn.default.bBlockActors;
        }

        if(KFPlayerController(C) != none)
        {
            KFPlayerController(C).ClientForceCollectGarbage();
        }
    }

    /* Maybe remove dropped weapons from the ground ? */
    if(bDestroyPickupsOnShopClose)
    {
        foreach AllActors(class'WeaponPickup', DroppedWeapon)
        {
            if ( DroppedWeapon.bDropped )
            {
                DroppedWeapon.Destroy();
            }
        }
    }

    if(!bSuccessfulBoot)
    {
        log("WARNING !! - Couldn't boot all players out of Shop : "@GetCurrentShop(),'Story_Debug');
    }

    return bSuccessfulBoot;

}

function Timer()
{
	if(GetCurrentShop() != none && !GetCurrentShop().bCurrentlyOpen)
    {
		GetCurrentShop().BootPlayers();
    }
}

function FindNewShop()
{
    local ShopVolume NewShop;

    NewShop = Shops[Rand(Shops.length)] ;
    NewShop.InitTeleports();

    if(KFGRI != none)
    {
        KFGRI.CurrentShop = NewShop;
    }

    log("=========================================",'Story_Debug');
    log("FIND Trader Shop : "@GetCurrentShop(),'Story_Debug');

}

function ShopVolume GetCurrentShop()
{
    if(KFGRI != none)
    {
        return KFGRI.CurrentShop ;
    }
}

defaultproperties
{
     bDisablePlayerCollision=True
     bDestroyPickupsOnShopClose=True
     Texture=Texture'KFStoryGame_Tex.Editor.Trader_ico'
}
