/*
	--------------------------------------------------------------
	Condition_TraderShop
	--------------------------------------------------------------

    A Type of timed condition which displays HUD info for Trader shops.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_TraderTime extends ObjCondition_Timed
editinlinenew;

var          bool           OldShopOpen;

/* Point the whisp at the pathnode closest to the Entrance to the trader shop*/

function       vector       GetWhispLocation(optional out Actor LocActor)
{
    LocActor = GetNearestPathNodeTo(GetAssociatedDoor().Location);
    return LocActor.Location;
}

function       bool         ShouldShowWhispTrailFor(PlayerController C)
{
    return Super.ShouldShowWhispTrailFor(C) && (KFPlayerController(C) == none || KFPlayerController(C).bWantsTraderPath) ;
}

/* Retrieves the Trader Door associated with the Currently Active Shop */
function    KFTraderDoor  GetAssociatedDoor()
{
    local int i;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(GetObjOwner().Level.game.GameReplicationInfo) ;
    if(GetObjOwner().StoryGI == none || KFGRI == none || KFGRI.CurrentShop == none)
    {
        return none;
    }

    for(i = 0 ; i < GetObjOwner().StoryGI.AllTraderDoors.length ; i ++)
    {
        if(GetObjOwner().StoryGI.AllTraderDoors[i].Tag == KFGRI.CurrentShop.Event)
        {
            return GetObjOwner().StoryGI.AllTraderDoors[i];
        }
    }

    return none;
}

/*Center the icon on the ShopVolume */

function        vector       GetLocation(optional out Actor LocActor)
{
    local KFGameReplicationInfo KFGRI;

    if(ConditionIsActive())
    {
        KFGRI = KFGameReplicationInfo(GetObjOwner().Level.game.GameReplicationInfo) ;
        if(KFGRI != none && KFGRI.CurrentShop != none)
        {
            LocActor = KFGRI.CurrentShop;
            return KFGRI.CurrentShop.Location ;
        }
    }

    return vect(0,0,0);
}


function ConditionTick(float DeltaTime)
{
    Super.ConditionTick(DeltaTime);
    UpdateWhispVisibility();
}

function ConditionDeActivated()
{
    Super.ConditionDeActivated();
    UpdateWhispVisibility();
}

function UpdateWhispVisibility()
{
    local bool NewShopOpen;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(GetObjOwner().Level.Game.GameReplicationInfo);
    if(KFGRI == none)
    {
        return;
    }

    if(KFGRI.CurrentShop != none)
    {
        NewShopOpen = KFGRI.CurrentShop.bCurrentlyOpen;

        // only show a whisp trail when the shop is open for business
        HUD_World.bShowWhispTrail = NewShopOpen ;

        OldShopOpen = NewShopOpen;
    }
}

defaultproperties
{
     bTraderTime=True
     HUD_World=(World_Texture=Texture'KFStoryGame_Tex.HUD.Trader_Icon_64',World_Hint="Trader",bShowWhispTrail=True,bIgnoreWorldLocHidden=True)
}
