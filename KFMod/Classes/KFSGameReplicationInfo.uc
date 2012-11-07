class KFSGameReplicationInfo extends KFGameReplicationInfo;

var KFSPLevelinfo KFPLevel; // Easier to do it this way.
var int CurrentObjectiveNum,ClientObjNum;

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority )
		CurrentObjectiveNum;
}

simulated function PostBeginPlay()
{
	Tag = 'NextObjective';
	Super.PostBeginPlay();
}
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	ClientObjNum = CurrentObjectiveNum;
	bNetNotify = True;
}

function Trigger( actor Other, pawn EventInstigator )
{
	local PlayerController PC;

	CurrentObjectiveNum++;
	PC = Level.GetLocalPlayerController();
	if( PC!=None )
		PC.ReceiveLocalizedMessage(Class'KFObjectiveMsg',CurrentObjectiveNum,,,KFPLevel);
}

simulated function PostNetReceive()
{
	local PlayerController PC;

	if( CurrentObjectiveNum!=ClientObjNum )
	{
		ClientObjNum = CurrentObjectiveNum;
		PC = Level.GetLocalPlayerController();
		if( PC!=None )
			PC.ReceiveLocalizedMessage(Class'KFObjectiveMsg',CurrentObjectiveNum,,,KFPLevel);
	}
}

defaultproperties
{
}
