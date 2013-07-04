class ACTION_OpenRandomTrader extends ScriptedAction;

var ()  bool                  bCloseOtherShops;
var ()  bool                  bOpenDoor;
var ()  bool                  bUseExistingShop;
var     ShopVolume            CurrentShop;

var array<ShopVolume>         Shops;

function CacheShops()
{
    local ShopVolume Shop;

    Shops.length = 0 ;
    foreach AllObjects(class 'ShopVolume',  Shop)
    {
        Shops[Shops.length] = Shop ;
    }
}

function bool InitActionFor(ScriptedController C)
{
    CacheShops();
    CurrentShop = GetCurrentShop(C);

    if(!bUseExistingShop || CurrentShop == none)
    {
        FindNewShop(C);
    }

    HandleShops();

    return true;
}

function FindNewShop(ScriptedController C)
{
    local ShopVolume NewShop;
    local KFGameReplicationInfo KFGRI;

    NewShop = Shops[Rand(Shops.length)] ;
    KFGRI = KFGameReplicationInfo(C.Level.game.GameReplicationInfo) ;
    if(KFGRI != none)
    {
        KFGRI.CurrentShop = NewShop;
    }
    CurrentShop = KFGRi.CurrentShop ;
    HandleShops();
}

function HandleShops()
{
    if(CurrentShop != none)
    {
        if(bOpenDoor && !CurrentShop.bCurrentlyOpen)
        {
            OpenSelectedShop();
        }

        CloseOtherShops();
    }
}

function CloseOtherShops()
{
    local int i;

    if(bCloseOtherShops)
    {
        for(i = 0 ; i < Shops.length ; i ++)
        {
            if(Shops[i].bCurrentlyOpen)
            {
                Shops[i].BootPlayers();
                Shops[i].CloseShop();
            }
        }
    }
}

function ShopVolume GetCurrentShop(ScriptedController C)
{
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(C.Level.game.GameReplicationInfo) ;
    if(KFGRI != none)
    {
        return KFGRi.CurrentShop ;
    }
}

function OpenSelectedShop()
{
    CurrentShop.InitTeleports();
    CurrentShop.OpenShop();
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
     bCloseOtherShops=True
     ActionString="Open Random Trader Shop"
}
