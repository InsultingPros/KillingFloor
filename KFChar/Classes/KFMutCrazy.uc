//-----------------------------------------------------------
// Written by Marco
//-----------------------------------------------------------
class KFMutCrazy extends Mutator;

var int LastSetWave;

function PostBeginPlay()
{
	SetTimer(0.1,False);
}
function Timer()
{
	local KFGameType KF;
	local int i,j;

	KF = KFGameType(Level.Game);
	if ( KF!=None )
	{
		for( i=0; i<KF.InitSquads.Length; i++ )
		{
			for( j=0; j<KF.InitSquads[i].MSquad.Length; j++ )
				KF.InitSquads[i].MSquad[j] = GetReplaceClass(KF.InitSquads[i].MSquad[j]);
		}
		for( i=0; i<KF.MonsterCollection.default.SpecialSquads.Length; i++ )
		{
			for( j=0; j<KF.MonsterCollection.default.SpecialSquads[i].ZedClass.Length; j++ )
				ReplaceMonsterStr(KF.MonsterCollection.default.SpecialSquads[i].ZedClass[j]);
		}
		for( i=0; i<KF.MonsterCollection.default.FinalSquads.Length; i++ )
		{
			for( j=0; j<KF.MonsterCollection.default.FinalSquads[i].ZedClass.Length; j++ )
				ReplaceMonsterStr(KF.MonsterCollection.default.FinalSquads[i].ZedClass[j]);
		}
		KF.FallbackMonster = GetReplaceClass( Class<KFMonster>(KF.FallbackMonster) );
		KF.MonsterCollection.default.EndGameBossClass = string(Class'ZombieBossMix');
	}
	Destroy();
}
final function Class<KFMonster> GetReplaceClass( Class<KFMonster> MC )
{
	switch( MC )
	{
	case Class'ZombieClot':
		return Class'ZombieClotMix';
	case Class'ZombieBloat':
		return Class'ZombieBloatMix';
	case Class'ZombieCrawler':
		return Class'ZombieCrawlerMix';
	case Class'ZombieStalker':
		return Class'ZombieStalkerMix';
	case Class'ZombieSiren':
		return Class'ZombieSirenMix';
	case Class'ZombieScrake':
		return Class'ZombieScrakeMix';
	case Class'ZombieFleshPound':
		return Class'ZombieFleshPoundMix';
	case Class'ZombieGorefast':
		return Class'ZombieGorefastMix';
	case Class'ZombieBoss':
		return Class'ZombieBossMix';
	default:
		return MC;
	}
}
final function ReplaceMonsterStr( out string MC )
{
	if( MC~="KFChar.ZombieClot" )
		MC = "KFChar.ZombieClotMix";
	else if( MC~="KFChar.ZombieBloat" )
		MC = "KFChar.ZombieBloatMix";
	else if( MC~="KFChar.ZombieCrawler" )
		MC = "KFChar.ZombieCrawlerMix";
	else if( MC~="KFChar.ZombieStalker" )
		MC = "KFChar.ZombieStalkerMix";
	else if( MC~="KFChar.ZombieSiren" )
		MC = "KFChar.ZombieSirenMix";
	else if( MC~="KFChar.ZombieScrake" )
		MC = "KFChar.ZombieScrakeMix";
	else if( MC~="KFChar.ZombieFleshPound" )
		MC = "KFChar.ZombieFleshPoundMix";
	else if( MC~="KFChar.ZombieGorefast" )
		MC = "KFChar.ZombieGorefastMix";
	else if( MC~="KFChar.ZombieBoss" )
		MC = "KFChar.ZombieBossMix";
}

defaultproperties
{
     GroupName="KF-MonsterMut"
     FriendlyName="Scramble Mode!"
     Description="Give specimen random models"
}
