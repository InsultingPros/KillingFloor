class KFFriendSoldierController extends KFInvasionBot;

function Possess(Pawn aPawn)
{
  Super(ScriptedController).Possess(aPawn);
  
  Pawn.MaxFallSpeed = 1.1 * Pawn.default.MaxFallSpeed; // so bots will accept a little falling damage for shorter routes
  Pawn.SetMovementPhysics();
 
   if (Pawn.Physics == PHYS_Walking)
    Pawn.SetPhysics(PHYS_Falling);
    WhatToDoNext(1);
    enable('NotifyBump');
}

function SetPawnClass(string inClass, string inCharacter)
{

}

defaultproperties
{
     PlayerReplicationInfoClass=None
}
