class CrossbuzzsawDeco extends Effects;

simulated function PostBeginPlay()
{
   	settimer(1.0, true);
   	PlayAnim('swing', 2.0);
}

simulated function timer()
{
    if (Owner == none )
    {
       SetTimer(0.0, false);
       Destroy();
    }
    else if (Pawn(Owner).Health < 0)
       gotostate('DeadPlayer');
}

state DeadPlayer
{

    simulated function BeginState()
    {
      settimer(4.0, false);
    }

    simulated function timer()
    {
           SetTimer(0.0, false);
       Destroy();
    }

}

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'KFWeaponModels.XbowBolt'
     DrawScale=19.000000
}
