//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KFClotMut extends Mutator;

function PostBeginPlay()
{
	SetTimer(0.1,False);
}
function Timer()
{
	local KFGameType KF;
	local byte i;
	local class<KFMonster> MC;

	KF = KFGameType(Level.Game);
	MC = Class<KFMonster>(DynamicLoadObject("KFChar.ZombieClot",Class'Class'));
	if ( KF!=None && MC!=None )
	{
		// groups of monsters that will be spawned
		KF.InitSquads.Length = 1;
		KF.InitSquads[0].MSquad.Length = 8;
		for( i=0; i<8; i++ )
			KF.InitSquads[0].MSquad[i] = MC;
	}
	Destroy();
}

defaultproperties
{
     GroupName="KF-MonsterMut"
     FriendlyName="Clot Buster"
     Description="Only Clots will appear during the game."
}
