class ACTION_ChangeConditionLoc extends ScriptedAction;

var ()  KF_ObjectiveCondition AssociatedCondition;
var ()  actor                 NewLocation;

function bool InitActionFor(ScriptedController C)
{
   if(AssociatedCondition != none)
   {
      AssociatedCondition.HUD_World.World_Location = NewLocation;
   }

   return false;
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
     ActionString="Update Condition Loc"
}
