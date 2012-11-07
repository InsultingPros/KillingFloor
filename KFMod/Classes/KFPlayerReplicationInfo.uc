// Custom KF Player Rep info. Now including experience levels.
class KFPlayerReplicationInfo extends xPlayerReplicationInfo;

//var float CurrentExperience, ExperienceLevel, ExpThreshold,
var float MGAmmo; //, CurrentWeight;
var bool bBuyingStuff, bStartingEquipmentChosen;
var int ThreeSecondScore; // Total of the points accrued in the last 3 seconds.  Cleared every 3 seconds.
var int PlayerHealth; // How much heal the player has. Used by the KFscoreboard.
var bool bViewingMatineeCinematic;
var string SubTitle[5];
var bool bWideScreenOverlay;

var class<KFVeterancyTypes> ClientVeteranSkill;
var	int						ClientVeteranSkillLevel;

var int CashThrowAmount; // Amount of cash a player throws per keypress.   Set in the player settings menu

var FakePlayerPawn BlamePawn;

replication
{
	// Things the server should send to the client.
	reliable if ( bNetDirty && (Role == Role_Authority) )
		bWideScreenOverlay,SubTitle,PlayerHealth,bBuyingStuff,bStartingEquipmentChosen,
		ThreeSecondScore,bViewingMatineeCinematic,ClientVeteranSkill,ClientVeteranSkillLevel;
}

/*
// KFTODO: Removed this hack for now, since it was making VOIP not work. Not sure what it did
// in the first place - Ramm
simulated function PostNetBeginPlay()
{
	local VoiceChatReplicationInfo VRI;

	VoiceType = class<VoicePack>(DynamicLoadObject(VoiceTypeName,class'Class'));

	if ( Level.GRI != None )
		Level.GRI.AddPRI(self);
	foreach DynamicActors(class'VoiceChatReplicationInfo', VRI)
	{
		VoiceInfo = VRI;
		break;
	}
}*/

simulated function SetGRI(GameReplicationInfo GRI)
{
	GRI.AddPRI(self);
}
function Timer()
{
	local Controller C;

	SetTimer(0.5 + FRand(), False);
	UpdatePlayerLocation();
	C = Controller(Owner);
	if( C==None )
		Return;
	if( C.Pawn==None )
		PlayerHealth = 0;
	else PlayerHealth = C.Pawn.Health;

	if( !bBot )
	{
		if ( !bReceivedPing )
			Ping = Min(int(0.25 * float(C.ConsoleCommand("GETPING"))),255);
	}
}
function Reset()
{
	if( KFGameType(Level.Game)!=None )
	{
		Score = KFGameType(Level.Game).StartingCash;
		Deaths = 0;
		HasFlag = None;
		bReadyToPlay = false;
		NumLives = 1;
		bOutOfLives = True;
	}
	else Super.Reset();
}
simulated function Destroyed()
{
	if( BlamePawn!=None )
		BlamePawn.Destroy();
	Super.Destroyed();
}
function FakePlayerPawn GetBlamePawn()
{
	if( BlamePawn!=None )
		Return BlamePawn;
	BlamePawn = Spawn(Class'FakePlayerPawn',,,vect(0,0,0));
	if( BlamePawn==None )
		Return None;
	BlamePawn.PlayerReplicationInfo = Self;
	BlamePawn.Controller = Controller(Owner);
}

defaultproperties
{
     PlayerHealth=100
     PlayerName="Fresh Meat"
     VoiceTypeName="KFCoreVoicePack.AussieVoice"
}
