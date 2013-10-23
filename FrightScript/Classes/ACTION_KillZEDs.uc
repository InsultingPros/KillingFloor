class ACTION_KillZEDs extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local KFMonster A ;

    ForEach C.DynamicActors(class'KFMonster', A)
    {
        A.Died(C,class'DamageType', A.Location) ;
    }

	return false;
}

defaultproperties
{
     ActionString="Kill ZEDs"
}
