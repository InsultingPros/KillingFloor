//=============================================================================
// ACTION_Monsterize.
// Spawn a MonsterController for this Pawn and have it possess the Pawn.
// by SuperApe -- Dec 2005
//=============================================================================
class ACTION_Monsterize extends ScriptedAction;
 
var()        name   MonsterControllerTag;
var()        class<Controller>  ControllerToSpawnFor;

function bool InitActionFor( ScriptedController C )
{
	local Controller SpawnedController;
	local Pawn P;

	P = C.Pawn;
	if( P==None )
		return false;
	if( ControllerToSpawnFor==None && Monster(P)!=None && Monster(P).ControllerClass!=None )
		ControllerToSpawnFor = Monster(P).ControllerClass;
	SpawnedController = C.spawn( ControllerToSpawnFor, None );
	if( SpawnedController==None )
		return false;
	SpawnedController.Tag = MonsterControllerTag;
	C.Pawn.Controller = None;
	C.Pawn = None;
	SpawnedController.Possess(P);
	return false;
}

defaultproperties
{
}
