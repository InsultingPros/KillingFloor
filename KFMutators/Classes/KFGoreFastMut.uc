//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFGoreFastMut extends Mutator;

function PostBeginPlay()
{
	SetTimer(0.1,False);
}
function Timer()
{
	local KFGameType KF;
	local byte i;
	local class<KFMonster> MC;
	local int MSquadLength;

	KF = KFGameType(Level.Game);
	MC = Class<KFMonster>(DynamicLoadObject(KF.GetEventGoreFastClassName(),Class'Class'));
	if ( KF!=None && MC!=None )
	{
		// groups of monsters that will be spawned
		KF.InitSquads.Length = 1;
		MSquadLength = Min( 8, KF.MaxZombiesOnce );
		KF.InitSquads[0].MSquad.Length = MSquadLength;
		for( i=0; i<MSquadLength; i++ )
			KF.InitSquads[0].MSquad[i] = MC;
	}
	Destroy();
}

defaultproperties
{
     GroupName="KF-MonsterMut"
     FriendlyName="Gored Fast"
     Description="Only GoreFasts will appear during the game."
}
