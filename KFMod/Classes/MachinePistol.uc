// Full Auto version of the  standard 9mm
class MachinePistol extends KFWeapon;

function byte BestMode()
{
        return 0;

}

defaultproperties
{
     MagCapacity=40
     ReloadRate=2.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="ReloadPistol"
     HudImage=Texture'KFKillMeNow.SingleHUD'
     Weight=4.000000
     FireModeClass(0)=Class'KFMod.MachinePFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'KFPlayerSound.getweaponout'
     AIRating=0.250000
     CurrentRating=0.250000
     bShowChargingBar=True
     Description="A fully automatic 9mm pistol.."
     DisplayFOV=70.000000
     Priority=3
     SmallViewOffset=(X=13.000000,Y=18.000000,Z=-10.000000)
     InventoryGroup=2
     GroupOffset=6
     PickupClass=Class'KFMod.MachinePistolPickup'
     PlayerViewOffset=(X=4.000000,Y=5.500000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'KFMod.SingleAttachment'
     IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
     ItemName="Machine-Pistol"
}
