// Freeze any players within it, when triggered.
//  If triggered again, unfreeze.
//  By : Alex

class KFPlayerFreezeVolume extends Volume;      //PhysicsVolume

var () class<Pawn> TypeToFreeze;
var () bool bNoJumping ;  // if you want to freeze jumps or not.
var () bool bForceCrouch; // if you want the players to be stuck in a crouch for the duration.
//var () bool bFreezeView; // if you want players not to be able to "look around"
var VolumeTimer CrouchCheckTimer;

simulated function Trigger( actor Other, pawn EventInstigator )
{
  local actor A;
  local Pawn P; 
  local Rotator VoidRotationRate;


    if ( CrouchCheckTimer == None )
    {
        CrouchCheckTimer = Spawn(class'VolumeTimer', Self);
        if ( CrouchCheckTimer != None )
            CrouchCheckTimer.TimerFrequency = 0.25;
    }

   ForEach TouchingActors(TypeToFreeze, A)
            if ( pawn(A)!= none)
            {
              P = pawn(A);
              P.bJumpCapable = !P.bJumpCapable;
             if(P.bJumpCapable)
             {
              P.AccelRate = P.default.AccelRate ;
              P.RotationRate = P.default.RotationRate;

             }
             else
              P.AccelRate = 0;
              P.RotationRate = VoidRotationRate;
            //   if(bNoJumping)

            }


}

function TimerPop(VolumeTimer T)
{
    local actor A;
    local Pawn          P;
    
    foreach TouchingActors(TypeToFreeze, A)
    {

      
      if( A != none )
      {
       P = pawn(A);
        if (bForceCrouch)
          P.ForceCrouch();
      }
    }
}

function DestroyCrouchChecker()
{
    if ( CrouchCheckTimer != None )
    {
        CrouchCheckTimer.Destroy();
        CrouchCheckTimer = None;
    }

}

defaultproperties
{
     bNoJumping=True
     bStatic=False
}
