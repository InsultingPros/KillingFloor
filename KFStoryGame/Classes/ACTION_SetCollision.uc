class ACTION_SetCollision extends ScriptedAction;

var(Action) bool bShouldCollideActors,bShouldBlockActors;
var(Action) name CollisionActorTag;

var Array<Actor> Target;

event PostBeginPlay( ScriptedSequence SS )
{
	local Actor A;

	if ( CollisionActorTag != '' )
	{
		ForEach SS.AllActors(class'Actor', A, CollisionActorTag)
			Target[Target.Length] = A;
	}
}

function bool InitActionFor(ScriptedController C)
{
	local int i;

	if ( Target.Length > 0 )
	{
		For (i=0; i<Target.Length; i++)
		{
			Target[i].SetCollision(bShouldCollideActors,bShouldBlockActors);
        }
    }
	else
	{
		C.GetInstigator().SetCollision(bShouldCollideActors,bShouldBlockActors);
	}

	return false;
}

defaultproperties
{
}
