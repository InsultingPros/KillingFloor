//=============================================================================
// KF Soldier. This guy will follow you and engage enemy zombies.
//=============================================================================
class KFSoldierFriendly extends KFHumanPawn;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    
    if ( (ControllerClass != None) && (Controller == None) )
        Controller = spawn(ControllerClass);
    if ( Controller != None )
    {
        Controller.Possess(self);
    }
}

defaultproperties
{
     RequiredEquipment(0)="none"
     RequiredEquipment(1)="none"
     RequiredEquipment(2)="KFMod.Shotgun"
     Mesh=SkeletalMesh'KFSoldiers.Powers'
     Skins(0)=Texture'KFCharacters.PowersSkin'
}
