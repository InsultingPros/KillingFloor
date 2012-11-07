class KFBeatDownMut extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
 {

  // Only pansies need ammunition.
  if ( Other.IsA('KFRandomAmmoSpawn') )
  {
   ReplaceWith(Other, "None");
   return false;
  }
  

  if ( Other.IsA('KFRandomItemSpawn') )
  {
   KFRandomItemSpawn(Other).default.PickupClasses[0]= class 'KFMod.BatPickup' ;
   KFRandomItemSpawn(Other).default.PickupClasses[1]= class 'KFMod.AxePickup' ;
   KFRandomItemSpawn(Other).default.PickupClasses[2]= class 'KFMod.BatPickup' ;
   KFRandomItemSpawn(Other).default.PickupClasses[3]= class 'KFMod.BatPickup' ;
   KFRandomItemSpawn(Other).default.PickupClasses[4]= class 'KFMod.AxePickup' ;
   KFRandomItemSpawn(Other).default.PickupClasses[5]= class 'KFMod.BatPickup' ;
   KFRandomItemSpawn(Other).default.PickupClasses[6]= class 'KFMod.AxePickup' ;
   KFRandomItemSpawn(Other).default.PickupClasses[7]= class 'KFMod.BatPickup' ;
   return false;
  }

return true;


}

defaultproperties
{
     FriendlyName="BeatDown"
     Description="Melee Weapons only. For ye hard'uns."
}
