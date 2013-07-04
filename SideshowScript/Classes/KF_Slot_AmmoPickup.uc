class KF_Slot_AmmoPickup extends KFAmmoPickup;

event PostBeginPlay()
{
    Super(Pickup).PostBeginPlay();
    GotoState('Pickup');
}

defaultproperties
{
     RespawnTime=0.000000
}
