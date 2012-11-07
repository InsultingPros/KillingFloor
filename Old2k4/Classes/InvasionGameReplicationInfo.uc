class InvasionGameReplicationInfo extends GameReplicationInfo;

var byte WaveNumber, BaseDifficulty, FinalWave;

replication
{
	reliable if ( bNetInitial && (Role == ROLE_Authority) )
		BaseDifficulty, FinalWave;
	reliable if(Role == ROLE_Authority)
		WaveNumber;
}

defaultproperties
{
}
